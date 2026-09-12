local actions = require("rbook.actions")
local catalog = require("rbook.catalog")
local config = require("rbook.config")
local deps = require("rbook.deps")

local M = {}

-- 过滤放在 picker 打开这一刻，而不是塞进 scanner：
-- catalog 是全局内存缓存，按 filetype 过滤会让缓存被某个 filetype 污染。

local function extension_of(path)
  return path and path:match("%.([%w_%-]+)$") or nil
end

-- 当前 buffer 该放行哪些扩展名。
-- 返回 nil 表示不过滤（show_all / 开关关掉 / filetype 未登记）。
local function allowed_extensions(show_all)
  if show_all then
    return nil
  end
  local files = config.get().files or {}
  if files.filter_by_filetype == false then
    return nil
  end

  local ft = vim.bo.filetype
  local exts = (files.filetype_extensions or {})[ft]
  if not exts or #exts == 0 then
    return nil, ft -- 未登记的 filetype：看全部
  end

  local allow = {}
  for _, ext in ipairs(exts) do
    allow[ext] = true
  end
  return allow, ft
end

local function extension_allowed(item, allow)
  if not allow then
    return true
  end
  local ext = extension_of(item.code_path)
  return ext ~= nil and allow[ext] == true
end

-- 模板：没有 language 的条目视为通用模板，始终放行。
-- 有 language 时仍按 code_path 的后缀判断（code.yaml 里两者实测完全一致）。
local function template_allowed(item, allow)
  if not allow then
    return true
  end
  if not item.language or item.language == "" then
    return true
  end
  return extension_allowed(item, allow)
end

local function title_for(base, ft, allow)
  if not allow then
    return base .. " · 全部"
  end
  return base .. " · " .. ft
end

local function text_for_template(item)
  local tags = table.concat(item.tags or {}, " ")
  local lang = item.language or ""
  return string.format(
    "%s %s %s [%s]",
    item.title or "",
    item.desc or "",
    tags,
    lang
  )
end

local function format_item(item)
  local ret = {}
  local lang = item.language or (item.source == "code_file" and "file" or "")
  ret[#ret + 1] = { item.title or "未命名", "Normal" }
  if item.desc and item.desc ~= "" then
    ret[#ret + 1] = { "  " .. item.desc, "Comment" }
  end
  if lang ~= "" then
    ret[#ret + 1] = { "  [" .. lang .. "]", "Special" }
  end
  return ret
end

local function pick(items, title)
  local snacks = deps.snacks()
  if not snacks then
    return
  end

  snacks.picker.pick({
    title = title,
    items = items,
    format = format_item,
    preview = "file",
    confirm = function(picker, item)
      picker:close()
      if item and item.is_markdown then
        actions.open_code(item)
      else
        actions.insert_code(item)
      end
    end,
    win = {
      input = {
        keys = {
          ["<C-y>"] = { "copy_code", mode = { "i", "n" } },
          ["<C-o>"] = { "open_code", mode = { "i", "n" } },
          ["<C-f>"] = { "insert_with_fold", mode = { "i", "n" } },
          ["<C-r>"] = { "refresh_rbook", mode = { "i", "n" } },
        },
      },
    },
    actions = {
      copy_code = function(picker, item)
        picker:close()
        actions.copy_code(item)
      end,
      open_code = function(picker, item)
        picker:close()
        actions.open_code(item)
      end,
      insert_with_fold = function(picker, item)
        picker:close()
        actions.insert_code(item, { fold_markers = true })
      end,
      refresh_rbook = function(picker)
        catalog.refresh()
        picker:close()
        vim.schedule(function()
          M.code()
        end)
      end,
    },
  })
end

function M.code(cmd_opts)
  local data = catalog.get()
  if not data then
    return
  end

  local allow, ft = allowed_extensions(cmd_opts and cmd_opts.bang)
  local items = {}
  for _, item in ipairs(data.templates) do
    if template_allowed(item, allow) then
      local copy = vim.deepcopy(item)
      copy.text = text_for_template(item)
      copy.file = item.code_path
      items[#items + 1] = copy
    end
  end

  if #items == 0 then
    vim.notify(
      ("rbook: 当前 filetype(%s) 没有匹配的模板，用 :RbookCode! 看全部"):format(ft or "未知"),
      vim.log.levels.WARN
    )
    return
  end

  pick(items, title_for("Rbook Code Templates", ft, allow))
end

function M.code_files(cmd_opts)
  local data = catalog.get()
  if not data then
    return
  end

  local allow, ft = allowed_extensions(cmd_opts and cmd_opts.bang)
  local items = {}
  for _, item in ipairs(data.code_files) do
    if extension_allowed(item, allow) then
      local copy = vim.deepcopy(item)
      copy.text = item.title .. " " .. item.desc
      copy.file = item.code_path
      items[#items + 1] = copy
    end
  end

  if #items == 0 then
    vim.notify(
      ("rbook: 当前 filetype(%s) 没有匹配的代码文件，用 :RbookCodeFiles! 看全部"):format(ft or "未知"),
      vim.log.levels.WARN
    )
    return
  end

  pick(items, title_for("Rbook Code Files", ft, allow))
end

return M

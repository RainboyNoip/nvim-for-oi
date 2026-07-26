local actions = require("rbook.actions")
local catalog = require("rbook.catalog")
local deps = require("rbook.deps")

local M = {}

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

function M.code()
  local data = catalog.get()
  if not data then
    return
  end

  local items = {}
  for _, item in ipairs(data.templates) do
    local copy = vim.deepcopy(item)
    copy.text = text_for_template(item)
    copy.file = item.code_path
    items[#items + 1] = copy
  end
  pick(items, "Rbook Code Templates")
end

function M.code_files()
  local data = catalog.get()
  if not data then
    return
  end

  local items = {}
  for _, item in ipairs(data.code_files) do
    local copy = vim.deepcopy(item)
    copy.text = item.title .. " " .. item.desc
    copy.file = item.code_path
    items[#items + 1] = copy
  end
  pick(items, "Rbook Code Files")
end

return M

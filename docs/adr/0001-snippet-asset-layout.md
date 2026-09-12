# Unify Snippet Asset Layout

Snippet assets are archived below `all_snippets/` with kebab-case type directories: `lua-snippets`, `vscode-snippets`, and `oi-snippets`. File snippets live under `oi-snippets/files`, while rbook templates live under `oi-snippets/rbook`; their pickers and loaders remain separate because they have different data models and entry points. LuaSnip uses explicit Lua entry modules so split implementation modules are not recursively loaded as duplicate snippet files. The repository keeps `RBOOK_CODE_YAML` and `fileSnip.setup({ snippetPath = ... })` as explicit external overrides, but removes the old default directory names.

## Considered Options

- Put every asset directly in one flat directory: rejected because file snippets and rbook templates have different selection and indexing semantics.
- Keep the old top-level directories with compatibility links: rejected because it leaves two physical sources of truth.
- Let `from_lua` recursively scan the split Lua modules: rejected because an entry module and its implementation directory can be loaded twice.

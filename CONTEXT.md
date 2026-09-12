# Snippet Assets

This context defines the kinds of reusable code assets in the Neovim configuration and the boundaries between their user-facing entry points.

## Language

**Lua snippet**:
An editor expansion defined by a Lua module, registered with LuaSnip for a filetype.
_Avoid_: file snippet, template

**VS Code snippet**:
An editor expansion defined by JSON and `package.json`, loadable by both VS Code and Neovim.
_Avoid_: Lua snippet

**File snippet**:
A file asset selected by the file snippet picker and inserted as file content into the current buffer.
_Avoid_: Lua snippet, rbook template

**rbook template**:
A complete code file indexed by `code.yaml`, selected through rbook and filtered by language.
_Avoid_: file snippet

**Snippet collection**:
The physical `all-snippets/` archive containing the independent Lua, VS Code, file, and rbook asset groups. It is an archive boundary, not a claim that the groups share one loading mechanism.
_Avoid_: unified snippet format

return {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "basedpyrightconfig.json",
    "pyrightconfig.json",
    ".git",
  },
  settings = {
    basedpyright = {
      analysis = {
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "basic",
        diagnosticSeverityOverrides = {
          reportMissingTypeStubs = "none",
          reportPossiblyUnboundVariable = "error",
          reportUnusedCallResult = "none",
          reportUnusedImport = "none",
          reportUnusedVariable = "none",
          reportUnknownArgumentType = "none",
          reportUnknownLambdaType = "none",
          reportUnknownMemberType = "none",
          reportUnknownParameterType = "none",
          reportUnknownVariableType = "none",
        },
      },
    },
  },
}

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
        -- 按比赛目标环境检查语法和标准库，而不是跟随本机解释器版本。
        pythonVersion = "3.15",
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

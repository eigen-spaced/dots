return {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    ".git",
  },
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic",
        diagnosticMode = "openFilesOnly",

        autoSearchPaths = true,
        useLibraryCodeForTypes = true,

        -- kill annoying noise
        diagnosticSeverityOverrides = {
          reportUnknownMemberType = "none",
          reportUnknownVariableType = "none",
          reportUnknownArgumentType = "none",
          reportUnknownLambdaType = "none",
          reportUnknownParameterType = "none",

          reportOptionalMemberAccess = "none",
          reportOptionalCall = "none",
          reportOptionalSubscript = "none",

          reportGeneralTypeIssues = "warning", -- not error
        },
      },
    },
  },
}

local lint = require('guard.lint')

local severities = {
  Error = lint.severities.ERROR,
  Warn = lint.severities.WARN,
  Hint = lint.severities.HINT,
}

return {
  cmd = 'statix',
  args = { 'check', '--stdin', '--format', 'json' },
  stdin = true,
  parse = function(result, bufnr)
    local diags = {}

    local report = (result ~= '' and vim.json.decode(result) or {}).report
    if type(report) ~= 'table' then
      return diags
    end

    for _, r in ipairs(report) do
      for _, d in ipairs(r.diagnostics) do
        table.insert(
          diags,
          lint.diag_fmt(
            bufnr,
            d.at.from.line > 0 and d.at.from.line - 1 or 0,
            d.at.from.column > 0 and d.at.from.column - 1 or 0,
            d.message,
            severities[r.severity] or lint.severities.warning,
            'statix'
          )
        )
      end
    end

    return diags
  end,
}

local M = {}

M.candidates = {}

function M.new()
  return setmetatable({}, { __index = M })
end

local function shorten(name)
  return vim.fn.join(
    vim.tbl_map(function(it)
      return it:sub(1, 1)
    end, vim.split(name, ':')),
    ''
  )
end

local function build_candidates()
  if #M.candidates > 0 then
    return M.candidates
  end

  local ln = vim.fn.line('$')

  local lines = vim.api.nvim_buf_get_lines(0, math.max(1, ln - 1000), ln, true)
  vim.fn.reverse(lines)

  local m = {}

  for _, line in ipairs(lines) do
    local account_name = line:match('^%s+([-%w:]+)')
    if account_name and not m[account_name] then
      table.insert(M.candidates, {
        label = account_name,
        filterText = account_name .. ' ' .. shorten(account_name),
        sortText = '999999' .. account_name,
        data = {
          alias = shorten(account_name),
        },
      })
      m[account_name] = true
    end
  end

  return M.candidates
end

function M.get_keyword_pattern()
  return [[\k\+]]
end

function M.is_available()
  return vim.o.filetype == 'hledger'
end

function M:complete(params, callback)
  local all = build_candidates()
  local candidates = {}

  local filter = vim.trim(params.context.cursor_before_line:lower())

  if 2 <= #filter then
    for _, candidate in ipairs(all) do
      if candidate.data.alias == filter then
        table.insert(candidates, vim.tbl_extend('force', candidate, { sortText = '000001' .. candidate.label }))
      end
    end
  end

  vim.list_extend(candidates, all)

  if vim.startswith(params.context.cursor_before_line, '  ') then
    callback(candidates)
  end
end

return M

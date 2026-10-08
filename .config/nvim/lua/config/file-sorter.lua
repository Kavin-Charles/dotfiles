local M = {}

function M.new(opts)
  opts = vim.tbl_extend("keep", opts or {}, { case_mode = "smart_case", fuzzy = true })
  local sorter = require("telescope").extensions.fzf.native_fzf_sorter(opts)
  local native_score = sorter.scoring_function

  sorter.scoring_function = function(self, prompt, line, entry)
    local path_score = native_score(self, prompt, line)
    if path_score < 0 or prompt == "" then return path_score end
    -- Explicit paths keep FZF's normal path ranking and extended query syntax.
    if prompt:find("/", 1, true) then return path_score end

    local path = entry and (entry.path or entry.filename) or line
    local name = path:match("[^/]+$") or path
    local name_score = native_score(self, prompt, name)
    if name_score < 0 then return 2 + path_score / (1 + path_score) end

    local query = prompt
    if opts.case_mode == "ignore_case" or (opts.case_mode == "smart_case" and not prompt:find("%u")) then
      name, query = name:lower(), query:lower()
    end
    local stem = name:gsub("%.[^.]+$", "")
    local tier = (name == query or stem == query) and 0 or 1
    -- Non-overlapping score ranges: exact filename/stem, fuzzy filename, path only.
    return tier + name_score / (1 + name_score) + math.min(#name, 1000) * 0.000001
  end
  return sorter
end

return M

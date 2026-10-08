return {
  {
    "nvim-telescope/telescope.nvim", branch = "0.1.x", cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },
    opts = {
      defaults = {
        prompt_prefix = " > ", selection_caret = " > ", sorting_strategy = "ascending",
        layout_config = { prompt_position = "top", width = 0.9, height = 0.8 },
        file_ignore_patterns = { "node_modules/", "%.git/", "target/", "%.venv/", "dist/" },
        path_display = { "truncate" },
        file_sorter = function(opts) return require("config.file-sorter").new(opts) end,
      },
      extensions = { fzf = { override_file_sorter = false } },
      pickers = { find_files = { hidden = true }, buffers = { sort_mru = true, ignore_current_buffer = true } },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      require("telescope").load_extension("fzf")
    end,
    keys = {
      { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Search text" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Search word" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search buffer" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
    },
  },
  {
    "ThePrimeagen/harpoon", branch = "harpoon2", dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Pin file" },
      { "<leader>hh", function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end, desc = "Pinned files" },
      { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Pinned file 1" },
      { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Pinned file 2" },
      { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Pinned file 3" },
      { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Pinned file 4" },
      { "<leader>5", function() require("harpoon"):list():select(5) end, desc = "Pinned file 5" },
    },
  },
}

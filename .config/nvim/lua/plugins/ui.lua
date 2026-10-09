return {
  {
    "nvim-mini/mini.nvim", lazy = false,
    config = function()
      require("mini.icons").setup({ style = "ascii" })
      require("mini.statusline").setup({ use_icons = false })
      require("mini.pairs").setup()
      require("mini.surround").setup({
        custom_surroundings = {
          ["("] = { output = { left = "(", right = ")" } },
          ["["] = { output = { left = "[", right = "]" } },
          ["{"] = { output = { left = "{", right = "}" } },
          ["<"] = { output = { left = "<", right = ">" } },
        },
      })
      vim.keymap.set("x", "<leader>s", "sa", { remap = true, desc = "Surround selection" })
      vim.keymap.set("n", "siw", "saiw", { remap = true, desc = "Surround current word" })
      local starter = require("mini.starter")
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniStarterOpened",
        group = vim.api.nvim_create_augroup("ObsidianStarterKeys", { clear = true }),
        callback = function()
          for key, direction in pairs({ h = "prev", j = "next", k = "prev", l = "next" }) do
            vim.keymap.set("n", key, function() starter.update_current_item(direction) end,
              { buffer = true, nowait = true, desc = "Starter: " .. direction .. " item" })
          end
        end,
      })
      starter.setup({
        header = "O B S I D I A N\n\nNeovim / Purple",
        footer = "h/k: previous   j/l: next   Enter: open   Space: commands",
        items = {
          { name = "Find files", action = "Telescope find_files", section = "Workspace" },
          { name = "Search text", action = "Telescope live_grep", section = "Workspace" },
          { name = "Browse files", action = "Oil", section = "Workspace" },
          { name = "New file", action = "enew | startinsert", section = "Workspace" },
          starter.sections.recent_files(5, false),
          { name = "Config", action = "edit " .. vim.fn.stdpath("config") .. "/init.lua", section = "Neovim" },
          { name = "Plugins", action = "Lazy", section = "Neovim" },
          { name = "Quit", action = "quit", section = "Neovim" },
        },
        content_hooks = { starter.gen_hook.adding_bullet("· "), starter.gen_hook.aligning("center", "center") },
      })
    end,
  },
  {
    "folke/which-key.nvim", event = "VeryLazy",
    opts = {
      delay = 300, preset = "modern",
      icons = {
        mappings = false, separator = ">", breadcrumb = ">",
        keys = {
          Up = "Up ", Down = "Down ", Left = "Left ", Right = "Right ",
          C = "Ctrl ", M = "Alt ", D = "Super ", S = "Shift ",
          CR = "Enter ", Esc = "Esc ", NL = "Enter ", BS = "Backspace ",
          Space = "Space ", Tab = "Tab ", ScrollWheelDown = "ScrollDown ", ScrollWheelUp = "ScrollUp ",
          F1 = "F1", F2 = "F2", F3 = "F3", F4 = "F4", F5 = "F5", F6 = "F6",
          F7 = "F7", F8 = "F8", F9 = "F9", F10 = "F10", F11 = "F11", F12 = "F12",
        },
      },
      spec = {
        { "<leader>f", group = "Find" }, { "<leader>g", group = "Git" },
        { "<leader>c", group = "Code" }, { "<leader>b", group = "Buffers" },
        { "<leader>h", group = "Harpoon" }, { "<leader>u", group = "UI / tools" },
        { "<leader>t", group = "Terminal" },
      },
    },
  },
  {
    "stevearc/oil.nvim", lazy = false,
    opts = {
      columns = { "icon" },
      view_options = { show_hidden = true },
      float = { border = "rounded", max_width = 100, max_height = 30 },
      keymaps = {
        ["<Esc>"] = { "actions.close", mode = "n" },
        ["a"] = { "o", mode = "n", desc = "New file (type name, then save)" },
      },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Browse parent directory" },
      { "<leader>e", "<cmd>Oil --float<cr>", desc = "File browser" },
    },
  },
}

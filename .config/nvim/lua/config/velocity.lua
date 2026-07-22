return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		opts = {
			flavour = "mocha",
			color_overrides = {
				mocha = {
					base = "#0A0A0A",
					mantle = "#0A0A0A",
					crust = "#2D2D30",
					blue = "#4A9EF1",
					sapphire = "#00FFF0",
					peach = "#FF8C42",
				},
			},
			custom_highlights = function(colors)
				return {
					SnacksDashboardDesc = { fg = colors.peach, style = { "bold" } },
					SnacksDashboardKey = { fg = colors.peach, style = { "bold" } },
					SnacksDashboardIcon = { fg = colors.peach },
					SnacksDashboardSpecial = { fg = colors.sapphire },
					SnacksDashboardFooter = { fg = colors.blue },
					SnacksDashboardHeader = { fg = colors.blue },
					SnacksDashboardDir = { fg = colors.subtext1 },
					SnacksDashboardTerminal = { fg = colors.blue },
				}
			end,
		},
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin",
		},
	},
}

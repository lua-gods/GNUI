local BASE = (...):match(".+[./]GNUI"):gsub("/", ".")
--TODO: convert everything here into a table
local atlas = nil ---@type string
---@diagnostic disable-next-line: undefined-global
if figuraMetatables then -- is Figura lmao
	atlas = (...):gsub("/", ".") .. ".ore"
else
	atlas = BASE:gsub("%.", "/") .. "/style/theme/ore.png"
end

---@type GNUI.Theme
return {
	title = "ore",
	styles = {
		box = {
			default = "opaque",

			empty = {
				normal = {
					type = "sprite",
				},
			},

			opaque = {
				normal = {
					type        = "nineslice",
					texturePath = atlas,
					uv          = vec(40, 1, 42, 3),
					border      = vec(1, 1, 1, 1),
					padding     = vec(1, 1, 1, 1),
				},
			},

			glass = {
				normal = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(40, 5, 42, 7),
					padding = vec(1, 1, 1, 1),
					border = vec(1, 1, 1, 1),
				},
			},
			highlight = {
				normal = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(26, 9, 28, 11),
					border = vec(1, 1, 1, 1),
					expand = vec(1, 1, 1, 1),
				},
			},
		},


		button = {
			default = "secondary",
			danger = {
				normal = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(15, 0, 19, 6),

					border = vec(2, 2, 2, 4),
					padding = vec(2, 2, 2, 0),
					expand = vec(0, 0, 0, 2),
					margin = vec(0, -2, 0, 2),

					textAlignment = vec(0, 0),
					textColor = "#ffffff",
				},
				pressed = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(15, 7, 19, 11),

					border = vec(2, 2, 2, 2),
					padding = vec(2, 2, 2, 0),
					margin = vec(0, 0, 0, 0),

					textAlignment = vec(0, 0),
					textColor = "#ffffff",
				},
			},
			primary = {
				normal = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(10, 0, 14, 6),

					border = vec(2, 2, 2, 4),
					padding = vec(2, 2, 2, 0),
					expand = vec(0, 0, 0, 2),
					margin = vec(0, -2, 0, 2),

					textAlignment = vec(0, 0),
					textColor = "#ffffff",
				},
				pressed = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(10, 7, 14, 11),

					border = vec(2, 2, 2, 2),
					padding = vec(2, 2, 2, 0),
					margin = vec(0, 0, 0, 0),

					textAlignment = vec(0, 0),
					textColor = "#ffffff",
				},
			},
			secondary = {
				normal = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(5, 0, 9, 6),

					border = vec(2, 2, 2, 4),
					padding = vec(2, 2, 2, 0),
					expand = vec(0, 0, 0, 2),
					margin = vec(0, -2, 0, 2),

					textAlignment = vec(0, 0),
					textColor = "#1b1b1b",
				},
				pressed = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(5, 7, 9, 11),

					border = vec(2, 2, 2, 2),
					padding = vec(2, 2, 2, 0),

					textAlignment = vec(0, 0),
					textColor = "#1b1b1b",
				},
			},
			tertiary = {
				normal = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(0, 0, 4, 6),

					border = vec(2, 2, 2, 4),
					padding = vec(2, 2, 2, 0),
					expand = vec(0, 0, 0, 2),
					margin = vec(0, -2, 0, 2),

					textAlignment = vec(0, 0),
					textColor = "#ffffff",
				},
				pressed = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(0, 7, 4, 11),

					border = vec(2, 2, 2, 2),
					padding = vec(2, 2, 2, 0),
					margin = vec(0, 0, 0, 0),

					textAlignment = vec(0, 0),
					textColor = "#ffffff",
				},
			},
			flat = {
				normal = {
					type = "quad",
					texturePath = atlas,
					uv = vec(30, 1, 30, 1),
					textColor = "#ffffff",
					textAlignment = vec(0, 0),
				},
				pressed = {
					type = "quad",
					texturePath = atlas,
					uv = vec(30, 5, 30, 5),
					textAlignment = vec(0, 0),
					textColor = "#ffffff",
				},
			},
		},
		textField = {
			default = {
				--colorHighlight="#00ff00",
				normal = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(1, 32, 5, 36),

					border = vec(1, 3, 1, 1),
					padding = vec(2, 2, 2, 2),

					textAlignment = vec(-1, 0),
					textColor = "#ffffff",
				},
				hovered = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(0, 38, 6, 44),

					border = vec(2, 4, 2, 2),
					padding = vec(2, 2, 2, 2),
					expand = vec(1, 1, 1, 1),

					textAlignment = vec(-1, 0),
					textColor = "#ffffff",
				},
				active = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(0, 38, 6, 44),

					border = vec(2, 4, 2, 2),
					padding = vec(2, 2, 2, 2),
					expand = vec(1, 1, 1, 1),

					textAlignment = vec(-1, 0),
					textColor = "#ffffff",
				},
				invalid = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(0, 45, 6, 51),

					border = vec(2, 4, 2, 2),
					padding = vec(2, 2, 2, 2),
					expand = vec(1, 1, 1, 1),

					textAlignment = vec(-1, 0),
					textColor = "#ffffff",
				},
			},
		},
		slider = {
			default = {
				normal = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(40, 5, 42, 7),
					padding = vec(1, 1, 1, 1),
					border = vec(1, 1, 1, 1),
				},
				pressed = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(40, 5, 42, 7),
					padding = vec(1, 1, 1, 1),
					border = vec(1, 1, 1, 1),
				},
				knob = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(0, 0, 4, 6),

					border = vec(2, 2, 2, 4),
					padding = vec(2, 2, 2, 0),
					expand = vec(0, 0, 0, 2),
					margin = vec(0, -2, 0, 2),

					textAlignment = vec(0, 0),
					textColor = "#ffffff",
				},
				knobLength = 5,
				knobPressed = {
					type = "nineslice",
					texturePath = atlas,
					uv = vec(40, 5, 42, 7),
					padding = vec(1, 1, 1, 1),
					border = vec(1, 1, 1, 1),
				},
			},
		},
	},
}

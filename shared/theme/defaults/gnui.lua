local BASE = (...):match(".+[./]GNUI"):gsub("/", ".")

local atlas ---@type string
---@diagnostic disable-next-line: undefined-global
if figuraMetatables then -- is Figura lmao
	atlas = (...):gsub("/", ".") .. ".gnui"
else
	atlas = BASE:gsub("%.", "/") .. "/style/theme/gnui.png"
end

---@type GNUI.Theme
return {
	title = "gnui",
	styles = {
		box = {
			default={
				normal = {
					type="nineslice",
					texturePath = atlas,
					uv = vec(4,9,8,13),
					border = vec(2,2,2,2),
					padding = vec(1,1,1,1),
					childGap = 1,
				}
			},
			highlight={
				normal = {
					type="nineslice",
					texturePath = atlas,
					uv = vec(8,0,10,2),
					border = vec(1,1,1,1),
					expand = vec(2,2,2,2),
				}
			},
			
			none = {
				normal = {
					type = "sprite",
					childGap = 1,
				},
			},
		},
		button = {
			default = {
				normal = {
					type="nineslice",
					texturePath = atlas,
					uv = vec(0,0,2,2),
					border = vec(1,1,1,1),
					padding = vec(3,2,2,1),
					textColor = "#141414",
				},
				hovered = {
					type="nineslice",
					texturePath = atlas,
					uv = vec(4,0,6,2),
					border = vec(1,1,1,1),
					padding = vec(3,2,2,1),
					textColor = "#141414",
				},
				pressed = {
					type="nineslice",
					texturePath = atlas,
					uv = vec(12,0,14,2),
					border = vec(1,1,1,1),
					padding = vec(3,2,2,1),
					textColor = "#141414",
				},
			}
		},
	},
}
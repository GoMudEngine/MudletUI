-- Centralized Style Configuration
-- All UI styles are defined here for easy theming and maintenance

ui = ui or {}
ui.theme = ui.theme or {}

-- Color Palette
ui.theme.colors = {
	-- Base colors
	background = "rgba(15,15,15,100%)",
	backgroundDark = "rgba(0,0,0,100%)",
	backgroundLight = "rgba(40,40,40,100%)",

	-- Text colors
	text = "white",
	textMuted = "grey",
	textHighlight = "gold",

	-- Status colors
	health = {
		high = "rgb(0,180,0)",
		medium = "rgb(255,255,0)",
		low = "rgb(180,0,0)",
		critical = "rgb(130,0,0)",
		background = "rgb(60,0,0)",
	},

	stamina = {
		high = "rgb(147,0,107)",
		medium = "rgb(127,0,87)",
		low = "rgb(117,0,77)",
		critical = "rgb(117,0,67)",
		background = "rgb(60,0,60)",
	},

	balance = {
		high = "rgb(0,0,180)",
		medium = "rgb(0,0,155)",
		low = "rgb(0,0,130)",
		critical = "rgb(25,25,150)",
		background = "rgb(0,0,60)",
	},

	-- Border colors
	borderNormal = "rgba(160,160,160,50%)",
	borderDark = "rgba(40,40,40,100%)",
	borderLight = "rgba(80,80,80,100%)",
}

-- Common style components
ui.theme.components = {
	-- Border styles
	borderRadius = "border-radius: 3px;",
	borderRadiusLarge = "border-radius: 5px;",

	-- Common borders
	gaugeBorder = function()
		return ui.theme.components.borderRadius .. "border: 1px solid " .. ui.theme.colors.borderNormal .. ";"
	end,

	-- Container borders
	containerBorderTop = function()
		return "border-bottom: 2px solid " .. ui.theme.colors.borderDark .. ";"
	end,

	containerBorderBottom = function()
		return "border-top: 2px solid " .. ui.theme.colors.borderDark .. ";"
	end,

	containerBorderLeft = function()
		return "border-right: 2px solid " .. ui.theme.colors.borderDark .. ";"
	end,

	containerBorderRight = function()
		return "border-left: 2px solid " .. ui.theme.colors.borderDark .. ";"
	end,

	-- Padding presets
	paddingSmall = "padding: 5px;",
	paddingMedium = "padding: 10px;",
	paddingLarge = "padding: 15px;",

	-- Transparent background
	transparentBg = "background-color: rgba(0,0,0,0%);",
}

-- Container styles
ui.theme.containers = {
	-- Main containers
	default = function()
		return "background-color: " .. ui.theme.colors.background .. ";"
	end,

	-- Border containers
	left = function()
		return ui.theme.containers.default() .. ui.theme.components.containerBorderLeft()
	end,

	right = function()
		return ui.theme.containers.default() .. ui.theme.components.containerBorderRight()
	end,

	top = function()
		return ui.theme.containers.default() .. ui.theme.components.containerBorderBottom() .. "padding-top: 10px;"
	end,

	bottom = function()
		return ui.theme.containers.default() .. ui.theme.components.containerBorderTop() .. "padding-bottom: 10px;"
	end,

	-- Special containers
	noBorder = function()
		return ui.theme.containers.default() .. "border: 0px solid " .. ui.theme.colors.background .. ";"
	end,

	moveable = function()
		return ui.theme.containers.default() .. ui.theme.components.borderRadiusLarge
	end,
}

-- Tab styles
ui.theme.tabs = {
	-- Tab colors (can be overridden by settings)
	activeFg = function()
		return ui.settings.activeTabFGColor or "white"
	end,

	activeBg = function()
		return ui.settings.activeTabBGColor or "purple"
	end,

	inactiveFg = function()
		return ui.settings.inactiveTabFGColor or "white"
	end,

	inactiveBg = function()
		return ui.settings.inactiveTabBGColor or "DimGrey"
	end,

	-- Tab CSS
	active = function()
		return string.format(
			[[
            background-color: %s;
            border-bottom: 1px solid %s;
            margin-right: 1px;
            margin-bottom: 0px;
            border-top-left-radius: 10%%;
            border-top-right-radius: 10%%;
            color: %s;
            font-family: %s, Consolas, 'Lucida Console', Monaco, 'Courier New', Courier, monospace;
        ]],
			ui.theme.tabs.activeBg(),
			ui.theme.tabs.activeBg(),
			ui.theme.tabs.activeFg(),
			ui.settings.tabFont or ui.settings.consoleFont
		)
	end,

	inactive = function()
		return string.format(
			[[
            background-color: %s;
            border-bottom: 1px solid %s;
            margin-right: 1px;
            margin-bottom: 0px;
            border-top-left-radius: 10%%;
            border-top-right-radius: 10%%;
            color: %s;
            font-family: %s, Consolas, 'Lucida Console', Monaco, 'Courier New', Courier, monospace;
        ]],
			ui.theme.tabs.inactiveBg(),
			ui.theme.tabs.inactiveBg(),
			ui.theme.tabs.inactiveFg(),
			ui.settings.tabFont or ui.settings.consoleFont
		)
	end,

	box = function()
		return "background-color: " .. ui.theme.colors.backgroundDark .. ";"
	end,
}

-- Gauge styles
ui.theme.gauges = {
	-- Common gauge text style
	text = function()
		return (ui.settings and ui.settings.cssFont or "") .. " color: white; qproperty-alignment: 'AlignCenter';"
	end,

	-- Health gauge
	hp = {
		front = function()
			return string.format(
				[[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(150, 25, 25), stop: 0.1 rgb(180,0,0), stop: 0.85 rgb(155,0,0), stop: 1 rgb(130,0,0)); %s]],
				ui.theme.components.gaugeBorder()
			)
		end,

		back = function()
			return "background-color: "
				.. ui.theme.colors.health.background
				.. "; "
				.. ui.theme.components.gaugeBorder()
		end,
	},

	-- Stamina/Spell points gauge
	sp = {
		front = function()
			return string.format(
				[[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(127, 0, 87), stop: 0.1 rgb(147, 0, 107), stop: 0.85 rgb(117, 0, 77), stop: 1 rgb(117, 0, 67)); %s]],
				ui.theme.components.gaugeBorder()
			)
		end,

		back = function()
			return "background-color: "
				.. ui.theme.colors.stamina.background
				.. "; "
				.. ui.theme.components.gaugeBorder()
		end,
	},

	-- Balance gauge
	balance = {
		front = function()
			return string.format(
				[[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(25, 25, 150), stop: 0.1 rgb(0,0,180), stop: 0.85 rgb(0,0,155), stop: 1 rgb(0,0,130)); %s]],
				ui.theme.components.gaugeBorder()
			)
		end,

		back = function()
			return "background-color: "
				.. ui.theme.colors.balance.background
				.. "; "
				.. ui.theme.components.gaugeBorder()
		end,
	},

	-- Enemy gauge (reuses health colors)
	enemy = {
		front = function()
			return string.format(
				[[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(150, 25, 25), stop: 0.1 rgb(180,0,0), stop: 0.85 rgb(155,0,0), stop: 1 rgb(130,0,0)); %s]],
				ui.theme.components.gaugeBorder()
			)
		end,

		back = function()
			return "background-color: rgb(60, 0, 0); " .. ui.theme.components.gaugeBorder()
		end,
	},

	-- XP gauge (uses balance colors)
	xp = {
		front = function()
			return ui.theme.gauges.balance.front()
		end,

		back = function()
			return ui.theme.gauges.balance.back()
		end,
	},

	-- Combat status gauge (uses balance colors)
	combatStatus = {
		front = function()
			return ui.theme.gauges.balance.front()
		end,

		back = function()
			return ui.theme.gauges.balance.back()
		end,
	},
}

-- Label styles
ui.theme.labels = {
	-- Vitals label (HP, SP, etc.)
	vitals = function()
		return string.format(
			[[
            font-weight: 400;
            padding-left: 2px;
            %s
            %s
        ]],
			ui.theme.components.transparentBg,
			ui.settings.cssFont or ""
		)
	end,

	-- Balance label
	balance = function()
		return string.format(
			[[
            font-weight: 200;
            qproperty-alignment: 'AlignRight|AlignVCenter';
            %s
            %s
        ]],
			ui.theme.components.transparentBg,
			ui.settings and ui.settings.cssFont or ""
		)
	end,

	-- Adjustable container labels
	adjustable = function(position)
		local bg = (position == "r" or position == "l") and ui.theme.colors.background or ui.theme.colors.backgroundDark
		return string.format(
			[[
            background-color: %s;
            border: 1px solid %s;
            border-%s: 0px;
            border-radius: 4px;
        ]],
			bg,
			bg,
			position == "r" and "left" or position == "l" and "right" or position == "t" and "bottom" or "top"
		)
	end,
}

-- Function to apply theme
function ui.applyTheme()
	-- This function will be called to apply all theme styles
	-- It's a placeholder for when we refactor the existing style applications
	ui.displayUIMessage("Theme system initialized")
end

-- Function to get a style
function ui.getStyle(category, name, subProperty, ...)
	-- Initialize theme if not already done
	if not ui.theme then
		if ui.initTheme then
			ui.initTheme()
		else
			return ""
		end
	end
	
	local styleCategory = ui.theme[category]
	if not styleCategory then
		return ""
	end

	local style = styleCategory[name]
	if not style then
		return ""
	end

	-- If subProperty is provided and style is a table, get the sub-property
	if subProperty and type(style) == "table" then
		style = style[subProperty]
		if not style then
			return ""
		end
	end

	-- If it's a function, call it with any provided arguments
	if type(style) == "function" then
		return style(...)
	end

	-- If it's still a table at this point, return empty string
	if type(style) == "table" then
		return ""
	end

	return style
end

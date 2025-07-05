-- Gauge Management System
-- Centralized system for creating and managing all UI gauges

ui = ui or {}
ui.gauges = ui.gauges or {}
ui.gaugeManager = ui.gaugeManager or {}

-- Gauge configurations
ui.gaugeManager.configs = {
	-- Player gauges
	player = {
		hp = {
			name = "hpGauge",
			position = { x = 10, y = 0 },
			size = { width = 250, height = 20 },
			label = { text = "HP", x = 5, y = 0 },
			style = "hp",
			updateFields = { "hp", "hp_max" },
			formatText = function(current, max)
				return string.format("%s/%s", ui.addNumberSeparator(current), ui.addNumberSeparator(max))
			end,
			calculateValue = function(current, max)
				return current / max
			end,
		},
		sp = {
			name = "spGauge",
			position = { x = 10, y = 30 },
			size = { width = 250, height = 20 },
			label = { text = "SP", x = 5, y = 0 },
			style = "sp",
			updateFields = { "sp", "sp_max" },
			formatText = function(current, max)
				return string.format("%s/%s", ui.addNumberSeparator(current), ui.addNumberSeparator(max))
			end,
			calculateValue = function(current, max)
				return current / max
			end,
		},
		-- Note: balGauge is actually used for combat cooldown, not balance
		cooldown = {
			name = "balGauge",
			position = { x = 270, y = 30 },
			size = { width = 250, height = 20 },
			style = "balance",
			updateFields = { "cooldown", "max_cooldown" },
			formatText = function(cooldown, maxCooldown)
				-- This is handled differently in updateCombatStatusGauge
				return ""
			end,
			calculateValue = function(cooldown, maxCooldown)
				-- This is handled differently in updateCombatStatusGauge
				return 0
			end,
		},
		-- XP gauge is not currently used, keeping config for future use
		xp = {
			name = "xpGauge",
			position = { x = 530, y = 0 }, -- Moved to avoid conflict with enemy gauge
			size = { width = 250, height = 20 },
			style = "xp",
			updateFields = { "xp", "xpmax" },
			formatText = function(current, max)
				if not current or not max or max == 0 then
					return "0.00%"
				end
				local percent = (current / max) * 100
				return string.format("%.2f%%", percent)
			end,
			calculateValue = function(current, max)
				if not max or max == 0 then
					return 0
				end
				return current / max
			end,
		},
	},

	-- Enemy gauge (uses CombatStatus data)
	enemy = {
		hp = {
			name = "enemyGauge",
			position = { x = 270, y = 0 },
			size = { width = 250, height = 20 },
			label = { text = "", x = 5, y = 0, fullWidth = true },
			style = "enemy",
			updateFields = { "target_hp_current", "target_hp_max" },
			formatText = function(current, max, targetName)
				if not targetName or targetName == "None" or targetName == "" then
					return "No Target"
				end
				if not current or current == "" or not max or max == "" then
					return targetName
				end
				return string.format(
					"%s: %s/%s",
					targetName,
					ui.addNumberSeparator(current),
					ui.addNumberSeparator(max)
				)
			end,
			calculateValue = function(current, max)
				if not current or current == 0 or not max or max == 0 then
					return 0
				end
				return current / max
			end,
		},
	},

	-- Combat status gauge (not currently used in UI)
	-- combatStatus = {
	--     balance = {
	--         name = "combatStatusGauge",
	--         size = {width = 190, height = 18},
	--         style = "combatStatus",
	--         updateFields = {"balance"},
	--         formatText = function(balance)
	--             if balance == "1" then
	--                 return "Balanced"
	--             elseif balance == "0" then
	--                 return "Off Balance"
	--             else
	--                 return "Unknown"
	--             end
	--         end,
	--         calculateValue = function(balance)
	--             return tonumber(balance) or 0
	--         end
	--     }
	-- }
}

-- Create a single gauge
function ui.gaugeManager.createGauge(category, gaugeName, container)
	local config = ui.gaugeManager.configs[category] and ui.gaugeManager.configs[category][gaugeName]
	if not config then
		ui.displayUIMessage("Gauge config not found: " .. category .. "." .. gaugeName)
		return nil
	end
	
	-- Check if container exists
	if not container then
		ui.displayUIMessage("Warning: No container provided for gauge: " .. config.name)
		return nil
	end

	-- Create the gauge using our factory function
	local gaugeParams = {
		name = config.name,
		x = config.position and config.position.x or 0,
		y = config.position and config.position.y or 0,
		width = config.size and config.size.width or 250,
		height = config.size and config.size.height or 20,
	}

	if ui.settings and ui.settings.consoleFont then
		gaugeParams.font = ui.settings.consoleFont
	end

	local gauge = ui.createGauge(config.style, gaugeParams, container)

	-- Create label if configured
	if config.label then
		local labelName = config.name .. "Label"
		local label = Geyser.Label:new({
			name = labelName,
			x = config.label.x,
			y = config.label.y,
			width = config.label.fullWidth and "100%" or config.size.width,
			height = config.label.fullWidth and "100%" or config.size.height,
			message = config.label.text,
		}, gauge)

		label:setStyleSheet(ui.getStyle("labels", "vitals"))
		if ui.settings and ui.settings.gaugeFontSize then
			label:setFontSize(ui.settings.gaugeFontSize)
		end

		-- Store label reference
		ui[labelName] = label
	end

	-- Store gauge reference and config
	ui[config.name] = gauge
	ui.gauges[config.name] = {
		gauge = gauge,
		config = config,
		category = category,
		name = gaugeName,
	}

	return gauge
end

-- Create all gauges for a category
function ui.gaugeManager.createGaugeSet(category, container)
	local configs = ui.gaugeManager.configs[category]
	if not configs then
		ui.displayUIMessage("Gauge category not found: " .. category)
		return {}
	end

	local gauges = {}
	for gaugeName, _ in pairs(configs) do
		local gauge = ui.gaugeManager.createGauge(category, gaugeName, container)
		if gauge then
			gauges[gaugeName] = gauge
		end
	end

	return gauges
end

-- Update a specific gauge
function ui.gaugeManager.updateGauge(gaugeName, data)
	local gaugeInfo = ui.gauges[gaugeName]
	if not gaugeInfo then
		return
	end

	local config = gaugeInfo.config
	local gauge = gaugeInfo.gauge

	-- Extract values based on config
	local values = {}
	for i, field in ipairs(config.updateFields) do
		values[i] = tonumber(data[field]) or 0
	end

	-- Calculate gauge value
	local gaugeValue = 0
	if config.calculateValue then
		gaugeValue = config.calculateValue(unpack(values))
	end

	-- Format text
	local text = ""
	if config.formatText then
		-- Pass any extra data (like enemy/target name) if available
		local extraData = data.name or data.target
		text = config.formatText(values[1], values[2], extraData)
	end

	-- Update gauge
	gauge:setValue(gaugeValue, 1, text)
end

-- Update all player gauges
function ui.gaugeManager.updatePlayerGauges()
	-- Try to initialize gauges if they don't exist yet
	if not ui.hpGauge and not ui.spGauge then
		if ui.gaugeDisplay or ui.container5 then
			ui.displayUIMessage("Attempting deferred gauge initialization...")
			ui.gaugeManager.initialize()
		end
		-- If still no gauges, exit
		if not ui.hpGauge and not ui.spGauge then
			return
		end
	end

	-- Use default values if no GMCP data
	local vitals = {}
	if ui.hasGmcpData("Char", "Vitals") then
		vitals = gmcp.Char.Vitals
	else
		-- Default values when no data
		vitals = {
			hp = 100,
			hp_max = 100,
			sp = 100,
			sp_max = 100
		}
	end

	-- Update only the gauges that exist
	if ui.hpGauge then
		ui.gaugeManager.updateGauge("hpGauge", vitals)
	end
	if ui.spGauge then
		ui.gaugeManager.updateGauge("spGauge", vitals)
	end
	-- balGauge is updated by updateCombatStatusGauge, not here
	-- xpGauge would be updated here if it was created
end

-- Update enemy gauge
function ui.gaugeManager.updateEnemyGauge()
	if not ui.hasGmcpData("Char", "CombatStatus") then
		-- No combat status data, clear gauge
		if ui.enemyGauge then
			ui.enemyGauge:setValue(0, 1, "No Target")
		end
		return
	end
	
	local status = gmcp.Char.CombatStatus
	
	-- Check if not in combat or no valid target
	if not status.in_combat or not status.target or status.target == "None" or status.target == "" then
		-- No enemy, hide or clear gauge
		if ui.enemyGauge then
			ui.enemyGauge:setValue(0, 1, "No Target")
		end
		return
	end
	
	-- Update gauge with CombatStatus data
	ui.gaugeManager.updateGauge("enemyGauge", {
		target_hp_current = tonumber(status.target_hp_current) or 0,
		target_hp_max = tonumber(status.target_hp_max) or 0,
		target = status.target
	})
end

-- Update combat status gauge (not currently used in UI)
-- function ui.gaugeManager.updateCombatStatusGauge()
--     if not ui.hasGmcpData("Char", "CombatStatus") then
--         return
--     end
--
--     local status = gmcp.Char.CombatStatus
--     ui.gaugeManager.updateGauge("combatStatusGauge", status)
-- end

-- Initialize all gauges (replaces ui.createPlayerGauges)
function ui.gaugeManager.initialize(container)
	-- Use the provided container or try to find the gauge display
	local gaugeContainer = container or ui.gaugeDisplay or ui.container5
	
	-- Check if we have a valid container
	if not gaugeContainer then
		ui.displayUIMessage("Warning: No gauge container available yet, deferring gauge creation")
		return
	end
	
	-- Create specific player gauges (not all in the set)
	ui.gaugeManager.createGauge("player", "hp", gaugeContainer)
	ui.gaugeManager.createGauge("player", "sp", gaugeContainer)
	ui.gaugeManager.createGauge("player", "cooldown", gaugeContainer) -- This creates balGauge

	-- Create enemy gauge
	ui.gaugeManager.createGauge("enemy", "hp", gaugeContainer)

	-- XP gauge is not currently used in the UI
	-- ui.gaugeManager.createGauge("player", "xp", gaugeContainer)

	ui.displayUIMessage("Gauge management system initialized")
end

-- Refresh all gauge displays
function ui.gaugeManager.refreshAll()
	ui.gaugeManager.updatePlayerGauges()
	ui.gaugeManager.updateEnemyGauge()
	-- ui.gaugeManager.updateCombatStatusGauge()  -- Not currently used
end

-- GMCP Helper Functions
-- Only includes helpers that provide real value:
-- 1. Calculated values (avoid repeated math)
-- 2. Structure migrations (room data)
-- 3. Complex repeated patterns

ui = ui or {}

-- Default values for consistency across the UI
ui.defaults = {
    health = 100,
    healthMax = 100,
    spellPoints = 100,
    spellPointsMax = 100,
    experience = 0,
    experienceToNext = 1,
    gold = 0,
    goldBank = 0
}

-- Room helpers (already exist in Utility_Functions.lua, moved here)
function ui.getRoomId()
    if gmcp and gmcp.Room and gmcp.Room.Info and gmcp.Room.Info.Basic then
        return gmcp.Room.Info.Basic.id
    end
    return nil
end

function ui.getRoomArea()
    if gmcp and gmcp.Room and gmcp.Room.Info and gmcp.Room.Info.Basic then
        return gmcp.Room.Info.Basic.area
    end
    return nil
end

function ui.getRoomName()
    if gmcp and gmcp.Room and gmcp.Room.Info and gmcp.Room.Info.Basic then
        return gmcp.Room.Info.Basic.name
    end
    return nil
end

-- Calculated value helpers (avoid repeated calculations)
function ui.getExperiencePercent()
    if gmcp and gmcp.Char and gmcp.Char.Worth then
        local xp = tonumber(gmcp.Char.Worth.experience) or ui.defaults.experience
        local tnl = tonumber(gmcp.Char.Worth.to_next_level) or ui.defaults.experienceToNext
        if tnl > 0 then
            return math.floor((xp / tnl) * 100)
        end
    end
    return 0
end

function ui.getExperienceInfo()
    if gmcp and gmcp.Char and gmcp.Char.Worth then
        local xp = tonumber(gmcp.Char.Worth.experience) or ui.defaults.experience
        local tnl = tonumber(gmcp.Char.Worth.to_next_level) or ui.defaults.experienceToNext
        local percent = tnl > 0 and math.floor((xp / tnl) * 100) or 0
        return {
            current = xp,
            toNext = tnl,
            percent = percent
        }
    end
    return {
        current = ui.defaults.experience,
        toNext = ui.defaults.experienceToNext,
        percent = 0
    }
end

-- Combat state helper (used in multiple places)
function ui.isInCombat()
    return gmcp and gmcp.Char and gmcp.Char.Combat and 
           gmcp.Char.Combat.Status and gmcp.Char.Combat.Status.in_combat or false
end

-- Backpack capacity helper (used in multiple displays)
function ui.getBackpackCapacity()
    if gmcp and gmcp.Char and gmcp.Char.Inventory and 
       gmcp.Char.Inventory.Backpack and gmcp.Char.Inventory.Backpack.Summary then
        local summary = gmcp.Char.Inventory.Backpack.Summary
        return {
            count = tonumber(summary.count) or 0,
            max = tonumber(summary.max) or 0
        }
    end
    return {count = 0, max = 0}
end

-- Game name helper (used in multiple places with fallback)
function ui.getGameName()
    if gmcp and gmcp.Game and gmcp.Game.Info and gmcp.Game.Info.name then
        return gmcp.Game.Info.name
    end
    return "GoMud"
end

-- Login time helper (with parsing)
function ui.getLoginTime()
    if gmcp and gmcp.Game and gmcp.Game.Info then
        -- Check if epoch exists and is a valid number
        local epoch = gmcp.Game.Info.login_time_epoch
        if epoch and type(epoch) == "number" and epoch > 0 then
            return epoch
        end
        -- Fall back to string format
        return gmcp.Game.Info.login_time
    end
    return nil
end
local event = Event()
function event.onTargetCombat(self, target)

    if configManager.getBoolean(configKeys.PVP_BALANCE) then
        target:registerEvent("pvpBalance")
        target:registerEvent("pvpBalance_2")
    end
	
end

event:register()

local event = CreatureEvent("pvp_login")
function event.onLogin(player)
	-- PVP BALANCE --
	if configManager.getBoolean(configKeys.PVP_BALANCE) then
		player:registerEvent("pvpBalance")
		player:registerEvent("pvpBalance_2")
	end
	return true
end

event:register()


local event = Event()
event.onLook = function(self, thing, position, distance, description)
	local description = "You see " .. thing:getDescription(distance)
	
	-- Look KILL AND DEATH -- 
	if thing:isPlayer() then
		local killStorage = 3000
		local deathStorage = 3001
		local killAmount, deathAmount = thing:getStorageValue(killStorage), thing:getStorageValue(deathStorage)
		if killAmount == -1 then killAmount = 0 end
		if deathAmount == -1 then deathAmount = 0 end
		description = description .. '\nKilled: [' ..killAmount..'] and ' .. 'Dieds: ['..deathAmount..']'
	end
	
	-- Look Show Health Monster in Percentage --
	if thing:isCreature() and thing:isMonster() then
	description = "".. description .."\nHealth: ["..math.floor((thing:getHealth() / thing:getMaxHealth()) * 100).."%]"
    end
	
	-- Look Experience Monsters --
	if thing:isCreature() and thing:isMonster() then
        local exp = thing:getType():getExperience() -- get monster experience
        exp = exp * Game.getExperienceStage(self:getLevel()) -- apply experience stage multiplier
        if configManager.getBoolean(configKeys.STAMINA_SYSTEM) then -- check if stamina system is active on the server
            local staminaMinutes = self:getStamina()
            if staminaMinutes > 2340 and self:isPremium() then -- 'happy hour' check
                exp = exp * 1.5
            elseif staminaMinutes <= 840 then -- low stamina check
                exp = exp * 0.5
            end
        end
        description = string.format("%s\nEstimated of Exp: [%d]", description, exp)
    end
	-- Imbuements System 8.60 --
	--[[local itemType = thing:getType()
		if (itemType and itemType:getImbuingSlots() > 0) then
			local imbuingSlots = "Imbuements: ("
			for i = 1, itemType:getImbuingSlots() do			
					if (i ~= itemType:getImbuingSlots()) then
						imbuingSlots = imbuingSlots.. "Empty Slot, "
					else
						imbuingSlots = imbuingSlots.. "Empty Slot)."
					end
				end
			description = string.gsub(description, "It weighs", imbuingSlots.. "\nIt weighs")
		end]]
		
	-- Look Shop and Deposit All NPC --	
	local NPC_BANKER = "Vauter"
	
	if (thing:isNpc() and thing:getName() == NPC_BANKER and distance <= 3) then
		local description = "You are depositing with " .. thing:getDescription(distance)
		self:say("hi", TALKTYPE_PRIVATE_PN, false, thing)
		self:say("deposit all", TALKTYPE_PRIVATE_PN, false, thing)
		self:say("yes", TALKTYPE_PRIVATE_PN, false, thing)
		self:sendTextMessage(MESSAGE_INFO_DESCR, description)
	elseif (thing:isNpc() and distance <= 3) then
		local description = "Are you talking to " .. thing:getDescription(distance)
		self:say("hi", TALKTYPE_PRIVATE_PN, false, thing)
		self:say("trade", TALKTYPE_PRIVATE_PN, false, thing)
		self:sendTextMessage(MESSAGE_INFO_DESCR, description)
		return false
	end
	
	-- Look Inspecting -- 
	if thing:isPlayer() and not self:getGroup():getAccess() then
        thing:sendTextMessage(MESSAGE_STATUS_SMALL,"The player [".. self:getName() .. '] looking at you.')
    end
		
	if self:getGroup():getAccess() then
		if thing:isItem() then
			description = string.format("%s\nItem ID: (%d)", description, thing:getId())
			
			local actionId = thing:getActionId()
			if actionId ~= 0 then
				description = string.format("%s, Action ID: (%d)", description, actionId)
			end

			local uniqueId = thing:getAttribute(ITEM_ATTRIBUTE_UNIQUEID)
			if uniqueId > 0 and uniqueId < 65536 then
				description = string.format("%s, Unique ID: (%d)", description, uniqueId)
			end

			local itemType = thing:getType()

			local transformEquipId = itemType:getTransformEquipId()
			local transformDeEquipId = itemType:getTransformDeEquipId()
			if transformEquipId ~= 0 then
				description = string.format("%s\nTransforms to: %d (onEquip)", description, transformEquipId)
			elseif transformDeEquipId ~= 0 then
				description = string.format("%s\nTransforms to: %d (onDeEquip)", description, transformDeEquipId)
			end

			local decayId = itemType:getDecayId()
			if decayId ~= -1 then
				description = string.format("%s\nDecays to: (%d)", description, decayId)
			end
		elseif thing:isPlayer() then
			local str = "%s\nHealth: %d / %d"
			if thing:isPlayer() and thing:getMaxMana() > 0 then
				str = string.format("%s, Mana: %d / %d", str, thing:getMana(), thing:getMaxMana())
			end
			description = string.format(str, description, thing:getHealth(), thing:getMaxHealth()) .. "."
		end

		if thing:isCreature() then
			if thing:isPlayer() then
				description = string.format("%s\nIP: %s.", description, thing:getIp())
			end
		end
	end
		-- Look Position -- 
		local position = thing:getPosition()
		description = string.format(
			"%s\nPosition: [X: %d], [Y: %d], [Z: %d].",
			description, position.x, position.y, position.z
		)
	return description
end

event:register()
local exercise_ids = {
	28540,
	28552,
	35279,
	35285,
	28553,	
	28541,
	35280,
	35286,
	28554,
	28542,
	35281,
	35287,
	28544,
	28556,
	35283,
	35289,
	28543,
	28555,
	35282,
	35288,
	28545,
	28557,
	35284,
	35290,
}

local event = Event()
event.onMoveItem = function(self, item, count, fromPosition, toPosition, fromCylinder, toCylinder)

	-- Exercise Weapons
    if isInArray(exercise_ids,item.itemid) then
        self:sendCancelMessage('You cannot move this item outside this container.')
        return false
    end

	if bit.band(toPosition.y, 0x40) == 0 then
		local itemType, moveItem = ItemType(item:getId())
		if bit.band(itemType:getSlotPosition(), SLOTP_TWO_HAND) ~= 0 and toPosition.y == CONST_SLOT_LEFT then
			local rightItem = self:getSlotItem(CONST_SLOT_RIGHT)
			if rightItem and not(itemType:isBow() and rightItem:getType():getWeaponType() == WEAPON_QUIVER) then
				moveItem = self:getSlotItem(CONST_SLOT_RIGHT)
			end
		elseif itemType:getWeaponType() == WEAPON_SHIELD and toPosition.y == CONST_SLOT_RIGHT then
			moveItem = self:getSlotItem(CONST_SLOT_LEFT)
			if moveItem and bit.band(ItemType(moveItem:getId()):getSlotPosition(), SLOTP_TWO_HAND) == 0 then
				return true
			end
		end

		if moveItem then
			local parent = item:getParent()
			local topParent = item:getTopParent()
			if parent:isContainer() and parent:getSize() == parent:getCapacity() then
				return RETURNVALUE_CONTAINERNOTENOUGHROOM
			end
			if Player(topParent) then
				return moveItem:moveTo(parent) and RETURNVALUE_NOERROR or RETURNVALUE_NOTPOSSIBLE
			else
				return RETURNVALUE_BOTHHANDSNEEDTOBEFREE
			end
		end
	end
	
	local containerTo = self:getContainerById(toPosition.y-64)
	if (containerTo) then
	local potions = {7618, 7588, 7591, 8473, 7620, 7589, 7590, 8472}
	local runes = {2260, 2261, 2262, 2263, 2264, 2265, 2266, 2267, 2268, 2269, 2270, 2271, 2272, 2273, 2274, 2275, 2276, 2277, 2278, 2279, 2280, 2281, 2282, 2283, 2284, 2285, 2286, 2287, 2288, 2289, 2290, 2291, 2292, 2293, 2294, 2295, 2296, 2297, 2298, 2299, 2300, 2301, 2302, 2303, 2304, 2305, 2306, 2307, 2308, 2309, 2310, 2311, 2312, 2313, 2314, 2315, 2316}
		--Supply Stash
		if (containerTo:getId() == ITEM_SUPPLY_STASH) then
		local itemType = item:getType()
			if (not (itemType:getType() == SLOTP_BACKPACK or isInArray(runes, item:getId()) or isInArray(potions, item:getId()))) then
				self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You can move only runes and potions in the Supply Stash.")
				return false
			end
		end
	end
	
	if toPosition.x == CONTAINER_POSITION then
		local containerId = toPosition.y - 64
		local container = self:getContainerById(containerId)		
		if not container then
			return true 
		end

		-- Do not let the player insert items into either the Reward Container or the Reward Chest
		local itemId = container:getId()		
		if itemId == ITEM_REWARD_CONTAINER or itemId == ITEM_REWARD_CHEST then
			self:sendCancelMessage('Sorry, not possible.')
			return false
		end

		-- The player also shouldn't be able to insert items into the boss corpse		
		local tile = Tile(container:getPosition())
		for _, item in ipairs(tile:getItems()) do
			if item:getAttribute(ITEM_ATTRIBUTE_CORPSEOWNER) == 2^31 - 1 and item:getName() == container:getName() then
				self:sendCancelMessage('Sorry, not possible.')
				return false
			end
		end
	end
	
	-- Do not let the player move the boss corpse.
	if item:getAttribute(ITEM_ATTRIBUTE_CORPSEOWNER) == 2^31 - 1 then
		self:sendCancelMessage('Sorry, not possible.')
		return false
	end

	return true
end

event:register()

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

local stoneSkinAmuletExhausted = {}

local tileLimit = 0
local protectionTileLimit = 15
local houseTileLimit = 7

CONTAINER_WEIGHT_CHECK = true -- true = enable / false = disable
CONTAINER_WEIGHT_MAX = 1000000 -- 1000000 = 10k = 10000.00 oz

event.onMoveItem = function(self, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	-- No move items with actionID = 100 --
	if item:getActionId() == 100 then
		addEvent(function()self:sendCancelMessage("You can't pick up this item.") end, 100)
		return false
	end
	
	-- Player Corpse Container --
	if fromCylinder and fromCylinder:isItem() then
        if fromCylinder:getId() == 3065 then
            if toCylinder ~= fromCylinder then
                self:say(string.format("x%d %s", count, item:getName()), TALKTYPE_MONSTER_SAY, false, nil, fromCylinder:getPosition())
            end
        end
    end
	
	-- No move parcel very heavy
	if CONTAINER_WEIGHT_CHECK and ItemType(item:getId()):isContainer()
	and item:getWeight() > CONTAINER_WEIGHT_MAX then
		self:sendCancelMessage("Your cannot move this item too heavy.")
		return false
	end
	
	-- Players cannot throw items on teleports
	if toPosition.x ~= CONTAINER_POSITION then
		local thing = Tile(toPosition):getItemByType(ITEM_TYPE_TELEPORT)
		if thing then
			self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	end
	
	-- Bath tube
	local toTile = Tile(toCylinder:getPosition())
	local topDownItem = toTile:getTopDownItem()
	if topDownItem and table.contains({ BATHTUB_EMPTY, BATHTUB_FILLED }, topDownItem:getId()) then
		return false
	end
	
	-- SSA exhaust
	if toPosition.x == CONTAINER_POSITION and toPosition.y == CONST_SLOT_NECKLACE
	and item:getId() == 3081 then
		local pid = self:getId()
		if stoneSkinAmuletExhausted[pid] then
			addEvent(function()self:sendCancelMessage("Wait 2 seconds for equip SSA again.") end, 100)
			return false
		else
			stoneSkinAmuletExhausted[pid] = true
			addEvent(function() stoneSkinAmuletExhausted[pid] = false end, 2000, pid)
			return true
		end
	end
	
	-- Max Tile --
	local tile = Tile(toPosition)
    if tile then
        local itemLimit = tile:getHouse() and houseTileLimit or tile:hasFlag(TILESTATE_PROTECTIONZONE) and protectionTileLimit or tileLimit
        if itemLimit > 0 and tile:getThingCount() > itemLimit and item:getType():getType() ~= ITEM_TYPE_MAGICFIELD then
			addEvent(function()self:sendCancelMessage("You can not add more items on this tile.") end, 100)
            return false
        end
    end
	
	-- Block Throw in Depot
	local tile = Tile(toPosition)
    if tile and tile:hasFlag(TILESTATE_DEPOT) and self:getPosition():getDistance(toPosition) > 1 then
		addEvent(function()self:sendCancelMessage("You can't throw items on top of this depot.") end, 100)
        return false
    end
	
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
	-- Gold Pouch
		if (containerTo:getId() == 23721) then
			if (not (item:getId() == ITEM_CRYSTAL_COIN or item:getId() == ITEM_PLATINUM_COIN or item:getId() == ITEM_GOLD_COIN)) then
				self:sendTextMessage(MESSAGE_INFO_DESCR, "You can move only money to this container.")
				return false
			end
		end
	local potions = {268, 237, 238, 266, 236, 239, 7643, 23375, 7642, 23374}
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

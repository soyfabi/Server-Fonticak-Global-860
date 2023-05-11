local event = Event()
event.onUseItem = function(self, item)
	if self:hasFlag(FLAG_CANT_USE_ITEMS) then
        return false
    end
    print("Player " .. self:getName() .. " used item with ID " .. item:getId())
	return true
end

event:register()
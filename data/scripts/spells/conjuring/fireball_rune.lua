local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	return creature:conjureItem(3147, 3189, 5)
end

spell:name("Fireball Rune")
spell:words("adori flam")
spell:group("support")
spell:vocation("sorcerer;true", "master sorcerer;true")
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(27)
spell:mana(460)
spell:soul(3)
spell:isAggressive(false)
spell:isPremium(false)
spell:needLearn(false)
spell:register()

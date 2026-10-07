/datum/action/cooldown/spell/conjure_item/summon_wealth
	name = "Призвать богатство"
	desc = "Ваша награда за продажу души."
	invocation_type = INVOCATION_WHISPER
	invocation = "Divitiae, da mihi divitias"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	button_icon_state  = "moneybag"
	item_type = /obj/item/coin/gold
	delete_old = FALSE
	cooldown_time = 10 SECONDS
	var/list/wealth = list(
		/obj/item/coin/gold,
		/obj/item/coin/diamond,
		/obj/item/coin/silver,
		/obj/item/stack/sheet/mineral/gold,
		/obj/item/stack/sheet/mineral/silver,
		/obj/item/stack/sheet/mineral/diamond,
		/obj/item/stack/spacecash/c1000
	)

/datum/action/cooldown/spell/conjure_item/summon_wealth/post_created(atom/cast_on, atom/created)
	item_type = pick(wealth)

//basic touch ability that heals basic damage types accessed by the ashwalker shaman
/datum/action/cooldown/spell/touch/healtouch
	name = "Целебное касание"
	desc = "Это заклинание заряжает вашу руку целительной энергиец, позволяя вам лечить некоторые повреждения."
	hand_path = /obj/item/melee/touch_attack/healtouch
	cooldown_time = 20 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "ИСЦЕЛЕНИЕ!"
	school = SCHOOL_RESTORATION
	can_cast_on_self = TRUE
	button_icon_state = "healtouch"
	sound = 'sound/magic/staff_healing.ogg'
	//total of 40 assuming they're hurt by both brute and burn
	var/brute = 20
	var/burn = 20
	var/tox = 10
	var/oxy = 50

/obj/item/melee/touch_attack/healtouch
	name = "healing touch"
	desc = "Целительная аура, вырывающаяся из вашей руки. При прикосновении к гуманоиду заживляет его раны."
	icon_state = "disintegrate" //ironic huh
	item_state = "disintegrate"

/obj/item/melee/touch_attack/healtouch/get_ru_names()
	return alist(
		NOMINATIVE = "целебное касание",
		GENITIVE = "целебного касания",
		DATIVE = "целебному касанию",
		ACCUSATIVE = "целебное касание",
		INSTRUMENTAL = "целебным касанием",
		PREPOSITIONAL = "целебном касании",
	)

/datum/action/cooldown/spell/touch/healtouch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	var/mob/living/M = victim
	new /obj/effect/temp_visual/heal(get_turf(M), "#899d39")
	var/update = NONE
	update |= M.heal_overall_damage(brute, burn, updating_health = FALSE)
	update |= M.heal_damages(tox = tox, oxy = oxy, updating_health = FALSE)
	if(update)
		M.updatehealth("healing touch")
	for(var/datum/disease/D in M.diseases)
		if(D.curable)
			D.cure(need_immunity = FALSE)
	return TRUE

/datum/action/cooldown/spell/touch/healtouch/shaman
	name = "Прикосновение шамана"
	desc = "Это заклинание заряжает вашу руку энергией Некрополя, позволяя вам лечить некоторые повреждения и взаимодействовать с некоторыми предметами."
	school = SCHOOL_LAVALAND
	can_cast_on_self = FALSE
	hand_path = /obj/item/melee/touch_attack/healtouch/shaman

/obj/item/melee/touch_attack/healtouch/shaman

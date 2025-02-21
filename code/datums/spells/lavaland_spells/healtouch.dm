//basic touch ability that heals basic damage types accessed by the ashwalker shaman
/obj/effect/proc_holder/spell/touch/healtouch
	name = "Прикосновение шамана"
	desc = "Это заклинание заряжает вашу руку энергией Некрополя, позволяя вам лечить некоторые повреждения и взаимодействовать с некоторыми предметами."
	hand_path = /obj/item/melee/touch_attack/healtouch

	school = "evocation"
	base_cooldown = 20 SECONDS
	clothes_req = FALSE

	action_icon_state = "healtouch"

/obj/item/melee/touch_attack/healtouch
	name = "\improper healing touch"
	desc = "Целительная аура, вырывающаяся из вашей руки. При прикосновении к гуманоиду заживляет его раны."
	ru_names = list(
        NOMINATIVE = "целебное касание",
        GENITIVE = "целебного касания",
        DATIVE = "целебному касанию",
        ACCUSATIVE = "целебное касание",
        INSTRUMENTAL = "целебным касанием",
        PREPOSITIONAL = "целебном касании"
  	)
	catchphrase = "ИСЦЕЛЕНИЕ!"
	on_use_sound = 'sound/magic/staff_healing.ogg'
	icon_state = "disintegrate" //ironic huh
	item_state = "disintegrate"
	//total of 40 assuming they're hurt by both brute and burn
	var/brute = 20
	var/burn = 20
	var/tox = 10
	var/oxy = 50
	var/heal_self = FALSE

/obj/item/melee/touch_attack/healtouch/afterattack(atom/target, mob/living/carbon/user, proximity, params)
	if(!proximity || (target == user && !heal_self) || !ismob(target) || !iscarbon(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	var/mob/living/M = target
	new /obj/effect/temp_visual/heal(get_turf(M), "#899d39")
	var/update = NONE
	update |= M.heal_overall_damage(brute, burn, updating_health = FALSE)
	update |= M.heal_damages(tox = tox, oxy = oxy, updating_health = FALSE)
	if(update)
		M.updatehealth("healing touch")
	for(var/datum/disease/D in M.diseases)
		if(D.curable)
			D.cure(need_immunity = FALSE)
	return ..()

/obj/effect/proc_holder/spell/touch/healtouch/advanced
	hand_path = /obj/item/melee/touch_attack/healtouch/advanced

/obj/item/melee/touch_attack/healtouch/advanced
	heal_self = TRUE

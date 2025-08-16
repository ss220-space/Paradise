/datum/airmob_data
	var/normal_name // Used only for names in list of choosing.
	var/icon/icon
	var/name
	var/ru_names
	var/desc
	var/maxHealth
	var/armor
	var/response_help = "гладит"
	var/response_disarm = "толкает"
	var/list/response_harm = list("бьёт", "атакует", "лупит", "колотит", "ударяет", "поражает")
	var/harm_intent_damage = 10
	var/melee_damage_lower = 10
	var/melee_damage_upper = 10
	var/obj_damage = 10
	var/armour_penetration = 0
	var/friendly = "касается"
	var/environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	var/speed = 1
	var/mob_size = MOB_SIZE_HUMAN
	var/appearance
	var/req_charge
	var/scan_num = 0
	var/rapid_melee = 1

/datum/airmob_data/New(mob/living/target, obj/item/fauna_bomb/spawner)
	. = ..()

	mob_size = target.mob_size
	normal_name = target.declent_ru(NOMINATIVE)
	icon = icon(initial(target.icon), initial(target.icon_state), SOUTH, 1, FALSE)
	name = "воздушная проекция [target.declent_ru(GENITIVE)]"
	desc = "Уплотненная смесь газов, принявшая форму [target.declent_ru(GENITIVE)]."

	ru_names = list(NOMINATIVE =	"воздушная проекция [target.declent_ru(GENITIVE)]", \
					GENITIVE =		"воздушной проекции [target.declent_ru(GENITIVE)]", \
					DATIVE =		"воздушной проекции [target.declent_ru(GENITIVE)]", \
					ACCUSATIVE =	"воздушную проекцию [target.declent_ru(GENITIVE)]", \
					INSTRUMENTAL =	"воздушной проекцей [target.declent_ru(GENITIVE)]", \
					PREPOSITIONAL = "воздушной проекции [target.declent_ru(GENITIVE)]")

	armor = list(MELEE = target.getarmor(attack_flag = MELEE), BULLET = target.getarmor(attack_flag = BULLET), \
				 LASER = target.getarmor(attack_flag = LASER), ENERGY = target.getarmor(attack_flag = ENERGY), \
				 BOMB = target.getarmor(attack_flag = BOMB), BIO = target.getarmor(attack_flag = BIO), \
				 RAD = target.getarmor(attack_flag = RAD), FIRE = target.getarmor(attack_flag = FIRE), \
				 ACID = target.getarmor(attack_flag = ACID))

	appearance = target.appearance
	maxHealth = target.maxHealth
	speed = target.cached_multiplicative_slowdown

	if(isanimal(target))
		var/mob/living/simple_animal/SA = target
		response_help = SA.response_help
		response_disarm = SA.response_disarm
		response_harm = pick(SA.response_harm)
		harm_intent_damage = SA.harm_intent_damage
		if(SA.melee_damage_type == BRUTE)
			melee_damage_lower = SA.melee_damage_lower
			melee_damage_upper = SA.melee_damage_upper
			obj_damage = SA.obj_damage

		req_charge = sqrt(max(20, target.maxHealth) * max(5, (melee_damage_lower + melee_damage_upper) / 2)) * 1.2
		armour_penetration = SA.armour_penetration
		friendly = SA.friendly
		environment_smash = SA.environment_smash
		return

	if(isalien(target))
		var/mob/living/carbon/alien/alien = target
		rapid_melee = 1.25
		armour_penetration = alien.armour_penetration
		melee_damage_lower = alien.attack_damage
		melee_damage_upper = alien.attack_damage
		obj_damage = alien.obj_damage
		environment_smash = alien.environment_smash
		req_charge = sqrt(max(20, target.maxHealth) * max(5, (melee_damage_lower + melee_damage_upper) / 2)) * 1.2
		return

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		rapid_melee = 1.25
		var/list/damage
		if(H.has_left_hand())
			damage = get_arm_damage(H, ITEM_SLOT_HAND_LEFT)
		else
			damage = get_arm_damage(H, ITEM_SLOT_HAND_RIGHT)

		melee_damage_lower = damage["lower"]
		melee_damage_upper = damage["upper"]
		req_charge = sqrt(max(20, target.maxHealth) * max(5, (melee_damage_lower + melee_damage_upper) / 2)) * 1.2

/datum/airmob_data/proc/get_arm_damage(mob/living/carbon/human/H, arm_slot)
	var/obj/item/item = H.get_item_by_slot(arm_slot)
	if(item)
		armour_penetration = max(armour_penetration, item.armour_penetration)
		if(!istype(item, /obj/item/twohanded))
			melee_damage_lower = max(melee_damage_lower, item.force)
			melee_damage_upper = max(melee_damage_upper, item.force)
		else
			var/obj/item/twohanded/ITH = item
			if(ITH.wielded)
				melee_damage_lower = max(melee_damage_lower, ITH.force_wielded)
				melee_damage_upper = max(melee_damage_upper, ITH.force_wielded)
			else
				melee_damage_lower = max(melee_damage_lower, ITH.force_unwielded)
				melee_damage_upper = max(melee_damage_upper, ITH.force_unwielded)
	else
		melee_damage_lower = max(melee_damage_lower, H.dna.species.punchdamagelow)
		melee_damage_upper = max(melee_damage_upper, H.dna.species.punchdamagehigh)

	return list("lower" = melee_damage_lower, "upper" = melee_damage_upper)

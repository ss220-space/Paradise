//Species unarmed attacks

/datum/unarmed_attack
	var/name
	/// Empty hand hurt intent verb.
	var/attack_verb
	/// What we beat with. It must be in the objective case
	var/attack_object
	/// Lowest possible damage to mobs
	var/damage_min = 0
	/// Highest possible damage to mobs
	var/damage_max = 9
	/// BRUTE BURN etc
	var/damage_type = BRUTE
	/// Damage at which punches will stun
	var/stun_threshold = 9
	/// Damage to objects
	var/obj_damage
	/// Path to sound file if success attack
	var/attack_sound
	/// Path to sound file if missed attack
	var/miss_sound
	/// See code\__DEFINES\combat.dm attack visual effects
	var/animation_type
	/// Type of damage: sharp or blunt
	var/sharp = FALSE
	/// Set TRUE, if can be sharpen with whetstone
	var/can_sharpen = FALSE
	var/icon_state


// PUNCH
/datum/unarmed_attack/punch
	name = "fists"
	attack_verb = list("ударил", "вмазал", "стукнул", "вдарил", "влепил")
	attack_object = "кулаком"
	attack_sound = "punch"
	miss_sound = 'sound/weapons/punchmiss.ogg'
	animation_type = ATTACK_EFFECT_PUNCH
	icon_state = "summons"

/datum/unarmed_attack/punch/diona
	name = "branches"
	attack_verb = list("охлестал", "тяжело стукнул", "лозой хлестанул", "ветвью щелкнул")
	attack_object = ""

/datum/unarmed_attack/punch/drask
	damage_min = 5
	damage_max = 12
	stun_threshold = 12
	obj_damage = 10

/datum/unarmed_attack/punch/wryn
	damage_min = 0
	damage_max = 1

/datum/unarmed_attack/punch/golem
	damage_min = 5
	damage_max = 14
	stun_threshold = 11

/datum/unarmed_attack/punch/golem/silver
	stun_threshold = 9

/datum/unarmed_attack/punch/golem/plasteel
	damage_min = 12
	damage_max = 21
	stun_threshold = 18
	attack_verb = list("громит", "сокрушает", "ломает", "бьёт")
	attack_sound = 'sound/effects/meteorimpact.ogg'

/datum/unarmed_attack/punch/golem/bananium
	damage_min = 0
	damage_max = 1
	attack_verb = list("HONK")
	attack_sound = 'sound/items/airhorn2.ogg'
	animation_type = ATTACK_EFFECT_DISARM

/datum/unarmed_attack/punch/golem/sand
	attack_sound = 'sound/effects/shovel_dig.ogg'

/datum/unarmed_attack/punch/golem/glass
	attack_sound = 'sound/effects/glassbr2.ogg'

/datum/unarmed_attack/punch/golem/bluespace
	attack_sound = 'sound/effects/phasein.ogg'

/datum/unarmed_attack/punch/golem/tranquillite
	attack_sound = null


//CLAWS
/datum/unarmed_attack/claws
	name = "claws"
	attack_verb = list("царапнул", "разорвал", "искромсал", "надорвал", "порвал", "полоснул")
	attack_object = "когтями"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	animation_type = ATTACK_EFFECT_CLAW
	sharp = TRUE
	can_sharpen = TRUE
	icon_state = "vampire_claws"

/datum/unarmed_attack/claws/armalis
	attack_verb = list("хлестает", "хлестанул", "искромсал", "разорвал") //армалисами почти никто не пользуется. Зачем вносить пол вырезаной расе которой никогда не будет в игре?
	damage_min = 6
	damage_max = 15

/datum/unarmed_attack/claws/shaman
	damage_min = 4
	damage_max = 7
	stun_threshold = 7

/datum/unarmed_attack/claws/draconid
	damage_min = 9
	damage_max = 18
	stun_threshold = 18


//BITE
/datum/unarmed_attack/bite
	name = "jaws"
	attack_verb = list("грызет", "кусает", "вгрызается", "трепает")
	attack_sound = 'sound/weapons/bite.ogg'
	animation_type = ATTACK_EFFECT_BITE
	sharp = TRUE
	icon_state = "lunge_finale"


/datum/unarmed_attack/proc/sharpen_act(increase)
	damage_min += increase
	damage_max += increase

/datum/unarmed_attack/proc/can_attack(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return TRUE

/datum/unarmed_attack/proc/attack(mob/living/carbon/human/user, mob/living/carbon/human/target, zone)
	var/attack_message = pick(attack_verb) + " " + attack_object

	user.do_attack_animation(target, animation_type)
	add_attack_logs(user, target, "Melee attacked with [name]")

	if(!iscarbon(user))
		target.LAssailant = null
	else
		target.LAssailant = user

	target.lastattacker = user.real_name
	target.lastattackerckey = user.ckey

	var/damage = rand(damage_min, damage_max)
	if(!damage)
		playsound(target.loc, miss_sound, 25, 1, -1)
		target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] [attack_message] [target.declent_ru(ACCUSATIVE)], но промахива[pluralize_ru(user.gender,"ется","ются")]!</span>")
		return FALSE

	var/obj/item/organ/external/affecting
	if(zone)
		affecting = zone
	else
		affecting = target.get_organ(ran_zone(user.zone_selected))
	var/armor_block = target.run_armor_check(affecting, MELEE)

	// Contract diseases

	//user beats target, check target's defense in selected zone
	for(var/datum/disease/virus/V in user.diseases)
		var/is_infected = FALSE
		if(istype(src, /datum/unarmed_attack/bite) && (V.spread_flags & BITES))
			is_infected = V.Contract(target, act_type = BITES|CONTACT, need_protection_check = TRUE, zone = affecting)
		if(!is_infected && (V.spread_flags & CONTACT))
			V.Contract(target, act_type = CONTACT, need_protection_check = TRUE, zone = affecting)

	//check user's defense in attacking zone (hands or mouth)
	for(var/datum/disease/virus/V in target.diseases)
		var/is_infected = FALSE
		if(istype(src, /datum/unarmed_attack/bite)  && (V.spread_flags > NON_CONTAGIOUS))
			//infected blood contacts with mouth, ignore protection & spread_flags
			is_infected = V.Contract(user, need_protection_check = FALSE)
		if(!is_infected && (V.spread_flags & CONTACT))
			V.Contract(user, act_type = CONTACT, need_protection_check = TRUE, zone = user.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)

	playsound(target.loc, attack_sound, 25, 1, -1)

	target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] [attack_message] [target.declent_ru(ACCUSATIVE)]!</span>")

	var/all_objectives = user?.mind?.get_all_objectives()
	if(target.mind && all_objectives)
		for(var/datum/objective/pain_hunter/objective in all_objectives)
			if(target.mind == objective.target)
				objective.take_damage(damage, damage_type)

	target.apply_damage(damage, damage_type, affecting, armor_block, sharp = src.sharp) //moving this back here means Armalis are going to knock you down  70% of the time, but they're pure adminbus anyway.
	if((target.stat != DEAD) && damage >= stun_threshold)
		target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] ослабля[pluralize_ru(user.gender,"ет","ют")] [target.declent_ru(ACCUSATIVE)]!</span>", \
						"<span class='userdanger'>[user.declent_ru(NOMINATIVE)] ослабля[pluralize_ru(user.gender,"ет","ют")] [target.declent_ru(ACCUSATIVE)]!</span>")
		target.apply_effect(4 SECONDS, WEAKEN, armor_block)
		target.forcesay(GLOB.hit_appends)
	else if(target.lying)
		target.forcesay(GLOB.hit_appends)
	return TRUE


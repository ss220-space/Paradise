/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 350
	health = 350
	attack_damage = 25
	time_to_open_doors = 0.2 SECONDS
	icon = 'icons/mob/xeno/warrior.dmi'
	icon_state = "sentinel"
	caste_icon_prefix = "sentinel"
	ventcrawler_trait = null
	caste_movement_delay = 0.7
	role_text = "Вы — Страж. Ваша основная задача — защита гнезда от непрошенных гостей."
	can_evolve = TRUE
	base_pixel_x = -16
	pixel_x = -16

/mob/living/carbon/alien/humanoid/sentinel/get_ru_names()
	return alist(
		NOMINATIVE = "ксеноморф-страж",
		GENITIVE = "ксеноморфа-стража",
		DATIVE = "ксеноморфу-стражу",
		ACCUSATIVE = "ксеноморфа-стража",
		INSTRUMENTAL = "ксеноморфом-стражем",
		PREPOSITIONAL = "ксеноморфе-страже",
	)

/mob/living/carbon/alien/humanoid/sentinel/Initialize(mapload)
	if(name == "alien sentinel")
		name = text("alien sentinel ([rand(1, 1000)])")
	real_name = name
	. = ..()
	AddSpell(new /datum/action/cooldown/spell/evolve/praetorian)

/mob/living/carbon/alien/humanoid/sentinel/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/sentinel,
		/obj/item/organ/internal/xenos/acidgland/sentinel,
		/obj/item/organ/internal/xenos/neurotoxin/sentinel
	)


/mob/living/carbon/alien/humanoid/praetorian
	name = "alien praetorian"
	icon = 'icons/mob/xeno/warrior.dmi'
	icon_state = "praetorian"
	caste_icon_prefix = "praetorian"
	caste = "s"
	base_pixel_x = -16
	pixel_x = -16
	maxHealth = 550
	health = 550
	status_flags = CANPARALYSE
	large = TRUE
	caste_movement_delay = 1.5
	ventcrawler_trait = null
	disarm_stamina_damage = 34
	armour_penetration = 30
	obj_damage = 80
	time_to_open_doors = 0.2 SECONDS
	environment_smash = ENVIRONMENT_SMASH_WALLS
	role_text = "Вы — Преторианец. Вы являетесь более сильной и неповоротливой версией Часового. Ваша основная задача — защита гнезда от непрошенных гостей."
	var/shield_active = FALSE
	var/shield_end_time = 0
	var/datum/action/cooldown/praetorian_shield/praetorian_shield
	var/caste_movement_delay_backup

/mob/living/carbon/alien/humanoid/praetorian/get_ru_names()
	return alist(
		NOMINATIVE = "ксеноморф-преторианец",
		GENITIVE = "ксеноморфа-преторианца",
		DATIVE = "ксеноморфу-преторианцу",
		ACCUSATIVE = "ксеноморфа-преторианца",
		INSTRUMENTAL = "ксеноморфом-преторианцем",
		PREPOSITIONAL = "ксеноморфе-преторианце",
	)

/mob/living/carbon/alien/humanoid/praetorian/Initialize(mapload)
	. = ..()
	if(name == "alien praetorian")
		name = text("alien praetorian ([rand(1, 1000)])")
	real_name = name
	AddSpell(new /datum/action/cooldown/spell/praetorian_shield)
	praetorian_count++

/mob/living/carbon/alien/humanoid/praetorian/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(.)
		praetorian_count--
		deactivate_shield()

/mob/living/carbon/alien/humanoid/praetorian/is_strong()
	return TRUE

/mob/living/carbon/alien/humanoid/praetorian/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/praetorian,
		/obj/item/organ/internal/xenos/acidgland/praetorian,
		/obj/item/organ/internal/xenos/neurotoxin
	)

/mob/living/carbon/alien/humanoid/praetorian/UnarmedAttack(atom/target, proximity_flag, list/modifiers)
	if(shield_active)
		to_chat(src, span_warning("Вы не можете атаковать под щитом!"))
		return
	. = ..(target, proximity_flag, modifiers)

/mob/living/carbon/alien/humanoid/praetorian/RangedAttack(atom/A, params)
	if(shield_active)
		to_chat(src, span_warning("Вы не можете атаковать под щитом!"))
		return
	. = ..(A, params)

/mob/living/carbon/alien/humanoid/praetorian/attackby(obj/item/I, mob/living/user, list/modifiers)
	if(shield_active && user == src)
		to_chat(src, span_warning("Вы не можете атаковать под щитом!"))
		return
	. = ..(I, user, modifiers)

/mob/living/carbon/alien/humanoid/praetorian/proc/activate_shield(duration)
	shield_active = TRUE
	shield_end_time = world.time + duration
	SetSlowed(duration, 2)
	update_icons()
	addtimer(CALLBACK(src, PROC_REF(deactivate_shield)), duration, TIMER_UNIQUE | TIMER_OVERRIDE)

/mob/living/carbon/alien/humanoid/praetorian/proc/deactivate_shield()
	if(!shield_active)
		return
	shield_active = FALSE
	update_icons()
	for(var/datum/action/cooldown/spell/praetorian_shield/action in actions)
		action.status_text = null
		action.UpdateButtonIcon()

/mob/living/carbon/alien/humanoid/praetorian/update_icons()
	. = ..()
	if(stat == DEAD)
		return
	if(shield_active)
		icon_state = "praetorian_shield"

/mob/living/carbon/alien/humanoid/praetorian/bullet_act(obj/projectile/proj, def_zone)
	var/impact_dir = NONE
	if(shield_active)
		var/atom/source = proj.starting ? proj.starting : proj.firer
		if(source)
			impact_dir = get_dir(src, source)
		if(impact_dir == src.dir || impact_dir == turn(src.dir, 90) || impact_dir == turn(src.dir, -90))
			if(prob(10))
				if(prob(50))
					visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] отражает [proj.declent_ru(ACCUSATIVE)]!"), \
						span_userdanger("Вы отражаете [proj.declent_ru(ACCUSATIVE)]!"))
					proj.reflect_back(src)
					return -1
				else
					visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] поглощает [proj.declent_ru(ACCUSATIVE)]!"), \
						span_userdanger("Вы поглощаете [proj.declent_ru(ACCUSATIVE)]!"))
					return proj.on_hit(src, 100, def_zone)

	var/base_armor = run_armor_check(def_zone, proj.flag, armour_penetration = proj.armour_penetration)
	var/bonus = 0
	if(shield_active)
		if(impact_dir == src.dir)
			bonus = 25
		else if(impact_dir == turn(src.dir, 90) || impact_dir == turn(src.dir, -90))
			bonus = 10
	var/armor = min(100, base_armor + bonus)
	if(!proj.nodamage && !QDELETED(src))
		apply_damage(proj.damage, proj.damage_type, def_zone, armor)
		if(proj.dismemberment)
			check_projectile_dismemberment(proj, def_zone)
	return proj.on_hit(src, armor, def_zone)

/mob/living/carbon/alien/humanoid/praetorian/ex_act(severity, target)
	. = ..()
	var/shielded = shield_active ? 1 : 0
	var/b_loss = null
	var/f_loss = null
	switch(severity)
		if(EXPLODE_DEVASTATE)
			gib()
			return
		if(EXPLODE_HEAVY)
			if(!shielded)
				b_loss += 60
			f_loss += 60
			AdjustDeaf(120 SECONDS)
		if(EXPLODE_LIGHT)
			b_loss += 30
			if(prob(50) && !shielded)
				Paralyse(2 SECONDS)
	take_overall_damage(b_loss, f_loss)

/mob/living/carbon/alien/humanoid/praetorian/getarmor(def_zone, attack_flag)
	. = ..()
	if(shield_active && attack_flag == BOMB)
		. += 25

/mob/living/carbon/alien/humanoid/praetorian/Paralyse()
	if(shield_active)
		return
	. = ..()

/mob/living/carbon/alien/humanoid/praetorian/Weaken()
	if(shield_active)
		return
	. = ..()

/mob/living/carbon/alien/humanoid/praetorian/Stun()
	if(shield_active)
		return
	. = ..()

/mob/living/carbon/alien/humanoid/praetorian/Knockdown()
	if(shield_active)
		return
	. = ..()

/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"
	caste = "q"
	maxHealth = 750
	health = 750
	icon = 'icons/mob/xeno/queen.dmi'
	icon_state = "queen"
	caste_icon_prefix = "queen"
	gib_icon_state = "queen_gib"
	gib_remains_icon_state = "queen_corpse"
	base_pixel_x = -28
	status_flags = CANPARALYSE
	large = TRUE
	move_resist = MOVE_FORCE_STRONG
	caste_movement_delay = 1.5
	ventcrawler_trait = null
	attack_damage = 40
	disarm_stamina_damage = 50
	armour_penetration = 50
	obj_damage = 80
	time_to_open_doors = 0.2 SECONDS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	pressure_resistance = 200
	antag_datum_type = /datum/antagonist/xenomorph/queen
	tts_seed = "Queen"
	var/mutable_appearance/spit_overlay

/mob/living/carbon/alien/humanoid/queen/Initialize(mapload)
	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in GLOB.alive_mob_list)
		if(Q == src)
			continue
		if(Q.stat == DEAD)
			continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	grant_all_babel_languages()
	. = ..()


/mob/living/carbon/alien/humanoid/queen/proc/play_spit_overlay()
	if(spit_overlay)
		cut_overlay(spit_overlay)
	spit_overlay = mutable_appearance(icon, "queen_spit", FLOAT_LAYER)
	add_overlay(spit_overlay)
	addtimer(CALLBACK(src, PROC_REF(clear_spit_overlay)), 5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/mob/living/carbon/alien/humanoid/queen/proc/clear_spit_overlay()
	if(!spit_overlay)
		return
	cut_overlay(spit_overlay)
	spit_overlay = null

/mob/living/carbon/alien/humanoid/queen/update_icons()
	. = ..()
	if(spit_overlay && stat != DEAD)
		add_overlay(spit_overlay)

/mob/living/carbon/alien/humanoid/queen/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/queen,
		/obj/item/organ/internal/xenos/acidgland/queen,
		/obj/item/organ/internal/xenos/eggsac,
		/obj/item/organ/internal/xenos/resinspinner,
		/obj/item/organ/internal/xenos/neurotoxin
	)

/mob/living/carbon/alien/humanoid/queen/death(gibbed)
	. = ..()
	SSshuttle.remove_hostile_environment(src)

/mob/living/carbon/alien/humanoid/queen/can_inject(mob/user, error_msg, target_zone, penetrate_thick, ignore_pierceimmune)
	return FALSE

/mob/living/carbon/alien/humanoid/queen/is_strong()
	return TRUE

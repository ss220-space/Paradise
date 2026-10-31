/**
 * # Alien Queen
 *
 * The xenomorph queen caste.
 */
/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"
	caste = "q"
	maxHealth = 750
	health = 750
	icon = 'icons/mob/xeno/queen.dmi'
	icon_state = "queen"
	caste_icon_prefix = "queen"
	base_pixel_x = -28
	pixel_x = -28
	status_flags = CANPARALYSE
	large = TRUE
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
	death_sound = 'sound/creatures/alien/alien_queen_died.ogg'
	/// Overlay shown while the queen is spitting.
	var/mutable_appearance/spit_overlay
	/// Overlay shown during the terror shriek.
	var/mutable_appearance/shriek_wave_overlay
	/// Overlay shown during the tail lash.
	var/mutable_appearance/tail_swing_overlay

/mob/living/carbon/alien/humanoid/queen/get_ru_names()
	return alist(
		NOMINATIVE = "королева ксеноморфов",
		GENITIVE = "королевы ксеноморфов",
		DATIVE = "королеве ксеноморфов",
		ACCUSATIVE = "королеву ксеноморфов",
		INSTRUMENTAL = "королевой ксеноморфов",
		PREPOSITIONAL = "королеве ксеноморфов",
	)

/mob/living/carbon/alien/humanoid/queen/Initialize(mapload)
	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/existing_queen in GLOB.alive_mob_list)
		if(existing_queen == src)
			continue
		if(existing_queen.stat == DEAD)
			continue
		if(existing_queen.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = name
	grant_all_babel_languages()
	. = ..()
	AddSpell(new /datum/action/cooldown/spell/aoe/terror_shriek_princess/xeno)
	AddSpell(new /datum/action/cooldown/spell/aoe/repulse/tail_lash)


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

/// Refreshes the queen's overlays after the base icon update.
/mob/living/carbon/alien/humanoid/queen/update_icons()
	. = ..()
	if(stat == DEAD)
		return
	if(spit_overlay)
		add_overlay(spit_overlay)
	if(shriek_wave_overlay)
		add_overlay(shriek_wave_overlay)
	if(tail_swing_overlay)
		add_overlay(tail_swing_overlay)

/mob/living/carbon/alien/humanoid/queen/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/queen,
		/obj/item/organ/internal/xenos/acidgland/queen,
		/obj/item/organ/internal/xenos/eggsac,
		/obj/item/organ/internal/xenos/resinspinner,
		/obj/item/organ/internal/xenos/neurotoxin,
	)

/// Handles queen-specific cleanup on death.
/mob/living/carbon/alien/humanoid/queen/death(gibbed)
	. = ..()
	SSshuttle.remove_hostile_environment(src)
	if(spit_overlay)
		cut_overlay(spit_overlay)
		spit_overlay = null
	if(shriek_wave_overlay)
		cut_overlay(shriek_wave_overlay)
		shriek_wave_overlay = null
	if(tail_swing_overlay)
		cut_overlay(tail_swing_overlay)
		tail_swing_overlay = null

/mob/living/carbon/alien/humanoid/queen/can_inject(mob/user, error_msg, target_zone, penetrate_thick, ignore_pierceimmune)
	return FALSE

/mob/living/carbon/alien/humanoid/queen/is_strong()
	return TRUE

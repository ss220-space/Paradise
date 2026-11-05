/mob/living/carbon/alien/humanoid/empress
	name = "alien empress"
	caste = "q"
	maxHealth = 900
	health = 900
	icon = 'icons/mob/alienhuge.dmi'
	icon_state = "alienq_s"
	pixel_x = -32 // huge sprite, keep it centered on the tile (was set on the removed /empress/large subtype)
	base_pixel_x = -32 // same shift for the add_offsets() base, so lying/standing, grabs, nests don't reset pixel_x
	status_flags = CANPARALYSE
	mob_size = MOB_SIZE_LARGE
	bubble_icon = "alienroyal"
	large = TRUE
	caste_movement_delay = 3
	obj_damage = 100
	time_to_open_doors = 0.2 SECONDS
	attack_damage = 50
	disarm_stamina_damage = 60
	armour_penetration = 60
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	ventcrawler_trait = null
	pressure_resistance = 200 //Because big, stompy xenos should not be blown around like paper.
	antag_datum_type = /datum/antagonist/xenomorph/queen

// 'icons/mob/alienhuge.dmi' only carries alienq_s/alienq_sleep/alienq_dead,
// so the stock update_icons() pose states (running, unconscious, husked) don't exist here.
/mob/living/carbon/alien/humanoid/empress/update_icons()
	cut_overlays()

	if(stat == DEAD)
		icon_state = "alien[caste]_dead"
	else if(stat == UNCONSCIOUS || body_position == LYING_DOWN)
		icon_state = "alien[caste]_sleep"
	else
		icon_state = "alien[caste]_s"

	for(var/image/I in overlays_standing)
		add_overlay(I)

/mob/living/carbon/alien/humanoid/empress/Initialize(mapload)
	. = ..()
	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/empress/E in GLOB.alive_mob_list)
		if(E == src)
			continue
		if(E.stat == DEAD)
			continue
		if(E.client)
			name = "alien grand princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = name

/mob/living/carbon/alien/humanoid/empress/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/queen,
		/obj/item/organ/internal/xenos/acidgland/queen,
		/obj/item/organ/internal/xenos/eggsac,
		/obj/item/organ/internal/xenos/resinspinner,
		/obj/item/organ/internal/xenos/neurotoxin
	)

/mob/living/carbon/alien/humanoid/empress/is_strong()
	return TRUE


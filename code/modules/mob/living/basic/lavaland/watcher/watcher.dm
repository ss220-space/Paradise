/// A floating eyeball which keeps its distance and sometimes make you look away.
/mob/living/basic/mining/watcher
	name = "watcher"
	desc = "A levitating, monocular creature held aloft by wing-like veins. A sharp spine of crystal protrudes from its body."
	icon_state = "watcher"
	icon_living = "watcher"
	icon_dead = "watcher_dead"
	health_doll_icon = "watcher"
	pixel_x = -12
	base_pixel_x = -12
	speak_emote = list("chimes")
	speed = 3
	maxHealth = 160
	health = 160
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = "buffets"
	attack_verb_simple = "buffet"
	crusher_loot = /obj/item/crusher_trophy/watcher_wing
	ai_controller = /datum/ai_controller/basic_controller/watcher
	butcher_results = list(
		/obj/item/stack/sheet/bone = 1,
		/obj/item/stack/ore/diamond = 2,
		/obj/item/stack/sheet/sinew = 2,
	)
	/// How often can we shoot?
	var/ranged_cooldown = 3 SECONDS
	/// What kind of beams we got?
	var/projectile_type = /obj/projectile/temp/watcher
	/// Icon state for our eye overlay
	var/eye_glow = "watcher_glow"
	/// Sound to play when we shoot
	var/shoot_sound = 'sound/weapons/pierce.ogg'
	/// Typepath of our gaze ability
	var/gaze_attack = /datum/action/cooldown/mob_cooldown/watcher_gaze

/mob/living/basic/mining/watcher/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/content_barfer)
	var/list/drops = get_loot_list()
	if(length(drops))
		AddElement(/datum/element/death_drops, string_list(drops))
	AddComponent(/datum/component/ai_target_timer)
	AddComponent(/datum/component/basic_ranged_ready_overlay, overlay_state = eye_glow)
	AddComponent(\
		/datum/component/ranged_attacks,\
		cooldown_time = ranged_cooldown,\
		projectile_type = projectile_type,\
		projectile_sound = shoot_sound,\
	)

	var/datum/action/cooldown/mob_cooldown/watcher_gaze/gaze = new gaze_attack(src)
	gaze.Grant(src)
	ai_controller.set_blackboard_key(BB_GENERIC_ACTION, gaze)
	AddComponent(/datum/component/revenge_ability, gaze, targeting = GET_TARGETING_STRATEGY(ai_controller.blackboard[BB_TARGETING_STRATEGY]))

/// More durable, burning projectiles
/mob/living/basic/mining/watcher/magmawing
	name = "magmawing watcher"
	desc = "Presented with extreme temperatures, adaptive watchers absorb heat through their circulatory wings and repurpose it as a weapon."
	icon_state = "watcher_magmawing"
	icon_living = "watcher_magmawing"
	icon_dead = "watcher_magmawing_dead"
	eye_glow = "fire_glow"
	maxHealth = 175 //Compensate for the lack of slowdown on projectiles with a bit of extra health
	health = 175
	projectile_type = /obj/projectile/temp/watcher/magma_wing
	gaze_attack = /datum/action/cooldown/mob_cooldown/watcher_gaze/fire
	crusher_loot = /obj/item/crusher_trophy/blaster_tubes/magma_wing
	crusher_drop_chance = 100 // There's only going to be one of these per round throw them a bone

/mob/living/basic/mining/watcher/magmawing/get_loot_list()
	var/static/list/death_loot = list(/obj/item/gem/magma)
	return death_loot

/mob/living/basic/mining/watcher/magmawing/spawner_made

/mob/living/basic/mining/watcher/magmawing/spawner_made/get_loot_list()
	return null

/// Less durable, freezing projectiles
/mob/living/basic/mining/watcher/icewing
	name = "icewing watcher"
	desc = "Watchers which fail to absorb enough heat during their development become fragile, but share their internal chill with their enemies."
	icon_state = "watcher_icewing"
	icon_living = "watcher_icewing"
	icon_dead = "watcher_icewing_dead"
	eye_glow = "ice_glow"
	maxHealth = 130
	health = 130
	projectile_type = /obj/projectile/temp/watcher/ice_wing
	gaze_attack = /datum/action/cooldown/mob_cooldown/watcher_gaze/ice
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/bone = 1)
	crusher_loot = /obj/item/crusher_trophy/watcher_wing/ice_wing
	crusher_drop_chance = 100

/mob/living/basic/mining/watcher/icewing/get_loot_list()
	var/static/list/death_loot = list(/obj/item/gem/fdiamond)
	return death_loot

/mob/living/basic/mining/watcher/icewing/spawner_made

/mob/living/basic/mining/watcher/icewing/spawner_made/get_loot_list()
	return null

/mob/living/basic/mining/watcher/random

/mob/living/basic/mining/watcher/random/Initialize(mapload)
	. = ..()
	if(prob(40))
		if(prob(50))
			new /mob/living/basic/mining/watcher/magmawing(loc)
		else
			new /mob/living/basic/mining/watcher/icewing(loc)
		return INITIALIZE_HINT_QDEL

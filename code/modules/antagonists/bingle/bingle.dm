/mob/living/simple_animal/hostile/bingle
	name = "bingle"
	real_name = "bingle"
	desc = "Тёмно-фиолетовое существо, чем-то напоминающее гориллу."
	speak_emote = list("визжит", "хнычет", "булькает", "тыдынькает")
	icon = 'icons/mob/bingle/bingles.dmi'
	icon_state = "bingle"
	icon_living = "bingle"
	icon_dead = "bingle"

	pass_flags = PASSTABLE

	maxHealth = 75
	health = 75
	speed = 0.5
	pressure_resistance = 100
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_WALLS
	melee_damage_lower = 1
	melee_damage_upper = 1

	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	attacktext = "бьёт"
	attack_sound = 'sound/effects/blobattack.ogg'
	butcher_results = null
	/// What hole we appeared from (or connected to)
	var/spawn_hole_uid

	/// Flag to check if we are already evolved or not
	var/evolved = FALSE
	/// What icon state we get on evolving
	var/evolved_icon_state = "bingle_armored"

	/// Additional stamina damage on attack
	var/stamina_damage = 33

	/// The minimum amount of reagents used on death
	var/reagents_amount_min = 3
	/// The maximum amount of reagents used on death
	var/reagents_amount_max = 5
	/// The minimum units amount of a reagent used on death
	var/reagent_min = 20
	/// The maximum units amount of a reagent used on death
	var/reagent_max = 30
	/// The range of the smoke on death
	var/smoke_range = 2

	/// Static list of all traits used by bingles
	var/static/list/bingle_traits = list(
		TRAIT_HEALS_FROM_BINGLE_HOLES,
		TRAIT_NEGATES_GRAVITY,
	)

/mob/living/simple_animal/hostile/bingle/get_ru_names()
	return list(
		NOMINATIVE = "бингл",
		GENITIVE = "бингла",
		DATIVE = "бинглу",
		ACCUSATIVE = "бингла",
		INSTRUMENTAL = "бинглом",
		PREPOSITIONAL = "бингле"
	)

/mob/living/simple_animal/hostile/bingle/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = INFINITY, \
		minbodytemp = 0, \
	)
	AddComponent(\
		/datum/component/ghost_direct_control, \
		ban_type = ROLE_BINGLE, \
		poll_candidates = FALSE, \
		after_assumed_control = CALLBACK(src, PROC_REF(add_datum_if_not_exist)), \
	)

/mob/living/simple_animal/hostile/bingle/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_BITE
	..()

/mob/living/simple_animal/hostile/bingle/Initialize(mapload, obj/structure/bingle_hole/hole)
	. = ..()
	if(hole)
		var/hole_uid = hole.UID()
		spawn_hole_uid = hole_uid
		LAZYADDASSOCLIST(GLOB.bingles_by_hole, hole_uid, src)
	RegisterSignal(src, COMSIG_BINGLE_EVOLVE, PROC_REF(evolve))
	RegisterSignal(src, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	add_traits(bingle_traits, INNATE_TRAIT)

/mob/living/simple_animal/hostile/bingle/Destroy()
	if(spawn_hole_uid)
		LAZYREMOVEASSOC(GLOB.bingles_by_hole, spawn_hole_uid, src)
	UnregisterSignal(src, COMSIG_BINGLE_EVOLVE)
	UnregisterSignal(src, COMSIG_LIVING_DEATH)
	remove_traits(bingle_traits, INNATE_TRAIT)
	return ..()

/mob/living/simple_animal/hostile/bingle/update_icon_state()
	icon_state = evolved ? evolved_icon_state : icon_state // We can't really unevolve

/mob/living/simple_animal/hostile/bingle/proc/on_evolve()
	SIGNAL_HANDLER
	evolve()

/mob/living/simple_animal/hostile/bingle/proc/evolve()
	evolved = TRUE
	maxHealth *= BINGLE_EVOLVE_HEALTH_MULTIPLIER
	obj_damage *= BINGLE_EVOLVE_OBJ_DAMAGE_MULTIPLIER
	update_icon(UPDATE_ICON_STATE)

/mob/living/simple_animal/hostile/bingle/AttackingTarget()
	. = ..()
	if(!.)
		return
	if(!isliving(target))
		return
	var/mob/living/living = target
	if(issilicon(living) || isanimal(living))
		living.apply_damage(stamina_damage, BRUTE)
	living.apply_effects(stutter = 10 SECONDS, confused = 2 SECONDS, stamina = stamina_damage)

/mob/living/simple_animal/hostile/bingle/proc/on_death()
	SIGNAL_HANDLER
	smoke_on_death()
	gib()

/mob/living/simple_animal/hostile/bingle/proc/smoke_on_death()
	var/list/possible_chems = get_death_chem_list()
	var/chemicals_to_use = rand(reagents_amount_min, reagents_amount_max)
	var/datum/reagents/reagents_list = new (reagent_max * reagents_amount_max)
	for(var/i in 1 to chemicals_to_use)
		var/chem_id = pick(possible_chems)
		reagents_list.add_reagent(chem_id, rand(reagent_min, reagent_max))

	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
	smoke.set_up(range = smoke_range, location = loc, carry = reagents_list, silent = TRUE)
	smoke.start()

/// Proc used to get a chem list for smoke on death
/mob/living/simple_animal/hostile/bingle/proc/get_death_chem_list()
	return GLOB.standard_chemicals

/mob/living/simple_animal/hostile/bingle/proc/add_datum_if_not_exist()
	if(!(mind.has_antag_datum(/datum/antagonist/bingle)))
		mind.add_antag_datum(/datum/antagonist/bingle, /datum/team/bingles)

/mob/living/simple_animal/hostile/bingle/lord
	name = "bingle lord"
	real_name = "bingle lord"
	desc = "Крупное тёмно-фиолетовое существо, чем-то напоминающее гориллу. Крупнее и агрессивнее своих сородичей."
	icon = 'icons/mob/bingle/binglelord.dmi'
	icon_state = "binglelord"
	icon_living = "binglelord"
	icon_dead = "binglelord"
	evolved_icon_state = "binglelord_armored"

	maxHealth = 200
	health = 200

	environment_smash = ENVIRONMENT_SMASH_RWALLS

	reagents_amount_min = 10
	reagents_amount_max = 15
	reagent_min = 50
	reagent_max = 75
	smoke_range = 7

	stamina_damage = 60

/mob/living/simple_animal/hostile/bingle/lord/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/bingle/create_hole/hole_action = new
	hole_action.Grant(src)

/mob/living/simple_animal/hostile/bingle/lord/get_death_chem_list()
	return GLOB.liver_toxins + GLOB.borer_reagents

/mob/living/simple_animal/hostile/bingle/lord/add_datum_if_not_exist()
	if(!(mind.has_antag_datum(/datum/antagonist/bingle/lord)))
		mind.add_antag_datum(/datum/antagonist/bingle/lord, /datum/team/bingles)

/mob/living/simple_animal/hostile/bingle/lord/get_ru_names()
	return list(
		NOMINATIVE = "лорд бинглов",
		GENITIVE = "лорда бинглов",
		DATIVE = "лорду бинглов",
		ACCUSATIVE = "лорда бинглов",
		INSTRUMENTAL = "лордом бинглов",
		PREPOSITIONAL = "лорде бинглов"
	)

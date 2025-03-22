///Simple animals 2.0, This time, let's really try to keep it simple. This basetype should purely be used as a base-level for implementing simplified behaviours for things such as damage and attacks. Everything else should be in components or AI behaviours.
/mob/living/basic
	name = "basic mob"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20
	gender = PLURAL
	status_flags = CANPUSH

	var/basic_mob_flags = NONE

	///Defines how fast the basic mob can move. This is a multiplier
	var/speed = 1
	///How much stamina the mob recovers per second
	var/stamina_recovery = 5

	///how much damage this basic mob does to objects, if any.
	var/obj_damage = 0
	///How much armour they ignore, as a flat reduction from the targets armour value.
	var/armour_penetration = 0
	///Damage type of a simple mob's melee attack, should it do damage.
	var/melee_damage_type = BRUTE


	///How much wounding power it has
	// var/wound_bonus = CANT_WOUND
	///How much bare wounding power it has
	var/bare_wound_bonus = 0
	///If the attacks from this are sharp
	var/sharpness = NONE

	/// Sound played when the critter attacks.
	var/attack_sound
	/// Override for the visual attack effect shown on 'do_attack_animation()'.
	var/attack_vis_effect
	///Played when someone punches the creature.
	var/attacked_sound = "punch" //This should be an element

	///What kind of objects this mob can smash.
	var/environment_smash = ENVIRONMENT_SMASH_NONE

	/// 1 for full damage , 0 for none , -1 for 1:1 heal from that source.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)

	///Verbs used for speaking e.g. "Says" or "Chitters". This can be elementized
	speak_emote = list()

	/// Minimum force required to deal any damage
	var/force_threshold = 0

	///When someone interacts with the simple animal.
	/// Help-intent verb in present continuous tense. "кто-то [response_help_continuous] вас"
	var/response_help_continuous = "осторожно тыкает"
	/// Help-intent verb in present simple tense. "Вы [response_help_simple] цель"
	var/response_help_simple = "осторожно ткнули"
	/// Disarm-intent verb in present continuous tense. "Кто-то [response_disarm_continuous] вас"
	var/response_disarm_continuous = "толкает"
	/// Disarm-intent verb in present simple tense. "Вы [response_disarm_simple] цель"
	var/response_disarm_simple = "толкнули"
	/// Harm-intent verb in present continuous tense. "Кто-то [response_harm_continuous] цель"
	var/response_harm_continuous = "ударяет"
	/// Harm-intent verb in present simple tense. "Вы [response_harm_simple] цель"
	var/response_harm_simple = "ударили"

	///Basic mob's own attacks verbs,
	///Attacking verb in present continuous tense. "Кто-то [attack_verb_continuous] цель"
	var/attack_verb_continuous = "атакует"
	///Attacking verb in present simple tense. "Вы [response_harm_simple] цель"
	var/attack_verb_simple = "атаковали"
	///Attacking, but without damage, verb in present continuous tense.
	var/friendly_verb_continuous = "обнюхивает"
	///Attacking, but without damage, verb in present simple tense.
	var/friendly_verb_simple = "нюхает"

	////////THIS SECTION COULD BE ITS OWN ELEMENT
	///Icon to use
	var/icon_living = ""
	///Icon when the animal is dead. Don't use animated icons for this.
	var/icon_dead = ""
	///We only try to show a gibbing animation if this exists.
	var/icon_gib = null
	///Flip the sprite upside down on death. Mostly here for things lacking custom dead sprites.
	var/flip_on_death = FALSE

	///If the mob can be spawned with a gold slime core. HOSTILE_SPAWN are spawned with plasma, FRIENDLY_SPAWN are spawned with blood.
	var/gold_core_spawnable = NO_SPAWN
	///Sentience type, for slime potions. SHOULD BE AN ELEMENT BUT I DONT CARE ABOUT IT FOR NOW
	var/sentience_type = SENTIENCE_ORGANIC

	var/list/atmos_requirements = list(
		"min_oxy" = 5,
		"max_oxy" = 0,
		"min_plas" = 0,
		"max_plas" = 1,
		"min_co2" = 0,
		"max_co2" = 5,
		"min_n2" = 0,
		"max_n2" = 0
	)
	/// This damage is taken when atmos doesn't fit all the requirements above.
	/// Set to 0 to avoid adding the atmos_requirements element.
	var/unsuitable_atmos_damage = 5
	/// Set to FALSE to avoid getting damage from temparature
	var/affects_by_temperature = TRUE
	/// Minimal body temperature without receiving damage
	var/minimum_survivable_temperature = 250
	/// Maximal body temperature without receiving damage
	var/maximum_survivable_temperature = 350

/mob/living/basic/Initialize(mapload)
	. = ..()

	if(gender == PLURAL)
		gender = pick(MALE,FEMALE)

	if(!real_name)
		real_name = name

	if(!loc)
		stack_trace("Basic mob being instantiated in nullspace")

	update_basic_mob_varspeed()

	if(speak_emote)
		speak_emote = string_list(speak_emote)

	apply_atmos_requirements()
	apply_temperature_requirements()

/mob/living/basic/proc/apply_atmos_requirements()
	if(unsuitable_atmos_damage == 0)
		return

	atmos_requirements = string_assoc_list(atmos_requirements)

	AddElement(/datum/element/atmos_requirements, atmos_requirements, unsuitable_atmos_damage)

/mob/living/basic/proc/apply_temperature_requirements()
	if(!affects_by_temperature)
		return
	AddComponent(/datum/component/animal_temperature, minimum_survivable_temperature, maximum_survivable_temperature)

/mob/living/basic/Life(delta_time, times_fired)
	. = ..()
	///Automatic stamina re-gain
	if(staminaloss > 0)
		adjustStaminaLoss(-stamina_recovery * delta_time, FALSE, TRUE)

/mob/living/basic/death(gibbed)
	if(!gibbed)
		if(!(basic_mob_flags & DEL_ON_DEATH))
			INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "deathgasp")

	if(basic_mob_flags & DEL_ON_DEATH)
		..()
		qdel(src)
		return
	else
		health = 0
		icon_state = icon_dead
		if(flip_on_death)
			transform = transform.Turn(180)
		set_density(FALSE)
		..()

// copied from simplemobs
/mob/living/basic/revive(full_heal = 0, admin_revive = 0)
	if(..()) //successfully ressuscitated from death
		icon = initial(icon)
		icon_state = icon_living
		set_density(initial(density))
		mobility_flags = MOBILITY_FLAGS_DEFAULT

/mob/living/basic/proc/melee_attack(atom/target)
	src.face_atom(target)
	// if(SEND_SIGNAL(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, target) & COMPONENT_HOSTILE_NO_ATTACK)
	// 	return FALSE //but more importantly return before attack_animal called
	var/result = target.attack_basic_mob(src)
	// SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, result) //Bee edit: We don't have pre_attackingtarget nor hostile simplemobs, so I'll just leave these here for anyone who stumbles upon this down the line
	return result

/mob/living/basic/proc/set_varspeed(var_value)
	speed = var_value
	update_basic_mob_varspeed()

/mob/living/basic/proc/update_basic_mob_varspeed()
	if(speed == 0)
		remove_movespeed_modifier(/datum/movespeed_modifier/simplemob_varspeed)
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/simplemob_varspeed, multiplicative_slowdown = speed)
	SEND_SIGNAL(src, POST_BASIC_MOB_UPDATE_VARSPEED)

//temp code
/mob/living/basic/examine(mob/user)
	. = ..()
	if(stat == DEAD)
		. += "<span class='deadsay'>Upon closer examination, [p_they()] appear[p_s()] to be dead.</span>"
		return

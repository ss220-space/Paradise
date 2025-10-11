/// Bonus amount of blood that vampire sucks from victim in units per diablerie level. Base is 30u, max is 50u with fourth level bonus
#define DIABLERIE_SUCKING_AMOUNT 5
/// Diablerie level at which our diablerie aura is shown to everyone, used only for convenience
#define ASCENDED_AURA_LEVEL 3


/**
 * "Diablerie" thing is entirely World of Darkness reference. In simple terms, 'diablerie' is the act of a vampire
 * killing another vampire by draining all of their blood, thereby taking their soul and becoming more powerful.
 * The word "diablerie" comes from French "diable" + "erie", which means something like "devilish practice"
 */
/datum/diablerie
	/// Reference to vampire antagonist datum, owner of this diablerie datum
	var/datum/antagonist/vampire/vampire_datum
	/// Reference to the vampire, owner of vampire datum
	var/mob/living/carbon/human/vampire
	/// Amount of times we performed diablerie on someone, limit is DIABLERIE_COUNT_MAX. Matches current diablerie level
	var/diablerie_count = 0
	/// Reference to diablerie aura. On level 1 only vampires can see it, at level [ASCENDED_AURA_LEVEL] — everyone
	var/obj/effect/diablerie_aura/diablerie_aura
	/// Used to store user unarmed attack datum to retrieve it, because we modify it
	var/datum/unarmed_attack/old_unarmed
	var/old_unarmed_type
	/// Static list of initialized diablerie levels
	var/static/list/diablerie_levels = list(
		new /datum/diablerie_level/level_one,
		new /datum/diablerie_level/level_two,
		new /datum/diablerie_level/level_three,
		new /datum/diablerie_level/level_four,
	)


/datum/diablerie/New(datum/antagonist/vampire/vampire_datum)
	. = ..()
	src.vampire_datum = vampire_datum
	vampire = vampire_datum.owner.current
	old_unarmed = vampire.dna.species.unarmed
	old_unarmed_type = vampire.dna.species.unarmed_type


/datum/diablerie/Destroy(force)
	UnregisterSignal(vampire, list(COMSIG_LIVING_DEATH, COMSIG_HUMAN_DESTROYED))
	force_diablerie_level(0)
	old_unarmed = null
	old_unarmed_type = null
	vampire_datum.diablerie = null
	vampire_datum = null
	vampire = null
	return ..()


/**
 * Adds [DIABLERIE_AURA_HUD] to the vampire to avoid using see_invis, only for levels below [ASCENDED_AURA_LEVEL]
 */
/datum/diablerie/proc/add_diablerie_hud(mob/living/owner)
	var/datum/atom_hud/diablerie_aura/aura_hud = GLOB.huds[DIABLERIE_AURA_HUD]
	aura_hud.add_atom_to_hud(owner)

	var/image/aura = owner.hud_list[DIABLERIE_AURA_HUD]
	if(!aura)
		return

	var/mutable_appearance/mutable = mutable_appearance(icon = 'icons/effects/vampire_effects.dmi', icon_state = "diablerie_aura", layer = vampire.layer - 0.1)
	aura.appearance = mutable


/**
 * Removes [DIABLERIE_AURA_HUD] from the vampire
 */
/datum/diablerie/proc/remove_diablerie_hud(mob/living/owner)
	var/datum/atom_hud/diablerie_aura/aura_hud = GLOB.huds[DIABLERIE_AURA_HUD]
	aura_hud.remove_atom_from_hud(owner)


/**
 * Increases diablerie level by one
 */
/datum/diablerie/proc/increase_diablerie_level()
	if(diablerie_count >= DIABLERIE_COUNT_MAX)
		return

	diablerie_count++
	var/datum/diablerie_level/diablerie_level = diablerie_levels[diablerie_count]
	diablerie_level.gain(src)
	apply_additional_bonuses()


/**
 * Decreases diablerie level by one
 */
/datum/diablerie/proc/decrease_diablerie_level()
	if(diablerie_count <= 0)
		return

	var/datum/diablerie_level/diablerie_level = diablerie_levels[diablerie_count]
	diablerie_level.remove(src)
	remove_additional_bonuses()
	diablerie_count--

	to_chat(vampire, span_danger("Вы ощущаете боль по всему телу, теряя драгоценную часть своей силы."))


/**
 * Every diablerie level increases amount of blood taken from victim per cycle by [DIABLERIE_SUCKING_AMOUNT]
 * and applies [DIABLERIE_COOLDOWN_REDUCTION] bonus on every active spell vampire has
 */
/datum/diablerie/proc/apply_additional_bonuses()
	vampire_datum.sucking_amount += DIABLERIE_SUCKING_AMOUNT
	for(var/obj/effect/proc_holder/spell/power in vampire_datum.powers)
		power.cooldown_handler.change_cooldowns(recharge_reduction = DIABLERIE_COOLDOWN_REDUCTION)

/**
 * Proc to properly remove bonuses from dibalerie level if it has been decreased
 */
/datum/diablerie/proc/remove_additional_bonuses()
	vampire_datum.sucking_amount = max(vampire_datum.sucking_amount - DIABLERIE_SUCKING_AMOUNT, initial(vampire_datum.sucking_amount))
	for(var/obj/effect/proc_holder/spell/power in vampire_datum.powers)
		power.cooldown_handler.change_cooldowns(recharge_reduction = -DIABLERIE_COOLDOWN_REDUCTION)


/**
 * Handles both cases of adding aura: just hud for vampires or the effect if we have ascended aura.
 * If 'ascended' set to 'TRUE', applies to the vampire the ascended aura seen by anyone
 */
/datum/diablerie/proc/add_diablerie_aura(ascended = FALSE)
	if(!ascended)
		add_diablerie_hud(vampire)
		return

	diablerie_aura = new()
	vampire.vis_contents |= diablerie_aura
	vampire.update_appearance()


/**
 * Proc to transfer diablerie aura from one mob to another, when transforming or transfering bodies
 *
 * Arguments:
 * * old_body - Old body to remove aura from
 * * new_body - New body to transfer aura to
 */
/datum/diablerie/proc/transfer_diablerie_aura(mob/living/old_body, mob/living/new_body)
	// Only vampires can see our aura at this moment, so we just transfer hud to the new body
	if(diablerie_count < ASCENDED_AURA_LEVEL)
		remove_diablerie_hud(old_body)
		add_diablerie_hud(new_body)
		return

	// At this point we already have aura as an effect seen by anyone, so we transfer it between vis_contents
	old_body?.vis_contents -= diablerie_aura
	old_body?.update_appearance()

	new_body?.vis_contents += diablerie_aura
	new_body?.update_appearance()


/**
 * Handles both cases of removing aura: removing vampire from hud or deleting the effect if we have ascended aura
 * if 'ascended' set to 'TRUE', removes from the vampire and deletes the diablerie_aura effect
 */
/datum/diablerie/proc/remove_diablerie_aura(ascended = FALSE)
	if(!ascended)
		remove_diablerie_hud(vampire)
		return

	vampire.vis_contents -= diablerie_aura
	vampire.update_appearance()
	QDEL_NULL(diablerie_aura)


/**
 * Proc to force certain diablerie level, used by traitor panel
 *
 * Arguments:
 * * level_to_force - Diablerie level we want to force on a vampire
 */
/datum/diablerie/proc/force_diablerie_level(level_to_force)
	if(level_to_force > DIABLERIE_COUNT_MAX || level_to_force < 0 || level_to_force == diablerie_count)
		return

	while(level_to_force > diablerie_count)
		increase_diablerie_level()

	while(level_to_force < diablerie_count)
		decrease_diablerie_level()

/**
 * Handles vampire ascension announcment and changes security code to GAMMA
 */
/datum/diablerie/proc/announce_vampire_ascended(mob/living/carbon/human/vampire)
	// We don't want announcments from shitspawning at admin zone
	var/turf/vampire_turf = get_turf(vampire)
	if(is_admin_level(vampire_turf.z))
		return

	RegisterSignal(vampire, list(COMSIG_LIVING_DEATH, COMSIG_HUMAN_DESTROYED), PROC_REF(announce_vampire_fallen))
	// We send an announcment and set station sec code to GAMMA so the crew can now legally fight the diablerie-ascended vampire
	GLOB.major_announcement.announce("Сканерами дальнего действия зафиксирован мощный всплеск блюспейс энергии, \
		указывающий на появление вампира особого класса. Его личность — [vampire.real_name]. Дальнейшее возвышение вампира должно быть немедленно предотвращено.",
		ANNOUNCE_CCPARANORMAL_RU,
		'sound/AI/commandreport.ogg'
	)
	log_game("Vampire [key_name(vampire)] reached [diablerie_count] diablerie level. Setting security level to GAMMA.")
	addtimer(CALLBACK(SSsecurity_level, TYPE_PROC_REF(/datum/controller/subsystem/security_level, set_level), SEC_LEVEL_GAMMA), 5 SECONDS)


/**
 * Handles vampire death announcment and changes security code to RED
 */
/datum/diablerie/proc/announce_vampire_fallen(mob/living/carbon/human/vampire)
	SIGNAL_HANDLER

	// We don't want announcments from shitspawning at admin zone
	var/turf/vampire_turf = get_turf(vampire)
	if(is_admin_level(vampire_turf.z))
		return

	GLOB.major_announcement.announce("Сканеры дальнего действия более не фиксируют блюспейс сигнатуру вампира особого класса, \
		возвышение было успешно предотвращено экипажем.",
		ANNOUNCE_CCPARANORMAL_RU,
		'sound/AI/commandreport.ogg'
	)
	log_game("Diablerie ascended vampire [key_name(vampire)] was killed by the crew. Lowering security level to RED.")
	addtimer(CALLBACK(SSsecurity_level, TYPE_PROC_REF(/datum/controller/subsystem/security_level, set_level), SEC_LEVEL_RED), 5 SECONDS)
	UnregisterSignal(vampire, list(COMSIG_LIVING_DEATH, COMSIG_HUMAN_DESTROYED))

/**
 * Applies all special effects of the current level to vampire
 */
/datum/diablerie_level/proc/gain(datum/diablerie/diablerie)
	SEND_SIGNAL(diablerie.vampire_datum, SIGNAL_DIABLERIE_LEVEL_GAIN, src)
	return

/**
 * Removes all special effects of the current level from vampire
 */
/datum/diablerie_level/proc/remove(datum/diablerie/diablerie)
	SEND_SIGNAL(diablerie.vampire_datum, SIGNAL_DIABLERIE_LEVEL_REMOVE, src)
	return


/**
 * Upgrades glare spells cooldown charges
 */
/datum/diablerie_level/proc/upgrade_glare_charges(datum/spell_cooldown/charges/charges)
	return

/**
 * Upgrade rejuvenate spells cooldown charges
 */
/datum/diablerie_level/proc/upgrade_rejuvenate_charges(datum/spell_cooldown/charges/charges)
	return

/**
 * Downgrade glare spells cooldown charges
 */
/datum/diablerie_level/proc/downgrade_glare_charges(datum/spell_cooldown/charges/charges)
	return

/**
 * Downgrade rejuvenate spells cooldown charges
 */
/datum/diablerie_level/proc/downgrade_rejuvenate_charges(datum/spell_cooldown/charges/charges)
	return

/**
 * Upgrades rejuvenate charges to 2,
 * CDR here is 5%,
 * sucking 35 units of blood per cycle
*/
/datum/diablerie_level/level_one/gain(datum/diablerie/diablerie)
	. = ..()
	var/mob/living/carbon/human/vampire = diablerie.vampire

	diablerie.add_diablerie_aura()

	ADD_TRAIT(vampire, TRAIT_NO_BREATH, VAMPIRE_TRAIT)

	to_chat(vampire, span_boldnotice("Сила вашего \"Восстановления\" возросла, и вы можете применять его больше раз. Кроме того, вам более не нужно дышать."))

/datum/diablerie_level/level_one/upgrade_rejuvenate_charges(datum/spell_cooldown/charges/charges)
	charges.change_cooldowns(new_max_charges = (charges.max_charges + 1))

/datum/diablerie_level/level_one/remove(datum/diablerie/diablerie)
	. = ..()

	diablerie.remove_diablerie_aura()

	REMOVE_TRAIT(diablerie.vampire, TRAIT_NO_BREATH, VAMPIRE_TRAIT)

/datum/diablerie_level/level_one/downgrade_rejuvenate_charges(datum/spell_cooldown/charges/charges)
	charges.change_cooldowns(new_max_charges = (charges.max_charges - 1))

/**
 * Upgrades glare charges to 3,
 * CDR here is 10%,
 * sucking 40 units of blood per cycle
 */
/datum/diablerie_level/level_two/gain(datum/diablerie/diablerie)
	. = ..()
	var/mob/living/carbon/human/vampire = diablerie.vampire
	// If the vampire doesn't cover his face, examination will reveal his dark nature
	if(!vampire.original_eye_color)
		vampire.original_eye_color = vampire.get_eye_color()

	ADD_TRAIT(vampire, TRAIT_RED_EYES, VAMPIRE_TRAIT)
	vampire.change_eye_color(COLOR_RED, FALSE)

	to_chat(vampire, span_boldnotice("Сила вашего взгляда возросла, и вы можете больше раз применять \"Вспышку\". Ваши глаза наливаются кроваво-красным светом."))

/datum/diablerie_level/level_two/upgrade_glare_charges(datum/spell_cooldown/charges/charges)
	charges.change_cooldowns(new_max_charges = (charges.max_charges + 1))

/datum/diablerie_level/level_two/remove(datum/diablerie/diablerie)
	. = ..()
	var/mob/living/carbon/human/vampire = diablerie.vampire

	if(!vampire.original_eye_color)
		vampire.original_eye_color = vampire.get_eye_color()

	REMOVE_TRAIT(vampire, TRAIT_RED_EYES, VAMPIRE_TRAIT)
	vampire.change_eye_color(vampire.original_eye_color, FALSE)

/datum/diablerie_level/level_two/downgrade_glare_charges(datum/spell_cooldown/charges/charges)
	charges.change_cooldowns(new_max_charges = (charges.max_charges - 1))

/**
 * Rejuvenate now heals internal bleedings,
 * black aura is seen by anyone,
 * CDR here is 15%,
 * sucking 45 units of blood per cycle
 */
/datum/diablerie_level/level_three/gain(datum/diablerie/diablerie)
	. = ..()
	diablerie.vampire_datum.add_ability(/datum/vampire_passive/regen_bleeding)

	diablerie.remove_diablerie_aura()
	diablerie.add_diablerie_aura(ascended = TRUE)

	to_chat(diablerie.vampire, span_boldnotice("Сила вашего \"Восстановления\" возросла, и теперь с его помощью вы можете восстанавливать внутренние кровотечения. Ваша аура теперь видна даже простым смертным. Вы всего в шаге от вершины могущества!"))


/datum/diablerie_level/level_three/remove(datum/diablerie/diablerie)
	. = ..()
	diablerie.vampire_datum.remove_ability(/datum/vampire_passive/regen_bleeding)

	diablerie.remove_diablerie_aura(ascended = TRUE)
	diablerie.add_diablerie_aura()


/**
 * Vampire gets 5 strength level, gargantua subclass has it by default, so they get claws no matter the species,
 * glare now ignores direction deviation and works fully for every direction,
 * vampire gets the ability to revive dead people as a vampires with free will and no antag objectives,
 * CC sends an announcment and vampire becomes major antagonist,
 * CDR here is 20%,
 * sucking 50 units of blood per cycle
 */
/datum/diablerie_level/level_four/gain(datum/diablerie/diablerie)
	. = ..()
	var/datum/antagonist/vampire/vampire_datum = diablerie.vampire_datum
	var/mob/living/carbon/human/vampire = diablerie.vampire

	vampire_datum.add_ability(/datum/vampire_passive/glare_aoe)

	vampire_datum.add_ability(/obj/effect/proc_holder/spell/vampire/raise_free_vampire)

	if(istype(vampire_datum.subclass, SUBCLASS_GARGANTUA))
		vampire.dna.species.unarmed = new /datum/unarmed_attack/claws
		vampire.dna.species.unarmed_type = /datum/unarmed_attack/claws
	else
		ADD_TRAIT(vampire, TRAIT_STRONG_MUSCLES, VAMPIRE_TRAIT)
		SEND_SIGNAL(vampire, COMSIG_STRENGTH_LEVEL_UP, 5)

	to_chat(vampire, span_boldnotice("Сила вашего тела возросла. Ваша \"Вспышка\" теперь срабатывает в полную силу, независимо от направления взгляда. Вы достигли пика своего могущества. Теперь долгом всех смертных будет уничтожить вас!"))

	diablerie.announce_vampire_ascended(vampire)


/datum/diablerie_level/level_four/remove(datum/diablerie/diablerie)
	. = ..()
	var/datum/antagonist/vampire/vampire_datum = diablerie.vampire_datum
	var/mob/living/carbon/human/vampire = diablerie.vampire

	vampire_datum.remove_ability(/datum/vampire_passive/glare_aoe)

	var/obj/effect/proc_holder/spell/vampire/raise_free_vampire/raise_free_vampire = locate() in vampire_datum.powers
	vampire_datum.remove_ability(raise_free_vampire)

	if(istype(vampire_datum.subclass, SUBCLASS_GARGANTUA))
		vampire.dna.species.unarmed = diablerie.old_unarmed
		vampire.dna.species.unarmed_type = diablerie.old_unarmed_type
	else
		REMOVE_TRAIT(vampire, TRAIT_STRONG_MUSCLES, VAMPIRE_TRAIT)

	diablerie.announce_vampire_fallen(vampire)


/obj/effect/diablerie_aura
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "diablerie_aura"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_UNDERLAY


#undef DIABLERIE_SUCKING_AMOUNT
#undef ASCENDED_AURA_LEVEL


#define WIELDER_SPELLS "wielder_spell"
#define SWORD_SPELLS "sword_spell"
#define SWORD_PREFIX "sword_prefix"

/obj/item/melee/cultblade/haunted
	name = "призрачный меч"
	desc = "Жуткий меч с клинком, который не чёрный, а скорей вообще не существует. \
			Он светится яростной, сдержанной зелёной энергией."
	icon_state = "hauntedblade"
	item_state = "hauntedblade"
	item_state = "hauntedblade"
	throwforce = 25
	block_chance = 55
	//wound_bonus = -25
	//bare_wound_bonus = 30
	free_use = TRUE
	light_color = COLOR_HERETIC_GREEN
	light_range = 3
	//demolition_mod = 1.5
	/// holder for the actual action when created.
	var/list/obj/effect/proc_holder/spell/path_sword_actions
	/// holder for the actual action when created.
	var/list/obj/effect/proc_holder/spell/path_wielder_actions
	var/mob/living/trapped_entity
	/// The heretic path that the variable below uses to index abilities. Assigned when the heretic is ensouled.
	var/heretic_path
	/// If the blade is bound, it cannot utilize its abilities, but neither can its wielder. They must unbind it to use it to its full potential.
	var/bound = TRUE
	/// Nested static list used to index abilities and names.
	var/static/list/heretic_paths_to_haunted_sword_abilities = list(
		// Ash
		PATH_ASH = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/ethereal_jaunt/ash),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/pointed/ash_beams),
			SWORD_PREFIX = "пепельный",
		),
		// Flesh
		PATH_FLESH = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/pointed/blood_siphon),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/pointed/cleave),
			SWORD_PREFIX = "сангвинический",
		),
		// Void
		PATH_VOID = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/pointed/void_phase),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/pointed/void_prison),
			SWORD_PREFIX = "мрачный",
		),
		// Blade
		PATH_BLADE = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/haunted),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/solo),
			SWORD_PREFIX = "острый",
		),
		// Rust
		PATH_RUST = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/cone/staggered/entropic_plume),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/aoe/rust_conversion, /obj/effect/proc_holder/spell/pointed/rust_construction),
			SWORD_PREFIX = "ржавый",
		),
		// Cosmic
		PATH_COSMIC = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/aoe/conjure/cosmic_expansion),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/pointed/projectile/star_blast),
			SWORD_PREFIX = "астральный",
		),
		// Lock
		PATH_LOCK = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/pointed/burglar_finesse),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/pointed/apetra_vulnera),
			SWORD_PREFIX = "острый",
		),
		// Moon
		PATH_MOON = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/pointed/projectile/moon_parade),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/pointed/moon_smile),
			SWORD_PREFIX = "сияющий",
		),
		// Starter
		PATH_START = list(
			WIELDER_SPELLS = null,
			SWORD_SPELLS = null,
			SWORD_PREFIX = "мертворожденный", // lol loser
		) ,
	)
	actions_types = list(/datum/action/item_action/haunted_blade)


/obj/item/melee/cultblade/haunted/get_ru_names()
	return list(
		NOMINATIVE = "призрачный меч",
		GENITIVE = "призрачного меча",
		DATIVE = "призрачному мечу",
		ACCUSATIVE = "призрачный меч",
		INSTRUMENTAL = "призрачным мечом",
		PREPOSITIONAL = "призрачнои мече",
	)


/obj/item/melee/cultblade/haunted/examine(mob/user)
	. = ..()

	var/examine_text = ""
	if(bound)
		examine_text = "[declent_ru(NOMINATIVE)] сияет тусклым, болезненно-зелёным светом. Исходящая от него сила явно связана рунами на клинке. Вы можете освободить его и овладеть его устрашающей мощью. Но стоит ли ослаблять оковы духа внутри?"
	else
		examine_text = "[declent_ru(NOMINATIVE)] сияет ярким зловещим бледно-лаймовым светом. Кто-то освободил дух внутри, и теперь сила, едва сдерживаемая и полная ярости, отчётливо резонирует внутри клинка. Вы можете снова запечатать его, или попытаться использовать его силу."

	. += span_cult(examine_text)


/datum/action/item_action/haunted_blade
	name = "Снять Печать" // img is of a chained shade
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "spirit_sealed"


/datum/action/item_action/haunted_blade/apply_button_icon(atom/movable/screen/movable/action_button/button, force)
	var/obj/item/melee/cultblade/haunted/blade = target
	if(!istype(blade))
		return ..()

	button_icon_state = "spirit_[blade.bound ? "sealed" : "unsealed"]"
	name = "[blade.bound ? "Свободная" : "Запечатанная"] Душа"
	return ..()


/obj/item/melee/cultblade/haunted/ui_action_click(mob/living/user, actiontype)
	//if(DOING_INTERACTION_WITH_TARGET(user, src))
	//	return // gtfo

	if(bound)
		unbind_blade(user)
		return

	if(user.mind?.isholy)
		on_priest_handle(user)

	else if(iscultist(user))
		on_cultist_handle(user)

	else if(IS_HERETIC_OR_MONSTER(user) || IS_LUNATIC(user))
		on_heresy_handle(user)

	else if(iswizard(user))
		on_wizard_handle(user)

	else
		on_normie_handle(user)


/obj/item/melee/cultblade/haunted/proc/on_priest_handle(mob/living/user, actiontype)
	user.visible_message(span_cultbold("Вы начинаете петь священные гимны в честь [SSticker.cultdat?.entity_name]..."),\
		span_cultbold("[user] начинает петь, держа [declent_ru(ACCUSATIVE)] над головой..."))

	if(!do_after(user, 6 SECONDS, src))
		to_chat(user, span_notice("Вас прервали!"))
		return

	playsound(user, 'sound/effects/pray_chaplain.ogg',60,TRUE)
	return TRUE


/obj/item/melee/cultblade/haunted/proc/on_cultist_handle(mob/living/carbon/human/user, actiontype)
	var/binding_implements = list(/obj/item/melee/cultblade/dagger, /obj/item/melee/sickly_blade/cursed)
	if(!user.is_holding_item_of_types(binding_implements))
		to_chat(user, span_notice("Вам нужно держать ритуальный кинжал, чтобы запечатать [declent_ru(ACCUSATIVE)]!"))
		return

	user.visible_message(span_cultbold("Вы начинаете надразрезать ладонь над [declent_ru(INSTRUMENTAL)]..."),\
		span_cultbold("[user] начинает надрезать свою ладонь над [declent_ru(INSTRUMENTAL)]..."))
	if(!do_after(user, 6 SECONDS, src))
		to_chat(user, span_notice("Вас прервали!"))
		return

	playsound(user, 'sound/weapons/slice.ogg', 30, TRUE)
	return TRUE


/obj/item/melee/cultblade/haunted/proc/on_heresy_handle(mob/living/carbon/human/user, actiontype)
	// todo make the former a subtype of latter
	var/binding_implements = list(/obj/item/clothing/neck/eldritch_amulet, /obj/item/clothing/neck/heretic_focus)
	if(!user.is_holding_item_of_types(binding_implements))
		to_chat(user, span_notice("Вам нужен амулет, чтобы запечатать [declent_ru(ACCUSATIVE)]!"))
		return

	user.visible_message(span_cultbold("Вы направляете силв Мансуса, усиливая запечатывающие руны..."), span_cultbold("[user.declent_ru(NOMINATIVE)] направляет сверхъестественную силу на [declent_ru(ACCUSATIVE)]..."))
	if(do_after(user, 6 SECONDS, src))
		return TRUE

	to_chat(user, span_notice("Вас прервали!"))


/obj/item/melee/cultblade/haunted/proc/on_wizard_handle(mob/living/user, actiontype)
	user.visible_message(span_cultbold("Вы начинаете быстро и ловко накладывать запечатывающие руны."), span_cultbold("[user] начинает чертить руны на [declent_ru(PREPOSITIONAL)]..."))
	if(do_after(user, 3 SECONDS, src))
		return TRUE

	to_chat(user, span_notice("Вас прервали!"))


/obj/item/melee/cultblade/haunted/proc/on_normie_handle(mob/living/carbon/human/user, actiontype)
	// todo make the former a subtype of latter
	var/binding_implements = list(/obj/item/storage/bible)
	if(!user.is_holding_item_of_types(binding_implements))
		to_chat(user, span_notice("Вам нужна Библия, чтобы запечатать [declent_ru(ACCUSATIVE)]!"))
		return

	var/passage = "[pick(GLOB.first_names_male)] [rand(1,9)]:[rand(1,25)]" // Space Bibles will have Alejandro 9:21 passages, as part of the Very New Testament.
	user.visible_message(span_cultbold("Вы начинаете читать вслух отрывок \"[passage]\"..."), span_cultbold("[user] начинает читать в слух отрывок \"[passage]\"..."))
	if(!do_after(user, 12 SECONDS, src))
		to_chat(user, span_notice("Вас прервали!"))
		return

	rebind_blade(user)


/obj/item/melee/cultblade/haunted/proc/unbind_blade(mob/user)
	var/holup = tgui_alert(user, "Вы уверены, что хотите освободить дух, заточённый внутри?", "Зло в банке", list("Мне нужна сила!", "А может и нет..."))
	if(holup != "Мне нужна сила!")
		return

	to_chat(user, span_cultbold("Вы начинаете концентрироваться на силе клинка, позволяя ему вести ваши пальцы по начертанным рунам..."))
	if(!do_after(user, 5 SECONDS, src))
		to_chat(user, span_notice("Вас прервали!"))
		return

	visible_message(span_danger("[user] освободил [declent_ru(ACCUSATIVE)]!"))
	bound = FALSE
	for(var/obj/effect/proc_holder/spell/sword_spell as anything in path_sword_actions)
		trapped_entity.mind.AddSpell(sword_spell)

	for(var/obj/effect/proc_holder/spell/wielder_spell as anything in path_wielder_actions)
		trapped_entity.mind.AddSpell(wielder_spell)

	free_use = TRUE
	force += 5
	armour_penetration += 10
	light_range += 3
	//trapped_entity.update_mob_action_buttons()

	playsound(src ,'sound/spookoween/insane_low_laugh.ogg', 200, TRUE) //quiet
	binding_filters_update()


/obj/item/melee/cultblade/haunted/proc/rebind_blade(mob/user)
	visible_message(span_danger("[user] запечатал [declent_ru(ACCUSATIVE)]!"))
	bound = TRUE
	force -= 5
	armour_penetration -= 10
	free_use = FALSE // it's a cult blade and you sealed away the other power.
	light_range -= 3
	for(var/obj/effect/proc_holder/spell/sword_spell as anything in path_sword_actions)
		user.mind.RemoveSpell(sword_spell)

	for(var/obj/effect/proc_holder/spell/wielder_spell as anything in path_wielder_actions)
		user.mind.RemoveSpell(wielder_spell)

	//trapped_entity.update_mob_action_buttons()

	playsound(src ,'sound/effects/wail.ogg', 20, TRUE)	// add BOUND alert and UNBOUND
	binding_filters_update()


/obj/item/melee/cultblade/haunted/Initialize(mapload, mob/soul_to_bind, mob/awakener, do_bind = TRUE)
	. = ..()

	AddElement(/datum/element/heretic_focus)
	//add_traits(list(TRAIT_CASTABLE_LOC, TRAIT_SPELLS_TRANSFER_TO_LOC), INNATE_TRAIT)
	if(do_bind && !mapload)
		bind_soul(soul_to_bind, awakener)

	binding_filters_update()
	addtimer(CALLBACK(src, PROC_REF(start_glow_loop)), rand(0.1 SECONDS, 1.9 SECONDS))


/obj/item/melee/cultblade/haunted/proc/bind_soul(mob/soul_to_bind, mob/awakener)

	var/datum/mind/trapped_mind = soul_to_bind?.mind

	if(!trapped_mind)
		return // Can't do anything further down the list

	if(trapped_mind)
		AddComponent(/datum/component/spirit_holding,\
			soul_to_bind = trapped_mind,\
			awakener = awakener,\
			allow_renaming = FALSE,\
			allow_channeling = FALSE,\
			allow_exorcism = FALSE,\
		)

	// Get the heretic's new body and antag datum.
	trapped_entity = trapped_mind?.current
	//trapped_entity.PossessByPlayer(trapped_mind?.key)
	var/datum/antagonist/heretic/heretic_holder = trapped_entity.mind?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_holder)
		stack_trace("[soul_to_bind] in but not a heretic on the heretic soul blade.")

	// Give the spirit a spell that lets them try to fly around.
	trapped_entity.AddSpell(new /obj/effect/proc_holder/spell/pointed/sword_fling(null, awakener))

	// Set the sword's path for spell selection.
	heretic_path = heretic_holder.heretic_path

	// Copy the objectives to keep for roundend, remove the datum as neither us nor the heretic need it anymore
	var/list/copied_objectives = heretic_holder.objectives.Copy()
	trapped_entity.mind.remove_antag_datum(/datum/antagonist/heretic)

	// Add the fallen antag datum, give them a heads-up of what's happening.
	var/datum/antagonist/soultrapped_heretic/bozo = new()
	bozo.objectives |= copied_objectives
	trapped_entity.mind.add_antag_datum(bozo)

	// Assigning the spells to give to the wielder and spirit.
	// Let them cast the given spell.
	ADD_TRAIT(trapped_entity, TRAIT_ALLOW_HERETIC_CASTING, INNATE_TRAIT)

	var/list/path_spells = heretic_paths_to_haunted_sword_abilities[heretic_path]

	var/list/wielder_spells = path_spells[WIELDER_SPELLS]
	var/list/sword_spells = path_spells[SWORD_SPELLS]

	name = "[path_spells[SWORD_PREFIX]] [name]"


	// Creating the path spells.
	// The sword is created bound - so we do not grant it the spells just yet, but we still create and store them.

	if(sword_spells)
		for(var/obj/effect/proc_holder/spell/sword_spell as anything in sword_spells)
			var/obj/effect/proc_holder/spell/instanced_spell = new sword_spell(trapped_entity)
			LAZYADD(path_sword_actions, instanced_spell)
			instanced_spell.overlay_icon_state = "bg_cult_border" // for flavor, and also helps distinguish

	if(!wielder_spells)
		binding_filters_update()
		return

	for(var/obj/effect/proc_holder/spell/wielder_spell as anything in wielder_spells)
		var/obj/effect/proc_holder/spell/instanced_spell = new wielder_spell(trapped_entity)
		LAZYADD(path_wielder_actions, instanced_spell)
		instanced_spell.overlay_icon_state = "bg_cult_border"


/obj/item/melee/cultblade/haunted/equipped(mob/user, slot, initial)
	. = ..()
	if((!(slot & ITEM_SLOT_HANDS)) || bound)
		return

	for(var/spell in path_wielder_actions)
		user.mind.AddSpell(spell)

	binding_filters_update()


/obj/item/melee/cultblade/haunted/dropped(mob/user, silent)
	. = ..()
	for(var/obj/effect/proc_holder/spell/wielder_spell in path_wielder_actions)
		user.mind.RemoveSpell(wielder_spell)

	binding_filters_update()


/obj/item/melee/cultblade/haunted/proc/binding_filters_update(mob/user)

	var/h_color = heretic_path ? GLOB.heretic_path_to_color[heretic_path] : "#FF00FF"

	// on bound
	if(bound)
		add_filter("bind_glow", 2, list("type" = "outline", "color" = h_color, "size" = 0.1))
		remove_filter("unbound_ray")
		update_filters()
		return

	// on unbound
	// we re-add this every time it's picked up or dropped
	remove_filter("unbound_ray")
	add_filter(name = "unbound_ray", priority = 1, params = list(
		type = "rays",
		size = 16,
		color = COLOR_HERETIC_GREEN, // the sickly green of the heretic leaking through
		density = 16,
	))
	// because otherwise the animations stack and it looks ridiculous
	var/ray_filter = get_filter("unbound_ray")
	animate(ray_filter, offset = 100, time = 2 MINUTES, loop = -1, flags = ANIMATION_PARALLEL) // Absurdly long animate so nobody notices it hitching when it loops
	animate(offset = 0, time = 2 MINUTES) // I sure hope duration of animate doesnt have any performance effect

	update_filters()


/obj/item/melee/cultblade/haunted/proc/start_glow_loop()
	var/filter = get_filter("bind_glow")
	if(!filter)
		return

	animate(filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
	animate(alpha = 40, time = 2.5 SECONDS)

#undef WIELDER_SPELLS
#undef SWORD_SPELLS
#undef SWORD_PREFIX

// List version of above proc
// Returns ret_item, which is either the successfully located item or null
/mob/living/carbon/human/proc/is_holding_item_of_types(list/typepaths)
	for(var/typepath in typepaths)
		var/ret_item = is_holding_item_of_type(typepath)
		return ret_item

//Checks if we're holding an item of type: typepath
/mob/living/carbon/human/proc/is_holding_item_of_type(typepath)
	for(var/obj/item/item in get_held_items())
		if(!istype(item, typepath))
			continue

		return item

	return FALSE

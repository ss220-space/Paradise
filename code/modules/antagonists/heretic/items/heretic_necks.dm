/obj/item/clothing/neck/heretic_focus
	name = "янтарный амулет"
	desc = "Янтарный кристалл, связанный с потусторонним миром. Если не смотреть на амулет, он начинает подрагивать."
	gender = MALE
	icon_state = "eldritch_necklace"
	resistance_flags = FIRE_PROOF


/obj/item/clothing/neck/heretic_focus/get_ru_names()
	return list(
		NOMINATIVE = "янтарный амулет",
		GENITIVE = "янтарного амулета",
		DATIVE = "янтарному амулету",
		ACCUSATIVE = "янтарный амулет",
		INSTRUMENTAL = "янтарным амулетом",
		PREPOSITIONAL = "янтарном амулете",
	)


/obj/item/clothing/neck/heretic_focus/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)


/obj/item/clothing/neck/heretic_focus/crimson_medallion
	name = "кровавый амулет"
	desc = "Кроваво-красное фокусирующее стекло, обеспечивающее связь с потусторонним миром и даже чем-то похуже. \
			Рубиновый глаз постоянно дёргается и смотрит во все стороны. Кажется, будто он беззвучно кричит..."
	icon_state = "crimson_medallion"
	/// The aura healing component. Used to delete it when taken off.
	var/datum/component/component
	/// If active or not, used to add and remove its cult and heretic buffs.
	var/active = FALSE


/obj/item/clothing/neck/heretic_focus/crimson_medallion/get_ru_names()
	return list(
		NOMINATIVE = "кровавый амулет",
		GENITIVE = "кровавого амулета",
		DATIVE = "кровавому амулету",
		ACCUSATIVE = "кровавый амулет",
		INSTRUMENTAL = "кровавым амулетом",
		PREPOSITIONAL = "кровавом амулете",
	)


/obj/item/clothing/neck/heretic_focus/crimson_medallion/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_NECK))
		return

	var/team_color = COLOR_ADMIN_PINK
	if(iscultist(user))
		//var/obj/effect/proc_holder/spell/cult/blood_magic/magic_holder = locate() in user.actions
		team_color = COLOR_CULT_RED
		//magic_holder.magic_enhanced = TRUE

	else if(IS_HERETIC_OR_MONSTER(user) && !active)
		for(var/obj/effect/proc_holder/spell/spell_action in user.actions)
			spell_action.base_cooldown *= 0.5
			active = TRUE

		team_color = COLOR_GREEN

	else
		team_color = pick(COLOR_CULT_RED, COLOR_GREEN)

	user.add_traits(list(TRAIT_MANSUS_TOUCHED/*, TRAIT_BLOODY_MESS*/), UID())
	to_chat(user, span_alert("Ваше сердцебиение приобретает странный, но успокаивающий нерегулярный ритм, \
							а кровь становится значительно менее вязкой, чем раньше. Вы не уверены, хорошо ли это."))
	component = user.AddComponent( \
		/datum/component/aura_healing, \
		range = 3, \
		brute_heal = 1, \
		burn_heal = 1, \
		blood_heal = 2, \
		suffocation_heal = 5, \
		simple_heal = 0.6, \
		requires_visibility = FALSE, \
		limit_to_trait = TRAIT_MANSUS_TOUCHED, \
		healing_color = team_color, \
	)


/obj/item/clothing/neck/heretic_focus/crimson_medallion/dropped(mob/living/user)
	. = ..()

	if(!istype(user))
		return

	if(HAS_TRAIT_FROM(user, TRAIT_MANSUS_TOUCHED, UID()))
		to_chat(user, span_notice("Ваши сердце и кровь возвращаются к своему обычному ритму и течению."))

	if(IS_HERETIC_OR_MONSTER(user) && active)
		for(var/obj/effect/proc_holder/spell/spell_action in user.actions)
			spell_action.base_cooldown *= 2
			active = FALSE

	QDEL_NULL(component)
	user.remove_traits(list(TRAIT_MANSUS_TOUCHED/*, TRAIT_BLOODY_MESS*/), UID())

	// If boosted enable is set, to prevent false dropped() calls from repeatedly nuking the max spells.
	//var/obj/effect/proc_holder/spell/cult/blood_magic/magic_holder = locate() in user.actions
	// Remove the last spell if over new limit, as we will reduce our max spell amount. Done beforehand as it causes a index out of bounds runtime otherwise.
	//if(magic_holder?.magic_enhanced)
	//	QDEL_NULL(magic_holder.spells[ENHANCED_BLOODCHARGE])

	//magic_holder?.magic_enhanced = FALSE


/obj/item/clothing/neck/heretic_focus/crimson_medallion/attack_self(mob/living/user, modifiers)
	. = ..()
	to_chat(user, span_danger("Вы сильно сжимаете [declent_ru(ACCUSATIVE)]..."))
	if(!do_after(user, 1.25 SECONDS, src))
		return

	to_chat(user, span_danger("[declent_ru(NOMINATIVE)] взрывается потоком крови, заливая вашу руку. Вы чувствуете, как кровь \
								просачивается вам под кожу. Ваше самочувствие резко улучшается, но вскоре возникает \
								ощущение пустоты, после которого вены начинают зудеть."))
	new /obj/effect/gibspawner/generic(get_turf(src))
	var/heal_amt = user.adjustBruteLoss(-50)
	user.adjustFireLoss( -(50 - abs(heal_amt)) ) // no double dipping

	// I want it to poison the user but I also think it'd be neat if they got their juice as well. But that cancels most of the damage out. So I dunno.
	user.reagents?.add_reagent(/datum/reagent/fuel/unholywater, rand(6, 10))
	user.reagents?.add_reagent(/datum/reagent/eldritch, rand(6, 10))
	qdel(src)


/obj/item/clothing/neck/heretic_focus/crimson_medallion/examine(mob/user)
	. = ..()

	var/magic_dude
	if(iscultist(user))
		. += span_cultbold("Этот амулет позволит вам хранить одно дополнительное заклинание и вдвое сократит \
							время подготовки заклинаний, а также обеспечит небольшой регенеративный эффект.")
		magic_dude = TRUE

	if(IS_HERETIC_OR_MONSTER(user))
		. += span_notice("Этот амулет вдвое сократит время перезарядки ваших заклинаний, \
						а также предоставит небольшой регенеративный эффект всем находящимся \
						поблизости еретикам и монстрам, включая вас.")
		magic_dude = TRUE

	if(!magic_dude)
		return

	. += span_red("Вы также можете сжать его, чтобы быстро восстановить большое количество здоровья, но за это придется заплатить...")


/obj/item/clothing/neck/eldritch_amulet
	name = "жуткий тёплый медальон"
	desc = "Странный медальон. Сквозь кристаллическую поверхность виден таинственный мир. \
			Вы видите своё бьющееся сердце среди тысяч других."
	gender = MALE
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eye_medalion"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// A secondary clothing trait only applied to heretics.
	var/heretic_only_trait = TRAIT_THERMAL_VISION


/obj/item/clothing/neck/eldritch_amulet/get_ru_names()
	return list(
		NOMINATIVE = "жуткий тёплый медальон",
		GENITIVE = "жуткого тёплого медальона",
		DATIVE = "жуткому тёплому медальону",
		ACCUSATIVE = "жуткий тёплый медальон",
		INSTRUMENTAL = "жутким тёплым медальоном",
		PREPOSITIONAL = "жутком тёплом медальоне",
	)


/obj/item/clothing/neck/eldritch_amulet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)


/obj/item/clothing/neck/eldritch_amulet/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_NECK))
		return

	if(!ishuman(user) || !IS_HERETIC_OR_MONSTER(user))
		return

	ADD_TRAIT(user, heretic_only_trait, "[CLOTHING_TRAIT]_[UID()]")
	user.update_sight()


/obj/item/clothing/neck/eldritch_amulet/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, heretic_only_trait, "[CLOTHING_TRAIT]_[UID()]")
	user.update_sight()


// The amulet conversion tool used by moon heretics
/obj/item/clothing/neck/heretic_focus/moon_amulet
	name = "амулет лунного света"
	desc = "Частица разума, души и луны. От простого взгляда на неё кружится голова. Вы слышите шепот полный смеха и радости."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "moon_amulette"
	// How much damage does this item do to the targets sanity?
	var/sanity_damage = 20


/obj/item/clothing/neck/heretic_focus/moon_amulet/get_ru_names()
	return list(
		NOMINATIVE = "амулет лунного света",
		GENITIVE = "амулета лунного света",
		DATIVE = "амулету лунного света",
		ACCUSATIVE = "амулет лунного света",
		INSTRUMENTAL = "амулетом лунного света",
		PREPOSITIONAL = "амулете лунного света",
	)


/obj/item/clothing/neck/heretic_focus/moon_amulet/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	var/mob/living/carbon/human/hit = target
	if(!IS_HERETIC_OR_MONSTER(user))
		user.balloon_alert(user, "луна наблюдает за вами")
		return

	if(hit.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND))
		return

	if(!hit.isInCrit())
		return

	user.balloon_alert(user, "[genderize_ru(target.gender, "он", "она", "оно", "они")] увид[pluralize_ru(target.gender, "ит", "ят")] правду!")
	hit.apply_status_effect(/datum/status_effect/moon_converted)
	//user.log_message("made [target] insane.", LOG_GAME)
	//hit.log_message("was driven insane by [user]")
	. = ..()

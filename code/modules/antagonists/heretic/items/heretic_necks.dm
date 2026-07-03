/obj/item/clothing/neck/heretic_focus
	name = "янтарный амулет"
	desc = "Янтарный кристалл, связанный с потусторонним миром. Если не смотреть на амулет, он начинает подрагивать."
	gender = MALE
	icon_state = "eldritch_necklace"
	resistance_flags = FIRE_PROOF


/obj/item/clothing/neck/heretic_focus/get_ru_names()
	return alist(
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
	return alist(
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

	//var/obj/effect/proc_holder/spell/cult/blood_magic/magic_holder = locate() in user.actions
	//if(magic_holder?.magic_enhanced)
	//	QDEL_NULL(magic_holder.spells[ENHANCED_BLOODCHARGE])


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
	return alist(
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


// An x-ray variant of the medallion (not granted by any knowledge; admin/loot curiosity).
/obj/item/clothing/neck/eldritch_amulet/piercing
	name = "жуткий пронзающий медальон"
	desc = "Странный медальон. Сквозь кристаллическую поверхность свет преломляется в новые, пугающие спектры. \
			Вы видите себя, отражённого в каскаде зеркал, искажённого до невозможных форм."
	heretic_only_trait = TRAIT_XRAY_VISION


/obj/item/clothing/neck/eldritch_amulet/piercing/get_ru_names()
	return alist(
		NOMINATIVE = "жуткий пронзающий медальон",
		GENITIVE = "жуткого пронзающего медальона",
		DATIVE = "жуткому пронзающему медальону",
		ACCUSATIVE = "жуткий пронзающий медальон",
		INSTRUMENTAL = "жутким пронзающим медальоном",
		PREPOSITIONAL = "жутком пронзающем медальоне",
	)


// A purely cosmetic lookalike medallion (no focus, no traits).
/obj/item/clothing/neck/fake_heretic_amulet
	name = "религиозная иконка"
	desc = "Странный медальон, из-за которого его носитель выглядит как член какого-то культа."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eye_medalion"


/obj/item/clothing/neck/fake_heretic_amulet/get_ru_names()
	return alist(
		NOMINATIVE = "религиозная иконка",
		GENITIVE = "религиозной иконки",
		DATIVE = "религиозной иконке",
		ACCUSATIVE = "религиозную иконку",
		INSTRUMENTAL = "религиозной иконкой",
		PREPOSITIONAL = "религиозной иконке",
	)


/obj/item/clothing/neck/heretic_focus/moon_amulet
	name = "амулет лунного света"
	desc = "Частица разума, души и луны. От простого взгляда на неё кружится голова. Вы слышите шепот полный смеха и радости."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "moon_amulette"
	/// How much damage does this item do to the targets sanity?
	var/sanity_damage = 20
	// Brain damage a non-heretic wearer must accrue from the curse before their mind shatters and they go
	// berserk (master220 has no sanity, so brain damage is the meter).
	var/conversion_threshold = 100
	// Once converted, the amulet can't just be flicked off - removing it takes a short channel (do_after).
	// These track that channel so the moon's grip can be wrestled off over a couple of seconds.
	var/removal_channel_time = 3 SECONDS
	/// TRUE while a removal channel is currently running (stops the channel from being started twice).
	var/being_removed = FALSE
	/// Set TRUE the instant a removal channel succeeds, so the very next unequip is allowed straight through.
	var/removal_authorized = FALSE
	// The off-screen laughter (laugh track) played when a moon blade strikes while this amulet is worn.
	var/static/list/possible_sounds = list(
		'sound/items/SitcomLaugh1.ogg',
		'sound/items/SitcomLaugh2.ogg',
		'sound/items/SitcomLaugh3.ogg',
	)


/obj/item/clothing/neck/heretic_focus/moon_amulet/get_ru_names()
	return alist(
		NOMINATIVE = "амулет лунного света",
		GENITIVE = "амулета лунного света",
		DATIVE = "амулету лунного света",
		ACCUSATIVE = "амулет лунного света",
		INSTRUMENTAL = "амулетом лунного света",
		PREPOSITIONAL = "амулете лунного света",
	)


/obj/item/clothing/neck/heretic_focus/moon_amulet/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!IS_HERETIC_OR_MONSTER(user))
		user.balloon_alert(user, "луна наблюдает за вами")
		return

	if(!ishuman(target))
		return ..()

	var/mob/living/carbon/human/hit = target
	// Heretics and their monsters are immune; so is anyone shrugging off mind magic.
	if(IS_HERETIC_OR_MONSTER(hit))
		return ..()
	if(hit.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND))
		user.balloon_alert(user, "разум сопротивляется!")
		return ..()

	// master220 has no sanity, so brain damage is the moon path's "madness meter": a mind already shattered
	// (or a body in crit) snaps and goes berserk; an intact mind is just driven a little madder (chat +
	// hallucination + brain damage) so you can finish softening it.
	var/madness = hit.get_organ_loss(INTERNAL_ORGAN_BRAIN)
	if(madness < 60 && !hit.isInCrit())
		to_chat(user, span_warning("Разум [hit.declent_ru(GENITIVE)] ещё слишком крепок, чтобы сломаться..."))
		to_chat(hit, span_userdanger("Я ВИЖУ СВЕТ, ЕГО НУЖНО ОСТАНОВИТЬ!"))
		hit.cause_hallucination(/datum/hallucination/delusion/preset/moon, "moonlight amulet")
		hit.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 20, 150)
		hit.emote(pick("giggle", "laugh"))
		return ..()

	// A mindshield keeps the mind anchored - it can't be flipped into a berserker.
	if(ismindshielded(hit))
		user.balloon_alert(user, "разум защищён имплантом!")
		to_chat(hit, span_warning("Что-то в вашей голове отражает вторжение Луны."))
		return ..()

	user.balloon_alert(user, "[genderize_ru(target.gender, "он", "она", "оно", "они")] увид[pluralize_ru(target.gender, "ит", "ят")] правду!")
	to_chat(user, span_purple("Вы обращаете [hit.declent_ru(ACCUSATIVE)] в безумного слугу Луны — теперь [genderize_ru(hit.gender, "он", "она", "оно", "они")] набросится на всех вокруг!"))
	hit.apply_status_effect(/datum/status_effect/moon_converted)
	log_game("[key_name(user)] drove [key_name(hit)] berserk with a moonlight amulet.")
	. = ..()


/obj/item/clothing/neck/heretic_focus/moon_amulet/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_NECK) || !ishuman(user))
		return
	if(IS_HERETIC_OR_MONSTER(user))
		// Heretic wearer: thermal vision lets you see heathens through walls and in the dark, and your moon
		// blade drops to 0 force so you can still swing it while the Resplendent Regalia pacifies you (its
		// damage comes from the eldritch blade effect, not physical force).
		ADD_TRAIT(user, TRAIT_THERMAL_VISION, "[CLOTHING_TRAIT]_[UID()]")
		user.update_sight()
		refresh_held_blades(user)
		// The amulet channels through the moon blade: a strike now carries off-screen laughter (a laugh
		// track) on top of the eldritch blade effect. We listen for the blade-attack signal to play it.
		RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_blade_laugh), override = TRUE)
		return
	// Non-heretic wearer: the amulet latches on and slowly devours the mind. It can still be removed right up
	// until the mind shatters, at which point the wearer goes berserk and is compelled to keep it on
	// (NODROP is applied then, in process()).
	to_chat(user, span_userdanger("Амулет холодит кожу, и далёкий хор смеха эхом отдаётся в вашей голове..."))
	START_PROCESSING(SSobj, src)


/obj/item/clothing/neck/heretic_focus/moon_amulet/dropped(mob/living/user)
	. = ..()
	if(!ishuman(user))
		return
	REMOVE_TRAIT(user, TRAIT_THERMAL_VISION, "[CLOTHING_TRAIT]_[UID()]")
	user.update_sight()
	UnregisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK)
	STOP_PROCESSING(SSobj, src)
	refresh_held_blades(user)
	// Tear down the removal-channel block and reset its state so a future wearer starts fresh (and isn't
	// gifted a free instant removal from a stale authorization).
	UnregisterSignal(src, COMSIG_ITEM_PRE_UNEQUIP)
	being_removed = FALSE
	removal_authorized = FALSE
	// Taking the amulet off (by any means - the removal channel, stripping, death, dismemberment) lifts the
	// moon's compulsion: the kill-everyone objective and berserk state are cleared.
	user.remove_status_effect(/datum/status_effect/moon_converted)


/// Plays the off-screen laughter when an eldritch blade lands while we're worn by a heretic. The amulet
/// channels through any sickly blade, so the moon blade qualifies as a subtype.
/obj/item/clothing/neck/heretic_focus/moon_amulet/proc/on_blade_laugh(mob/living/attacker, mob/living/victim, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER
	if(!istype(blade, /obj/item/melee/sickly_blade))
		return
	to_chat(attacker, span_purple(pick(
		"Вы рассекаете [victim.declent_ru(ACCUSATIVE)], раздваивая [genderize_ru(victim.gender, "его", "её", "его", "их")] отражение надвое.",
		"Клинок входит глубоко, освобождая [victim.declent_ru(ACCUSATIVE)] от лишних мыслей. Безупречно.",
		"Свет вспыхивает на лезвии, и [victim.declent_ru(NOMINATIVE)] на миг видит мир в иных, невозможных красках.",
	)))
	to_chat(victim, span_userdanger(pick(
		"Удар [attacker.declent_ru(GENITIVE)] вырывает из вас нечто большее, чем плоть.",
		"Лезвие вонзается, и вы теряете что-то глубоко внутри. Эта боль хуже любой раны.",
		"Мир на миг распадается на тысячу зеркал, и в каждом — чужой смех.",
	)))
	playsound(attacker, pick(possible_sounds), 40, TRUE)


/// Re-evaluates the force of any moon blades [user] is holding so wearing the amulet lets them swing while
/// pacified (force 0 bypasses the pacifism block) and restores it once the amulet comes off.
/obj/item/clothing/neck/heretic_focus/moon_amulet/proc/refresh_held_blades(mob/living/user)
	for(var/obj/item/melee/sickly_blade/moon/blade in user.get_held_items())
		blade.update_pacifism_force(user)


/// Non-heretic curse: grinds the wearer's brain down each tick; once shattered, they go berserk (a gradual
/// brain-damage curse since master220 has no sanity). The brain grind STOPS the moment they convert (PROCESS_KILL).
/obj/item/clothing/neck/heretic_focus/moon_amulet/process(seconds_per_tick)
	var/mob/living/carbon/human/wearer = loc
	if(!istype(wearer) || wearer.neck != src || wearer.stat == DEAD || IS_HERETIC_OR_MONSTER(wearer))
		return PROCESS_KILL
	if(wearer.has_status_effect(/datum/status_effect/moon_converted))
		return PROCESS_KILL
	wearer.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 4, 150)
	if(prob(25))
		wearer.cause_hallucination(/datum/hallucination/delusion/preset/moon, "moonlight amulet curse")
	if(prob(20))
		wearer.emote(pick("giggle", "laugh"))
	if(wearer.get_organ_loss(INTERNAL_ORGAN_BRAIN) < conversion_threshold)
		return
	// The mind shatters. They are bound to the moon: a kill-everyone objective and the compulsion to keep the
	// amulet on. The amulet can still be torn off, but no longer in an instant - it now resists removal, so
	// prying it loose takes a short channel (see on_pre_unequip). The brain damage ends here.
	to_chat(wearer, span_userdanger("ЛУНА ПОКАЗЫВАЕТ ВАМ ПРАВДУ — И НЕ ОТПУСКАЕТ! УБЕЙТЕ ВСЕХ ЛЖЕЦОВ!"))
	RegisterSignal(src, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(on_pre_unequip), override = TRUE)
	wearer.apply_status_effect(/datum/status_effect/moon_converted/permanent)
	return PROCESS_KILL


/// Once converted, the amulet clings on: the first attempt to take it off is blocked and instead opens a
/// short removal channel. Only when that channel finishes (removal_authorized) does an unequip go through.
/obj/item/clothing/neck/heretic_focus/moon_amulet/proc/on_pre_unequip(datum/source, force, atom/newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER
	// Forced removals (admin / gibbing / the channel's own authorized drop) pass straight through.
	if(force || removal_authorized)
		return
	if(!being_removed)
		var/mob/living/wearer = loc
		if(isliving(wearer))
			INVOKE_ASYNC(src, PROC_REF(channel_removal), wearer)
	return COMPONENT_ITEM_BLOCK_UNEQUIP


/// The "wrestle the amulet off" channel. On success the moon's grip breaks and the amulet comes off (its
/// dropped() then clears the conversion / objective); on failure nothing changes.
/obj/item/clothing/neck/heretic_focus/moon_amulet/proc/channel_removal(mob/living/wearer)
	being_removed = TRUE
	wearer.balloon_alert(wearer, "вы боретесь с амулетом...")
	wearer.visible_message(span_warning("[wearer.declent_ru(NOMINATIVE)] силится сорвать с себя [declent_ru(ACCUSATIVE)]!"))
	if(do_after(wearer, removal_channel_time, src))
		removal_authorized = TRUE
		wearer.drop_item_ground(src)
	being_removed = FALSE

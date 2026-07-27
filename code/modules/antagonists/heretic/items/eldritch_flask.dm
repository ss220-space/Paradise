/obj/item/reagent_containers/glass/beaker/eldritch
	name = "flask of eldritch essence"
	desc = "Токсичен для людей с ограниченным мышлением, но освежает тех, кто обладает знаниями о запредельном."
	gender = MALE
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldritch_flask"
	list_reagents = list(/datum/reagent/eldritch = 50)


/obj/item/reagent_containers/glass/beaker/eldritch/get_ru_names()
	return alist(
		NOMINATIVE = "флакон с жуткой эссенцией",
		GENITIVE = "флакона с жуткой эссенцией",
		DATIVE = "флакону с жуткой эссенцией",
		ACCUSATIVE = "флакон с жуткой эссенцией",
		INSTRUMENTAL = "флаконом с жуткой эссенцией",
		PREPOSITIONAL = "флаконе с жуткой эссенцией"
	)


/obj/item/reagent_containers/glass/phylactery
	name = "phylactery of damnation"
	desc = "Используется для кражи крови у будущих жертв. Крадёт кровь по правому клику, даже на расстоянии."
	gender = FEMALE
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "phylactery"
	base_icon_state = "phylactery"
	volume = 10
	/// Cooldown before you can steal blood again
	COOLDOWN_DECLARE(drain_cooldown)


/obj/item/reagent_containers/glass/phylactery/get_ru_names()
	return alist(
		NOMINATIVE = "проклятая филактерия",
		GENITIVE = "проклятой филактерии",
		DATIVE = "проклятой филактерии",
		ACCUSATIVE = "проклятую филактерию",
		INSTRUMENTAL = "проклятой филактерией",
		PREPOSITIONAL = "проклятой филактерии"
	)


/obj/item/reagent_containers/glass/phylactery/interact_with_atom_secondary(atom/target, mob/living/user, list/modifiers)
	if(!COOLDOWN_FINISHED(src, drain_cooldown))
		user.balloon_alert(user, "подождите!")
		return NONE

	if(!ishuman(target))
		return NONE

	user.changeNext_move(CLICK_CD_MELEE)
	var/mob/living/living_target = target
	if(living_target == user)
		return ITEM_INTERACT_BLOCKING

	if(reagents.total_volume >= reagents.maximum_volume)
		to_chat(user, span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] полон."))
		return ITEM_INTERACT_BLOCKING

	if(living_target.can_block_magic(MAGIC_RESISTANCE_HOLY))
		to_chat(user, span_warning("Вы не можете набрать крови у [living_target.declent_ru(GENITIVE)]!"))
		COOLDOWN_START(src, drain_cooldown, 5 SECONDS)
		to_chat(living_target, span_warning("Вы чувствуете, как некая сила пытается украсть вашу кровь, но что-то мешает ей!"))
		return ITEM_INTERACT_BLOCKING

	var/drawn_amount = min(reagents.maximum_volume - reagents.total_volume, 5)
	if(!living_target.transfer_blood_to(src, drawn_amount))
		to_chat(user, span_warning("У вас не получилось набрать крови у [living_target.declent_ru(GENITIVE)]!"))
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("Вы взяли образец крови у [living_target.declent_ru(GENITIVE)]."))
	to_chat(living_target, span_warning("Вы чувствуете лёгкий укол!"))
	COOLDOWN_START(src, drain_cooldown, 5 SECONDS)
	playsound(src, 'sound/effects/catalyst.ogg', 20, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_exponent = 10)
	return ITEM_INTERACT_SUCCESS


/obj/item/reagent_containers/glass/phylactery/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom_secondary(interacting_with, user, modifiers)


/obj/item/reagent_containers/glass/phylactery/on_reagent_change()
	. = ..()
	update_icon()


/obj/item/reagent_containers/glass/phylactery/update_icon_state()
	. = ..()
	switch(reagents.total_volume)
		if(0)
			icon_state = base_icon_state

		if(0.1 to 5)
			icon_state = base_icon_state + "_1"

		if(5.1 to 10)
			icon_state = base_icon_state + "_2"


/obj/item/ether
	name = "ether of the newborn"
	desc = "Флакон с густой, вызывающей тошноту зелёной жидкостью. Полностью восстанавливает организм, \
			а затем погружает вас в крепкий сон на целую минуту."
	gender = FEMALE
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "poison_flask"


/obj/item/ether/get_ru_names()
	return alist(
		NOMINATIVE = "душа нерождённого младенца",
		GENITIVE = "души нерождённого младенца",
		DATIVE = "душе нерождённого младенца",
		ACCUSATIVE = "душу нерождённого младенца",
		INSTRUMENTAL = "душой нерождённого младенца",
		PREPOSITIONAL = "душе нерождённого младенца"
	)


/obj/item/ether/attack_self(mob/living/user, modifiers)
	. = ..()
	user.revive()
	for(var/obj/item/implant/to_remove in user.contents)
		to_remove.removed(user)

	user.apply_status_effect(/datum/status_effect/eldritch_sleep)
	user.SetSleeping(60 SECONDS)
	qdel(src)


/datum/status_effect/eldritch_sleep
	id = "eldritch_sleep"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_sleep
	show_duration = TRUE
	/// List of traits our drinker gets while they are asleep
	var/list/sleeping_traits = list(TRAIT_NO_BREATH, TRAIT_RESIST_COLD, TRAIT_RESIST_COLD, TRAIT_RESIST_COLD, TRAIT_RESIST_HEAT)


/datum/status_effect/eldritch_sleep/on_apply()
	. = ..()
	owner.add_traits(sleeping_traits, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_STASIS, TRAIT_STATUS_EFFECT(id))


/datum/status_effect/eldritch_sleep/on_remove()
	owner.SetSleeping(0) // Wake up bookworm, we have some heathens to burn
	owner.remove_traits(sleeping_traits, TRAIT_STATUS_EFFECT(id))
	owner.reagents?.remove_all(100) // If someone gives you over 100 units of poison while you sleep then you deserve this L
	REMOVE_TRAIT(owner, TRAIT_STASIS, TRAIT_STATUS_EFFECT(id))


/atom/movable/screen/alert/status_effect/eldritch_sleep
	name = "Необъяснимый Сон"
	desc = "Вы чувствуете неописуемое тепло, укрывающее вас как одеяло..."
	icon = 'icons/mob/screen_alert_heretic.dmi'
	icon_state = "eldritch_slumber"


/datum/reagent/eldritch
	name = "Сущность Ужаса"
	id = "eldritch"
	description = "Странная жидкость, бросающая вызов законам физики. \
					Она исцеляет, но только тех, кто может видеть дальше границ этой хрупкой реальности. \
					Невероятно вредна для людей с ограниченным мышлением. Эта жидкость очень быстро метаболизируется."
	taste_description = "Ag'hsj'saje'sh"
	color = "#1f8016"
	metabolization_rate = 2.5 * REAGENTS_METABOLISM  //0.5u/second
	process_flags = ORGANIC | SYNTHETIC // Magical, so works on non-organic drinkers.

/datum/reagent/eldritch/on_mob_life(mob/living/carbon/drinker)
	. = ..()
	var/need_mob_update = FALSE
	if(IS_HERETIC_OR_MONSTER(drinker))
		drinker.AdjustImmobilized(-40 * REM) // master220: closest equivalent of tg's AdjustAllImmobility
		need_mob_update += drinker.adjustStaminaLoss(-10 * REM, updating_health = FALSE)
		need_mob_update += drinker.adjustToxLoss(-2 * REM, updating_health = FALSE, forced = TRUE)
		need_mob_update += drinker.adjustOxyLoss(-2 * REM, updating_health = FALSE)
		need_mob_update += drinker.adjustBruteLoss(-2 * REM, updating_health = FALSE)
		need_mob_update += drinker.adjustFireLoss(-2 * REM)
		if(drinker.blood_volume < BLOOD_VOLUME_NORMAL)
			drinker.blood_volume += 3 * REM
		return

	need_mob_update = drinker.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 3 * REM, 150)
	need_mob_update += drinker.adjustToxLoss(2 * REM, updating_health = FALSE)
	need_mob_update += drinker.adjustFireLoss(2 * REM, updating_health = FALSE)
	need_mob_update += drinker.adjustOxyLoss(2 * REM, updating_health = FALSE)
	need_mob_update += drinker.adjustBruteLoss(2 * REM)

/datum/reagent/eldritch/reaction_turf(turf/exposed_turf, reac_volume, color)
	. = ..()
	if(!(reac_volume >= 1.5 || isplatingturf(exposed_turf)) || HAS_TRAIT(exposed_turf, TRAIT_RUSTY))
		return
	exposed_turf.rust_turf()

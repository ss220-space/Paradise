// An unholy water flask, but for heretics.
// Heals heretics, harms non-heretics. Pretty much identical.
/obj/item/reagent_containers/glass/beaker/eldritch
	name = "флакон с жуткой эссенцией"
	desc = "Токсичен для людей с ограниченным мышлением, но освежает тех, кто обладает знаниями о запредельном."
	gender = MALE
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldritch_flask"
	list_reagents = list(/datum/reagent/eldritch = 50)


/obj/item/reagent_containers/glass/beaker/eldritch/get_ru_names()
	return list(
		NOMINATIVE = "флакон с жуткой эссенцией",
		GENITIVE = "флакона с жуткой эссенцией",
		DATIVE = "флакону с жуткой эссенцией",
		ACCUSATIVE = "флакон с жуткой эссенцией",
		INSTRUMENTAL = "флаконом с жуткой эссенцией",
		PREPOSITIONAL = "флаконе с жуткой эссенцией"
	)


// Unique bottle that lets you instantly draw blood from a victim
/obj/item/reagent_containers/glass/phylactery
	name = "проклятая филактерия"
	desc = "Используется для кражи крови у будущих жертв."
	gender = FEMALE
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "phylactery"
	base_icon_state = "phylactery"
	//has_variable_transfer_amount = FALSE
	//reagent_flags = OPENCONTAINER | DUNKABLE | TRANSPARENT
	volume = 10
	/// Cooldown before you can steal blood again
	COOLDOWN_DECLARE(drain_cooldown)


/obj/item/reagent_containers/glass/phylactery/get_ru_names()
	return list(
		NOMINATIVE = "проклятая филактерия",
		GENITIVE = "проклятой филактерии",
		DATIVE = "проклятой филактерии",
		ACCUSATIVE = "проклятую филактерию",
		INSTRUMENTAL = "проклятой филактерией",
		PREPOSITIONAL = "проклятой филактерии"
	)


/obj/item/reagent_containers/glass/phylactery/afterattack(obj/target, mob/user, proximity, params)
	if(!COOLDOWN_FINISHED(src, drain_cooldown))
		user.balloon_alert(user, "подождите!")
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!ishuman(target))
		return ..()

	var/mob/living/living_target = target
	if(reagents.total_volume >= reagents.maximum_volume)
		to_chat(user, span_notice("[declent_ru(NOMINATIVE)] полон."))
		return ATTACK_CHAIN_BLOCKED

	if(living_target == user)
		return ATTACK_CHAIN_BLOCKED

	if(living_target.can_block_magic(MAGIC_RESISTANCE_HOLY))
		to_chat(user, span_warning("Вы не можете набрать крови у [living_target.declent_ru(GENITIVE)]!"))
		COOLDOWN_START(src, drain_cooldown, 5 SECONDS)
		to_chat(living_target, span_warning("Вы чувствуете, как некая сила пытается украсть вашу кровь, но что-то мешает ей!"))
		return ATTACK_CHAIN_BLOCKED

	var/drawn_amount = min(reagents.maximum_volume - reagents.total_volume, 5)
	if(!living_target.transfer_blood_to(src, drawn_amount))
		to_chat(user, span_warning("У вас не получилось набрать крови у [living_target.declent_ru(GENITIVE)]!"))
		return ATTACK_CHAIN_SUCCESS

	to_chat(user, span_notice("Вы взяли образец крови у [living_target.declent_ru(GENITIVE)]."))
	to_chat(living_target, span_warning("Вы чувствуете лёгкий укол!"))
	COOLDOWN_START(src, drain_cooldown, 5 SECONDS)
	playsound(src, 'sound/effects/catalyst.ogg', 20, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_exponent = 10)
	return ATTACK_CHAIN_SUCCESS


/obj/item/reagent_containers/glass/phylactery/update_icon_state()
	. = ..()
	switch(reagents.total_volume)
		if(0)
			icon_state = base_icon_state

		if(0.1 to 5)
			icon_state = base_icon_state + "_1"

		if(5.1 to 10)
			icon_state = base_icon_state + "_2"


// Funny potion that is basically an aheal. The downside is that it puts you to sleep for a minute.
/obj/item/ether
	name = "душа нерожденного младенца"
	desc = "Флакон с тошнотворной, густой зелёной жидкостью. Полностью восстанавливает организм, \
			а затем погружает в крепкий сон на целую минуту."
	gender = FEMALE
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "poison_flask"


/obj/item/ether/get_ru_names()
	return list(
		NOMINATIVE = "душа нерожденного младенца",
		GENITIVE = "души нерожденного младенца",
		DATIVE = "душе нерожденного младенца",
		ACCUSATIVE = "душу нерожденного младенца",
		INSTRUMENTAL = "душой нерожденного младенца",
		PREPOSITIONAL = "душе нерожденного младенца"
	)


/obj/item/ether/attack_self(mob/living/user, modifiers)
	. = ..()
	user.rejuvenate()
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
	//show_duration = TRUE
	/// List of traits our drinker gets while they are asleep
	var/list/sleeping_traits = list(TRAIT_NO_BREATH, TRAIT_RESIST_COLD, TRAIT_RESIST_COLD, TRAIT_RESIST_COLD, TRAIT_RESIST_HEAT)


/datum/status_effect/eldritch_sleep/on_apply()
	. = ..()
	owner.add_traits(sleeping_traits, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_FAKEDEATH, HERETIC_TRAIT)
	owner.updatehealth("fakedeath")


/datum/status_effect/eldritch_sleep/on_remove()
	owner.SetSleeping(0) // Wake up bookworm, we have some heathens to burn
	owner.remove_traits(sleeping_traits, TRAIT_STATUS_EFFECT(id))
	owner.reagents?.remove_all(100) // If someone gives you over 100 units of poison while you sleep then you deserve this L
	REMOVE_TRAIT(owner, TRAIT_FAKEDEATH, HERETIC_TRAIT)
	owner.updatehealth("fakedeath")


/atom/movable/screen/alert/status_effect/eldritch_sleep
	name = "Жуткий сон"
	desc = "Вы чувствуете неописуемое тепло, защищающее вас..."
	icon_state = "eldritch_slumber"

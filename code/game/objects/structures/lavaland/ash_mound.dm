// ============================================================
// ПЕПЕЛЬНЫЙ ХОЛМИК
// ============================================================

/obj/structure/closet/ash_mound
	name = "пепельный холмик"
	desc = "Небольшая насыпь пепла. Кажется, под ней что-то зарыто."
	icon = 'icons/obj/lavaland/ash_mound.dmi'
	icon_state = "ash_mound"
	anchored = TRUE
	density = FALSE
	mob_storage_capacity = 1
	locked = TRUE
	breakout_time = 0

/obj/structure/closet/ash_mound/Initialize(mapload)
	. = ..()
	close()
	update_icon()

/obj/structure/closet/ash_mound/Destroy()
	for(var/mob/living/L in contents)
		remove_unbury_action(L)
	return ..()

/obj/structure/closet/ash_mound/examine(mob/user)
	. = ..()
	if(contents.len)
		. += "Из-под пепла что-то торчит."
	else
		. += "Внутри пусто."

/obj/structure/closet/ash_mound/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/shovel))
		start_excavation(user, W, tool_speed = 5 SECONDS)
		return TRUE
	if(istype(W, /obj/item/pickaxe))
		start_excavation(user, W, tool_speed = 7 SECONDS)
		return TRUE
	if(istype(W, /obj/item/kitchen/knife))
		start_excavation(user, W, tool_speed = 12 SECONDS, damage_chance = 5)
		return TRUE
	return ..()

/obj/structure/closet/ash_mound/attack_hand(mob/user, list/modifiers)
	if(!user.get_active_hand())
		start_excavation(user, null, tool_speed = 20 SECONDS, damage_chance = 10, self_damage = TRUE)
		return TRUE
	return ..()

/obj/structure/closet/ash_mound/proc/start_excavation(mob/user, obj/item/tool, tool_speed, damage_chance = 0, self_damage = FALSE)
	to_chat(user, span_notice("Вы начинаете раскапывать [src]..."))
	if(!do_after(user, tool_speed, target = src))
		return

	var/turf/T = get_turf(src)
	if(T.is_blocked_turf(exclude_mobs = TRUE))
		to_chat(user, span_warning("Место над холмиком занято, раскопать не получится."))
		return

	for(var/mob/living/L in contents)
		remove_unbury_action(L)

	if(damage_chance && prob(damage_chance))
		for(var/atom/movable/AM in contents)
			if(isliving(AM))
				to_chat(user, span_danger("Вы задели что-то живое внутри!"))
			else if(isobj(AM))
				var/obj/O = AM
				O.take_damage(5)
				to_chat(user, span_danger("Вы повредили [O] внутри!"))

	if(self_damage && prob(10))
		to_chat(user, span_danger("Вы поцарапали руки!"))

	for(var/atom/movable/AM in contents)
		AM.forceMove(T)

	T.visible_message(span_notice("[user] раскапывает [src], обнаруживая содержимое!"))
	qdel(src)

// ============================================================
// ФОРМИРУЮЩИЙСЯ ХОЛМИК (автоматическое погребение)
// ============================================================

/obj/structure/closet/ash_mound/forming
	name = "пепельный холмик"
	desc = "Пепел скапливается, образуя холмик. Кажется, что-то исчезает под ним."
	icon_state = "ash_mound_forming"					// нужен отдельный спрайт (пока можно использовать ash_mound)
	var/form_time = 20 SECONDS

/obj/structure/closet/ash_mound/forming/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(finish_forming)), form_time)

/obj/structure/closet/ash_mound/forming/proc/finish_forming()
	var/turf/T = get_turf(src)
	if(!T)
		return
	for(var/atom/movable/AM in T.contents)
		if(AM == src)
			continue
		if(isliving(AM))
			var/mob/living/L = AM
			if(L.stat >= UNCONSCIOUS)
				L.forceMove(src)
		else if(isitem(AM) || istype(AM, /obj/structure))
			if(can_bury_structure(AM))
				AM.forceMove(src)
	icon_state = "ash_mound"
	name = initial(name)
	desc = initial(desc)

// ============================================================
// КНОПКА «ВЫБРАТЬСЯ ИЗ ПЕПЛА»
// ============================================================

/obj/structure/closet/ash_mound/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	if(isliving(AM))
		var/mob/living/L = AM
		if(L.client)
			if(!locate(/datum/action/innate/ash_unbury) in L.actions)
				var/datum/action/innate/ash_unbury/A = new()
				A.Grant(L)

/datum/action/innate/ash_unbury
	name = "Выбраться из пепла"
	desc = "Попытаться выбраться наружу."
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "unbury"
	var/time_to_exit = 15 SECONDS

/datum/action/innate/ash_unbury/Trigger(trigger_flags)
	var/mob/living/user = owner
	var/obj/structure/closet/ash_mound/mound = user.loc
	if(!istype(mound))
		Remove(user)
		return
	to_chat(user, span_notice("Вы начинаете выкарабкиваться из пепла..."))
	if(!do_after(user, time_to_exit, target = mound))
		return
	if(user.loc != mound)
		return
	var/turf/T = get_turf(mound)
	user.forceMove(T)
	T.visible_message(span_warning("[user] выбирается из пепельного холмика!"))
	qdel(mound)
	Remove(user)

// ============================================================
// ВСПОМОГАТЕЛЬНЫЕ ПРОЦЕДУРЫ
// ============================================================

/proc/add_unbury_action(mob/living/L)
	if(!L.client)
		return
	if(!locate(/datum/action/innate/ash_unbury) in L.actions)
		var/datum/action/innate/ash_unbury/A = new()
		A.Grant(L)

/proc/remove_unbury_action(mob/living/L)
	if(!L.client)
		return
	var/datum/action/innate/ash_unbury/A = locate(/datum/action/innate/ash_unbury) in L.actions
	if(A)
		A.Remove(L)

// Можно ли закопать предмет или структуру (не заякоренную, не крупную)
/proc/can_bury_structure(atom/movable/AM)
	if(isitem(AM))
		var/obj/item/I = AM
		return !I.anchored
	if(istype(AM, /obj/structure))
		var/obj/structure/S = AM
		if(S.anchored)
			return FALSE
		if(istype(S, /obj/structure/window))
			return FALSE
		if(istype(S, /obj/structure/grille))
			return FALSE
		if(istype(S, /obj/structure/table))
			return FALSE
		if(istype(S, /obj/structure/rack))
			return FALSE
		if(istype(S, /obj/structure/closet/ash_mound))
			return FALSE
		return TRUE
	return FALSE

// Закапывание моба (себя) + всё незакреплённое и бессознательное на тайле
/proc/bury_mob(mob/living/target, mob/user, time_to_bury)
	var/turf/T = get_turf(target)
	if(!istype(T, /turf/simulated/floor/plating/asteroid))
		to_chat(user, span_warning("Здесь неподходящая поверхность для закапывания."))
		return
	if(locate(/obj/structure/closet/ash_mound) in T)
		to_chat(user, span_warning("Здесь уже есть пепельный холмик."))
		return
	to_chat(user, span_notice("Вы начинаете закапываться в пепел..."))
	if(!do_after(user, time_to_bury, target = target))
		return
	if(get_turf(target) != T)
		return
	var/obj/structure/closet/ash_mound/mound = new(T)
	for(var/atom/movable/AM in T.contents)
		if(AM == mound)
			continue
		if(isliving(AM))
			var/mob/living/L = AM
			if(L.stat >= UNCONSCIOUS)
				L.forceMove(mound)
		else if(isitem(AM) || istype(AM, /obj/structure))
			if(can_bury_structure(AM))
				AM.forceMove(mound)
	target.forceMove(mound)
	T.visible_message(span_warning("[target] зарывается в пепел, и всё вокруг исчезает под холмиком."))
	add_unbury_action(target)

// Закапывание одного предмета/структуры (без захвата мобов)
/proc/bury_thing(atom/movable/AM, mob/user, time_to_bury)
	var/turf/T = get_turf(AM)
	if(!istype(T, /turf/simulated/floor/plating/asteroid))
		to_chat(user, span_warning("Здесь неподходящая поверхность для закапывания."))
		return
	if(locate(/obj/structure/closet/ash_mound) in T)
		to_chat(user, span_warning("Здесь уже есть пепельный холмик."))
		return
	to_chat(user, span_notice("Вы начинаете закапывать [AM]..."))
	if(!do_after(user, time_to_bury, target = AM))
		return
	if(get_turf(AM) != T)
		return
	var/obj/structure/closet/ash_mound/mound = new(T)
	for(var/atom/movable/thing in T.contents)
		if(thing == mound)
			continue
		if(isitem(thing) || istype(thing, /obj/structure))
			if(can_bury_structure(thing))
				thing.forceMove(mound)
	T.visible_message(span_warning("[user] закапывает [AM], и всё вокруг исчезает под холмиком."))

// ============================================================
// БЛОКИРОВКА ОТКРЫТИЯ ЯЩИКОВ НА GRAB (закапывание)
// ============================================================

/obj/structure/closet/attackby(obj/item/W, mob/user, params)
	if(user.a_intent == INTENT_GRAB && (istype(W, /obj/item/shovel) || istype(W, /obj/item/pickaxe)))
		if(istype(loc, /turf/simulated/floor/plating/asteroid))
			if(can_bury_structure(src))
				bury_thing(src, user, 20 SECONDS)
				return TRUE
	return ..()

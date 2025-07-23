/obj/vehicle/ridden/wheelchair
	name = "wheelchair"
	desc = "Коляска для людей с ограниченными физическими возможностями. Почему просто не пришить новые ноги?"
	ru_names = list(
		NOMINATIVE = "инвалидная коляска",
		GENITIVE = "инвалидной коляски",
		DATIVE = "инвалидной коляске",
		ACCUSATIVE = "инвалидную коляску",
		INSTRUMENTAL = "инвалидной коляской",
		PREPOSITIONAL = "инвалидной коляске"
	)
	icon = 'icons/obj/chairs.dmi'
	icon_state = "wheelchair"
	base_icon_state = "wheelchair"
	/// Overlay used to overlap buckled mob.
	var/mutable_appearance/chair_overlay
	/// Currently applied skin, it contains path, not an instance.
	var/obj/item/fluff/rapid_wheelchair_kit/applied_skin
	var/decon_amount = 10
	var/material_type = /obj/item/stack/sheet/metal
	var/decon_speed = 3
	var/kit_applied = FALSE
	var/exists_bell = FALSE
	var/detonation_delay = FALSE
	var/obj/item/grenade/bomb = null
	var/datum/action/innate/wheelchair/bell/bell_action

/obj/vehicle/ridden/wheelchair/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/wheelchair)
	chair_overlay = mutable_appearance(icon, "wheelchair_overlay", ABOVE_MOB_LAYER)
	update_icon(UPDATE_OVERLAYS)
	bell_action = new /datum/action/innate/wheelchair/bell(callback = CALLBACK(src, PROC_REF(on_bell_action)))

/obj/vehicle/ridden/wheelchair/Destroy()
	chair_overlay = null
	applied_skin = null
	QDEL_NULL(bell_action)
	return ..()

/obj/vehicle/ridden/wheelchair/proc/on_skin_apply(obj/item/fluff/rapid_wheelchair_kit/kit, mob/user)
	if(applied_skin && applied_skin == kit.type)
		to_chat(user, span_warning("Эта [declent_ru(NOMINATIVE)] уже модифицирована!"))
		return

	to_chat(user, span_notice("Вы начинаете модифицировать [declent_ru(ACCUSATIVE)]..."))
	if(!do_after(user, 2 SECONDS, src))
		return

	applied_skin = kit.type
	chair_overlay = mutable_appearance(icon, kit.new_overlay, ABOVE_MOB_LAYER)
	update_appearance()
	qdel(kit)

/obj/vehicle/ridden/wheelchair/screwdriver_act(mob/user, obj/item/I)
	if(!bomb)
		return
	if(decon_speed)
		user.visible_message(
			span_notice("[user] начина[pluralize_ru(user.gender,"ет","ют")] откручивать [bomb.declent_ru(ACCUSATIVE)] при помощи [I.declent_ru(INSTRUMENTAL)]..."),
			span_notice("Вы начинаете откреплять [bomb.declent_ru(ACCUSATIVE)] при помощи [I.declent_ru(INSTRUMENTAL)]..."),
			span_warning("Слышны звуки работы с инструментом.")
		)
	if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume))
		return
	bomb.item_flags &= ~IN_STORAGE
	user.put_in_any_hand_if_possible(bomb)
	bomb = null
	user.balloon_alert(user, "успешно разобрано")

/obj/vehicle/ridden/wheelchair/wrench_act(mob/user, obj/item/I)
	if(decon_speed)
		TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume))
		return

	var/obj/item/stack/sheet/G = new material_type(loc, decon_amount)
	G.add_fingerprint(user)
	if(bomb)
		bomb.forceMove(loc)
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	user.balloon_alert(user, "успешно разобрано")
	deconstruct()

/obj/vehicle/ridden/wheelchair/update_icon_state()
	icon_state = applied_skin ? initial(applied_skin.new_icon_state) : base_icon_state


/obj/vehicle/ridden/wheelchair/update_overlays()
	. = ..()
	. += chair_overlay


/obj/vehicle/ridden/wheelchair/update_name(updates = ALL)
	. = ..()
	name = applied_skin ? initial(applied_skin.new_name) : initial(name)


/obj/vehicle/ridden/wheelchair/update_desc(updates = ALL)
	. = ..()
	desc = applied_skin ? initial(applied_skin.new_desc) : initial(desc)
	if (exists_bell)
		desc += " К подлокотнику зачем-то прикреплён звонок."
	if (bomb)
		desc += " Под сиденьем что-то есть."


///Modify logic

/obj/vehicle/ridden/wheelchair/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/desk_bell))
		desk_bell_act(item, user, params)
		return ATTACK_CHAIN_PROCEED
	if(isgrenade(item))
		grenade_act(item, user, params)
		return ATTACK_CHAIN_BLOCKED | ATTACK_CHAIN_NO_AFTERATTACK
	. = ..()
	return

/obj/vehicle/ridden/wheelchair/proc/desk_bell_act(obj/item/item, mob/user, params)
	if(exists_bell)
		return
	to_chat(user, span_notice("Вы начинаете прикреплять [item.declent_ru(ACCUSATIVE)] к [declent_ru(PREPOSITIONAL)]..."))
	if (!do_after(user, 2 SECONDS, src))
		return
	user.balloon_alert(user, "прикреплено")
	exists_bell = TRUE
	update_desc()
	qdel(item)

/obj/vehicle/ridden/wheelchair/proc/grenade_act(obj/item/item, mob/user, params)
	if(bomb)
		return
	to_chat(user, span_notice("Вы начинаете прикреплять [item.declent_ru(ACCUSATIVE)] к [declent_ru(PREPOSITIONAL)]..."))
	if (!do_after(user, 2 SECONDS, src))
		return
	if (!user.drop_item_ground(item))
		return
	bomb = item
	item.do_pickup_animation(src)
	item.forceMove(src)
	item.item_flags |= IN_STORAGE
	if (clown_check(user))
		user.balloon_alert(user, "прикреплено")
	update_desc()

/obj/vehicle/ridden/wheelchair/proc/clown_check(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, span_warning("А какой провод надо прикрепить к звонку?"))
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		addtimer(CALLBACK(src, PROC_REF(delayed_boom)), 0.5 SECONDS)
		return FALSE
	return TRUE

/obj/vehicle/ridden/wheelchair/proc/delayed_boom()
	bomb.prime()


///Buckle logic

/obj/vehicle/ridden/wheelchair/post_buckle_mob(mob/living/user)
	if (exists_bell)
		bell_action.Grant(user)
	return ..()

/obj/vehicle/ridden/wheelchair/post_unbuckle_mob(mob/living/user)
	if (exists_bell)
		bell_action.Remove(user)
	return ..()


///Bell logic

/obj/vehicle/ridden/wheelchair/proc/on_bell_action()
	if(!bomb)
		bell_sound()
		return
	if(detonation_delay)
		bell_sound()
		return
	detonation_delay = TRUE
	for(var/i = 0; i < 5; i++)
		addtimer(CALLBACK(src, PROC_REF(bell_sound)), (0.25 * i) SECONDS)
	addtimer(CALLBACK(src, PROC_REF(detonate_bomb)), 2 SECONDS)


/obj/vehicle/ridden/wheelchair/proc/bell_sound()
	playsound(src, "sound/machines/bell.ogg", 70, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

/obj/vehicle/ridden/wheelchair/proc/detonate_bomb()
	bomb.prime()
	if(QDELETED(bomb)) //If bomb deleted after detonation
		bomb = null
	//Else multiple time detonation bomb, safe it
	detonation_delay = FALSE


///Action

/datum/action/innate/wheelchair
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	var/datum/callback/bell_action

/datum/action/innate/wheelchair/New(Target, datum/callback/callback)
	. = ..()
	bell_action = callback


/datum/action/innate/wheelchair/Destroy()
	QDEL_NULL(bell_action)
	return ..()

/datum/action/innate/wheelchair/Activate()
	bell_action.Invoke()

/datum/action/innate/wheelchair/bell
	icon_icon = 'icons/obj/bureaucracy.dmi'
	button_icon_state = "desk_bell"
	name = "Звонок"


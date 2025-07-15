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
	///Actions
	var/datum/action/innate/wheelchair/bell_action = new

/obj/vehicle/ridden/wheelchair/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/wheelchair)
	chair_overlay = mutable_appearance(icon, "wheelchair_overlay", ABOVE_MOB_LAYER)
	update_icon(UPDATE_OVERLAYS)

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

/obj/vehicle/ridden/wheelchair/wrench_act(mob/user, obj/item/I)
	if(decon_speed)
		TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume))
		return

	var/obj/item/stack/sheet/G = new material_type(loc, decon_amount)
	G.add_fingerprint(user)
	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
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

/obj/vehicle/ridden/wheelchair/attackby(obj/item/item, mob/user, params)
	if(!istype(item, /obj/item/desk_bell))
		. = ..()
		return
	if(exists_bell)
		return ATTACK_CHAIN_PROCEED
	to_chat(user, span_notice("Вы начинаете прикреплять [item.declent_ru(ACCUSATIVE)] к [declent_ru(PREPOSITIONAL)]..."))
	if (!do_after(user, 2 SECONDS, src))
		return ATTACK_CHAIN_PROCEED
	user.balloon_alert(user, "прикреплено")
	exists_bell = TRUE
	update_desc()
	qdel(item)
	return ATTACK_CHAIN_PROCEED

/obj/vehicle/ridden/wheelchair/post_unbuckle_mob(mob/living/user)
	if (exists_bell)
		bell_action.Remove(user)
	return ..()

/obj/vehicle/ridden/wheelchair/post_buckle_mob(mob/living/user)
	if (exists_bell)
		bell_action.Grant(user, src)
	return ..()

/datum/action/innate/wheelchair
	name = "Звонок"
	icon_icon = 'icons/obj/bureaucracy.dmi'
	button_icon_state = "desk_bell"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	var/obj/vehicle/ridden/wheelchair/wheelchair

/datum/action/innate/wheelchair/Grant(mob/living/L, obj/vehicle/ridden/wheelchair/W)
	if(W)
		wheelchair = W
	. = ..()

/datum/action/innate/wheelchair/Destroy()
	wheelchair = null
	return ..()

/datum/action/innate/wheelchair/Activate()
	playsound(wheelchair, "sound/machines/bell.ogg", 70, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

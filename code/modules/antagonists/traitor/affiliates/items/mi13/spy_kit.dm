/obj/machinery/camera/emp_proof/mi13
	network = list("MI13")
	use_power = NO_POWER_USE

/obj/item/spy_bug
	name = "spy bug"
	desc = "Миниатюрное устройство с камерой и микрофоном. На обратной стороне можно заметить миниатюрную гравировку \"MI13\""
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "spy_bug"
	item_state = "nothing"
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_EARS
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=30, MAT_GLASS=20)
	var/list/network = list("MI13")
	var/c_tag
	var/obj/machinery/camera/emp_proof/mi13/camera

/obj/item/spy_bug/Initialize(mapload, list/network = list("MI13"), c_tag)
	. = ..()
	src.network = network
	if(!c_tag)
		src.c_tag = pick("Альфа ", "Бета ", "Гамма ", "Дельта ") + " [rand(111111, 999999)]"
	else
		src.c_tag = c_tag

	name = "spy bug \"" + src.c_tag + "\""
	camera = new(src, network, src.c_tag)

/obj/item/spy_bug/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim)
	return ATTACK_CHAIN_BLOCKED

/obj/item/spy_bug/afterattack(atom/target, mob/user, proximity, params, status)
	. = ..()

	if(!ismovable(target))
		return

	if(istype(target, /obj/item/camera_bug/spy_monitor))
		var/obj/item/camera_bug/spy_monitor/monitor = target
		network = monitor.network
		user.balloon_alert(user, "Подключено")
		return

	hook(user, target)

/obj/item/spy_bug/proc/unhook(mob/user)
	qdel(loc.GetComponent(/datum/component/spy_bug))
	forceMove(get_turf(loc))

	if(user)
		to_chat(user, span_notice("You unhooked [src]."))
	else
		loc.visible_message(span_warning("[src] falls off the [loc]."))

/obj/item/spy_bug/proc/hook(mob/user, atom/movable/I)
	if(!istype(I))
		return

	if(!user.drop_transfer_item_to_loc(src, I))
		return

	I.AddComponent(/datum/component/spy_bug)
	to_chat(user, span_notice("You have silently attached [src] on [I]."))

/obj/item/spy_bug/strip_action(mob/user, mob/living/carbon/human/owner, atom/I)
	if(!I)
		return FALSE

	hook(user, I)
	return TRUE

/obj/item/spy_bug/emp_act(severity)
	. = ..()
	do_sparks(3, TRUE, src.loc)
	unhook()

/obj/item/spy_bug/attack_self(mob/user)
	. = ..()
	var/new_name = tgui_input_text(user, "Назовите жучок.", "Смена имени", name)
	if(new_name)
		name = "spy bug \"" + new_name + "\""
		qdel(camera)
		c_tag = new_name
		camera = new(src, network, c_tag)

/datum/component/spy_bug
	var/obj/item/spy_bug/bug

/datum/component/spy_bug/RegisterWithParent()
	var/atom/par = parent
	for (var/obj/item/spy_bug/spy_bug in par.contents)
		bug = spy_bug

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(on_altclick))
	RegisterSignal(parent, COMSIG_PREQDELETED, PROC_REF(deleted_handler))

/datum/component/spy_bug/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(parent, COMSIG_CLICK_ALT)
	UnregisterSignal(parent, COMSIG_PREQDELETED)

/datum/component/spy_bug/proc/on_examine(datum/source, mob/living/carbon/human/user, list/examine_list)
	SIGNAL_HANDLER

	if(!istype(user))
		return

	examine_list += span_warning("Вы видите небольшое устройство с микрофоном и камерой.")

/datum/component/spy_bug/proc/on_altclick(mob/living/carbon/human/user)
	SIGNAL_HANDLER

	if(!istype(user))
		return

	if (!user.Adjacent(parent))
		return

	if (user.stat)
		return

	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	bug.unhook(user)

/datum/component/spy_bug/proc/deleted_handler()
	bug.unhook()

/obj/item/camera_bug/spy_monitor
	name = "spy monitor"
	desc = ""
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "spy_monitor"
	item_state	= "qm_tablet"
	integrated_console_type = /obj/machinery/computer/security/camera_bug
	network = list("MI13")

/obj/item/camera_bug/spy_monitor/Initialize(mapload, list/network)
	if(network)
		src.network = network

	. = ..()

/obj/item/storage/box/syndie_kit/spy_bugs_kit

/obj/item/storage/box/syndie_kit/spy_bugs_kit/populate_contents()
	var/network = "MI13_[rand(111111, 999999)]"
	new /obj/item/camera_bug/spy_monitor(src, list(network))
	for(var/i = 1; i <= 5; ++i)
		new /obj/item/spy_bug(src, list(network), "[i]")

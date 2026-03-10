// This item just has an integrated camera console, which the data is "proxied" to
/obj/item/camera_bug
	name = "camera bug"
	desc = "Для незаконного слежения через сеть камер наблюдения."
	gender = MALE
	icon = 'icons/obj/device.dmi'
	icon_state = "camera_bug"
	w_class = WEIGHT_CLASS_TINY
	item_state = "camera_bug"
	throw_speed = 4
	throw_range	= 20
	origin_tech = "syndicate=1;engineering=3"
	var/obj/machinery/computer/security/camera_bug/integrated_console

/obj/item/camera_bug/get_ru_names()
	return list(
		NOMINATIVE = "переносной монитор",
		GENITIVE = "переносного монитора",
		DATIVE = "переносному монитору",
		ACCUSATIVE = "переносной монитор",
		INSTRUMENTAL = "переносным монитором",
		PREPOSITIONAL = "переносном мониторе",
	)

/obj/machinery/computer/security/camera_bug
	name = "invasive camera utility"
	desc = "Как это сюда попало?! Пожалуйста, сообщите об этом как об ошибке на github."
	use_power = NO_POWER_USE

/obj/item/camera_bug/Initialize(mapload)
	. = ..()
	integrated_console = new(src)
	integrated_console.parent = src
	integrated_console.network = list("SS13")

/obj/item/camera_bug/Destroy()
	integrated_console.parent = null
	QDEL_NULL(integrated_console)
	return ..()

/obj/item/camera_bug/attack_self(mob/user as mob)
	ui_interact(user)

/obj/item/camera_bug/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/camera_bug/ui_interact(mob/user, datum/tgui/ui = null)
	integrated_console.ui_interact(user, ui)

/obj/item/camera_bug/ert
	name = "ERT Camera Monitor"
	desc = "Небольшое портативное устройство, используемое командирами ОБР для удаленного наблюдения."

/obj/item/camera_bug/ert/Initialize(mapload)
	. = ..()
	integrated_console.network = list("ERT")
////////////////////////////////////
// 		MARK: Syndicate Advanced Bug
////////////////////////////////////
/obj/item/camera_bug/syndicate
	name = "camera bug"
	desc = "Продвинутая версия жучка с модулем прямого нейронного интерфейса. Позволяет."
	var/obj/machinery/computer/camera_advanced/portable/advanced_console
	var/is_eye_active = FALSE

/obj/item/camera_bug/syndicate/Initialize(mapload)
	. = ..()
	advanced_console = new(src)
	advanced_console.parent_item = src
	advanced_console.networks = list("SS13")

	START_PROCESSING(SSobj, src)

/obj/item/camera_bug/syndicate/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(advanced_console)
	return ..()

/obj/item/camera_bug/syndicate/process()
	if(!advanced_console || !advanced_console.current_user)
		return

	var/mob/living/living_user = advanced_console.current_user
	if(!(src in living_user.contents) || living_user.incapacitated() || living_user.stat != CONSCIOUS)
		advanced_console.remove_eye_control(living_user)

/obj/machinery/computer/security/camera_bug/ui_data(mob/user)
	var/list/data = ..()

	if(istype(parent, /obj/item/camera_bug/syndicate))
		data["is_portable"] = TRUE

	return data

/obj/machinery/computer/security/camera_bug/ui_act(action, params)
	if(..())
		return TRUE

	if(action == "toggle_advanced")
		if(!istype(parent, /obj/item/camera_bug/syndicate))
			return FALSE

		var/obj/item/camera_bug/syndicate/cam_bug = parent

		if(cam_bug && isliving(usr))
			var/datum/tgui/ui = SStgui.get_open_ui(usr, src)
			if(ui)
				ui.close()

			usr.unset_machine()
			cam_bug.advanced_console.attack_hand(usr)

		return TRUE

/obj/machinery/computer/camera_advanced/portable
	name = "portable advanced camera link"
	use_power = NO_POWER_USE
	var/obj/item/camera_bug/syndicate/parent_item

/obj/machinery/computer/camera_advanced/portable/check_eye(mob/user)
	if(!parent_item || !(parent_item in user.contents) || user.incapacitated() || user.stat != CONSCIOUS)
		user.unset_machine()
		return

/obj/machinery/computer/camera_advanced/portable/on_unset_machine(mob/M)
	..()

	if(parent_item && !QDELETED(parent_item) && M && M.stat == CONSCIOUS)
		parent_item.ui_interact(M)

/obj/machinery/computer/camera_advanced/portable/attack_hand(mob/user)
	if(current_user || !iscarbon(user))
		return

	user.set_machine(src)

	if(!eyeobj)
		CreateEye()

	eyeobj.eye_initialized = TRUE
	give_eye_control(user)
	eyeobj.setLoc(get_turf(user))

	for(var/atom/movable/screen/plane_master/master_plane in user.hud_used?.get_true_plane_masters(CAMERA_STATIC_PLANE))
		master_plane.unhide_plane(user)

/obj/machinery/computer/security/camera_bug/ui_host()
	return parent ? parent : src

/obj/machinery/computer/camera_advanced/portable/ui_host()
	return parent_item ? parent_item : src

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
	/// Integrated camera console to serve UI data
	var/obj/machinery/computer/security/camera_bug/integrated_console

/obj/item/camera_bug/get_ru_names()
	return alist(
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

// 		MARK: Syndicate Advanced Bug
/obj/item/camera_bug/syndicate
	desc = "Переносной монитор с чипом удалённого доступа. Позволяет свободно перемещать обзор по всей сети камер."
	var/obj/machinery/computer/camera_advanced/portable/advanced_console

/obj/item/camera_bug/syndicate/Initialize(mapload)
	. = ..()
	advanced_console = new(src)
	advanced_console.parent_item = src
	advanced_console.networks = list("SS13")

/obj/item/camera_bug/syndicate/Destroy()
	advanced_console.parent_item = null
	QDEL_NULL(advanced_console)
	return ..()

/obj/machinery/computer/security/camera_bug/ui_data(mob/user)
	var/list/data = ..()

	if(is_syndi_camera_bug(parent))
		data["is_portable"] = TRUE

	return data

/obj/machinery/computer/security/camera_bug/ui_act(action, params)
	if(..())
		return TRUE

	if(action == "toggle_advanced")
		if(!is_syndi_camera_bug(parent))
			return FALSE

		var/obj/item/camera_bug/syndicate/cam_bug = parent

		if(isliving(usr))
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
	if(!parent_item || QDELETED(parent_item) || parent_item.loc != user || user.incapacitated() || user.stat != CONSCIOUS)
		user.unset_machine()
		return

/obj/machinery/computer/camera_advanced/portable/on_unset_machine(mob/used_mob)
	..()

	if(parent_item && !QDELETED(parent_item) && used_mob && used_mob.stat == CONSCIOUS)
		parent_item.ui_interact(used_mob)

/obj/machinery/computer/camera_advanced/portable/attack_hand(mob/user)
	if(..())
		return

	if(eyeobj)
		eyeobj.eye_initialized = TRUE
		eyeobj.setLoc(get_turf(user))

	for(var/atom/movable/screen/plane_master/master_plane in user.hud_used?.get_true_plane_masters(CAMERA_STATIC_PLANE))
		master_plane.unhide_plane(user)

/obj/machinery/computer/security/camera_bug/ui_host()
	return parent ? parent : src

/obj/machinery/computer/camera_advanced/portable/ui_host()
	return parent_item ? parent_item : src

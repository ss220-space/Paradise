/obj/item/sensor_device
	name = "handheld crew monitor"
	desc = "Миниатюрное устройство, с помощью которого можно отслеживать датчики членов экипажа станции."
	ru_names = list(
		NOMINATIVE = "ручной монитор экипажа",
		GENITIVE = "ручного монитора экипажа",
		DATIVE = "ручному монитору экипажа",
		ACCUSATIVE = "ручной монитор экипажа",
		INSTRUMENTAL = "ручным монитором экипажа",
		PREPOSITIONAL = "ручном мониторе экипажа"
	)
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	item_state = "scanner"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	origin_tech = "programming=3;materials=3;magnets=3"
	var/datum/ui_module/crew_monitor/crew_monitor

/obj/item/sensor_device/Initialize(mapload)
	.=..()
	crew_monitor = new(src)

/obj/item/sensor_device/Destroy()
	QDEL_NULL(crew_monitor)
	return ..()

/obj/item/sensor_device/attack_self(mob/user)
	ui_interact(user)


/obj/item/sensor_device/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!.)
		return FALSE

	var/mob/user = usr
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !ishuman(user))
		return FALSE

	if(over_object == user)
		attack_self(user)
		return TRUE

	return FALSE


/obj/item/sensor_device/ui_interact(mob/user, datum/tgui/ui = null)
	crew_monitor.ui_interact(user, ui)

/obj/item/sensor_device/advanced

/obj/item/sensor_device/advanced/command
	name = "command crew monitor"
	desc = "Миниатюрное устройство, с помощью которого можно отслеживать датчики членов экипажа станции. Эта модель настроена на членов командования."
	ru_names = list(
		NOMINATIVE = "командный монитор экипажа",
		GENITIVE = "командного монитора экипажа",
		DATIVE = "командному монитору экипажа",
		ACCUSATIVE = "командный монитор экипажа",
		INSTRUMENTAL = "командным монитором экипажа",
		PREPOSITIONAL = "командном мониторе экипажа"
	)
	item_state = "blueshield_monitor"
	icon_state = "c_scanner"

/obj/item/sensor_device/advanced/command/Initialize(mapload)
	. = ..()
	crew_monitor.crew_vision = CREW_VISION_COMMAND

/obj/item/sensor_device/advanced/security
	name = "security crew monitor"
	desc = "Миниатюрное устройство, с помощью которого можно отслеживать датчики членов экипажа станции. Эта модель настроена на членов службы безопасности."
	ru_names = list(
		NOMINATIVE = "охранный монитор экипажа",
		GENITIVE = "охранного монитора экипажа",
		DATIVE = "охранному монитору экипажа",
		ACCUSATIVE = "охранный монитор экипажа",
		INSTRUMENTAL = "охранным монитором экипажа",
		PREPOSITIONAL = "охранном мониторе экипажа"
	)
	item_state = "brig_monitor"
	icon_state = "s_scanner"

/obj/item/sensor_device/advanced/security/Initialize(mapload)
	. = ..()
	crew_monitor.crew_vision = CREW_VISION_SECURITY

/obj/item/sensor_device/advanced/mining
	name = "mining crew monitor"
	desc = "Миниатюрное устройство, с помощью которого можно отслеживать датчики членов экипажа станции. Эта модель настроена на шахтёрский персонал станции."
	ru_names = list(
		NOMINATIVE = "шахтёрский монитор экипажа",
		GENITIVE = "шахтёрского монитора экипажа",
		DATIVE = "шахтёрскому монитору экипажа",
		ACCUSATIVE = "шахтёрский монитор экипажа",
		INSTRUMENTAL = "шахтёрским монитором экипажа",
		PREPOSITIONAL = "шахтёрском мониторе экипажа"
	)
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	icon_state = "shaft_scanner"
	item_state = "mining_scanner"

/obj/item/sensor_device/advanced/mining/Initialize(mapload)
	. = ..()
	crew_monitor.crew_vision = CREW_VISION_MINING

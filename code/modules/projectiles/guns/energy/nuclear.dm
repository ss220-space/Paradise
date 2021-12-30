/obj/item/gun/energy/gun
	name = "energy gun"
	desc = "A basic energy-based gun with two settings: kill and disable."
	icon_state = "energy"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	origin_tech = "combat=4;magnets=3"
	modifystate = 2
	can_flashlight = 1
	ammo_x_offset = 3
	flight_x_offset = 15
	flight_y_offset = 10

/obj/item/gun/energy/gun/cyborg
	desc = "An energy-based laser gun that draws power from the cyborg's internal energy cell directly. So this is what freedom looks like?"

/obj/item/gun/energy/gun/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/gun/cyborg/emp_act()
	return

/obj/item/gun/energy/gun/mini
	name = "Миниатюрный энергопистолет"
	desc = "Небольшой энергопистолет со встроенным фонариком. У него два режима: оглушающий и летальный."
	icon_state = "mini"
	w_class = WEIGHT_CLASS_SMALL
	ammo_x_offset = 2
	charge_sections = 3
	can_flashlight = 0 // Can't attach or detach the flashlight, and override it's icon update
	actions_types = list(/datum/action/item_action/toggle_gunlight)

/obj/item/gun/energy/gun/mini/Initialize(mapload, ...)
	gun_light = new /obj/item/flashlight/seclite(src)
	. = ..()
	cell.maxcharge = 600
	cell.charge = 600

/obj/item/gun/energy/gun/mini/update_icon()
	..()
	if(gun_light && gun_light.on)
		overlays += "mini-light"

/obj/item/gun/energy/gun/hos
	name = "\improper Многофазный энергопистолет Икс-01"
	desc = "Это дорогая, современная версия антикварного лазерного пистолета. У этого оружия есть несколько уникальных режимов ведения огня, но нет возможности самостоятельно перезаряжаться с течением времени."
	icon_state = "hoslaser"
	origin_tech = null
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/hos, /obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser/hos)
	ammo_x_offset = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/gun/energy/gun/blueshield
	name = "Улучшенный оглушающий револьвер"
	desc = "Улучшенный оглушающий револьвер со способностью стрелять как электродами, так и лазером."
	icon_state = "bsgun"
	item_state = "gun"
	force = 7
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/hos, /obj/item/ammo_casing/energy/laser/hos)
	ammo_x_offset = 1
	shaded_charge = 1

/obj/item/gun/energy/gun/blueshield/pdw9
	name = "Тазер-пистолет PDW-9"
	desc = "Пистолет военного образца, используемый многими ополченцами этого сектора космоса."
	icon_state = "pdw9pistol"

/obj/item/gun/energy/gun/turret
	name = "Гибридный ствол турели"
	desc = "Тяжелая гибридная энергетическая пушка с двумя режимами: оглушающим и летальным."
	icon_state = "turretlaser"
	item_state = "turretlaser"
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	weapon_weight = WEAPON_HEAVY
	can_flashlight = 0
	trigger_guard = TRIGGER_GUARD_NONE
	ammo_x_offset = 2

/obj/item/gun/energy/gun/nuclear
	name = "Продвинутый энергетический карабин"
	desc = "Энергетический карабин с экспериментальным миниатюрным ядерным реактором, автоматически заряжающим внутреннюю батарею."
	icon_state = "nucgun"
	item_state = "nucgun"
	origin_tech = "combat=4;magnets=4;powerstorage=4"
	var/fail_tick = 0
	charge_delay = 5
	can_charge = 0
	ammo_x_offset = 1
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	selfcharge = 1

/obj/item/laser_modification_case
	name = "laser weapons modification case"
	desc = "Одноразовый набор, используемый для серьёзной модификации лазерного и энергетического оружия. В комплект входят зарядные устройства и запасные аккумуляторы."
	icon = 'icons/obj/device.dmi'
	icon_state = "modcase"
	item_state = "modcase"

	/// Not actually used, all upgrades used in attackby of those weapons
	var/static/list/upgradable_weapons = list(
		/obj/item/gun/energy/accumulator/energy_carbine,
		/obj/item/gun/energy/laser/automatic/carbine,
		/obj/item/gun/energy/laser/hitscan/carbine,
	)
	var/static/list/weapons_names = list(
		"аккумуляторные энерго-винтовки «Скорпион»",
		"автоматические лазерные винтовки «Гроза»",
		"лазерные винтовки «Страж»",
	)

/obj/item/laser_modification_case/examine(mob/user)
	. = ..()
	. += span_notice("Используется для модификации определённых видов оружия в более специализированные вариации.")
	. += span_notice("Как правило, каждое оружие улучшается из стандартного карабина в следующие типы: Дробовик, Штурмовая винтовка, Снайперская винтовка или пистолет.")
	. += span_notice("Пистолеты, будучи несколько слабее стандартной винтовки, обладают меньшим размером и позволяют хранить себя в сумках и кобурах.")
	. += span_notice("Дробовики стреляют лазерной картечью, позволяя вести огонь в тесных пространствах.")
	. += span_notice("Штурмовые винтовки обладают автоматическим огнём и позволяют вести непрерывную стрельбу, а так же обладают встроенным счётчиком боезапаса.")
	. += span_notice("Снайперские винтовки наносят огромный ущерб, однако их заряд батареи крайне ограничен, а непрерывная стрельба затруднена.")
	. += span_notice("Список улучшаемого оружия: [russian_list(weapons_names)]")


// parent type for weapon case modificator
/datum/energy_weapon_type
	var/name = "оружие"
	var/icon = 'icons/obj/weapons/energy.dmi'
	var/icon_state = "retro"
	var/parent_weapon_type = /obj/item/gun/energy
	var/chosen_type = /obj/item/gun/energy

// MARK: accumulator types
/datum/energy_weapon_type/accumulator
	parent_weapon_type = /obj/item/gun/energy/accumulator

/datum/energy_weapon_type/accumulator/carbine
	name = "карабин «Скорпион»"
	icon_state = "energycarbine"
	chosen_type = /obj/item/gun/energy/accumulator/energy_carbine

/datum/energy_weapon_type/accumulator/automatic
	name = "автомат «Медуза»"
	icon_state = "energy_rifle"
	chosen_type = /obj/item/gun/energy/accumulator/automatic

/datum/energy_weapon_type/accumulator/pistol
	name = "пистолет «Оса»"
	icon_state = "energypistol"
	chosen_type = /obj/item/gun/energy/accumulator/energy_pistol

/datum/energy_weapon_type/accumulator/shotgun
	name = "дробовик «Скарабей»"
	icon_state = "energy_shotgun"
	chosen_type = /obj/item/gun/energy/accumulator/shotgun

/datum/energy_weapon_type/accumulator/sniper_rifle
	name = "снайперская винтовка «Богомол»"
	icon = 'icons/obj/weapons/guns_48x32.dmi'
	icon_state = "energy_sniper_rifle"
	chosen_type = /obj/item/gun/energy/accumulator/sniper_rifle

// MARK: automatic types
/datum/energy_weapon_type/automatic
	parent_weapon_type = /obj/item/gun/energy/laser/automatic

/datum/energy_weapon_type/automatic/carbine
	name = "карабин «Гроза»"
	icon_state = "automatic_laser"
	chosen_type = /obj/item/gun/energy/laser/automatic/carbine

/datum/energy_weapon_type/automatic/automatic
	name = "автомат «Ливень»"
	icon_state = "automatic_laser_rifle"
	chosen_type = /obj/item/gun/energy/laser/automatic/assault_mg

/datum/energy_weapon_type/automatic/pistol
	name = "пистолет «Буря»"
	icon_state = "automatic_laser_pistol"
	chosen_type = /obj/item/gun/energy/laser/automatic/pistol

/datum/energy_weapon_type/automatic/shotgun
	name = "дробовик «Шторм»"
	icon_state = "automatic_laser_shotgun"
	chosen_type = /obj/item/gun/energy/laser/automatic/shotgun

/datum/energy_weapon_type/automatic/sniper_rifle
	name = "снайперская винтовка «Град»"
	icon = 'icons/obj/weapons/guns_48x32.dmi'
	icon_state = "automatic_sniper_rifle"
	chosen_type = /obj/item/gun/energy/laser/automatic/sniper_rifle

// MARK: hitscan types
/datum/energy_weapon_type/hitscan
	parent_weapon_type = /obj/item/gun/energy/laser/hitscan

/datum/energy_weapon_type/hitscan/carbine
	name = "карабин «Страж»"
	icon_state = "lasergun"
	chosen_type = /obj/item/gun/energy/laser/hitscan/carbine

/datum/energy_weapon_type/hitscan/automatic
	name = "автомат «Зенит»"
	icon_state = "lasermg"
	chosen_type = /obj/item/gun/energy/laser/hitscan/assault_mg

/datum/energy_weapon_type/hitscan/pistol
	name = "пистолет «Шершень»"
	icon_state = "laserpistol"
	chosen_type = /obj/item/gun/energy/laser/hitscan/pistol

/datum/energy_weapon_type/hitscan/shotgun
	name = "дробовик «Фокус»"
	icon_state = "lasershotgun"
	chosen_type = /obj/item/gun/energy/laser/hitscan/shotgun

/datum/energy_weapon_type/hitscan/sniper_rifle
	name = "снайперская винтовка «Игла»"
	icon_state = "laserrifle"
	icon = 'icons/obj/weapons/guns_48x32.dmi'
	chosen_type = /obj/item/gun/energy/laser/hitscan/sniper_rifle

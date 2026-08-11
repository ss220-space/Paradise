/obj/item/laser_modification_case
	name = "laser weapons modification case"
	desc = "Одноразовый набор, используемый для серьёзной модификации лазерного и энергетического оружия."
	icon = 'icons/obj/device.dmi'
	icon_state = "modcase"
	item_state = "modcase"
	w_class = WEIGHT_CLASS_NORMAL

	/// Not actually used, all upgrades used in attackby of those weapons
	var/static/list/upgradable_weapons = list(
		/obj/item/gun/energy/accumulator/energy_carbine,
		/obj/item/gun/energy/laser/automatic,
		/obj/item/gun/energy/laser/hitscan,
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
	. += span_notice("Штурмовые винтовки обладают автоматическим огнём и позволяют вести непрерывную стрельбу")
	. += span_notice("Снайперские винтовки наносят огромный ущерб, однако их заряд батареи крайне ограничен, а непрерывная стрельба затруднена.")
	. += span_notice("Список улучшаемого оружия: [russian_list(weapons_names)]")

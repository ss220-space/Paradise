/obj/effect/spawner/random/stock_parts
	name = "stock parts spawner"
	icon_state = "stock_parts"
	loot = list(
		// T1
		/obj/item/stock_parts/capacitor,
		/obj/item/stock_parts/scanning_module,
		/obj/item/stock_parts/manipulator,
		/obj/item/stock_parts/micro_laser,
		/obj/item/stock_parts/matter_bin,

		// T2
		/obj/item/stock_parts/capacitor/adv,
		/obj/item/stock_parts/scanning_module/adv,
		/obj/item/stock_parts/manipulator/nano,
		/obj/item/stock_parts/micro_laser/high,
		/obj/item/stock_parts/matter_bin/adv,

		// T3
		/obj/item/stock_parts/capacitor/super,
		/obj/item/stock_parts/scanning_module/phasic,
		/obj/item/stock_parts/manipulator/pico,
		/obj/item/stock_parts/micro_laser/ultra,
		/obj/item/stock_parts/matter_bin/super,

		// T4
		/obj/item/stock_parts/capacitor/quadratic,
		/obj/item/stock_parts/scanning_module/triphasic,
		/obj/item/stock_parts/manipulator/femto,
		/obj/item/stock_parts/micro_laser/quadultra,
		/obj/item/stock_parts/matter_bin/bluespace,

		// Power cells
		/obj/item/stock_parts/cell,
		/obj/item/stock_parts/cell/high,
		/obj/item/stock_parts/cell/high/plus,
		/obj/item/stock_parts/cell/super,
		/obj/item/stock_parts/cell/hyper,
		/obj/item/stock_parts/cell/bluespace,
		/obj/item/stock_parts/cell/infinite/abductor,
		/obj/item/stock_parts/cell/high/slime,
		/obj/item/stock_parts/cell/potato,
	)

/obj/effect/spawner/random/decals_spawner
	name = "decals spawner"

/obj/effect/spawner/random/decals_spawner/Initialize(mapload)
	var/static/list/decals_list
	if(!decals_list)
		decals_list = valid_subtypesof(/obj/effect/decal/cleanable) - list(/obj/effect/decal/cleanable/cobweb, /obj/effect/decal/cleanable/cobweb2)
	loot = decals_list
	return ..()



/**********************Mining Equipment Vendor Items**************************/
//misc stuff you can buy from the vendor that has special code but doesn't really need its own file

/**********************Facehugger toy**********************/
/obj/item/clothing/mask/facehugger/toy
	item_state = "facehugger_inactive"
	desc = "Игрушка, которую часто используют, чтобы подшутить над другими шахтерами, подкладывая ее в их кровати. После того, как за что-то зацепишься, требуется некоторое время для подзарядки."
	real = 0
	sterile = 1
	mob_throw_hit_sound = null
	equip_sound = 'sound/items/handling/equip/generic_equip4.ogg'
	drop_sound = 'sound/items/handling/drop/generic_drop5.ogg'
	pickup_sound = 'sound/items/handling/pickup/generic_pickup3.ogg'
	clothing_traits = null
	holder_flags = ALIEN_HOLDER | HUMAN_HOLDER

/obj/item/clothing/mask/facehugger/toy/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/proximity_monitor)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/clothing/mask/facehugger/toy/Die()
	return

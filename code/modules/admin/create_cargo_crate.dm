/datum/admins/proc/create_cargo_crate()

	if(!check_rights(R_SPAWN))
		return

	var/path = tgui_input_list(usr, "Выберите тип для спавна", "Карго ящики", (typecacheof(/datum/supply_packs) + typecacheof(/datum/syndie_supply_packs)))
	if(!path || !ispath(path))
		return
	var/datum/supply_order/order = (path in typecacheof(/datum/supply_packs))? new /datum/supply_order : new /datum/syndie_supply_order
	order.ordernum = 0
	order.object = new path
	order.orderedby = "ОШИБКА"
	order.orderedbyRank = "ОШИБКА"
	order.crates = 1
	order.createObject(get_turf(usr))

	log_and_message_admins("spawned cargo pack [order.object.name] at ([usr.x],[usr.y],[usr.z])")

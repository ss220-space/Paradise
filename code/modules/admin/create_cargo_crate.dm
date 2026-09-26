/datum/admins/proc/create_cargo_crate()

	if(!check_rights(R_SPAWN))
		return

	var/path = tgui_input_list(usr, "Выберите тип для спавна", "Карго ящики", (typecacheof(/datum/supply_packs) + typecacheof(/datum/syndie_supply_packs)))
	if(!path || !ispath(path))
		return
	SSadmin_verbs.dynamic_invoke_verb(owner, /datum/admin_verb/spawn_cargo)

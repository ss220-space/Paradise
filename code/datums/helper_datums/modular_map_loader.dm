/obj/modular_map_root
	name = "modular map root"
	icon = 'icons/effects/bitrunning.dmi'
	icon_state = "safehouse"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/config_file
	var/key

/obj/modular_map_root/proc/load_module()
	if(isnull(config_file) || isnull(key))
		stack_trace("modular map root: missing config_file or key (config [config_file], key [key])")
		return

	var/turf/destination = get_turf(src)
	var/list/config = rustg_read_toml_file(config_file)
	var/list/room = config["rooms"]?[key]
	if(!length(room?["modules"]))
		stack_trace("modular map root: no modules listed for key '[key]' in [config_file]")
		return

	var/datum/map_template/module = new(path = "[config["directory"]][pick(room["modules"])]")
	module.load(destination)

	if(!(locate(/obj/modular_map_connector) in destination))
		stack_trace("modular map root: module for key '[key]' did not align its connector to the root")

	qdel(src, force = TRUE)

/obj/modular_map_connector
	name = "modular map connector"
	icon = 'icons/effects/bitrunning.dmi'
	icon_state = "safehouse"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/modular_map_root/safehouse
	config_file = "strings/modular_maps/safehouse.toml"

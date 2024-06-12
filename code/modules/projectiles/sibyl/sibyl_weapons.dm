/obj/item/gun/energy/proc/install_sibyl()
	var/obj/item/sibyl_system_mod/M = new /obj/item/sibyl_system_mod
	M.voice_is_enabled = FALSE
	M.install(src)

/obj/item/gun/energy/dominator/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

/obj/item/gun/energy/gun/advtaser/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

/obj/item/gun/energy/disabler/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

/obj/item/gun/energy/gun/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

/obj/item/gun/energy/gun/mini/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

/obj/item/gun/energy/gun/pdw9/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

/obj/item/gun/energy/gun/nuclear/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

/obj/item/gun/energy/laser/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

/obj/item/gun/energy/immolator/multi/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

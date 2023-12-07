
/obj/item/storage/box/survival
	name = "boxed survival kit"
	var/target_species = "Universal"
	var/design_type = null

/obj/item/storage/box/survival/machine
	name = "IPC maintenance kit"
	icon_state = "box_machine"
	target_species = "Machine"

/obj/item/storage/box/survival/plasmaman
	icon_state = "box_plasma"
	target_species = "Plasmaman"

/obj/item/storage/box/survival/vox
	icon_state = "box_vox"
	target_species = "Vox"

// STANDART BOXES

/obj/item/storage/box/survival/regular
	icon_state = "box_civ"
	design_type = "civillian"

/obj/item/storage/box/survival/regular/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/machine/regular
	design_type = "civillian"

/obj/item/storage/box/survival/machine/populate_contents()
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/plasmaman/regular
	design_type = "civillian"

/obj/item/storage/box/survival/plasmaman/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/plasma(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/vox/regular
	design_type = "civillian"

/obj/item/storage/box/survival/vox/populate_contents()
	new /obj/item/clothing/mask/breath/vox(src)
	new /obj/item/tank/internals/emergency_oxygen/nitrogen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/regular/brigphys
	icon_state = "box_brigphys"
	design_type = "brigphys"

/obj/item/storage/box/survival/machine/regular/brigphys
	icon_state = "box_machine"
	design_type = "brigphys"

/obj/item/storage/box/survival/plasmaman/regular/brigphys
	icon_state = "box_plasma"
	design_type = "brigphys"

/obj/item/storage/box/survival/vox/regular/brigphys
	icon_state = "box_vox"
	design_type = "brigphys"

/obj/item/storage/box/survival/engineer
	icon_state = "box_eng"
	design_type = "engineer"

/obj/item/storage/box/survival/engineer/populate_contents()
	new /obj/item/clothing/mask/breath( src )
	new /obj/item/tank/internals/emergency_oxygen/engi( src )
	new /obj/item/storage/firstaid/crew( src )
	new /obj/item/flashlight/flare/glowstick/blue( src )

/obj/item/storage/box/survival/machine/regular/engineer
	icon_state = "box_machine"
	design_type = "engineer"

/obj/item/storage/box/survival/plasmaman/engineer
	icon_state = "box_plasma"
	design_type = "engineer"

/obj/item/storage/box/survival/plasmaman/engineer/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/plasmaman/belt(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/vox/engineer
	icon_state = "box_vox"
	design_type = "engineer"

/obj/item/storage/box/survival/vox/engineer/populate_contents()
	new /obj/item/clothing/mask/breath/vox(src)
	new /obj/item/tank/internals/emergency_oxygen/double/vox(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/miner
	icon_state = "box_min"
	design_type = "miner"

/obj/item/storage/box/survival/miner/populate_contents()
	new /obj/item/clothing/mask/gas/explorer(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/machine/miner
	icon_state = "box_machine"
	design_type = "miner"

/obj/item/storage/box/survival/machine/miner/populate_contents()
	new /obj/item/crowbar/red(src)
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/plasmaman/miner
	icon_state = "box_plasma"
	design_type = "miner"

/obj/item/storage/box/survival/plasmaman/miner/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/plasmaman/belt(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/vox/miner
	icon_state = "box_vox"
	design_type = "miner"

/obj/item/storage/box/survival/vox/miner/populate_contents()
	new /obj/item/clothing/mask/breath/vox(src)
	new /obj/item/tank/internals/emergency_oxygen/double/vox(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

// SECURITY BOXES

/obj/item/storage/box/survival/security
	design_type = "security"
	can_hold = list(/obj/item/clothing/mask/gas/sechailer)

/obj/item/storage/box/survival/security/populate_contents()
	new /obj/item/tank/internals/emergency_oxygen/engi/sec(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/red(src)
	new /obj/item/radio/sec(src)

/obj/item/storage/box/survival/security/Initialize(mapload)
	. = ..()
	if(istype(loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		switch(H.mind?.assigned_role)
			if("Security Officer")
				icon_state = "[icon_state]_officer"
			if("Head of Security")
				icon_state = "[icon_state]_hos"
			if("Security Cadet")
				icon_state = "[icon_state]_cadet"
			if("Warden")
				icon_state = "[icon_state]_warden"
			if("Pilot")
				icon_state = "[icon_state]_pilot"
			if("Detective")
				icon_state = "[icon_state]_detective"

/obj/item/storage/box/survival/security/machine
	name = "IPC maintenance kit"
	target_species = "Machine"

/obj/item/storage/box/survival/security/machine/populate_contents()
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/red(src)
	new /obj/item/radio/sec(src)

/obj/item/storage/box/survival/security/plasmaman
	target_species = "Plasmaman"

/obj/item/storage/box/survival/security/plasmaman/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/plasmaman/belt(src)
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/red(src)
	new /obj/item/radio/sec(src)

/obj/item/storage/box/survival/security/vox
	target_species = "Vox"

/obj/item/storage/box/survival/security/vox/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/emergency_oxygen/double/vox(src)
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/red(src)
	new /obj/item/radio/sec(src)

// PROCEDURE BOXES

/obj/item/storage/box/survival/procedure
	design_type = "procedure"

/obj/item/storage/box/survival/procedure/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/pink(src)
	new /obj/item/book/manual/security_space_law(src)
	new /obj/item/taperecorder(src)
	new /obj/item/camera(src)

/obj/item/storage/box/survival/procedure/Initialize(mapload)
	. = ..()
	if(istype(loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		switch(H.mind?.assigned_role)
			if("Internal Affairs Agent")
				icon_state = "[icon_state]_iaa"
			if("Magistrate")
				icon_state = "[icon_state]_magistrate"

/obj/item/storage/box/survival/procedure/machine
	target_species = "Machine"

/obj/item/storage/box/survival/procedure/machine/populate_contents()
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/pink(src)
	new /obj/item/book/manual/security_space_law(src)
	new /obj/item/taperecorder(src)
	new /obj/item/camera(src)

/obj/item/storage/box/survival/procedure/plasmaman
	target_species = "Plasmaman"

/obj/item/storage/box/survival/procedure/plasmaman/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/plasma(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/pink(src)
	new /obj/item/book/manual/security_space_law(src)
	new /obj/item/taperecorder(src)
	new /obj/item/camera(src)

/obj/item/storage/box/survival/procedure/vox
	target_species = "Vox"

/obj/item/storage/box/survival/procedure/vox/populate_contents()
	new /obj/item/clothing/mask/breath/vox(src)
	new /obj/item/tank/internals/emergency_oxygen/nitrogen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/pink(src)
	new /obj/item/book/manual/security_space_law(src)
	new /obj/item/taperecorder(src)
	new /obj/item/camera(src)

// SYNDICATE BOXES

/obj/item/storage/box/survival/syndicate
	icon_state = "box_syndi"
	design_type = "syndicate"
	can_hold = list(/obj/item/clothing/mask/gas/syndicate)

/obj/item/storage/box/survival/syndicate/populate_contents()
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/reagent_containers/food/pill/initropidril(src)
	new /obj/item/flashlight/flare/glowstick/red(src)

/obj/item/storage/box/survival/syndicate/machine
	target_species = "Machine"

/obj/item/storage/box/survival/syndicate/machine/populate_contents()
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/red(src)

/obj/item/storage/box/survival/syndicate/plasmaman
	target_species = "Plasmaman"

/obj/item/storage/box/survival/syndicate/plasmaman/populate_contents()
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/plasmaman/belt(src)
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/reagent_containers/food/pill/initropidril(src)
	new /obj/item/flashlight/flare/glowstick/red(src)

/obj/item/storage/box/survival/syndicate/vox
	target_species = "Vox"

/obj/item/storage/box/survival/syndicate/vox/populate_contents()
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/double/vox(src)
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/reagent_containers/food/pill/initropidril(src)
	new /obj/item/flashlight/flare/glowstick/red(src)

// CENTCOMM BOXES

/obj/item/storage/box/survival/centcomm
	name = "officer kit"
	icon_state = "box_ert"
	design_type = "centcomm"
	storage_slots = 14
	max_combined_w_class = 20
	can_hold = list(/obj/item/clothing/mask/gas/sechailer)

/obj/item/storage/box/survival/centcomm/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/emergency_oxygen/double(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/door_remote/omni(src)
	new /obj/item/implanter/death_alarm(src)
	new /obj/item/reagent_containers/hypospray/combat/nanites(src)
	new /obj/item/pinpointer(src)
	new /obj/item/pinpointer/crew/centcom(src)

/obj/item/storage/box/survival/centcomm/machine
	target_species = "Machine"

/obj/item/storage/box/survival/centcomm/machine/populate_contents()
	new /obj/item/flashlight/seclite(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/door_remote/omni(src)
	new /obj/item/implanter/death_alarm(src)
	new /obj/item/reagent_containers/hypospray/combat/nanites(src)
	new /obj/item/pinpointer(src)
	new /obj/item/pinpointer/crew/centcom(src)

/obj/item/storage/box/survival/centcomm/plasmaman
	target_species = "Plasmaman"

/obj/item/storage/box/survival/centcomm/plasmaman/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/plasmaman/belt(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/door_remote/omni(src)
	new /obj/item/implanter/death_alarm(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/reagent_containers/hypospray/combat/nanites(src)
	new /obj/item/pinpointer(src)
	new /obj/item/pinpointer/crew/centcom(src)

/obj/item/storage/box/survival/centcomm/vox
	target_species = "Vox"

/obj/item/storage/box/survival/centcomm/vox/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/emergency_oxygen/double/vox(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/door_remote/omni(src)
	new /obj/item/implanter/death_alarm(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/reagent_containers/hypospray/combat/nanites(src)
	new /obj/item/pinpointer(src)
	new /obj/item/pinpointer/crew/centcom(src)

/obj/item/storage/box/survival/ert
	icon_state = "box_ert"
	design_type = "ert"
	can_hold = list(/obj/item/clothing/mask/gas/sechailer)

/obj/item/storage/box/survival/ert/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/storage/firstaid/crew/combat(src)

/obj/item/storage/box/survival/ert/machine
	target_species = "Machine"

/obj/item/storage/box/survival/ert/machine/populate_contents()
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/stack/nanopaste(src)

/obj/item/storage/box/survival/ert/plasmaman
	target_species = "Plasmaman"

/obj/item/storage/box/survival/ert/plasmaman/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/plasmaman/belt(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/storage/firstaid/crew/combat(src)

/obj/item/storage/box/survival/ert/vox
	target_species = "Vox"

/obj/item/storage/box/survival/ert/vox/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/emergency_oxygen/double/vox(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/storage/firstaid/crew/combat(src)

/obj/item/storage/box/survival/soviet
	desc = "A standard issue Soviet military survival kit."
	icon_state = "box_soviet"

/obj/item/storage/box/survival/soviet/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/storage/firstaid/crew/combat(src)

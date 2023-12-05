
/obj/item/storage/box/survival
	name = "boxed survival kit"
	var/target_species = null
	var/design_type = null

// STANDART BOXES

/obj/item/storage/box/survival/regular
	icon_state = "box_civ"
	design_type = "civillian"

/obj/item/storage/box/survival/regular/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/machine
	icon_state = "box_machine"
	target_species = "machine"

/obj/item/storage/box/survival/machine/populate_contents()
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/plasmaman
	icon_state = "box_plasma"
	target_species = "plasmaman"

/obj/item/storage/box/survival/plasmaman/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/plasma(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/vox
	icon_state = "box_vox"
	target_species = "vox"

/obj/item/storage/box/survival/vox/populate_contents()
	new /obj/item/clothing/mask/breath/vox(src)
	new /obj/item/tank/internals/emergency_oxygen/nitrogen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/engineer
	icon_state = "box_eng"
	design_type = "engineer"

/obj/item/storage/box/survival/engineer/populate_contents()
	new /obj/item/clothing/mask/breath( src )
	new /obj/item/tank/internals/emergency_oxygen/engi( src )
	new /obj/item/storage/firstaid/crew( src )
	new /obj/item/flashlight/flare/glowstick/blue( src )

/obj/item/storage/box/survival/machine/engineer
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

/obj/item/storage/box/survival/miner/vox
	icon_state = "box_vox"
	design_type = "miner"

/obj/item/storage/box/survival/miner/vox/populate_contents()
	new /obj/item/clothing/mask/breath/vox(src)
	new /obj/item/tank/internals/emergency_oxygen/double/vox(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/brigphys
	icon_state = "box_brigphys"
	design_type = "brigphys"

/obj/item/storage/box/survival/machine/brigphys
	icon_state = "box_machine"
	design_type = "brigphys"

/obj/item/storage/box/survival/plasmaman/brigphys
	icon_state = "box_plasma"
	design_type = "brigphys"

/obj/item/storage/box/survival/vox/brigphys
	icon_state = "box_vox"
	design_type = "brigphys"

/obj/item/storage/box/survival/security
	can_hold = list(/obj/item/clothing/mask/gas/sechailer)

/obj/item/storage/box/survival/security/populate_contents()
	new /obj/item/tank/internals/emergency_oxygen/engi/sec(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/red(src)
	new /obj/item/radio/sec(src)

// SECURITY BOXES

/obj/item/storage/box/survival/machine/security
	can_hold = list(/obj/item/clothing/mask/gas/sechailer)

/obj/item/storage/box/survival/machine/security/populate_contents()
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/red(src)
	new /obj/item/radio/sec(src)

/obj/item/storage/box/survival/plasmaman/security
	can_hold = list(/obj/item/clothing/mask/gas/sechailer)

/obj/item/storage/box/survival/plasmaman/security/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/plasmaman/belt(src)
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/red(src)
	new /obj/item/radio/sec(src)

/obj/item/storage/box/survival/vox/security
	can_hold = list(/obj/item/clothing/mask/gas/sechailer)

/obj/item/storage/box/survival/vox/security/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/emergency_oxygen/double/vox(src)
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/red(src)
	new /obj/item/radio/sec(src)

/obj/item/storage/box/survival/security/officer
	icon_state = "box_sec"
	design_type = "officer"

/obj/item/storage/box/survival/machine/security/officer
	icon_state = "box_machine"
	design_type = "officer"

/obj/item/storage/box/survival/plasmaman/security/officer
	icon_state = "box_plasma"
	design_type = "officer"

/obj/item/storage/box/survival/vox/security/officer
	icon_state = "box_vox"
	design_type = "officer"

/obj/item/storage/box/survival/security/hos
	icon_state = "box_hos"
	design_type = "hos"

/obj/item/storage/box/survival/machine/security/hos
	icon_state = "box_machine"
	design_type = "hos"

/obj/item/storage/box/survival/plasmaman/security/hos
	icon_state = "box_plasma"
	design_type = "hos"

/obj/item/storage/box/survival/vox/security/hos
	icon_state = "box_vox"
	design_type = "hos"

/obj/item/storage/box/survival/security/cadet
	icon_state = "box_cadet"
	design_type = "cadet"

/obj/item/storage/box/survival/machine/security/cadet
	icon_state = "box_machine"
	design_type = "cadet"

/obj/item/storage/box/survival/plasmaman/security/cadet
	icon_state = "box_plasma"
	design_type = "cadet"

/obj/item/storage/box/survival/vox/security/cadet
	icon_state = "box_vox"
	design_type = "cadet"

/obj/item/storage/box/survival/security/warden
	icon_state = "box_warden"
	design_type = "warden"

/obj/item/storage/box/survival/machine/security/warden
	icon_state = "box_machine"
	design_type = "warden"

/obj/item/storage/box/survival/plasmaman/security/warden
	icon_state = "box_plasma"
	design_type = "warden"

/obj/item/storage/box/survival/vox/security/warden
	icon_state = "box_vox"
	design_type = "warden"

/obj/item/storage/box/survival/security/pilot
	icon_state = "box_pilot"
	design_type = "pilot"

/obj/item/storage/box/survival/machine/security/pilot
	icon_state = "box_machine"
	design_type = "pilot"

/obj/item/storage/box/survival/plasmaman/security/pilot
	icon_state = "box_plasma"
	design_type = "pilot"

/obj/item/storage/box/survival/vox/security/pilot
	icon_state = "box_vox"
	design_type = "pilot"

/obj/item/storage/box/survival/security/detective
	icon_state = "box_detective"
	design_type = "detective"

/obj/item/storage/box/survival/machine/security/detective
	icon_state = "box_machine"
	design_type = "detective"

/obj/item/storage/box/survival/plasmaman/security/detective
	icon_state = "box_plasma"
	design_type = "detective"

/obj/item/storage/box/survival/vox/security/detective
	icon_state = "box_vox"
	design_type = "detective"

// PROCEDURE BOXES

/obj/item/storage/box/survival/procedure

/obj/item/storage/box/survival/procedure/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/pink(src)
	new /obj/item/book/manual/security_space_law(src)
	new /obj/item/taperecorder(src)
	new /obj/item/camera(src)

/obj/item/storage/box/survival/machine/procedure

/obj/item/storage/box/survival/machine/populate_contents()
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/pink(src)
	new /obj/item/book/manual/security_space_law(src)
	new /obj/item/taperecorder(src)
	new /obj/item/camera(src)

/obj/item/storage/box/survival/plasmaman/procedure

/obj/item/storage/box/survival/plasmaman/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/plasma(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/pink(src)
	new /obj/item/book/manual/security_space_law(src)
	new /obj/item/taperecorder(src)
	new /obj/item/camera(src)

/obj/item/storage/box/survival/vox/procedure

/obj/item/storage/box/survival/vox/populate_contents()
	new /obj/item/clothing/mask/breath/vox(src)
	new /obj/item/tank/internals/emergency_oxygen/nitrogen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/pink(src)
	new /obj/item/book/manual/security_space_law(src)
	new /obj/item/taperecorder(src)
	new /obj/item/camera(src)

/obj/item/storage/box/survival/procedure/iaa
	icon_state = "box_avd"
	design_type = "iaa"

/obj/item/storage/box/survival/machine/procedure/iaa
	design_type = "iaa"

/obj/item/storage/box/survival/plasmaman/procedure/iaa
	design_type = "iaa"

/obj/item/storage/box/survival/vox/procedure/iaa
	design_type = "iaa"

/obj/item/storage/box/survival/procedure/magistrate
	icon_state = "box_magisraka"
	design_type = "magistrate"

/obj/item/storage/box/survival/machine/procedure/magistrate
	design_type = "magistrate"

/obj/item/storage/box/survival/plasmaman/procedure/magistrate
	design_type = "magistrate"

/obj/item/storage/box/survival/vox/procedure/magistrate
	design_type = "magistrate"

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

/obj/item/storage/box/survival/machine/syndicate
	design_type = "syndicate"
	can_hold = list(/obj/item/clothing/mask/gas/syndicate)

/obj/item/storage/box/survival/machine/security/populate_contents()
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/red(src)

/obj/item/storage/box/survival/plasmaman/syndicate
	design_type = "syndicate"
	can_hold = list(/obj/item/clothing/mask/gas/syndicate)

/obj/item/storage/box/survival/plasmaman/security/populate_contents()
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/plasmaman/belt(src)
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/reagent_containers/food/pill/initropidril(src)
	new /obj/item/flashlight/flare/glowstick/red(src)

/obj/item/storage/box/survival/vox/syndicate
	design_type = "syndicate"
	can_hold = list(/obj/item/clothing/mask/gas/syndicate)

/obj/item/storage/box/survival/vox/security/populate_contents()
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

/obj/item/storage/box/centcomofficer/populate_contents()
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

/obj/item/storage/box/survival/machine/centcomm
	name = "officer kit"
	icon_state = "box_ert"
	design_type = "centcomm"
	storage_slots = 14
	max_combined_w_class = 20

/obj/item/storage/box/survival/machine/centcomm/populate_contents()
	new /obj/item/flashlight/seclite(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/door_remote/omni(src)
	new /obj/item/implanter/death_alarm(src)
	new /obj/item/reagent_containers/hypospray/combat/nanites(src)
	new /obj/item/pinpointer(src)
	new /obj/item/pinpointer/crew/centcom(src)

/obj/item/storage/box/survival/plasmaman/centcomm
	name = "officer kit"
	icon_state = "box_ert"
	design_type = "centcomm"
	storage_slots = 14
	max_combined_w_class = 20

/obj/item/storage/box/survival/plasmaman/centcomm/populate_contents()
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

/obj/item/storage/box/survival/vox/centcomm
	name = "officer kit"
	icon_state = "box_ert"
	design_type = "centcomm"
	storage_slots = 14
	max_combined_w_class = 20

/obj/item/storage/box/survival/vox/centcomm/populate_contents()
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

/obj/item/storage/box/survival/ert/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/storage/firstaid/crew/ert(src)

/obj/item/storage/box/survival/machine/ert
	design_type = "ert"

/obj/item/storage/box/survival/machine/ert/populate_contents()
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/stack/nanopaste(src)

/obj/item/storage/box/survival/plasmaman/ert
	design_type = "ert"

/obj/item/storage/box/survival/plasmaman/ert/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/plasmaman/belt(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/storage/firstaid/crew/ert(src)

/obj/item/storage/box/survival/vox/ert
	design_type = "ert"

/obj/item/storage/box/survival/vox/ert/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/emergency_oxygen/double/vox(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/storage/firstaid/crew/ert(src)

/obj/item/storage/box/survival/soviet
	desc = "A standard issue Soviet military survival kit."
	icon_state = "box_soviet"
	design_type = "ussp"

/obj/item/storage/box/survival/soviet/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/storage/firstaid/crew/combat(src)

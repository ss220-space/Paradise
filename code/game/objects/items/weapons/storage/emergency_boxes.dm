/*	If you want to ...
1. ...	use different sprite for your box on specific role - just make it inside Initialize() of chosen box.
2. ...	make a boxes for new species, then make new "species" sub-type for every "emergency box" sub-type.
		Example: `/obj/item/storage/box/survival/regular/my_new_cool_species`
3. ...	create new type of boxes, then make it directly from `/obj/item/storage/box/survival/...`and don't forget to make
		"species" sub-types from every "exotic box user" species, if your new box will be able to be used by other species.
		Example: `/obj/item/storage/box/survival/my_new_cool_box/plasmaman`

	Exotic box users: Machine, Plasmaman, Vox.
*/

/obj/item/storage/box/survival
	name = "boxed survival kit"
	var/target_species = null	// Put here the name of species, what uses exotic emergency boxes.
								// Don't forget to set `speciesbox = FALSE` in species.
// STANDART BOXES

/obj/item/storage/box/survival/regular
	icon_state = "box_civ"

/obj/item/storage/box/survival/regular/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/regular/Initialize(mapload)
	. = ..()
	if(istype(loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		if(H.mind?.assigned_role == "Brig Physician")
			icon_state = "[icon_state]_bm"

/obj/item/storage/box/survival/regular/machine
	name = "IPC maintenance kit"
	icon_state = "box_civ_machine"
	target_species = "Machine"

/obj/item/storage/box/survival/regular/machine/populate_contents()
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/regular/plasmaman
	icon_state = "box_civ_plasma"
	target_species = "Plasmaman"

/obj/item/storage/box/survival/regular/plasmaman/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/plasma(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/regular/vox
	icon_state = "box_civ_vox"
	target_species = "Vox"

/obj/item/storage/box/survival/regular/vox/populate_contents()
	new /obj/item/clothing/mask/breath/vox(src)
	new /obj/item/tank/internals/emergency_oxygen/nitrogen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/engineer
	icon_state = "box_eng"

/obj/item/storage/box/survival/engineer/populate_contents()
	new /obj/item/clothing/mask/breath( src )
	new /obj/item/tank/internals/emergency_oxygen/engi( src )
	new /obj/item/storage/firstaid/crew( src )
	new /obj/item/flashlight/flare/glowstick/blue( src )

/obj/item/storage/box/survival/engineer/machine
	name = "IPC maintenance kit"
	icon_state = "box_eng_machine"
	target_species = "Machine"

/obj/item/storage/box/survival/engineer/machine/populate_contents()
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/engineer/plasmaman
	icon_state = "box_eng_plasma"
	target_species = "Plasmaman"

/obj/item/storage/box/survival/engineer/plasmaman/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/plasmaman/belt(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/engineer/vox
	icon_state = "box_eng_vox"
	target_species = "Vox"

/obj/item/storage/box/survival/engineer/vox/populate_contents()
	new /obj/item/clothing/mask/breath/vox(src)
	new /obj/item/tank/internals/emergency_oxygen/double/vox(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/miner
	icon_state = "box_min"

/obj/item/storage/box/survival/miner/populate_contents()
	new /obj/item/clothing/mask/gas/explorer(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/miner/machine
	icon_state = "box_min_machine"
	target_species = "Machine"

/obj/item/storage/box/survival/miner/machine/populate_contents()
	new /obj/item/crowbar/red(src)
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/miner/plasmaman
	icon_state = "box_min_plasma"
	target_species = "Plasmaman"

/obj/item/storage/box/survival/miner/plasmaman/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/plasmaman/belt(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/miner/vox
	icon_state = "box_min_vox"
	target_species = "Vox"

/obj/item/storage/box/survival/miner/vox/populate_contents()
	new /obj/item/clothing/mask/breath/vox(src)
	new /obj/item/tank/internals/emergency_oxygen/double/vox(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

// SECURITY BOXES

/obj/item/storage/box/survival/security
	icon_state = "box_sec"
	w_class_override = list(/obj/item/clothing/mask/gas/sechailer)

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
			if("Head of Security")
				icon_state = "[icon_state]_hos"
			if("Security Cadet")
				icon_state = "[icon_state]_cad"
			if("Warden")
				icon_state = "[icon_state]_war"
			if("Pilot")
				icon_state = "[icon_state]_pil"
			if("Detective")
				icon_state = "[icon_state]_det"

/obj/item/storage/box/survival/security/machine
	name = "IPC maintenance kit"
	icon_state = "box_sec_machine"
	target_species = "Machine"

/obj/item/storage/box/survival/security/machine/populate_contents()
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/red(src)
	new /obj/item/radio/sec(src)

/obj/item/storage/box/survival/security/plasmaman
	icon_state = "box_sec_plasma"
	target_species = "Plasmaman"

/obj/item/storage/box/survival/security/plasmaman/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/plasmaman/belt(src)
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/red(src)
	new /obj/item/radio/sec(src)

/obj/item/storage/box/survival/security/vox
	icon_state = "box_sec_vox"
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
	icon_state = "box_pro"

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
		if(H.mind?.assigned_role == "Magistrate")
			icon_state = "[icon_state]_mag"

/obj/item/storage/box/survival/procedure/machine
	name = "IPC maintenance kit"
	icon_state = "box_pro_machine"
	target_species = "Machine"

/obj/item/storage/box/survival/procedure/machine/populate_contents()
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/pink(src)
	new /obj/item/book/manual/security_space_law(src)
	new /obj/item/taperecorder(src)
	new /obj/item/camera(src)

/obj/item/storage/box/survival/procedure/plasmaman
	icon_state = "box_pro_plasma"
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
	icon_state = "box_pro_vox"
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
	w_class_override = list(/obj/item/clothing/mask/gas/syndicate)

/obj/item/storage/box/survival/syndicate/populate_contents()
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/reagent_containers/food/pill/initropidril(src)
	new /obj/item/flashlight/flare/glowstick/red(src)

/obj/item/storage/box/survival/syndicate/machine
	name = "IPC maintenance kit"
	icon_state = "box_syndi_machine"
	target_species = "Machine"

/obj/item/storage/box/survival/syndicate/machine/populate_contents()
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/circuit_fryer(src)
	new /obj/item/flashlight/flare/glowstick/red(src)

/obj/item/storage/box/survival/syndicate/plasmaman
	icon_state = "box_syndi_plasma"
	target_species = "Plasmaman"

/obj/item/storage/box/survival/syndicate/plasmaman/populate_contents()
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/plasmaman/belt(src)
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/reagent_containers/food/pill/initropidril(src)
	new /obj/item/flashlight/flare/glowstick/red(src)

/obj/item/storage/box/survival/syndicate/vox
	icon_state = "box_syndi_vox"
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
	icon_state = "box_cc"
	storage_slots = 14
	max_combined_w_class = 20
	w_class_override = list(/obj/item/clothing/mask/gas/sechailer)

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
	icon_state = "box_cc_machine"
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
	icon_state = "box_cc_plasma"
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
	icon_state = "box_cc_vox"
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
	w_class_override = list(/obj/item/clothing/mask/gas/sechailer)

/obj/item/storage/box/survival/ert/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/storage/firstaid/crew/combat(src)

/obj/item/storage/box/survival/ert/machine
	name = "IPC maintenance kit"
	icon_state = "box_ert_machine"
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
	icon_state = "box_ert_plasma"
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
	icon_state = "box_ert_vox"
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

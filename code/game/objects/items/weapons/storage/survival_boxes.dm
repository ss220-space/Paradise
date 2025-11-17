/*
 * Survival kits:
 * - Basic survival kit
 * - Species-specific survival kits.
 * - Job-specific survival kits
 *
 * How it works:
 * 1. Create a job-specific survival kit.
 * 2. Change the created survival kit according to species.
 */

// MARK: Base survival box
/obj/item/storage/box/survival
	icon_state = "box_civ"
	var/breathmask = /obj/item/clothing/mask/breath
	var/internals = /obj/item/tank/internals/emergency_oxygen
	var/first_aid = /obj/item/storage/firstaid/crew
	var/glowstick = /obj/item/flashlight/flare/glowstick/blue

/obj/item/storage/box/survival/populate_contents()
	if(breathmask)
		new breathmask(src)
	if(internals)
		new internals(src)
	if(first_aid)
		new first_aid(src)
	if(glowstick)
		new glowstick(src)

//MARK: Job-specific survival boxes
/obj/item/storage/box/survival/brigphys
	icon_state = "box_brigphys"

/obj/item/storage/box/survival/engineer
	icon_state = "box_eng"
	internals = /obj/item/tank/internals/emergency_oxygen/engi

/obj/item/storage/box/survival/survival_mining
	icon_state = "box_min"
	breathmask = /obj/item/clothing/mask/gas/explorer/folded
	internals = /obj/item/tank/internals/emergency_oxygen/engi

/obj/item/storage/box/survival/survival_mining/populate_contents()
	. = ..()
	new /obj/item/crowbar/small(src)
	new /obj/item/stack/medical/bruise_pack/military(src)

/obj/item/storage/box/survival/survival_security
	icon_state = "box_sec"
	breathmask = /obj/item/clothing/mask/gas/sechailer/folded
	internals = /obj/item/tank/internals/emergency_oxygen/engi/sec
	glowstick = /obj/item/flashlight/flare/glowstick/red

/obj/item/storage/box/survival/survival_security/populate_contents()
	. = ..()
	new /obj/item/crowbar/small(src)
	new /obj/item/radio/sec(src)
	new /obj/item/stack/medical/bruise_pack/military(src)

/obj/item/storage/box/survival/survival_security/hos
	icon_state = "box_hos"

/obj/item/storage/box/survival/survival_security/cadet
	icon_state = "box_cadet"

/obj/item/storage/box/survival/survival_security/warden
	icon_state = "box_warden"

/obj/item/storage/box/survival/survival_security/pilot
	icon_state = "box_pilot"

/obj/item/storage/box/survival/survival_security/detective
	icon_state = "box_detective"

/obj/item/storage/box/survival/survival_laws
	icon_state = "box_avd"
	glowstick = /obj/item/flashlight/flare/glowstick/pink

/obj/item/storage/box/survival/survival_laws/populate_contents()
	. = ..()
	new /obj/item/book/manual/security_space_law(src)
	new /obj/item/taperecorder(src)
	new /obj/item/camera(src)

/obj/item/storage/box/survival/survival_laws/magisraka
	icon_state = "box_magisraka"

/obj/item/storage/box/survival/survival_syndi
	icon_state = "box_syndi"
	breathmask = /obj/item/clothing/mask/gas/syndicate
	internals = /obj/item/tank/internals/emergency_oxygen/engi/syndi
	first_aid = null
	glowstick = /obj/item/flashlight/flare/glowstick/red

/obj/item/storage/box/survival/survival_syndi/populate_contents()
	. = ..()
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/traneksam(src)
	new /obj/item/reagent_containers/food/pill/initropidril(src)
	new /obj/item/stack/medical/bruise_pack/military(src)

/obj/item/storage/box/survival/centcomofficer
	name = "officer kit"
	icon_state = "box_ert"
	storage_slots = 14
	max_combined_w_class = 20
	breathmask = /obj/item/clothing/mask/gas/sechailer/folded
	internals = /obj/item/tank/internals/emergency_oxygen/double
	first_aid = null
	glowstick = null

/obj/item/storage/box/survival/centcomofficer/populate_contents()
	. = ..()
	new /obj/item/flashlight/seclite(src)
	new /obj/item/kitchen/knife/combat(src)

	new /obj/item/radio/centcom(src)
	new /obj/item/door_remote/omni(src)
	new /obj/item/implanter/death_alarm(src)

	new /obj/item/reagent_containers/hypospray/combat/nanites(src)
	new /obj/item/pinpointer(src)
	new /obj/item/pinpointer/crew/centcom(src)
	new /obj/item/stack/medical/bruise_pack/military(src)

/obj/item/storage/box/survival/soviet
	name = "boxed survival kit"
	desc = "A standard issue Soviet military survival kit."
	icon_state = "box_soviet"

/obj/item/storage/box/survival/soviet/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/traneksam(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/small(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/reagent_containers/food/pill/patch/synthflesh(src)
	new /obj/item/reagent_containers/food/pill/patch/synthflesh(src)


// MARK: Response team
/obj/item/storage/box/survival/responseteam
	name = "boxed survival kit"
	icon_state = "box_ert"

/obj/item/storage/box/survival/responseteam/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer/folded(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/small(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/stack/medical/bruise_pack/military(src)

// ERT set for trial admins
/obj/item/storage/box/survival/responseteam/amber/commander
	name = "ERT Amber Commander kit"

/obj/item/storage/box/survival/responseteam/amber/commander/populate_contents()
	new /obj/item/clothing/under/rank/centcom_officer/sensor (src)
	new /obj/item/radio/headset/ert/alt/commander (src)
	new /obj/item/card/id/ert/registration/commander (src)
	new /obj/item/pinpointer (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/clothing/shoes/combat (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/suit/armor/vest/ert/command (src)
	new /obj/item/clothing/glasses/hud/skills/sunglasses (src)
	new /obj/item/clothing/mask/gas/sechailer/swat (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/clothing/head/helmet/ert/command (src)
	new /obj/item/storage/backpack/ert/commander/prespawn (src)

/obj/item/storage/backpack/ert/commander/prespawn/populate_contents()
	new /obj/item/storage/box/survival/responseteam (src)
	new /obj/item/restraints/handcuffs (src)
	new /obj/item/storage/lockbox/mindshield (src)
	new /obj/item/flashlight/seclite (src)

/obj/item/storage/box/survival/responseteam/amber/security
	name = "ERT Amber Security kit"

/obj/item/storage/box/survival/responseteam/amber/security/populate_contents()
	new /obj/item/storage/box/survival/responseteam (src)
	new /obj/item/clothing/under/rank/security/sensor (src)
	new /obj/item/storage/belt/security/response_team (src)
	new /obj/item/pda/heads/ert/security (src)
	new /obj/item/card/id/ert/registration/security (src)
	new /obj/item/clothing/shoes/combat (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/suit/armor/vest/ert/security (src)
	new /obj/item/gun/energy/gun/advtaser/sibyl (src)
	new /obj/item/clothing/glasses/hud/security/sunglasses (src)
	new /obj/item/clothing/mask/gas/sechailer/swat (src)
	new /obj/item/clothing/head/helmet/ert/security (src)
	new /obj/item/storage/backpack/ert/security/trialmoment/prespawn (src)

/obj/item/storage/backpack/ert/security/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/box/survival/responseteam (src)
	new /obj/item/storage/box/zipties (src)
	new /obj/item/storage/box/teargas (src)
	new /obj/item/flashlight/seclite (src)
	new /obj/item/gun/energy/laser/sibyl (src)

/obj/item/storage/box/survival/responseteam/amber/medic
	name = "ERT Amber Medic kit"

/obj/item/storage/box/survival/responseteam/amber/medic/populate_contents()
	new /obj/item/clothing/under/rank/medical (src)
	new /obj/item/pda/heads/ert/medical (src)
	new /obj/item/card/id/ert/registration/medic (src)
	new /obj/item/clothing/shoes/white (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/suit/armor/vest/ert/medical (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/clothing/glasses/hud/health/sunglasses (src)
	new /obj/item/clothing/head/helmet/ert/medical (src)
	new /obj/item/clothing/mask/surgical (src)
	new /obj/item/storage/belt/medical/surgery/loaded (src)
	new /obj/item/reagent_containers/hypospray/safety/ert (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/defibrillator/loaded (src)
	new /obj/item/storage/backpack/ert/medical/trialmoment/prespawn (src)
	new /obj/item/storage/firstaid/adv (src)
	new /obj/item/storage/firstaid/regular (src)
	new /obj/item/storage/pill_bottle/ert (src)
	new /obj/item/flashlight/seclite (src)

/obj/item/storage/backpack/ert/engineer/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/firstaid/adv (src)
	new /obj/item/storage/firstaid/regular (src)
	new /obj/item/storage/box/autoinjectors (src)
	new /obj/item/roller/holo (src)
	new /obj/item/storage/pill_bottle/ert (src)
	new /obj/item/flashlight/seclite (src)
	new /obj/item/healthanalyzer/advanced (src)
	new /obj/item/handheld_defibrillator (src)

/obj/item/storage/box/survival/responseteam/amber/engineer
	name = "ERT Amber Engineer kit"

/obj/item/storage/box/survival/responseteam/amber/engineer/populate_contents()
	new /obj/item/clothing/under/rank/engineer (src)
	new /obj/item/storage/belt/utility/full/multitool (src)
	new /obj/item/pda/heads/ert/engineering (src)
	new /obj/item/card/id/ert/registration/engineering (src)
	new /obj/item/clothing/shoes/magboots (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/engineer (src)
	new /obj/item/tank/internals/emergency_oxygen/engi (src)
	new /obj/item/clothing/glasses/meson/night (src)
	new /obj/item/clothing/mask/gas (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/storage/backpack/ert/engineer/trialmoment/prespawn (src)

/obj/item/storage/backpack/ert/engineer/prespawn/trialmoment/populate_contents()
	new /obj/item/storage/box/survival/responseteam (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/t_scanner (src)
	new /obj/item/stack/sheet/glass/fifty (src)
	new /obj/item/stack/sheet/metal/fifty (src)
	new /obj/item/rpd (src)
	new /obj/item/flashlight (src)

/obj/item/storage/box/survival/responseteam/amber/janitor
	name = "ERT Amber Janitor kit"

/obj/item/storage/box/survival/responseteam/amber/janitor/populate_contents()
	new /obj/item/clothing/under/color/purple/sensor (src)
	new /obj/item/storage/belt/janitor/ert (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/shoes/galoshes (src)
	new /obj/item/radio/headset/ert/alt (src)
	new /obj/item/card/id/ert/registration/janitor (src)
	new /obj/item/pda/centcom (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/clothing/suit/armor/vest/ert/janitor (src)
	new /obj/item/clothing/head/helmet/ert/janitor (src)
	new /obj/item/clothing/glasses/sunglasses (src)
	new /obj/item/storage/backpack/ert/janitor/trialmoment/prespawn (src)

/obj/item/storage/backpack/ert/janitor/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/box/survival/responseteam (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/grenade/chem_grenade/antiweed (src)
	new /obj/item/grenade/chem_grenade/antiweed (src)
	new /obj/item/reagent_containers/spray/cleaner (src)
	new /obj/item/storage/bag/trash (src)
	new /obj/item/storage/box/lights/mixed (src)
	new /obj/item/holosign_creator/janitor (src)
	new /obj/item/flashlight (src)
	new /obj/item/melee/flyswatter (src)

/obj/item/storage/box/survival/responseteam/red/commander
	name = "ERT Red Commander kit"

/obj/item/storage/box/survival/responseteam/red/commander/populate_contents()
	new /obj/item/clothing/under/rank/centcom_officer/sensor (src)
	new /obj/item/radio/headset/ert/alt/commander (src)
	new /obj/item/card/id/ert/registration/commander (src)
	new /obj/item/pinpointer (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/clothing/shoes/combat (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/commander (src)
	new /obj/item/clothing/glasses/sunglasses (src)
	new /obj/item/clothing/mask/gas/sechailer/swat (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/gun/projectile/automatic/pistol/sp8/sp8t (src)
	new /obj/item/storage/backpack/ert/commander/trialmoment/prespawn (src)

/obj/item/storage/backpack/ert/commander/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/box/survival/responseteam (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/camera_bug/ert (src)
	new /obj/item/door_remote/omni (src)
	new /obj/item/restraints/handcuffs (src)
	new /obj/item/clothing/shoes/magboots (src)
	new /obj/item/storage/lockbox/mindshield (src)
	new/obj/item/implanter/mindshield/ert (src)
	new/obj/item/implanter/death_alarm (src)

/obj/item/storage/box/survival/responseteam/red/security
	name = "ERT Red Security kit"

/obj/item/storage/box/survival/responseteam/red/security/populate_contents()
	new /obj/item/clothing/under/rank/security/sensor (src)
	new /obj/item/storage/belt/security/response_team (src)
	new /obj/item/pda/heads/ert/security (src)
	new /obj/item/card/id/ert/registration/security (src)
	new /obj/item/clothing/shoes/combat (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/security (src)
	new /obj/item/gun/projectile/automatic/lasercarbine (src)
	new /obj/item/clothing/glasses/night (src)
	new /obj/item/clothing/mask/gas/sechailer/swat (src)
	new /obj/item/storage/backpack/ert/security/trialmoment/prespawn (src)

/obj/item/storage/backpack/ert/security/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/box/survival/responseteam (src)
	new	/obj/item/gun/projectile/automatic/pistol/sp8/sp8t (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/clothing/shoes/magboots (src)
	new /obj/item/storage/box/handcuffs (src)
	new /obj/item/grenade/flashbang (src)
	new /obj/item/grenade/flashbang (src)
	new/obj/item/ammo_box/magazine/laser (src)
	new/obj/item/ammo_box/magazine/laser (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/implanter/mindshield/ert (src)
	new /obj/item/implanter/death_alarm (src)

/obj/item/storage/box/survival/responseteam/red/engineer
	name = "ERT Red Engineer kit"

/obj/item/storage/box/survival/responseteam/red/engineer/populate_contents()
	new /obj/item/clothing/under/rank/engineer (src)
	new /obj/item/pda/heads/ert/engineering (src)
	new /obj/item/card/id/ert/registration/engineering (src)
	new /obj/item/clothing/shoes/magboots/advance (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/storage/belt/utility/chief/full (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/engineer (src)
	new /obj/item/tank/internals/emergency_oxygen/engi (src)
	new /obj/item/clothing/glasses/meson/night (src)
	new /obj/item/clothing/mask/gas (src)
	new /obj/item/t_scanner/extended_range (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/storage/backpack/ert/engineer/trialmoment/prespawn (src)

/obj/item/storage/backpack/ert/engineer/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/box/survival/responseteam (src)
	new /obj/item/gun/projectile/automatic/pistol/sp8/sp8t (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/rcd/preloaded (src)
	new /obj/item/rcd_ammo (src)
	new /obj/item/rcd_ammo (src)
	new /obj/item/rcd_ammo (src)
	new /obj/item/rpd (src)
	new /obj/item/gun/energy/gun/sibyl (src)
	new /obj/item/implanter/mindshield/ert (src)
	new /obj/item/implanter/death_alarm (src)

/obj/item/storage/box/survival/responseteam/red/medic
	name = "ERT Red Medic kit"

/obj/item/storage/box/survival/responseteam/red/medic/populate_contents()
	new /obj/item/clothing/under/rank/medical (src)
	new /obj/item/pda/heads/ert/medical (src)
	new /obj/item/card/id/ert/registration/medic (src)
	new /obj/item/clothing/shoes/white (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/medical (src)
	new /obj/item/clothing/glasses/hud/health/sunglasses (src)
	new /obj/item/gun/energy/gun/sibyl (src)
	new /obj/item/defibrillator/compact/loaded (src)
	new /obj/item/reagent_containers/hypospray/safety/ert (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/storage/backpack/ert/medical/trialmoment/prespawn (src)

/obj/item/storage/backpack/ert/medical/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/box/survival/responseteam (src)
	new /obj/item/gun/projectile/automatic/pistol/sp8/sp8t (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/storage/firstaid/ertm (src)
	new /obj/item/clothing/mask/surgical (src)
	new /obj/item/storage/firstaid/toxin (src)
	new /obj/item/storage/firstaid/brute (src)
	new /obj/item/storage/firstaid/fire (src)
	new /obj/item/storage/box/autoinjectors (src)
	new /obj/item/roller/holo (src)
	new /obj/item/clothing/shoes/magboots (src)
	new /obj/item/bodyanalyzer (src)
	new /obj/item/healthanalyzer/advanced (src)
	new /obj/item/handheld_defibrillator (src)
	new /obj/item/implanter/mindshield/ert (src)
	new /obj/item/implanter/death_alarm (src)

/obj/item/storage/box/survival/responseteam/red/janitor
	name = "ERT red Janitor kit"

/obj/item/storage/box/survival/responseteam/red/janitor/populate_contents()
	new	/obj/item/clothing/under/color/purple/sensor (src)
	new /obj/item/storage/belt/janitor/ert (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/shoes/galoshes (src)
	new /obj/item/radio/headset/ert/alt (src)
	new /obj/item/card/id/ert/registration/janitor (src)
	new /obj/item/pda/centcom (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/janitor
	new /obj/item/clothing/glasses/hud/security/sunglasses
	new /obj/item/scythe/tele
	new /obj/item/storage/backpack/ert/janitor/trialmoment/prespawn(src)

/obj/item/storage/backpack/ert/janitor/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/box/survival/responseteam (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/grenade/chem_grenade/antiweed (src)
	new /obj/item/grenade/chem_grenade/antiweed (src)
	new /obj/item/reagent_containers/spray/cleaner (src)
	new /obj/item/storage/bag/trash (src)
	new /obj/item/storage/box/lights/mixed (src)
	new /obj/item/holosign_creator/janitor (src)
	new /obj/item/flashlight (src)
	new /obj/item/melee/flyswatter (src)
	new /obj/item/gun/projectile/automatic/pistol/sp8/sp8t (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/implanter/mindshield/ert (src)
	new /obj/item/implanter/death_alarm (src)


//MARK: Species-specific survival boxes
/obj/item/storage/box/survival/species/populate_contents()
	. = ..()
	create_species_specific_items(src)

/obj/item/storage/box/survival/species/proc/create_species_specific_items(obj/item/storage/box/place)
	return // Add here species specific items to add after create job specific.

/obj/item/storage/box/survival/species/unathi
	first_aid = /obj/item/storage/firstaid/crew/unathi

/obj/item/storage/box/survival/species/vox
	icon_state = "box_vox"
	breathmask = /obj/item/clothing/mask/breath/vox
	internals = /obj/item/tank/internals/emergency_oxygen/nitrogen

/obj/item/storage/box/survival/species/machine
	icon_state = "box_machine"
	breathmask = null
	internals = null
	first_aid = null

/obj/item/storage/box/survival/species/machine/create_species_specific_items(obj/item/storage/box/place)
	new /obj/item/weldingtool/mini(place)
	new /obj/item/stack/cable_coil/random(place)

/obj/item/storage/box/survival/species/nucleation
	icon_state = "box_nucleation"
	breathmask = null
	internals = null
	first_aid = /obj/item/storage/firstaid/crew/nucleation

/obj/item/storage/box/survival/species/plasmaman
	icon_state = "box_plasma"
	internals = /obj/item/tank/internals/emergency_oxygen/plasma

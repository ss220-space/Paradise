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

/obj/item/storage/box/survival/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

//MARK: Job-specific survival boxes
/obj/item/storage/box/survival_unathi
	icon_state = "box_civ"

/obj/item/storage/box/survival_unathi/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/storage/firstaid/crew/unathi(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/brigphys
	icon_state = "box_brigphys"

/obj/item/storage/box/survival_vox
	icon_state = "box_vox"

/obj/item/storage/box/survival_vox/populate_contents()
	new /obj/item/clothing/mask/breath/vox(src)
	new /obj/item/tank/internals/emergency_oxygen/nitrogen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival_machine
	icon_state = "box_machine"

/obj/item/storage/box/survival_machine/populate_contents()
	new /obj/item/weldingtool/mini(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival_nucleation
	icon_state = "box_nucleation"

/obj/item/storage/box/survival_nucleation/populate_contents()
	new /obj/item/storage/firstaid/crew/nucleation(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival_plasmaman
	icon_state = "box_plasma"

/obj/item/storage/box/survival_plasmaman/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/plasma(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/engineer
	icon_state = "box_eng"

/obj/item/storage/box/engineer/populate_contents()
	new /obj/item/clothing/mask/breath( src )
	new /obj/item/tank/internals/emergency_oxygen/engi( src )
	new /obj/item/storage/firstaid/crew( src )
	new /obj/item/flashlight/flare/glowstick/blue( src )
	return

/obj/item/storage/box/survival_mining
	icon_state = "box_min"

/obj/item/storage/box/survival_mining/populate_contents()
	new /obj/item/clothing/mask/gas/explorer/folded(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/crowbar/small(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)
	new /obj/item/stack/medical/bruise_pack/military(src)

/obj/item/storage/box/survival_security
	icon_state = "box_sec"

/obj/item/storage/box/survival_security/populate_contents()
	new /obj/item/tank/internals/emergency_oxygen/engi/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/red(src)
	new /obj/item/crowbar/small(src)
	new /obj/item/clothing/mask/gas/sechailer/folded(src)
	new /obj/item/radio/sec(src)
	new /obj/item/stack/medical/bruise_pack/military(src)

/obj/item/storage/box/survival_security/hos
	icon_state = "box_hos"

/obj/item/storage/box/survival_security/cadet
	icon_state = "box_cadet"

/obj/item/storage/box/survival_security/warden
	icon_state = "box_warden"

/obj/item/storage/box/survival_security/pilot
	icon_state = "box_pilot"

/obj/item/storage/box/survival_security/detective
	icon_state = "box_detective"

/obj/item/storage/box/survival_laws
	icon_state = "box_avd"

/obj/item/storage/box/survival_laws/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/pink(src)
	new /obj/item/book/manual/security_space_law(src)
	new /obj/item/taperecorder(src)
	new /obj/item/camera(src)

/obj/item/storage/box/survival_laws/magisraka
	icon_state = "box_magisraka"

/obj/item/storage/box/survival_syndi
	icon_state = "box_syndi"

/obj/item/storage/box/survival_syndi/populate_contents()
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/traneksam(src)
	new /obj/item/reagent_containers/food/pill/initropidril(src)
	new /obj/item/flashlight/flare/glowstick/red(src)
	new /obj/item/stack/medical/bruise_pack/military(src)


// MARK: Centcom shits
/obj/item/storage/box/centcomofficer
	name = "officer kit"
	icon_state = "box_ert"
	storage_slots = 14
	max_combined_w_class = 20

/obj/item/storage/box/centcomofficer/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer/folded(src)
	new /obj/item/tank/internals/emergency_oxygen/double(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/kitchen/knife/combat(src)

	new /obj/item/radio/centcom(src)
	new /obj/item/door_remote/omni(src)
	new /obj/item/implanter/death_alarm(src)

	new /obj/item/reagent_containers/hypospray/combat/nanites(src)
	new /obj/item/pinpointer(src)
	new /obj/item/pinpointer/crew/centcom(src)
	new /obj/item/stack/medical/bruise_pack/military(src)

/obj/item/storage/box/responseteam
	name = "boxed survival kit"
	icon_state = "box_ert"

/obj/item/storage/box/responseteam/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer/folded(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/small(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/stack/medical/bruise_pack/military(src)

// ERT set for trial admins
/obj/item/storage/box/responseteam/amber/commander
	name = "ERT Amber Commander kit"

/obj/item/storage/box/responseteam/amber/commander/populate_contents()
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
	new /obj/item/storage/box/responseteam (src)
	new /obj/item/restraints/handcuffs (src)
	new /obj/item/storage/lockbox/mindshield (src)
	new /obj/item/flashlight/seclite (src)

/obj/item/storage/box/responseteam/amber/security
	name = "ERT Amber Security kit"

/obj/item/storage/box/responseteam/amber/security/populate_contents()
	new /obj/item/storage/box/responseteam (src)
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
	new /obj/item/storage/box/responseteam (src)
	new /obj/item/storage/box/zipties (src)
	new /obj/item/storage/box/teargas (src)
	new /obj/item/flashlight/seclite (src)
	new /obj/item/gun/energy/laser/sibyl (src)

/obj/item/storage/box/responseteam/amber/medic
	name = "ERT Amber Medic kit"

/obj/item/storage/box/responseteam/amber/medic/populate_contents()
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

/obj/item/storage/box/responseteam/amber/engineer
	name = "ERT Amber Engineer kit"

/obj/item/storage/box/responseteam/amber/engineer/populate_contents()
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
	new /obj/item/storage/box/responseteam (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/t_scanner (src)
	new /obj/item/stack/sheet/glass/fifty (src)
	new /obj/item/stack/sheet/metal/fifty (src)
	new /obj/item/rpd (src)
	new /obj/item/flashlight (src)

/obj/item/storage/box/responseteam/amber/janitor
	name = "ERT Amber Janitor kit"

/obj/item/storage/box/responseteam/amber/janitor/populate_contents()
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
	new /obj/item/storage/box/responseteam (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/grenade/chem_grenade/antiweed (src)
	new /obj/item/grenade/chem_grenade/antiweed (src)
	new /obj/item/reagent_containers/spray/cleaner (src)
	new /obj/item/storage/bag/trash (src)
	new /obj/item/storage/box/lights/mixed (src)
	new /obj/item/holosign_creator/janitor (src)
	new /obj/item/flashlight (src)
	new /obj/item/melee/flyswatter (src)

/obj/item/storage/box/responseteam/red/commander
	name = "ERT Red Commander kit"

/obj/item/storage/box/responseteam/red/commander/populate_contents()
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
	new /obj/item/storage/box/responseteam (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/camera_bug/ert (src)
	new /obj/item/door_remote/omni (src)
	new /obj/item/restraints/handcuffs (src)
	new /obj/item/clothing/shoes/magboots (src)
	new /obj/item/storage/lockbox/mindshield (src)
	new/obj/item/implanter/mindshield/ert (src)
	new/obj/item/implanter/death_alarm (src)

/obj/item/storage/box/responseteam/red/security
	name = "ERT Red Security kit"

/obj/item/storage/box/responseteam/red/security/populate_contents()
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
	new /obj/item/storage/box/responseteam (src)
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

/obj/item/storage/box/responseteam/red/engineer
	name = "ERT Red Engineer kit"

/obj/item/storage/box/responseteam/red/engineer/populate_contents()
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
	new /obj/item/storage/box/responseteam (src)
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

/obj/item/storage/box/responseteam/red/medic
	name = "ERT Red Medic kit"

/obj/item/storage/box/responseteam/red/medic/populate_contents()
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
	new /obj/item/storage/box/responseteam (src)
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

/obj/item/storage/box/responseteam/red/janitor
	name = "ERT red Janitor kit"

/obj/item/storage/box/responseteam/red/janitor/populate_contents()
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
	new /obj/item/storage/box/responseteam (src)
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

/obj/item/storage/box/hardsuit
	icon_state = "box_ert"
	storage_slots = 3

/obj/item/storage/box/hardsuit/engineering/response_team
	name = "Boxed engineer response team hardsuit kit"

/obj/item/storage/box/hardsuit/engineering/response_team/populate_contents()
	new /obj/item/clothing/mask/breath (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/engineer (src)
	new /obj/item/tank/internals/emergency_oxygen (src)

/obj/item/storage/box/hardsuit/engineering
	name = "Boxed engineering hardsuit kit"

/obj/item/storage/box/hardsuit/engineering/populate_contents()
	new /obj/item/clothing/mask/breath (src)
	new /obj/item/clothing/suit/space/hardsuit/engine (src)
	new /obj/item/tank/internals/emergency_oxygen (src)

/obj/item/storage/box/hardsuit/medical/responseteam
	name = "Boxed medical response team hardsuit kit"

/obj/item/storage/box/hardsuit/medical/populate_contents()
	new /obj/item/clothing/mask/breath (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/medical (src)
	new /obj/item/tank/internals/emergency_oxygen (src)

/obj/item/storage/box/hardsuit/medical
	name = "Boxed medical hardsuit kit"

/obj/item/storage/box/medical/populate_contents()
	new /obj/item/clothing/mask/breath (src)
	new /obj/item/clothing/suit/space/hardsuit/medical (src)
	new /obj/item/tank/internals/emergency_oxygen (src)

/obj/item/storage/box/hardsuit/janitor/response_team
	name = "Boxed janitor response team hardsuit kit"

/obj/item/storage/box/hardsuit/janitor/response_team/populate_contents()
	new /obj/item/clothing/mask/breath (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/janitor (src)
	new /obj/item/tank/internals/emergency_oxygen (src)

/obj/item/storage/box/soviet
	name = "boxed survival kit"
	desc = "A standard issue Soviet military survival kit."
	icon_state = "box_soviet"

/obj/item/storage/box/soviet/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/traneksam(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/small(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/reagent_containers/food/pill/patch/synthflesh(src)
	new /obj/item/reagent_containers/food/pill/patch/synthflesh(src)

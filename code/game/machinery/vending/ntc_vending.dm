/obj/machinery/vending/ntc
	req_access = list(ACCESS_CENT_GENERAL)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta

	icon_state = "nta_base"
	panel_overlay = "nta_panel"
	screen_overlay = "nta"
	lightmask_overlay = "nta_lightmask"
	broken_overlay = "nta_broken"
	broken_lightmask_overlay = "nta_lightmask"
	vend_overlay = "nta_vend"
	deny_overlay = "nta_deny"
	vend_overlay_time = 3 SECONDS

/obj/machinery/vending/ntc/update_overlays()
	. = list()

	underlays.Cut()

	. += base_icon_state

	if(panel_open)
		. += "nta_panel"

	if((stat & NOPOWER) || force_no_power_icon_state)
		. += "nta_off"
		return

	if(stat & BROKEN)
		. += "nta_broken"
	else
		if(flick_sequence & FLICK_VEND)
			. += vend_overlay

		else if(flick_sequence & FLICK_DENY)
			. += deny_overlay

	underlays += emissive_appearance(icon, "nta_lightmask", src)

/obj/machinery/vending/ntc/medal
	name = "NT Cargo Encouragement"
	desc = "A encourage vendor with many of medal types."
	icon = 'icons/obj/storage.dmi'
	icon_state = "medalbox"
	products = list(
		/obj/item/clothing/accessory/medal = 5,
		/obj/item/clothing/accessory/medal/engineering = 5,
		/obj/item/clothing/accessory/medal/security = 5,
		/obj/item/clothing/accessory/medal/science = 5,
		/obj/item/clothing/accessory/medal/service = 5,
		/obj/item/clothing/accessory/medal/medical = 5,
		/obj/item/clothing/accessory/medal/legal = 5,
		/obj/item/clothing/accessory/medal/silver = 5,
		/obj/item/clothing/accessory/medal/silver/leadership = 5,
		/obj/item/clothing/accessory/medal/silver/valor = 5,
		/obj/item/clothing/accessory/medal/gold = 5,
		/obj/item/clothing/accessory/medal/gold/heroism = 5
	)

/obj/machinery/vending/ntc/medical
	name = "NT Cargo Medical Gear"
	desc = "A some medical equipment vendor for cargo."

	icon_state = "nta_base"
	base_icon_state = "nta-medical"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-medical_deny"

	products = list(
		/obj/item/storage/box/hardsuit/medical/responseteam = 10,
		/obj/item/storage/box/hardsuit/medical = 10,
		/obj/item/clothing/glasses/hud/health/night = 10,
		/obj/item/bodyanalyzer/advanced = 10,
		/obj/item/storage/firstaid/tactical = 10,
		/obj/item/gun/medbeam = 10,
		/obj/item/defibrillator/compact/loaded = 10,
		/obj/item/handheld_defibrillator = 10,
		/obj/item/vending_refill/medical = 10)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/ntc/engineering
	name = "NT Cargo Engineering Gear"
	desc = "A some engineering equipment vendor for cargo."

	icon_state = "nta_base"
	base_icon_state = "nta-engi"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-engi_deny"

	products = list(
		/obj/item/storage/box/hardsuit/engineering/response_team = 10,
		/obj/item/storage/box/hardsuit/engineering = 10,
		/obj/item/clothing/glasses/meson/sunglasses = 10,
		/obj/item/clothing/gloves/color/yellow = 10,
		/obj/item/storage/belt/utility/chief/full = 10,
		/obj/item/rcd/combat = 10,
		/obj/item/rcd_ammo/large = 20,
		/obj/item/grenade/chem_grenade/metalfoam = 30
	)

/obj/machinery/vending/ntc/janitor
	name = "NT Cargo Janitor Gear"
	desc = "A some janitor equipment vendor for cargo."

	icon_state = "nta_base"
	base_icon_state = "nta-janitor"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-janitor_deny"

	products = list(
		/obj/item/storage/box/hardsuit/janitor/response_team = 10,
		/obj/item/storage/belt/janitor/ert = 10,
		/obj/item/clothing/shoes/galoshes = 10,
		/obj/item/reagent_containers/spray/cleaner = 20,
		/obj/item/watertank/janitor = 10,
		/obj/item/soap/ert = 10,
		/obj/item/storage/bag/trash/bluespace = 10,
		/obj/item/lightreplacer/bluespace = 10,
		/obj/item/scythe/tele = 20,
		/obj/item/grenade/chem_grenade/cleaner = 30,
		/obj/item/grenade/clusterbuster/cleaner = 30,
		/obj/item/grenade/chem_grenade/antiweed = 30,
		/obj/item/grenade/clusterbuster/antiweed = 30
	)

/obj/machinery/vending/ntcrates
	name = "NT Cargo Preset Gear"
	desc = "A already preset of equipments vendor for cargo."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta

	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "magivend_off"
	panel_overlay = "magivend_panel"
	screen_overlay = "magivend"
	lightmask_overlay = "magivend_lightmask"
	broken_overlay = "magivend_broken"
	broken_lightmask_overlay = "magivend_broken_lightmask"

	products = list(
		/obj/structure/closet/crate/trashcart/NTdelivery = 100,
		/obj/structure/closet/crate/secure/gear = 100,
		/obj/structure/closet/crate/secure/weapon = 100,
		/obj/item/storage/backpack/duffel/security/riot = 100,
		/obj/item/storage/backpack/duffel/security/war = 100,
		/obj/item/storage/backpack/duffel/hydro/weed = 100,
		/obj/item/storage/backpack/duffel/security/spiders = 100,
		/obj/item/storage/backpack/duffel/security/blob = 100,
		/obj/item/storage/backpack/duffel/engineering/building_event = 100
	)

/obj/machinery/vending/ntc/ert
	name = "NT Response Team Base Gear"
	desc = "A ERT Base equipment vendor"

	icon_state = "nta_base"
	base_icon_state = "nta-blue"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-blue_deny"

	products = list(
		/obj/item/storage/box/responseteam/amber/commander = 100,
		/obj/item/storage/box/responseteam/amber/security = 100,
		/obj/item/storage/box/responseteam/amber/engineer = 100,
		/obj/item/storage/box/responseteam/amber/medic = 100,
		/obj/item/storage/box/responseteam/amber/janitor = 100,
		/obj/item/storage/box/responseteam/red/commander = 100,
		/obj/item/storage/box/responseteam/red/security = 100,
		/obj/item/storage/box/responseteam/red/engineer = 100,
		/obj/item/storage/box/responseteam/red/medic = 100,
		/obj/item/storage/box/responseteam/red/janitor = 100)

/obj/machinery/vending/ntc_resources
	name = "NT Matter Сompression Vendor"
	desc = "Its vendor use advanced technology of matter compression and can have a many volume of resources."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta

	icon_state = "engi_off"
	panel_overlay = "engi_panel"
	screen_overlay = "engi"
	lightmask_overlay = "engi_lightmask"
	broken_overlay = "engi_broken"
	broken_lightmask_overlay = "engi_broken_lightmask"
	deny_overlay = "engi_deny"
	deny_lightmask = "engi_deny_lightmask"

	products = list(/obj/item/stack/sheet/mineral/diamond/fifty = 50,
		/obj/item/stack/sheet/mineral/gold/fifty = 50,
		/obj/item/stack/sheet/glass/fifty = 50,
		/obj/item/stack/sheet/metal/fifty = 50,
		/obj/item/stack/sheet/mineral/plasma/fifty = 50,
		/obj/item/stack/sheet/mineral/silver/fifty = 50,
		/obj/item/stack/sheet/mineral/titanium/fifty = 50,
		/obj/item/stack/sheet/mineral/uranium/fifty = 50)
	contraband = list(/obj/item/stack/sheet/mineral/tranquillite/fifty = 50,
		/obj/item/stack/sheet/mineral/bananium/fifty = 50,
		/obj/item/stack/sheet/mineral/sandstone/fifty = 50,
		/obj/item/stack/sheet/mineral/abductor/fifty = 50)

/obj/machinery/vending/mech/ntc
	icon = 'icons/obj/machines/vending.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/mech/ntc/exousuit
	name = "NT Exosuit Bluespace Transporter"
	desc = "Fabricator with advanced technology of bluespace transporting of resources."
	icon = 'icons/obj/machines/robotics.dmi'
	icon_state = "fab-idle"
	products = list(
		/obj/mecha/combat/durand = 10,
		/obj/mecha/combat/gygax = 10,
		/obj/mecha/combat/phazon = 10,
		/obj/mecha/medical/odysseus = 10,
		/obj/mecha/working/ripley = 10,
		/obj/mecha/working/ripley/firefighter = 10,
		/obj/mecha/working/clarke = 10)

/obj/machinery/vending/mech/ntc/equipment
	name = "NT Exosuit Bluespace Transporter"
	desc = "Fabricator with advanced technology of bluespace transporting of resources."

	icon_state = "engivend_off"
	panel_overlay = "engivend_panel"
	screen_overlay = "engivend"
	lightmask_overlay = "engivend_lightmask"
	broken_overlay = "engivend_broken"
	broken_lightmask_overlay = "engivend_broken_lightmask"
	deny_overlay = "engivend_deny"

	products = list(
		/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster = 10,
		/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster = 10,
		/obj/item/mecha_parts/mecha_equipment/repair_droid = 10,
		/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay = 10,
		/obj/item/mecha_parts/mecha_equipment/generator/nuclear = 10
	)

/obj/machinery/vending/mech/ntc/weapon
	name = "NT Exosuit Bluespace Transporter"
	desc = "Fabricator with advanced technology of bluespace transporting of resources."

	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "liberationstation_off"
	panel_overlay = "liberationstation_panel"
	screen_overlay = "liberationstation"
	lightmask_overlay = "liberationstation_lightmask"
	broken_overlay = "liberationstation_broken"
	broken_lightmask_overlay = "liberationstation_broken_lightmask"

	products = list(
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/dual = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/medium = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/heavy = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/amlg = 10,
	)

/obj/machinery/vending/mech/ntc/tools
	name = "NT Exosuit Bluespace Transporter"
	desc = "Fabricator with advanced technology of bluespace transporting of resources."

	icon_state = "tool_off"
	panel_overlay = "tool_panel"
	screen_overlay = "tool"
	lightmask_overlay = "tool_lightmask"
	broken_overlay = "tool_broken"
	broken_lightmask_overlay = "tool_broken_lightmask"
	deny_overlay = "tool_deny"

	products = list(/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp = 10,
		/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill = 10,
		/obj/item/mecha_parts/mecha_equipment/mining_scanner = 10,
		/obj/item/mecha_parts/mecha_equipment/rcd = 10,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma = 10,
		/obj/item/mecha_parts/mecha_equipment/extinguisher = 10,
		/obj/item/mecha_parts/mecha_equipment/cable_layer = 10,
		/obj/item/mecha_parts/mecha_equipment/wormhole_generator = 10,
	)


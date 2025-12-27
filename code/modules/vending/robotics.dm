/obj/machinery/vending/robotics
	name = "Robotech Deluxe"
	desc = "Все, что вам нужно для создания вашей собственной армии роботов."
	icon_state = "robotics_off"
	panel_overlay = "robotics_panel"
	screen_overlay = "robotics"
	lightmask_overlay = "robotics_lightmask"
	broken_overlay = "robotics_broken"
	broken_lightmask_overlay = "robotics_broken_lightmask"
	deny_overlay = "robotics_deny"
	deny_lightmask = "robotics_deny_lightmask"
	req_access = list(ACCESS_ROBOTICS)
	refill_canister = /obj/item/vending_refill/robotics
	default_price = PAYCHECK_LOWER
	default_premium_price = PAYCHECK_CREW

	products = list(
		/obj/item/clothing/suit/storage/labcoat = 4,
		/obj/item/clothing/under/rank/roboticist = 4,
		/obj/item/stack/cable_coil = 4,
		/obj/item/flash = 4,
		/obj/item/stock_parts/cell/high = 12,
		/obj/item/assembly/prox_sensor = 3,
		/obj/item/assembly/signaler = 3,
		/obj/item/healthanalyzer = 3,
		/obj/item/scalpel = 2,
		/obj/item/circular_saw = 2,
		/obj/item/tank/internals/anesthetic = 2,
		/obj/item/clothing/mask/breath/medical = 5,
		/obj/item/screwdriver = 5,
		/obj/item/crowbar = 5,
	)

/obj/machinery/vending/robotics/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Robotech Deluxe",
		GENITIVE = "торгового автомата Robotech Deluxe",
		DATIVE = "торговому автомату Robotech Deluxe",
		ACCUSATIVE = "торговый автомат Robotech Deluxe",
		INSTRUMENTAL = "торговым автоматом Robotech Deluxe",
		PREPOSITIONAL = "торговом автомате Robotech Deluxe",
	)

/obj/machinery/vending/robotics/nt
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/robotics/nt/durand
	products = list(
		/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay = 3,
		/obj/item/mecha_parts/mecha_equipment/repair_droid = 3,
		/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster = 3,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot = 3,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg = 3,
	)

/obj/machinery/vending/robotics/nt/gygax
	products = list(
		/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay = 3,
		/obj/item/mecha_parts/mecha_equipment/repair_droid = 3,
		/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster = 3,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion = 3,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy = 3,
	)

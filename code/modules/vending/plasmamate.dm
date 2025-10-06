/obj/machinery/vending/plasmamate
	name = "PlasmaMate"
	desc = "Автомат, выдающий снаряжение для плазмолюдов. Бесплатно!"
	icon_state = "plasmavendor_off"
	panel_overlay = "plasmavendor_panel"
	screen_overlay = "plasmavendor_screen"
	broken_overlay = "plasmavendor_broken"
	vend_reply = "Не забыв+айте о безоп+асности при см+ене снаряж+ения!"
	refill_canister = /obj/item/vending_refill/plasma

	products = list(
		/obj/item/storage/lockbox/plasma/captain = 1,
		/obj/item/storage/lockbox/plasma/hos = 1,
		/obj/item/storage/lockbox/plasma/qm = 1,
		/obj/item/storage/lockbox/plasma/cmo = 1,
		/obj/item/storage/lockbox/plasma/rd = 1,
		/obj/item/storage/lockbox/plasma/ce = 1,
		/obj/item/storage/lockbox/plasma/hop = 1,
		/obj/item/storage/lockbox/plasma/barmen = 10,
		/obj/item/storage/lockbox/plasma/nt_rep = 1,
		/obj/item/storage/lockbox/plasma/chef = 10,
		/obj/item/storage/lockbox/plasma/botany = 10,
		/obj/item/storage/lockbox/plasma/librarian = 10,
		/obj/item/storage/lockbox/plasma/janitor = 10,
		/obj/item/storage/lockbox/plasma/sec = 5,
		/obj/item/storage/lockbox/plasma/pilot = 1,
		/obj/item/storage/lockbox/plasma/det = 1,
		/obj/item/storage/lockbox/plasma/warden = 1,
		/obj/item/storage/lockbox/plasma/cargo = 10,
		/obj/item/storage/lockbox/plasma/miner = 5,
		/obj/item/storage/lockbox/plasma/medic = 10,
		/obj/item/storage/lockbox/plasma/brig_med = 5,
		/obj/item/storage/lockbox/plasma/paramedic = 10,
		/obj/item/storage/lockbox/plasma/coroner = 10,
		/obj/item/storage/lockbox/plasma/viro = 10,
		/obj/item/storage/lockbox/plasma/chemist = 10,
		/obj/item/storage/lockbox/plasma/genetic = 10,
		/obj/item/storage/lockbox/plasma/scientist = 10,
		/obj/item/storage/lockbox/plasma/robot = 10,
		/obj/item/storage/lockbox/plasma/engineer = 10,
		/obj/item/storage/lockbox/plasma/mechanic = 5,
		/obj/item/storage/lockbox/plasma/atmos = 1,
		/obj/item/storage/lockbox/plasma/mime = 5,
		/obj/item/storage/lockbox/plasma/clown = 5,
		/obj/item/storage/lockbox/plasma/blueshield = 1,
	)

/obj/machinery/vending/plasmamate/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат PlasmaMate",
		GENITIVE = "торгового автомата PlasmaMate",
		DATIVE = "торговому автомату PlasmaMate",
		ACCUSATIVE = "торговый автомат PlasmaMate",
		INSTRUMENTAL = "торговым автоматом PlasmaMate",
		PREPOSITIONAL = "торговом автомате PlasmaMate"
	)

/obj/machinery/vending/assist
	icon_state = "generic_off"
	panel_overlay = "generic_panel"
	screen_overlay = "generic"
	lightmask_overlay = "generic_lightmask"
	broken_overlay = "generic_broken"
	broken_lightmask_overlay = "generic_broken_lightmask"

	products = list(
		/obj/item/assembly/prox_sensor = 5,/obj/item/assembly/igniter = 3,/obj/item/assembly/signaler = 4,
		/obj/item/wirecutters = 1, /obj/item/cartridge/signal = 4
	)
	contraband = list(/obj/item/flashlight = 5, /obj/item/assembly/timer = 2, /obj/item/assembly/voice = 2, /obj/item/assembly/health = 2)

	slogan_list = list(
		"Т+олько с+амое л+учшее!",
		"Им+еются вс+якие шт+учки.",
		"С+амое над+ёжное обор+удование!",
		"Л+учшее снаряж+ение в к+осмосе!"
	)

	refill_canister = /obj/item/vending_refill/assist

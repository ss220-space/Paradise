/obj/machinery/vending/syndicigs
	name = "Suspicious Cigarette Machine"
	desc = "Кури, раз уж взял."
	slogan_list = list(
		"Космосигар+еты хор+оши на вкус, как+ими он+и и должн+ы быть!",
		"Затян+итесь!",
		"Не в+ерьте иссл+едованиям — кур+ите сег+одня!",
		"Наверняк+а не +очень-то и вр+едно для вас!",
		"Не в+ерьте уч+ёным!",
		"На здор+овье!",
		"Не брос+айте кур+ить, куп+ите ещ+ё!",
		"Затян+итесь!",
		"Никот+иновый рай.",
		"Л+учшие сигар+еты с 2150-го г+ода.",
		"Сигар+еты с мн+ожеством нагр+ад."
	)


	icon_state = "cigs_off"
	panel_overlay = "cigs_panel"
	screen_overlay = "cigs"
	lightmask_overlay = "cigs_lightmask"
	broken_overlay = "cigs_broken"
	broken_lightmask_overlay = "cigs_broken_lightmask"

	products = list(/obj/item/storage/fancy/cigarettes/syndicate = 10,/obj/item/lighter/random = 5)

/obj/machinery/vending/syndicigs/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Suspicious Cigarette Machine",
		GENITIVE = "торгового автомата Suspicious Cigarette Machine",
		DATIVE = "торговому автомату Suspicious Cigarette Machine",
		ACCUSATIVE = "торговый автомат Suspicious Cigarette Machine",
		INSTRUMENTAL = "торговым автоматом Suspicious Cigarette Machine",
		PREPOSITIONAL = "торговом автомате Suspicious Cigarette Machine"
	)

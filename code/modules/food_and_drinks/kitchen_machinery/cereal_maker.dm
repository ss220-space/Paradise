/obj/machinery/cooker/cerealmaker
	name = "cereal maker"
	desc = "Делает хлопья практически из чего угодно. Вкусно, практично, синтетично."
	icon = 'icons/obj/machines/cooking_machines.dmi'
	icon_state = "cereal_off"
	thiscooktype = "хлопья"
	cooktime = 200
	onicon = "cereal_on"
	officon = "cereal_off"

/obj/machinery/cooker/cerealmaker/get_ru_names()
	return list(
		NOMINATIVE = "аппарат для хлопьев",
		GENITIVE = "аппарата для хлопьев",
		DATIVE = "аппарату для хлопьев",
		ACCUSATIVE = "аппарат для хлопьев",
		INSTRUMENTAL = "аппаратом для хлопьев",
		PREPOSITIONAL = "аппарате для хлопьев"
	)

/obj/machinery/cooker/cerealmaker/setIcon(obj/item/copyme, obj/item/copyto)
	var/image/img = new(copyme.icon, copyme.icon_state)
	img.transform *= 0.7
	copyto.add_overlay(img)
	copyto.copy_overlays(copyme)

/obj/machinery/cooker/cerealmaker/changename(obj/item/name, obj/item/setme)
	setme.name = "коробка хлопьев из [name.declent_ru(GENITIVE)]"
	setme.desc = "[name.desc] Оно было переработано в [thiscooktype]."

/obj/machinery/cooker/cerealmaker/gettype()
	var/obj/item/reagent_containers/food/snacks/cereal/type = new(get_turf(src))
	return type

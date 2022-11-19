//===== Drask food =====
//Soap
/obj/item/soap/new_stat_eat()
	. = ..()
	material_type = MATERIAL_CLASS_SOAP
	max_bites = 6
	nutritional_value = 15
	is_only_grab_intent = TRUE

/obj/item/soap/homemade/new_stat_eat()
	. = ..()
	nutritional_value = 30

/obj/item/soap/deluxe/new_stat_eat()
	. = ..()
	nutritional_value = 60

/obj/item/soap/syndie/new_stat_eat()
	. = ..()
	nutritional_value = 100

/obj/item/soap/nanotrasen/new_stat_eat()
	. = ..()
	max_bites = 12
	nutritional_value = 15

/obj/item/soap/ducttape/new_stat_eat()
	. = ..()
	max_bites = 2
	nutritional_value = 10

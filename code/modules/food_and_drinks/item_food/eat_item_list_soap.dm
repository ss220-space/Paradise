//===== Drask food =====
//Soap

/obj/item/soap/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_SOAP, \
	max_bites = 6, \
	nutritional_value = 15, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/soap/homemade/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_SOAP, \
	max_bites = 6, \
	nutritional_value = 30, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/soap/deluxe/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_SOAP, \
	max_bites = 6, \
	nutritional_value = 60, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/soap/syndie/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_SOAP, \
	max_bites = 6, \
	nutritional_value = 100, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/soap/nanotrasen/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_SOAP, \
	max_bites = 12, \
	nutritional_value = 15, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/soap/ducttape/add_eatable_component()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_SOAP, \
	max_bites = 2, \
	nutritional_value = 10, \
	is_only_grab_intent = TRUE, \
	)

//===== Drask food =====
//Soap

/obj/item/soap/homemade/ComponentInitialize()
	AddComponent(/datum/component/slippery, 4 SECONDS, lube_flags = (SLIDE|SLIP_WHEN_LYING))
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_SOAP, \
	max_bites = 6, \
	nutritional_value = 30, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/soap/deluxe/ComponentInitialize()
	AddComponent(/datum/component/slippery, 4 SECONDS, lube_flags = (SLIDE|SLIP_WHEN_LYING))
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_SOAP, \
	max_bites = 6, \
	nutritional_value = 60, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/soap/syndie/ComponentInitialize()
	AddComponent(/datum/component/slippery, 4 SECONDS, lube_flags = (SLIDE|SLIP_WHEN_LYING))
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_SOAP, \
	max_bites = 6, \
	nutritional_value = 100, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/soap/nanotrasen/ComponentInitialize()
	AddComponent(/datum/component/slippery, 4 SECONDS, lube_flags = (SLIDE|SLIP_WHEN_LYING))
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_SOAP, \
	max_bites = 12, \
	nutritional_value = 15, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/soap/ducttape/ComponentInitialize()
	AddComponent(/datum/component/slippery, 4 SECONDS, lube_flags = (SLIDE|SLIP_WHEN_LYING))
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_SOAP, \
	max_bites = 2, \
	nutritional_value = 10, \
	is_only_grab_intent = TRUE, \
	)

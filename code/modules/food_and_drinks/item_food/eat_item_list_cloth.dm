//==== =Moth-Nian-Tkach food =====
/obj/item/clothing/bedsheet/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_CLOTH, \
	max_bites = 10, \
	nutritional_value = 15, \
	)

/obj/item/clothing/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_CLOTH, \
	max_bites = 10, \
	integrity_bite = 20, \
	nutritional_value = 5, \
	)

//UNDER
/obj/item/clothing/under/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_CLOTH, \
	max_bites = 10, \
	integrity_bite = 40, \
	nutritional_value = 10, \
	)


//NECK
/obj/item/clothing/neck/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_CLOTH, \
	max_bites = 8, \
	integrity_bite = 20, \
	nutritional_value = 10, \
	)


//ACCESSORY
/obj/item/clothing/accessory/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_CLOTH, \
	max_bites = 10, \
	integrity_bite = 20, \
	nutritional_value = 5, \
	is_only_grab_intent = TRUE, \
	)


//GLOVES
/obj/item/clothing/gloves/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_CLOTH, \
	max_bites = 2, \
	integrity_bite = 20, \
	nutritional_value = 10, \
	)


//MASK
/obj/item/clothing/mask/bandana/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_CLOTH, \
	max_bites = 4, \
	integrity_bite = 20, \
	nutritional_value = 10, \
	)


//HEAD
/obj/item/clothing/head/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_CLOTH, \
	max_bites = 6, \
	integrity_bite = 20, \
	nutritional_value = 10, \
	)


//SUIT
/obj/item/clothing/suit/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_CLOTH, \
	max_bites = 16, \
	integrity_bite = 20, \
	nutritional_value = 10, \
	)

/obj/item/clothing/suit/hooded/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_CLOTH, \
	max_bites = 20, \
	integrity_bite = 20, \
	nutritional_value = 10, \
	)

/obj/item/clothing/suit/chef/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_CLOTH, \
	max_bites = 8, \
	integrity_bite = 20, \
	nutritional_value = 10, \
	)

/obj/item/clothing/suit/apron/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_CLOTH, \
	max_bites = 8, \
	integrity_bite = 20, \
	nutritional_value = 10, \
	)

/obj/item/clothing/suit/towel/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_CLOTH, \
	max_bites = 12, \
	nutritional_value = 10, \
	integrity_bite = 20, \
	is_only_grab_intent = TRUE, \
	)

/obj/item/clothing/suit/towel/short/ComponentInitialize()
	AddComponent( \
	/datum/component/eatable, \
	material_type = MATERIAL_CLASS_CLOTH, \
	max_bites = 8, \
	nutritional_value = 10, \
	integrity_bite = 20, \
	is_only_grab_intent = TRUE, \
	)

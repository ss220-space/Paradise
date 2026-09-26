/datum/item_skin_data/whistle
	item_path = /obj/item/clothing/mask/whistle
	var/activate_sound

/datum/item_skin_data/whistle/on_apply(obj/item/target)
	. = ..()
	var/obj/item/clothing/mask/whistle/target_whistle = target
	if(istype(target_whistle))
		target_whistle.activate_sound = activate_sound


/datum/item_skin_data/whistle/default
	name = "Обычный свисток"
	icon_state = "whistle"
	activate_sound = 'sound/items/whistle.ogg'

/datum/item_skin_data/whistle/trench
	name = "Свисток тренера"
	icon_state = "whistle2"
	activate_sound = 'sound/items/whistle_trench.ogg'

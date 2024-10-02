/obj/item/clothing/under/punpun
	name = "fancy uniform"
	desc = "It looks like it was tailored for a monkey."
	icon_state = "punpun"
	item_color = "punpun"
	species_restricted = list(SPECIES_MONKEY)

/mob/living/carbon/human/lesser/monkey/punpun/Initialize(mapload)
	. = ..()
	name = "Pun Pun"
	real_name = name
	
	var/obj/item/clothing/under/punpun/prom = new(src)
	var/obj/item/clothing/accessory/petcollar/prom_collar = new(src)
	var/obj/item/card/id/punpun/punpun_id = new(prom_collar)
	prom_collar.access_id = punpun_id
	prom_collar.on_attached(prom, src)
	equip_to_slot_if_possible(prom, ITEM_SLOT_CLOTH_INNER)

	tts_seed = "Chen"

/mob/living/carbon/human/lesser/monkey/punpun/can_use_machinery(obj/machinery/mas)
	. = ..()
	var/static/list/typecache_whitelist = typecacheof(list(
		/obj/machinery/vending,
		/obj/machinery/chem_dispenser/soda,
		/obj/machinery/chem_dispenser/beer,
	))
	if(is_type_in_typecache(mas, typecache_whitelist))
		return TRUE

/mob/living/carbon/human/lesser/monkey/punpun/get_npc_respawn_message()
	return "Вы подчиняетесь Повару, Бармену и ГП. Вам нельзя покидать бар без их разрешения. Ваша задача  развлекать посетителей, обслуживать их и слушаться ваших хозяев."

/mob/living/carbon/human/lesser/monkey/teeny/Initialize(mapload)
	. = ..()
	name = "Mr. Teeny"
	real_name = name
	update_transform(0.8)
	tts_seed = "Chen"

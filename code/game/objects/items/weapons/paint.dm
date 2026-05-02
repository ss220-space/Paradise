//NEVER USE THIS IT SUX	-PETETHEGOAT

/obj/item/reagent_containers/glass/paint
	desc = "Это ведро краски."
	name = "paint bucket"
	icon = 'icons/obj/items.dmi'
	icon_state = "paint_neutral"
	item_state = "paintcan"
	materials = list(MAT_METAL=200)
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	max_integrity = 100
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5,10,20,30,50,70)
	volume = 70
	/// paint title in ru_names
	var/paint_title_ru = ""

/obj/item/reagent_containers/glass/paint/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag)
		return

	if(!is_open_container())
		return

	if(istype(target) && reagents.total_volume >= 5)
		user.visible_message(span_warning("[target] has been splashed with something by [user]!"))
		spawn(5)
			reagents.reaction(target, REAGENT_TOUCH)
			reagents.remove_any(5)
	else
		return ..()

/obj/item/reagent_containers/glass/paint/get_ru_names()
	return list(
		NOMINATIVE = "ведро [paint_title_ru]",
		GENITIVE = "ведра [paint_title_ru]",
		DATIVE = "ведру [paint_title_ru]",
		ACCUSATIVE = "ведро [paint_title_ru]",
		INSTRUMENTAL = "ведром [paint_title_ru]",
		PREPOSITIONAL = "ведре [paint_title_ru]",
	)

/obj/item/reagent_containers/glass/paint/red
	name = "red paint bucket"
	icon_state = "paint_red"
	list_reagents = list("paint_red" = 70)
	paint_title_ru = "красной краски"

/obj/item/reagent_containers/glass/paint/green
	name = "green paint bucket"
	icon_state = "paint_green"
	list_reagents = list("paint_green" = 70)
	paint_title_ru = "зеленой краски"

/obj/item/reagent_containers/glass/paint/blue
	name = "blue paint bucket"
	icon_state = "paint_blue"
	list_reagents = list("paint_blue" = 70)
	paint_title_ru = "синей краски"

/obj/item/reagent_containers/glass/paint/yellow
	name = "yellow paint bucket"
	icon_state = "paint_yellow"
	list_reagents = list("paint_yellow" = 70)
	paint_title_ru = "желтой краски"

/obj/item/reagent_containers/glass/paint/violet
	name = "violet paint bucket"
	icon_state = "paint_violet"
	list_reagents = list("paint_violet" = 70)
	paint_title_ru = "фиолетовой краски"

/obj/item/reagent_containers/glass/paint/black
	name = "black paint bucket"
	icon_state = "paint_black"
	list_reagents = list("paint_black" = 70)
	paint_title_ru = "черной краски"

/obj/item/reagent_containers/glass/paint/white
	name = "white paint bucket"
	icon_state = "paint_white"
	list_reagents = list("paint_white" = 70)
	paint_title_ru = "белой краски"

/obj/item/reagent_containers/glass/paint/remover
	name = "paint remover bucket"
	list_reagents = list("paint_remover" = 70)
	paint_title_ru = "краскоудалителя"

/obj/item/random_paint_box
	name = "paint box"
	desc = "Коробка, которая содержит случайное ведро с краской."
	icon = 'icons/obj/storage/boxes.dmi'
	icon_state = "giftcrate3"

/obj/item/random_paint_box/attack_self(mob/user)
	var/static/list/paint_types
	if(!paint_types)
		paint_types = subtypesof(/obj/item/reagent_containers/glass/paint)
	var/chosen = pick(paint_types)
	var/obj/item/thing = new chosen(user.drop_location())
	user.put_in_hands(thing)
	qdel(src)

/obj/item/random_paint_box/get_ru_names()
	return list(
		NOMINATIVE = "коробка красок",
		GENITIVE = "коробки красок",
		DATIVE = "коробке красок",
		ACCUSATIVE = "коробку красок",
		INSTRUMENTAL = "коробкой красок",
		PREPOSITIONAL = "коробке красок",
	)

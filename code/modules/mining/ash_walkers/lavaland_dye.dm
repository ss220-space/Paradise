/obj/item/lavaland_dye
	name = "generic dye"
	desc = "Если вы это видите, то Зюзя дебил конечно."
	gender = FEMALE
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "cinnabar_spleen"
	lefthand_file = 'icons/mob/inhands/lavaland/fish_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/fish_items_righthand.dmi'
	item_state = "spleen"
	w_class = WEIGHT_CLASS_TINY
	/// Name of body marking, that applies to human
	var/picked_dye = "Cinnabar Dyes"
	/// Name of overlay, that applies to totem
	var/totem_dye = "сinnabar"
	/// Fluff russian name for examine
	var/fluff_name = "киноварная"

/obj/item/lavaland_dye/cinnabar
	name = "cinnabar-colored spleen"
	desc = "Селезёнка, добытая из тела лавовой рыбы. Содержит в себе частицы киновари и обладает характерным коричневато-красным цветом."
	ru_names = list(
		NOMINATIVE = "селезёнка киноварного цвета",
		GENITIVE = "селезёнки киноварного цвета",
		DATIVE = "селезёнке киноварного цвета",
		ACCUSATIVE = "селезёнку киноварного цвета",
		INSTRUMENTAL = "селезёнкой киноварного цвета",
		PREPOSITIONAL = "селезёнке киноварного цвета",
	)
	icon_state = "cinnabar_spleen"
	picked_dye = "Cinnabar Dyes"
	totem_dye = "cinnabar"
	fluff_name = "киноварная"

/obj/item/lavaland_dye/crimson
	name = "crimson-colored spleen"
	desc = "Селезёнка, добытая из тела лавовой рыбы. Содержит в себе частицы неизвестной жидкости, похожей на кровь, и обладает характерным кроваво-красным цветом."
	ru_names = list(
		NOMINATIVE = "селезёнка кровавого цвета",
		GENITIVE = "селезёнки кровавого цвета",
		DATIVE = "селезёнке кровавого цвета",
		ACCUSATIVE = "селезёнку кровавого цвета",
		INSTRUMENTAL = "селезёнкой кровавого цвета",
		PREPOSITIONAL = "селезёнке кровавого цвета",
	)
	icon_state = "crimson_spleen"
	picked_dye = "Crimson Dyes"
	totem_dye = "crimson"
	fluff_name = "кровавая"

/obj/item/lavaland_dye/indigo
	name = "indigo-colored spleen"
	desc = "Селезёнка, добытая из тела лавовой рыбы. Содержит в себе вещество, похожее на чернила, и обладает характерным тёмно-синим цветом."
	ru_names = list(
		NOMINATIVE = "селезёнка тёмно-синего цвета",
		GENITIVE = "селезёнки тёмно-синего цвета",
		DATIVE = "селезёнке тёмно-синего цвета",
		ACCUSATIVE = "селезёнку тёмно-синего цвета",
		INSTRUMENTAL = "селезёнкой тёмно-синего цвета",
		PREPOSITIONAL = "селезёнке тёмно-синего цвета",
	)
	icon_state = "indigo_spleen"
	picked_dye = "Indigo Dyes"
	totem_dye = "indigo"
	fluff_name = "тёмно-синяя"

/obj/item/lavaland_dye/mint
	name = "mint-colored spleen"
	desc = "Селезёнка, добытая из тела лавовой рыбы. Содержит в себе частицы минералов и обладает характерным мятно-зелёным цветом."
	ru_names = list(
		NOMINATIVE = "селезёнка мятного цвета",
		GENITIVE = "селезёнки мятного цвета",
		DATIVE = "селезёнке мятного цвета",
		ACCUSATIVE = "селезёнку мятного цвета",
		INSTRUMENTAL = "селезёнкой мятного цвета",
		PREPOSITIONAL = "селезёнке мятного цвета",
	)
	icon_state = "mint_spleen"
	picked_dye = "Mint Dyes"
	totem_dye = "mint"
	fluff_name = "мятная"

/obj/item/lavaland_dye/amber
	name = "amber-colored spleen"
	desc = "Селезёнка, добытая из тела лавовой рыбы. Содержит в себе частицы природного янтаря и обладает характерным янтарно-желтым цветом."
	ru_names = list(
		NOMINATIVE = "селезёнка янтарного цвета",
		GENITIVE = "селезёнки янтарного цвета",
		DATIVE = "селезёнке янтарного цвета",
		ACCUSATIVE = "селезёнку янтарного цвета",
		INSTRUMENTAL = "селезёнкой янтарного цвета",
		PREPOSITIONAL = "селезёнке янтарного цвета",
	)
	icon_state = "amber_spleen"
	picked_dye = "Amber Dyes"
	totem_dye = "amber"
	fluff_name = "янтарная"

/obj/item/lavaland_mortar
	name = "wooden mortar"
	desc = "Небольшая ступка с находящейся в ней растолочённой селезёнкой. Используется для нанесения красок на тело."
	ru_names = list(
		NOMINATIVE = "деревянная ступка",
		GENITIVE = "деревянной ступки",
		DATIVE = "деревянной ступке",
		ACCUSATIVE = "деревянную ступку",
		INSTRUMENTAL = "деревянной ступкой",
		PREPOSITIONAL = "деревянной ступке",
	)
	gender = FEMALE
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "amber_dyes"
	lefthand_file = 'icons/mob/inhands/lavaland/fish_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/fish_items_righthand.dmi'
	item_state = "paint"
	w_class = WEIGHT_CLASS_TINY
	/// Name of body marking, that applies to human
	var/picked_dye = "Cinnabar Dyes"
	/// Name of overlay, that applies to totem, also used in icon_states
	var/totem_dye = "сinnabar"
	/// Fluff russian name for examine
	var/fluff_name = "киноварная"
	/// How many times you can use it
	var/uses = 5

/obj/item/lavaland_mortar/examine(mob/user)
	. = ..()
	. += span_notice("В ступке находится [fluff_name] краска.")
	if(uses > 0) //what if someone makes -1 uses for testing or smth
		. += span_notice("Краски в ступке осталось на [uses] использовани[declension_ru(uses, "е", "я", "й")].")

/obj/item/lavaland_mortar/cinnabar_dyes
	icon_state = "cinnabar_dyes"
	picked_dye = "Cinnabar Dyes"
	totem_dye = "cinnabar"
	fluff_name = "киноварная"

/obj/item/lavaland_mortar/crimson_dyes
	icon_state = "crimson_dyes"
	picked_dye = "Crimson Dyes"
	totem_dye = "crimson"
	fluff_name = "кровавая"

/obj/item/lavaland_mortar/indigo_dyes
	icon_state = "indigo_dyes"
	picked_dye = "Indigo Dyes"
	totem_dye = "indigo"
	fluff_name = "тёмно-синяя"

/obj/item/lavaland_mortar/mint_dyes
	icon_state = "mint_dyes"
	picked_dye = "Mint Dyes"
	totem_dye = "mint"
	fluff_name = "мятная"

/obj/item/lavaland_mortar/amber_dyes
	icon_state = "amber_dyes"
	picked_dye = "Amber Dyes"
	totem_dye = "amber"
	fluff_name = "янтарная"

/obj/item/lavaland_mortar/update_icon_state()
	. = ..()
	icon_state = "[totem_dye]_dyes"

/obj/item/lavaland_mortar/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim)
	if(!isunathi(target))
		balloon_alert(user, "цель неподходящей расы!")
		return ..()

	if(user.a_intent != INTENT_HELP)
		return ..()

	. = ATTACK_CHAIN_PROCEED

	to_chat(user, span_notice("Вы начинаете наносить краску на [target]."))
	if(!do_after(user, 5 SECONDS, target, max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_warning("Вы прекращаете наносить краску на тело.")))
		return ..()

	target.change_markings(picked_dye, location = "body")
	uses--
	if(!uses)
		balloon_alert(user, "краска закончилась!")
		qdel(src)
		var/obj/item/reagent_containers/food/drinks/mushroom_bowl/bowl = new(loc)
		user.put_in_hands(bowl)

/obj/item/lavaland_mortar/attack_obj(obj/object, mob/living/user, params)
	if(!istype(object, /obj/structure/ash_totem))
		return ..()

	. = ATTACK_CHAIN_PROCEED_SUCCESS

	var/obj/structure/ash_totem/totem = object
	to_chat(user, span_notice("Вы начинаете наносить краску на [totem.declent_ru(ACCUSATIVE)]."))

	if(!do_after(user, 5 SECONDS, totem, max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_warning("Вы прекращаете наносить краску на [totem.declent_ru(ACCUSATIVE)].")))
		return ..()

	totem.applied_dye = totem_dye
	totem.applied_dye_fluff_name = fluff_name
	totem.update_icon(UPDATE_OVERLAYS)

	uses--
	if(!uses)
		balloon_alert(user, "краска закончилась!")
		qdel(src)
		var/obj/item/reagent_containers/food/drinks/mushroom_bowl/bowl = new(loc)
		user.put_in_hands(bowl)

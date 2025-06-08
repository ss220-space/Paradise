/obj/item/soap
	name = "soap"
	desc = "Дешёвый кусок мыла. Он даже ничем не пахнет."
	ru_names = list(
		NOMINATIVE = "мыло",
		GENITIVE = "мыла",
		DATIVE = "мылу",
		ACCUSATIVE = "мыло",
		INSTRUMENTAL = "мылом",
		PREPOSITIONAL = "мыле"
	)
	gender = PLURAL
	icon = 'icons/obj/janitor.dmi'
	icon_state = "soap"
	belt_icon = "soap"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	item_flags = SKIP_ATTACK_MESSAGE
	var/cleanspeed = 50 //slower than mop

/obj/item/soap/ComponentInitialize()
	AddComponent(/datum/component/slippery, 4 SECONDS, lube_flags = (SLIDE|SLIP_WHEN_LYING))

/obj/item/soap/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		user.balloon_alert(user, "Сначала уберите [target.declent_ru(ACCUSATIVE)]!")
	else if(istype(target, /obj/effect/decal/cleanable) || istype(target, /obj/effect/rune))
		user.visible_message("<span class='warning'>[user] начинает оттирать [target.declent_ru(ACCUSATIVE)] с помощью [src.declent_ru(INSTRUMENTAL)].</span>")
		if(do_after(user, cleanspeed, target) && target)
			to_chat(user, "<span class='notice'>Вы оттёрли [target.declent_ru(GENITIVE)].</span>")
			if(issimulatedturf(target.loc))
				clean_turf(target.loc)
				return
			qdel(target)
	else if(issimulatedturf(target))
		user.visible_message("<span class='warning'>[user] начинает оттирать [target.declent_ru(ACCUSATIVE)] с помощью [src.declent_ru(INSTRUMENTAL)].</span>")
		if(do_after(user, cleanspeed, target))
			to_chat(user, "<span class='notice'>Вы оттёрли [target.declent_ru(ACCUSATIVE)].</span>")
			clean_turf(target)
	else
		user.visible_message("<span class='warning'>[user] начинает оттирать [target.declent_ru(ACCUSATIVE)] с помощью [src.declent_ru(INSTRUMENTAL)].</span>")
		if(do_after(user, cleanspeed, target))
			to_chat(user, "<span class='notice'>Вы оттёрли [target.declent_ru(ACCUSATIVE)].</span>")
			var/obj/effect/decal/cleanable/C = locate() in target
			qdel(C)
			target.clean_blood()

/obj/item/soap/proc/clean_turf(turf/simulated/T)
	T.clean_blood()
	for(var/obj/effect/O in T)
		if(O.is_cleanable())
			qdel(O)


/obj/item/soap/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		user.visible_message(
			span_warning("[user] моет рот [target.declent_ru(GENITIVE)] с [declent_ru(INSTRUMENTAL)]!"),
			span_notice("Вы отмыли рот [target.declent_ru(GENITIVE)] с [declent_ru(INSTRUMENTAL)]!"),
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/item/soap/nanotrasen
	desc = "Именное мыло НаноТрейзен. Обладает игривым запахом плазмы."
	icon_state = "soapnt"

/obj/item/soap/homemade
	desc = "Домашний кусок мыла. Пахнет... любопытно...."
	icon_state = "soapgibs"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_apple
	desc = "Домашний кусок мыла. Обладает ароматом яблока."
	icon_state = "soapapple"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_potato
	desc = "Домашний кусок мыла. Обладает ароматом картошки."
	icon_state = "soappotato"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_pumpkin
	desc = "Домашний кусок мыла. Обладает ароматом тыквы."
	icon_state = "soappumpkin"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_silver
	desc = "Домашний кусок мыла. Обладает ароматом серебра."
	icon_state = "soapsilver"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_tomato
	desc = "Домашний кусок мыла. Обладает ароматом помидора."
	icon_state = "soaptomato"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_uran
	desc = "Домашний кусок мыла. Обладает ароматом урана."
	icon_state = "soapuran"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_watermelon
	desc = "Домашний кусок мыла. Обладает ароматом арбуза."
	icon_state = "soapwatermelon"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_whiskey
	desc = "Домашний кусок мыла. Обладает ароматом виски."
	icon_state = "soapwhiskey"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_banana
	desc = "Домашний кусок мыла. Обладает ароматом банана."
	icon_state = "soapbanana"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_beer
	desc = "Домашний кусок мыла. Обладает ароматом пива."
	icon_state = "soapbeer"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_berry
	desc = "Домашний кусок мыла. Обладает ароматом свежих ягод."
	icon_state = "soapberry"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_carrot
	desc = "Домашний кусок мыла. Обладает ароматом моркови."
	icon_state = "soapcarrot"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_chocolate
	desc = "Домашний кусок мыла. Обладает шоколадным ароматом."
	icon_state = "soapchocolate"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_cola
	desc = "Домашний кусок мыла. Обладает ароматом Кока-Колы."
	icon_state = "soapcola"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_corn
	desc = "Домашний кусок мыла. Обладает ароматом кукурузы."
	icon_state = "soapcorn"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_golden
	desc = "Домашний кусок мыла. Обладает ароматом роскоши."
	icon_state = "soapgolden"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_grape
	desc = "Домашний кусок мыла. Обладает ароматом винограда."
	icon_state = "soapgrape"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_lemon
	desc = "Домашний кусок мыла. Обладает ароматом лимона."
	icon_state = "soaplemon"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_lime
	desc = "Домашний кусок мыла. Обладает ароматом лайма."
	icon_state = "soaplime"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_milk
	desc = "Домашний кусок мыла. Обладает молочным ароматом."
	icon_state = "soapmilk"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_orange
	desc = "Домашний кусок мыла. Обладает ароматом апельсина."
	icon_state = "soaporange"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_pineapple
	desc = "Домашний кусок мыла. Обладает ароматом ананаса."
	icon_state = "soappineapple"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/ducttape
	desc = "Домашний кусок мыла. Он похож на заклееные изолентой ошмётки... Оно точно сможет что-то отмыть?"
	icon_state = "soapgibs"

/obj/item/soap/ducttape/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return

	if(user.client && (target in user.client.screen))
		user.balloon_alert(user, "Сначала уберите [target.declent_ru(ACCUSATIVE)]!")
	else
		user.visible_message("<span class='warning'>[user] начинает размазывать [src.declent_ru(ACCUSATIVE)] по [target.declent_ru(DATIVE)].</span>")
		if(do_after(user, cleanspeed, target))
			to_chat(user, "<span class='notice'>Вы ["моете"] [target.declent_ru(ACCUSATIVE)].</span>")
			if(issimulatedturf(target))
				new /obj/effect/decal/cleanable/blood/gibs/cleangibs(target)
			else if(iscarbon(target))
				for(var/obj/item/carried_item in target.contents)
					if(!istype(carried_item, /obj/item/implant))//If it's not an implant.
						carried_item.add_mob_blood(target)//Oh yes, there will be blood...
				var/mob/living/carbon/human/H = target
				H.bloody_hands(target,0)
				H.bloody_body(target)

	return

/obj/item/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of comdoms."
	"Раскошный кусок мыла производства Waffle Co. Пахнет важностью и тщеславием."
	icon_state = "soapdeluxe"
	cleanspeed = 40 //slightly better because deluxe -- captain gets one of these

/obj/item/soap/ert
	desc = "Мыло высокого качества, с запахом морской волны, специально для очистки полов от въевшейся крови неудачливого экипажа."
	icon_state = "soapert"
	cleanspeed = 10

/obj/item/soap/syndie
	desc = "Ненадёжный кусок мыла, сделанный из едких химикатов для ускоренного отмывания крови."
	icon_state = "soapsyndie"
	belt_icon = "soapsyndie"
	cleanspeed = 10 //much faster than mop so it is useful for traitors who want to clean crime scenes

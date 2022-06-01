/obj/item/radio/spy_spider
	name = "жучок"
	desc = "Кажется, ты видел такого в фильмах про шпионов."
	icon_state = "spy_spider"
	frequency = SPY_SPIDER_FREQ
	freqlock = SPY_SPIDER_FREQ
	listening = FALSE
	broadcasting = FALSE
	canhear_range = 3

/obj/item/radio/spy_spider/examine(mob/user)
	. = ..()
	. += "<span class='info'>Сейчас он [broadcasting ? "включен" : "выключен"]</span>"

/obj/item/radio/spy_spider/attack_self(mob/user)
	broadcasting = !broadcasting
	if(broadcasting)
		to_chat(user, "<span class='info'>Ты включил жучка.</span>")
	else
		to_chat(user, "<span class='info'>Ты выключил жучка.</span>")
	return TRUE

/obj/item/encryptionkey/spy_spider
	name = "Spy Encryption Key"
	icon_state = "spy_cypherkey"
	channels = list("Spy Spider" = TRUE)

/obj/item/storage/lockbox/spy_kit
	name = "набор жучков"
	desc = "Не самый легальный из способов достать информацию, но какая разница, если никто не узнает?"
	storage_slots = 5
	req_access = list(ACCESS_FORENSICS_LOCKERS)

/obj/item/storage/lockbox/spy_kit/Initialize(mapload)
	. = ..()
	new /obj/item/radio/spy_spider(src)
	new /obj/item/radio/spy_spider(src)
	new /obj/item/radio/spy_spider(src)
	new /obj/item/encryptionkey/spy_spider(src)
	new /obj/item/encryptionkey/spy_spider(src)


/**
 * CLOTHING PART
 */

/obj/item/clothing
	var/obj/item/radio/spy_spider/spy_spider_attached = null

/obj/item/clothing/Destroy()
	QDEL_NULL(spy_spider_attached)
	return ..()

/obj/item/clothing/hear_talk(mob/M, list/message_pieces)
	. = ..()
	spy_spider_attached?.hear_talk(M, message_pieces)

/obj/item/clothing/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/radio/spy_spider))
		return ..()
	if(spy_spider_attached || !((slot_flags & SLOT_OCLOTHING) || (slot_flags & SLOT_ICLOTHING)))
		to_chat(user, "<span class='warning'>Ты не нашел места для жучка!</span>")
		return TRUE
	var/obj/item/radio/spy_spider/spy_spider = I

	if(!spy_spider.broadcasting)
		to_chat(user, "<span class='warning'>Жучок выключен!</span>")
		return TRUE

	user.unEquip(spy_spider)
	spy_spider.forceMove(src)
	spy_spider_attached = spy_spider
	to_chat(user, "<span class='info'>Ты незаметно прикрепил жучок к [src].</span>")
	return TRUE

/obj/item/clothing/proc/remove_spy_spider()
	set name = "Снять жучок"
	set category = "Object"
	set src in range(1, usr)

	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr

	if(spy_spider_attached)
		if(!user.put_in_any_hand_if_possible(spy_spider_attached, del_on_fail = FALSE))
			var/turf/user_loc = get_turf(user)
			spy_spider_attached.forceMove(user_loc)
		spy_spider_attached = null

	verbs -= /obj/item/clothing/proc/remove_spy_spider


/**
 * HUMAN PART
 */

/mob/living/carbon/human/attackby(obj/item/I, mob/living/user, def_zone)
	if(!istype(I, /obj/item/radio/spy_spider))
		return ..()

	if(!(w_uniform || wear_suit))
		to_chat(user, "<span class='warning'>У тебя нет желания лезть к [genderize_ru(gender, "нему", "ней", "этому", "ним")] в трусы. Жучок надо крепить на одежду!</span>")
		return TRUE

	var/obj/item/radio/spy_spider/spy_spider = I
	var/obj/item/clothing/clothing_for_attach = wear_suit || w_uniform
	if(clothing_for_attach.spy_spider_attached)
		to_chat(user, "<span class='warning'>Ты не нашел места для жучка!</span>")
		return TRUE

	if(!spy_spider.broadcasting)
		to_chat(user, "<span class='warning'>Жучок выключен!</span>")
		return TRUE

	var/attempt_cancel_message = "<span class='warning'>Ты не успел установить жучок.</span>"
	if(!do_after_once(user, 3 SECONDS, TRUE, src, TRUE, attempt_cancel_message))
		return TRUE

	user.unEquip(spy_spider)
	spy_spider.forceMove(clothing_for_attach)
	clothing_for_attach.spy_spider_attached = spy_spider
	to_chat(user, "<span class='info'>Ты незаметно прикрепил жучок к одежде [src].</span>")
	return TRUE



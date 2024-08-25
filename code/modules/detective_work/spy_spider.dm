/obj/item/radio/spy_spider
	name = "жучок"
	desc = "Кажется, ты видел такого в фильмах про шпионов."
	icon_state = "spy_spider"
	frequency = SPY_SPIDER_FREQ
	freqlock = SPY_SPIDER_FREQ
	listening = FALSE
	broadcasting = FALSE
	canhear_range = 3
	gender = MALE
	ru_names = list(NOMINATIVE = "жучок", GENITIVE = "жучка", DATIVE = "жучку", ACCUSATIVE = "жучок", INSTRUMENTAL = "жучком", PREPOSITIONAL = "жучке")

/obj/item/radio/spy_spider/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Сейчас он [broadcasting ? "включён" : "выключен"]</span>"

/obj/item/radio/spy_spider/attack_self(mob/user)
	broadcasting = !broadcasting
	if(broadcasting)
		to_chat(user, "<span class='notice'>Ты включаешь жучок.</span>")
	else
		to_chat(user, "<span class='notice'>Ты выключил жучка.</span>")
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

/obj/item/clothing/emp_act(severity)
	. = ..()
	spy_spider_attached?.emp_act(severity)

/obj/item/clothing/hear_talk(mob/M, list/message_pieces)
	. = ..()
	spy_spider_attached?.hear_talk(M, message_pieces)


/obj/item/clothing/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/radio/spy_spider))
		add_fingerprint(user)
		var/obj/item/radio/spy_spider/spy_spider = I
		if(!(slot_flags & (ITEM_SLOT_CLOTH_OUTER|ITEM_SLOT_CLOTH_INNER)))
			to_chat(user, span_warning("Вы не находите места для жучка."))
			return ATTACK_CHAIN_PROCEED
		if(spy_spider_attached)
			to_chat(user, span_warning("Жучок уже установлен."))
			return ATTACK_CHAIN_PROCEED
		if(!spy_spider.broadcasting)
			to_chat(user, span_warning("Жучок выключен."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(spy_spider, src))
			return ATTACK_CHAIN_PROCEED
		spy_spider_attached = spy_spider
		to_chat(user, span_notice("Вы незаметно прикрепляете жучок к [declent_ru(DATIVE)]."))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/clothing/proc/remove_spy_spider()
	set name = "Снять жучок"
	set category = "Object"
	set src in range(1, usr)

	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr

	if(spy_spider_attached)
		if(!user.put_in_any_hand_if_possible(spy_spider_attached))
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

	. = ATTACK_CHAIN_PROCEED

	if(!w_uniform && !wear_suit)
		to_chat(user, span_warning("У Вас нет желания лезть к [genderize_ru(gender, "нему", "ней", "этому", "ним")] в трусы. Жучок необходимо крепить на одежду!"))
		return .

	var/obj/item/radio/spy_spider/spy_spider = I
	var/obj/item/clothing/clothing_for_attach = wear_suit || w_uniform
	if(clothing_for_attach.spy_spider_attached)
		to_chat(user, span_warning("Жучок уже установлен!"))
		return .

	if(!spy_spider.broadcasting)
		to_chat(user, span_warning("Жучок выключен!"))
		return .

	var/attempt_cancel_message = span_warning("Вы прекращаете установку жучка.")
	if(!do_after(user, 3 SECONDS, src, max_interact_count = 1, cancel_on_max = TRUE, cancel_message = attempt_cancel_message, category = DA_CAT_TOOL))
		return .

	if(QDELETED(clothing_for_attach) || !clothing_for_attach.loc != src || clothing_for_attach.spy_spider_attached || !spy_spider.broadcasting || !user.temporarily_remove_item_from_inventory(spy_spider))
		return .

	. = ATTACK_CHAIN_BLOCKED_ALL
	to_chat(user, span_info("Вы незаметно прикрепляете жучок к одежде [declent_ru(GENITIVE)]."))
	spy_spider.forceMove(clothing_for_attach)
	clothing_for_attach.spy_spider_attached = spy_spider


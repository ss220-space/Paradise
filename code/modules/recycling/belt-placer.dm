/obj/item/storage/conveyor //Stores conveyor belts, click floor to make belt, use a conveyor switch on this to link all belts to that lever.
	name = "conveyor belt placer"
	desc = "This device facilitates the rapid deployment of conveyor belts."
	icon = 'icons/obj/storage/boxes.dmi'
	icon_state = "belt_placer"
	righthand_file = 'icons/mob/inhands/storage_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/storage_lefthand.dmi'
	item_state = "conv"
	w_class = WEIGHT_CLASS_BULKY //Because belts are large things, you know?
	can_hold = list(/obj/item/conveyor_construct)
	flags = CONDUCT
	max_w_class = WEIGHT_CLASS_BULKY
	max_combined_w_class = 28 //7 belts
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	display_contents_with_number = TRUE
	use_to_pickup = TRUE
	origin_tech = "engineering=1"

/obj/item/storage/conveyor/bluespace
	name = "bluespace conveyor belt placer"
	desc = "Устройство, предназначенное для ускоренной укладки конвейерных лент. В отличие от обычного укладчика, оно вмещает гораздо больше лент."
	icon_state = "bluespace_belt_placer"
	item_state = "bs_conv"
	w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 50
	max_combined_w_class = 200 //50 belts
	origin_tech = "engineering=2;bluespace=1"

/obj/item/storage/conveyor/bluespace/get_ru_names()
	return list(
		NOMINATIVE = "блюспейс укладчик конвейеров",
		GENITIVE = "блюспейс укладчика конвейеров",
		DATIVE = "блюспейс укладчику конвейеров",
		ACCUSATIVE = "блюспейс укладчик конвейеров",
		INSTRUMENTAL = "блюспейс укладчиком конвейеров",
		PREPOSITIONAL = "блюспейс укладчике конвейеров"
	)

/obj/item/storage/conveyor/attackby(obj/item/I, mob/user, params) //So we can link belts en masse
	if(istype(I, /obj/item/conveyor_switch_construct))
		add_fingerprint(user)
		var/obj/item/conveyor_switch_construct/switch_construct = I
		var/linked = FALSE //For nice message
		for(var/obj/item/conveyor_construct/conveyor in contents)
			conveyor.id = switch_construct.id
			linked = TRUE
		if(linked)
			balloon_alert(user, span_notice("все ленты в [declent_ru(PREPOSITIONAL)] связаны с [switch_construct]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/storage/conveyor/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	var/obj/item/conveyor_construct/conveyor = locate() in contents
	if(!conveyor)
		to_chat(user, span_warning("There are no belts in [src]."))
		return
	conveyor.afterattack(target, user, proximity, params)


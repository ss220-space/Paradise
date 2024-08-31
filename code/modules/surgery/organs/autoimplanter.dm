/obj/item/autoimplanter
	name = "autoimplanter"
	desc = "A device that automatically injects a cyber-implant into the user without the hassle of extensive surgery. It has a slot to insert implants and a screwdriver slot for removing accidentally added implants."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndi-autoimplanter"
	item_state = "walkietalkie"//left as this so as to intentionally not have inhands
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/weapons/circsawhit.ogg'
	var/obj/item/organ/internal/cyberimp/storedorgan

/obj/item/autoimplanter/old
	icon_state = "autoimplanter"


/obj/item/autoimplanter/attack_self(mob/user)//when the object is used...
	. = ..()
	if(!.)
		autoimplant(user)


/// Core code of self-implanting
/obj/item/autoimplanter/proc/autoimplant(mob/living/carbon/human/user)
	if(!ishuman(user))
		return FALSE
	if(!storedorgan)
		to_chat(user, span_warning("Киберимплант не обнаружен."))
		return FALSE
	if(!user.bodyparts_by_name[check_zone(storedorgan.parent_organ_zone)])
		to_chat(user, span_warning("Отсутствует требуемая часть тела!"))
		return FALSE
	if(HAS_TRAIT(user, TRAIT_NO_CYBERIMPLANTS))
		to_chat(user, span_warning("Ваш вид неспособен принять этот киберимплант!"))
		return FALSE
	storedorgan.insert(user)//insert stored organ into the user
	user.visible_message(
		span_notice("[user] активиру[pluralize_ru(user.gender,"ет","ют")] автоимплантер и вы слышите недолгий механический шум."),
		span_notice("Вы чувствуете острое жжение, когда автоимплантер приступает к работе."),
	)
	playsound(get_turf(user), usesound, 50, TRUE)
	storedorgan = null
	return TRUE


/obj/item/autoimplanter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/organ/internal/cyberimp))
		add_fingerprint(user)
		if(storedorgan)
			to_chat(user, span_warning("В устройстве уже установлен другой киберимплант."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		storedorgan = I
		to_chat(user, span_notice("Вы установили [I.name] в автоимплантер."))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/autoimplanter/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!storedorgan)
		add_fingerprint(user)
		to_chat(user, span_notice("Устройство не содержит киберимплантов."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	storedorgan.forceMove(drop_location())
	storedorgan.add_fingerprint(user)
	storedorgan = null
	to_chat(user, span_notice("Вы извлекли [storedorgan.name] из устройства."))


/obj/item/autoimplanter/oneuse
	desc = "A device that automatically injects a cyber-implant into the user without the hassle of extensive surgery. At once."


/obj/item/autoimplanter/oneuse/autoimplant(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return .
	visible_message(span_warning("Автоимплантер зловеще пищит и через мгновение вспыхивает, оставляя только пепел."))
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	user.temporarily_remove_item_from_inventory(src, force = TRUE)
	qdel(src)


/obj/item/autoimplanter/oneuse/screwdriver_act(mob/living/user, obj/item/I)
	var/self_destruct = !isnull(storedorgan)
	. = ..()
	if(!self_destruct)
		return .
	visible_message(span_warning("Автоимплантер зловеще пищит и через мгновение вспыхивает, оставляя только пепел."))
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	user.temporarily_remove_item_from_inventory(src, force = TRUE)
	qdel(src)


/obj/item/autoimplanter/oneuse/meson
	name = "autoimplanter(meson scanner implant)"
	storedorgan = new /obj/item/organ/internal/cyberimp/eyes/meson

/obj/item/autoimplanter/oneuse/mantisblade
	name = "autoimplanter (mantis blade right)"
	storedorgan = new /obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/horlex

/obj/item/autoimplanter/oneuse/mantisblade/l
	name = "autoimplanter (mantis blade left)"
	storedorgan = new /obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/horlex/l

/obj/item/autoimplanter/oneuse/razorblade
	name = "autoimplanter (razorblade)"
	storedorgan = new /obj/item/organ/internal/cyberimp/tail/blade

/obj/item/autoimplanter/oneuse/laserblade
	name = "autoimplanter (laserblade)"
	storedorgan = new /obj/item/organ/internal/cyberimp/tail/blade/laser/syndi

/obj/item/autoimplanter/traitor
	desc = "A device that automatically injects a cyber-implant into the user without the hassle of extensive surgery. This model is capable of implanting up to three implants before destroing."
	var/uses = 3


/obj/item/autoimplanter/traitor/autoimplant(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return .
	uses--
	if(uses > 0)
		return .
	visible_message(span_warning("Автоимплантер зловеще пищит и через мгновение вспыхивает, оставляя только пепел."))
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	user.temporarily_remove_item_from_inventory(src, force = TRUE)
	qdel(src)


/obj/item/autoimplanter/traitor/examine(mob/user)
	. = ..()
	if(uses)
		. += span_notice("Осталось использований: [uses].")

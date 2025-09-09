/obj/item/autoimplanter
	name = "autoimplanter"
	desc = "A device that automatically injects a cyber-implant into the user without the hassle of extensive surgery. \
			It has a slot to insert implants and a screwdriver slot for removing accidentally added implants."
	gender = MALE
	icon = 'icons/obj/device.dmi'
	icon_state = "syndi-autoimplanter"
	item_state = "walkietalkie"//left as this so as to intentionally not have inhands
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/weapons/circsawhit.ogg'
	var/obj/item/organ/internal/cyberimp/storedorgan

/obj/item/autoimplanter/get_ru_names()
	return list(
		NOMINATIVE = "автоимплантер",
		GENITIVE = "автоимплантера",
		DATIVE = "автоимплантеру",
		ACCUSATIVE = "автоимплантер",
		INSTRUMENTAL = "автоимплантером",
		PREPOSITIONAL = "автоимплантере"
	)

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

	if(!storedorgan.can_insert(target = user) || HAS_TRAIT(user, TRAIT_NO_CYBERIMPLANTS)) //make it silent
		to_chat(user, span_warning("Ваш вид не подходит для установки этого киберимпланта!"))
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
	if(!istype(I, /obj/item/organ/internal/cyberimp))
		return ..()

	add_fingerprint(user)

	if(storedorgan)
		balloon_alert(user, "слот для киберимпланта занят!")
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(I, src))
		return ..()

	storedorgan = I
	balloon_alert(user, "киберимплант установлен")
	return ATTACK_CHAIN_BLOCKED_ALL


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

/obj/item/autoimplanter/oneuse/sec_hud
	name = "autoimplanter (sechud)"
	desc = "Одноразовый автоимплантер, содержащий в себе охранный ИЛС. Имплант можно достать отверткой, но вставить назад уже нельзя."
	storedorgan = new /obj/item/organ/internal/cyberimp/eyes/hud/security
	icon_state = "autoimplanter"

/obj/item/autoimplanter/oneuse/sec_hud/get_ru_names()
	return list(
		NOMINATIVE = "автоимплантер с охранным ИЛС",
		GENITIVE = "автоимплантера с охранным ИЛС",
		DATIVE = "автоимплантеру с охранным ИЛС",
		ACCUSATIVE = "автоимплантер с охранным ИЛС",
		INSTRUMENTAL = "автоимплантером с охранным ИЛС",
		PREPOSITIONAL = "автоимплантере с охранным ИЛС"
	)

/obj/item/autoimplanter/oneuse/med_hud
	name = "autoimplanter (medhud)"
	desc = "Одноразовый автоимплантер, содержащий в себе медицинский ИЛС. Имплант можно достать отверткой, но вставить назад уже нельзя."
	storedorgan = new /obj/item/organ/internal/cyberimp/eyes/hud/medical
	icon_state = "autoimplanter"

/obj/item/autoimplanter/oneuse/med_hud/get_ru_names()
	return list(
		NOMINATIVE = "автоимплантер с медицинским ИЛС",
		GENITIVE = "автоимплантера с медицинским ИЛС",
		DATIVE = "автоимплантеру с медицинским ИЛС",
		ACCUSATIVE = "автоимплантер с медицинским ИЛС",
		INSTRUMENTAL = "автоимплантером с медицинским ИЛС",
		PREPOSITIONAL = "автоимплантере с медицинским ИЛС"
	)

/obj/item/autoimplanter/oneuse/diagnostic_hud
	name = "autoimplanter (diagnostic hud)"
	desc = "Одноразовый автоимплантер, содержащий в себе диагностический ИЛС. Имплант можно достать отверткой, но вставить назад уже нельзя."
	storedorgan = new /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic
	icon_state = "autoimplanter"

/obj/item/autoimplanter/oneuse/diagnostic_hud/get_ru_names()
	return list(
		NOMINATIVE = "автоимплантер с диагностическим ИЛС",
		GENITIVE = "автоимплантера с диагностическим ИЛС",
		DATIVE = "автоимплантеру с диагностическим ИЛС",
		ACCUSATIVE = "автоимплантер с диагностическим ИЛС",
		INSTRUMENTAL = "автоимплантером с диагностическим ИЛС",
		PREPOSITIONAL = "автоимплантере с диагностическим ИЛС"
	)

/obj/item/autoimplanter/oneuse/meson_eyes
	name = "autoimplanter (meson)"
	desc = "Одноразовый автоимплантер, содержащий в себе мезонный ИЛС. Имплант можно достать отверткой, но вставить назад уже нельзя."
	storedorgan = new /obj/item/organ/internal/cyberimp/eyes/meson
	icon_state = "autoimplanter"

/obj/item/autoimplanter/oneuse/meson_eyes/get_ru_names()
	return list(
		NOMINATIVE = "автоимплантер с мезонным ИЛС",
		GENITIVE = "автоимплантера с мезонным ИЛС",
		DATIVE = "автоимплантеру с мезонным ИЛС",
		ACCUSATIVE = "автоимплантер с мезонным ИЛС",
		INSTRUMENTAL = "автоимплантером с мезонным ИЛС",
		PREPOSITIONAL = "автоимплантере с мезонным ИЛС"
	)


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

/obj/item/card/id/ert
	name = "ERT ID"
	icon_state = "ERT_empty"
	item_state = "ert-id"

/obj/item/card/id/ert/get_ru_names()
	return list(
		NOMINATIVE = "ID-карта ОБР",
		GENITIVE = "ID-карты ОБР",
		DATIVE = "ID-карте ОБР",
		ACCUSATIVE = "ID-карту ОБР",
		INSTRUMENTAL = "ID-картой ОБР",
		PREPOSITIONAL = "ID-карте ОБР",
	)

/obj/item/card/id/ert/commander
	icon_state = "ERT_leader"

/obj/item/card/id/ert/security
	icon_state = "ERT_security"

/obj/item/card/id/ert/engineering
	icon_state = "ERT_engineering"

/obj/item/card/id/ert/medic
	icon_state = "ERT_medical"

/obj/item/card/id/ert/registration
	name = "EDDITABLE ERT ID"
	/// The name of the squad role
	var/membership = "Член"
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_SECURITY, ACCESS_CENT_STORAGE, ACCESS_CENT_SPECOPS, ACCESS_SALVAGE_CAPTAIN)

/obj/item/card/id/ert/registration/get_ru_names()
	return list(
		NOMINATIVE = "изменяемая ID-карта ОБР",
		GENITIVE = "изменяемой ID-карты ОБР",
		DATIVE = "изменяемой ID-карте ОБР",
		ACCUSATIVE = "изменяемую ID-карту ОБР",
		INSTRUMENTAL = "изменяемой ID-картой ОБР",
		PREPOSITIONAL = "изменяемой ID-карте ОБР",
	)

/obj/item/card/id/ert/registration/commander
	icon_state = "ERT_leader"
	membership = "Командир"

/obj/item/card/id/ert/registration/security
	icon_state = "ERT_security"
	membership = "Оперативник"

/obj/item/card/id/ert/registration/engineering
	icon_state = "ERT_engineering"
	membership = "Инженер"

/obj/item/card/id/ert/registration/medic
	icon_state = "ERT_medical"
	membership = "Медик"

/obj/item/card/id/ert/registration/janitor
	icon_state = "ERT_janitorial"
	membership = "Уборщик"

/obj/item/card/id/ert/registration/attack_self(mob/user as mob)
	if(!registered && ishuman(user))
		registered_name = "[pick("Лейтенант", "Капитан", "Майор")] [user.real_name]"
		SetOwnerInfo(user)
		assignment = "[membership] ОБР"
		RebuildHTML()
		update_label()
		registered = TRUE
		balloon_alert(user, "зарегестрировано на вас")
	else
		..()


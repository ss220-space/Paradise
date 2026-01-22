/obj/item/card/id/ert
	name = "ERT ID"
	icon_state = "ERT_empty"
	item_state = "ert-id"

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
	var/membership
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_SECURITY, ACCESS_CENT_STORAGE, ACCESS_CENT_SPECOPS, ACCESS_SALVAGE_CAPTAIN)

/obj/item/card/id/ert/registration/commander
	icon_state = "ERT_leader"
	membership = "Leader"

/obj/item/card/id/ert/registration/security
	icon_state = "ERT_security"
	membership = "Officer"

/obj/item/card/id/ert/registration/engineering
	icon_state = "ERT_engineering"
	membership = "Engineer"

/obj/item/card/id/ert/registration/medic
	icon_state = "ERT_medical"
	membership = "Medic"

/obj/item/card/id/ert/registration/janitor
	icon_state = "ERT_janitorial"
	membership = "Janitor"

/obj/item/card/id/ert/registration/attack_self(mob/user as mob)
	if(!registered && ishuman(user))
		registered_name = "[pick("Лейтенант", "Капитан", "Майор")] [user.real_name]"
		SetOwnerInfo(user)
		assignment = "Emergency Response Team [membership]"
		RebuildHTML()
		update_label()
		registered = TRUE
		to_chat(user, span_notice("Теперь этот ID зарегистрирован на вас."))
	else
		..()


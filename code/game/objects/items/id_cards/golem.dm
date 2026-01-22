/obj/item/card/id/golem
	name = "Free Golem ID"
	desc = "Карта для начисления очков шахтёра и покупки снаряжения. Используйте, чтобы отметить её своей."
	icon_state = "research"
	access = list(ACCESS_FREE_GOLEMS, ACCESS_ROBOTICS, ACCESS_CLOWN, ACCESS_MIME) //access to robots/mechs

/obj/item/card/id/golem/attack_self(mob/user as mob)
	if(!registered && ishuman(user))
		registered_name = user.real_name
		SetOwnerInfo(user)
		assignment = "Free Golem"
		RebuildHTML()
		update_label()
		desc = "Карта для начисления очков шахтёра и покупки снаряжения."
		registered = TRUE
		to_chat(user, span_notice("Теперь этот ID зарегистрирован на вас."))
	else
		..()

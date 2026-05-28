/obj/item/card/id/golem
	name = "Free Golem ID"
	desc = "Идентификационная карта, используемая свободными големами. Обладает базовым уровнем доступа \
			и возможность накопления шахтёрских очков добычи."
	icon_state = "research"
	access = list(ACCESS_FREE_GOLEMS, ACCESS_ROBOTICS, ACCESS_CLOWN, ACCESS_MIME) //access to robots/mechs

/obj/item/card/id/golem/get_ru_names()
	return list(
		NOMINATIVE = "ID-карта свободного голема",
		GENITIVE = "ID-карты свободного голема",
		DATIVE = "ID-карте свободного голема",
		ACCUSATIVE = "ID-карту свободного голема",
		INSTRUMENTAL = "ID-картой свободного голема",
		PREPOSITIONAL = "ID-карте свободного голема",
	)

/obj/item/card/id/golem/attack_self(mob/user as mob)
	if(!registered && ishuman(user))
		registered_name = user.real_name
		SetOwnerInfo(user)
		assignment = "Свободный голем"
		RebuildHTML()
		update_label()
		registered = TRUE
		balloon_alert(user, "зарегестрировано на вас")
	else
		..()

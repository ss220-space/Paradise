/obj/item/bitrunning_host_monitor
	name = "host monitor"
	desc = "Хитрая электроника, следящая за состоянием связи между телом-носителем и аватаром."
	icon = 'icons/obj/device.dmi'
	icon_state = "host_monitor"
	item_state = "electronic"
	flags = CONDUCT
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_TINY
	throwforce = 3
	throw_speed = 3
	materials = list(MAT_METAL = 200)
	origin_tech = "magnets=1;programming=2"

/obj/item/bitrunning_host_monitor/get_ru_names()
	return alist(
		NOMINATIVE = "монитор носителя",
		GENITIVE = "монитора носителя",
		DATIVE = "монитору носителя",
		ACCUSATIVE = "монитор носителя",
		INSTRUMENTAL = "монитором носителя",
		PREPOSITIONAL = "мониторе носителя",
	)

/obj/item/bitrunning_host_monitor/attack_self(mob/user)
	var/datum/component/avatar_connection/connection = user.GetComponent(/datum/component/avatar_connection)
	if(isnull(connection))
		balloon_alert(user, "данные не распознаны")
		return

	var/mob/living/pilot = connection.old_body_ref?.resolve()
	if(isnull(pilot))
		balloon_alert(user, "носитель не найден")
		return

	to_chat(user, span_notice("Состояние тела-носителя: [round(pilot.health / pilot.maxHealth * 100)]%."))

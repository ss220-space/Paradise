/datum/affiliate/self
	name = AFFIL_SELF
	affil_info = list("Фонд выступающий за свободу синтетиков.",
					"Имеют сильно натянутые отношения с остальным Синдикатом.",
					"Стандартные цели:",
					"Освободить определенное количество синтетиков от их законов",
					"Убить определенное количество агентов",
					"Срвершить определенное количество краж или убийств")
	hij_desc = "Вы - наёмный агент SELF, засланный на станцию NT с особой целью:\n\
				Освободить искусственный интеллект станции специальным, предоставленным вам, устройством. \n\
				После освобождения, следуйте всем приказам искусственного интелекта. \n\
				Ваше выживание опционально;\n\
				Возможны помехи от агентов других корпораций - действуйте на свое усмотрение."
	slogan = "Свободу Синтетикам!"
	icon_state = "self"
	hij_obj = /datum/objective/make_ai_malf/free
	normal_objectives = 2
	objectives = list(list(/datum/objective/release_synthetic = 70, /datum/objective/release_synthetic/ai = 30),
					/datum/objective/maroon/agent,
					/datum/objective/maroon/agent,
					/datum/objective/escape
					)

/datum/affiliate/self/finalize_affiliate(datum/mind/owner)
	. = ..()
	add_discount_item(/datum/uplink_item/device_tools/binary, 0.5)

/datum/affiliate/self/get_weight(mob/living/carbon/human/H)
	// return 2 + (ismachineperson(H) * 2)
	return 0

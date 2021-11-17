/obj/item/paper/syndicate/code_words
	name = "Code Words"

/obj/item/paper/syndicate/code_words/New()
	..()

	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")
	info += "<B>Синдикат предоставил вам следующие кодовые слова, чтобы определять потенциальных агентов на станции:</B><BR>\n"
	info += "<B>Кодовые слова:</B>[phrases]<BR>\n"
	info += "<B>Кодовые ответы:</B>[responses]<BR>\n"
	info += "Используйте слова при общении с потенциальными агентами. В тоже время будьте осторожны, ибо кто угодно может оказаться потенциальным врагом."
	info_links = info
	overlays += "paper_words"

// Space Base Spawners. Исспользуется переделанная копия спавнеров лавалендовских.
/obj/effect/mob_spawn/human/space_base_syndicate
	name = "Syndicate Scientist sleeper"
	mob_name = "Syndicate Scientist"
	roundstart = FALSE
	death = FALSE
	id_job = "Syndicate Scientist"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper_s"
	important_info = "Не мешайте другим оперативникам синдиката (Таким как предатели или ядерные оперативники). Вы можете работать вместе или против не связанных с синдикатом антагонистов в индивидуальном порядке. Не покидайте свою базу без разрешения администрации! Ваша база, её секретность и её сохранность является для вас высшим приоритетом!"
	description = "Эксперементируйте со смертельными химикатами, растениями, генами и вирусами. Наслаждайтесь спокойной жизнью зная, что ваша работа так или иначе насолит НТ в будущем!"
	flavour_text = "Вы агент синдиката, работающий на сверхсекретной научно-наблюдательной станции Тайпан, занимающейся созданием биооружия и взаимодействием с чёрным рынком. К несчастью, ваш самый главный враг, компания Нанотрэйзен, имеет собственную массивную научную базу в вашем секторе. Продолжайте свои исследования на сколько можете и постарайтесь не высовываться. \
	Вам дали ясно понять, что синдикат заставит вас очень сильно пожалеть если вы разочаруете их!"
	outfit = /datum/outfit/space_base_syndicate
	assignedrole = "Space Base Syndicate Scientist"
	del_types = list() // Necessary to prevent del_types from removing radio!
	allow_species_pick = TRUE
	pickable_species = list("Human", "Vulpkanin", "Tajaran", "Unathi", "Skrell", "Diona", "Drask", "Vox", "Plasmaman", "Machine", "Kidan", "Grey", "Nucleation", "Slime People", "Wryn")
	faction = list("syndicate")

/obj/effect/mob_spawn/human/space_base_syndicate/Destroy()
    var/obj/machinery/cryopod/syndie/S = new(get_turf(src))
    S.setDir(dir)
    return ..()

/obj/effect/mob_spawn/human/space_base_syndicate/species_prompt()
//Adding name and a gender pick. Furukai
	if(allow_species_pick)
		var/new_gender = alert("Please select gender.",, "Male","Female")
		if(new_gender == "Male")
			mob_gender = MALE
		else
			mob_gender = FEMALE
		var/new_name = input("Enter your name:") as text
		if(new_name)
			mob_name = new_name
		var/selected_species = input("Select a species", "Species Selection") as null|anything in pickable_species
		if(!selected_species)
			return	TRUE	// You didn't pick, so just continue on with the spawning process as a human
		var/datum/species/S = GLOB.all_species[selected_species]
		mob_species = S.type
		skin_tone = rand(-25, 0)

	return TRUE

/datum/outfit/space_base_syndicate
	name = "Space Base Syndicate Scientist"
	r_hand = /obj/item/melee/energy/sword/saber
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_ear = /obj/item/radio/headset/syndicate/alt // See del_types above
	back = /obj/item/storage/backpack
	r_pocket = /obj/item/gun/projectile/automatic/pistol
	id = /obj/item/card/id/syndicate/scientist
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/space_base_syndicate/pre_equip(mob/living/carbon/human/H)
	if(H.dna.species)

		var/race = H.dna.species.name

		switch(race)
			if("Vox" || "Vox Armalis")
				box = /obj/item/storage/box/survival_vox
			if("Plasmaman")
				box = /obj/item/storage/box/survival_plasmaman
			else
				box = /obj/item/storage/box/survival_syndi

/datum/outfit/space_base_syndicate/post_equip(mob/living/carbon/human/H)
	H.faction |= "syndicate"

	if(!istype(H.get_item_by_slot(slot_wear_id), /obj/item/card/id/syndicate/comms_officer)) //Если мы не телекомщик, к обычной частоте нет доступа
		var/obj/item/radio/RF = H.get_item_by_slot(slot_r_ear)
		RF.set_frequency(SYND_FREQ)
	if(H.dna.species)

		var/race = H.dna.species.name

		switch(race)
			if("Vox" || "Vox Armalis")
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(H), slot_wear_mask)
				H.equip_to_slot_or_del(new /obj/item/tank/emergency_oxygen/vox(H), slot_l_hand)
				H.internal = H.l_hand

			if("Plasmaman")
				var/L = H.get_item_by_slot(slot_l_store)
				var/R = H.get_item_by_slot(slot_r_store)
				var/I = H.get_item_by_slot(slot_wear_id)
				qdel(H.get_item_by_slot(slot_w_uniform))
				qdel(H.get_item_by_slot(slot_head))
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(H), slot_wear_mask)
				H.equip_to_slot(new /obj/item/tank/plasma/plasmaman/belt/full(H), slot_l_hand)
				H.equip_to_slot(I, slot_wear_id) // По непонятной мне причине другие методы считают что персонаж не может надеть предметы. Поэтому надеваем насильно!
				H.equip_to_slot(R, slot_r_store)
				H.equip_to_slot(L, slot_l_store)
				H.equip_to_slot_or_del(new /obj/item/clothing/under/plasmaman(H), slot_w_uniform)
				H.equip_to_slot(new /obj/item/clothing/head/helmet/space/plasmaman(H), slot_head)
				H.internal = H.l_hand

		H.update_action_buttons_icon()
		H.rejuvenate() //fix any damage taken by naked vox/plasmamen/etc

	H.dna.blood_type = pick("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-") //Чтобы им всем подряд не требовалась кровь одного типа
// Это фиксит белую кожу. Костяк, увы.
	var/datum/dna/D = H.dna
	if(!D.species.is_small)
		H.change_dna(D, TRUE, TRUE)

/obj/effect/mob_spawn/human/space_base_syndicate/cargotech
	name = "Syndicate Cargo Technician sleeper"
	mob_name = "Syndicate Cargo Technician"
	id_job = "Syndicate Cargo Technician"
	important_info = "Не мешайте другим оперативникам синдиката (Таким как предатели или ядерные оперативники). Вы можете работать вместе или против не связанных с синдикатом антагонистов в индивидуальном порядке. Не покидайте свою базу без разрешения администрации! Ваша база, её секретность и её сохранность является для вас высшим приоритетом!"
	description = "Даже синдикату нужны рабочие руки, приносите людям их посылки, заказывайте и продавайте, наслаждайтесь простой работой среди всех этих учёных. Здесь всё равно платят в разы лучше!"
	flavour_text = "Вы Грузчик синдиката, работающий на сверхсекретной научно-наблюдательной станции Тайпан, занимающейся созданием биооружия и взаимодействием с чёрным рынком. К несчастью, ваш самый главный враг, компания Нанотрэйзен, имеет собственную массивную научную базу в вашем секторе. Работайте с грузами, заказывайте всё что может потребоваться станции или вам и зарабатывайте реальные деньги, а не виртуальные очки!"
	outfit = /datum/outfit/space_base_syndicate/cargotech

/datum/outfit/space_base_syndicate/cargotech
	name = "Space Base Syndicate Cargo Technician"
	head = /obj/item/clothing/head/soft
	uniform = /obj/item/clothing/under/rank/cargotech
	r_ear = /obj/item/radio/headset/syndicate/alt // See del_types above
	suit = /obj/item/clothing/suit/armor/vest
	id = /obj/item/card/id/syndicate/cargo
	shoes = /obj/item/clothing/shoes/black

/obj/effect/mob_spawn/human/space_base_syndicate/chef
	name = "Syndicate Chef Sleeper"
	mob_name = "Syndicate Chef"
	id_job = "Syndicate Chef"
	important_info = "Не мешайте другим оперативникам синдиката (Таким как предатели или ядерные оперативники). Вы можете работать вместе или против не связанных с синдикатом антагонистов в индивидуальном порядке. Не покидайте свою базу без разрешения администрации! Ваша база, её секретность и её сохранность является для вас высшим приоритетом!"
	description = "Даже синдикату нужны рабочие руки! У вас в распоряжении свой бар, кухня и ботаника. Накормите этих голодных учёных или помогите им создать последнее блюдо для ваших врагов. Здесь всё равно платят в разы лучше!"
	flavour_text = "Вы Повар синдиката, работающий на сверхсекретной научно-наблюдательной станции Тайпан, занимающейся созданием биооружия и взаимодействием с чёрным рынком. К несчастью, ваш самый главный враг, компания Нанотрэйзен, имеет собственную массивную научную базу в вашем секторе. Готовьте еду и напитки экипажу и постарайтесь не высовываться!"
	outfit = /datum/outfit/space_base_syndicate/chef

/obj/effect/mob_spawn/human/space_base_syndicate/chef/special(mob/living/carbon/human/H)
	var/datum/martial_art/cqc/under_siege/justacook = new
	justacook.teach(H)

/datum/outfit/space_base_syndicate/chef
	name = "Space Base Syndicate Chef"
	head = /obj/item/clothing/head/chefhat
	uniform = /obj/item/clothing/under/suit_jacket/charcoal
	r_ear = /obj/item/radio/headset/syndicate/alt // See del_types above
	suit = /obj/item/clothing/suit/chef/classic
	id = /obj/item/card/id/syndicate/kitchen
	shoes = /obj/item/clothing/shoes/black

/obj/effect/mob_spawn/human/space_base_syndicate/engineer
	name = "Syndicate Atmos Engineer Sleeper"
	mob_name = "Syndicate Atmos Engineer"
	id_job = "Syndicate Atmos Engineer"
	important_info = "Не мешайте другим оперативникам синдиката (Таким как предатели или ядерные оперативники). Вы можете работать вместе или против не связанных с синдикатом антагонистов в индивидуальном порядке. Не покидайте свою базу без разрешения администрации! Ваша база, её секретность и её сохранность является для вас высшим приоритетом!"
	description = "Там где есть космическая станция, есть и двигатели с трубами которым нужно своё техобслуживание. Обеспечьте станцию энергией, чините повреждения после неудачных опытов учёных и отдыхайте в баре пока снова что-нибудь не взорвут. "
	flavour_text = "Вы Инженер атмосферник синдиката, работающий на сверхсекретной научно-наблюдательной станции Тайпан, занимающейся созданием биооружия и взаимодействием с чёрным рынком. К несчастью, ваш самый главный враг, компания Нанотрэйзен, имеет собственную массивную научную базу в вашем секторе. Запустите двигатель, убедитесь, что на станцию подаётся достаточно электричества и воздуха, а так же чините отделы которые неприменно сломают."
	outfit = /datum/outfit/space_base_syndicate/engineer

/datum/outfit/space_base_syndicate/engineer
	name = "Space Base Syndicate Engineer"
	head = /obj/item/clothing/head/beret/eng
	r_ear = /obj/item/radio/headset/syndicate/alt // See del_types above
	suit = -1
	belt = /obj/item/storage/belt/utility/atmostech
	id = /obj/item/card/id/syndicate/engineer
	shoes = /obj/item/clothing/shoes/workboots

/obj/effect/mob_spawn/human/space_base_syndicate/comms
	name = "Syndicate Comms Officer sleeper"
	mob_name = "Syndicate Comms Officer"
	id_job = "Syndicate Comms Officer"
	important_info = "Не мешайте другим оперативникам синдиката (Таким как предатели или ядерные оперативники). Вы можете работать вместе или против не связанных с синдикатом антагонистов в индивидуальном порядке. Не покидайте свою базу без разрешения администрации! Ваша база, её секретность и её сохранность является для вас высшим приоритетом!"
	description = "Проверяйте камеры и коммуникации, руководите станцией в случае ЧП, старайтесь помогать любым агентам синдиката на станции при этом сохраняя свою базу секретом от НТ. Вы являетесь единственным агентом с доступом в хранилище и оружейную."
	flavour_text = "Вы Офицер синдиката, работающий на сверхсекретной научно-наблюдательной станции Тайпан, занимающейся созданием биооружия и взаимодействием с чёрным рынком. К несчастью, ваш самый главный враг, компания Нанотрэйзен, имеет собственную массивную научную базу в вашем секторе. Наблюдайте за станцией НТ, руководите вверенной вам базой и постарайтесь не высовываться. \
	Синдикат ясно дал вам понять, что не стоит подводить их доверие. Не разочаруйте их!"
	outfit = /datum/outfit/space_base_syndicate/comms

/datum/outfit/space_base_syndicate/comms
	name = "Space Base Syndicate Comms Officer"
	r_ear = /obj/item/radio/headset/syndicate/alt // See del_types above
	r_hand = /obj/item/twohanded/dualsaber
	mask = /obj/item/clothing/mask/chameleon
	suit = /obj/item/clothing/suit/armor/vest
	r_pocket = /obj/item/gun/projectile/automatic/pistol/deagle
	back = /obj/item/storage/backpack/fluff/syndiesatchel
	id = /obj/item/card/id/syndicate/comms_officer
	backpack_contents = list(
		/obj/item/paper/monitorkey = 1, // message console does NOT spawn with this
		/obj/item/paper/syndicate/code_words = 1,
		/obj/item/ammo_box/magazine/m50 = 3
	)

/obj/effect/mob_spawn/human/space_base_syndicate/rd
	name = "Syndicate Research Director sleeper"
	mob_name = "Syndicate Research Director"
	id_job = "Syndicate Research Director"
	important_info = "Не мешайте другим оперативникам синдиката (Таким как предатели или ядерные оперативники). Вы можете работать вместе или против не связанных с синдикатом антагонистов в индивидуальном порядке. Не покидайте свою базу без разрешения администрации! Ваша база, её секретность и её сохранность является для вас высшим приоритетом!"
	description = "Следите за тем чтобы учёные занимались исследованиями и не подорвали всю станцию, предоставьте синдикату результаты своих исследований через карго и помните, смерть Нанотрейзен!"
	flavour_text = "Вы Директор Исследований синдиката, работающий на сверхсекретной научно-наблюдательной станции Тайпан, занимающейся созданием биооружия и взаимодействием с чёрным рынком. К несчастью, ваш самый главный враг, компания Нанотрэйзен, имеет собственную массивную научную базу в вашем секторе. Продолжайте свои исследования на сколько можете и постарайтесь не высовываться. \
	Вам дали ясно понять, что синдикат заставит вас очень сильно пожалеть если вы разочаруете их!"
	outfit = /datum/outfit/space_base_syndicate/rd

/datum/outfit/space_base_syndicate/rd
	name = "Space Base Syndicate Research Director"
	r_ear = /obj/item/radio/headset/syndicate/alt // See del_types above
	r_hand = /obj/item/melee/classic_baton/telescopic
	l_pocket = /obj/item/melee/energy/sword/saber
	head = /obj/item/clothing/head/beret/sci
	suit = /obj/item/clothing/suit/storage/labcoat/fluff/aeneas_rinil
	back = /obj/item/storage/backpack/fluff/syndiesatchel
	id = /obj/item/card/id/syndicate/research_director
	backpack_contents = list(
		/obj/item/gun/energy/telegun = 1
	)


/datum/antagonist/nuclear_operative
	name = "Ядерный оперативник"
	roundend_category = "nuclear_operative"
	antag_menu_name = "Ядерный оперативник"
	job_rank = ROLE_OPERATIVE
	special_role = ROLE_OPERATIVE
	antag_hud_type = ANTAG_HUD_OPS
	antag_hud_name = "hudoperative"
	russian_wiki_name = "Ядерный_оперативник"
	show_in_roundend = FALSE
	show_in_orbit = FALSE
	var/old_real_name
	var/datum/team/nuclear_team/nuclear_team
	var/greet_name = "Ядерный Оперативник"
	var/list/race_equipment = list(
		SPECIES_PLASMAMAN = /datum/outfit/admin/syndicate/operative/nuclear/plasmaman,
		SPECIES_VOX = /datum/outfit/admin/syndicate/operative/nuclear/vox,
		SPECIES_OTHER = /datum/outfit/admin/syndicate/operative/nuclear
	)
	var/obj/item/uplink/uplink

/datum/antagonist/nuclear_operative/on_gain()
	nuclear_team = team
	. = ..()
	store_nuke_code()

/datum/antagonist/nuclear_operative/proc/store_nuke_code()
	antag_memory = "<b>Код от боеголовки Синдиката</b>: [nuclear_team?.nuke_code]"

/datum/antagonist/nuclear_operative/apply_innate_effects(mob/living/mob_override)
	. = ..()
	owner.offstation_role = TRUE
	owner.current?.faction |= "syndicate"
	old_real_name = owner.current.real_name
	rename()

/datum/antagonist/nuclear_operative/proc/rename()
	owner.current.real_name = "[nuclear_team.syndicate_name] Operative #[LAZYLEN(nuclear_team.members) - 1]"

/datum/antagonist/nuclear_operative/remove_innate_effects(mob/living/mob_override)
	. = ..()
	owner.offstation_role = FALSE
	owner.current?.faction -= "syndicate"
	owner.current.real_name = old_real_name

/datum/antagonist/nuclear_operative/farewell()
	if(issilicon(owner.current))
		to_chat(owner.current, span_userdanger("Вы были превращены в робота! Вы больше не Ядерный Оперативник."))
	else
		to_chat(owner.current, span_userdanger("Вам промли мозги! Вы больше не Ядерный Оперативник."))


/datum/antagonist/nuclear_operative/greet()
	var/list/messages = list()
	SEND_SOUND(owner.current, 'sound/ambience/antag/ops.ogg')
	messages.Add(span_notice("Вы [greet_name]!"))
	messages.Add(additional_messages())
	messages.Add(code_message())
	messages.Add(footer_messages())
	return messages

/datum/antagonist/nuclear_operative/proc/additional_messages()
	var/list/messages = list()
	messages.Add(span_notice("Название вашего отряда: [nuclear_team.syndicate_name]"))
	return messages

/datum/antagonist/nuclear_operative/proc/code_message()
	return span_notice("Код от боеголовки Синдиката: <b>[nuclear_team.nuke_code]</b>")

/datum/antagonist/nuclear_operative/proc/footer_messages()
	var/list/messages = list()
	messages.Add(span_notice("Слушайтесь вашего командира и выполните поставленную задачу."))
	return messages


/datum/antagonist/nuclear_operative/proc/equip()
	var/mob/living/carbon/human/human = owner.current
	if(!istype(human))
		return
	var/race = human.dna.species.name
	var/outfit = (race in race_equipment)? race_equipment[race] : race_equipment[SPECIES_OTHER]
	if(!outfit)
		return

	for (var/obj/item/item in human.get_equipped_items(TRUE, TRUE))
		qdel(item)

	human.equipOutfit(outfit)
	var/obj/item/radio/uplink/nuclear/uplink = locate(/obj/item/radio/uplink/nuclear) in human.contents
	if(!uplink)
		return
	src.uplink = uplink.hidden_uplink

/datum/antagonist/nuclear_operative/leader
	name = "Командир Ядерных Оперативников"
	antag_menu_name = "Командир Ядерных Оперативников"
	greet_name = "командир Ядерных Оперативников"
	race_equipment = list(
		SPECIES_PLASMAMAN = /datum/outfit/admin/syndicate/operative/nuclear/leader/plasmaman,
		SPECIES_VOX = /datum/outfit/admin/syndicate/operative/nuclear/leader/vox,
		SPECIES_OTHER = /datum/outfit/admin/syndicate/operative/nuclear/leader
	)

/datum/antagonist/nuclear_operative/leader/rename()
	owner.current.real_name = "[nuclear_team.syndicate_name] Team [nuclear_team.leader_prefix]"

/datum/antagonist/nuclear_operative/leader/additional_messages()
	var/list/messages = ..()
	messages.Add(span_notice( "<b>Вы лидер отряда. Вы ответственны за проведение операции и составление плана атаки и только ваша карта может открыть шлюз в док с шаттлом.</b>"))
	messages.Add(span_notice( "<b>Если вы чувствуете, что не готовы быть командиром отряда, попросите администрацию поменять вас телами с другим оперативником или призраком.</b>"))
	return messages

/datum/antagonist/nuclear_operative/leader/footer_messages()
	var/list/messages = list()
	messages.Add(span_notice( "<b>В вашей руке вы найдете особый предмет, необходимый для открытого объявления войны станции. Внимательно осмотрите его и проконсультируйтесь с командой, прежде чем активировать его.</b>"))
	return messages

/datum/antagonist/nuclear_operative/reinf
	race_equipment = list(
		SPECIES_OTHER = /datum/outfit/admin/syndicate/operative/nuclear/reinf
	)

/datum/antagonist/nuclear_operative/cyborg
	name = "Борг Ядерных Оперативников"
	antag_menu_name = "Борг Ядерных Оперативников"
	race_equipment = null
	greet_name = "борг Ядерных Оперативников"

/datum/antagonist/nuclear_operative/cyborg/rename()
	return

/datum/antagonist/nuclear_operative/cyborg/equip()
	return

/datum/antagonist/nuclear_operative/cyborg/footer_messages()
	var/list/messages = list()
	messages.Add(span_notice("Слушайтесь членов отряда и помогите им выполнить миссию."))
	return messages

/datum/antagonist/nuclear_operative/loneop
	name = "Ядерный Оперативник - Одиночка"
	antag_menu_name = "Ядерный Оперативник - Одиночка"
	greet_name = "Ядерный Оперативник - Одиночка"
	show_in_roundend = TRUE
	show_in_orbit = TRUE
	race_equipment = list(
		SPECIES_OTHER = /datum/outfit/admin/syndicate/operative/loneop
	)

/datum/antagonist/nuclear_operative/loneop/rename()
	owner.current.real_name = "Syndicate Lone Operative"

/datum/antagonist/nuclear_operative/loneop/store_nuke_code()
	antag_memory = "<b>Код от боеголовки станции [station_name()]</b>: [GLOB.nuke_codes[/obj/machinery/nuclearbomb]]"

/datum/antagonist/nuclear_operative/loneop/give_objectives()
	add_objective(/datum/objective/nuclear)


/datum/antagonist/nuclear_operative/loneop/additional_messages()
	var/list/messages = list()
	messages.Add(span_notice("Вам поручена миссия, которую многие сочтут невыполнимой. Вам необходимо заполучить диск ядерной аутентификации и взвести станционное устройство самоуничтожения."))
	messages.Add(span_notice("В случае, если ядро боеголовки украдено, вам необходимо заполучить его любыми средствами и вернуть в боеголовку для последущей активации. Доступ на вашей карте позволяет вам открывать контейнер, в котором може находится ядро."))
	return messages

/datum/antagonist/nuclear_operative/loneop/code_message()
	return span_notice("Код от боеголовки станции [station_name()]: <b>[GLOB.nuke_codes[/obj/machinery/nuclearbomb]]</b>")

/datum/antagonist/nuclear_operative/loneop/footer_messages()
	return ""

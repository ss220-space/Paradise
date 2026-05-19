/datum/team/vox_raiders
	name = "Vox Raiders"
	antag_datum_type = /datum/antagonist/vox_raider

/datum/team/vox_raiders/New(list/starting_members)
	. = ..()
	forge_objectives()

/datum/team/vox_raiders/proc/forge_objectives()
	PRIVATE_PROC(TRUE)
	objectives |= new /datum/objective/raider_steal()
	var/list/possible_collect_objective_types = list(
		/datum/objective/raider_entirety_steal,
		/datum/objective/raider_collection_access,
		/datum/objective/raider_collection_tech
	)
	var/picked_collect_objective_type = pick(possible_collect_objective_types)
	objectives |= new picked_collect_objective_type()
	objectives |= new /datum/objective/survive/vox

/datum/team/vox_raiders/add_member(datum/mind/new_member, add_objectives)
	. = ..()
	update_team_name()

/datum/team/vox_raiders/remove_member(datum/mind/member, force = FALSE)
	. = ..()
	update_team_name()

/datum/team/vox_raiders/proc/update_team_name()
	PRIVATE_PROC(TRUE)
	var/new_name = get_raider_names_text()
	if(!new_name)
		name = initial(name)
		return

	name = "[initial(name)] of [new_name]"

/datum/team/vox_raiders/proc/get_raider_names_text(datum/mind/raider_to_exclude)
	var/list/raider_names = list()
	for(var/datum/mind/raider as anything in members)
		if(raider == raider_to_exclude)
			continue

		raider_names += raider.name

	return raider_names.Join(", ")

/datum/team/vox_raiders/declare_completion()
	. = list()
	var/teamwin = TRUE
	.+= "<br><b>Стая [name]</b>"
	for(var/datum/objective/objective in objectives)
		if(!objective.check_completion())
			teamwin = FALSE
	if(teamwin)
		. += span_green("<br><b>Стая успешно завершила свои цели!</b>")
	else
		. += span_red("<br><b>Стая провалилась!</b>")
	var/num_survive = length(members)
	for(var/datum/mind/mind in members)
		if(!mind.current || mind.current.stat == DEAD)
			num_survive--
	if(num_survive == length(members))
		. += span_green("<br><b>Вся стая выжила!</b>")
	else if(num_survive <= 0)
		. += span_red("<br><b>Вся стая погибла!</b>")
	else
		. += span_orange("<br><b>У стаи есть потери!</b>")
	var/list/score = declare_completion_score()
	. += score.Join("")

/datum/team/vox_raiders/proc/declare_completion_score()
	. = list(span_fontsize3("<br><b>Прогресс Вокс'ов:</b>"))
	var/obj/machinery/vox_trader/trader = locate() in SSmachines.get_by_type(/obj/machinery/vox_trader)
	if(!trader)
		. += "<br>"
		return
	trader.synchronize_traders_stats()

	. += "<br><br><b>Всего заработано Кикиридитов:</b> [trader.all_values_sum]"

	var/precious_count = 0
	var/biggest_index
	for(var/item in trader.precious_collected_dict)
		var/value = trader.precious_collected_dict[item][VOX_TRADER_VALUE]
		var/count = trader.precious_collected_dict[item][VOX_TRADER_COUNT]
		precious_count += count
		if(!biggest_index || trader.precious_collected_dict[biggest_index][VOX_TRADER_VALUE] <= value)
			biggest_index = item

	. += "<br><b>Самый дорогой проданный товар:</b> \
		<br>[biggest_index] ([trader.precious_collected_dict[biggest_index][VOX_TRADER_VALUE]]), \
		всего продано [trader.precious_collected_dict[biggest_index][VOX_TRADER_COUNT]] штук."

	. += "<br><br><b>Собраны доступы:<br></b>"
	var/list/checked_accesses = list()
	var/list/region_codes = list(
		REGION_GENERAL, REGION_SECURITY, REGION_MEDBAY, REGION_RESEARCH,
		REGION_ENGINEERING, REGION_SUPPLY, REGION_COMMAND, REGION_CENTCOMM
	)

	for(var/code in region_codes)
		var/list/region_accesses
		if(code != REGION_CENTCOMM)
			region_accesses = get_region_accesses(code)
		else
			region_accesses = list(ACCESS_CENT_GENERAL)
		for(var/access in trader.collected_access_list)
			if(access in region_accesses)
				region_accesses.Remove(access)
		checked_accesses["[code]"] = region_accesses

	var/access_count = 0
	for(var/code in region_codes)
		if(length(checked_accesses["[code]"]) > 0)
			continue
		switch(code)
			if(REGION_GENERAL)
				. += "Собраны все общественные и сервисные доступы!"
			if(REGION_SECURITY)
				. += span_red("<br>Собраны все доступы службы безопасности!")
			if(REGION_MEDBAY)
				. += span_color("<br>Собраны все доступы медицинского отдела!", "teal")
			if(REGION_RESEARCH)
				. += span_purple("<br>Собраны все доступы научного отдела!")
			if(REGION_ENGINEERING)
				. += span_orange("<br>Собраны все инженерные доступы!")
			if(REGION_SUPPLY)
				. += span_color("<br><font color='brown'>Собраны все доступы отдела снабжения!", "brown")
			if(REGION_COMMAND)
				. += span_blue("<br>Собраны все командные доступы!")
			if(REGION_CENTCOMM)
				. += span_green("<br><b>Получен особый доступ к Центральному Командованию!</b>")
		access_count++

	if(!access_count)
		. += "<br>Ни одного полного отдела доступов!"

	. += "<br><br><b>Собраны технологии:</b>"
	for(var/i in trader.collected_tech_dict)
		. += "<br>[i]: [trader.collected_tech_dict[i]]"

	. += "<br>"

/proc/create_vox_team(count)
	var/image/source = image('icons/obj/cardboard_cutout.dmi', "vox_raider")
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Вы хотите стать частью стаи воксов-рейдеров, прибывающей на станцию?", ROLE_VOX_RAIDER, source = source, role_cleanname = "Вокса-рейдера")

	if(!length(candidates))
		return FALSE

	var/num = min(length(candidates), count)
	list_clear_nulls(candidates)
	var/list/assigned = list()
	for(var/i in 1 to num)
		if(i >= count)
			break
		var/candidate = pick(candidates)
		assigned.Add(candidate)
		candidates.Remove(candidate)

	for(var/mob/dead/observer/candidate as anything in assigned)
		var/mob/living/carbon/human/body = new(pick(GLOB.raider_spawn))
		body.possess_by_player(candidate.ckey)
		transform_body_vox_raider(body)
		body.mind.add_antag_datum(/datum/antagonist/vox_raider, /datum/team/vox_raiders)
		body.equipOutfit(/datum/outfit/vox)

/proc/transform_body_vox_raider(mob/living/carbon/human/target)

	var/sounds = rand(2, 8)
	var/i = 0
	var/list/newname = list()

	while(i <= sounds)
		i++
		newname += pick(list("ti", "hi", "ki", "ya", "ta", "ha", "ka", "ya", "chi", "cha", "kah"))

	var/mob/living/carbon/human/vox = target
	var/obj/item/organ/external/head/head_organ = vox.get_organ(BODY_ZONE_HEAD)

	vox.real_name = capitalize(newname.Join(""))
	vox.dna.real_name = vox.real_name
	vox.name = vox.real_name
	target.mind?.name = vox.name
	vox.age = rand(12, 20)
	vox.set_species(/datum/species/vox)
	vox.s_tone = rand(1, 6)
	LAZYREINITLIST(vox.languages)
	vox.flavor_text = ""
	vox.add_language(LANGUAGE_VOX)
	vox.add_language(LANGUAGE_GALACTIC_COMMON)
	vox.add_language(LANGUAGE_TRADER)
	head_organ.h_style = "Short Vox Quills"
	head_organ.f_style = "Shaved"
	vox.change_hair_color(97, 79, 25)
	vox.change_eye_color(rand(1, 255), rand(1, 255), rand(1, 255))
	vox.underwear = "Nude"
	vox.undershirt = "Nude"
	vox.socks = "Nude"
	vox.force_update_limbs()
	vox.update_dna()
	vox.update_eyes()

	for(var/obj/item/organ/external/limb as anything in vox.bodyparts)
		limb.status &= ~ORGAN_ROBOT

	var/obj/item/implant/cortical/stack = new(vox)
	stack.implant(vox)

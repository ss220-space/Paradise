// Syndicate Infiltration Team (SIT)
// A little like Syndicate Strike Team (SST) but geared towards stealthy team missions rather than murderbone.

GLOBAL_VAR_INIT(sent_syndicate_infiltration_team, 0)

/client/proc/syndicate_infiltration_team()
	set category = "Event"
	set name = "Отправить Диверсионный Отряд Синдиката"
	set desc = "Спавнит Диверсионный Отряд Синдиката в их месте постоянной дислокации на СЦК."
	if(!check_rights(R_ADMIN))
		to_chat(src, "Только администраторы могут использовать эту команду.")
		return
	if(!SSticker)
		tgui_alert(src, "Игра еще не началась!")
		return
	if(tgui_alert(src, "Вы хотите отправить Диверсионный Отряд Синдиката?", "Подтверждение", list("Да","Нет")) != "Да")
		return
	var/spawn_dummies = 0
	if(tgui_alert(src, "Создавать полноразмерную команду, даже если призраков недостаточно для их заполнения?", "Подтверждение", list("Да","Нет")) == "Да")
		spawn_dummies = 1
	var/list/teamsizeoptions = list(2,3,4,5,6)
	var/teamsize = tgui_input_list(src, "Сколько должно быть членов, включая лидера?","Количество членов отряда", teamsizeoptions)
	if(!(teamsize in teamsizeoptions))
		tgui_alert(src, "Недопустимый размер команды. Отмена.")
		return
	var/input = null
	while(!input)
		input = tgui_input_text(src, "Пожалуйста, уточните, какую миссию будет выполнять Диверсионный Отряд Синдиката.", "Укажите миссию", "", max_length=MAX_MESSAGE_LEN)
		if(!input)
			tgui_alert(src, "Миссия не указана. Отмена.")
			return
	var/tcamount = tgui_input_number(src, "Как много ТК вы хотите дать каждому члену команды? Рекомендовано: 100-150. Они не могут продавать ТК.","Количество ТК", 100, 5000)

	if(GLOB.sent_syndicate_infiltration_team == 1)
		if(tgui_alert(src, "Диверсионный Отряд Синдиката уже был отправлен. Нужно ли посылать еще один?","Подтверждение", list("Да","Нет")) != "Да")
			return

	var/syndicate_leader_selected = 0

	var/list/infiltrators = list()

	var/image/I = new('icons/obj/cardboard_cutout.dmi', "cutout_sit")
	infiltrators = pick_candidates_all_types(src, teamsize, "Вы хотите поиграть за Диверсанта Синдиката?", ROLE_TRAITOR, 21, 30 SECONDS, FALSE, GLOB.role_playtime_requirements[ROLE_TRAITOR], TRUE, FALSE, I, "Диверсант Синдиката", input)

	if(!infiltrators.len)
		to_chat(src, "Никто не захотел быть Диверсантом Синдиката.")
		return 0

	GLOB.sent_syndicate_infiltration_team = 1

	var/list/sit_spawns = list()
	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		if(L.name == "Syndicate-Infiltrator")
			sit_spawns += L

	var/num_spawned = 1
	var/team_leader = null
	for(var/obj/effect/landmark/L in sit_spawns)
		if(!infiltrators.len && !spawn_dummies) break
		syndicate_leader_selected = num_spawned == 1?1:0
		var/mob/living/carbon/human/new_syndicate_infiltrator = create_syndicate_infiltrator(L, syndicate_leader_selected, tcamount, 0)
		if(infiltrators.len)
			var/mob/theguy = pick(infiltrators)
			if(theguy.key != key)
				new_syndicate_infiltrator.key = theguy.key
				new_syndicate_infiltrator.internal = new_syndicate_infiltrator.s_store
				new_syndicate_infiltrator.update_action_buttons_icon()
			infiltrators -= theguy
		to_chat(new_syndicate_infiltrator, span_danger("Вы [!syndicate_leader_selected?"Диверсант":"<B>Командир Диверсантов</B>"] в подчинении Синдиката. \nВаша миссия: <B>[input]</B>"))
		to_chat(new_syndicate_infiltrator, span_notice("Вы оснащены имплантом аплинка, который поможет вам достичь ваших целей. ((активируйте его с помощью кнопки в левом верхнем углу экрана))"))
		new_syndicate_infiltrator.faction += "syndicate"
		GLOB.data_core.manifest_inject(new_syndicate_infiltrator)
		if(syndicate_leader_selected)
			team_leader = new_syndicate_infiltrator
			to_chat(new_syndicate_infiltrator, span_danger("Как лидер отряда, вы должны организовать его! Отдайте роль кому-нибудь другому, если вы не можете с ней справиться."))
		else
			to_chat(new_syndicate_infiltrator, span_danger("Лидер отряда: [team_leader]. Он отвечает за миссию!"))
		teamsize--
		to_chat(new_syndicate_infiltrator, span_notice("В ваших заметках хранится еще больше полезной информации."))
		new_syndicate_infiltrator.mind.store_memory("<B>Миссия:</B> [input] ")
		new_syndicate_infiltrator.mind.store_memory("<B>Лидер:</B> [team_leader] ")
		new_syndicate_infiltrator.mind.store_memory("<B>Стартовое снаряжение:</B> <BR>- Наушник синдиката ((:t для вашего канала))<BR>- Хамелион-комбинезон ((правый щелчок мыши для смены цвета))<BR> - ID карта агента ((Может изменять должность и другие данные))<BR> - Имплант аплинка ((в левом верхнем углу экрана)) <BR> - Имплант распыления ((превращает тело при смерти в пыль)) <BR> - Боевые перчатки ((изолированы, замаскированны под черные перчатки)) <BR> - Все, что куплено с помощью вашего импланта аплинка")
		var/datum/atom_hud/antag/opshud = GLOB.huds[ANTAG_HUD_OPS]
		opshud.join_hud(new_syndicate_infiltrator.mind.current)
		set_antag_hud(new_syndicate_infiltrator.mind.current, "hudoperative")
		new_syndicate_infiltrator.regenerate_icons()
		num_spawned++
		if(!teamsize)
			break
	log_and_message_admins("has spawned a Syndicate Infiltration Team.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn SIT") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

// ---------------------------------------------------------------------------------------------------------

/client/proc/create_syndicate_infiltrator(obj/spawn_location, syndicate_leader_selected = 0, uplink_tc = 20, is_mgmt = 0)
	var/mob/living/carbon/human/new_syndicate_infiltrator = new(spawn_location.loc)

	var/syndicate_infiltrator_name = random_name(pick(MALE,FEMALE))

	var/datum/preferences/A = new() //Randomize appearance
	A.real_name = syndicate_infiltrator_name
	A.copy_to(new_syndicate_infiltrator)
	new_syndicate_infiltrator.dna.ready_dna(new_syndicate_infiltrator)

	//Creates mind stuff.
	new_syndicate_infiltrator.mind_initialize()
	new_syndicate_infiltrator.mind.assigned_role = "Syndicate Infiltrator"
	new_syndicate_infiltrator.mind.special_role = "Syndicate Infiltrator"
	new_syndicate_infiltrator.mind.offstation_role = TRUE //they can flee to z2 so make them inelligible as antag targets
	SSticker.mode.traitors |= new_syndicate_infiltrator.mind //Adds them to extra antag list
	new_syndicate_infiltrator.change_voice()
	new_syndicate_infiltrator.equip_syndicate_infiltrator(syndicate_leader_selected, uplink_tc, is_mgmt)
	return new_syndicate_infiltrator

// ---------------------------------------------------------------------------------------------------------

/mob/living/carbon/human/proc/equip_syndicate_infiltrator(syndicate_leader_selected = 0, num_tc, flag_mgmt)
	// Storage items
	equip_to_slot_or_del(new /obj/item/storage/backpack(src), ITEM_SLOT_BACK)
	equip_to_slot_or_del(new /obj/item/storage/box/survival(src), ITEM_SLOT_BACKPACK)
	equip_to_slot_or_del(new /obj/item/clothing/under/chameleon(src), ITEM_SLOT_CLOTH_INNER)
	if(!flag_mgmt)
		equip_to_slot_or_del(new /obj/item/flashlight(src), ITEM_SLOT_BACKPACK)
		equip_to_slot_or_del(new /obj/item/storage/belt/utility/full/multitool(src), ITEM_SLOT_BELT)

	var/obj/item/clothing/gloves/combat/G = new /obj/item/clothing/gloves/combat(src)
	G.name = "black gloves"
	equip_to_slot_or_del(G, ITEM_SLOT_GLOVES)

	// Implants:
	// Uplink
	var/obj/item/implant/uplink/sit/U = new /obj/item/implant/uplink/sit(src)
	U.implant(src)
	if (flag_mgmt)
		U.hidden_uplink.uses = 2500
	else
		U.hidden_uplink.uses = num_tc
	// Dust
	var/obj/item/implant/dust/D = new /obj/item/implant/dust(src)
	D.implant(src)

	// Radio & PDA
	var/obj/item/radio/R = new /obj/item/radio/headset/syndicate/syndteam(src)
	R.set_frequency(SYNDTEAM_FREQ)
	equip_to_slot_or_del(R, ITEM_SLOT_EAR_LEFT)
	equip_or_collect(new /obj/item/pda(src), ITEM_SLOT_BACKPACK)

	// Other gear
	equip_to_slot_or_del(new /obj/item/clothing/shoes/chameleon/noslip(src), ITEM_SLOT_FEET)

	var/obj/item/card/id/syndicate/W = new(src)
	if (flag_mgmt)
		W.icon_state = "commander"
	else
		W.icon_state = "id"
	W.access = list(ACCESS_MAINT_TUNNELS,ACCESS_EXTERNAL_AIRLOCKS)
	W.assignment = JOB_TITLE_CIVILIAN
	W.access += get_access(JOB_TITLE_CIVILIAN)
	W.access += list(ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CARGO, ACCESS_RESEARCH)
	if(flag_mgmt)
		W.assignment = "Syndicate Management Consultant"
		W.access += get_syndicate_access("Syndicate Commando")
	else if(syndicate_leader_selected)
		W.access += get_syndicate_access("Syndicate Commando")
	else
		W.access += get_syndicate_access("Syndicate Operative")
	W.name = "[real_name]'s ID Card ([W.assignment])"
	W.registered_name = real_name
	equip_to_slot_or_del(W, ITEM_SLOT_ID)

	return 1

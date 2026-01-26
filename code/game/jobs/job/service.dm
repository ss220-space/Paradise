/datum/job/head_of_staff/hop
	title = JOB_TITLE_HOP
	flag = JOB_FLAG_HOP
	department = STATION_DEPARTMENT_SERVICE
	department_flag = JOBCAT_SUPPORT
	is_service = 1
	blocked_race_for_job = list(SPECIES_VOX)
	selection_color = "#6bef76"
	access = list(
		ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
		ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_EVA, ACCESS_HEADS,
		ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
		ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_LAWYER,
		ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
		ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM
	)
	minimal_access = list(
		ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
		ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_EVA, ACCESS_HEADS,
		ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
		ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_LAWYER,
		ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
		ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM
	)
	exp_type = EXP_TYPE_SERVICE
	outfit = /datum/outfit/job/hop

/datum/outfit/job/hop
	name = JOB_TITLE_HOP
	jobtype = /datum/job/head_of_staff/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel_alt
	suit = /obj/item/clothing/suit/hop_jacket
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/hopcap
	glasses = /obj/item/clothing/glasses/hud/skills/sunglasses
	l_ear = /obj/item/radio/headset/heads/hop
	id = /obj/item/card/id/silver
	l_pocket = /obj/item/lighter/zippo/hop
	pda = /obj/item/pda/heads/hop
	backpack_contents = list(
		/obj/item/storage/box/ids = 1,
		/obj/item/melee/baton/telescopic = 1,
	)

	implants = list()

/datum/job/service
	department = STATION_DEPARTMENT_SERVICE
	department_flag = JOBCAT_SUPPORT
	is_service = 1
	supervisors = "Главой персонала"
	department_head = list(JOB_TITLE_HOP)
	selection_color = "#d1e8d3"
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW
	paycheck = PAYCHECK_CREW

/datum/job/service/bartender
	title = JOB_TITLE_BARTENDER
	flag = JOB_FLAG_BARTENDER
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_BAR, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Barman", "Barkeeper", "Drink Artist")
	outfit = /datum/outfit/job/bartender

/datum/outfit/job/bartender
	name = JOB_TITLE_BARTENDER
	jobtype = /datum/job/service/bartender

	uniform = /obj/item/clothing/under/rank/bartender
	suit = /obj/item/clothing/suit/armor/vest
	belt = /obj/item/storage/belt/bandolier/full
	l_ear = /obj/item/radio/headset/headset_service
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	pda = /obj/item/pda/bar
	backpack_contents = list(
		/obj/item/toy/russian_revolver = 1,
	)

/datum/outfit/job/bartender/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	H.force_gene_block(GLOB.soberblock, TRUE, TRUE)

/datum/job/service/chef
	title = JOB_TITLE_CHEF
	flag = JOB_FLAG_CHEF
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_KITCHEN, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Cook", "Culinary Artist", "Butcher")
	outfit = /datum/outfit/job/chef

/datum/outfit/job/chef
	name = JOB_TITLE_CHEF
	jobtype = /datum/job/service/chef

	uniform = /obj/item/clothing/under/rank/chef
	suit = /obj/item/clothing/suit/chef
	belt = /obj/item/storage/belt/chef
	head = /obj/item/clothing/head/chefhat
	l_ear = /obj/item/radio/headset/headset_service
	pda = /obj/item/pda/chef
	backpack_contents = list(
		/obj/item/paper/chef=1,\
		/obj/item/book/manual/chef_recipes=1)

/datum/outfit/job/chef/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	var/datum/martial_art/cqc/under_siege/justacook = new
	justacook.teach(H)

/datum/outfit/job/chef/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Culinary Artist")
				uniform = /obj/item/clothing/under/artist
				belt = /obj/item/storage/belt/chef/artistred
				head = /obj/item/clothing/head/chefcap
				suit = /obj/item/clothing/suit/storage/chefbluza

/datum/job/service/botanist
	title = JOB_TITLE_BOTANIST
	flag = JOB_FLAG_BOTANIST
	total_positions = 2
	spawn_positions = 2
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_HYDROPONICS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Hydroponicist", "Botanical Researcher")
	outfit = /datum/outfit/job/botanist

/datum/outfit/job/botanist
	name = JOB_TITLE_BOTANIST
	jobtype = /datum/job/service/botanist

	uniform = /obj/item/clothing/under/rank/hydroponics
	suit = /obj/item/clothing/suit/apron
	gloves = /obj/item/clothing/gloves/botanic_leather
	l_ear = /obj/item/radio/headset/headset_service
	suit_store = /obj/item/plant_analyzer
	pda = /obj/item/pda/botanist

	backpack = /obj/item/storage/backpack/botany
	satchel = /obj/item/storage/backpack/satchel_hyd
	dufflebag = /obj/item/storage/backpack/duffel/hydro

/datum/job/service/clown
	title = JOB_TITLE_CLOWN
	flag = JOB_FLAG_CLOWN
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_CLOWN, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_CLOWN, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Performance Artist", "Comedian", "Jester")
	outfit = /datum/outfit/job/clown

/datum/outfit/job/clown
	name = JOB_TITLE_CLOWN
	jobtype = /datum/job/service/clown

	uniform = /obj/item/clothing/under/rank/clown
	belt = /obj/item/signmaker
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	l_ear = /obj/item/radio/headset/headset_service
	id = /obj/item/card/id/clown
	pda = /obj/item/pda/clown
	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/stamp/clown = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/storage/fancy/crayons = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofbanana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/clown_recorder = 1,
	)

	implants = list(/obj/item/implant/sad_trombone)

	backpack = /obj/item/storage/backpack/clown
	satchel = /obj/item/storage/backpack/satchel_clown
	dufflebag = /obj/item/storage/backpack/duffel/clown

/datum/outfit/job/clown/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.gender == FEMALE)
		mask = /obj/item/clothing/mask/gas/clown_hat/sexy
		uniform = /obj/item/clothing/under/rank/clown/sexy

/datum/outfit/job/clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(ismachineperson(H))
		var/obj/item/organ/internal/cyberimp/brain/clown_voice/implant = new
		implant.insert(H)

	H.force_gene_block(GLOB.clumsyblock, TRUE, TRUE)
	H.force_gene_block(GLOB.comicblock, TRUE, TRUE)
	H.add_language(LANGUAGE_CLOWN)
	H.grant_mimicking()

/mob/living/carbon/human/proc/grant_mimicking()
	if(!(locate(/datum/action/innate/mimicking) in actions))
		var/datum/action/innate/mimicking/mimicking = new
		mimicking.Grant(src)
	add_verb(src, /mob/living/carbon/human/proc/mimicking)

/datum/action/innate/mimicking
	name = "Подражание"
	button_icon_state = "clown"
	check_flags = AB_CHECK_CONSCIOUS
	var/list/voice_slots = list()
	var/empty_slots = 3
	var/list/available_voices
	var/datum/mimicking_voice/selected

/datum/action/innate/mimicking/New()
	..()
	var/donor_level = owner?.client ? owner.client.donator_level : 0
	available_voices = list()
	for(var/level in 0 to donor_level)
		available_voices += SStts.tts_seeds_names_by_donator_levels["[level]"]

/datum/action/innate/mimicking/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return FALSE
	ui_interact(owner)

/datum/action/innate/mimicking/ui_state(mob/user)
	return GLOB.conscious_state

/datum/action/innate/mimicking/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mimicking", "Подражание")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/action/innate/mimicking/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	var/datum/mimicking_voice/voice
	if(params["id"])
		for(var/datum/mimicking_voice/find_voice in voice_slots)
			if(find_voice.UID() != params["id"])
				continue
			voice = find_voice
	switch(action)
		if("Choose")
			if(!voice)
				stack_trace("Mimicking can not find it own voice.")
				return
			if(voice.selected)
				return
			set_selected(voice)
			owner.update_tts_seed(voice.voice)
		if("Delete")
			if(!voice)
				stack_trace("Mimicking can not find it own voice.")
				return
			if(voice.selected)
				selected = null
			voice_slots -= voice
			empty_slots++
		if("Add")
			if(empty_slots < 1)
				to_chat(owner, span_notice("У вас нет свободных слотов."))
				return
			var/voice_name = tgui_input_text(owner, "Выберите имя для слота", "Подражание")
			if(!voice_name)
				return
			var/voice_seed = tgui_input_list(owner, "Выберите TTS-голос для слота.", "Подражание", available_voices, owner.tts_seed)
			if(!voice_seed)
				return
			var/new_voice = new /datum/mimicking_voice(voice_name, voice_seed)
			add_voice(new_voice)
	SStgui.update_uis(src)

/datum/action/innate/mimicking/ui_data(mob/user)
	var/list/data = list()
	var/list/slots = list()
	for(var/datum/mimicking_voice/voice in voice_slots)
		if(istype(voice))
			slots += list(voice.voice_data())
	data["slots"] = slots
	return data

/datum/action/innate/mimicking/proc/set_selected(datum/mimicking_voice/new_voice)
	if(selected)
		selected.selected = FALSE
	selected = new_voice
	selected.selected = TRUE

/datum/action/innate/mimicking/proc/add_voice(datum/mimicking_voice/voice)
	voice_slots += voice
	empty_slots--

/datum/action/innate/mimicking/proc/remove_voice(datum/mimicking_voice/voice)
	voice_slots -= voice
	empty_slots++

/datum/mimicking_voice
	var/name
	var/voice
	var/selected = FALSE

/datum/mimicking_voice/New(name, voice)
	src.name = name
	src.voice = voice

/datum/mimicking_voice/proc/voice_data()
	return list("name" = name, "voice" = voice, "selected" = selected, "id" = UID())

/mob/living/carbon/human/proc/mimicking(mob/living/carbon/human/H)
	set name = "Имитировать голос"
	set category = STATPANEL_IC
	if(!H)
		to_chat(usr, span_notice("Используйте <b>ПКМ</b> для выбора цели."))
	var/datum/action/innate/mimicking/mimic = locate(/datum/action/innate/mimicking) in usr.actions
	if(!mimic)
		return
	if(mimic.empty_slots < 1)
		to_chat(usr, span_notice("У вас нет свободных слотов."))
		return
	var/new_voice = new /datum/mimicking_voice(H.name, H.tts_seed)
	mimic.add_voice(new_voice)
	SStgui.update_uis(mimic)

//action given to antag clowns
/datum/action/innate/toggle_clumsy
	name = "Переключить клоунскую неуклюжесть"
	button_icon_state = "clown"

/datum/action/innate/toggle_clumsy/Activate()
	var/mob/living/carbon/human/clown = owner
	if(!clown.force_gene_block(GLOB.clumsyblock, TRUE))
		return
	active = TRUE
	background_icon_state = "bg_spell"
	UpdateButtonIcon()
	to_chat(clown, span_notice("Вы начинаете вести тебя неуклюже, чтобы сбросить с себя подозрения."))

/datum/action/innate/toggle_clumsy/Deactivate()
	var/mob/living/carbon/human/clown = owner
	if(!clown.force_gene_block(GLOB.clumsyblock, FALSE))
		return
	active = FALSE
	background_icon_state = "bg_default"
	UpdateButtonIcon()
	to_chat(clown, span_notice("Вы фокусируетесь на задаче и перестаёте вести себя неуклюже."))

/datum/job/service/mime
	title = JOB_TITLE_MIME
	flag = JOB_FLAG_MIME
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_MIME, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MIME, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Panthomimist")
	outfit = /datum/outfit/job/mime

/datum/outfit/job/mime
	name = JOB_TITLE_MIME
	jobtype = /datum/job/service/mime

	uniform = /obj/item/clothing/under/mime
	suit = /obj/item/clothing/suit/suspenders
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/beret
	mask = /obj/item/clothing/mask/gas/mime
	l_ear = /obj/item/radio/headset/headset_service
	id = /obj/item/card/id/mime
	pda = /obj/item/pda/mime
	backpack_contents = list(
		/obj/item/toy/crayon/mime = 1,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing = 1,
		/obj/item/cane = 1,
	)
	backpack = /obj/item/storage/backpack/mime
	satchel = /obj/item/storage/backpack/satchel_mime

/datum/outfit/job/mime/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/mimeskirt
		mask = /obj/item/clothing/mask/gas/mime/sexy

/datum/outfit/job/mime/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/conjure/build/mime_wall(null))
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/mime/speak(null))
		H.mind.miming = TRUE

/datum/job/service/janitor
	title = JOB_TITLE_JANITOR
	flag = JOB_FLAG_JANITOR
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Custodial Technician", "Sanitation Technician")
	outfit = /datum/outfit/job/janitor

/datum/outfit/job/janitor
	name = JOB_TITLE_JANITOR
	jobtype = /datum/job/service/janitor

	uniform = /obj/item/clothing/under/rank/janitor
	l_ear = /obj/item/radio/headset/headset_service
	pda = /obj/item/pda/janitor

/datum/job/service/librarian
	title = JOB_TITLE_LIBRARIAN
	flag = JOB_FLAG_LIBRARIAN
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Journalist")
	outfit = /datum/outfit/job/librarian

/datum/outfit/job/librarian
	name = JOB_TITLE_LIBRARIAN
	jobtype = /datum/job/service/librarian

	uniform = /obj/item/clothing/under/suit_jacket/red
	l_ear = /obj/item/radio/headset/headset_service
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/barcodescanner
	l_hand = /obj/item/storage/bag/books
	pda = /obj/item/pda/librarian
	backpack_contents = list(
		/obj/item/videocam = 1,
	)

/datum/job/service/chaplain
	title = JOB_TITLE_CHAPLAIN
	flag = JOB_FLAG_CHAPLAIN
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_MORGUE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MORGUE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Priest", "Monk", "Preacher", "Reverend", "Oracle", "Nun", "Imam", "Exorcist")
	outfit = /datum/outfit/job/chaplain

/datum/outfit/job/chaplain
	name = JOB_TITLE_CHAPLAIN
	jobtype = /datum/job/service/chaplain

	uniform = /obj/item/clothing/under/rank/chaplain
	l_ear = /obj/item/radio/headset/headset_service
	pda = /obj/item/pda/chaplain
	backpack_contents = list(
		/obj/item/camera/spooky = 1,
		/obj/item/nullrod = 1,
	)

/datum/outfit/job/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	if(visualsOnly)
		return

	if(H.mind)
		H.mind.isholy = TRUE
		ADD_TRAIT(H, TRAIT_HEALS_FROM_HOLY_PYLONS, INNATE_TRAIT)

	INVOKE_ASYNC(src, PROC_REF(religion_pick), H)

/datum/outfit/job/chaplain/proc/religion_pick(mob/living/carbon/human/user)
	var/obj/item/storage/bible/bible = new /obj/item/storage/bible(get_turf(user))
	bible.customisable = TRUE // Only the initial bible is customisable
	user.put_in_l_hand(bible)

	var/religion_name = "Christianity"
	var/new_religion = tgui_input_text(user, "You are the Chaplain. What name do you give your beliefs? Default is Christianity.", "Name change", religion_name, max_length = MAX_NAME_LEN)

	if(!new_religion)
		new_religion = religion_name

	switch(lowertext(new_religion))
		if("christianity")
			bible.name = "The Holy Bible"
		if("satanism")
			bible.name = "The Unholy Bible"
		if("cthulu")
			bible.name = "The Necronomicon"
		if("islam")
			bible.name = "Quran"
		if("scientology")
			bible.name = pick("The Biography of L. Ron Hubbard", "Dianetics")
		if("chaos")
			bible.name = "The Book of Lorgar"
		if("imperium")
			bible.name = "Uplifting Primer"
		if("toolboxia")
			bible.name = "Toolbox Manifesto Robusto"
		if("science")
			bible.name = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
		else
			bible.name = "The Holy Book of [new_religion]"
	SSblackbox.record_feedback("text", "religion_name", 1, "[new_religion]", 1)

	var/deity_name = "Space Jesus"
	var/new_deity = tgui_input_text(user, "Who or what do you worship? Default is Space Jesus.", "Name change", deity_name, max_length = MAX_NAME_LEN)

	if(!length(new_deity) || (new_deity == "Space Jesus"))
		new_deity = deity_name
	bible.deity_name = new_deity
	SSblackbox.record_feedback("text", "religion_deity", 1, "[new_deity]", 1)

	user.AddSpell(new /obj/effect/proc_holder/spell/chaplain_bless(null))

	if(SSticker)
		SSticker.Bible_deity_name = bible.deity_name

/datum/job/service/explorer
	title = JOB_TITLE_EXPLORER
	flag = JOB_FLAG_EXPLORER
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_GATEWAY, ACCESS_EVA, ACCESS_EXTERNAL_AIRLOCKS)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_GATEWAY, ACCESS_EVA, ACCESS_EXTERNAL_AIRLOCKS)
	outfit = /datum/outfit/job/explorer
	hidden_from_job_prefs = TRUE

/datum/outfit/job/explorer
	// This outfit is never used, because there are no slots for this job.
	// To get it, you have to go to the HOP and ask for a transfer to it.
	name = JOB_TITLE_EXPLORER
	jobtype = /datum/job/service/explorer
	uniform = /obj/item/clothing/under/color/random

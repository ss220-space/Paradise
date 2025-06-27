#define PRE_TITLE 1
#define TITLE 2
#define SYLLABLE 3
#define MULTIPLE_SYLLABLE 4
#define SUFFIX 5
/obj/item/book/codex_gigas
	name = "Codex Gigas"
	icon_state ="demonomicon"
	throw_speed = 1
	throw_range = 10
	lefthand_file = 'icons/mob/inhands/chaplain_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/chaplain_righthand.dmi'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	author = "Силы, находящиеся за пределами вашего понимания"
	unique = TRUE
	title = "Кодекс Гигас"
	var/currentName = ""
	var/is_used = FALSE
	var/currentSection = PRE_TITLE
	var/datum/devilinfo/current_devil

/obj/item/book/codex_gigas/attack_self(mob/user)
	if(!user.has_vision())
		return

	if(!user.is_literate())
		to_chat(user, span_notice("Вы не умеете читать."))
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human = user

	if(locate(/datum/objective/sintouched/acedia) in human.mind?.objectives)
		to_chat(user, span_notice("Ничего из этого не имеет значения, зачем вы это читаете?."))
		return

	ask_name(user)

/obj/item/book/codex_gigas/proc/perform_research(mob/living/carbon/human, devil_name)
	var/speed = 30 SECONDS
	var/correctness = 85
	var/willpower = 95
	is_used = TRUE
	if(human.job in list(JOB_TITLE_LIBRARIAN)) // the librarian is both faster, and more accurate than normal crew members at research
		speed = 4.5 SECONDS
		correctness = 100
		willpower = 100

	if(human.job in list(JOB_TITLE_CHAPLAIN) || human.mind.isholy) // the librarian is both faster, and more accurate than normal crew members at research
		speed = 30 SECONDS
		correctness = 100

	if(human.job in list(JOB_TITLE_CAPTAIN, JOB_TITLE_OFFICER, JOB_TITLE_HOS, JOB_TITLE_DETECTIVE, JOB_TITLE_WARDEN))
		willpower = 99

	if(human.job in list(JOB_TITLE_CLOWN)) // WHO GAVE THE CLOWN A DEMONOMICON?  BAD THINGS WILL HAPPEN!
		willpower = 25

	correctness -= human.getBrainLoss() * 0.5 //Brain damage makes researching hard.
	speed += human.getBrainLoss() * 0.3 SECONDS
	human.visible_message("[human.declent_ru(NOMINATIVE)] открыва[pluralize_ru(human.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)] и начина[pluralize_ru(human.gender, "ет", "ют")] усердно читать.")

	if(!do_after(human, speed, human, DEFAULT_DOAFTER_IGNORE | DA_IGNORE_HELD_ITEM))
		is_used = FALSE
		return

	var/used_name = devil_name

	if(!prob(correctness))
		used_name += "x"

	current_devil = devilInfo(used_name)
	is_used = FALSE
	ui_interact(human)
	SStgui.update_uis(src)
	addtimer(CALLBACK(src, PROC_REF(close), human, willpower), 10 MINUTES)

/obj/item/book/codex_gigas/proc/close(mob/living/carbon/human/human, willpower)
	if(!prob(willpower))
		human.mind?.add_antag_datum(/datum/antagonist/sintouched)
	current_devil = null
	currentName = ""
	currentSection = PRE_TITLE
	SStgui.update_uis(src)

/obj/item/book/codex_gigas/proc/ask_name(mob/reader)
	ui_interact(reader)

/obj/item/book/codex_gigas/ui_act(action, params)
	if(..())
		return
	if(!action)
		return FALSE
	switch(action)
		if("search")
			if(is_used)
				return FALSE
			SStgui.close_uis(src)
			INVOKE_ASYNC(src, PROC_REF(perform_research), usr, currentName)
			currentName = ""
			currentSection = PRE_TITLE
			return FALSE

		if("reset")
			current_devil = null
			currentName = ""
			currentSection = PRE_TITLE
			return TRUE

		if("clear")
			currentName = ""
			currentSection = PRE_TITLE
			return TRUE

		else
			currentName += action
			var/oldSection = currentSection
			if(GLOB.devil_pre_title.Find(action))
				currentSection = TITLE
			else if(GLOB.devil_title.Find(action))
				currentSection = SYLLABLE
			else if(GLOB.devil_syllable.Find(action))
				if (currentSection >= SYLLABLE)
					currentSection = MULTIPLE_SYLLABLE
				else
					currentSection = SYLLABLE
			else if(GLOB.devil_suffix.Find(action))
				currentSection = SUFFIX
			return currentSection != oldSection

/obj/item/book/codex_gigas/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CodexGigas", name, 500, 400)
		ui.open()

/obj/item/book/codex_gigas/ui_data(mob/user)
	var/list/data = list()
	data["name"] = currentName
	data["currentSection"] = currentSection
	if(current_devil)
		data["hasDevilInfo"] = TRUE
		data["devilName"] = current_devil.truename
		data["ban"] = current_devil.ban.desc
		data["bane"] = current_devil.bane.desc
		data["obligation"] = current_devil.obligation.desc
		data["banish"] = current_devil.banish.desc
	return data

/obj/item/book/codex_gigas/ui_static_data(mob/user)
	var/list/data = list()
	data["prefixes"] = GLOB.devil_pre_title
	data["titles"] = GLOB.devil_title
	data["names"] = GLOB.devil_syllable
	data["suffixes"] = GLOB.devil_suffix
	return data

/obj/item/book/codex_gigas
	name = "Codex Gigas"
	icon_state ="demonomicon"
	throw_speed = 1
	throw_range = 10
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	author = "Forces beyond your comprehension"
	unique = TRUE
	title = "The codex gigas"
	var/inUse = FALSE

/obj/item/book/codex_gigas/attack_self(mob/user)
	if(!user.has_vision())
		return

	if(inUse)
		to_chat(user,"<span class='notice'>Someone else is reading it.</span>")
		return
		
	if(!user.is_literate())
		to_chat(user, span_notice("You don't know how to read."))
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human = user
	
	if(locate(/datum/objective/sintouched/acedia) in human.mind?.objectives)
		to_chat(user, span_notice("None of this matters, why are you reading this? You put the [title] down."))
		return

	inUse = TRUE

	var/devilName = copytext(sanitize(input(user, "What infernal being do you wish to research?", "Codex Gigas", null) as text), 1, MAX_MESSAGE_LEN)
	var/speed = 30 SECONDS
	var/correctness = 85
	var/willpower = 95

	if(human.job in list(JOB_TITLE_LIBRARIAN)) // the librarian is both faster, and more accurate than normal crew members at research
		speed = 4.5 SECONDS
		correctness = 100
		willpower = 100

	if(human.job in list(JOB_TITLE_CHAPLAIN)) // the librarian is both faster, and more accurate than normal crew members at research
		speed = 30 SECONDS
		correctness = 100

	if(human.job in list(JOB_TITLE_CAPTAIN, JOB_TITLE_OFFICER, JOB_TITLE_HOS, JOB_TITLE_DETECTIVE, JOB_TITLE_WARDEN))
		willpower = 99

	if(human.job in list(JOB_TITLE_CLOWN)) // WHO GAVE THE CLOWN A DEMONOMICON?  BAD THINGS WILL HAPPEN!
		willpower = 25

	correctness -= human.getBrainLoss() *0.5 //Brain damage makes researching hard.
	speed += human.getBrainLoss() * 0.3 SECONDS
	user.visible_message("[user] opens [title] and begins reading intently.")

	if(!do_after(human, speed, human, DEFAULT_DOAFTER_IGNORE | DA_IGNORE_HELD_ITEM))
		return

	var/usedName = devilName
			
	if(!prob(correctness))
		usedName += "x"

	var/datum/antagonist/devil/devil = devilInfo(usedName)
	user << browse("Information on [devilName]<br><br><br>[devil.info.ban.desc]<br>[devil.info.bane.desc]<br>[devil.info.obligation.desc]<br>[devil.info.banish.desc]", "window=book")

	inUse = FALSE
	addtimer(CALLBACK(src, PROC_REF(close), human, willpower), 10 SECONDS)

/obj/item/book/codex_gigas/proc/close(mob/living/carbon/human/human, willpower)
	if(!prob(willpower))
		human.mind?.add_antag_datum(/datum/antagonist/sintouched)

	onclose(human, "book")

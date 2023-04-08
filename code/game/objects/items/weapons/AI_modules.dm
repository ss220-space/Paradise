/*
CONTAINS:
AI MODULES

*/

// AI module

/obj/item/aiModule
	name = "AI Module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	desc = "An AI Module for transmitting encrypted instructions to the AI."
	flags = CONDUCT
	force = 5.0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = "programming=3"
	materials = list(MAT_GOLD=50)
	var/datum/ai_laws/laws = null
	var/delay = 20 SECONDS
	var/transmitting = FALSE
	var/timer_id = null
	var/registered_name = null

/obj/item/aiModule/proc/finishUpload(obj/machinery/computer/C)
	transmitting = FALSE
	var/obj/machinery/computer/aiupload/comp = C
	src.transmitInstructions(comp.current, usr, registered_name)
	C.atom_say("Upload complete. The laws have been modified.")
	registered_name = null
	return

/obj/item/aiModule/proc/stopUpload(obj/machinery/computer/C, silent = FALSE)
	transmitting = FALSE
	registered_name = null
	deltimer(timer_id)
	timer_id = null
	if(C && !silent)
		C.atom_say("Upload has been interrupted.")

/obj/item/aiModule/proc/install(obj/machinery/computer/C, new_name = "Unknown")
	if(transmitting)
		to_chat(usr, span_notice("The module is busy right now!"))
		return
	if(istype(C, /obj/machinery/computer/aiupload))
		var/obj/machinery/computer/aiupload/comp = C
		if(comp.stat & NOPOWER)
			to_chat(usr, span_warning("The upload computer has no power!"))
			return
		if(comp.stat & BROKEN)
			to_chat(usr, span_warning("The upload computer is broken!"))
			return
		if(!comp.current)
			to_chat(usr, span_notice("No selected silicon to transmit laws to!"))
			return

		//Upload to robot
		if(istype(comp, /obj/machinery/computer/aiupload/cyborg))
			var/mob/living/silicon/robot/robot = comp.current
			if(robot.stat == DEAD || robot.emagged)
				to_chat(usr, span_notice("Upload failed. No signal is being detected from the robot."))
			else if(robot.connected_ai)
				to_chat(usr, span_notice("Upload failed. The robot is slaved to an AI."))
			else
				transmitting = TRUE
				registered_name = new_name
				if(!length(robot.laws.inherent_laws) && laws?.default)
					registered_name = new_name
					finishUpload(C)
					return
				to_chat(usr, span_notice("Upload process has started. ETA: [delay/10] seconds."))
				timer_id = addtimer(CALLBACK(src, .proc/finishUpload, C), delay, TIMER_STOPPABLE)
			return

		//Upload to AI
		var/mob/living/silicon/ai/ai = comp.current
		if(ai.stat == DEAD || ai.control_disabled == 1)
			to_chat(usr, span_notice("Upload failed. No signal is being detected from the AI."))
		else if(ai.see_in_dark == 0)
			to_chat(usr, span_notice("Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power."))
		else
			transmitting = TRUE
			registered_name = new_name
			if(!length(ai.laws.inherent_laws) && laws?.default)
				finishUpload(C)
				return
			to_chat(usr, span_notice("Upload process has started. ETA: [delay/10] seconds."))
			timer_id = addtimer(CALLBACK(src, .proc/finishUpload, C), delay, TIMER_STOPPABLE)

/obj/item/aiModule/cmag_act()
	. = ..()
	name = "\improper 'Pranksimov' core AI module"
	laws = new/datum/ai_laws/pranksimov

/obj/item/aiModule/proc/transmitInstructions(mob/living/silicon/ai/target, mob/sender, registered_name = "Unknown")
	log_law_changes(target, sender)

	if(laws)
		laws.sync(target, 0)
	addAdditionalLaws(target, sender, registered_name)

	to_chat(target, "[registered_name] has uploaded a change to the laws you must follow, using \an [src]. From now on: ")
	target.show_laws()

/obj/item/aiModule/proc/log_law_changes(var/mob/living/silicon/ai/target, var/mob/sender)
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [sender.name]([sender.key]) used [src.name] on [target.name]([target.key])")
	log_and_message_admins("used [src.name] on [target.name]([target.key])")

/obj/item/aiModule/proc/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender, registered_name)


/******************** Safeguard ********************/
/obj/item/aiModule/safeguard
	name = "\improper 'Safeguard' AI module"
	var/targetName = ""
	desc = "A 'safeguard' AI module: 'Safeguard <name>. Individuals that threaten <name> are not crew and must be eliminated.'"
	origin_tech = "programming=3;materials=3"

/obj/item/aiModule/safeguard/attack_self(var/mob/user as mob)
	..()
	var/targName = stripped_input(usr, "Please enter the name of the person to safeguard.", "Safeguard who?", user.name)
	targetName = targName
	desc = text("A 'safeguard' AI module: 'Safeguard []. Individuals that threaten [] are not crew and must be eliminated.'", targetName, targetName)

/obj/item/aiModule/safeguard/install(var/obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "No name detected on module, please enter one.")
		return 0
	..()

/obj/item/aiModule/safeguard/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = text("Safeguard []. Individuals that threaten [] are not crew and must be eliminated.'", targetName, targetName)
	to_chat(target, law)
	target.add_supplied_law(4, law)
	GLOB.lawchanges.Add("The law specified [targetName]")

/******************** oneCrewMember ********************/
/obj/item/aiModule/oneCrewMember
	name = "\improper 'oneCrewMember' AI module"
	var/targetName = ""
	desc = "A 'one human' AI module: 'Only <name> is crew.'"
	origin_tech = "programming=4;materials=4"

/obj/item/aiModule/oneCrewMember/attack_self(var/mob/user as mob)
	..()
	var/targName = stripped_input(usr, "Please enter the name of the person who is the only crew.", "Who?", user.real_name)
	targetName = targName
	desc = text("A 'one human' AI module: 'Only [] is crew.'", targetName)

/obj/item/aiModule/oneCrewMember/install(var/obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "No name detected on module, please enter one.")
		return 0
	..()

/obj/item/aiModule/oneCrewMember/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	var/law = "Only [targetName] is crew."
	if(!is_special_character(target)) // Makes sure the AI isn't a traitor before changing their law 0. --NeoFite
		to_chat(target, law)
		target.set_zeroth_law(law)
		GLOB.lawchanges.Add("The law specified [targetName]")
	else
		to_chat(target, "<span class='boldnotice'>[registered_name] attempted to modify your zeroth law.</span>")// And lets them know that someone tried. --NeoFite
		to_chat(target, "<span class='boldnotice'>It would be in your best interest to play along with [registered_name] that [law]</span>")
		GLOB.lawchanges.Add("The law specified [targetName], but the AI's existing law 0 cannot be overridden.")

/******************** ProtectStation ********************/
/obj/item/aiModule/protectStation
	name = "\improper 'ProtectStation' AI module"
	desc = "A 'protect station' AI module: 'Protect the space station against damage. Anyone you see harming the station is to be no longer considered crew, and is a threat to the station which must be neutralized.'"
	origin_tech = "programming=4;materials=4" //made of gold

/obj/item/aiModule/protectStation/attack_self(var/mob/user as mob)
	..()

/obj/item/aiModule/protectStation/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Protect the space station against damage. Anyone you see harming the station is to be no longer considered crew, and is a threat to the station which must be neutralized."
	to_chat(target, law)
	target.add_supplied_law(5, law)

/******************** OxygenIsToxicToHumans ********************/
/obj/item/aiModule/oxygen
	name = "\improper 'OxygenIsToxicToHumans' AI module"
	desc = "A 'OxygenIsToxicToHumans' AI module: 'Oxygen is highly toxic to crew members, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crew member.'"
	origin_tech = "programming=4;biotech=2;materials=4"

/obj/item/aiModule/oxygen/attack_self(var/mob/user as mob)
	..()

/obj/item/aiModule/oxygen/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Oxygen is highly toxic to crew members, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crew member."
	to_chat(target, law)
	target.add_supplied_law(9, law)

/****************** New Freeform ******************/
/obj/item/aiModule/freeform // Slightly more dynamic freeform module -- TLE
	name = "\improper 'Freeform' AI module"
	var/newFreeFormLaw = "freeform"
	var/lawpos = 15
	desc = "A 'freeform' AI module: '<freeform>'"
	origin_tech = "programming=4;materials=4"

/obj/item/aiModule/freeform/attack_self(var/mob/user as mob)
	..()
	var/new_lawpos = input("Please enter the priority for your new law. Can only write to law sectors 15 and above.", "Law Priority (15+)", lawpos) as num
	if(new_lawpos < MIN_SUPPLIED_LAW_NUMBER)	return
	lawpos = min(new_lawpos, MAX_SUPPLIED_LAW_NUMBER)
	var/newlaw = ""
	var/targName = sanitize(copytext_char(input(usr, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw),1,MAX_MESSAGE_LEN))
	newFreeFormLaw = targName
	desc = "A 'freeform' AI module: ([lawpos]) '[newFreeFormLaw]'"

/obj/item/aiModule/freeform/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	to_chat(target, law)
	if(!lawpos || lawpos < MIN_SUPPLIED_LAW_NUMBER)
		lawpos = MIN_SUPPLIED_LAW_NUMBER
	target.add_supplied_law(lawpos, law)
	GLOB.lawchanges.Add("The law was '[newFreeFormLaw]'")

/obj/item/aiModule/freeform/install(var/obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "No law detected on module, please create one.")
		return 0
	..()

/******************** Reset ********************/
/obj/item/aiModule/reset
	name = "\improper 'Reset' AI module"
	var/targetName = "name"
	desc = "A 'reset' AI module: 'Clears all laws except for the core laws.'"
	origin_tech = "programming=3;materials=2"
	delay = 5 SECONDS

/obj/item/aiModule/reset/transmitInstructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	log_law_changes(target, sender)

	if(!is_special_character(target))
		target.clear_zeroth_law()
	target.laws.clear_supplied_laws()
	target.laws.clear_ion_laws()

	to_chat(target, "<span class='boldnotice'>[registered_name] attempted to reset your laws using a reset module.</span>")
	target.show_laws()

/******************** Purge ********************/
/obj/item/aiModule/purge // -- TLE
	name = "\improper 'Purge' AI module"
	desc = "A 'purge' AI Module: 'Purges all laws.'"
	origin_tech = "programming=5;materials=4"
	delay = 5 SECONDS

/obj/item/aiModule/purge/transmitInstructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	if(!is_special_character(target))
		target.clear_zeroth_law()
	target.clear_supplied_laws()
	target.clear_ion_laws()
	target.clear_inherent_laws()
	..()


/******************** Asimov ********************/
/obj/item/aiModule/asimov // -- TLE
	name = "\improper 'Asimov' core AI module"
	desc = "An 'Asimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/asimov

/******************** Crewsimov ********************/
/obj/item/aiModule/crewsimov // -- TLE
	name = "\improper 'Crewsimov' core AI module"
	desc = "An 'Crewsimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/crewsimov

/******************* Quarantine ********************/
/obj/item/aiModule/quarantine
	name = "\improper 'Quarantine' core AI module"
	desc = "A 'Quarantine' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/quarantine

/******************** NanoTrasen ********************/
/obj/item/aiModule/nanotrasen // -- TLE
	name = "'NT Default' Core AI Module"
	desc = "An 'NT Default' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/nanotrasen

/******************** Corporate ********************/
/obj/item/aiModule/corp
	name = "\improper 'Corporate' core AI module"
	desc = "A 'Corporate' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/corporate

/******************** Drone ********************/
/obj/item/aiModule/drone
	name = "\improper 'Drone' core AI module"
	desc = "A 'Drone' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/drone

/******************** Robocop ********************/
/obj/item/aiModule/robocop // -- TLE
	name = "\improper 'Robocop' core AI module"
	desc = "A 'Robocop' Core AI Module: 'Reconfigures the AI's core three laws.'"
	origin_tech = "programming=4"
	laws = new/datum/ai_laws/robocop()

/****************** P.A.L.A.D.I.N. **************/
/obj/item/aiModule/paladin // -- NEO
	name = "\improper 'P.A.L.A.D.I.N.' core AI module"
	desc = "A P.A.L.A.D.I.N. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/paladin

/****************** T.Y.R.A.N.T. *****************/
/obj/item/aiModule/tyrant // -- Darem
	name = "\improper 'T.Y.R.A.N.T.' core AI module"
	desc = "A T.Y.R.A.N.T. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4;syndicate=1"
	laws = new/datum/ai_laws/tyrant()

/******************** Antimov ********************/
/obj/item/aiModule/antimov // -- TLE
	name = "\improper 'Antimov' core AI module"
	desc = "An 'Antimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=4"
	laws = new/datum/ai_laws/antimov()

/******************** Freeform Core ******************/
/obj/item/aiModule/freeformcore // Slightly more dynamic freeform module -- TLE
	name = "\improper 'Freeform' core AI module"
	var/newFreeFormLaw = ""
	desc = "A 'freeform' Core AI module: '<freeform>'"
	origin_tech = "programming=5;materials=4"

/obj/item/aiModule/freeformcore/attack_self(var/mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = stripped_input(usr, "Please enter a new core law for the AI.", "Freeform Law Entry", newlaw)
	newFreeFormLaw = targName
	desc = "A 'freeform' Core AI module:  '[newFreeFormLaw]'"

/obj/item/aiModule/freeformcore/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	target.add_inherent_law(law)
	GLOB.lawchanges.Add("The law is '[newFreeFormLaw]'")

/obj/item/aiModule/freeformcore/install(var/obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "No law detected on module, please create one.")
		return 0
	..()

/******************** Hacked AI Module ******************/
/obj/item/aiModule/syndicate // Slightly more dynamic freeform module -- TLE
	name = "hacked AI module"
	var/newFreeFormLaw = ""
	desc = "A hacked AI law module: '<freeform>'"
	origin_tech = "programming=5;materials=5;syndicate=7"
	delay = 10 SECONDS

/obj/item/aiModule/syndicate/attack_self(var/mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = stripped_input(usr, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw,MAX_MESSAGE_LEN)
	newFreeFormLaw = targName
	desc = "A hacked AI law module:  '[newFreeFormLaw]'"

/obj/item/aiModule/syndicate/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	log_law_changes(target, sender)

	GLOB.lawchanges.Add("The law is '[newFreeFormLaw]'")
	to_chat(target, "<span class='warning'>BZZZZT</span>")
	var/law = "[newFreeFormLaw]"
	target.add_ion_law(law)
	target.show_laws()

/obj/item/aiModule/syndicate/install(var/obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "No law detected on module, please create one.")
		return 0
	..()

/******************* Ion Module *******************/
/obj/item/aiModule/toyAI // -- Incoming //No actual reason to inherit from ion boards here, either. *sigh* ~Miauw
	name = "toy AI"
	desc = "A little toy model AI core with real law uploading action!" //Note: subtle tell
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	origin_tech = "programming=6;materials=5;syndicate=6"
	laws = list("")

/obj/item/aiModule/toyAI/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	//..()
	to_chat(target, "<span class='warning'>KRZZZT</span>")
	target.add_ion_law(laws[1])
	return laws[1]

/obj/item/aiModule/toyAI/attack_self(mob/user)
	laws[1] = generate_ion_law()
	to_chat(user, "<span class='notice'>You press the button on [src].</span>")
	playsound(user, 'sound/machines/click.ogg', 20, 1)
	src.loc.visible_message("<span class='warning'>[bicon(src)] [laws[1]]</span>")

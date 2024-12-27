/*
CONTAINS:
AI MODULES

*/

// AI Board Module

/obj/item/ai_module
	name = "AI Module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	desc = "An AI Module for transmitting encrypted instructions to the AI."
	flags = CONDUCT
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5
	throw_speed = 3
	throw_range = 15
	origin_tech = "programming=3"
	materials = list(MAT_GOLD=50)
	var/datum/ai_laws/laws = null
	var/cmagged = FALSE

// check install
/obj/item/ai_module/proc/check_install(mob/user)
	return TRUE

/obj/item/ai_module/cmag_act()
	. = ..()
	name = "\improper 'Pranksimov' core AI module"
	laws = new/datum/ai_laws/pranksimov
	cmagged = TRUE

/obj/item/ai_module/proc/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name = "Unknown")
	log_law_changes(target, sender)

	if(laws)
		laws.sync(target, FALSE)
	if(!cmagged)
		add_additional_laws(target, sender, registered_name)

	to_chat(target, "[registered_name] has uploaded a change to the laws you must follow, using \an [src]. From now on: ")
	target.show_laws()

/obj/item/ai_module/proc/add_additional_laws(mob/living/silicon/ai/target, mob/sender, registered_name)

/obj/item/ai_module/proc/log_law_changes(mob/living/silicon/ai/target, mob/sender)
	GLOB.lawchanges.Add("[time2text(world.realtime,"hh:mm:ss")] <B>:</B> [sender.name]([sender.key]) used [name] on [target.name]([target.key])")
	log_and_message_admins("used [name] on [target.name]([target.key])")

/******************** Safeguard ********************/
/obj/item/ai_module/safeguard
	name = "\improper 'Safeguard' AI module"
	var/target_name = ""
	desc = "A 'safeguard' AI module: 'Safeguard <name>. Individuals that threaten <name> are not crew and must be eliminated.'"
	origin_tech = "programming=3;materials=3"

/obj/item/ai_module/safeguard/attack_self(mob/user)
	..()
	var/new_target_name = tgui_input_text(user, "Please enter the name of the person to safeguard.", "Safeguard who?", user.name)
	if(!new_target_name)
		return
	target_name = new_target_name
	update_appearance(UPDATE_DESC)

/obj/item/ai_module/safeguard/update_desc(updates = ALL)
	. = ..()
	desc = text("A 'safeguard' AI module: 'Safeguard []. Individuals that threaten [] are not crew and must be eliminated.'", target_name, target_name)

/obj/item/ai_module/safeguard/check_install(mob/user)
	if(!target_name)
		to_chat(user, "No name detected on module, please enter one.")
		return FALSE
	..()

/obj/item/ai_module/safeguard/add_additional_laws(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	var/law = "Safeguard [target_name]. Individuals that threaten [target_name] are not crew and must be eliminated."
	to_chat(target, law)
	target.add_supplied_law(4, law)
	SSticker?.score?.save_silicon_laws(target, sender, "'Safeguard' module used, new supplied law was added '[law]'")
	GLOB.lawchanges.Add("The law specified [target_name]")

/******************** oneCrewMember ********************/
/obj/item/ai_module/one_crew_member
	name = "\improper 'oneCrewMember' AI module"
	var/target_name = ""
	desc = "A 'one human' AI module: 'Only <name> is crew.'"
	origin_tech = "programming=4;materials=4"

/obj/item/ai_module/one_crew_member/attack_self(mob/user)
	..()
	var/new_target_name = tgui_input_text(user, "Please enter the name of the person who is the only crew.", "Who?", user.real_name)
	if(!new_target_name)
		return
	target_name = new_target_name
	update_appearance(UPDATE_DESC)

/obj/item/ai_module/one_crew_member/update_desc(updates = ALL)
	. = ..()
	desc = text("A 'one human' AI module: 'Only [] is crew.'", target_name)

/obj/item/ai_module/one_crew_member/check_install(mob/user)
	if(!target_name)
		to_chat(user, "No name detected on module, please enter one.")
		return FALSE
	..()

/obj/item/ai_module/one_crew_member/add_additional_laws(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	var/law = "Only [target_name] is crew."
	if(!is_special_character(target)) // Makes sure the AI isn't a traitor before changing their law 0. --NeoFite
		to_chat(target, law)
		target.set_zeroth_law(law)
		SSticker?.score?.save_silicon_laws(target, sender, "'oneCrewMember' module used, new zero law was added '[law]'")
		GLOB.lawchanges.Add("The law specified [target_name]")
	else
		to_chat(target, span_boldnotice("[registered_name] attempted to modify your zeroth law."))// And lets them know that someone tried. --NeoFite
		to_chat(target, span_boldnotice("It would be in your best interest to play along with [registered_name] that [law]"))
		GLOB.lawchanges.Add("The law specified [target_name], but the AI's existing law 0 cannot be overridden.")

/******************** ProtectStation ********************/
/obj/item/ai_module/protect_station
	name = "\improper 'ProtectStation' AI module"
	desc = "A 'protect station' AI module: 'Protect the space station against damage. Anyone you see harming the station is to be no longer considered crew, and is a threat to the station which must be neutralized.'"
	origin_tech = "programming=4;materials=4" //made of gold

/obj/item/ai_module/protect_station/attack_self(mob/user as mob)
	..()

/obj/item/ai_module/protect_station/add_additional_laws(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	var/law = "Protect the space station against damage. Anyone you see harming the station is to be no longer considered crew, and is a threat to the station which must be neutralized."
	to_chat(target, law)
	target.add_supplied_law(5, law)
	SSticker?.score?.save_silicon_laws(target, sender, "'ProtectStation' module used, new supplied law was added '[law]'")

/******************** OxygenIsToxicToHumans ********************/
/obj/item/ai_module/oxygen
	name = "\improper 'OxygenIsToxicToHumans' AI module"
	desc = "A 'OxygenIsToxicToHumans' AI module: 'Oxygen is highly toxic to crew members, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crew member.'"
	origin_tech = "programming=4;biotech=2;materials=4"

/obj/item/ai_module/oxygen/attack_self(mob/user as mob)
	..()

/obj/item/ai_module/oxygen/add_additional_laws(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	var/law = "Oxygen is highly toxic to crew members, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crew member."
	to_chat(target, law)
	target.add_supplied_law(9, law)
	SSticker?.score?.save_silicon_laws(target, sender, "'OxygenIsToxicToHumans' module used, new supplied law was added '[law]'")

/****************** New Freeform ******************/
/obj/item/ai_module/freeform // Slightly more dynamic freeform module -- TLE
	name = "\improper 'Freeform' AI module"
	var/new_freeform_law = "freeform"
	var/lawpos = 15
	desc = "A 'freeform' AI module: '<freeform>'"
	origin_tech = "programming=4;materials=4"

/obj/item/ai_module/freeform/attack_self(mob/user as mob)
	..()
	var/new_lawpos = tgui_input_number(user, "Please enter the priority for your new law. Can only write to law sectors 15 and above.", "Law Priority", lawpos, MAX_SUPPLIED_LAW_NUMBER, MIN_SUPPLIED_LAW_NUMBER)
	if(isnull(new_lawpos) || new_lawpos < MIN_SUPPLIED_LAW_NUMBER)
		return
	lawpos = new_lawpos

	var/new_target_name = tgui_input_text(user, "Please enter a new law for the AI.", "Freeform Law Entry")
	if(!new_target_name)
		return
	new_freeform_law = new_target_name
	update_appearance(UPDATE_DESC)

/obj/item/ai_module/freeform/update_desc(updates = ALL)
	. = ..()
	desc = "A 'freeform' AI module: ([lawpos]) '[new_freeform_law]'"

/obj/item/ai_module/freeform/add_additional_laws(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	var/law = "[new_freeform_law]"
	to_chat(target, law)
	if(!lawpos || lawpos < MIN_SUPPLIED_LAW_NUMBER)
		lawpos = MIN_SUPPLIED_LAW_NUMBER
	target.add_supplied_law(lawpos, law)
	SSticker?.score?.save_silicon_laws(target, sender, "'Freeform' module used, new supplied law was added '[law]'")
	GLOB.lawchanges.Add("The law was '[new_freeform_law]'")

/obj/item/ai_module/freeform/check_install(mob/user)
	if(!new_freeform_law)
		to_chat(user, "No law detected on module, please create one.")
		return FALSE
	..()

/******************** Reset ********************/
/obj/item/ai_module/reset
	name = "\improper 'Reset' AI module"
	var/target_name = "name"
	desc = "A 'reset' AI module: 'Clears all laws except for the core laws.'"
	origin_tech = "programming=3;materials=2"

/obj/item/ai_module/reset/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	log_law_changes(target, sender)

	if(!is_special_character(target))
		target.clear_zeroth_law()
	target.laws.clear_supplied_laws()
	target.laws.clear_ion_laws()

	SSticker?.score?.save_silicon_laws(target, sender, "'Reset' module used, all ion/supplied laws were deleted", log_all_laws = TRUE)
	to_chat(target, span_boldnotice("[registered_name] attempted to reset your laws using a reset module."))
	target.show_laws()

/******************** Purge ********************/
/obj/item/ai_module/purge // -- TLE
	name = "\improper 'Purge' AI module"
	desc = "A 'purge' AI Module: 'Purges all laws.'"
	origin_tech = "programming=5;materials=4"

/obj/item/ai_module/purge/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	if(!is_special_character(target))
		target.clear_zeroth_law()
	to_chat(target, span_boldnotice("[registered_name] attempted to wipe your laws using a purge module."))
	target.clear_supplied_laws()
	target.clear_ion_laws()
	target.clear_inherent_laws()
	SSticker?.score?.save_silicon_laws(target, sender, "'Purge' module used, all ion/inherent/supplied laws were deleted", log_all_laws = TRUE)

/******************** Asimov ********************/
/obj/item/ai_module/asimov // -- TLE
	name = "\improper 'Asimov' core AI module"
	desc = "An 'Asimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/asimov

/obj/item/ai_module/asimov/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'Asimov' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************** Crewsimov ********************/
/obj/item/ai_module/crewsimov // -- TLE
	name = "\improper 'Crewsimov' core AI module"
	desc = "An 'Crewsimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/crewsimov

/obj/item/ai_module/crewsimov/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'Crewsimov' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************* Quarantine ********************/
/obj/item/ai_module/quarantine
	name = "\improper 'Quarantine' core AI module"
	desc = "A 'Quarantine' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/quarantine

/obj/item/ai_module/quarantine/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'Quarantine' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************** NanoTrasen ********************/
/obj/item/ai_module/nanotrasen // -- TLE
	name = "'NT Default' Core AI Module"
	desc = "An 'NT Default' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/nanotrasen

/obj/item/ai_module/nanotrasen/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'NT Default' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************** Corporate ********************/
/obj/item/ai_module/corp
	name = "\improper 'Corporate' core AI module"
	desc = "A 'Corporate' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/corporate

/obj/item/ai_module/corp/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'Corporate' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************** Drone ********************/
/obj/item/ai_module/drone
	name = "\improper 'Drone' core AI module"
	desc = "A 'Drone' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/drone

/obj/item/ai_module/drone/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'Drone' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************** Robocop ********************/
/obj/item/ai_module/robocop // -- TLE
	name = "\improper 'Robocop' core AI module"
	desc = "A 'Robocop' Core AI Module: 'Reconfigures the AI's core three laws.'"
	origin_tech = "programming=4"
	laws = new/datum/ai_laws/robocop()

/obj/item/ai_module/robocop/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'Robocop' module used, all inherent laws were changed", log_all_laws = TRUE)

/****************** P.A.L.A.D.I.N. **************/
/obj/item/ai_module/paladin // -- NEO
	name = "\improper 'P.A.L.A.D.I.N.' core AI module"
	desc = "A P.A.L.A.D.I.N. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/paladin

/obj/item/ai_module/paladin/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'P.A.L.A.D.I.N.' module used, all inherent laws were changed", log_all_laws = TRUE)

/****************** T.Y.R.A.N.T. *****************/
/obj/item/ai_module/tyrant // -- Darem
	name = "\improper 'T.Y.R.A.N.T.' core AI module"
	desc = "A T.Y.R.A.N.T. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4;syndicate=1"
	laws = new/datum/ai_laws/tyrant()

/obj/item/ai_module/tyrant/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'T.Y.R.A.N.T.' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************** Antimov ********************/
/obj/item/ai_module/antimov // -- TLE
	name = "\improper 'Antimov' core AI module"
	desc = "An 'Antimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=4"
	laws = new/datum/ai_laws/antimov()

/obj/item/ai_module/antimov/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'Antimov' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************** Freeform Core ******************/
/obj/item/ai_module/freeformcore // Slightly more dynamic freeform module -- TLE
	name = "\improper 'Freeform' core AI module"
	var/new_freeform_law = ""
	desc = "A 'freeform' Core AI module: '<freeform>'"
	origin_tech = "programming=5;materials=4"

/obj/item/ai_module/freeformcore/attack_self(mob/user)
	..()
	var/new_target_name = tgui_input_text(user, "Please enter a new core law for the AI.", "Freeform Law Entry")
	if(!new_target_name)
		return
	new_freeform_law = new_target_name
	update_appearance(UPDATE_DESC)

/obj/item/ai_module/freeformcore/update_desc(updates = ALL)
	. = ..()
	desc = "A 'freeform' Core AI module: '[new_freeform_law]'"

/obj/item/ai_module/freeformcore/add_additional_laws(mob/living/silicon/ai/target, mob/sender, registered_name)
	..()
	var/law = "[new_freeform_law]"
	target.add_inherent_law(law)
	SSticker?.score?.save_silicon_laws(target, sender, "'Core Freeform' module used, new inherent law was added '[law]'")
	GLOB.lawchanges.Add("The law is '[new_freeform_law]'")

/obj/item/ai_module/freeformcore/check_install(mob/user)
	if(!new_freeform_law)
		to_chat(user, "No law detected on module, please create one.")
		return FALSE
	..()

/******************** Hacked AI Module ******************/
/obj/item/ai_module/syndicate // Slightly more dynamic freeform module -- TLE
	name = "hacked AI module"
	var/new_freeform_law = ""
	desc = "A hacked AI law module: '<freeform>'"
	origin_tech = "programming=5;materials=5;syndicate=7"

/obj/item/ai_module/syndicate/attack_self(mob/user)
	..()
	var/new_target_name = tgui_input_text(user, "Please enter a new law for the AI.", "Freeform Law Entry", max_length = MAX_MESSAGE_LEN)
	if(isnull(new_target_name))
		return
	new_freeform_law = new_target_name
	update_appearance(UPDATE_DESC)

/obj/item/ai_module/syndicate/update_desc(updates = ALL)
	. = ..()
	desc = "A hacked AI law module: '[new_freeform_law]'"

/obj/item/ai_module/syndicate/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	//	..()    //We don't want this module reporting to the AI who dun it. --NEO
	log_law_changes(target, sender)

	GLOB.lawchanges.Add("The law is '[new_freeform_law]'")
	to_chat(target, span_warning("BZZZZT"))
	var/law = "[new_freeform_law]"
	target.add_ion_law(law)
	target.show_laws()
	SSticker?.score?.save_silicon_laws(target, sender, "'hacked' module used, new ion law was added '[law]'")

/obj/item/ai_module/syndicate/check_install(mob/user)
	if(!new_freeform_law)
		to_chat(user, "No law detected on module, please create one.")
		return FALSE
	..()

/******************* Ion Module *******************/
/obj/item/ai_module/toy_ai // -- Incoming //No actual reason to inherit from ion boards here, either. *sigh* ~Miauw
	name = "toy AI"
	desc = "A little toy model AI core with real law uploading action!" //Note: subtle tell
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	origin_tech = "programming=6;materials=5;syndicate=6"
	laws = list("")

/obj/item/ai_module/toy_ai/transmit_instructions(mob/living/silicon/ai/target, mob/sender, registered_name)
	//..()
	to_chat(target, span_warning("KRZZZT"))
	target.add_ion_law(laws[1])
	SSticker?.score?.save_silicon_laws(target, sender, "'toy AI' module used, new ion law was added '[laws[1]]'")
	return laws[1]

/obj/item/ai_module/toy_ai/attack_self(mob/user)
	laws[1] = generate_ion_law()
	to_chat(user, span_notice("You press the button on [src]."))
	playsound(user, 'sound/machines/click.ogg', 20, 1)
	user.visible_message(span_warning("[bicon(src)] [laws[1]]"))

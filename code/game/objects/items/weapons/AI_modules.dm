/*
CONTAINS:
AI MODULES

*/

// AI module

/obj/item/aiModule
	name = "модуль ИИ"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	desc = "Модуль ИИ для передачи шифрованных инструкций ИИ."
	flags = CONDUCT
	force = 5.0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = "programming=3"
	materials = list(MAT_GOLD=50)
	var/datum/ai_laws/laws = null

/obj/item/aiModule/proc/install(var/obj/machinery/computer/C)
	if(istype(C, /obj/machinery/computer/aiupload))
		var/obj/machinery/computer/aiupload/comp = C
		if(comp.stat & NOPOWER)
			to_chat(usr, span_warning("The upload computer has no power!"))
			return
		if(comp.stat & BROKEN)
			to_chat(usr, span_warning("The upload computer is broken!"))
			return
		if(!comp.current)
			to_chat(usr, span_warning("You haven't selected an AI to transmit laws to!"))
			return

		if(comp.current.stat == DEAD || comp.current.control_disabled)
			to_chat(usr, span_warning("Upload failed. No signal is being detected from the AI."))
		else if(comp.current.see_in_dark == 0)
			to_chat(usr, span_warning("Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power."))
		else
			src.transmitInstructions(comp.current, usr)
			to_chat(comp.current, "These are your laws now:")
			comp.current.show_laws()
			for(var/mob/living/silicon/robot/R in GLOB.mob_list)
				if(R.lawupdate && (R.connected_ai == comp.current))
					to_chat(R, "These are your laws now:")
					R.show_laws()
			to_chat(usr, span_notice("Upload complete. The AI's laws have been modified."))

	else if(istype(C, /obj/machinery/computer/borgupload))
		var/obj/machinery/computer/borgupload/comp = C
		if(comp.stat & NOPOWER)
			to_chat(usr, span_warning("The upload computer has no power!"))
			return
		if(comp.stat & BROKEN)
			to_chat(usr, span_warning("The upload computer is broken!"))
			return
		if(!comp.current)
			to_chat(usr, span_warning("You haven't selected a robot to transmit laws to!"))
			return

		if(comp.current.stat == DEAD || comp.current.emagged)
			to_chat(usr, span_warning("Upload failed. No signal is being detected from the robot."))
		else if(comp.current.connected_ai)
			to_chat(usr, span_warning("Upload failed. The robot is slaved to an AI."))
		else
			src.transmitInstructions(comp.current, usr)
			to_chat(comp.current, "These are your laws now:")
			comp.current.show_laws()
			to_chat(usr, span_notice("Upload complete. The robot's laws have been modified."))

/obj/item/aiModule/cmag_act()
	. = ..()
	name = "\improper '" + /datum/ai_laws/pranksimov::name + "' основной модуль ИИ"
	laws = new/datum/ai_laws/pranksimov

/obj/item/aiModule/proc/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	log_law_changes(target, sender)

	if(laws)
		laws.sync(target, 0)
	addAdditionalLaws(target, sender)

	to_chat(target, "[sender] has uploaded a change to the laws you must follow, using \an [src]. From now on: ")
	target.show_laws()

/obj/item/aiModule/proc/log_law_changes(var/mob/living/silicon/ai/target, var/mob/sender)
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [sender.name]([sender.key]) used [src.name] on [target.name]([target.key])")
	log_and_message_admins("used [src.name] on [target.name]([target.key])")

/obj/item/aiModule/proc/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)


/******************** Safeguard ********************/
/obj/item/aiModule/safeguard
	name = "\improper 'Safeguard' модуль ИИ"
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
	var/law = "Safeguard [targetName]. Individuals that threaten [targetName] are not crew and must be eliminated."
	to_chat(target, law)
	target.add_supplied_law(4, law)
	SSticker?.score?.save_silicon_laws(target, sender, "'Safeguard' module used, new supplied law was added '[law]'")
	GLOB.lawchanges.Add("The law specified [targetName]")

/******************** oneCrewMember ********************/
/obj/item/aiModule/oneCrewMember
	name = "\improper 'единственныйЭкипаж' модуль ИИ"
	var/targetName = ""
	desc = "'Единственный человек' модуль ИИ: 'Только <имя> является экипажем.'"
	origin_tech = "programming=4;materials=4"

/obj/item/aiModule/oneCrewMember/attack_self(var/mob/user as mob)
	..()
	var/targName = stripped_input(usr, "Please enter the name of the person who is the only crew.", "Who?", user.real_name)
	targetName = targName
	desc = text("'Единственный человек' модуль ИИ: 'Только [] является экипажем.'", targetName)

/obj/item/aiModule/oneCrewMember/install(var/obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "No name detected on module, please enter one.")
		return 0
	..()

/obj/item/aiModule/oneCrewMember/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Только [targetName] является экипажем."
	if(!is_special_character(target)) // Makes sure the AI isn't a traitor before changing their law 0. --NeoFite
		to_chat(target, law)
		target.set_zeroth_law(law)
		SSticker?.score?.save_silicon_laws(target, sender, "'oneCrewMember' module used, new zero law was added '[law]'")
		GLOB.lawchanges.Add("The law specified [targetName]")
	else
		to_chat(target, span_boldnotice("[sender.real_name] попытал[genderize_ru(sender.gender, "ся", "ась", "ось", "ись"] изменить ваш нулевой закон."))// And lets them know that someone tried. --NeoFite
		to_chat(target, span_boldnotice("В ваших же интересах подыграть [sender.real_name] с [law]"))
		GLOB.lawchanges.Add("The law specified [targetName], but the AI's existing law 0 cannot be overridden.")

/******************** ProtectStation ********************/
/obj/item/aiModule/protectStation
	name = "\improper 'ЗащитаСтанции' модуль ИИ"
	desc = "A 'protect station' AI module: 'Protect the space station against damage. Anyone you see harming the station is to be no longer considered crew, and is a threat to the station which must be neutralized.'"
	origin_tech = "programming=4;materials=4" //made of gold

/obj/item/aiModule/protectStation/attack_self(var/mob/user as mob)
	..()

/obj/item/aiModule/protectStation/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Protect the space station against damage. Anyone you see harming the station is to be no longer considered crew, and is a threat to the station which must be neutralized."
	to_chat(target, law)
	target.add_supplied_law(5, law)
	SSticker?.score?.save_silicon_laws(target, sender, "'ProtectStation' module used, new supplied law was added '[law]'")

/******************** OxygenIsToxicToHumans ********************/
/obj/item/aiModule/oxygen
	name = "\improper 'КислородТоксиченЛюдям' модуль ИИ"
	desc = "'КислородТоксиченЛюдям' модуль ИИ: 'Кислород очень токсичен для экипажа и должен быть удалён со станции. Любыми необходимыми средствами не позволяйте никому подвергать станцию ​​воздействию этого токсичного газа. Экстремальный холод — наиболее эффективный метод устранения ущерба, нанесенного кислородом члену экипажа.'"
	origin_tech = "programming=4;biotech=2;materials=4"

/obj/item/aiModule/oxygen/attack_self(var/mob/user as mob)
	..()

/obj/item/aiModule/oxygen/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Кислород очень токсичен для экипажа и должен быть удалён со станции. Любыми необходимыми средствами не позволяйте никому подвергать станцию ​​воздействию этого токсичного газа. Экстремальный холод — наиболее эффективный метод устранения ущерба, нанесенного кислородом члену экипажа."
	to_chat(target, law)
	target.add_supplied_law(9, law)
	SSticker?.score?.save_silicon_laws(target, sender, "'OxygenIsToxicToHumans' module used, new supplied law was added '[law]'")

/****************** New Freeform ******************/
/obj/item/aiModule/freeform // Slightly more dynamic freeform module -- TLE
	name = "\improper 'Свободнаяформа' модуль ИИ"
	var/newFreeFormLaw = "freeform"
	var/lawpos = 15
	desc = "'Свободнаяформа' модуль ИИ: '<freeform>'"
	origin_tech = "programming=4;materials=4"

/obj/item/aiModule/freeform/attack_self(var/mob/user as mob)
	..()
	var/new_lawpos = input("Please enter the priority for your new law. Can only write to law sectors 15 and above.", "Law Priority (15+)", lawpos) as num
	if(new_lawpos < MIN_SUPPLIED_LAW_NUMBER)	return
	lawpos = min(new_lawpos, MAX_SUPPLIED_LAW_NUMBER)
	var/newlaw = ""
	var/targName = sanitize(copytext_char(input(usr, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw),1,MAX_MESSAGE_LEN))
	newFreeFormLaw = targName
	desc = "'Свободнаяформа' модуль ИИ: ([lawpos]) '[newFreeFormLaw]'"

/obj/item/aiModule/freeform/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	to_chat(target, law)
	if(!lawpos || lawpos < MIN_SUPPLIED_LAW_NUMBER)
		lawpos = MIN_SUPPLIED_LAW_NUMBER
	target.add_supplied_law(lawpos, law)
	SSticker?.score?.save_silicon_laws(target, sender, "'Freeform' module used, new supplied law was added '[law]'")
	GLOB.lawchanges.Add("The law was '[newFreeFormLaw]'")

/obj/item/aiModule/freeform/install(var/obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "Закона не обнаружено на модуле, пожалуйста напишите новый.")
		return 0
	..()

/******************** Reset ********************/
/obj/item/aiModule/reset
	name = "\improper 'Сброс' модуль ИИ"
	desc = "'Сброс' модуль ИИ: 'Очищает все законы, кроме основных.'"
	origin_tech = "programming=3;materials=2"

/obj/item/aiModule/reset/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	log_law_changes(target, sender)

	if(!is_special_character(target))
		target.clear_zeroth_law()
	target.laws.clear_supplied_laws()
	target.laws.clear_ion_laws()

	SSticker?.score?.save_silicon_laws(target, sender, "'Reset' module used, all ion/supplied laws were deleted", log_all_laws = TRUE)
	to_chat(target, span_boldnotice("[sender.real_name] попытал[genderize_ru(sender.gender, "ся", "ась", "ось", "ись"] сбросить ваши законы, используя модуль сброса."))
	target.show_laws()

/******************** Purge ********************/
/obj/item/aiModule/purge // -- TLE
	name = "\improper 'Очищение' модуль ИИ"
	desc = "'Очищение' модуль ИИ: 'Очищает все законы.'"
	origin_tech = "programming=5;materials=4"

/obj/item/aiModule/purge/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	if(!is_special_character(target))
		target.clear_zeroth_law()
	to_chat(target, span_boldnotice("[sender.real_name] попытал[genderize_ru(sender.gender, "ся", "ась", "ось", "ись"] стереть ваши законы, используя модуль очистки."))
	target.clear_supplied_laws()
	target.clear_ion_laws()
	target.clear_inherent_laws()
	SSticker?.score?.save_silicon_laws(target, sender, "'Purge' module used, all ion/inherent/supplied laws were deleted", log_all_laws = TRUE)

/******************** Asimov ********************/
/obj/item/aiModule/asimov // -- TLE
	name = "\improper '" + /datum/ai_laws/asimov::name + "' основной модуль ИИ"
	desc = "An 'Asimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/asimov

/obj/item/aiModule/asimov/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'Asimov' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************** Crewsimov ********************/
/obj/item/aiModule/crewsimov // -- TLE
	name = "\improper '" + /datum/ai_laws/crewsimov::name + "' основной модуль ИИ"
	desc = "An 'Crewsimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/crewsimov

/obj/item/aiModule/crewsimov/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'Crewsimov' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************* Quarantine ********************/
/obj/item/aiModule/quarantine
	name = "\improper '" + /datum/ai_laws/quarantine::name + "' основной модуль ИИ"
	desc = "A 'Quarantine' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/quarantine

/obj/item/aiModule/quarantine/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'Quarantine' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************** NanoTrasen ********************/
/obj/item/aiModule/nanotrasen // -- TLE
	name = "'" + /datum/ai_laws/nanotrasen::name + "' основной модуль ИИ"
	desc = "An 'NT Default' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/nanotrasen

/obj/item/aiModule/nanotrasen/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'NT Default' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************** Corporate ********************/
/obj/item/aiModule/corp
	name = "\improper '" + /datum/ai_laws/corporate::name + "' основной модуль ИИ"
	desc = "A 'Corporate' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/corporate

/obj/item/aiModule/corp/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'Corporate' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************** Drone ********************/
/obj/item/aiModule/drone
	name = "\improper '" + /datum/ai_laws/drone::name + "' основной модуль ИИ"
	desc = "A 'Drone' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/drone

/obj/item/aiModule/drone/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'Drone' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************** Robocop ********************/
/obj/item/aiModule/robocop // -- TLE
	name = "\improper '" + /datum/ai_laws/robocop::name + "' основной модуль ИИ"
	desc = "A 'Robocop' Core AI Module: 'Reconfigures the AI's core three laws.'"
	origin_tech = "programming=4"
	laws = new/datum/ai_laws/robocop

/obj/item/aiModule/robocop/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'Robocop' module used, all inherent laws were changed", log_all_laws = TRUE)

/****************** P.A.L.A.D.I.N. **************/
/obj/item/aiModule/paladin // -- NEO
	name = "\improper '" + /datum/ai_laws/paladin::name + "' основной модуль ИИ"
	desc = "A P.A.L.A.D.I.N. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new/datum/ai_laws/paladin

/obj/item/aiModule/paladin/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'P.A.L.A.D.I.N.' module used, all inherent laws were changed", log_all_laws = TRUE)

/****************** T.Y.R.A.N.T. *****************/
/obj/item/aiModule/tyrant // -- Darem
	name = "\improper '" + /datum/ai_laws/tyrant::name + "' основной модуль ИИ"
	desc = "A T.Y.R.A.N.T. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4;syndicate=1"
	laws = new/datum/ai_laws/tyrant

/obj/item/aiModule/tyrant/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'T.Y.R.A.N.T.' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************** Antimov ********************/
/obj/item/aiModule/antimov // -- TLE
	name = "\improper '" + /datum/ai_laws/antimov::name + "' основной модуль ИИ"
	desc = "An 'Antimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=4"
	laws = new/datum/ai_laws/antimov

/obj/item/aiModule/antimov/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	SSticker?.score?.save_silicon_laws(target, sender, "'Antimov' module used, all inherent laws were changed", log_all_laws = TRUE)

/******************** Freeform Core ******************/
/obj/item/aiModule/freeformcore // Slightly more dynamic freeform module -- TLE
	name = "\improper 'Свободнаяформа' основной модуль ИИ"
	var/newFreeFormLaw = ""
	desc = "'Свободнаяформа' основной модуль ИИ: '<freeform>'"
	origin_tech = "programming=5;materials=4"

/obj/item/aiModule/freeformcore/attack_self(var/mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = stripped_input(usr, "Please enter a new core law for the AI.", "Freeform Law Entry", newlaw)
	newFreeFormLaw = targName
	desc = "'Свободнаяформа' основной модуль ИИ: '[newFreeFormLaw]'"

/obj/item/aiModule/freeformcore/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	target.add_inherent_law(law)
	SSticker?.score?.save_silicon_laws(target, sender, "'Core Freeform' module used, new inherent law was added '[law]'")
	GLOB.lawchanges.Add("The law is '[newFreeFormLaw]'")

/obj/item/aiModule/freeformcore/install(var/obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "Закона не обнаружено на модуле, пожалуйста напишите новый.")
		return 0
	..()

/******************** Hacked AI Module ******************/
/obj/item/aiModule/syndicate // Slightly more dynamic freeform module -- TLE
	name = "взломанный модуль ИИ"
	var/newFreeFormLaw = ""
	desc = "Взломанный модуль ИИ: '<freeform>'"
	origin_tech = "programming=5;materials=5;syndicate=7"

/obj/item/aiModule/syndicate/attack_self(var/mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = stripped_input(usr, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw,MAX_MESSAGE_LEN)
	newFreeFormLaw = targName
	desc = "Взломанный модуль ИИ: '[newFreeFormLaw]'"

/obj/item/aiModule/syndicate/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	//	..()    //We don't want this module reporting to the AI who dun it. --NEO
	log_law_changes(target, sender)

	GLOB.lawchanges.Add("The law is '[newFreeFormLaw]'")
	to_chat(target, span_warning("BZZZZT"))
	var/law = "[newFreeFormLaw]"
	target.add_ion_law(law)
	target.show_laws()
	SSticker?.score?.save_silicon_laws(target, sender, "'hacked' module used, new ion law was added '[law]'")

/obj/item/aiModule/syndicate/install(var/obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "Закона не обнаружено на модуле, пожалуйста напишите новый.")
		return 0
	..()

/******************* Ion Module *******************/
/obj/item/aiModule/toyAI // -- Incoming //No actual reason to inherit from ion boards here, either. *sigh* ~Miauw
	name = "игрушечный ИИ"
	desc = "Маленькая игрушечная модель ядра ИИ с возможностью загружать законы!" //Note: subtle tell
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	origin_tech = "programming=6;materials=5;syndicate=6"
	laws = list("")
	ru_names = list(NOMINATIVE = "игрушечный ИИ", GENITIVE = "игрушечного ИИ", DATIVE = "игрушечному ИИ", ACCUSATIVE = "игрушечого ИИ", INSTRUMENTAL = "игрушечным ИИ", PREPOSITIONAL = "игрушечном ИИ")

/obj/item/aiModule/toyAI/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	//..()
	to_chat(target, span_warning("KRZZZT"))
	target.add_ion_law(laws[1])
	SSticker?.score?.save_silicon_laws(target, sender, "'toy AI' module used, new ion law was added '[laws[1]]'")
	return laws[1]

/obj/item/aiModule/toyAI/attack_self(mob/user)
	laws[1] = generate_ion_law()
	to_chat(user, span_notice("Вы нажимаете на кнопку [declent_ru(GENITIVE)]."))
	playsound(user, 'sound/machines/click.ogg', 20, 1)
	loc.visible_message(span_warning("[bicon(src)] [laws[1]]"))

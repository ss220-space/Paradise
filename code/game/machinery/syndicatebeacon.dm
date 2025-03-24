//  Beacon randomly spawns in space
//	When a non-traitor (no special role in /mind) uses it, he is given the choice to become a traitor
//	If he accepts there is a random chance he will be accepted, rejected, or rejected and killed
//	Bringing certain items can help improve the chance to become a traitor


/obj/machinery/syndicate_beacon
	name = "ominous beacon"
	desc = "This looks suspicious..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	anchored = TRUE
	density = TRUE

	var/temptext = ""
	var/selfdestructing = 0
	var/charges = 1

/obj/machinery/syndicate_beacon/attack_hand(var/mob/user as mob)
	add_fingerprint(user)
	usr.set_machine(src)
	var/dat = {"<span style='color: #005500;'><i>Scanning [pick("retina pattern", "voice print", "fingerprints", "dna sequence")]...<br>Identity confirmed,<br></i></span>"}
	if(ishuman(user) || istype(user, /mob/living/silicon/ai))
		if(is_special_character(user))
			dat += "<span style='color: #07700;'><i>Operative record found. Greetings, Agent [user.name].</i></span><br>"
		else if(charges < 1)
			dat += "<tt>Connection severed.</tt><bb>"
		else
			var/honorific = "Mr."
			if(user.gender == FEMALE)
				honorific = "Ms."
			dat += "<span style='color: red;'><i>Identity not found in operative database. What can the Syndicate do for you today, [honorific] [user.name]?</i></span><br>"
			if(!selfdestructing)
				dat += "<br><br><a href='byond://?src=[UID()];betraitor=1;traitormob=\ref[user]'>\"[pick("I want to switch teams.", "I want to work for you.", "Let me join you.", "I can be of use to you.", "You want me working for you, and here's why...", "Give me an objective.", "How's the 401k over at the Syndicate?")]\"</a><br>"
	dat += temptext
	var/datum/browser/popup = new(user, "syndbeacon", "Syndicate Beacon")
	popup.set_content(dat)
	popup.open(TRUE)
	onclose(user, "syndbeacon")

/obj/machinery/syndicate_beacon/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["betraitor"])
		if(charges < 1)
			src.updateUsrDialog()
			return
		var/mob/M = locate(href_list["traitormob"])
		if(M.mind.special_role)
			temptext = "<i>В данный момент вы нам не нужны. Приятного дня.</i><br>"
			src.updateUsrDialog()
			return
		charges -= 1
		if(prob(50))
			temptext = "<span style='color: red;'><i><b>Двойной агент. Ты планировал предать нас с самого начала. Позвольте нам отплатить за услугу тем же.</b></i></span>"
			src.updateUsrDialog()
			spawn(rand(50,200)) selfdestruct()
			return
		if(ishuman(M))
			var/mob/living/carbon/human/N = M
			var/objective = "Свободная цель"
			var/objective_name = "Свободная цель"
			switch(rand(1,100))
				if(1 to 50)
					objective = "Украдите [pick("ручной телепортер", "Капитанский антикварный лазер", "Капитанский джетпак", "Капитанскую ID карту", "Капитанский комбинезон")]."
					objective_name = "Украсть"
				if(51 to 60)
					objective = "Уничтожьте не менее 70% плазменных резервуаров станции."
					objective_name = "Уничтожить плазму"
				if(61 to 70)
					objective = "Отключите электроэнергию на 80% или более территории станции."
					objective_name = "Обесточить станцию"
				if(71 to 80)
					objective = "Уничтожьте ИИ."
					objective_name = "Уничтожить ИИ"
				if(81 to 90)
					objective = "Убейте всех обезьян на станции."
					objective_name = "Уничтожить обезьян"
				else
					objective = "Убедитесь, что по крайней мере 80% станции эвакуируется на шаттле."
					objective_name = "Эвакуировать экипаж"

			var/datum/objective/custom_objective = new(objective)
			custom_objective.needs_target = FALSE
			custom_objective.owner = N.mind
			custom_objective.antag_menu_name = objective_name
			N.mind.objectives += custom_objective
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = N.mind
			N.mind.objectives += escape_objective

			var/datum/antagonist/traitor/T = new()
			T.give_objectives = FALSE
			N.mind.add_antag_datum(T)

			to_chat(M, "<b>Вы вступили в ряды Синдиката и стали предателем!</b>")
			message_admins("[key_name_admin(N)] has accepted a traitor objective from a syndicate beacon.")


	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/syndicate_beacon/proc/selfdestruct()
	selfdestructing = 1
	spawn() explosion(src.loc, rand(3,8), rand(1,3), 1, 10)



////////////////////////////////////////
//Singularity beacon
////////////////////////////////////////
/obj/machinery/power/singularity_beacon
	name = "ominous beacon"
	desc = "This looks suspicious..."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "beacon"

	anchored = FALSE
	density = TRUE
	layer = MOB_LAYER - 0.2 //so people can't hide it and it's REALLY OBVIOUS
	stat = 0

	var/active = 0
	var/icontype = "beacon"


/obj/machinery/power/singularity_beacon/proc/Activate(mob/user = null)
	if(surplus() < 1500)
		if(user)
			to_chat(user, span_notice("The connected wire doesn't have enough current."))
		return
	for(var/thing in GLOB.singularities)
		var/obj/singularity/singulo = thing
		if(singulo.z == z)
			singulo.target = src
	icon_state = "[icontype]1"
	active = 1
	START_PROCESSING(SSmachines, src)
	if(user)
		to_chat(user, span_notice("You activate the beacon."))


/obj/machinery/power/singularity_beacon/proc/Deactivate(mob/user = null)
	for(var/thing in GLOB.singularities)
		var/obj/singularity/singulo = thing
		if(singulo.target == src)
			singulo.target = null
	icon_state = "[icontype]0"
	active = 0
	if(user)
		to_chat(user, span_notice("You deactivate the beacon."))


/obj/machinery/power/singularity_beacon/attack_ai(mob/user as mob)
	return


/obj/machinery/power/singularity_beacon/attack_hand(var/mob/user as mob)
	if(anchored)
		add_fingerprint(user)
		return active ? Deactivate(user) : Activate(user)
	else
		to_chat(user, span_warning("You need to screw the beacon to the floor first!"))
		return


/obj/machinery/power/singularity_beacon/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(active)
		to_chat(user, span_warning("You need to deactivate the beacon first!"))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(anchored)
		set_anchored(FALSE)
		to_chat(user, span_notice("You unscrew the beacon from the floor."))
		disconnect_from_network()
		return
	else
		if(!connect_to_network())
			to_chat(user, "This device must be placed over an exposed cable.")
			return
		set_anchored(TRUE)
		to_chat(user, span_notice("You screw the beacon to the floor and attach the cable."))

/obj/machinery/power/singularity_beacon/Destroy()
	if(active)
		Deactivate()
	return ..()

//stealth direct power usage
/obj/machinery/power/singularity_beacon/process()
	if(!active)
		return PROCESS_KILL

	if(surplus() >= 1500)
		add_load(1500)
	else
		Deactivate()

/obj/machinery/power/singularity_beacon/syndicate
	icontype = "beaconsynd"
	icon_state = "beaconsynd0"

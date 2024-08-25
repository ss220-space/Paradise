/obj/structure/AIcore
	density = TRUE
	anchored = FALSE
	name = "AI core"
	icon = 'icons/mob/ai.dmi'
	icon_state = "0"
	max_integrity = 500
	var/state = 0
	var/datum/ai_laws/laws = null
	var/obj/item/circuitboard/aicore/circuit = null
	var/obj/item/mmi/brain = null

/obj/structure/AIcore/Destroy()
	QDEL_NULL(laws)
	QDEL_NULL(circuit)
	QDEL_NULL(brain)
	return ..()


/obj/structure/AIcore/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	switch(state)
		if(EMPTY_CORE)
			if(istype(I, /obj/item/circuitboard/aicore))
				if(!user.drop_transfer_item_to_loc(I, src))
					return ..()
				add_fingerprint(user)
				playsound(loc, I.usesound, 50, TRUE)
				to_chat(user, span_notice("You place the circuit board inside the frame."))
				update_icon(UPDATE_ICON_STATE)
				state = CIRCUIT_CORE
				circuit = I
				return ATTACK_CHAIN_BLOCKED_ALL

		if(SCREWED_CORE)
			if(istype(I, /obj/item/stack/cable_coil))
				add_fingerprint(user)
				var/obj/item/stack/cable_coil/coil = I
				if(coil.get_amount() < 5)
					to_chat(user, span_warning("You need five lengths of cable to wire the frame!"))
					return ATTACK_CHAIN_PROCEED
				playsound(loc, coil.usesound, 50, TRUE)
				to_chat(user, span_notice("You start to add cables to the frame."))
				if(!do_after(user, 2 SECONDS * coil.toolspeed, src, category = DA_CAT_TOOL) || state != SCREWED_CORE || QDELETED(coil))
					return ATTACK_CHAIN_PROCEED
				if(!coil.use(5))
					to_chat(user, span_warning("At some point during construction you lost some cable. Make sure you have five lengths before trying again."))
					return ATTACK_CHAIN_PROCEED
				to_chat(user, span_notice("You add cables to the frame."))
				state = CABLED_CORE
				update_icon(UPDATE_ICON_STATE)
				return ATTACK_CHAIN_PROCEED_SUCCESS

		if(CABLED_CORE)
			if(istype(I, /obj/item/stack/sheet/rglass))
				add_fingerprint(user)
				var/obj/item/stack/sheet/rglass/rglass = I
				if(rglass.get_amount() < 2)
					to_chat(user, span_warning("You need two sheets of [rglass.name] to insert them into the AI core!"))
					return ATTACK_CHAIN_PROCEED
				if(!do_after(user, 2 SECONDS * rglass.toolspeed, src, category = DA_CAT_TOOL) || state != CABLED_CORE || QDELETED(rglass))
					return ATTACK_CHAIN_PROCEED
				if(!rglass.use(2))
					to_chat(user, span_warning("At some point during construction you lost some [rglass.name]. Make sure you have two sheets of [rglass.name] before trying again."))
					return ATTACK_CHAIN_PROCEED
				to_chat(user, span_notice("You put in the [rglass.name] panel."))
				state = GLASS_CORE
				update_icon(UPDATE_ICON_STATE)
				return ATTACK_CHAIN_PROCEED_SUCCESS

			if(istype(I, /obj/item/aiModule/purge))
				add_fingerprint(user)
				laws.clear_inherent_laws()
				to_chat(user, span_notice("Law module applied."))
				return ATTACK_CHAIN_PROCEED_SUCCESS

			if(istype(I, /obj/item/aiModule/freeform))
				add_fingerprint(user)
				var/obj/item/aiModule/freeform/freeform = I
				laws.add_inherent_law(freeform.newFreeFormLaw)
				to_chat(user, span_notice("Added a freeform law."))
				return ATTACK_CHAIN_PROCEED_SUCCESS

			if(istype(I, /obj/item/aiModule))
				add_fingerprint(user)
				var/obj/item/aiModule/aiModule = I
				if(!aiModule.laws)
					to_chat(user, span_warning("This AI module can not be applied directly to AI cores."))
					return ATTACK_CHAIN_PROCEED
				laws = aiModule.laws
				return ATTACK_CHAIN_PROCEED_SUCCESS

			if(istype(I, /obj/item/mmi))
				add_fingerprint(user)
				if(brain)
					to_chat(user, span_warning("There is already [brain] installed into the frame."))
					return ATTACK_CHAIN_PROCEED

				var/obj/item/mmi/mmi = I
				if(!mmi.brainmob)
					to_chat(user, span_warning("Sticking an empty [mmi.name] into the frame would sort of defeat the purpose."))
					return ATTACK_CHAIN_PROCEED

				if(mmi.brainmob.stat == DEAD)
					to_chat(user, span_warning("Sticking a dead [mmi.name] into the frame would sort of defeat the purpose."))
					return ATTACK_CHAIN_PROCEED

				if(!mmi.brainmob.client)
					to_chat(user, span_warning("Sticking an inactive [mmi.name] into the frame would sort of defeat the purpose."))
					return ATTACK_CHAIN_PROCEED

				if(jobban_isbanned(mmi.brainmob, JOB_TITLE_AI) || jobban_isbanned(mmi.brainmob, "nonhumandept"))
					to_chat(user, span_warning("This [mmi.name] does not seem to fit."))
					return ATTACK_CHAIN_PROCEED

				var/datum/job/job_ai = SSjobs.name_occupations[JOB_TITLE_AI]
				if(job_ai.available_in_playtime(mmi.brainmob.client))
					to_chat(user, span_warning("This [mmi.name] does not seem to fit."))
					return ATTACK_CHAIN_PROCEED

				if(!mmi.brainmob.mind)
					to_chat(user, span_warning("This [mmi.name] is mindless!"))
					return ATTACK_CHAIN_PROCEED

				if(istype(mmi, /obj/item/mmi/syndie))
					to_chat(user, span_warning("This MMI does not seem to fit!"))
					return ATTACK_CHAIN_PROCEED

				if(!user.drop_transfer_item_to_loc(mmi, src))
					return ..()

				brain = mmi
				to_chat(user, span_notice("You add [mmi] to the frame."))
				update_icon(UPDATE_ICON_STATE)
				return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/AIcore/crowbar_act(mob/living/user, obj/item/I)
	if(state !=CIRCUIT_CORE && state != GLASS_CORE && !(state == CABLED_CORE && brain))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	switch(state)
		if(CIRCUIT_CORE)
			to_chat(user, span_notice("You remove the circuit board."))
			state = EMPTY_CORE
			circuit.forceMove(loc)
			circuit = null
			return
		if(GLASS_CORE)
			to_chat(user, span_notice("You remove the glass panel."))
			state = CABLED_CORE
			new /obj/item/stack/sheet/rglass(loc, 2)
			return
		if(CABLED_CORE)
			if(brain)
				to_chat(user, span_notice("You remove the brain."))
				brain.forceMove(loc)
				brain = null
	update_icon(UPDATE_ICON_STATE)

/obj/structure/AIcore/screwdriver_act(mob/living/user, obj/item/I)
	if(!(state in list(SCREWED_CORE, CIRCUIT_CORE, GLASS_CORE, AI_READY_CORE)))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	switch(state)
		if(SCREWED_CORE)
			to_chat(user, span_notice("You unfasten the circuit board."))
			state = CIRCUIT_CORE
		if(CIRCUIT_CORE)
			to_chat(user, span_notice("You screw the circuit board into place."))
			state = SCREWED_CORE
		if(GLASS_CORE)
			message_admins("[key_name_admin(usr)] has completed an AI core in [ADMIN_VERBOSEJMP(src)].")
			add_game_logs("has completed an AI core in [AREACOORD(src)].", usr)
			to_chat(user, span_notice("You connect the monitor."))
			if(!brain)
				var/open_for_latejoin = tgui_alert(user, "Would you like this core to be open for latejoining AIs?", "Latejoin", list("Yes", "No")) == "Yes"
				var/obj/structure/AIcore/deactivated/D = new(loc)
				if(open_for_latejoin)
					GLOB.empty_playable_ai_cores += D
			else
				if(brain.brainmob.mind)
					SSticker.mode.remove_cultist(brain.brainmob.mind, 1)
					SSticker.mode.remove_clocker(brain.brainmob.mind, 1)
					SSticker.mode.remove_revolutionary(brain.brainmob.mind, 1)

				var/mob/living/silicon/ai/A = new /mob/living/silicon/ai(loc, laws, brain)
				if(A) //if there's no brain, the mob is deleted and a structure/AIcore is created
					A.rename_self(JOB_TITLE_AI, 1)
					SSticker?.score?.save_silicon_laws(A, user, "AI construction", log_all_laws = TRUE)
			SSblackbox.record_feedback("amount", "ais_created", 1)
			qdel(src)
		if(AI_READY_CORE)
			to_chat(user, span_notice("You disconnect the monitor."))
			state = GLASS_CORE
	update_icon(UPDATE_ICON_STATE)


/obj/structure/AIcore/wirecutter_act(mob/living/user, obj/item/I)
	if(state != CABLED_CORE)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(brain)
		to_chat(user, span_warning("Get that [brain.name] out of there first!"))
	else
		to_chat(user, span_notice("You remove the cables."))
		state = SCREWED_CORE
		update_icon()
		new /obj/item/stack/cable_coil(loc, 5)

/obj/structure/AIcore/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I, 20)

/obj/structure/AIcore/update_icon_state()
	switch(state)
		if(EMPTY_CORE)
			icon_state = "0"
		if(CIRCUIT_CORE)
			icon_state = "1"
		if(SCREWED_CORE)
			icon_state = "2"
		if(CABLED_CORE)
			if(brain)
				icon_state = "3b"
			else
				icon_state = "3"
		if(GLASS_CORE)
			icon_state = "4"
		if(AI_READY_CORE)
			icon_state = "ai-empty"

/obj/structure/AIcore/deconstruct(disassembled = TRUE)
	if(state == GLASS_CORE)
		new /obj/item/stack/sheet/rglass(loc, 2)
	if(state >= CABLED_CORE)
		new /obj/item/stack/cable_coil(loc, 5)
	if(circuit)
		circuit.forceMove(loc)
		circuit = null
	new /obj/item/stack/sheet/plasteel(loc, 4)
	qdel(src)

/obj/structure/AIcore/welder_act(mob/user, obj/item/I)
	if(state)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_WELD_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		to_chat(user, span_notice("You deconstruct the frame."))
		new /obj/item/stack/sheet/plasteel(drop_location(), 4)
		qdel(src)

/obj/structure/AIcore/deactivated
	name = "inactive AI"
	icon_state = "ai-empty"
	anchored = TRUE
	state = AI_READY_CORE

/obj/structure/AIcore/deactivated/Initialize(mapload)
	. = ..()
	circuit = new(src)

/obj/structure/AIcore/deactivated/Destroy()
	if(src in GLOB.empty_playable_ai_cores)
		GLOB.empty_playable_ai_cores -= src
	return ..()

/client/proc/empty_ai_core_toggle_latejoin()
	set name = "Toggle AI Core Latejoin"
	set category = "Admin"

	var/list/cores = list()
	for(var/obj/structure/AIcore/deactivated/D in world)
		cores["[D] ([D.loc.loc])"] = D

	if(!cores.len)
		to_chat(src, "No deactivated AI cores were found.")

	var/id = input("Which core?", "Toggle AI Core Latejoin", null) as null|anything in cores
	if(!id) return

	var/obj/structure/AIcore/deactivated/D = cores[id]
	if(!D) return

	if(D in GLOB.empty_playable_ai_cores)
		GLOB.empty_playable_ai_cores -= D
		to_chat(src, "\The [id] is now <font color=\"#ff0000\">not available</font> for latejoining AIs.")
	else
		GLOB.empty_playable_ai_cores += D
		to_chat(src, "\The [id] is now <font color=\"#008000\">available</font> for latejoining AIs.")


/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//The type of interaction, the player performing the operation, the AI itself, and the card object, if any.


/atom/proc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(istype(card))
		if(card.flush)
			to_chat(user, span_boldannounceic("ERROR:") + "AI flush is in progress, cannot execute transfer protocol.")
			return 0
	return 1


/obj/structure/AIcore/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(state != AI_READY_CORE || !..())
		return
 //Transferring a carded AI to a core.
	if(interaction == AI_TRANS_FROM_CARD)
		AI.control_disabled = FALSE
		AI.aiRadio.disabledAi = FALSE
		AI.forceMove(loc)//To replace the terminal.
		AI.on_the_card = FALSE
		to_chat(AI, "You have been uploaded to a stationary terminal. Remote device connection restored.")
		to_chat(user, span_boldnotice("Transfer successful:") + span_notice("[AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed."))
		qdel(src)
	else //If for some reason you use an empty card on an empty AI terminal.
		to_chat(user, "There is no AI loaded on this terminal!")

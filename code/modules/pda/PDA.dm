
//The advanced pea-green monochrome lcd of tomorrow.
// EDIT 2020-09-21: We have had NanoUI PDAs for years, and I am now finally TGUI-ing them
// They arent pea green trash. I DEFY YOU COMMENTS!!! -aa

/// Global list of all PDAs in the world
GLOBAL_LIST_EMPTY(PDAs)


/obj/item/pda
	name = "PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	w_class = WEIGHT_CLASS_TINY
	item_flags = DENY_UI_BLOCKED
	slot_flags = ITEM_SLOT_ID|ITEM_SLOT_PDA|ITEM_SLOT_BELT
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	origin_tech = "programming=2"

	//Main variables
	var/owner = null
	var/default_cartridge = null // Access level defined by cartridge
	var/special_pen = null //special variable for nonstandart pens in new PDAs
	var/obj/item/cartridge/cartridge = null //current cartridge
	var/datum/data/pda/app/current_app = null
	var/datum/data/pda/app/lastapp = null

	//Secondary variables
	var/model_name = "Thinktronic 5230 Personal Data Assistant"
	var/datum/data/pda/utility/scanmode/scanmode = null

	var/lock_code = "" // Lockcode to unlock uplink
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/detonate = 1 // Can the PDA be blown up?
	var/ttone = "beep" //The ringtone!
	var/list/ttone_sound = list(
		"beep" = 'sound/machines/twobeep.ogg',
		"boom" = 'sound/effects/explosionfar.ogg',
		"slip" = 'sound/misc/slip.ogg',
		"honk" = 'sound/items/bikehorn.ogg',
		"SKREE" = 'sound/voice/shriek1.ogg',
		"holy" = 'sound/items/PDA/ambicha4-short.ogg',
		"xeno" = 'sound/voice/hiss1.ogg',
		"stalk" = 'sound/items/PDA/stalk1.ogg',
		"stalk2" = 'sound/items/PDA/stalk2.ogg',
	)

	var/list/programs = list(
		new/datum/data/pda/app/main_menu,
		new/datum/data/pda/app/notekeeper,
		new/datum/data/pda/app/messenger,
		new/datum/data/pda/app/manifest,
		new/datum/data/pda/app/atmos_scanner,
		new/datum/data/pda/utility/flashlight)
	var/list/shortcut_cache = list()
	var/list/shortcut_cat_order = list()
	var/list/notifying_programs = list()

	var/obj/item/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above
	var/ownrank = null // this one is rank, never alt title

	var/obj/item/paicard/pai = null	// A slot for a personal AI device
	var/retro_mode = 0

	/// Used for chameleon PDA interactions.
	var/obj/item/pda/chameleon_skin
	/// Custom job name used in chameleon PDA.
	var/fakejob
	/// Our icon saved in the text format for TGUI usage
	var/base64icon
	/// Custom PDA name used in update_name()
	var/custom_name
	/// Current PDA case
	var/obj/item/pda_case/current_case
	/// Current PDA painting applied by /obj/machinery/pdapainter.
	/// Saved in and associatove list format: "icon" -> icon_state/item_state, "base64" - > base64icon, "desc" -> desc
	var/list/current_painting


/*
 *	The Actual PDA
 */
/obj/item/pda/Initialize(mapload)
	. = ..()
	GLOB.PDAs += src
	GLOB.PDAs = sortAtom(GLOB.PDAs)

	base64icon = "[icon2base64(icon(icon, icon_state, frame = 1))]"

	update_programs()
	if(default_cartridge)
		cartridge = new default_cartridge(src)
		cartridge.update_programs(src)
	if(special_pen)
		new special_pen(src)
	else
		new /obj/item/pen(src)
	start_program(find_program(/datum/data/pda/app/main_menu))


/obj/item/pda/Destroy()
	GLOB.PDAs -= src
	var/T = get_turf(loc)
	if(id)
		id.forceMove(T)
	if(pai)
		pai.forceMove(T)
	current_app = null
	scanmode = null
	QDEL_LIST(programs)
	QDEL_NULL(cartridge)
	QDEL_NULL(current_case)
	current_painting?.Cut()
	return ..()


/obj/item/pda/proc/can_use(mob/user)
	if(loc != user)
		return FALSE

	if(user.incapacitated() || !isAI(user) && HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE

	return TRUE


/obj/item/pda/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/pda/GetID()
	return id ? id : ..()


/obj/item/pda/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	. = ..()

	var/mob/user = usr
	if(!ishuman(user) || !Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE

	attack_self(user)
	return TRUE


/obj/item/pda/attack_self(mob/user as mob)
	user.set_machine(src)
	if(active_uplink_check(user))
		return
	ui_interact(user)

/obj/item/pda/proc/start_program(datum/data/pda/P)
	if(P && ((P in programs) || (cartridge && (P in cartridge.programs))))
		return P.start()
	return 0

/obj/item/pda/proc/find_program(type)
	var/datum/data/pda/A = locate(type) in programs
	if(A)
		return A
	if(cartridge)
		A = locate(type) in cartridge.programs
		if(A)
			return A
	return null

// force the cache to rebuild on update_ui
/obj/item/pda/proc/update_shortcuts()
	shortcut_cache.Cut()

/obj/item/pda/proc/update_programs()
	for(var/A in programs)
		var/datum/data/pda/P = A
		P.pda = src

/obj/item/pda/proc/close(mob/user)
	SStgui.close_uis(src)

/obj/item/pda/verb/verb_reset_pda()
	set category = "Object"
	set name = "Reset PDA"
	set src in usr

	if(issilicon(usr))
		return

	if(can_use(usr))
		start_program(find_program(/datum/data/pda/app/main_menu))
		notifying_programs.Cut()
		update_icon(UPDATE_OVERLAYS)
		to_chat(usr, "<span class='notice'>You press the reset button on \the [src].</span>")
		SStgui.update_uis(src)
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")

/obj/item/pda/AltClick(mob/living/user)
	if(!iscarbon(user))
		return
	if(can_use(user))
		if(id)
			remove_id(user)
		else
			to_chat(user, "<span class='warning'>This PDA does not have an ID in it!</span>")


/obj/item/pda/CtrlClick(mob/user)
	..()
	if(issilicon(user))
		return

	if(can_use(user))
		remove_pen(user)


/obj/item/pda/proc/remove_id(mob/user)
	if(!id)
		return
	id.forceMove_turf()
	if(ismob(loc))
		var/mob/M = loc
		M.put_in_hands(id)
		to_chat(user, "<span class='notice'>You remove the ID from the [name].</span>")
		SStgui.update_uis(src)
	id = null
	update_icon(UPDATE_OVERLAYS)


/obj/item/pda/verb/verb_remove_id()
	set category = "Object"
	set name = "Remove id"
	set src in usr

	if(issilicon(usr))
		return

	if( can_use(usr) )
		if(id)
			remove_id(usr)
		else
			to_chat(usr, "<span class='notice'>This PDA does not have an ID in it.</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")

/obj/item/pda/verb/verb_remove_pen()
	set category = "Object"
	set name = "Remove pen"
	set src in usr
	remove_pen(usr)

/obj/item/pda/proc/remove_pen(mob/user)

	if(issilicon(user))
		return

	if( can_use(user) )
		var/obj/item/pen/O = locate() in src
		if(O)
			to_chat(user, "<span class='notice'>You remove \the [O] from [src].</span>")
			if(istype(loc, /mob))
				var/mob/M = loc
				if(M.get_active_hand() == null)
					M.put_in_hands(O)
					return
			O.forceMove(get_turf(src))
		else
			to_chat(user, "<span class='warning'>This PDA does not have a pen in it.</span>")
	else
		to_chat(user, "<span class='notice'>You cannot do this while restrained.</span>")


/obj/item/pda/proc/id_check(mob/user, in_pda_usage)
	if(in_pda_usage)
		if(id)
			remove_id(user)
			return TRUE
		var/obj/item/I = user.get_active_hand()
		if(istype(I, /obj/item/card/id) && user.drop_transfer_item_to_loc(I, src))
			id = I
			update_icon(UPDATE_OVERLAYS)
			return TRUE
		return FALSE
	var/obj/item/card/id/I = user.get_active_hand()
	if(istype(I, /obj/item/card/id) && I.registered_name && user.drop_transfer_item_to_loc(I, src))
		if(id)
			id.forceMove_turf()
			user.put_in_hands(id)
		id = I
		update_icon(UPDATE_OVERLAYS)
		return TRUE
	return FALSE


/obj/item/pda/update_name(updates = ALL)
	. = ..()
	if((ownjob || fakejob) && custom_name)
		name = "[custom_name] ([fakejob ? fakejob : ownjob])"
	else if(chameleon_skin)
		name = initial(chameleon_skin.name)
	else if(ownjob && owner)
		name = "PDA-[owner] ([ownjob])"
	else
		name = initial(name)


/obj/item/pda/update_desc(updates = ALL)
	. = ..()
	if(chameleon_skin)
		desc = initial(chameleon_skin.desc)
	else if(current_case?.new_desc)
		desc = current_case.new_desc
	else if(current_painting)
		desc = current_painting["desc"]
	else
		desc = initial(desc)


/obj/item/pda/update_icon(updates = ALL)
	. = ..()
	update_equipped_item(update_speedmods = FALSE)


/obj/item/pda/update_icon_state()
	if(chameleon_skin)
		icon_state = initial(chameleon_skin.icon_state)
		base64icon = "[icon2base64(icon(icon, icon_state, frame = 1))]"
	else if(current_case?.new_icon_state)
		icon_state = current_case.new_icon_state
		base64icon = "[icon2base64(icon(icon, icon_state, frame = 1))]"
	else if(current_painting)
		icon_state = current_painting["icon"]
		base64icon = current_painting["base64"]
	else
		icon_state = initial(icon_state)
		base64icon = "[icon2base64(icon(icon, icon_state, frame = 1))]"

	if(chameleon_skin)
		item_state = initial(chameleon_skin.item_state)
	else if(current_case?.new_item_state)
		item_state = current_case.new_item_state
	else if(current_painting)
		item_state = current_painting["icon"]
	else
		item_state = initial(item_state)


/obj/item/pda/update_overlays()
	. = ..()

	var/static/list/id_icon_states = icon_states('icons/goonstation/objects/pda_overlay.dmi')
	var/static/list/id_cards_cache = list()
	var/static/pda_blink_overlay
	var/static/pda_light_overlay

	if(!pda_blink_overlay)
		pda_blink_overlay = iconstate2appearance(icon, "pda-r")
		pda_light_overlay = iconstate2appearance(icon, "pda-light")

	if(id && (id.icon_state in id_icon_states))
		if(!id_cards_cache[id.icon_state])
			id_cards_cache[id.icon_state] = iconstate2appearance('icons/goonstation/objects/pda_overlay.dmi', id.icon_state)
		. += id_cards_cache[id.icon_state]

	if(length(notifying_programs))
		. += pda_blink_overlay

	var/datum/data/pda/utility/flashlight/flight = locate() in programs
	if(flight?.fon)
		. += pda_light_overlay


/obj/item/pda/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pda_case))
		add_fingerprint(user)
		if(current_case)
			if(alert("There is already [current_case.name] installed, [I.name] will replace it.", "Are you sure?", "Yes", "No") != "Yes")
				return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ATTACK_CHAIN_PROCEED
		remove_pda_case()
		apply_pda_case(I)
		to_chat(user, span_notice("You have put [I] onto the PDA."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/cartridge))
		add_fingerprint(user)
		if(cartridge)
			to_chat(user, span_warning("The PDA is already holding another cartridge."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		cartridge = I
		cartridge.update_programs(src)
		update_shortcuts()
		to_chat(user, span_notice("You have inserted [I] into the PDA."))
		SStgui.update_uis(src)
		if(cartridge.radio)
			cartridge.radio.hostpda = src
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/card/id))
		add_fingerprint(user)
		var/obj/item/card/id/id_card = I
		if(!id_card.registered_name)
			to_chat(user, span_warning("The PDA rejects empty ID card."))
			return ATTACK_CHAIN_PROCEED
		if(!owner)
			owner = id_card.registered_name
			ownjob = id_card.assignment
			ownrank = id_card.rank
			update_appearance(UPDATE_NAME)
			to_chat(user, span_notice("The ID card has been scanned."))
			SStgui.update_uis(src)
			return ATTACK_CHAIN_PROCEED_SUCCESS
		if(!can_use(user))
			return ATTACK_CHAIN_PROCEED
		if(id_check(user, in_pda_usage = FALSE))
			to_chat(user, span_notice("You have put the ID card into the PDA.<br>You can remove it with <b>ALT-click</b>."))
			SStgui.update_uis(src)
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/paicard))
		add_fingerprint(user)
		if(pai)
			to_chat(user, span_warning("The PDA is already holding another pAI card."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		pai = I
		to_chat(user, span_notice("You have inserted the pAI card into the PDA."))
		SStgui.update_uis(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(is_pen(I))
		add_fingerprint(user)
		var/obj/item/pen/holded_pen = locate() in src
		if(holded_pen)
			to_chat(user, span_warning("The PDA is already holding another pen.<br>You can remove it with <b>Ctrl-click</b>."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You have slided [I] into the PDA.<br>You can remove it with <b>Ctrl-click</b>."))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/pda/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(scanmode && iscarbon(target))
		. |= ATTACK_CHAIN_SUCCESS
		scanmode.scan_mob(target, user)


/obj/item/pda/afterattack(atom/A, mob/user, proximity, params)
	if(proximity && scanmode)
		scanmode.scan_atom(A, user)

/obj/item/pda/proc/explode() //This needs tuning.
	if(!detonate)
		return
	var/turf/T = get_turf(src.loc)

	if(ismob(loc))
		var/mob/M = loc
		M.show_message("<span class='danger'>Your [src] explodes!</span>", 1)

	if(T)
		T.hotspot_expose(700,125)

		explosion(T, -1, -1, 2, 3, cause = src)
	qdel(src)
	return



// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/pda/emp_act(severity)
	for(var/atom/A in src)
		A.emp_act(severity)

/obj/item/pda/proc/play_ringtone()
	var/S

	if(ttone in ttone_sound)
		S = ttone_sound[ttone]
	else
		S = 'sound/machines/twobeep.ogg'
	playsound(loc, S, 50, 1)
	for(var/mob/O in hearers(3, loc))
		O.show_message(text("[bicon(src)] *[ttone]*"))

/obj/item/pda/proc/set_ringtone(mob/user)
	var/new_tone = tgui_input_text(user, "Please enter new ringtone", name, ttone, max_length = 20, encode = FALSE)
	if(in_range(src, usr) && loc == usr)
		if(new_tone)
			if(hidden_uplink && hidden_uplink.check_trigger(usr, trim(lowertext(new_tone)), lowertext(lock_code)))
				to_chat(usr, "The PDA softly beeps.")
				close(usr)
			else
				ttone = new_tone
			return 1
	else
		close(usr)
	return 0

/obj/item/pda/process()
	if(current_app)
		current_app.program_process()

/obj/item/pda/extinguish_light(force = FALSE)
	var/datum/data/pda/utility/flashlight/FL = find_program(/datum/data/pda/utility/flashlight)
	if(FL && FL.fon)
		FL.start()

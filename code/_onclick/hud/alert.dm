//A system to manage and display alerts on screen without needing you to do it yourself

//PUBLIC -  call these wherever you want

/**
 * Proc to create or update an alert. Returns the alert if the alert is new or updated, 0 if it was thrown already.
 * Each mob may only have one alert per category.
 *
 * Arguments:
 * * category - a text string corresponding to what type of alert it is
 * * type - a type path of the actual alert type to throw
 * * severity - is an optional number that will be placed at the end of the icon_state for this alert
 *   For example, high pressure's icon_state is "highpressure" and can be serverity 1 or 2 to get "highpressure1" or "highpressure2"
 * * obj/new_master - optional argument. Sets the alert's icon state to "template" in the ui_style icons with the master as an overlay. Clicks are forwarded to master
 * * no_anim - whether the alert should play a small sliding animation when created on the player's screen
 * * icon_override - makes it so the alert is not replaced until cleared by a clear_alert with clear_override, and it's used for hallucinations.
 * * list/alert_args - a list of arguments to pass to the alert when creating it
 */
/mob/proc/throw_alert(category, type, severity, obj/new_master, override = FALSE, timeout_override, no_anim, icon_override, list/alert_args)
	if(!category)
		return

	var/atom/movable/screen/alert/alert = LAZYACCESS(alerts, category)
	if(alert)
		if(alert.override_alerts)
			return 0
		if(new_master && new_master != alert.master)
			WARNING("[src] threw alert [category] with new_master [new_master] while already having that alert with master [alert.master]")
			clear_alert(category)
			return .()
		else if(alert.type != type)
			clear_alert(category)
			return .()
		else if(!severity || severity == alert.severity)
			if(alert.timeout)
				clear_alert(category)
				return .()
			else //no need to update
				return 0
	else
		if(alert_args)
			alert_args.Insert(1, null) // So it's still created in nullspace.
			alert = new type(arglist(alert_args))
		else
			alert = new type()
		alert.override_alerts = override
		if(override)
			alert.timeout = null

	if(icon_override)
		alert.icon = icon_override

	if(new_master)
		var/old_layer = new_master.layer
		var/old_plane = new_master.plane
		new_master.layer = FLOAT_LAYER
		new_master.plane = FLOAT_PLANE
		alert.add_overlay(new_master)
		new_master.layer = old_layer
		new_master.plane = old_plane
		alert.icon_state = "template" // We'll set the icon to the client's ui pref in reorganize_alerts()
		alert.master = new_master
	else
		alert.icon_state = "[initial(alert.icon_state)][severity]"
		alert.severity = severity

	LAZYSET(alerts, category, alert) // This also creates the list if it doesn't exist
	if(client && hud_used)
		hud_used.reorganize_alerts()

	if(!no_anim)
		alert.transform = matrix(32, 6, MATRIX_TRANSLATE)
		animate(alert, transform = matrix(), time = 2.5, easing = CUBIC_EASING)

	var/timeout = timeout_override || alert.timeout
	if(timeout)
		addtimer(CALLBACK(alert, TYPE_PROC_REF(/atom/movable/screen/alert, do_timeout), src, category), timeout)
		alert.timeout = world.time + timeout - world.tick_lag

	return alert

// Proc to clear an existing alert.
/mob/proc/clear_alert(category, clear_override = FALSE)
	var/atom/movable/screen/alert/alert = LAZYACCESS(alerts, category)
	if(!alert)
		return 0
	if(alert.override_alerts && !clear_override)
		return 0

	alerts -= category
	if(client && hud_used)
		hud_used.reorganize_alerts()
		client.screen -= alert
	qdel(alert)

/atom/movable/screen/alert
	icon = 'icons/mob/screen_alert.dmi'
	icon_state = "default"
	name = "Alert"
	desc = "Something seems to have gone wrong with this alert, so report this bug please"
	mouse_opacity = MOUSE_OPACITY_ICON
	var/timeout = 0 //If set to a number, this alert will clear itself after that many deciseconds
	var/severity = 0
	var/alerttooltipstyle = ""
	var/override_alerts = FALSE //If it is overriding other alerts of the same type

/atom/movable/screen/alert/MouseEntered(location,control,params)
	openToolTip(usr, src, params, title = name, content = desc, theme = alerttooltipstyle)


/atom/movable/screen/alert/MouseExited()
	closeToolTip(usr)

/atom/movable/screen/alert/proc/do_timeout(mob/M, category)
	if(!M || !M.alerts)
		return

	if(timeout && M.alerts[category] == src && world.time >= timeout)
		M.clear_alert(category)

//Gas alerts
/atom/movable/screen/alert/not_enough_oxy
	name = "Choking (No O2)"
	desc = "You're not getting enough oxygen. Find some good air before you pass out! The box in your backpack has an oxygen tank and breath mask in it."
	icon_state = "not_enough_oxy"

/atom/movable/screen/alert/too_much_oxy
	name = "Choking (O2)"
	desc = "There's too much oxygen in the air, and you're breathing it in! Find some good air before you pass out!"
	icon_state = "too_much_oxy"

/atom/movable/screen/alert/not_enough_nitro
    name = "Choking (No N)"
    desc = "You're not getting enough nitrogen. Find some good air before you pass out!"
    icon_state = "not_enough_nitro"

/atom/movable/screen/alert/too_much_nitro
    name = "Choking (N)"
    desc = "There's too much nitrogen in the air, and you're breathing it in! Find some good air before you pass out!"
    icon_state = "too_much_nitro"

/atom/movable/screen/alert/not_enough_co2
	name = "Choking (No CO2)"
	desc = "You're not getting enough carbon dioxide. Find some good air before you pass out!"
	icon_state = "not_enough_co2"

/atom/movable/screen/alert/too_much_co2
	name = "Choking (CO2)"
	desc = "There's too much carbon dioxide in the air, and you're breathing it in! Find some good air before you pass out!"
	icon_state = "too_much_co2"

/atom/movable/screen/alert/not_enough_tox
	name = "Choking (No Plasma)"
	desc = "You're not getting enough plasma. Find some good air before you pass out!"
	icon_state = "not_enough_tox"

/atom/movable/screen/alert/too_much_tox
	name = "Choking (Plasma)"
	desc = "There's highly flammable, toxic plasma in the air and you're breathing it in. Find some fresh air. The box in your backpack has an oxygen tank and gas mask in it."
	icon_state = "too_much_tox"
//End gas alerts

/atom/movable/screen/alert/gross
	name = "Grossed out."
	desc = "That was kind of gross..."
	icon_state = "gross"

/atom/movable/screen/alert/verygross
	name = "Very grossed out."
	desc = "I'm not feeling very well.."
	icon_state = "gross2"

/atom/movable/screen/alert/disgusted
	name = "DISGUSTED"
	desc = "ABSOLUTELY DISGUSTIN'"
	icon_state = "gross3"

// Hunger alerts

/atom/movable/screen/alert/hunger
	icon = 'icons/mob/screen_hunger.dmi'

/atom/movable/screen/alert/hunger/fat
	name = "Fat"
	desc = "You ate too much food, lardass. Run around the station and lose some weight."
	icon_state = "fat"

/atom/movable/screen/alert/hunger/full
	name = "Full"
	desc = "You feel full and satisfied, but you shouldn't eat much more."
	icon_state = "full"

/atom/movable/screen/alert/hunger/well_fed
	name = "Well Fed"
	desc = "You feel quite satisfied, but you may be able to eat a bit more."
	icon_state = "well_fed"

/atom/movable/screen/alert/hunger/fed
	name = "Fed"
	desc = "You feel moderately satisfied, but a bit more food may not hurt."
	icon_state = "fed"

/atom/movable/screen/alert/hunger/hungry
	name = "Hungry"
	desc = "Some food would be good right about now."
	icon_state = "hungry"

/atom/movable/screen/alert/hunger/starving
	name = "Starving"
	desc = "You're severely malnourished. The hunger pains make moving around a chore."
	icon_state = "starving"

/// Machine "hunger"

/atom/movable/screen/alert/hunger/fat/machine
	name = "Over Charged"
	desc = "Your cell has excessive charge due to electrical shocks. Run around the station and spend some energy."

/atom/movable/screen/alert/hunger/full/machine
	name = "Full Charge"
	desc = "Your cell is at full charge. Might want to give APCs some space."

/atom/movable/screen/alert/hunger/well_fed/machine
	name = "High Charge"
	desc = "You're almost all charged, but could top up a bit more."

/atom/movable/screen/alert/hunger/fed/machine
	name = "Half Charge"
	desc = "You feel moderately charged, but a bit more juice couldn't hurt."

/atom/movable/screen/alert/hunger/hungry/machine
	name = "Low Charge"
	desc = "Could use a little charging right about now."

/atom/movable/screen/alert/hunger/starving/machine
	name = "Nearly Discharged"
	desc = "You're almost drained. The low power makes moving around a chore."


/// Vampire "hunger"

/atom/movable/screen/alert/hunger/fat/vampire
	name = "Ожирение"
	desc = "Вы выпили столько крови, что пузо уже не влезает в штаны. Бегайте теперь по станции кругами, чтобы похудеть."

/atom/movable/screen/alert/hunger/full/vampire
	name = "Пресыщение"
	desc = "Вы чувствуете спокойствие и приятную насыщенность. Но жажда крови обязательно вернётся…"

/atom/movable/screen/alert/hunger/well_fed/vampire
	name = "Сытость"
	desc = "Вы вполне сыты, но могли бы выпить ещё немного крови."

/atom/movable/screen/alert/hunger/fed/vampire
	name = "Удовлетворённость"
	desc = "Вы не голодны, но испить ещё немного крови не помешало бы."

/atom/movable/screen/alert/hunger/hungry/vampire
	name = "Недоедание"
	desc = "Вы жаждете отведать свежей крови."

/atom/movable/screen/alert/hunger/starving/vampire
	name = "Жажда"
	desc = "Вас наполняет жажда. Она приносит физическую боль. Вам тяжело передвигаться."

/// End of Vampire "hunger"


/atom/movable/screen/alert/hot
	name = "Too Hot"
	desc = "You're flaming hot! Get somewhere cooler and take off any insulating clothing like a fire suit."
	icon_state = "hot"

/atom/movable/screen/alert/hot/robot
    desc = "The air around you is too hot for a humanoid. Be careful to avoid exposing them to this enviroment."

/atom/movable/screen/alert/cold
	name = "Too Cold"
	desc = "You're freezing cold! Get somewhere warmer and take off any insulating clothing like a space suit."
	icon_state = "cold"

/atom/movable/screen/alert/cold/drask
    name = "Cold"
    desc = "You're breathing supercooled gas! It's stimulating your metabolism to regenerate damaged tissue."

/atom/movable/screen/alert/cold/robot
    desc = "The air around you is too cold for a humanoid. Be careful to avoid exposing them to this enviroment."

/atom/movable/screen/alert/lowpressure
	name = "Low Pressure"
	desc = "The air around you is hazardously thin. A space suit would protect you."
	icon_state = "lowpressure"

/atom/movable/screen/alert/highpressure
	name = "High Pressure"
	desc = "The air around you is hazardously thick. A fire suit would protect you."
	icon_state = "highpressure"

/atom/movable/screen/alert/lightexposure
	name = "Light Exposure"
	desc = "You're exposed to light."
	icon_state = "lightexposure"

/atom/movable/screen/alert/nolight
	name = "No Light"
	desc = "You're not exposed to any light."
	icon_state = "nolight"

/atom/movable/screen/alert/blind
	name = "Blind"
	desc = "You can't see! This may be caused by a genetic defect, eye trauma, being unconscious, \
or something covering your eyes."
	icon_state = "blind"

/atom/movable/screen/alert/high
	name = "High"
	desc = "Whoa man, you're tripping balls! Careful you don't get addicted... if you aren't already."
	icon_state = "high"

/atom/movable/screen/alert/drunk
	name = "Drunk"
	desc = "All that alcohol you've been drinking is impairing your speech, motor skills, and mental cognition."
	icon_state = "drunk"

/atom/movable/screen/alert/embeddedobject
	name = "Embedded Object"
	desc = "Something got lodged into your flesh and is causing major bleeding. It might fall out with time, but surgery is the safest way. \
			If you're feeling frisky, click yourself in help intent to pull the object out."
	icon_state = "embeddedobject"

/atom/movable/screen/alert/embeddedobject/Click()
	if(isliving(usr))
		var/mob/living/carbon/human/M = usr
		return M.help_shake_act(M)

/atom/movable/screen/alert/asleep
	name = "Asleep"
	desc = "You've fallen asleep. Wait a bit and you should wake up. Unless you don't, considering how helpless you are."
	icon_state = "asleep"


/atom/movable/screen/alert/negative
	name = "Negative Gravity"
	desc = "You're getting pulled upwards. While you won't have to worry about falling down anymore, you may accidentally fall upwards!"
	icon_state = "negative"


/atom/movable/screen/alert/weightless
	name = "Weightless"
	desc = "Gravity has ceased affecting you, and you're floating around aimlessly. You'll need something large and heavy, like a \
wall or lattice, to push yourself off if you want to move. A jetpack would enable free range of motion. A pair of \
magboots would let you walk around normally on the floor. Barring those, you can throw things, use a fire extinguisher, \
or shoot a gun to move around via Newton's 3rd Law of Motion."
	icon_state = "weightless"


/atom/movable/screen/alert/highgravity
	name = "High Gravity"
	desc = "You're getting crushed by high gravity, picking up items and movement will be slowed."
	icon_state = "paralysis"


/atom/movable/screen/alert/veryhighgravity
	name = "Crushing Gravity"
	desc = "You're getting crushed by high gravity, picking up items and movement will be slowed. You'll also accumulate brute damage!"
	icon_state = "paralysis"


/atom/movable/screen/alert/fire
	name = "On Fire"
	desc = "You're on fire. Stop, drop and roll to put the fire out or move to a vacuum area."
	icon_state = "fire"


/atom/movable/screen/alert/fire/Click()
	if(!isliving(usr))
		return FALSE

	var/mob/living/living_user = usr
	if(!living_user.can_resist())
		return FALSE

	living_user.changeNext_move(CLICK_CD_RESIST)

	if(!(living_user.mobility_flags & MOBILITY_MOVE))
		return FALSE

	return living_user.resist_fire()


/atom/movable/screen/alert/direction_lock
	name = "Direction Lock"
	desc = "You are facing only one direction, slowing your movement down. Click here to stop the direction lock."
	icon_state = "direction_lock"

/atom/movable/screen/alert/direction_lock/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		return L.clear_forced_look()


//ALIENS

/atom/movable/screen/alert/alien_tox
	name = "Plasma"
	desc = "There's flammable plasma in the air. If it lights up, you'll be toast."
	icon_state = "alien_tox"
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_fire
// This alert is temporarily gonna be thrown for all hot air but one day it will be used for literally being on fire
	name = "Too Hot"
	desc = "It's too hot! Flee to space or at least away from the flames. Standing on weeds will heal you."
	icon_state = "alien_fire"
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_vulnerable
	name = "Severed Matriarchy"
	desc = "Your queen has been killed, you will suffer movement penalties and loss of hivemind. A new queen cannot be made until you recover."
	icon_state = "alien_noqueen"
	alerttooltipstyle = "alien"

//BLOBS

/atom/movable/screen/alert/nofactory
	name = "No Factory"
	desc = "You have no factory, and are slowly dying!"
	icon_state = "blobbernaut_nofactory"
	alerttooltipstyle = "blob"

//SILICONS

/atom/movable/screen/alert/nocell
	name = "Missing Power Cell"
	desc = "Unit has no power cell. No modules available until a power cell is reinstalled. Robotics may provide assistance."
	icon_state = "nocell"

/atom/movable/screen/alert/emptycell
	name = "Out of Power"
	desc = "Unit's power cell has no charge remaining. No modules available until power cell is recharged. \
Recharging stations are available in robotics, the dormitory bathrooms, and the AI satellite."
	icon_state = "emptycell"

/atom/movable/screen/alert/lowcell
	name = "Low Charge"
	desc = "Unit's power cell is running low. Recharging stations are available in robotics, the dormitory bathrooms, and the AI satellite."
	icon_state = "lowcell"

//Diona Nymph
/atom/movable/screen/alert/nymph
	name = "Gestalt merge"
	desc = "You have merged with a diona gestalt and are now part of it's biomass. You can still wiggle yourself free though."

/atom/movable/screen/alert/nymph/Click()
	if(!usr || !usr.client)
		return
	if(isnymph(usr))
		var/mob/living/simple_animal/diona/D = usr
		return D.resist()

//Need to cover all use cases - emag, illegal upgrade module, malf AI hack, traitor cyborg
/atom/movable/screen/alert/hacked
	name = "Hacked"
	desc = "Hazardous non-standard equipment detected. Please ensure any usage of this equipment is in line with unit's laws, if any."
	icon_state = "hacked"

/atom/movable/screen/alert/locked
	name = "Locked Down"
	desc = "Unit has been remotely locked down. Usage of a Robotics Control Console like the one in the Research Director's \
office by your AI master or any qualified human may resolve this matter. Robotics may provide further assistance if necessary."
	icon_state = "locked"

/atom/movable/screen/alert/newlaw
	name = "Law Update"
	desc = "Laws have potentially been uploaded to or removed from this unit. Please be aware of any changes \
so as to remain in compliance with the most up-to-date laws."
	icon_state = "newlaw"
	timeout = 300

/atom/movable/screen/alert/hackingapc
	name = "Hacking APC"
	desc = "An Area Power Controller is being hacked. When the process is \
		complete, you will have exclusive control of it, and you will gain \
		additional processing time to unlock more malfunction abilities."
	icon_state = "hackingapc"
	timeout = 600
	var/atom/target = null

/atom/movable/screen/alert/hackingapc/Destroy()
	target = null
	return ..()

/atom/movable/screen/alert/hackingapc/Click()
	if(!usr || !usr.client)
		return
	if(!target)
		return
	var/mob/living/silicon/ai/AI = usr
	var/turf/T = get_turf(target)
	if(T)
		AI.eyeobj.setLoc(T)

//MECHS
/atom/movable/screen/alert/low_mech_integrity
	name = "Mech Damaged"
	desc = "Mech integrity is low."
	icon_state = "low_mech_integrity"

/atom/movable/screen/alert/mech_port_available
	name = "Connect to Port"
	desc = "Click here to connect to an air port and refill your oxygen!"
	icon_state = "mech_port"
	var/obj/machinery/atmospherics/unary/portables_connector/target = null

/atom/movable/screen/alert/mech_port_available/Destroy()
	target = null
	return ..()

/atom/movable/screen/alert/mech_port_available/Click()
	if(!usr || !usr.client)
		return
	if(!ismecha(usr.loc) || !target)
		return
	var/obj/mecha/M = usr.loc
	if(M.connect(target))
		to_chat(usr, "<span class='notice'>[M] connects to the port.</span>")
	else
		to_chat(usr, "<span class='notice'>[M] failed to connect to the port.</span>")

/atom/movable/screen/alert/mech_port_disconnect
	name = "Disconnect from Port"
	desc = "Click here to disconnect from your air port."
	icon_state = "mech_port_x"

/atom/movable/screen/alert/mech_port_disconnect/Click()
	if(!usr || !usr.client)
		return
	if(!ismecha(usr.loc))
		return
	var/obj/mecha/M = usr.loc
	if(M.disconnect())
		to_chat(usr, "<span class='notice'>[M] disconnects from the port.</span>")
	else
		to_chat(usr, "<span class='notice'>[M] is not connected to a port at the moment.</span>")

/atom/movable/screen/alert/mech_nocell
	name = "Missing Power Cell"
	desc = "Mech has no power cell."
	icon_state = "nocell"

/atom/movable/screen/alert/mech_emptycell
	name = "Out of Power"
	desc = "Mech is out of power."
	icon_state = "emptycell"

/atom/movable/screen/alert/mech_lowcell
	name = "Low Charge"
	desc = "Mech is running out of power."
	icon_state = "lowcell"

/atom/movable/screen/alert/mech_maintenance
	name = "Maintenance Protocols"
	desc = "Maintenance protocols are currently in effect, most actions disabled."
	icon_state = "locked"

//GUARDIANS
/atom/movable/screen/alert/cancharge
	name = "Charge Ready"
	desc = "You are ready to charge at a location!"
	icon_state = "guardian_charge"
	alerttooltipstyle = "parasite"

/atom/movable/screen/alert/canstealth
	name = "Stealth Ready"
	desc = "You are ready to enter stealth!"
	icon_state = "guardian_canstealth"
	alerttooltipstyle = "parasite"

/atom/movable/screen/alert/instealth
	name = "In Stealth"
	desc = "You are in stealth and your next attack will do bonus damage!"
	icon_state = "guardian_instealth"
	alerttooltipstyle = "parasite"


//GHOSTS
//TODO: expand this system to replace the pollCandidates/CheckAntagonist/"choose quickly"/etc Yes/No messages
/atom/movable/screen/alert/notify_cloning
	name = "Revival"
	desc = "Someone is trying to revive you. Re-enter your corpse if you want to be revived!"
	icon_state = "template"
	timeout = 300

/atom/movable/screen/alert/notify_cloning/Click()
	if(!usr || !usr.client)
		return
	var/mob/dead/observer/G = usr
	G.reenter_corpse()


/atom/movable/screen/alert/ghost
	name = "Ghost"
	desc = "Would you like to ghost? You will be notified when your body is removed from the nest."
	icon_state = "template"
	timeout = 5 MINUTES // longer than any infection should be


/atom/movable/screen/alert/ghost/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/image/I = image('icons/mob/mob.dmi', icon_state = "ghost", layer = FLOAT_LAYER, dir = SOUTH)
	I.layer = FLOAT_LAYER
	I.plane = FLOAT_PLANE
	add_overlay(I)


/atom/movable/screen/alert/ghost/Click()
	var/mob/living/carbon/human/infected_user = usr
	if(!istype(infected_user) || infected_user.stat == DEAD)
		infected_user.clear_alert("ghost_nest")
		return
	var/obj/item/clothing/mask/facehugger/hugger_mask = infected_user.wear_mask
	if(!istype(hugger_mask) || !(locate(/obj/item/organ/internal/body_egg/alien_embryo) in infected_user.internal_organs) || hugger_mask.sterile)
		infected_user.clear_alert("ghost_nest")
		return
	infected_user.ghostize(TRUE)


#define FLOAT_LAYER_TIME -1
#define FLOAT_LAYER_STACKS -2
#define FLOAT_LAYER_SELECTOR -3

/atom/movable/screen/alert/notify_action
	name = "Body created"
	desc = "A body was created. You can enter it."
	icon_state = "template"
	timeout = 30 SECONDS
	/// Target atom of this alert
	var/atom/target
	/// Action type we got from clicking on this alert
	var/action = NOTIFY_JUMP
	/// If true you need to call START_PROCESSING manually
	var/show_time_left = FALSE
	/// MA for maptext showing time left for poll
	var/mutable_appearance/time_left_overlay
	/// MA for overlay showing that you're signed up to poll
	var/mutable_appearance/signed_up_overlay
	/// MA for maptext overlay showing how many polls are stacked together
	var/mutable_appearance/stacks_overlay
	/// If set, on Click() it'll register the player as a candidate
	var/datum/candidate_poll/poll


/atom/movable/screen/alert/notify_action/Initialize(mapload)
	. = ..()
	signed_up_overlay = mutable_appearance('icons/mob/screen_gen.dmi', "selector", FLOAT_LAYER_SELECTOR)


/atom/movable/screen/alert/notify_action/Destroy()
	target = null
	QDEL_NULL(time_left_overlay)
	QDEL_NULL(signed_up_overlay)
	QDEL_NULL(stacks_overlay)
	poll = null
	return ..()


/atom/movable/screen/alert/notify_action/process()
	if(show_time_left)
		var/timeleft = timeout - world.time
		if(timeleft <= 0)
			return PROCESS_KILL
		cut_overlay(time_left_overlay)
		time_left_overlay = new
		time_left_overlay.maptext = MAPTEXT("<span style='font-family: \"Small Fonts\"; font-weight: bold; font-size: 32px; color: [(timeleft <= 10 SECONDS) ? "red" : "white"];'>[CEILING(timeleft / 10, 1)]</span>")
		time_left_overlay.transform = time_left_overlay.transform.Translate(4, 16)
		time_left_overlay.layer = FLOAT_LAYER_TIME
		add_overlay(time_left_overlay)


/atom/movable/screen/alert/notify_action/Click()
	if(!usr || !usr.client)
		return
	var/mob/dead/observer/observer = usr
	if(!istype(observer))
		return

	if(poll)
		var/success = FALSE
		if(observer in poll.signed_up)
			success = poll.remove_candidate(observer)
		else
			success = poll.sign_up(observer)
		if(success)
			// Add a small overlay to indicate we've signed up
			update_signed_up_alert(observer)

	else if(target)
		switch(action)
			if(NOTIFY_ATTACK)
				target.attack_ghost(observer)
			if(NOTIFY_JUMP)
				var/turf/target_turf = get_turf(target)
				if(target_turf)
					observer.abstract_move(target_turf)
			if(NOTIFY_FOLLOW)
				observer.ManualFollow(target)


/atom/movable/screen/alert/notify_action/Topic(href, href_list)
	var/mob/dead/observer/observer = usr
	if(!href_list["signup"] || !poll || !istype(observer))
		return
	var/success = FALSE
	if(observer in poll.signed_up)
		success = poll.remove_candidate(observer)
	else
		success = poll.sign_up(observer)
	if(success)
		update_signed_up_alert(observer)


/atom/movable/screen/alert/notify_action/proc/update_signed_up_alert(mob/user)
	if(user in poll.signed_up)
		add_overlay(signed_up_overlay)
	else
		cut_overlay(signed_up_overlay)


/atom/movable/screen/alert/notify_action/proc/display_stacks(stacks = 1)
	cut_overlay(stacks_overlay)
	if(stacks <= 1)
		return
	stacks_overlay = new
	stacks_overlay.maptext = MAPTEXT("<span style='font-family: \"Small Fonts\"; font-size: 32px; color: yellow;'>[stacks]x</span>")
	stacks_overlay.transform = stacks_overlay.transform.Translate(4, 2)
	stacks_overlay.layer = FLOAT_LAYER_STACKS
	add_overlay(stacks_overlay)

#undef FLOAT_LAYER_TIME
#undef FLOAT_LAYER_STACKS
#undef FLOAT_LAYER_SELECTOR


/atom/movable/screen/alert/notify_soulstone
	name = "Soul Stone"
	desc = "Someone is trying to capture your soul in a soul stone. Click to allow it."
	icon_state = "template"
	timeout = 10 SECONDS
	var/obj/item/soulstone/stone = null
	var/stoner = null

/atom/movable/screen/alert/notify_soulstone/Click()
	if(!usr || !usr.client)
		return
	if(stone)
		if(tgui_alert(usr, "Do you want to be captured by [stoner]'s soul stone? This will destroy your corpse and make it \
		impossible for you to get back into the game as your regular character.", "Respawn", list("No", "Yes")) ==  "Yes")
			stone?.opt_in = TRUE

/atom/movable/screen/alert/notify_soulstone/Destroy()
	stone = null
	return ..()


/atom/movable/screen/alert/notify_mapvote
	name = "Map Vote"
	desc = "Vote on which map you would like to play on next!"
	icon_state = "map_vote"

/atom/movable/screen/alert/notify_mapvote/Click()
	usr.client.vote()

//OBJECT-BASED

/atom/movable/screen/alert/restrained/buckled
	name = "Buckled"
	desc = "You've been buckled to something. Click the alert to unbuckle unless you're handcuffed."
	icon_state = "buckled"

/atom/movable/screen/alert/restrained/handcuffed
	name = "Handcuffed"
	desc = "You're handcuffed and can't act. If anyone drags you, you won't be able to move. Click the alert to free yourself."

/atom/movable/screen/alert/restrained/legcuffed
	name = "Legcuffed"
	desc = "You're legcuffed, which slows you down considerably. Click the alert to free yourself."

/atom/movable/screen/alert/restrained/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		return L.resist()

/atom/movable/screen/alert/restrained/buckled/Click()
	var/mob/living/L = usr
	if(!istype(L) || !L.can_resist())
		return
	L.changeNext_move(CLICK_CD_RESIST)
	if(L.last_special <= world.time)
		return L.resist_buckle()

// PRIVATE = only edit, use, or override these if you're editing the system as a whole

// Re-render all alerts - also called in /datum/hud/show_hud() because it's needed there
/datum/hud/proc/reorganize_alerts()
	var/list/alerts = mymob.alerts
	if(!alerts)
		return FALSE
	var/icon_pref
	if(!hud_shown)
		for(var/i in 1 to alerts.len)
			mymob.client.screen -= alerts[alerts[i]]
		return TRUE
	for(var/i in 1 to alerts.len)
		var/atom/movable/screen/alert/alert = alerts[alerts[i]]
		if(alert.icon_state == "template")
			if(!icon_pref)
				icon_pref = ui_style2icon(mymob.client.prefs.UI_style)
			alert.icon = icon_pref
		switch(i)
			if(1)
				. = ui_alert1
			if(2)
				. = ui_alert2
			if(3)
				. = ui_alert3
			if(4)
				. = ui_alert4
			if(5)
				. = ui_alert5 // Right now there's 5 slots
			else
				. = ""
		alert.screen_loc = .
		mymob.client.screen |= alert
	return TRUE

/atom/movable/screen/alert/Click(location, control, params)
	if(!usr || !usr.client)
		return
	var/paramslist = params2list(params)
	if(paramslist["shift"]) // screen objects don't do the normal Click() stuff so we'll cheat
		to_chat(usr, "<span class='boldnotice'>[name]</span> - <span class='info'>[desc]</span>")
		return
	if(master)
		return usr.client.Click(master, location, control, params)

/atom/movable/screen/alert/Destroy()
	severity = 0
	master = null
	screen_loc = ""
	return ..()

/// Gives the player the option to succumb while in critical condition
/atom/movable/screen/alert/succumb
	name = "Succumb"
	desc = "Shuffle off this mortal coil."
	icon_state = "succumb"

/atom/movable/screen/alert/succumb/Click()
	if(!usr || !usr.client)
		return
	var/mob/living/living_owner = usr
	if(!istype(usr))
		return
	living_owner.do_succumb(TRUE)

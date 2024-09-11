#define DAMAGE 1
#define FIRE_OLAY 2
#define POD_LIGHT 1
#define WINDOW 2
#define RIM 3
#define PAINT 4

#define NO_GRAVITY_SPEED (0.15 SECONDS)
#define GRAVITY_SPEED (0.4 SECONDS)

#define POD_MISC_LOCK_DOOR 		"Lock Doors"
#define POD_MISC_POD_DOORS 		"Toggle Nearby Pod Doors"
#define POD_MISC_UNLOAD_CARGO 	"Unload Cargo"
#define POD_MISC_CHECK_SEAT		"Check under Seat"
#define POD_MISC_LOCATOR_SKAN   "Scan sector"

#define POD_MISC_SYSTEMS list(POD_MISC_LOCK_DOOR, POD_MISC_POD_DOORS, POD_MISC_CHECK_SEAT, POD_MISC_UNLOAD_CARGO, POD_MISC_LOCATOR_SKAN)

/obj/item/pod_paint_bucket
	name = "space pod paintkit"
	desc = "Pimp your ride"
	icon = 'icons/obj/items.dmi'
	icon_state = "paint_red"

/obj/spacepod
	name = "\improper space pod"
	desc = "A space pod meant for space travel."
	icon = 'icons/goonstation/48x48/pods.dmi'
	density = TRUE //Dense. To raise the heat.
	opacity = FALSE

	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	move_force = MOVE_FORCE_VERY_STRONG
	resistance_flags = ACID_PROOF

	layer = BEHIND_MOB_LAYER
	infra_luminosity = 15

	var/mob/living/pilot	//There is only ever one pilot and he gets all the privledge
	var/list/mob/passengers = list() //passengers can't do anything and are variable in number
	var/max_passengers = 0
	var/obj/item/storage/internal/cargo_hold

	var/datum/spacepod/equipment/equipment_system

	var/battery_type = "/obj/item/stock_parts/cell/high"
	var/obj/item/stock_parts/cell/battery

	var/datum/gas_mixture/cabin_air
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/use_internal_tank = 0

	var/hatch_open = 0

	var/next_firetime = 0

	var/has_paint = 0

	var/list/pod_overlays
	var/list/pod_paint_effect
	var/list/colors = new/list(4)
	var/health = 250

	var/lights = 0
	var/lights_power = 6
	var/can_paint = TRUE

	var/list/icon_light_color = list("pod_civ" = LIGHT_COLOR_WHITE, \
									 "pod_mil" = "#BBF093", \
									 "pod_synd" = LIGHT_COLOR_RED, \
									 "pod_gold" = LIGHT_COLOR_WHITE, \
									 "pod_black" = "#3B8FE5", \
									 "pod_industrial" = "#CCCC00")

	var/unlocked = TRUE
	var/move_delay = NO_GRAVITY_SPEED
	COOLDOWN_DECLARE(spacepod_move_cooldown)
	COOLDOWN_DECLARE(cooldown_emp)	//Used for disabling movement when hit by an EMP
	var/datum/effect_system/trail_follow/spacepod/ion_trail

	// Actions
	var/datum/action/innate/pod/pod_eject/eject_action = new
	var/datum/action/innate/pod/pod_eject/passanger_eject = new
	var/datum/action/innate/pod/pod_toggle_internals/internals_action = new
	var/datum/action/innate/pod/pod_toggle_lights/lights_action = new
	var/datum/action/innate/pod/pod_fire/fire_action = new
	var/datum/action/innate/pod/pod_misc/misc_action = new

/obj/spacepod/proc/apply_paint(mob/user)
	var/part_type
	if(!can_paint)
		to_chat(user, span_warning("You can't repaint this type of pod!"))
		return

	var/part = input(user, "Choose part", null) as null|anything in list("Lights","Rim","Paint","Windows")
	switch(part)
		if("Lights")
			part_type = POD_LIGHT
		if("Rim")
			part_type = RIM
		if("Paint")
			part_type = PAINT
		if("Windows")
			part_type = WINDOW
		else
	var/coloradd = input(user, "Choose a color", "Color") as color
	colors[part_type] = coloradd
	if(!has_paint)
		has_paint = 1
	update_icons()

/obj/spacepod/get_cell()
	return battery

/obj/spacepod/Initialize(mapload)
	. = ..()
	if(!pod_overlays)
		pod_overlays = new/list(2)
		pod_overlays[DAMAGE] = image(icon, icon_state="pod_damage")
		pod_overlays[FIRE_OLAY] = image(icon, icon_state="pod_fire")
	if(!pod_paint_effect)
		pod_paint_effect = new/list(4)
		pod_paint_effect[POD_LIGHT] = image(icon,icon_state = "LIGHTS")
		pod_paint_effect[WINDOW] = image(icon,icon_state = "Windows")
		pod_paint_effect[RIM] = image(icon,icon_state = "RIM")
		pod_paint_effect[PAINT] = image(icon,icon_state = "PAINT")
	bound_width = 64
	bound_height = 64
	battery = new battery_type(src)
	add_cabin()
	add_airtank()
	src.use_internal_tank = 1
	equipment_system = new(src)
	equipment_system.installed_modules += battery
	GLOB.spacepods_list += src
	cargo_hold = new/obj/item/storage/internal(src)
	cargo_hold.w_class = 5	//so you can put bags in
	cargo_hold.storage_slots = 0	//You need to install cargo modules to use it.
	cargo_hold.max_w_class = 5		//fit almost anything
	cargo_hold.max_combined_w_class = 0 //you can optimize your stash with larger items
	START_PROCESSING(SSobj, src)
	ion_trail = new
	ion_trail.set_up(src)
	ion_trail.start()


/obj/spacepod/Destroy()
	if(equipment_system.cargo_system)
		equipment_system.cargo_system.removed(null)
	QDEL_NULL(equipment_system)
	QDEL_NULL(cargo_hold)
	QDEL_NULL(battery)
	QDEL_NULL(cabin_air)
	QDEL_NULL(internal_tank)
	QDEL_NULL(ion_trail)
	occupant_sanity_check()
	if(pilot)
		eject_pilot()
	if(passengers)
		for(var/mob/M in passengers)
			eject_passenger(M)
	GLOB.spacepods_list -= src
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/spacepod/process()
	give_air()
	regulate_temp()


/obj/spacepod/proc/update_icons()
	if(!pod_overlays)
		pod_overlays = new/list(2)
		pod_overlays[DAMAGE] = image(icon, icon_state="pod_damage")
		pod_overlays[FIRE_OLAY] = image(icon, icon_state="pod_fire")

	if(!pod_paint_effect)
		pod_paint_effect = new/list(4)
		pod_paint_effect[POD_LIGHT] = image(icon,icon_state = "LIGHTS")
		pod_paint_effect[WINDOW] = image(icon,icon_state = "Windows")
		pod_paint_effect[RIM] = image(icon,icon_state = "RIM")
		pod_paint_effect[PAINT] = image(icon,icon_state = "PAINT")
	cut_overlays()

	if(has_paint)
		var/image/to_add
		if(!isnull(pod_paint_effect[POD_LIGHT]))
			to_add = pod_paint_effect[POD_LIGHT]
			to_add.color = colors[POD_LIGHT]
			add_overlay(to_add)
		if(!isnull(pod_paint_effect[WINDOW]))
			to_add = pod_paint_effect[WINDOW]
			to_add.color = colors[WINDOW]
			add_overlay(to_add)
		if(!isnull(pod_paint_effect[RIM]))
			to_add = pod_paint_effect[RIM]
			to_add.color = colors[RIM]
			add_overlay(to_add)
		if(!isnull(pod_paint_effect[PAINT]))
			to_add = pod_paint_effect[PAINT]
			to_add.color = colors[PAINT]
			add_overlay(to_add)
	if(health <= round(initial(health)/2))
		add_overlay(pod_overlays[DAMAGE])
		if(health <= round(initial(health)/4))
			add_overlay(pod_overlays[FIRE_OLAY])


	light_color = icon_light_color[src.icon_state]

	if(blocks_emissive)
		add_overlay(get_emissive_block())

/obj/spacepod/bullet_act(var/obj/item/projectile/P)
	. = P.on_hit(src)
	if(P.damage_type == BRUTE || P.damage_type == BURN)
		deal_damage(P.damage)

/obj/spacepod/AllowDrop()
	return TRUE

/obj/spacepod/blob_act(obj/structure/blob/B)
	deal_damage(30)

/obj/spacepod/force_eject_occupant(mob/target)
	if(target == pilot)
		eject_pilot()
	else
		eject_passenger(target)

/obj/spacepod/proc/eject_pilot()
	pilot.forceMove(get_turf(src))
	RemoveActions(pilot)
	pilot = null

/obj/spacepod/proc/eject_passenger(mob/living/passenger)
	passenger.forceMove(get_turf(src))
	passanger_eject.Remove(passenger)
	passengers -= passenger

/obj/spacepod/attack_animal(mob/living/simple_animal/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if((user.a_intent == INTENT_HELP && user.ckey) || user.melee_damage_upper == 0)
		user.custom_emote(EMOTE_VISIBLE, "[user.friendly] [src].")
		return FALSE
	else
		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		deal_damage(damage)
		visible_message(span_danger("[user]</span> [user.attacktext] [src]!"))
		add_attack_logs(user, src, "attacked")
		return TRUE

/obj/spacepod/attack_alien(mob/living/carbon/alien/user)
	if(user.a_intent == INTENT_HARM)
		user.do_attack_animation(src)
		user.changeNext_move(CLICK_CD_MELEE)
		deal_damage(user.obj_damage)
		playsound(src.loc, 'sound/weapons/slash.ogg', 50, 1, -1)
		to_chat(user, span_warning("You slash at [src]!"))
		visible_message(span_warning("The [user] slashes at [src.name]'s armor!"))

/obj/spacepod/attack_tk()
	return

/obj/spacepod/proc/deal_damage(damage)
	var/oldhealth = health
	health = max(0, health - damage)
	var/percentage = (health / initial(health)) * 100
	occupant_sanity_check()
	if(oldhealth > health && percentage <= 25 && percentage > 0)
		play_sound_to_riders('sound/effects/engine_alert2.ogg')
	if(oldhealth > health && !health)
		play_sound_to_riders('sound/effects/engine_alert1.ogg')
	if(!health)
		spawn(0)
			message_to_riders(span_userdanger("Critical damage to the vessel detected, core explosion imminent!"))
			for(var/i in 1 to 3)
				var/count = 3
				message_to_riders(span_warning("[count]"))
				count--
				sleep(10)
			if(LAZYLEN(pilot) || LAZYLEN(passengers))
				for(var/M in passengers + pilot)
					var/mob/living/L = M
					L.adjustBruteLoss(300)
			explosion(loc, 0, 0, 2, cause = src)
			robogibs(loc)
			robogibs(loc)
			qdel(src)

	update_icons()

/obj/spacepod/proc/repair_damage(var/repair_amount)
	if(health)
		health = min(initial(health), health + repair_amount)
		update_icons()


/obj/spacepod/ex_act(severity)
	occupant_sanity_check()
	switch(severity)
		if(1)
			if(passengers || pilot)
				for(var/mob/M in passengers | pilot)
					var/mob/living/carbon/human/H = M
					if(H)
						H.forceMove(get_turf(src))
						H.ex_act(severity + 1)
						to_chat(H, span_warning("You are forcefully thrown from [src]!"))
			qdel(src)
		if(2)
			deal_damage(100)
		if(3)
			if(prob(40))
				deal_damage(50)

/obj/spacepod/emp_act(severity)
	occupant_sanity_check()
	cargo_hold.emp_act(severity)

	if(battery && battery.charge > 0)
		battery.use((battery.charge/3)/(severity*2))
	deal_damage(80 / severity)
	if(COOLDOWN_TIMELEFT(src, cooldown_emp) < (80 SECONDS / severity))
		COOLDOWN_START(src, cooldown_emp, 80 SECONDS / severity)

	switch(severity)
		if(1)
			message_to_riders(span_warning("The pod console flashes 'Heavy EMP WAVE DETECTED'."))
		if(2)
			message_to_riders(span_warning("The pod console flashes 'EMP WAVE DETECTED'."))

/obj/spacepod/proc/play_sound_to_riders(mysound)
	if(length(passengers | pilot) == 0)
		return
	var/sound/S = sound(mysound)
	S.wait = 0 //No queue
	S.channel = SSsounds.random_available_channel()
	S.volume = 50
	for(var/mob/M in passengers | pilot)
		M << S

/obj/spacepod/proc/message_to_riders(mymessage)
	if(length(passengers | pilot) == 0)
		return
	for(var/mob/M in passengers | pilot)
		to_chat(M, mymessage)


/obj/spacepod/attackby(obj/item/I, mob/user, params)
	var/cached_damage = I.force
	if(user.a_intent == INTENT_HARM)
		. = ..()
		if(!ATTACK_CHAIN_CANCEL_CHECK(.))
			deal_damage(cached_damage)
		return .

	if(istype(I, /obj/item/stock_parts/cell))
		add_fingerprint(user)
		if(!hatch_open)
			to_chat(user, span_warning("The maintenance hatch is closed."))
			return ATTACK_CHAIN_PROCEED
		if(battery)
			to_chat(user, span_warning("The spacepod already has a battery."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		battery = I
		to_chat(user, span_notice("You have installed a new battery into the spacepod."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/spacepod_equipment/key))
		add_fingerprint(user)
		if(!equipment_system)
			to_chat(user, span_warning("The pod has no equipment datum, yell at the coders."))
			return ATTACK_CHAIN_PROCEED
		if(!istype(equipment_system.lock_system, /obj/item/spacepod_equipment/lock/keyed))
			to_chat(user, span_warning("The spacepod has no tumbler lock."))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/spacepod_equipment/key/key = I
		if(key.id != equipment_system.lock_system.id)
			to_chat(user, span_warning("Wrong key."))
			return ATTACK_CHAIN_PROCEED
		lock_pod(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/spacepod_equipment))
		add_fingerprint(user)
		if(!hatch_open)
			to_chat(user, span_warning("The maintenance hatch is closed."))
			return ATTACK_CHAIN_PROCEED
		if(!equipment_system)
			to_chat(user, span_warning("The pod has no equipment datum, yell at the coders."))
			return ATTACK_CHAIN_PROCEED
		var/success = FALSE
		if(istype(I, /obj/item/spacepod_equipment/weaponry))
			success = add_equipment(user, I, "weapon_system")
		else if(istype(I, /obj/item/spacepod_equipment/misc))
			success = add_equipment(user, I, "misc_system")
		else if(istype(I, /obj/item/spacepod_equipment/cargo))
			success = add_equipment(user, I, "cargo_system")
		else if(istype(I, /obj/item/spacepod_equipment/sec_cargo))
			success = add_equipment(user, I, "sec_cargo_system")
		else if(istype(I, /obj/item/spacepod_equipment/lock))
			success = add_equipment(user, I, "lock_system")
		else if(istype(I, /obj/item/spacepod_equipment/locators))
			success = add_equipment(user, I, "locator_system")
		else
			stack_trace("Attempted to install unknown spacepod equipment ([I.type]).")
		if(!success)
			return ATTACK_CHAIN_PROCEED
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/lock_buster))
		var/obj/item/lock_buster/buster = I
		if(!buster.on)
			to_chat(user, span_warning("You should turn on [buster]."))
			return ATTACK_CHAIN_PROCEED
		if(equipment_system.lock_system)
			user.visible_message(
				span_warning("[user] starts drilling through [src]'s lock."),
				span_notice("You start drilling through [src]'s lock..."),
			)
			if(!do_after(user, 10 SECONDS * buster.toolspeed, src, category = DA_CAT_TOOL) || !equipment_system.lock_system)
				return ATTACK_CHAIN_PROCEED
			QDEL_NULL(equipment_system.lock_system)
			unlocked = TRUE
			user.visible_message(
				span_warning("[user] has destroyed [src]'s lock."),
				span_notice("You have destroyed [src]'s lock."),
			)
			return ATTACK_CHAIN_PROCEED_SUCCESS
		if(!unlocked)	// we don't have a lock system, and the pod is still somehow locked, unlocking.
			unlocked = TRUE
			user.visible_message(
				span_notice("[user] has repaired [src]'s doors with [buster]."),
				span_notice("You have repaired [src]'s doors with [buster]."),
			)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	// must be the last option as all items not listed prior will be stored
	if(cargo_hold && cargo_hold.storage_slots > 0 && !hatch_open && unlocked)
		cargo_hold.attackby(I, user, params)
		return ATTACK_CHAIN_BLOCKED_ALL

	. = ..()
	if(!ATTACK_CHAIN_CANCEL_CHECK(.))
		deal_damage(cached_damage)


/obj/spacepod/crowbar_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!equipment_system.lock_system || unlocked || hatch_open)
		hatch_open = !hatch_open
		to_chat(user, span_notice("You [hatch_open ? "open" : "close"] the maintenance hatch."))
	else
		to_chat(user, span_warning("The hatch is locked shut!"))


/obj/spacepod/welder_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return
	. = TRUE
	if(!hatch_open)
		to_chat(user, span_warning("You must open the maintenance hatch before attempting repairs."))
		return
	if(health >= initial(health))
		to_chat(user, span_boldnotice("[src] is fully repaired!"))
		return
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, span_notice("You start welding the spacepod..."))
	if(I.use_tool(src, user, 20, 3, volume = I.tool_volume))
		repair_damage(10)
		to_chat(user, span_notice("You mend some [pick("dents","bumps","damage")] with [I]"))


/obj/spacepod/proc/add_equipment(mob/user, obj/item/spacepod_equipment/SPE, slot)
	if(equipment_system.vars[slot])
		to_chat(user, span_warning("The spacepod already has a [slot], remove it first."))
		return FALSE
	if(SPE.loc == user && !user.drop_transfer_item_to_loc(SPE, src))
		return FALSE
	to_chat(user, span_notice("You have installed [SPE] into the spacepod."))
	equipment_system.vars[slot] = SPE
	var/obj/item/spacepod_equipment/system = equipment_system.vars[slot]
	system.my_atom = src
	equipment_system.installed_modules += SPE
	max_passengers += SPE.occupant_mod
	cargo_hold.storage_slots += SPE.storage_mod["slots"]
	cargo_hold.max_combined_w_class += SPE.storage_mod["w_class"]


/obj/spacepod/attack_hand(mob/user)
	if(user.a_intent == INTENT_GRAB && unlocked)
		var/mob/living/target
		if(pilot)
			target = pilot
		else if(passengers.len > 0)
			target = passengers[1]

		if(istype(target))
			src.visible_message(span_warning("[user] is trying to rip the door open and pull [target] out of the [src]!"),
				span_warning("You see [user] outside the door trying to rip it open!"))
			if(do_after(user, 5 SECONDS, src))
				target.Stun(2 SECONDS)
				if(pilot)
					eject_pilot()
				else
					eject_passenger(target)
				target.visible_message(span_warning("[user] flings the door open and tears [target] out of the [src]"),
					span_warning("The door flies open and you are thrown out of the [src] and to the ground!"))
				return
			target.visible_message(span_warning("[user] was unable to get the door open!"),
					span_warning("You manage to keep [user] out of the [src]!"))

	if(!hatch_open)
		if(cargo_hold.storage_slots > 0)
			if(unlocked)
				cargo_hold.open(user)
			else
				to_chat(user, span_notice("The storage compartment is locked"))
		return ..()
	if(!equipment_system || !istype(equipment_system))
		to_chat(user, span_warning("The pod has no equpment datum, or is the wrong type, yell at IK3I."))
		return
	var/list/possible = list()
	if(battery)
		possible.Add("Energy Cell")
	if(equipment_system.weapon_system)
		possible.Add("Weapon System")
	if(equipment_system.misc_system)
		possible.Add("Misc. System")
	if(equipment_system.cargo_system)
		possible.Add("Cargo System")
	if(equipment_system.sec_cargo_system)
		possible.Add("Secondary Cargo System")
	if(equipment_system.lock_system)
		possible.Add("Lock System")
	if(equipment_system.locator_system)
		possible.Add("Locator System")
	switch(tgui_input_list(user, "Remove which equipment?", "Equipment",possible))
		if("Energy Cell")
			if(user.get_active_hand() && user.get_inactive_hand())
				to_chat(user, span_warning("You need an open hand to do that."))
				return
			battery.forceMove_turf()
			user.put_in_any_hand_if_possible(battery, ignore_anim = FALSE)
			to_chat(user, span_notice("You remove [battery] from the space pod"))
			battery = null
			return
		if("Weapon System")
			remove_equipment(user, equipment_system.weapon_system, "weapon_system")
			return
		if("Misc. System")
			remove_equipment(user, equipment_system.misc_system, "misc_system")
			return
		if("Cargo System")
			remove_equipment(user, equipment_system.cargo_system, "cargo_system")
			return
		if("Secondary Cargo System")
			remove_equipment(user, equipment_system.sec_cargo_system, "sec_cargo_system")
			return
		if("Lock System")
			remove_equipment(user, equipment_system.lock_system, "lock_system")
		if("Locator System")
			remove_equipment(user, equipment_system.locator_system, "locator_system")


/obj/spacepod/proc/remove_equipment(mob/user, obj/item/spacepod_equipment/SPE, slot)

	if(passengers.len > max_passengers - SPE.occupant_mod)
		to_chat(user, span_warning("Someone is sitting in [SPE]!"))
		return

	var/sum_w_class = 0
	for(var/obj/item/I in cargo_hold.contents)
		sum_w_class += I.w_class
	if(cargo_hold.contents.len > cargo_hold.storage_slots - SPE.storage_mod["slots"] || sum_w_class > cargo_hold.max_combined_w_class - SPE.storage_mod["w_class"])
		to_chat(user, span_warning("Empty [SPE] first!"))
		return

	if(user.get_active_hand() && user.get_inactive_hand())
		to_chat(user, span_warning("You need an open hand to do that."))
		return

	SPE.forceMove(get_turf(src))
	user.put_in_any_hand_if_possible(SPE, ignore_anim = FALSE)
	to_chat(user, span_notice("You remove [SPE] from the equipment system."))
	equipment_system.installed_modules -= SPE
	max_passengers -= SPE.occupant_mod
	cargo_hold.storage_slots -= SPE.storage_mod["slots"]
	cargo_hold.max_combined_w_class -= SPE.storage_mod["w_class"]
	SPE.removed(user)
	SPE.my_atom = null
	equipment_system.vars[slot] = null


/obj/spacepod/hear_talk/hear_talk(mob/M, list/message_pieces)
	cargo_hold.hear_talk(M, message_pieces)
	..()

/obj/spacepod/hear_message(mob/M, var/msg)
	cargo_hold.hear_message(M, msg)
	..()

/obj/spacepod/proc/return_inv()

	var/list/L = list(  )

	L += src.contents

	for(var/obj/item/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/gift/G in src)
		L += G.gift
		if(isstorage(G.gift))
			var/obj/item/storage/inv = G.gift
			L += inv.return_inv()
	return L

/obj/spacepod/civilian
	icon_state = "pod_civ"
	desc = "A sleek civilian space pod."


/obj/spacepod/civilian/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/pod_paint_bucket))
		apply_paint(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/spacepod/random
	icon_state = "pod_civ"
// placeholder

/obj/spacepod/sec
	name = "\improper security spacepod"
	desc = "An armed security spacepod with reinforced armor plating."
	icon_state = "pod_dece"
	health = 600

/obj/spacepod/syndi
	name = "syndicate spacepod"
	desc = "A spacepod painted in syndicate colors."
	icon_state = "pod_synd"
	health = 400
	unlocked = FALSE

/obj/spacepod/syndi/unlocked
	unlocked = TRUE


/obj/spacepod/sec/Initialize(mapload)
	. = ..()

	var/obj/item/spacepod_equipment/weaponry/burst_taser/T = new /obj/item/spacepod_equipment/weaponry/taser
	T.loc = equipment_system
	equipment_system.weapon_system = T
	equipment_system.weapon_system.my_atom = src
	equipment_system.installed_modules += T
	var/obj/item/spacepod_equipment/misc/tracker/L = new /obj/item/spacepod_equipment/misc/tracker
	L.loc = equipment_system
	equipment_system.misc_system = L
	equipment_system.misc_system.my_atom = src
	equipment_system.installed_modules += L
	var/obj/item/spacepod_equipment/sec_cargo/chair/C = new /obj/item/spacepod_equipment/sec_cargo/chair
	C.loc = equipment_system
	equipment_system.sec_cargo_system = C
	equipment_system.sec_cargo_system.my_atom = src
	equipment_system.installed_modules += C
	max_passengers = 1
	var/obj/item/spacepod_equipment/lock/keyed/K = new /obj/item/spacepod_equipment/lock/keyed
	K.loc = equipment_system
	equipment_system.lock_system = K
	equipment_system.lock_system.my_atom = src
	equipment_system.lock_system.id = 100000
	equipment_system.installed_modules += K

/obj/spacepod/random/Initialize(mapload)
	. = ..()
	icon_state = pick("pod_civ", "pod_black", "pod_mil", "pod_synd", "pod_gold", "pod_industrial")
	switch(icon_state)
		if("pod_civ")
			desc = "A sleek civilian space pod."
		if("pod_black")
			desc = "An all black space pod with no insignias."
		if("pod_mil")
			desc = "A dark grey space pod brandishing the Nanotrasen Military insignia"
		if("pod_synd")
			desc = "A menacing military space pod with Fuck NT stenciled onto the side"
		if("pod_gold")
			desc = "A civilian space pod with a gold body, must have cost somebody a pretty penny"
		if("pod_industrial")
			desc = "A rough looking space pod meant for industrial work"
	update_icons()

/obj/spacepod/proc/toggle_internal_tank(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(user != pilot)
		to_chat(user, span_notice("You can't reach the controls from your chair."))
		return

	use_internal_tank = !use_internal_tank
	to_chat(user, span_notice("Now taking air from [use_internal_tank?"internal airtank":"environment"]."))

/obj/spacepod/proc/add_cabin()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.oxygen = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.nitrogen = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	return cabin_air

/obj/spacepod/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank

/obj/spacepod/proc/get_turf_air()
	var/turf/T = get_turf(src)
	if(T)
		. = T.return_air()

/obj/spacepod/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	else
		var/turf/T = get_turf(src)
		if(T)
			return T.remove_air(amount)

/obj/spacepod/return_air()
	if(use_internal_tank)
		return cabin_air
	return get_turf_air()

/obj/spacepod/proc/return_pressure()
	. = 0
	if(use_internal_tank)
		. =  cabin_air.return_pressure()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_pressure()

/obj/spacepod/proc/return_temperature()
	. = 0
	if(use_internal_tank)
		. = cabin_air.return_temperature()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_temperature()

/obj/spacepod/proc/moved_other_inside(var/mob/living/carbon/human/H as mob)
	occupant_sanity_check()
	if(passengers.len < max_passengers)
		H.forceMove(src)
		passengers += H
		H.forceMove(src)
		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		return 1

/obj/spacepod/MouseDrop_T(mob/living/dropping, mob/living/user, params)
	if(user == pilot || (user in passengers) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE

	. = TRUE
	if(isliving(dropping))
		occupant_sanity_check()

		if(dropping != user && unlocked && (dropping.stat == DEAD || dropping.incapacitated()))
			if(passengers.len >= max_passengers && !pilot)
				to_chat(user, span_danger("<b>That person can't fly the pod!</b>"))
				return .
			if(passengers.len < max_passengers)
				visible_message(span_danger("[user.name] starts loading [dropping.name] into the pod!"))
				if(do_after(user, 5 SECONDS, dropping))
					moved_other_inside(dropping)
			return .

		if(dropping == user)
			enter_pod(user)

	else if(isobj(dropping))
		load_cargo(user, dropping)


/obj/spacepod/proc/load_cargo(mob/user, obj/object)
	var/obj/item/spacepod_equipment/cargo/cargo = equipment_system.cargo_system
	if(!cargo)
		return
	var/valid_cargo = FALSE
	if(istype(cargo, /obj/item/spacepod_equipment/cargo/ore))
		if(istype(object, /obj/structure/ore_box))
			valid_cargo = TRUE
	else if(istype(cargo, /obj/item/spacepod_equipment/cargo/crate))
		if(istype(object, /obj/structure/closet/crate))
			valid_cargo = TRUE
	if(!valid_cargo)
		return
	if(!cargo.storage)
		to_chat(user, span_notice("You begin loading [object] into [src]'s [cargo]"))
		if(do_after(user, 4 SECONDS, src))
			cargo.storage = object
			object.forceMove(cargo)
			to_chat(user, span_notice("You load [object] into [src]'s [cargo]!"))
		else
			to_chat(user, span_warning("You fail to load [object] into [src]'s [cargo]"))
	else
		to_chat(user, span_warning("[src] already has \an [cargo.storage]"))


/obj/spacepod/proc/enter_pod(mob/user)
	if(!ishuman(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE

	if(equipment_system.lock_system && !unlocked)
		to_chat(user, span_warning("[src]'s doors are locked!"))
		return FALSE

	if(get_dist(src, user) > 2)
		to_chat(user, "They are too far away to put inside")
		return FALSE

	var/fukkendisk = user.GetTypeInAllContents(/obj/item/disk/nuclear)
	if(fukkendisk)
		to_chat(user, span_danger("<B>The nuke-disk is locking the door every time you try to open it. You get the feeling that it doesn't want to go into the spacepod.</b>"))
		return FALSE

	if(user.has_buckled_mobs()) //mob attached to us
		to_chat(user, span_warning("[user] will not fit into [src] because [user.p_they()] [user.p_have()] creatures attached to [user.p_them()]!"))
		return FALSE

	move_inside(user)
	return TRUE


/obj/spacepod/proc/move_inside(mob/living/user)
	if(!istype(user))
		log_debug("SHIT'S GONE WRONG WITH THE SPACEPOD [src] AT [x], [y], [z], AREA [get_area(src)], TURF [get_turf(src)]")

	occupant_sanity_check()

	if(passengers.len <= max_passengers)
		visible_message(span_notice("[user] starts to climb into [src]."))
		if(do_after(user, 4 SECONDS, src))
			if(!pilot || pilot == null)
				pilot = user
				user.forceMove(src)
				GrantActions(user)
				add_fingerprint(user)
				playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
				return
			if(passengers.len < max_passengers)
				passengers += user
				user.forceMove(src)
				passanger_eject.Grant(user, src)
				add_fingerprint(user)
				playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
			else
				to_chat(user, span_notice("You were too slow. Try better next time, loser."))
		else
			to_chat(user, span_notice("You stop entering [src]."))
	else
		to_chat(user, span_danger("You can't fit in [src], it's full!"))

/obj/spacepod/proc/occupant_sanity_check()  // going to have to adjust this later for cargo refactor
	if(passengers)
		if(passengers.len > max_passengers)
			for(var/i = passengers.len; i <= max_passengers; i--)
				var/mob/occupant = passengers[i - 1]
				occupant.forceMove(get_turf(src))
				log_debug("##SPACEPOD WARNING: passengers EXCEED CAP: MAX passengers [max_passengers], passengers [english_list(passengers)], TURF [get_turf(src)] | AREA [get_area(src)] | COORDS [x], [y], [z]")
				passengers[i - 1] = null
		for(var/mob/M in passengers)
			if(!ismob(M))
				M.forceMove(get_turf(src))
				log_debug("##SPACEPOD WARNING: NON-MOB OCCUPANT [M], TURF [get_turf(src)] | AREA [get_area(src)] | COORDS [x], [y], [z]")
				passengers -= M
			else if(M.loc != src)
				log_debug("##SPACEPOD WARNING: OCCUPANT [M] ESCAPED, TURF [get_turf(src)] | AREA [get_area(src)] | COORDS [x], [y], [z]")
				passengers -= M

/obj/spacepod/proc/exit_pod(mob/user)
	if(user.stat != CONSCIOUS) // unconscious people can't let themselves out
		return

	occupant_sanity_check()

	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_notice("You attempt to stumble out of the [src]. This will take two minutes."))
		if(pilot && pilot != user)
			to_chat(pilot, span_warning("[user] is trying to escape the [src]."))
		if(!do_after(user, 2 MINUTES, src))
			return

	if(user == pilot)
		eject_pilot()
	else if(user in passengers)
		eject_passenger(user)

	to_chat(user, span_notice("You climb out of [src]."))

/obj/spacepod/proc/lock_pod(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(user in passengers && user != pilot)
		to_chat(user, span_notice("You can't reach the controls from your chair."))
		return

	if(!equipment_system.lock_system)
		to_chat(user, span_warning("[src] has no locking podnism."))
		unlocked = TRUE //Should never be false without a lock, but if it somehow happens, that will force an unlock.
	else
		unlocked = !unlocked
		to_chat(user, span_warning("You [unlocked ? "unlock" : "lock"] the doors."))


/obj/spacepod/proc/toggleDoors(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(user != pilot)
		to_chat(user, span_notice("You can't reach the controls from your chair"))
		return

	for(var/obj/machinery/door/poddoor/multi_tile/P in orange(3, src))
		var/mob/living/carbon/human/L = user

		if(P.check_access(L.get_active_hand()) || P.check_access(L.wear_id))
			if(P.density)
				P.open()
				return TRUE
			else
				P.close()
				return TRUE

		for(var/mob/living/carbon/human/O in passengers)
			if(P.check_access(O.get_active_hand()) || P.check_access(O.wear_id))
				if(P.density)
					P.open()
					return TRUE
				else
					P.close()
					return TRUE

		to_chat(user, span_warning("Access denied."))
		return

	to_chat(user, span_warning("You are not close to any pod doors."))

/obj/spacepod/proc/fireWeapon(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(user != pilot)
		to_chat(user, span_notice("You can't reach the controls from your chair."))
		return

	if(!equipment_system.weapon_system)
		to_chat(user, span_warning("[src] has no weapons!"))
		return

	equipment_system.weapon_system.fire_weapons()

/obj/spacepod/proc/unload(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(user != pilot)
		to_chat(user, span_notice("You can't reach the controls from your chair."))
		return

	if(!equipment_system.cargo_system)
		to_chat(user, span_warning("[src] has no cargo system!"))
		return

	equipment_system.cargo_system.unload()

/obj/spacepod/proc/toggleLights(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(user != pilot)
		to_chat(user, span_notice("You can't reach the controls from your chair."))
		return

	lights = !lights

	if(lights)
		set_light(lights_power, l_on = TRUE)
	else
		set_light_on(FALSE)

	visible_message("Lights toggled [lights ? "on" : "off"].")

/obj/spacepod/proc/checkSeat(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	to_chat(user, span_notice("You start rooting around under the seat for lost items"))
	if(do_after(user, 4 SECONDS, src))
		var/obj/badlist = list(internal_tank, cargo_hold, pilot, battery) + passengers + equipment_system.installed_modules
		var/list/true_contents = contents - badlist
		if(true_contents.len > 0)
			var/obj/I = pick(true_contents)
			if(user.put_in_any_hand_if_possible(I))
				src.contents -= I
				to_chat(user, span_notice("You find a [I] [pick("under the seat", "under the console", "in the maintenance access")]!"))
			else
				to_chat(user, span_notice("You think you saw something shiny, but you can't reach it!"))
		else
			to_chat(user, span_notice("You fail to find anything of value."))
	else
		to_chat(user, span_notice("You decide against searching the [src]"))

/obj/spacepod/proc/startScan(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(user != pilot)
		to_chat(user, span_notice("You can't reach the controls from your chair."))
		return
	if(!equipment_system.locator_system)
		to_chat(user, span_warning("[src] has no locator system!"))
		return

	equipment_system.locator_system.atom_say("Сканирование сектора...")
	if(do_after(user, 5 SECONDS, src))
		equipment_system.locator_system.scan(user)
	else
		equipment_system.locator_system.atom_say("Ошибка сканирования. Сохраняйте неподвижность.")

/obj/spacepod/proc/GrantActions(mob/living/user)
	eject_action.Grant(user, src)
	internals_action.Grant(user, src)
	lights_action.Grant(user, src)
	misc_action.Grant(user, src)
	fire_action.Grant(user, src)

/obj/spacepod/proc/RemoveActions(mob/living/user)
	eject_action.Remove(user)
	internals_action.Remove(user)
	lights_action.Remove(user)
	misc_action.Remove(user)
	fire_action.Remove(user)

/datum/action/innate/pod
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	var/obj/spacepod/pod

/datum/action/innate/pod/Grant(mob/living/L, obj/spacepod/S)
	if(S)
		pod = S
	. = ..()

/datum/action/innate/pod/Destroy()
	pod = null
	return ..()

/datum/action/innate/pod/pod_eject
	name = "Eject From Pod"
	button_icon_state = "mech_eject"

/datum/action/innate/pod/pod_eject/Activate()
	pod.exit_pod(owner)

/datum/action/innate/pod/pod_toggle_internals
	name = "Toggle Internal Airtank Usage"
	button_icon_state = "mech_internals_on"

/datum/action/innate/pod/pod_toggle_internals/Activate()
	if(!owner || !pod || pod.pilot != owner)
		return
	pod.toggle_internal_tank(owner)
	button_icon_state = "mech_internals_[pod.use_internal_tank ? "on" : "off"]"
	UpdateButtonIcon()

/datum/action/innate/pod/pod_toggle_lights
	name = "Toggle Lights"
	button_icon_state = "mech_lights_off"

/datum/action/innate/pod/pod_toggle_lights/Activate()
	if(!owner || !pod || pod.pilot != owner)
		return
	pod.toggleLights(owner)
	button_icon_state = "mech_lights_[pod.lights ? "on" : "off"]"
	UpdateButtonIcon()

/datum/action/innate/pod/pod_fire
	name = "Fire Pod Weaponds"
	button_icon_state = "mech_zoom_off"

/datum/action/innate/pod/pod_fire/Activate()
	if(!owner || !pod || pod.pilot != owner)
		return
	pod.fireWeapon(owner)

/datum/action/innate/pod/pod_misc
	name = "Misc Pod Systems"
	button_icon_state = "mech_misc"

/datum/action/innate/pod/pod_misc/Activate()
	if(!owner || !pod || pod.pilot != owner)
		return
	var/misc_system = tgui_input_list(owner, "Choose misc module to use", "Spacepod", POD_MISC_SYSTEMS)
	if(!misc_system)
		return
	if(!owner || !pod || pod.pilot != owner) //we check twice because of input
		return
	switch(misc_system)
		if(POD_MISC_LOCK_DOOR)
			pod.lock_pod(owner)
		if(POD_MISC_POD_DOORS)
			pod.toggleDoors(owner)
		if(POD_MISC_UNLOAD_CARGO)
			pod.unload(owner)
		if(POD_MISC_CHECK_SEAT)
			pod.checkSeat(owner)
		if(POD_MISC_LOCATOR_SKAN)
			pod.startScan(owner)

// Fun fact, these procs are just copypastes from pod code
// And have been for the past 4 years
// Please send help
/obj/spacepod/proc/regulate_temp()
	if(cabin_air && cabin_air.return_volume() > 0)
		var/delta = cabin_air.temperature - T20C
		cabin_air.temperature -= max(-10, min(10, round(delta/4,0.1)))

/obj/spacepod/proc/give_air()
	if(internal_tank)
		var/datum/gas_mixture/tank_air = internal_tank.return_air()
		var/release_pressure = ONE_ATMOSPHERE
		var/cabin_pressure = cabin_air.return_pressure()
		var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
		var/transfer_moles = 0
		if(pressure_delta > 0) //cabin pressure lower than release pressure
			if(tank_air.return_temperature() > 0)
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
				cabin_air.merge(removed)
		else if(pressure_delta < 0) //cabin pressure higher than release pressure
			var/datum/gas_mixture/t_air = get_turf_air()
			pressure_delta = cabin_pressure - release_pressure
			if(t_air)
				pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
			if(pressure_delta > 0) //if location pressure is lower than cabin pressure
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
				if(t_air)
					t_air.merge(removed)
				else //just delete the cabin gas, we're in space or some shit
					qdel(removed)


// it looks really good with default Process_Spacemove and newtonian movement actually, should make a button to turn it on/off
/obj/spacepod/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE	// obviously


/obj/spacepod/relaymove(mob/user, direction)
	if(!COOLDOWN_FINISHED(src, spacepod_move_cooldown))
		return FALSE

	if(!pilot || user != pilot || !direction)
		COOLDOWN_START(src, spacepod_move_cooldown, 0.5 SECONDS)	// Don't make it spam
		return FALSE

	. = TRUE

	if(health <= 0)
		to_chat(user, span_warning("She's dead, Jim."))
		. = FALSE
	else if(!battery)
		to_chat(user, span_warning("No energy cell detected."))
		. = FALSE
	else if(!COOLDOWN_FINISHED(src, cooldown_emp))
		to_chat(user, span_warning("The pod control interface isn't responding. The console indicates [COOLDOWN_TIMELEFT(src, cooldown_emp)] second\s before reboot."))
		. = FALSE
	else if(!battery.use(1))
		to_chat(user, span_warning("Not enough charge left."))
		. = FALSE
	if(!.)
		COOLDOWN_START(src, spacepod_move_cooldown, 0.5 SECONDS)
		return .

	if(direction & (UP|DOWN))
		COOLDOWN_START(src, spacepod_move_cooldown, 0.5 SECONDS)
		var/turf/above = GET_TURF_ABOVE(loc)
		if((direction & UP) && can_z_move(DOWN, above, z_move_flags = ZMOVE_FALL_FLAGS)) // going up and can fall down is bad.
			return FALSE
		. = zMove(direction)
		if(.)
			pilot.update_z(z) // after we moved
	else
		var/turf/next_step = get_step(src, direction)
		if(!next_step)
			COOLDOWN_START(src, spacepod_move_cooldown, 0.5 SECONDS)
			return FALSE
		var/calculated_move_delay = has_gravity(loc) ? GRAVITY_SPEED : NO_GRAVITY_SPEED
		. = Move(next_step, direction)
		if(ISDIAGONALDIR(direction) && loc == next_step)
			calculated_move_delay *= sqrt(2)
		set_glide_size(DELAY_TO_GLIDE_SIZE(calculated_move_delay))
		COOLDOWN_START(src, spacepod_move_cooldown, calculated_move_delay)

	if(. && equipment_system.cargo_system)
		for(var/atom/pod_loc as anything in locs)
			for(var/obj/item/item in pod_loc.contents)
				equipment_system.cargo_system.passover(item)


//// Damaged spacepod
/obj/spacepod/civilian/damaged
	desc = "Heavy damaged spacepod"

/obj/spacepod/civilian/damaged/Initialize(mapload)
	. = ..()
	deal_damage(200)
	update_icon()


#undef DAMAGE
#undef FIRE_OLAY
#undef WINDOW
#undef POD_LIGHT
#undef RIM
#undef PAINT
#undef NO_GRAVITY_SPEED
#undef GRAVITY_SPEED
#undef POD_MISC_LOCK_DOOR
#undef POD_MISC_POD_DOORS
#undef POD_MISC_UNLOAD_CARGO
#undef POD_MISC_CHECK_SEAT
#undef POD_MISC_SYSTEMS
#undef POD_MISC_LOCATOR_SKAN

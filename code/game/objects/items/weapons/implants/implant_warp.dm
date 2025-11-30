/obj/item/implant/warp
	name = "warp implant"
	desc = "Warps you to where you were 10 seconds before when activated."
	icon_state = "warp"
	implant_data = /datum/implant_fluff/warp

	STATIC_COOLDOWN_DECLARE(cooldown)
	var/total_delay = 10 SECONDS
	var/last_use = 0
	var/list/positions = list()
	var/next_prune = 0

/obj/item/implant/warp/Destroy()
	positions = null
	return ..()

/obj/item/implant/warp/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if(.)
		update_position()
		RegisterSignal(imp_in, COMSIG_MOVABLE_MOVED, PROC_REF(update_position))

/obj/item/implant/warp/removed(mob/living/source, silent, special)
	. = ..()
	clear_positions()

/obj/item/implant/warp/proc/update_position(datum/source)
	if(!isatom(imp_in.loc))
		return
	positions[num2text(world.time)] = list(imp_in.loc, imp_in.dir)
	if(!((++next_prune) % 10))
		prune()

/obj/item/implant/warp/proc/clear_positions()
	positions = list()

/obj/item/implant/warp/proc/get_tele_position()
	prune()
	return positions[positions[1]][1]

/obj/item/implant/warp/proc/do_teleport_effects()
	var/safety = 100
	var/list/done = list()
	var/time
	var/turf/target

	var/all_steps = min(length(positions), safety)
	var/delta_alpha = round(200 / all_steps)
	var/latest_alpha = 200

	for(var/i in 1 to length(positions))
		if(!--safety)
			break
		time = positions[i]
		target = positions[time][1]
		if(done[target])
			continue
		done[target] = TRUE
		if(!istype(target))
			continue

		var/obj/effect/temp_visual/nothing/warp/temp = new /obj/effect/temp_visual/nothing/warp(target, positions[time][2])

		temp.alpha = latest_alpha
		temp.overlays = imp_in.overlays
		temp.dir = positions[time][2]
		latest_alpha -= delta_alpha

		animate(temp, alpha = 0, time = 9)

/obj/item/implant/warp/activate()
	. = ..()
	if(!COOLDOWN_FINISHED(src, cooldown))
		to_chat(imp_in, span_warning("Имплант еще не готов!"))
		imp_in.balloon_alert(imp_in, "перезарядка!")
		return

	last_use = world.time
	prune()
	do_teleport_effects()		//first.
	do_teleport(imp_in, get_tele_position())

	COOLDOWN_START(src, cooldown, 30 SECONDS)

/obj/item/implant/warp/proc/prune()
	var/minimum_time = world.time - total_delay
	var/remove = 0
	for(var/i in 1 to length(positions))
		if(!(text2num(positions[i]) < minimum_time))
			break
		remove++

	if(!remove)
		return
	positions.Cut(1, remove + 1)

/obj/item/implanter/warp
	name = "Implanter (warp)"
	imp = /obj/item/implant/warp

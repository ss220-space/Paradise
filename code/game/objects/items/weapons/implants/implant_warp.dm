//Indexes for the queue
#define WARP_LOC 1
#define WARP_DIR 2
#define WAPR_MAX_STEPS 125

/obj/item/implant/warp
	name = "warp implant"
	desc = "При активации переносит пользователя на 125 метров назад."
	icon_state = "warp"
	implant_data = /datum/implant_fluff/warp

	STATIC_COOLDOWN_DECLARE(cooldown)
	var/queue/position_queue

/obj/item/implant/warp/Destroy()
	position_queue = null
	return ..()

/obj/item/implant/warp/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if(!.)
		return

	position_queue = new()
	RegisterSignal(imp_in, COMSIG_MOVABLE_MOVED, PROC_REF(update_position))
	update_position()

/obj/item/implant/warp/removed(mob/living/source, silent, special)
	. = ..()

/obj/item/implant/warp/proc/update_position(datum/source = null)
	SIGNAL_HANDLER
	if(!isatom(imp_in.loc))
		return

	inject_position(imp_in.loc)

/obj/item/implant/warp/proc/inject_position(atom/new_loc)
	if(!new_loc)
		return
	if(position_queue.count >= WAPR_MAX_STEPS)
		position_queue.dequeue()

	position_queue.enqueue(list(new_loc, imp_in.dir))

/obj/item/implant/warp/proc/clear_positions()
	position_queue = new()
	update_position()

/obj/item/implant/warp/proc/do_teleport_effects()
	var/delta_alpha = round(225 / position_queue.count)
	var/latest_alpha = 225

	while(position_queue.count)
		var/list/data = position_queue.dequeue()
		if(!data?[WARP_LOC] || !isturf(data?[WARP_LOC]))
			continue

		var/obj/effect/temp_visual/warp/temp = new /obj/effect/temp_visual/warp(data[WARP_LOC])
		temp.alpha = latest_alpha
		temp.appearance = imp_in.appearance
		temp.dir = data?[WARP_DIR] ? data?[WARP_DIR] : imp_in.dir
		latest_alpha -= delta_alpha

		animate(temp, alpha = 0, time = 0.9 SECONDS)

/obj/item/implant/warp/proc/teleport_owner()
	while(position_queue.count)
		var/list/data = position_queue.dequeue()
		if(!data?[WARP_LOC])
			continue
		if(!do_teleport(imp_in, data[WARP_LOC]))
			continue
		imp_in.dir = data?[WARP_DIR] ? data?[WARP_DIR] : imp_in.dir
		return

	imp_in.balloon_alert(imp_in, "ошибка телепортации!")

/obj/item/implant/warp/activate()
	. = ..()
	if(!COOLDOWN_FINISHED(src, cooldown))
		imp_in.balloon_alert(imp_in, "перезарядка!")
		return

	teleport_owner()
	do_teleport_effects()
	clear_positions()
	COOLDOWN_START(src, cooldown, 30 SECONDS)

/obj/item/implanter/warp
	name = "Implanter (warp)"
	imp = /obj/item/implant/warp

#undef WARP_LOC
#undef WARP_DIR
#undef WAPR_MAX_STEPS

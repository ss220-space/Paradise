#define _LOC 1
#define _DIR 2

/obj/item/implant/warp
	name = "Варп имплант"
	desc = "Варп-имплант EX-27 при активации переносит пользователя на 150 метров назад."
	icon_state = "warp"
	implant_data = /datum/implant_fluff/warp

	STATIC_COOLDOWN_DECLARE(cooldown)
	var/queue/position_queue = new()
	var/max_warp_steps = 150

/obj/item/implant/warp/Destroy()
	position_queue = null
	return ..()

/obj/item/implant/warp/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if(!.)
		return
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
	if(position_queue.count >= max_warp_steps)
		position_queue.dequeue()
	position_queue.enqueue(list(new_loc, imp_in.dir))

/obj/item/implant/warp/proc/clear_positions()
	position_queue = null
	position_queue = new()
	update_position()

/obj/item/implant/warp/proc/do_teleport_effects()
	var/delta_alpha = round(225 / position_queue.count)
	var/latest_alpha = 225

	while(!position_queue.is_empty())
		var/list/data = position_queue.dequeue()
		if(!data?[_LOC] || !isturf(data?[_LOC]))
			continue

		var/obj/effect/temp_visual/nothing/warp/temp = new /obj/effect/temp_visual/nothing/warp(data[_LOC])
		temp.alpha = latest_alpha
		temp.overlays = imp_in.overlays
		temp.dir = data?[_DIR] ? data?[_DIR] : imp_in.dir
		latest_alpha -= delta_alpha

		animate(temp, alpha = 0, time = 9)

/obj/item/implant/warp/proc/teleport_owner()
	while(!position_queue.is_empty()) //На случай если головной турф будет удален
		var/list/data = position_queue.dequeue()
		if(!data?[_LOC])
			continue
		if(!do_teleport(imp_in, data[_LOC]))
			continue
		imp_in.dir = data?[_DIR] ? data?[_DIR] : imp_in.dir
		return

	imp_in.balloon_alert(imp_in, "Ошибка телепортации!")

/obj/item/implant/warp/activate()
	. = ..()
	if(!COOLDOWN_FINISHED(src, cooldown))
		to_chat(imp_in, span_warning("Имплант еще не готов!"))
		imp_in.balloon_alert(imp_in, "перезарядка!")
		return

	teleport_owner()
	do_teleport_effects()
	clear_positions()
	COOLDOWN_START(src, cooldown, 30 SECONDS)

/obj/item/implanter/warp
	name = "Implanter (warp)"
	imp = /obj/item/implant/warp

#undef _LOC
#undef _DIR

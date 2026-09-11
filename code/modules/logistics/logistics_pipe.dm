/obj/structure/logistics_pipe
	name = "logistics pipe"
	desc = "Подпольная труба логистической сети."
	icon = 'icons/obj/pipes_and_stuff/not_atmos/logistics.dmi'
	icon_state = "logi-s"
	base_icon_state = "logi-s"
	anchored = TRUE
	dir = NONE
	max_integrity = 200
	on_blueprints = TRUE
	layer = LOGISTICS_PIPE_LAYER
	level = 1
	damage_deflection = 10
	set_dir_on_move = FALSE
	armor = list(MELEE = 25, BULLET = 10, LASER = 10, ENERGY = 100, BOMB = 0, BIO = 100, FIRE = 90, ACID = 30)
	var/initialize_dirs = NONE
	var/dpdir = NONE
	var/flip_type
	var/datum/logistics_net/logistics_net
	var/datum/component/logistics_interface/linked_interface
	COOLDOWN_DECLARE(eject_effects_cd)

/obj/structure/logistics_pipe/get_ru_names()
	return alist(
		NOMINATIVE = "логистическая труба",
		GENITIVE = "логистической трубы",
		DATIVE = "логистической трубе",
		ACCUSATIVE = "логистическую трубу",
		INSTRUMENTAL = "логистической трубой",
		PREPOSITIONAL = "логистической трубе",
	)

/obj/structure/logistics_pipe/Initialize(mapload, obj/structure/logistics_construct/made_from)
	. = ..()
	if(made_from)
		setDir(made_from.dir)
	if(ISDIAGONALDIR(dir))
		initialize_dirs = NONE
	if(initialize_dirs != DISP_DIR_NONE)
		dpdir = dir
		if(initialize_dirs & DISP_DIR_LEFT)
			dpdir |= turn(dir, 90)
		if(initialize_dirs & DISP_DIR_RIGHT)
			dpdir |= turn(dir, -90)
		if(initialize_dirs & DISP_DIR_FLIP)
			dpdir |= REVERSE_DIR(dir)
	else if(ISDIAGONALDIR(dir))
		dpdir = dir
	update_appearance(UPDATE_ICON_STATE)
	AddElement(/datum/element/undertile)
	connect_to_network()
	try_link_interface()

/obj/structure/logistics_pipe/Destroy()
	spew_forth()
	if(linked_interface?.linked_pipe == src)
		linked_interface.disconnect_pipe()
	linked_interface = null
	logistics_net?.remove_pipe(src)
	logistics_net = null
	return ..()

/obj/structure/logistics_pipe/proc/get_neighbors()
	. = list()
	for(var/dir_iter in GLOB.cardinal)
		if(!(dpdir & dir_iter))
			continue
		var/turf/next_turf = get_step(src, dir_iter)
		if(!next_turf)
			continue
		for(var/obj/structure/logistics_pipe/pipe in next_turf)
			if(pipe == src)
				continue
			if(pipe.dpdir & REVERSE_DIR(dir_iter))
				. += pipe

/obj/structure/logistics_pipe/proc/connect_to_network()
	var/datum/logistics_net/chosen
	for(var/obj/structure/logistics_pipe/neighbor as anything in get_neighbors())
		if(!neighbor.logistics_net)
			continue
		if(!chosen)
			chosen = neighbor.logistics_net
		else if(chosen != neighbor.logistics_net)
			chosen.merge(neighbor.logistics_net)
	if(!chosen)
		chosen = new
	chosen.add_pipe(src)

/obj/structure/logistics_pipe/proc/spew_forth()
	var/turf/our_turf = get_turf(src)
	for(var/obj/structure/logistics_holder/holder in contents)
		holder.active = FALSE
		expel(holder, our_turf)

/obj/structure/logistics_pipe/proc/nextdir(obj/structure/logistics_holder/holder)
	if(length(holder.path_dirs))
		var/next = holder.path_dirs[1]
		holder.path_dirs.Cut(1, 2)
		return next
	return dpdir & (~REVERSE_DIR(holder.dir))

/obj/structure/logistics_pipe/proc/try_link_interface()
	if(linked_interface)
		return
	for(var/obj/machinery/machine in loc)
		var/datum/component/logistics_interface/interface = machine.GetComponent(/datum/component/logistics_interface)
		if(!interface)
			continue
		interface.connect_pipe(src)
		return

/obj/structure/logistics_pipe/proc/transfer(obj/structure/logistics_holder/holder)
	if(should_deliver(holder))
		holder.deliver(holder.dest_interface)
		return
	return transfer_to_dir(holder, nextdir(holder))

/obj/structure/logistics_pipe/proc/should_deliver(obj/structure/logistics_holder/holder)
	if(!holder.dest_interface || holder.dest_interface.linked_pipe != src)
		return FALSE
	if(holder.dir == DOWN || holder.dir == NONE)
		return FALSE
	return TRUE

/obj/structure/logistics_pipe/proc/transfer_to_dir(obj/structure/logistics_holder/holder, next_dir)
	if(!next_dir)
		return
	holder.setDir(next_dir)
	var/turf/next_loc = holder.nextloc()
	var/obj/structure/logistics_pipe/pipe = holder.findpipe(next_loc)
	if(!pipe)
		return
	holder.forceMove(pipe)
	return pipe

/obj/structure/logistics_pipe/proc/expel(obj/structure/logistics_holder/holder, turf/expel_to, direction)
	if(!expel_to)
		expel_to = get_turf(src)
	var/turf/target = expel_to
	if(direction)
		target = get_ranged_target_turf(expel_to, direction, 5)
	if(COOLDOWN_FINISHED(src, eject_effects_cd))
		COOLDOWN_START(src, eject_effects_cd, 1 SECONDS)
		playsound(src, 'sound/machines/hiss.ogg', 50, FALSE)
	if(isfloorturf(expel_to))
		var/turf/simulated/floor/floor_turf = expel_to
		if(floor_turf.underfloor_accessibility != UNDERFLOOR_INTERACTABLE)
			floor_turf.remove_tile(null, TRUE, TRUE)
	holder.expel_contents(target)
	qdel(holder)

/obj/structure/logistics_pipe/attackby(obj/item/I, mob/user, params)
	var/turf/our_turf = loc
	if(isturf(our_turf) && HAS_TRAIT(src, TRAIT_UNDERFLOOR))
		to_chat(user, span_warning("You cannot interact with something that's under the floor!"))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/structure/logistics_pipe/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	var/turf/our_turf = loc
	if(isturf(our_turf) && HAS_TRAIT(src, TRAIT_UNDERFLOOR))
		to_chat(user, span_warning("You can't interact with something that's under the floor!"))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
		return
	WELDER_SLICING_SUCCESS_MESSAGE
	deconstruct()

/obj/structure/logistics_pipe/deconstruct(disassembled = TRUE)
	if(disassembled)
		var/obj/structure/logistics_construct/construct = new(loc, null, null, src)
		construct.set_anchored(TRUE)
		transfer_fingerprints_to(construct)
	spew_forth()
	return ..()

/obj/structure/logistics_pipe/rpd_act(mob/user, obj/item/rpd/our_rpd, mode)
	if(mode == RPD_DELETE_MODE)
		return FALSE
	return ..()

/obj/structure/logistics_pipe/segment
	initialize_dirs = DISP_DIR_FLIP

/obj/structure/logistics_pipe/segment/update_icon_state()
	icon_state = "logi-s"
	base_icon_state = icon_state
	return ..()

/obj/structure/logistics_pipe/junction
	name = "logistics junction"
	icon_state = "logi-j1"
	base_icon_state = "logi-j1"
	initialize_dirs = DISP_DIR_RIGHT | DISP_DIR_FLIP
	flip_type = /obj/structure/logistics_pipe/junction/reversed

/obj/structure/logistics_pipe/junction/reversed
	icon_state = "logi-j2"
	base_icon_state = "logi-j2"
	initialize_dirs = DISP_DIR_LEFT | DISP_DIR_FLIP
	flip_type = /obj/structure/logistics_pipe/junction

/obj/structure/logistics_pipe/junction/yjunction
	name = "logistics y-junction"
	icon_state = "logi-y"
	base_icon_state = "logi-y"
	initialize_dirs = DISP_DIR_LEFT | DISP_DIR_RIGHT
	flip_type = null

/obj/structure/logistics_pipe/trunk
	name = "logistics trunk"
	icon_state = "logi-t"
	base_icon_state = "logi-t"
	initialize_dirs = DISP_DIR_FLIP

/obj/structure/logistics_pipe/trunk/nextdir(obj/structure/logistics_holder/holder)
	if(holder.dir == DOWN)
		if(length(holder.path_dirs))
			var/next = holder.path_dirs[1]
			holder.path_dirs.Cut(1, 2)
			return next
		return dir
	return NONE

/obj/structure/logistics_pipe/trunk/transfer(obj/structure/logistics_holder/holder)
	if(holder.dir == DOWN)
		return transfer_to_dir(holder, nextdir(holder))
	if(linked_interface && holder.dest_interface == linked_interface)
		holder.deliver(linked_interface)
		return
	expel(holder, get_turf(src), dir)

/obj/structure/logistics_holder
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	dir = NONE
	var/obj/structure/logistics_pipe/current_pipe
	var/obj/structure/logistics_pipe/last_pipe
	var/active = FALSE
	var/count = LOGISTICS_MAX_STEPS
	var/list/path_dirs = list()
	var/datum/component/logistics_interface/dest_interface
	var/datum/logistics_net/origin_net
	var/request_num = 0
	var/datum/weakref/request_ref
	var/list/shipment_manifest = list()

/obj/structure/logistics_holder/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_WEATHER_IMMUNE, INNATE_TRAIT)
	shipment_manifest = list()

/obj/structure/logistics_holder/Destroy()
	active = FALSE
	origin_net?.in_flight -= src
	origin_net = null
	dest_interface = null
	request_ref = null
	current_pipe = null
	last_pipe = null
	shipment_manifest = null
	return ..()

/obj/structure/logistics_holder/proc/start_moving()
	if(!istype(loc, /obj/structure/logistics_pipe))
		expel_contents(get_turf(src))
		qdel(src)
		return
	active = TRUE
	if(istype(loc, /obj/structure/logistics_pipe/trunk))
		setDir(DOWN)
	else
		setDir(NONE)
	current_pipe = loc
	var/delay = LOGISTICS_HOLDER_MOVE_DELAY
	var/datum/move_loop/our_loop = GLOB.move_manager.move_logistics(src, delay = delay, timeout = delay * count)
	if(our_loop)
		RegisterSignal(our_loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
		RegisterSignal(our_loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(try_expel))
		RegisterSignal(our_loop, COMSIG_QDELETING, PROC_REF(movement_stop))

/obj/structure/logistics_holder/proc/pre_move(datum/move_loop/source)
	SIGNAL_HANDLER
	last_pipe = loc

/obj/structure/logistics_holder/proc/try_expel(datum/move_loop/source, result, visual_delay)
	SIGNAL_HANDLER
	if(QDELETED(src) || current_pipe || !active)
		return
	if(last_pipe)
		last_pipe.expel(src, get_turf(src), dir)
	else
		expel_contents(get_turf(src))
		qdel(src)

/obj/structure/logistics_holder/proc/movement_stop(datum/source)
	SIGNAL_HANDLER
	current_pipe = null
	last_pipe = null
	active = FALSE

/obj/structure/logistics_holder/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!loc || istype(loc, /obj/structure/logistics_pipe))
		return
	expel_contents(get_turf(loc) || old_loc)
	qdel(src)

/obj/structure/logistics_holder/proc/nextloc()
	return get_step(src, dir)

/obj/structure/logistics_holder/proc/findpipe(turf/check_turf)
	if(!check_turf)
		return null
	var/fdir = REVERSE_DIR(dir)
	for(var/obj/structure/logistics_pipe/pipe in check_turf)
		if(fdir & pipe.dpdir)
			return pipe
	return null

/obj/structure/logistics_holder/proc/expel_contents(atom/target)
	release_remaining_reservations()
	if(!target)
		target = get_turf(src)
	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(target)

/obj/structure/logistics_holder/proc/abort_shipment()
	active = FALSE
	expel_contents(get_turf(src))
	qdel(src)

/obj/structure/logistics_holder/proc/release_remaining_reservations()
	var/datum/logistics_request/request = request_ref?.resolve()
	if(!request || !length(shipment_manifest))
		shipment_manifest?.Cut()
		return
	for(var/stock_name in shipment_manifest)
		request.release_reservation(stock_name, shipment_manifest[stock_name])
	shipment_manifest.Cut()

/obj/structure/logistics_holder/proc/deliver(datum/component/logistics_interface/interface)
	active = FALSE
	var/datum/logistics_request/request = request_ref?.resolve()
	var/list/manifest = shipment_manifest?.Copy() || list()
	if(QDELETED(interface))
		expel_contents(get_turf(src))
		qdel(src)
		return

	var/list/undelivered = list()
	var/turf/drop_turf = get_turf(interface.parent)
	for(var/stock_name in manifest)
		var/need = manifest[stock_name]
		var/delivered_now = 0
		for(var/obj/item/item in contents)
			if(delivered_now >= need)
				break
			if(!interface.adapter?.item_matches_stock(item, stock_name))
				continue
			var/units = logistics_item_units(item)
			var/take = min(units, need - delivered_now)
			if(take <= 0)
				continue
			if(isstack(item) && take < units)
				var/obj/item/stack/stack = item
				if(!stack.logistics_count_amount)
					continue
				var/obj/item/stack/piece = stack.split(null, take)
				if(!interface.try_insert_item(piece))
					if(!QDELETED(piece))
						piece.forceMove(src)
						if(!QDELETED(stack))
							piece.merge(stack)
					continue
				delivered_now += take
				continue
			if(!interface.try_insert_item(item))
				continue
			delivered_now += take
		var/failed = max(need - delivered_now, 0)
		if(failed > 0)
			undelivered[stock_name] = failed

	for(var/obj/item/leftover in contents)
		leftover.forceMove(drop_turf)

	if(request)
		request.finalize_shipment(manifest, undelivered)
		shipment_manifest.Cut()
		request.net?.try_complete_request(request)

	interface.play_receive_sound()
	qdel(src)

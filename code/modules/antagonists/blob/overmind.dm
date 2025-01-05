GLOBAL_LIST_EMPTY(overminds)


/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	desc = "The overmind. It controls the blob."
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"
	nightvision = 8
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS
	invisibility = INVISIBILITY_OBSERVER
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	see_invisible = SEE_INVISIBLE_LIVING
	pass_flags = PASSBLOB
	faction = list(ROLE_BLOB)
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = TRUE
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	pass_flags = PASSBLOB
	verb_say = "states"

	hud_type = /datum/hud/blob_overmind
	var/obj/structure/blob/special/core/blob_core = null // The blob overmind's core
	var/blob_points = 0
	var/max_blob_points = OVERMIND_MAX_POINTS_DEFAULT
	var/last_attack = 0
	var/datum/blobstrain/reagent/blobstrain
	var/list/blob_mobs = list()
	/// A list of all blob structures
	var/list/all_blobs = list()
	var/list/resource_blobs = list()
	var/list/factory_blobs = list()
	var/list/node_blobs = list()
	var/free_strain_rerolls = OVERMIND_STARTING_REROLLS
	var/last_reroll_time = 0 //time since we last rerolled, used to give free rerolls
	var/nodes_required = TRUE //if the blob needs nodes to place resource and factory blobs
	var/list/blobs_legit = list()
	var/max_count = 0 //The biggest it got before death
	var/rerolling = FALSE
	/// The list of strains the blob can reroll for.
	var/list/strain_choices
	/// Whether the blob split
	var/split_used = FALSE
	/// Is blob offspring of another blob
	var/is_offspring = FALSE
	/// Does the blob have an infinite resource?
	var/is_infinity = FALSE


/mob/camera/blob/Initialize(mapload, core = null, starting_points = OVERMIND_STARTING_POINTS)
	ADD_TRAIT(src, TRAIT_BLOB_ALLY, INNATE_TRAIT)
	blob_points = starting_points
	blob_core = core
	GLOB.overminds += src
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	last_attack = world.time
	select_strain(TRUE)
	color = blobstrain.complementary_color
	if(blob_core)
		blob_core.update_blob()
	. = ..()
	START_PROCESSING(SSobj, src)
	GLOB.blob_telepathy_mobs |= src


/mob/camera/blob/Destroy()
	QDEL_NULL(blobstrain)
	for(var/obj/structure/blob/blob_structure as anything in all_blobs)
		blob_structure.overmind = null
		blob_structure.update_blob()
	all_blobs = null
	resource_blobs = null
	factory_blobs = null
	node_blobs = null
	for(var/mob/living/simple_animal/hostile/blob_minion/mob as anything in blob_mobs)
		if(istype(mob) && !mob.factory_linked)
			mob.death()
	blob_mobs = null
	GLOB.overminds -= src
	QDEL_LIST_ASSOC_VAL(strain_choices)

	STOP_PROCESSING(SSobj, src)
	GLOB.blob_telepathy_mobs -= src

	return ..()


/mob/camera/blob/process()
	if(!blob_core)
		qdel(src)
		return
	if(!free_strain_rerolls && (last_reroll_time + BLOB_POWER_REROLL_FREE_TIME < world.time))
		to_chat(src, span_boldnotice("Вы получили еще одну бесплатную смену штамма."))
		free_strain_rerolls = TRUE
	track_z()


/mob/camera/blob/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	sync_mind()
	update_health_hud()
	sync_lighting_plane_alpha()
	add_points(0)
	var/turf/T = get_turf(src)
	if(isturf(T))
		update_z(T.z)


/mob/camera/blob/Logout()
	update_z(null)
	. = ..()


/mob/camera/blob/proc/can_attack()
	return (world.time > (last_attack + CLICK_CD_RANGE))

/mob/camera/blob/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(world.time < last_movement)
		return
	last_movement = world.time + 0.5 // cap to 20fps

	var/obj/structure/blob/B = locate() in range(OVERMIND_MAX_CAMERA_STRAY, newloc)
	if(B)
		loc = newloc
	else
		return FALSE


/mob/camera/blob/can_z_move(direction, turf/start, turf/destination, z_move_flags = NONE, mob/living/rider)
	. = ..()
	if(!.)
		return
	var/turf/target_turf = .
	if(!is_valid_turf(target_turf)) // Allows unplaced blobs to travel through station z-levels
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(src, span_warning("Ваш пункт назначения недействителен. Перейдите в другое место и попробуйте еще раз."))
		return null

/mob/camera/blob/proc/is_valid_turf(turf/tile)
	var/area/area = get_area(tile)
	if((area && !(area.area_flags & BLOBS_ALLOWED)) || !tile || !is_station_level(tile.z))
		return FALSE
	return TRUE


/mob/camera/blob/get_status_tab_items()
	. = ..()
	if(blob_core)
		. += list(list("Здоровье ядра:", "[blob_core.obj_integrity]"))
		. += list(list("Ресурсы:", "[(is_infinity || SSticker?.mode?.is_blob_infinity_points)? "INF" : "[blob_points]/[max_blob_points]"]"))
		. += list(list("Критическая Масса:", "[TOTAL_BLOB_MASS]/[NEEDED_BLOB_MASS]"))
	if(free_strain_rerolls)
		. += list(list("Осталось бесплатных смен штамма:", "[free_strain_rerolls]"))

/mob/camera/blob/update_health_hud()
	if(!blob_core)
		return FALSE
	var/current_health = round((blob_core.obj_integrity / blob_core.max_integrity) * 100)
	hud_used.blobhealthdisplay.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[current_health]%</font></div>")
	for(var/mob/living/simple_animal/hostile/blob_minion/blobbernaut/blobbernaut in blob_mobs)
		var/datum/hud/using_hud = blobbernaut.hud_used
		if(!using_hud?.blobpwrdisplay)
			continue
		using_hud.blobpwrdisplay.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[current_health]%</font></div>")


/mob/camera/blob/say(
	message,
	bubble_type,
	sanitize = TRUE,
)
	if(!message)
		return

	if(client)
		if(GLOB.admin_mutes_assoc[ckey] & MUTE_IC)
			to_chat(src, span_boldwarning("Вы не можете писать IC сообщения (мут)."))
			return
		if(client.handle_spam_prevention(message, MUTE_IC))
			return

	if(stat)
		return

	blob_talk(message)

/mob/camera/blob/proc/blob_talk(message)

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	add_say_logs(src, message, language = "BLOB")

	var/message_a = say_quote(message)
	var/rendered = span_big(span_blob("<b>\[Blob Telepathy\] <span class='name'>[name]</span>(<font color=\"[blobstrain.color]\">[blobstrain.name]</font>)</b> [message_a], [message]"))
	relay_to_list_and_observers(rendered, GLOB.blob_telepathy_mobs, src)

/mob/camera/blob/proc/add_points(points)
	blob_points = clamp(blob_points + points, 0, max_blob_points)
	hud_used.blobpwrdisplay.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[(is_infinity || SSticker?.mode?.is_blob_infinity_points)? "INF" : round(blob_points)]</font></div>")


/mob/camera/blob/proc/select_strain(first_select = FALSE)
	var/reagent_type = pick(GLOB.valid_blobstrains)
	set_strain(reagent_type, first_select)



/mob/camera/blob/proc/set_strain(datum/blobstrain/new_strain, first_select = FALSE)
	if(!ispath(new_strain))
		return FALSE

	var/had_strain = FALSE
	if(istype(blobstrain))
		blobstrain.on_lose()
		qdel(blobstrain)
		had_strain = TRUE

	blobstrain = new new_strain(src)
	var/datum/antagonist/blob_overmind/overmind_datum = mind?.has_antag_datum(/datum/antagonist/blob_overmind)
	if(overmind_datum)
		overmind_datum.strain = blobstrain
	blobstrain.on_gain()

	if(had_strain && !first_select)
		var/list/messages = get_strain_info()
		to_chat(src, chat_box_red(messages.Join("<br>")))
	SEND_SIGNAL(src, COMSIG_BLOB_SELECTED_STRAIN, blobstrain)


/mob/camera/blob/proc/get_strain_info()
	. = list()
	. += span_notice("Ваш штамм: <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font>!")
	. += span_notice("Штамм <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font> [blobstrain.description]")
	if(blobstrain.effectdesc)
		. += span_notice("Штамм <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font> [blobstrain.effectdesc]")
	return .

/mob/camera/blob/examine(mob/user)
	. = ..()
	if(blobstrain)
		. += "Штамм блоба — <font color=\"[blobstrain.color]\">[blobstrain.name]</font>."

/mob/camera/blob/blob_act(obj/structure/blob/B)
	return

/// Create a blob spore and link it to us
/mob/camera/blob/proc/create_spore(turf/spore_turf, spore_type = /mob/living/simple_animal/hostile/blob_minion/spore/minion)
	var/mob/living/simple_animal/hostile/blob_minion/spore/spore = new spore_type(spore_turf)
	assume_direct_control(spore)
	return spore

/// Give our new minion the properties of a minion
/mob/camera/blob/proc/assume_direct_control(mob/living/minion)
	minion.AddComponent(/datum/component/blob_minion, src)

/// Add something to our list of mobs and wait for it to die
/mob/camera/blob/proc/register_new_minion(mob/living/minion)
	blob_mobs |= minion
	if(!istype(minion, /mob/living/simple_animal/hostile/blob_minion/blobbernaut))
		RegisterSignal(minion, COMSIG_LIVING_DEATH, PROC_REF(on_minion_death))

/// When a spore (or zombie) dies then we do this
/mob/camera/blob/proc/on_minion_death(mob/living/spore)
	SIGNAL_HANDLER
	blobstrain.on_sporedeath(spore)

/mob/camera/blob/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents = TRUE)
	..()
	update_z(new_turf?.z)

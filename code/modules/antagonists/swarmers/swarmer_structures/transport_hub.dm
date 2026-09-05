/**
 * Swarmer transport hub
 *
 * Allows swarmers to teleport between them.
 * Works the same way cult teleport runes work.
 */
/obj/structure/swarmer/transport_hub
	name = "swarmer hub"
	desc = "Телепортер \"Свармеров\", позволяющий им телепортироваться к другим телепортерам."
	swarmer_examine = "Можно использовать, нажав на телепортер в интенте \"Помощь\""
	icon_state = "hub_enabled"
	max_integrity = 100
	/// Key name of our hub, created on init and changed after on spell cast
	var/listkey
	/// Spark system (since we use them a lot)
	var/datum/effect_system/spark_spread/spark_system
	/// Current state (for emp act)
	var/enabled = TRUE

/obj/structure/swarmer/transport_hub/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	var/locname = initial(A.name)
	listkey = "[locname]" // Can be changed on conjure by a swarmer
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/structure/swarmer/transport_hub/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/// Switches enabled var value
/obj/structure/swarmer/transport_hub/proc/toggle_enabled()
	enabled = !enabled
	update_icon(UPDATE_ICON_STATE)

// Turns off the hub for 10 * severity seconds
/obj/structure/swarmer/transport_hub/emp_act(severity)
	..()
	if(!enabled)
		return
	toggle_enabled()
	addtimer(CALLBACK(src, PROC_REF(toggle_enabled)), SWARMER_STRUCTURE_EMP_DURATION * severity, TIMER_DELETE_ME)

// Changes sprite based on if we are emped or unanchored
/obj/structure/swarmer/transport_hub/update_icon_state()
	icon_state = (enabled && anchored) ? initial(icon_state) : "hub_disabled"

/**
 * Main teleport proc
 *
 * Works the same way blood cult runes work.
 */
/obj/structure/swarmer/transport_hub/swarmer_help_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	. = ..()
	if(!.)
		return
	if(!enabled) // Emped
		swarmer.balloon_alert(swarmer, "калибруется!")
		return

	var/list/potential_hubs = get_hub_list()
	if(!length(potential_hubs))
		swarmer.balloon_alert(swarmer, "отсутствуют другие хабы!")
		return

	var/input_hub_key = tgui_input_list(swarmer, "Выберите хаб для телепорта.", "Выбор хаба", potential_hubs) //we know what key they picked
	var/obj/structure/swarmer/transport_hub/actual_selected_hub = potential_hubs[input_hub_key] //what hub does that key correspond to?
	if(!Adjacent(swarmer) || QDELETED(src) || !actual_selected_hub)
		return

	playsound(swarmer, 'sound/swarmer/swarmer_teleport.ogg', 100, TRUE)
	if(!do_after(swarmer, SWARMER_TELEPORT_DELAY(swarmer), src, max_interact_count = 1))
		swarmer.balloon_alert(swarmer, "нельзя двигаться!")
		return
	var/turf/target_turf = get_turf(actual_selected_hub)
	swarmer.forceMove(target_turf)
	spark_system.start()
	actual_selected_hub.spark_system.start()

/// Proc used to get a list of all active hubs
/obj/structure/swarmer/transport_hub/proc/get_hub_list()
	var/list/potential_hubs = list()
	var/list/hub_names = list()
	var/list/duplicate_hub_count = list()
	for(var/obj/structure/swarmer/transport_hub/hub in GLOB.swarmer_objects)
		if(!hub.enabled)
			continue
		var/resultkey = hub.listkey
		if(resultkey in hub_names)
			duplicate_hub_count[resultkey]++
			resultkey = "[resultkey] ([duplicate_hub_count[resultkey]])"
		else
			hub_names += resultkey
			duplicate_hub_count[resultkey] = 1
		if(hub != src)
			potential_hubs[resultkey] = hub
	return potential_hubs

/obj/structure/swarmer/transport_hub/get_ru_names()
	return alist(
		NOMINATIVE = "телепортатор \"Свармеров\"",
		GENITIVE = "телепортатора \"Свармеров\"",
		DATIVE = "телепортатору \"Свармеров\"",
		ACCUSATIVE = "телепортатор \"Свармеров\"",
		INSTRUMENTAL = "телепортатором \"Свармеров\"",
		PREPOSITIONAL = "телепортаторе \"Свармеров\""
	)

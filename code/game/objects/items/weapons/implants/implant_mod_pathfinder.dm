/obj/item/implant/mod
	name = "MOD pathfinder bio-chip"
	desc = "Данный био-чип позволяет пользователю вызвать к себе модульный костюм в любое время."
	implant_data = /datum/implant_fluff/pathfinder
	actions_types = list(/datum/action/item_action/mod_recall)
	/// The pathfinder module we are linked to
	var/obj/item/mod/module/pathfinder/module
	/// The jet icon we apply to the MOD.
	var/image/jet_icon
	/// List of turfs through which a mod 'steps' to reach the waypoint
	var/list/path = list()
	/// The target turf we are after
	var/turf/target
	/// How many times have we tried to move?
	var/tries = 0

/obj/item/implant/mod/get_ru_names()
	return list(
		NOMINATIVE = "био-чип для модуля \"Первопроходец\"",
		GENITIVE = "био-чипа для модуля \"Первопроходец\"",
		DATIVE = "био-чипу для модуля \"Первопроходец\"",
		ACCUSATIVE = "био-чип для модуля \"Первопроходец\"",
		INSTRUMENTAL = "био-чипом для модуля \"Первопроходец\"",
		PREPOSITIONAL = "био-чипе для модуля \"Первопроходец\"",
	)

/obj/item/implant/mod/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/item/mod/module/pathfinder))
		return INITIALIZE_HINT_QDEL
	module = loc
	jet_icon = image(icon = 'icons/obj/clothing/modsuit/mod_modules.dmi', icon_state = "mod_jet", layer = LOW_ITEM_LAYER)

/obj/item/implant/mod/Destroy()
	if(path)
		end_recall(successful = FALSE)
	module = null
	jet_icon = null
	return ..()

/obj/item/implant/mod/proc/recall()
	target = get_turf(imp_in)
	if(!module?.mod)
		imp_in.balloon_alert(imp_in, "модуль не подсоединён!")
		return FALSE
	if(module.mod.open)
		imp_in.balloon_alert(imp_in, "костюм раскрыт!")
		return FALSE
	if(length(path))
		imp_in.balloon_alert(imp_in, "костюм уже в пути!")
		return FALSE
	if(ismob(get_atom_on_turf(module.mod)))
		imp_in.balloon_alert(imp_in, "костюм на ком-то надет!")
		return FALSE
	if(module.mod.loc != get_turf(module.mod))
		imp_in.balloon_alert(imp_in, "костюм внутри хранилища!")
		return FALSE
	if(module.z != z || get_dist(imp_in, module.mod) > 150)
		imp_in.balloon_alert(imp_in, "костюм слишком далеко!")
		return FALSE
	if(!ishuman(imp_in)) //Need to be specific
		imp_in.balloon_alert(imp_in, "неизвестное существо!")
		return FALSE
	var/mob/living/carbon/human/human = imp_in
	set_path(get_path_to(module.mod, target, 150, access = human.get_access(), simulated_only = FALSE)) //Yes, science proves jetpacks work in space. More at 11.
	if(!length(path)) //Cannot reach target. Give up and announce the issue.
		human.balloon_alert(human, "невозможно рассчитать путь!")
		return FALSE
	human.balloon_alert(human, "костюм в пути...")
	animate(module.mod, 0.2 SECONDS, pixel_x = 0, pixel_y = 0)
	module.mod.add_overlay(jet_icon)
	RegisterSignal(module.mod, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	mod_move(target)
	return TRUE

/obj/item/implant/mod/proc/set_path(list/newpath)
	if(newpath == null)
		end_recall(FALSE)
	path = newpath ? newpath : list()

/obj/item/implant/mod/proc/end_recall(successful = TRUE)
	if(!module?.mod)
		return
	module.mod.cut_overlay(jet_icon)
	module.mod.transform = matrix()
	UnregisterSignal(module.mod, COMSIG_MOVABLE_MOVED)
	if(successful)
		return
	imp_in.balloon_alert(imp_in, "связь с костюмом потеряна!")
	path = list() //Stopping endless end_recall with luck.

/obj/item/implant/mod/proc/on_move(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	var/matrix/mod_matrix = matrix()
	mod_matrix.Turn(get_angle(source, imp_in))
	source.transform = mod_matrix

/obj/item/implant/mod/proc/mod_move(dest)
	dest = get_turf(dest) //We must always compare turfs, so get the turf of the dest var if dest was originally something else.
	if(get_turf(module.mod) == dest) //We have arrived, no need to move again.
		for(var/mob/living/carbon/human/human in range(1, module.mod))
			if(human == imp_in)
				module.attach(imp_in)
				end_recall()
				return TRUE
		end_recall(FALSE)
		return FALSE

	if(!dest || !path || !length(path)) //A-star failed or a path/destination was not set.
		set_path(null)
		return FALSE

	var/turf/last_node = get_turf(path[length(path)]) //This is the turf at the end of the path, it should be equal to dest.
	if(dest != last_node) //The path should lead us to our given destination. If this is not true, we must stop.
		set_path(null)
		return FALSE

	var/step_count = 3 //Temp speed for now

	if(step_count >= 1 && tries < 5)
		for(var/step_number in 1 to step_count)
			// Hopefully this wont fill the buckets too much
			addtimer(CALLBACK(src, PROC_REF(mod_step)), 2 * (step_number - 1))
	if(tries >= 5)
		set_path(null)
	var/target = get_turf(imp_in)
	var/mob/living/carbon/human/our_human = imp_in
	set_path(get_path_to(module.mod, target, 150, access = our_human.get_access(), simulated_only = FALSE)) //Yes, science proves jetpacks work in space. More at 11.
	addtimer(CALLBACK(src, PROC_REF(mod_move), target), 6) //I'll value this properly soon

	return TRUE

/obj/item/implant/mod/proc/mod_step() //Step,increase tries if failed
	if(!path || !length(path))
		return FALSE
	for(var/obj/machinery/door/our_door in range(2, module.mod))
		if(our_door.operating || our_door.emagged)
			continue
		if(our_door.requiresID() && our_door.allowed(imp_in))
			if(our_door.density)
				our_door.open()

	if(!step_towards(module.mod, path[1]))
		tries++
		return FALSE

	increment_path()
	tries = 0
	return TRUE

/obj/item/implant/mod/proc/increment_path()
	if(!path || !length(path))
		return
	path.Cut(1, 2)

/datum/action/item_action/mod_recall
	name = "Вызов МЭК"
	desc = "Призовите привязанный модульный экзокостюм к себе из любого места на станции."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "recall"
	background_icon_state = "bg_mod"
	button_icon = 'icons/mob/actions/actions_mod.dmi'
	/// The cooldown for the recall.
	COOLDOWN_DECLARE(recall_cooldown)

/datum/action/item_action/mod_recall/New(Target)
	..()
	if(!istype(Target, /obj/item/implant/mod))
		qdel(src)
		return

/datum/action/item_action/mod_recall/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/item/implant/mod/implant = target
	if(!COOLDOWN_FINISHED(src, recall_cooldown))
		clicker.balloon_alert(clicker, "на перезарядке!")
		return
	if(implant.recall())
		COOLDOWN_START(src, recall_cooldown, 15 SECONDS)

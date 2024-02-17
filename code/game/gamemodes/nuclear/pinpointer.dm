#define MODE_OFF 	0
#define MODE_DISK 	1
#define MODE_NUKE 	2
#define MODE_ADV 	3
#define MODE_SHIP 	4
#define MODE_OPERATIVE 5
#define MODE_CREW 	6
#define MODE_NINJA 	7
#define MODE_THIEF 	8
#define MODE_TENDRIL 9
#define SETTING_DISK 		0
#define SETTING_LOCATION 	1
#define SETTING_OBJECT 		2

/obj/item/pinpointer
	name = "pinpointer"
	icon = 'icons/obj/device.dmi'
	icon_state = "pinoff"
	flags = CONDUCT
	slot_flags = SLOT_PDA | SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	materials = list(MAT_METAL=500)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/obj/item/disk/nuclear/the_disk = null
	var/obj/machinery/nuclearbomb/the_bomb = null
	var/obj/machinery/nuclearbomb/syndicate/the_s_bomb = null // used by syndicate pinpointers.
	var/atom/target = null
	var/turf/target_turf = null
	var/turf/source_turf = null
	var/prev_dist
	var/cur_index = 1 // Which index the current mode is
	var/mode = MODE_OFF // On which mode the pointer is at
	var/modes = list(MODE_DISK, MODE_NUKE) // Which modes are there
	var/shows_nuke_timer = TRUE
	var/syndicate = FALSE // Indicates pointer is syndicate, and points to the syndicate nuke.
	var/icon_off = "pinoff"
	var/icon_null = "pinonnull"
	var/icon_direct = "pinondirect"
	var/icon_close = "pinonclose"
	var/icon_medium = "pinonmedium"
	var/icon_far = "pinonfar"


/obj/item/pinpointer/Initialize(mapload)
	. = ..()
	GLOB.pinpointer_list += src


/obj/item/pinpointer/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	GLOB.pinpointer_list -= src
	mode = MODE_OFF
	the_disk = null
	the_bomb = null
	the_s_bomb = null
	target = null
	target_turf = null
	source_turf = null
	return ..()


/obj/item/pinpointer/process()
	switch(mode)
		if(MODE_DISK)
			workdisk()
		if(MODE_NUKE)
			workbomb()


/obj/item/pinpointer/attack_self(mob/user)
	cycle(user)


/obj/item/pinpointer/proc/cycle(mob/user, silent = FALSE)
	if(cur_index > length(modes))
		mode = MODE_OFF
		prev_dist = null
		update_icon(UPDATE_ICON_STATE)
		STOP_PROCESSING(SSfastprocess, src)
		cur_index = 1
		if(!silent)
			to_chat(user, span_notice("You turn off [name]."))
		return
	if(cur_index == 1)
		START_PROCESSING(SSfastprocess, src)
	mode = modes[cur_index++]
	if(!target)
		update_icon(UPDATE_ICON_STATE)	// we need to update icon only without target, since processing will do it for us
	if(!silent)
		to_chat(user, span_notice("[get_mode_text(mode)]"))


/obj/item/pinpointer/proc/get_mode_text(mode)
	switch(mode)
		if(MODE_DISK)
			return "Authentication Disk Locator active."
		if(MODE_NUKE)
			return "Nuclear Device Locator active."
		if(MODE_ADV)
			return "Advanced Pinpointer Online."
		if(MODE_SHIP)
			return "Shuttle Locator active."
		if(MODE_OPERATIVE)
			return "You point the pinpointer to the nearest operative."
		if(MODE_CREW)
			return "You turn on the pinpointer."
		if(MODE_THIEF)
			return "Вы включили спец-пинпоинтер."
		if(MODE_TENDRIL)
			return "High energy scanner active."


/obj/item/pinpointer/proc/scandisk()
	if(!the_disk)
		the_disk = locate() in GLOB.poi_list


/obj/item/pinpointer/proc/scanbomb()
	if(syndicate && !the_s_bomb)
		the_s_bomb = locate() in GLOB.poi_list
		return
	if(!syndicate && !the_bomb)
		the_bomb = locate() in GLOB.poi_list


/obj/item/pinpointer/update_icon_state()
	if(mode == MODE_OFF)
		icon_state = icon_off
		return

	if(!target)
		icon_state = icon_null
		return

	switch(prev_dist)
		if(-1)
			icon_state = icon_direct
		if(1 to 8)
			icon_state = icon_close
		if(9 to 16)
			icon_state = icon_medium
		if(16 to INFINITY)
			icon_state = icon_far


/obj/item/pinpointer/proc/pinpoint_at(atom/pin_target)
	if(!pin_target)
		nullify_targets()
		return

	target = pin_target
	if(!target_turf)
		target_turf = get_turf(pin_target)
	if(!source_turf)
		source_turf = get_turf(src)

	if(!(target_turf && source_turf) || (target_turf.z != source_turf.z))
		nullify_targets()
		return

	dir = get_dir(source_turf, target_turf)
	var/new_dist = get_dist(source_turf, target_turf)
	if(new_dist != prev_dist)
		prev_dist = new_dist
		update_icon(UPDATE_ICON_STATE)

	target_turf = null
	source_turf = null


/obj/item/pinpointer/proc/nullify_targets(stop_icon_update = FALSE)
	var/should_update = target
	target = null
	target_turf = null
	source_turf = null
	prev_dist = null
	if(!stop_icon_update && should_update)
		update_icon(UPDATE_ICON_STATE)


/obj/item/pinpointer/proc/workdisk()
	scandisk()
	pinpoint_at(the_disk)


/obj/item/pinpointer/proc/workbomb()
	scanbomb()
	pinpoint_at(syndicate ? the_s_bomb : the_bomb)


/obj/item/pinpointer/examine(mob/user)
	. = ..()
	if(shows_nuke_timer)
		for(var/obj/machinery/nuclearbomb/bomb in GLOB.poi_list)
			if(bomb.timing)
				. += span_warning("Extreme danger. Arming signal detected. Time remaining: [bomb.timeleft]")

/obj/item/pinpointer/advpinpointer
	name = "advanced pinpointer"
	desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal."
	modes = list(MODE_ADV)
	var/modelocked = FALSE // If true, user cannot change mode.
	var/setting = NONE


/obj/item/pinpointer/advpinpointer/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += span_info("You can <b>Alt-Click</b> to choose tracking target.")


/obj/item/pinpointer/advpinpointer/process()
	switch(setting)
		if(SETTING_DISK)
			workdisk()
		if(SETTING_LOCATION, SETTING_OBJECT)
			pinpoint_at(target)


/obj/item/pinpointer/advpinpointer/AltClick(mob/user)
	if(Adjacent(user))
		toggle_mode(user)
		return
	..()


/obj/item/pinpointer/advpinpointer/verb/toggle_mode_verb()
	set category = "Object"
	set name = "Toggle Pinpointer Mode"
	set src in usr

	toggle_mode(usr)


/obj/item/pinpointer/advpinpointer/proc/toggle_mode(mob/user)
	if(!iscarbon(user) || user.incapacitated())
		return

	if(modelocked)
		to_chat(user, span_warning("[src] is locked. It can only track one specific target."))
		return

	switch(alert("Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", "Location", "Disk Recovery", "Other Signature"))
		if("Location")
			setting = SETTING_LOCATION

			var/locationx = input(user, "Enter X coordinate to search.", "Location X Define" , "") as null|num
			if(isnull(locationx) || !(user in view(1,src)))
				return
			var/locationy = input(user, "Enter Y coordinate to search.", "Location Y Define" , "") as null|num
			if(isnull(locationy) || !(user in view(1,src)))
				return

			source_turf = get_turf(src)
			locationx = clamp(locationx, 1, 255)
			locationy = clamp(locationy, 1, 255)
			target = locate(locationx, locationy, source_turf.z)
			to_chat(user, span_notice("You point the pinpointer to coordinates: [locationx], [locationy]."))

		if("Disk Recovery")
			setting = SETTING_DISK
			to_chat(user, span_notice("You point the pinpointer to Nuclear Authentication Disk."))

		if("Other Signature")
			setting = SETTING_OBJECT
			switch(alert("Search for item signature or DNA fragment?" , "Signature Mode Select" , "Item" , "DNA"))
				if("Item")
					var/list/item_names = list()
					var/list/item_paths = list()
					for(var/datum/theft_objective/objective as anything in GLOB.potential_theft_objectives)
						var/name = initial(objective.name)
						item_names += name
						item_paths[name] = initial(objective.typepath)
					var/targetitem = tgui_input_list(user, "Select item to serach for.", "Item Mode Select", item_names)
					if(!targetitem)
						return

					target = null
					var/list/target_candidates = get_all_of_type(item_paths[targetitem], subtypes = TRUE)
					for(var/obj/item/candidate in target_candidates)
						if(!is_admin_level((get_turf(candidate)).z))
							target = candidate
							to_chat(user, span_notice("You point the pinpointer to [target]."))
							break

					if(!target)
						nullify_targets(stop_icon_update = TRUE)
						to_chat(user, span_warning("Could not find [targetitem] signature!"))

				if("DNA")
					var/DNAstring = input("Input DNA string to search for." , "Please Enter String" , "")
					if(!DNAstring)
						return

					target = null
					for(var/mob/living/carbon/human/check as anything in GLOB.human_list)
						if(!check.dna)
							continue
						if(check.dna.unique_enzymes == DNAstring)
							target = check
							to_chat(user, span_notice("You point the pinpointer to [check.real_name]."))
							break

					if(!target)
						nullify_targets(stop_icon_update = TRUE)
						to_chat(user, span_warning("Failed to detect humanoid with DNA: [DNAstring]!"))

	if(mode == MODE_OFF)
		cycle(user, silent = TRUE)


///////////////////////
//nuke op pinpointers//
///////////////////////
/obj/item/pinpointer/nukeop
	var/obj/docking_port/mobile/home = null
	slot_flags = SLOT_BELT | SLOT_PDA
	syndicate = TRUE
	modes = list(MODE_DISK, MODE_NUKE)


/obj/item/pinpointer/nukeop/process()
	switch(mode)
		if(MODE_DISK)
			workdisk()
		if(MODE_NUKE)
			workbomb()
		if(MODE_SHIP)
			worklocation()


/obj/item/pinpointer/nukeop/workdisk()
	if(GLOB.bomb_set)	//If the bomb is set, lead to the shuttle
		mode = MODE_SHIP	//Ensures worklocation() continues to work
		modes = list(MODE_SHIP)
		playsound(loc, 'sound/machines/twobeep.ogg', 50, TRUE)	//Plays a beep
		visible_message(span_notice("Shuttle Locator mode actived."))			//Lets the mob holding it know that the mode has changed
		return		//Get outta here
	scandisk()
	pinpoint_at(the_disk)


/obj/item/pinpointer/nukeop/workbomb()
	if(GLOB.bomb_set)	//If the bomb is set, lead to the shuttle
		mode = MODE_SHIP	//Ensures worklocation() continues to work
		modes = list(MODE_SHIP)
		playsound(loc, 'sound/machines/twobeep.ogg', 50, TRUE)	//Plays a beep
		visible_message(span_notice("Shuttle Locator mode actived."))			//Lets the mob holding it know that the mode has changed
		return		//Get outta here
	scanbomb()
	pinpoint_at(the_s_bomb)


/obj/item/pinpointer/nukeop/proc/worklocation()
	if(!GLOB.bomb_set)
		mode = MODE_DISK
		modes = list(MODE_DISK, MODE_NUKE)
		playsound(loc, 'sound/machines/twobeep.ogg', 50, TRUE)
		visible_message(span_notice("Authentication Disk Locator mode actived."))
		return
	if(!home)
		home = SSshuttle.getShuttle("syndicate")
	pinpoint_at(home)


/obj/item/pinpointer/operative
	name = "operative pinpointer"
	desc = "A pinpointer that leads to the first Syndicate operative detected."
	icon_state = "pinoff_contractor"
	icon_off = "pinoff_contractor"
	icon_null = "pinonnull_contractor"
	icon_direct = "pinondirect_contractor"
	icon_close = "pinonclose_contractor"
	icon_medium = "pinonmedium_contractor"
	icon_far = "pinonfar_contractor"
	modes = list(MODE_OPERATIVE)


/obj/item/pinpointer/operative/process()
	if(mode == MODE_OPERATIVE)
		scan_for_ops()
		pinpoint_at(target)


/obj/item/pinpointer/operative/proc/scan_for_ops()
	target = null	// Resets nearest_op every time it scans
	var/closest_distance = 1000
	source_turf = get_turf(src)
	if(!source_turf)
		return
	var/mob/living/carbon/human/holder = get(loc, /mob/living/carbon/human)
	for(var/mob/living/carbon/human/operative as anything in (GLOB.human_list - holder))
		if(operative.mind && (operative.mind in SSticker.mode.syndicates))
			target_turf = get_turf(operative)
			if(!target_turf)
				continue
			var/new_dist = get_dist(source_turf, target_turf)
			if(source_turf.z == target_turf.z && new_dist < closest_distance)	//Actually points toward the nearest op, instead of a random one like it used to
				target = operative
				closest_distance = new_dist


/obj/item/pinpointer/operative/examine(mob/user)
	. = ..()
	if(target)
		var/mob/living/carbon/human/operative = target
		. += span_notice("Nearest operative detected is <i>[operative.real_name]</i>.")
	else
		. += span_notice("No operatives detected within scanning range.")


/obj/item/pinpointer/ninja
	name = "spider clan pinpointer"
	desc = "A pinpointer that leads to the first Spider Clan assassin detected."
	modes = list(MODE_NINJA)


/obj/item/pinpointer/ninja/process()
	if(mode == MODE_NINJA)
		scan_for_ninja()
		pinpoint_at(target)


/obj/item/pinpointer/ninja/proc/scan_for_ninja()
	target = null //Resets nearest_ninja every time it scans
	var/closest_distance = 1000
	source_turf = get_turf(src)
	if(!source_turf)
		return
	var/mob/living/carbon/human/holder = get(loc, /mob/living/carbon/human)
	for(var/mob/living/carbon/human/potential_ninja as anything in (GLOB.human_list - holder))
		if(isninja(potential_ninja))
			target_turf = get_turf(potential_ninja)
			if(!target_turf)
				continue
			var/new_dist = get_dist(source_turf, target_turf)
			if(source_turf.z == target_turf.z && new_dist < closest_distance)
				target = potential_ninja
				closest_distance = new_dist


/obj/item/pinpointer/ninja/examine(mob/user)
	. = ..()
	if(target)
		var/mob/living/carbon/human/ninja = target
		. += span_notice("Nearest ninja detected is <i>[ninja.real_name]</i>.")
	else
		. += span_notice("No ninjas detected within scanning range.")


/obj/item/pinpointer/crew
	name = "crew pinpointer"
	desc = "A handheld tracking device that points to crew suit sensors."
	shows_nuke_timer = FALSE
	icon_state = "pinoff_crew"
	icon_off = "pinoff_crew"
	icon_null = "pinonnull_crew"
	icon_direct = "pinondirect_crew"
	icon_close = "pinonclose_crew"
	icon_medium = "pinonmedium_crew"
	icon_far = "pinonfar_crew"
	modes = list(MODE_CREW)


/obj/item/pinpointer/crew/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += span_info("You can <b>Alt-Click</b> to choose whom to track.")


/obj/item/pinpointer/crew/proc/is_trackable(mob/living/carbon/human/pin_target)
	if(pin_target && istype(pin_target.w_uniform, /obj/item/clothing/under))
		source_turf = get_turf(src)
		if(!source_turf)
			return FALSE
		var/obj/item/clothing/under/uniform = pin_target.w_uniform
		// Suit sensors must be on maximum.
		if(!uniform.has_sensor || uniform.sensor_mode < 3)
			return FALSE
		target_turf = get_turf(pin_target)
		return target_turf && source_turf.z == target_turf.z
	return FALSE


/obj/item/pinpointer/crew/process()
	if(mode == MODE_CREW)
		pinpoint_at(target)


/obj/item/pinpointer/crew/pinpoint_at(atom/pin_target)
	if(!is_trackable(pin_target))
		nullify_targets()
		return
	..()


/obj/item/pinpointer/crew/AltClick(mob/user)
	if(Adjacent(user))
		choose_signal(user)
		return
	..()


/obj/item/pinpointer/crew/verb/choose_signal_verb()
	set category = "Object"
	set name = "Track Signals"
	set src in usr

	choose_signal(usr)


/obj/item/pinpointer/crew/proc/choose_signal(mob/living/carbon/user)
	if(!iscarbon(user) || user.incapacitated())
		return

	var/list/name_counts = list()
	var/list/names = list()

	for(var/mob/living/carbon/human/human as anything in GLOB.human_list)
		if(!is_trackable(human))
			continue

		var/human_name = "Unknown"
		if(human.wear_id)
			var/obj/item/card/id/card = human.wear_id.GetID()
			if(card)
				human_name = card.registered_name

		while(human_name in name_counts)
			name_counts[human_name]++
			human_name = "[human_name] ([name_counts[human_name]])"
		names[human_name] = human
		name_counts[human_name] = 1

	if(!length(names))
		user.visible_message(
			span_notice("[user]'s pinpointer fails to detect any signals."),
			span_notice("Your pinpointer fails to detect any signals."),
		)
		return

	var/choice = tgui_input_list(user, "Person to track", "Pinpoint", names)
	if(!choice || !src || !user || (user.get_active_hand() != src) || user.incapacitated())
		return

	target = names[choice]
	user.visible_message(
		span_notice("[user] activates [user.p_their()] pinpointer."),
		span_notice("You start tracking [choice]."),
	)

	if(mode == MODE_OFF)
		cycle(user, silent = TRUE)


/obj/item/pinpointer/crew/centcom
	name = "centcom pinpointer"
	desc = "A handheld tracking device that tracks crew based on remote centcom sensors."


/obj/item/pinpointer/crew/centcom/is_trackable(mob/living/carbon/human/pin_target)
	source_turf = get_turf(src)
	target_turf = get_turf(pin_target)
	return source_turf && target_turf && source_turf.z == target_turf.z


///////////////////////
///thief pinpointers///
///////////////////////
/obj/item/pinpointer/thief
	name = "pinpointer"
	desc = "Модифицированный пинпоинтер #REDACTED# предназначенный для нахождения всех ценных и интересных для #REDACTED# сигнатур, не передающий сигналы локаторами. На обратной стороне напечатан странный непонятный детский ребус."
	modes = list(MODE_THIEF)
	shows_nuke_timer = FALSE
	icon_state = "pinoff_crew"
	icon_off = "pinoff_crew"
	icon_null = "pinonnull_crew"
	icon_direct = "pinondirect_crew"
	icon_close = "pinonclose_crew"
	icon_medium = "pinonmedium_crew"
	icon_far = "pinonfar_crew"
	var/setting = NONE
	var/list/current_targets
	var/targets_index = 1


/obj/item/pinpointer/thief/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += span_info("Нажмите <b>Alt-Click</b> для выбора режима отслеживания.")


/obj/item/pinpointer/thief/process()
	if(setting == SETTING_LOCATION || setting == SETTING_OBJECT)
		pinpoint_at(target)


/obj/item/pinpointer/thief/cycle(mob/user, silent = TRUE)
	. = ..()
	switch(setting)
		if(SETTING_LOCATION)
			if(!target)
				to_chat(user, span_notice("Определите координаты локации у пинпоинтера."))
		if(SETTING_OBJECT)
			if(!target)
				to_chat(user, span_notice("Определите цель пинпоинтера."))
		else
			to_chat(user, span_notice("Режим пинпоинтера не определен."))


/obj/item/pinpointer/thief/AltClick(mob/user)
	if(Adjacent(user))
		toggle_mode(user)
		return
	..()


/obj/item/pinpointer/thief/verb/toggle_mode_verb()
	set category = "Object"
	set name = "Переключить Режим Пинпоинтера"
	set src in usr

	toggle_mode(usr)


/obj/item/pinpointer/thief/proc/toggle_mode(mob/user)
	if(!iscarbon(user) || user.incapacitated())
		return

	switch(alert("Выберите режим пинпоинтера.", "Выбор режима пинпоинтера", "Локация", "Сигнатура Объекта", "Цели"))
		if("Локация")
			setting = SETTING_LOCATION

			var/locationx = input(user, "Введите X координату для поиска.", "Локация?" , "") as null|num
			if(isnull(locationx) || !(user in view(1,src)))
				return
			var/locationy = input(user, "Введите Y координату для поиска.", "Локация?" , "") as null|num
			if(isnull(locationy) || !(user in view(1,src)))
				return

			source_turf = get_turf(src)
			locationx = clamp(locationx, 1, 255)
			locationy = clamp(locationy, 1, 255)
			target = locate(locationx, locationy, source_turf.z)
			to_chat(user, span_notice("Вы переключили пинпоинтер на координаты: [locationx], [locationy]."))

		if("Сигнатура Объекта")
			setting = SETTING_OBJECT
			var/list/targets_list = list()
			var/list/target_names = list()
			var/list/target_paths = list()
			var/input_ask = "Выберите сигнатуру"
			var/input_tittle = "Режим выбора"

			var/input_type
			input_type = alert("Какие типы сигнатуры объектов необходимо найти?" , "Выбор Сигнатуры Объектов" , "Предмет" , "Структура" , "Питомец")
			if(!input_type)
				return

			var/input_subtype
			switch(input_type)
				if("Предмет")
					input_subtype = alert("Какой тип доступности предмета?" , "Определение Доступности Предмета" , "Сложнодоступен" , "Доступен" , "Коллекционный")
					switch(input_subtype)
						if("Сложнодоступен")
							for(var/datum/theft_objective/theft as anything in (GLOB.potential_theft_objectives_hard|GLOB.potential_theft_objectives))
								targets_list += initial(theft.typepath)

						if("Доступен")
							for(var/datum/theft_objective/theft as anything in GLOB.potential_theft_objectives_medium)
								targets_list += initial(theft.typepath)

						if("Коллекционный")
							for(var/datum/theft_objective/collect/theft as anything in GLOB.potential_theft_objectives_collect)
								var/typepath_datum = initial(theft.typepath)
								if(typepath_datum)
									targets_list += typepath_datum
									continue
								var/subtype_datum = initial(theft.subtype)
								var/list/type_list = subtype_datum ? subtypesof(subtype_datum) : initial(theft.type_list)
								targets_list += type_list

					if(!input_subtype)
						return

					input_subtype = " ([input_subtype])"
					if(!length(targets_list))
						return

				if("Структура")
					for(var/datum/theft_objective/structure/theft as anything in GLOB.potential_theft_objectives_structure)
						targets_list += initial(theft.typepath)

				if("Питомец")
					for(var/datum/theft_objective/animal/theft as anything in GLOB.potential_theft_objectives_animal)
						targets_list += initial(theft.typepath)

			for(var/atom/theft_typepath as anything in targets_list)
				var/theft_name = initial(theft_typepath.name)
				target_names += theft_name
				target_paths[theft_name] = theft_typepath

			var/choosen_target = tgui_input_list(user, "[input_ask], типа \"[input_type][input_subtype]\"", "[input_tittle]: [input_type][input_subtype]", target_names)
			if(!choosen_target)
				return

			current_targets = get_theft_targets_station(target_paths[choosen_target], subtypes = TRUE, blacklist = list(user))
			if(!length(current_targets))
				to_chat(user, span_warning("Не удалось обнаружить <b>[choosen_target]</b>!"))
				return

			targets_index = 1
			target = current_targets[targets_index]
			to_chat(user, span_notice("Вы переключили пинпоинтер для обнаружения <b>[choosen_target]</b>. Найдено целей: <b>[length(current_targets)]</b>."))

		if("Цели")
			var/input_type = alert("Какую операцию стоит произвести?", "Выбор Операции", "Показать Цели", "Следующая Цель")
			switch(input_type)
				if("Показать Цели")
					setting = SETTING_OBJECT
					var/list/all_objectives = user.mind.get_all_objectives()
					if(length(all_objectives) && user.mind.has_antag_datum(/datum/antagonist/thief))
						var/list/targets_list = list()
						var/list/target_names = list()
						var/list/target_paths = list()

						for(var/datum/objective/steal/objective in all_objectives)
							if(istype(objective, /datum/objective/steal/collect))
								var/datum/theft_objective/collect/theft = objective.steal_target
								var/list/wanted_item_types = theft?.wanted_items
								if(wanted_item_types && length(wanted_item_types))
									targets_list |= wanted_item_types

							else
								var/wanted_type = objective.steal_target?.typepath
								if(wanted_type)
									targets_list |= wanted_type

						for(var/atom/theft_typepath as anything in targets_list)
							var/theft_name = initial(theft_typepath.name)
							target_names += theft_name
							target_paths[theft_name] = theft_typepath

						var/choosen_target = tgui_input_list(user, "Выберите интересующую вас цель:", "Режим Выбора Цели", target_names)
						if(!choosen_target)
							return

						current_targets = get_theft_targets_station(target_paths[choosen_target], subtypes = TRUE, blacklist = list(user))
						if(!length(current_targets))
							to_chat(user, span_warning("Не удалось обнаружить <b>[choosen_target]</b>!"))
							return

						targets_index = 1
						target = current_targets[targets_index]
						to_chat(user, span_notice("Вы переключили пинпоинтер для обнаружения <b>[choosen_target]</b>. Найдено целей: <b>[length(current_targets)]</b>."))

					else
						to_chat(user, span_warning("Не удалось обнаружить интересные цели для #REDACTED#! Если вы не член #REDACTED#, верните устройство владельцу или обратитесь по зашифрованному номеру на обратной стороне пинпоинтера."))
						return

				if("Следующая Цель")
					if(!length(current_targets))
						to_chat(user, span_warning("Не удалось идентифицировать режим отслеживания!"))
						return

					targets_index++
					if(targets_index > length(current_targets))
						targets_index = 1
						var/atom/temp_target = current_targets[targets_index]
						to_chat(user, span_warning("Доступные цели, с сигнатурой <b>[initial(temp_target.name)]</b>, закончились, возвращаемся к первой!"))

					else
						var/atom/temp_target = current_targets[targets_index]
						to_chat(user, span_notice("Вы переключили пинпоинтер на <b>[targets_index]</b> цель из <b>[length(current_targets)]</b>, сигнатура: <b>[initial(temp_target.name)]</b>."))

					target = current_targets[targets_index]

	if(mode == MODE_OFF)
		cycle(user, silent = TRUE)


/obj/item/pinpointer/tendril
	name = "ancient scanning unit"
	desc = "Convenient that the scanning unit for the robot survived. Seems to point to the tendrils around here."
	icon_state = "pinoff_ancient"
	icon_off = "pinoff_ancient"
	icon_null = "pinonnull_ancient"
	icon_direct = "pinondirect_ancient"
	icon_close = "pinonclose_ancient"
	icon_medium = "pinonmedium_ancient"
	icon_far = "pinonfar_ancient"
	modes = list(MODE_TENDRIL)


/obj/item/pinpointer/tendril/process()
	if(mode == MODE_TENDRIL)
		scan_for_tendrils()
		pinpoint_at(target)


/obj/item/pinpointer/tendril/proc/scan_for_tendrils()
	target = null //Resets nearest_op every time it scans
	var/closest_distance = 1000
	source_turf = get_turf(src)
	if(!source_turf)
		return
	for(var/obj/structure/spawner/lavaland/tendril as anything in GLOB.tendrils)
		target_turf = get_turf(tendril)
		if(!target_turf)
			continue
		var/new_dist = get_dist(source_turf, target_turf)
		if(source_turf.z == target_turf.z && new_dist < closest_distance)
			target = tendril
			closest_distance = new_dist


/obj/item/pinpointer/tendril/examine(mob/user)
	. = ..()
	if(mode == MODE_TENDRIL)
		. += "Number of high energy signatures remaining: [length(GLOB.tendrils)]"


#undef MODE_OFF
#undef MODE_DISK
#undef MODE_NUKE
#undef MODE_ADV
#undef MODE_SHIP
#undef MODE_OPERATIVE
#undef MODE_CREW
#undef MODE_NINJA
#undef MODE_THIEF
#undef MODE_TENDRIL
#undef SETTING_DISK
#undef SETTING_LOCATION
#undef SETTING_OBJECT


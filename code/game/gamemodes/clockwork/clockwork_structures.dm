/obj/structure/clockwork
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/clockwork.dmi'

/obj/structure/clockwork/beacon
	name = "herald's beacon"
	desc = "An imposing spire formed of brass. It somewhat pulsates. Cool and pretty!"
	icon_state = "beacon"

/obj/structure/clockwork/altar
	name = "credence"
	desc = "A strange brass platform with spinning cogs inside. It demands somethinge in exchange for goods... once upon a time. Now it's just a dull piece of brass."
	icon_state = "altar"
	density = FALSE

/obj/structure/clockwork/functional
	max_integrity = 100
	var/cooldowntime = 0
	var/death_message = "<span class='danger'>The structure falls apart.</span>"
	var/death_sound = 'sound/effects/forge_destroy.ogg'
	var/canbehidden = FALSE
	var/hidden = FALSE
	var/hidden_type
	var/list/choosable_items = list(
		"rack" = /obj/structure/rack,
		"table" = /obj/structure/table,
		"wooden table" = /obj/structure/table/wood,
		"personal closet" = /obj/structure/closet/secure_closet/personal,
		"girder" = /obj/structure/girder,
		"bookcase" = /obj/structure/bookcase
		)

/obj/structure/clockwork/functional/update_name(updates = ALL)
	. = ..()
	if(!hidden)
		name = initial(name)
		return
	switch(hidden_type)
		if("rack")
			name = "rack"
		if("table")
			name = "table"
		if("wooden table")
			name = "wooden table"
		if("personal closet")
			name = "personal closet"
		if("girder")
			name = "girder"
		if("bookcase")
			name = "bookcase"


/obj/structure/clockwork/functional/update_desc(updates = ALL)
	. = ..()
	if(!hidden)
		desc = initial(desc)
		return
	switch(hidden_type)
		if("rack")
			desc = "Different from the Middle Ages version. <BR><span class='notice'>It's held together by a couple of <b>bolts</b>.</span>"
		if("table")
			desc = "A square piece of metal standing on four metal legs. It can not move. <BR><span class='notice'>The top is <b>screwed</b> on, but the main <b>bolts</b> are also visible.</span>"
		if("wooden table")
			desc = "Do not apply fire to this. Rumour says it burns easily. <BR><span class='notice'>The top is <b>screwed</b> on, but the main <b>bolts</b> are also visible.</span>"
		if("personal closet")
			desc = "It's a secure locker for personnel. The first card swiped gains control."
		if("girder")
			desc = "<span class='notice'>The bolts are <b>lodged</b> in place.</span>"
		if("bookcase")
			desc = null


/obj/structure/clockwork/functional/update_icon_state()
	if(!hidden)
		icon = initial(icon)
		icon_state = anchored ? "[initial(icon_state)]-off" : initial(icon_state)
		return
	switch(hidden_type)
		if("rack")
			icon = 'icons/obj/objects.dmi'
			icon_state = "rack"
		if("table")
			icon = 'icons/obj/smooth_structures/table.dmi'
			icon_state = "table"
		if("wooden table")
			icon = 'icons/obj/smooth_structures/wood_table.dmi'
			icon_state = "wood_table"
		if("personal closet")
			icon = 'icons/obj/closet.dmi'
			icon_state = "secureoff"
		if("girder")
			icon = 'icons/obj/structures.dmi'
			icon_state = "girder"
		if("bookcase")
			icon = 'icons/obj/library.dmi'
			icon_state = "book-0"


/obj/structure/clockwork/functional/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/clockslab) && isclocker(user))
		add_fingerprint(user)
		if(I.enchant_type == HIDE_SPELL && canbehidden)
			var/choice
			if(!hidden)
				choice = show_radial_menu(user, src, choosable_items, require_near = TRUE)
				if(I.enchant_type != HIDE_SPELL || !choice || !Adjacent(user) || user.incapacitated())
					return ATTACK_CHAIN_BLOCKED_ALL
			toggle_hide(choice)
			to_chat(user, span_notice("You [hidden ? null : "un"]disguise [src]."))
			playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)
			I.deplete_spell()
			return ATTACK_CHAIN_BLOCKED_ALL
		if(hidden)
			toggle_hide(null)
			return ATTACK_CHAIN_BLOCKED_ALL
		if(!anchored && !isfloorturf(loc))
			to_chat(user, span_warning("A floor must be present to secure [src]!"))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(locate(/obj/structure/clockwork) in (loc.contents-src))
			to_chat(user, span_warning("There is a structure here!"))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(locate(/obj/structure/falsewall) in loc)
			to_chat(user, span_warning("There is a structure here!"))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		set_anchored(!anchored)
		to_chat(user, span_notice("You [anchored ? "":"un"]secure [src] [anchored ? "to":"from"] the floor."))
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/structure/clockwork/functional/obj_destruction()
	visible_message(death_message)
	playsound(src, death_sound, 50, TRUE)
	. = ..()

/obj/structure/clockwork/functional/examine(mob/user)
	. = ..()
	if(hidden && isclocker(user))
		. += "<span class='notice'>It's a disguised [initial(name)]!</span>"

// returns TRUE if hidden, if unhidden FALSE
/obj/structure/clockwork/functional/proc/toggle_hide(chosen_type)
	hidden = !hidden
	if(!hidden)
		hidden_type = null
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
		return FALSE

	hidden_type = chosen_type
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
	return TRUE

/obj/structure/clockwork/functional/beacon
	name = "herald's beacon"
	desc = "An imposing spire formed of brass. It somewhat pulsates."
	icon_state = "beacon"
	max_integrity = 250 // A very important one
	death_message = "<span class='danger'>The beacon crumbles and falls in parts to the ground relaesing it's power!</span>"
	death_sound = 'sound/effects/creepyshriek.ogg'
	var/heal_delay = 6 SECONDS
	var/last_heal = 0
	var/area/areabeacon
	var/areastring = null
	color = "#FFFFFF"

/obj/structure/clockwork/functional/beacon/Initialize(mapload)
	. = ..()
	areabeacon = get_area(src)
	GLOB.clockwork_beacons += src
	START_PROCESSING(SSobj, src)
	var/area/A = get_area(src)
	//if area isn't specified use current
	if(isarea(A))
		areabeacon = A
	SSticker.mode.clocker_objs.beacon_check()

/obj/structure/clockwork/functional/beacon/process()
	adjust_clockwork_power(CLOCK_POWER_BEACON)

	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(5, src))
			if(!isclocker(L))
				continue
			if(L.reagents?.has_reagent("holywater"))
				to_chat(L, "<span class='warning'>You feel a terrible liquid disappearing from your body.</span>")
				L.reagents.del_reagent("holywater")
			if(iscogscarab(L))
				var/mob/living/silicon/robot/cogscarab/C = L
				C.wind_up_timer = min(C.wind_up_timer + 60, CLOCK_MAX_WIND_UP_TIMER) //every 6 seconds gains 60 seconds. roughly, every second 10 to timer.
			if(!(L.health < L.maxHealth))
				continue
			new /obj/effect/temp_visual/heal(get_turf(L), "#960000")

			if(ishuman(L))
				L.heal_overall_damage(10, 10, affect_robotic = TRUE)
			if(isrobot(L))
				L.heal_overall_damage(5, 5)

			else if(isanimal(L))
				var/mob/living/simple_animal/M = L
				if(M.health < M.maxHealth)
					M.adjustHealth(-8)

			if(ishuman(L) && !HAS_TRAIT(L, TRAIT_NO_BLOOD_RESTORE) && L.blood_volume < BLOOD_VOLUME_NORMAL)
				L.blood_volume += 1


/obj/structure/clockwork/functional/beacon/Destroy()
	GLOB.clockwork_beacons -= src
	STOP_PROCESSING(SSobj, src)
	for(var/datum/mind/M in SSticker.mode.clockwork_cult)
		to_chat(M.current, "<span class='danger'>You get the feeling that one of the beacons have been destroyed! The source comes from [areabeacon.name]</span>")
	return ..()

/obj/structure/clockwork/functional/beacon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/clockslab) && isclocker(user))
		add_fingerprint(user)
		to_chat(user, span_danger("You try to unsecure [src], but it's secures himself back tightly!"))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/structure/clockwork/functional/altar
	name = "credence"
	desc = "A strange brass platform with spinning cogs inside. It demands something in exchange for goods..."
	icon_state = "altar"
	density = FALSE
	death_message = "<span class='danger'>The credence breaks in pieces as it dusts into nothing!</span>"
	canbehidden = TRUE
	choosable_items = list(
		"potted plant" = /obj/item/twohanded/required/kirbyplants,
		"chair" = /obj/structure/chair,
		"stool" = /obj/structure/chair/stool,
		"broken grille" = /obj/structure/grille/broken
		)
	var/locname = null
	var/obj/effect/temp_visual/ratvar/altar_convert/glow

	var/mob/living/carbon/human/converting = null // Who is getting converted
	var/mob/living/has_clocker = null // A clocker who checks the converting

	var/first_stage = FALSE // Did convert started?
	var/second_stage = FALSE // Did we started to gib someone?
	var/convert_timer = 0

// For fake brass
/obj/structure/clockwork/functional/fake_altar
	desc = "A strange brass platform with spinning cogs inside. It demands somethinge in exchange for goods... once upon a time. Now it's just a dull piece of brass."

/obj/structure/clockwork/functional/altar/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	locname = initial(A.name)
	GLOB.clockwork_altars += src
	START_PROCESSING(SSprocessing, src)

/obj/structure/clockwork/functional/altar/Destroy()
	GLOB.clockwork_altars -= src
	if(converting)
		stop_convert()
	STOP_PROCESSING(SSprocessing, src)
	return ..()


/obj/structure/clockwork/functional/altar/update_name(updates = ALL)
	. = ..()
	if(!hidden)
		name = initial(name)
		return
	switch(hidden_type)
		if("potted plant")
			name = "potted plant"
		if("chair")
			name = "chair"
		if("stool")
			name = "stool"
		if("broken grille")
			name = "grille"


/obj/structure/clockwork/functional/altar/update_desc(updates = ALL)
	. = ..()
	if(!hidden)
		desc = initial(desc)
		return
	switch(hidden_type)
		if("potted plant")
			desc = null
		if("chair")
			desc = "You sit in this. Either by will or force."
		if("stool")
			desc = "Apply butt."
		if("broken grille")
			desc = "A flimsy framework of metal rods."


/obj/structure/clockwork/functional/altar/update_icon_state()
	if(!hidden)
		icon = initial(icon)
		if(!anchored)
			icon_state = "[initial(icon_state)]-off"
			return
		icon_state = first_stage ? "[initial(icon_state)]-fast" : initial(icon_state)
		return
	switch(hidden_type)
		if("potted plant")
			icon = 'icons/obj/flora/plants.dmi'
			icon_state = "plant-[rand(1,36)]"
		if("chair")
			icon = 'icons/obj/chairs.dmi'
			icon_state = "chair"
		if("stool")
			icon = 'icons/obj/chairs.dmi'
			icon_state = "stool"
		if("broken grille")
			icon = 'icons/obj/structures.dmi'
			icon_state = "brokengrille"


/obj/structure/clockwork/functional/altar/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/clockslab) && isclocker(user))
		add_fingerprint(user)
		if(hidden)
			toggle_hide(null)
			if(anchored)
				START_PROCESSING(SSprocessing, src)
			to_chat(user, span_notice("You undisguise [src]."))
			playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			return ATTACK_CHAIN_BLOCKED_ALL
		if(I.enchant_type == HIDE_SPELL && canbehidden)
			var/choice
			if(!hidden)
				choice = show_radial_menu(user, src, choosable_items, require_near = TRUE)
				if(I.enchant_type != HIDE_SPELL || !choice || !Adjacent(user) || user.incapacitated())
					return ATTACK_CHAIN_BLOCKED_ALL
			toggle_hide(choice)//cuz we sure its unhidden
			if(isprocessing)
				STOP_PROCESSING(SSprocessing, src)
				if(glow)
					QDEL_NULL(glow)
				first_stage = FALSE
				second_stage = FALSE
				convert_timer = 0
				converting = null
			to_chat(user, span_notice("You disguise [src]."))
			playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			I.deplete_spell()
			return ATTACK_CHAIN_BLOCKED_ALL
		if(!anchored && !isfloorturf(loc))
			to_chat(user, span_warning("A floor must be present to secure [src]!"))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(!anchored && locate(/obj/structure/clockwork) in (loc.contents-src))
			to_chat(user, span_warning("There is a structure here!"))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(locate(/obj/structure/falsewall) in loc)
			to_chat(user, span_warning("There is a structure here!"))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		set_anchored(!anchored)
		update_icon(UPDATE_ICON_STATE)
		to_chat(user, span_notice("You [anchored ? "":"un"]secure [src] [anchored ? "to":"from"] the floor."))
		if(!anchored)
			stop_convert(TRUE)
			STOP_PROCESSING(SSprocessing, src)
		else
			START_PROCESSING(SSprocessing, src)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/structure/clockwork/functional/altar/process()
	for(var/mob/living/M in range(1, src))
		if(isclocker(M) && M.stat == CONSCIOUS)
			has_clocker = M
			break
	if(!converting && has_clocker)
		for(var/mob/living/carbon/human/H in range(0, src))
			if(isclocker(H))
				continue
			if(!H.mind)
				continue
			if(H)
				converting = H
				break
	if(converting && (converting in range(0, src)) && (has_clocker || second_stage))
		if(!anchored || hidden)
			stop_convert()
			return
		convert_timer++
		has_clocker = null
		switch(convert_timer)
			if(0 to 8)
				if(!first_stage)
					first_stage_check(converting)
			if(9 to 16)
				if(!second_stage)
					second_stage_check(converting)
				else
					converting.take_overall_damage(5, 5)
			if(17)
				adjust_clockwork_power(CLOCK_POWER_SACRIFICE)
				var/obj/item/mmi/robotic_brain/clockwork/cube = new (get_turf(src))
				cube.try_to_transfer(converting)
	else if(first_stage)
		stop_convert()

/obj/structure/clockwork/functional/altar/proc/first_stage_check(var/mob/living/carbon/human/target)
	first_stage = TRUE
	target.visible_message("<span class='warning'>[src] begins to glow a piercing amber!</span>", "<span class='clock'>You feel something start to invade your mind...</span>")
	glow = new (get_turf(src))
	animate(glow, alpha = 255, time = 8 SECONDS)
	update_icon(UPDATE_ICON_STATE)

/obj/structure/clockwork/functional/altar/proc/second_stage_check(var/mob/living/carbon/human/target)
	second_stage = TRUE
	if(!is_convertable_to_clocker(target.mind) || target.stat == DEAD) // mindshield or holy or mindless monkey. or dead guy
		target.visible_message("<span class='warning'>[src] in glowing manner starts corrupting [target]!</span>", \
		"<span class='danger'>You feel as your body starts to corrupt by [src] underneath!</span>")
		target.Weaken(20 SECONDS)
	else // just a living non-clocker civil
		to_chat(target, "<span class='clocklarge'><b>\"You belong to me now.\"</b></span>")
		target.heal_overall_damage(50, 50)
		if(isgolem(target))
			target.mind.wipe_memory()
			target.set_species(/datum/species/golem/clockwork)
		SSticker.mode.add_clocker(target.mind)
		target.Weaken(10 SECONDS) //Accept new power... and new information
		target.EyeBlind(10 SECONDS)
		stop_convert(TRUE)

/obj/structure/clockwork/functional/altar/proc/stop_convert(var/silent = FALSE)
	QDEL_NULL(glow)
	first_stage = FALSE
	second_stage = FALSE
	convert_timer = 0
	converting = null
	update_icon(UPDATE_ICON_STATE)
	if(!silent)
		visible_message("<span class='warning'>[src] slowly stops glowing!</span>")


/obj/structure/clockwork/functional/altar/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/shard))
		add_fingerprint(user)
		if(!ishuman(user))
			to_chat(user, span_warning("You are too weak to push the shard inside!"))
			return ATTACK_CHAIN_PROCEED
		if(!anchored)
			to_chat(user, span_warning("It has to be anchored before you can start!"))
			return ATTACK_CHAIN_PROCEED
		var/area/A = get_area(src)
		if(!double_check(user, A))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ATTACK_CHAIN_PROCEED
		GLOB.command_announcement.Announce("Была обнаружена аномально высокая концентрация энергии в [A.map_name]. Источник энергии указывает на попытку вызвать потустороннего бога по имени Ратвар. Сорвите ритуал любой ценой, пока станция не была уничтожена! Действие космического закона и стандартных рабочих процедур приостановлено. Весь экипаж должен уничтожать культистов на месте.", "Отдел Центрального Командования по делам высших измерений.", 'sound/AI/spanomalies.ogg')
		visible_message(span_dangerbigger("[user] ominously presses [I] into [src] as the mechanism inside starts to shine!"))
		qdel(I)
		begin_the_ritual()
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/structure/clockwork/functional/altar/proc/double_check(mob/living/user, area/A)
	var/datum/game_mode/gamemode = SSticker.mode

	if(GLOB.ark_of_the_clockwork_justiciar)
		to_chat(user, "<span class='clockitalic'>There is already Gateway somewhere!</span>")
		return FALSE

	if(gamemode.clocker_objs.clock_status < RATVAR_NEEDS_SUMMONING)
		to_chat(user, "<span class='clockitalic'><b>Ratvar</b> is not ready to be summoned yet!</span>")
		return FALSE
	if(gamemode.clocker_objs.clock_status == RATVAR_HAS_RISEN)
		to_chat(user, "<span class='clocklarge'>\"My fellow. There is no need for it anymore.\"</span>")
		return FALSE

	var/list/summon_areas = gamemode.clocker_objs.obj_summon.ritual_spots
	if(!(A in summon_areas))
		to_chat(user, "<span class='cultlarge'>Ratvar can only be summoned where the veil is weak - in [english_list(summon_areas)]!</span>")
		return FALSE
	var/confirm_final = tgui_alert(user, "This is the FINAL step to summon, the crew will be alerted to your presence AND your location!",
	"The power comes...", list("Let Ratvar shine ones more!", "No"))
	if(user)
		if(confirm_final != "Let Ratvar shine ones more!")
			to_chat(user, "<span class='clockitalic'><b>You decide to prepare further before pincing the shard.</b></span>")
			return FALSE
		return TRUE

/obj/structure/clockwork/functional/altar/proc/begin_the_ritual()
	visible_message("<span class='danger'>The [src] expands itself revealing into the great Ark!</span>")
	new /obj/structure/clockwork/functional/celestial_gateway(get_turf(src))
	qdel(src)
	return

/obj/structure/clockwork/functional/cogscarab_fabricator
	name = "cogscarab fabricator"
	desc = "House for a tons of little cogscarabs, self-producing and maintaining itself."
	icon_state = "fabricator"
	death_message = "<span class='danger'>Fabricator crumbles and dusts, leaving nothing behind!</span>"
	var/list/cogscarab_list = list()
	canbehidden = TRUE
	var/cog_slots = 0
	var/timer_fabrictor = null

/obj/structure/clockwork/functional/cogscarab_fabricator/examine(mob/user)
	. = ..()
	if(!hidden && (isclocker(user) || isobserver(user)))
		. += "<span class='notice'>There's [cog_slots - cogscarab_list.len] cogscarab ready. [timer_fabrictor ? "And it's creating another one now" : "It stopped creating."]."


/obj/structure/clockwork/functional/cogscarab_fabricator/update_icon_state()
	icon_state = anchored ? "[initial(icon_state)]-off" : initial(icon_state)


/obj/structure/clockwork/functional/cogscarab_fabricator/Initialize(mapload)
	. = ..()
	GLOB.clockwork_fabricators += src
	timer_fabrictor = addtimer(CALLBACK(src, PROC_REF(open_slot)), TIME_NEW_COGSCRAB SECONDS)
	notify_ghosts("[src] is created at [get_area(src)].", title = "New cogscarab fabricator!", source = src, flashwindow = FALSE, action = NOTIFY_JUMP)

/obj/structure/clockwork/functional/cogscarab_fabricator/obj_destruction()
	. = ..()
	GLOB.clockwork_fabricators -= src

/obj/structure/clockwork/functional/cogscarab_fabricator/proc/open_slot()
	cog_slots += 1
	notify_ghosts("[src] made a new shell at [get_area(src)]!", title = "Cogscarab ready!", source = src, action = NOTIFY_ATTACK)
	if(cog_slots < MAX_COGSCRAB_PER_FABRICATOR)
		timer_fabrictor = addtimer(CALLBACK(src, PROC_REF(open_slot)), TIME_NEW_COGSCRAB SECONDS)
	else
		timer_fabrictor = null

/obj/structure/clockwork/functional/cogscarab_fabricator/proc/close_slot(cogscarab)
	cogscarab_list -= cogscarab
	cog_slots -= 1
	if(!timer_fabrictor)
		timer_fabrictor = addtimer(CALLBACK(src, PROC_REF(open_slot)), TIME_NEW_COGSCRAB SECONDS)


/obj/structure/clockwork/functional/cogscarab_fabricator/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/clockslab) && isclocker(user) && I.enchant_type != HIDE_SPELL && !hidden)
		add_fingerprint(user)
		if(!anchored && !isfloorturf(loc))
			to_chat(user, span_warning("A floor must be present to secure [src]!"))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(locate(/obj/structure/clockwork) in (loc.contents-src))
			to_chat(user, span_warning("There is a structure here!"))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(locate(/obj/structure/falsewall) in loc)
			to_chat(user, span_warning("There is a structure here!"))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		set_anchored(!anchored)
		update_icon(UPDATE_ICON_STATE)
		to_chat(user, span_notice("You [anchored ? "":"un"]secure [src] [anchored ? "to":"from"] the floor."))
		if(!anchored)
			if(timer_fabrictor)
				deltimer(timer_fabrictor)
				timer_fabrictor = null
		else
			if(cog_slots < MAX_COGSCRAB_PER_FABRICATOR)
				timer_fabrictor = addtimer(CALLBACK(src, PROC_REF(open_slot)), TIME_NEW_COGSCRAB SECONDS)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/structure/clockwork/functional/cogscarab_fabricator/toggle_hide(chosen_type)
	. = ..()
	if(. && timer_fabrictor) // hidden
		deltimer(timer_fabrictor)
		timer_fabrictor = null
	else
		if(cog_slots < MAX_COGSCRAB_PER_FABRICATOR)
			timer_fabrictor = addtimer(CALLBACK(src, PROC_REF(open_slot)), TIME_NEW_COGSCRAB SECONDS)

/obj/structure/clockwork/functional/cogscarab_fabricator/attack_ghost(mob/dead/observer/user)
	if(hidden)
		to_chat(user, "<span class='warning'>It's hidden and cannot produce you at this state!</span>")
		return FALSE
	if(!anchored)
		to_chat(user, "<span class='warning'>It seems to be non-functional to produce a new shell!</span>")
		return FALSE
	if(cogscarab_list.len >= cog_slots)
		to_chat(user, "<span class='notice'>There's no empty shells to take!</span>")
		return FALSE
	if(alert(user, "Do you wish to become cogscarab?",,"Yes","No") == "Yes")
		if(cogscarab_list.len >= cog_slots) //Double check. No duplications
			to_chat(user, "<span class='notice'>There's no empty shells to take!</span>")
			return FALSE
		var/mob/living/silicon/robot/cogscarab/cog = new(loc)
		cog.key = user.key
		if(SSticker.mode.add_clocker(cog.mind))
			cog.create_log(CONVERSION_LOG, "[cog.mind] became clock drone")
		cog.fabr = src
		cogscarab_list += cog
		return TRUE
	return FALSE

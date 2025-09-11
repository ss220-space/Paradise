/obj/item/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/used = FALSE

/obj/item/antag_spawner/proc/spawn_antag(client/C, turf/T, type = "")
	return

/obj/item/antag_spawner/proc/equip_antag(mob/target)
	return

///////////BORGS AND OPERATIVES
/obj/item/antag_spawner/nuke_ops
	name = "syndicate operative teleporter"
	desc = "A single-use teleporter designed to quickly reinforce operatives in the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/borg_to_spawn
	var/checking = FALSE
	var/rolename = "Syndicate Operative"
	var/image/poll_icon
	var/poll_icon_file = 'icons/mob/simple_human.dmi'
	var/poll_icon_state = "syndicate_space_sword"

/obj/item/antag_spawner/nuke_ops/Initialize(mapload)
	. = ..()
	poll_icon = image(icon = poll_icon_file, icon_state = poll_icon_state)

/obj/item/antag_spawner/nuke_ops/proc/before_candidate_search(user)
	return TRUE

/obj/item/antag_spawner/nuke_ops/proc/check_usability(mob/user)
	if(used)
		to_chat(user, "<span class='warning'>[src] is out of power!</span>")
		return FALSE
	if(!(user.mind.has_antag_datum(/datum/antagonist/nuclear_operative)))
		to_chat(user, "<span class='danger'>AUTHENTICATION FAILURE. ACCESS DENIED.</span>")
		return FALSE
	if(checking)
		to_chat(user, "<span class='danger'>The device is already connecting to Syndicate command. Please wait.</span>")
		return FALSE
	return TRUE

/obj/item/antag_spawner/nuke_ops/attack_self(mob/user)
	if(!(check_usability(user)))
		return

	var/continue_proc = before_candidate_search(user)
	if(!continue_proc)
		return

	checking = TRUE

	to_chat(user, "<span class='notice'>You activate [src] and wait for confirmation.</span>")
	var/list/nuke_candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за [rolename]?", ROLE_OPERATIVE, TRUE, 15 SECONDS, source = poll_icon)
	if(LAZYLEN(nuke_candidates))
		checking = FALSE
		if(QDELETED(src) || !check_usability(user))
			return
		used = TRUE
		var/mob/dead/observer/G = pick(nuke_candidates)
		spawn_antag(G.client, get_turf(src), user.mind)
		do_sparks(4, TRUE, src)
		qdel(src)
	else
		checking = FALSE
		to_chat(user, "<span class='warning'>Unable to connect to Syndicate command. Please wait and try again later or use the teleporter on your uplink to get your points refunded.</span>")

/obj/item/antag_spawner/nuke_ops/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)

	M.key = C.key
	create_syndicate(M.mind)
	var/datum/antagonist/nuclear_operative/datum = M.mind.add_antag_datum(/datum/antagonist/nuclear_operative/reinf, /datum/team/nuclear_team)
	datum.equip()

//////SYNDICATE BORG
/obj/item/antag_spawner/nuke_ops/borg_tele
	name = "syndicate cyborg teleporter"
	desc = "A single-use teleporter designed to quickly reinforce operatives in the field."
	var/switch_roles = FALSE

/obj/item/antag_spawner/nuke_ops/borg_tele/assault
	name = "syndicate assault cyborg teleporter"
	borg_to_spawn = "Assault"
	rolename = "Syndicate Assault Cyborg"
	poll_icon_file = 'icons/mob/robots.dmi'
	poll_icon_state = "syndie-bloodhound-preview"

/obj/item/antag_spawner/nuke_ops/borg_tele/medical
	name = "syndicate medical teleporter"
	borg_to_spawn = "Medical"
	rolename = "Syndicate Medical Cyborg"
	poll_icon_file = 'icons/mob/robots.dmi'
	poll_icon_state = "syndi-medi"

/obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	name = "syndicate saboteur teleporter"
	borg_to_spawn = "Saboteur"
	rolename = "Syndicate Saboteur Cyborg"
	poll_icon_file = 'icons/mob/robots.dmi'
	poll_icon_state = "syndi-engi-preview"

#define SYNDICATE_CYBORG "Борг Синдиката"
#define NUCLEAR_OPERATIVE "Ядерный Оперативник"
#define CANCER_SWITCH_ROLES_CHOICE "Не активировать этот робот-телепортатор"

/obj/item/antag_spawner/nuke_ops/borg_tele/before_candidate_search(mob/user)
	var/switch_roles_choice = tgui_input_list(usr, "Вы хотите продолжить играть за оперативника или стать боргом? Если вы выберете борга, другой игрок займет ваше старое тело.", "Играть за", list(NUCLEAR_OPERATIVE, SYNDICATE_CYBORG, CANCER_SWITCH_ROLES_CHOICE))
	if(!switch_roles_choice || !(check_usability(user)) || switch_roles_choice == CANCER_SWITCH_ROLES_CHOICE)
		return FALSE

	if(switch_roles_choice == SYNDICATE_CYBORG)
		switch_roles = TRUE
		rolename = "Syndicate Operative"
	else
		switch_roles = FALSE

	return TRUE

#undef SYNDICATE_CYBORG
#undef NUCLEAR_OPERATIVE
#undef CANCER_SWITCH_ROLES_CHOICE

/obj/item/antag_spawner/nuke_ops/borg_tele/spawn_antag(client/C, turf/T, datum/mind/user)
	if(!(user.has_antag_datum(/datum/antagonist/nuclear_operative)))
		used = FALSE
		return

	var/mob/living/silicon/robot/R
	switch(borg_to_spawn)
		if("Medical")
			R = new /mob/living/silicon/robot/syndicate/medical(T)
		if("Saboteur")
			R = new /mob/living/silicon/robot/syndicate/saboteur(T)
		else
			R = new /mob/living/silicon/robot/syndicate(T) //Assault borg by default

	var/brainfirstname = pick(GLOB.first_names_male)
	var/brainopslastname = pick(GLOB.last_names)
	if(prob(50))
		brainfirstname = pick(GLOB.first_names_female)
		brainopslastname = pick(GLOB.last_names_female)

	var/datum/team/nuclear_team/team = GLOB.antagonist_teams[/datum/team/nuclear_team]
	if(team?.syndicate_name)  //the brain inside the syndiborg has the same last name as the other ops.
		brainopslastname = team.syndicate_name
	var/brainopsname = "[brainfirstname] [brainopslastname]"

	R.mmi.name = "[initial(R.mmi.name)]: [brainopsname]"
	R.mmi.brainmob.real_name = brainopsname
	R.mmi.brainmob.name = brainopsname

	if(!switch_roles)
		R.key = C.key
	else
		var/mob/living/L = user.current
		R.key = user.current.client.key
		L.key = C.key
	R.mind.add_antag_datum(/datum/antagonist/nuclear_operative/cyborg, /datum/team/nuclear_team)

///////////SLAUGHTER DEMON

/obj/item/antag_spawner/slaughter_demon //Warning edgiest item in the game
	name = "vial of blood"
	desc = "A magically infused bottle of blood, distilled from countless murder victims. Used in unholy rituals to attract horrifying creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"
	var/shatter_msg = "<span class='notice'>You shatter the bottle, no \
		turning back now!</span>"
	var/veil_msg = "<span class='warning'>You sense a dark presence lurking \
		just beyond the veil...</span>"
	var/objective_verb = "Kill"
	var/mob/living/demon_type = /mob/living/simple_animal/demon/slaughter

/obj/item/antag_spawner/slaughter_demon/attack_self(mob/user)
	if(level_blocks_magic(user.z)) //this is to make sure the wizard does NOT summon a demon from the Den..
		to_chat(user, "<span class='notice'>You should probably wait until you reach the station.</span>")
		return

	if(used)
		to_chat(user, "<span class='notice'>This bottle already has a broken seal.</span>")
		return
	used = TRUE
	to_chat(user, "<span class='notice'>You break the seal on the bottle, calling upon the dire spirits of the underworld...</span>")

	var/type = "slaughter"
	if(demon_type == /mob/living/simple_animal/demon/slaughter/laughter)
		type = "laughter"
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a [type] demon summoned by [user.real_name]?", ROLE_DEMON, TRUE, 10 SECONDS, source = demon_type)

	if(candidates.len > 0)
		var/mob/C = pick(candidates)
		spawn_antag(C, get_turf(src.loc), initial(demon_type.name), user)
		to_chat(user, "[shatter_msg]")
		to_chat(user, "[veil_msg]")
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, TRUE)
		qdel(src)
	else
		used = FALSE
		to_chat(user, "<span class='notice'>The demons do not respond to your summon. Perhaps you should try again later.</span>")


/obj/item/antag_spawner/slaughter_demon/spawn_antag(client/C, turf/T, type = "", mob/user)
	var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(T)
	var/mob/living/simple_animal/demon/demon = new demon_type(holder)
	demon.vialspawned = TRUE
	demon.holder = holder
	demon.key = C.key
	demon.mind.assigned_role = ROLE_DEMON
	demon.mind.special_role = SPECIAL_ROLE_DEMON
	SSticker.mode.demons |= demon.mind
	var/datum/objective/assassinate/KillDaWiz = new /datum/objective/assassinate
	KillDaWiz.owner = demon.mind
	KillDaWiz.target = user.mind
	KillDaWiz.explanation_text = "[objective_verb] [user.real_name], the one who was foolish enough to summon you."
	demon.mind.objectives += KillDaWiz
	var/datum/objective/KillDaCrew = new /datum/objective
	KillDaCrew.owner = demon.mind
	KillDaCrew.explanation_text = "[objective_verb] everyone else while you're at it."
	KillDaCrew.completed = TRUE
	demon.mind.objectives += KillDaCrew
	var/list/messages = demon.mind.prepare_announce_objectives()
	to_chat(demon, chat_box_red(messages.Join("<br>")))

/obj/item/antag_spawner/slaughter_demon/laughter
	name = "vial of tickles"
	desc = "A magically infused bottle of clown love, distilled from \
		countless hugging attacks. Used in funny rituals to attract \
		adorable creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vialtickles"
	veil_msg = "<span class='warning'>You sense an adorable presence \
		lurking just beyond the veil...</span>"
	objective_verb = "Hug and tickle"
	demon_type = /mob/living/simple_animal/demon/slaughter/laughter


/obj/item/antag_spawner/slaughter_demon/shadow
	name = "vial of shadow"
	desc = "A magically infused bottle of pure darkness, distilled from \
		ground up shadowling bones. Used in dark rituals to attract \
		dark creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vialshadows"
	veil_msg = "<span class='warning'>You sense a dark presence \
		lurking in the shadows...</span>"
	objective_verb = "Kill"
	demon_type = /mob/living/simple_animal/demon/shadow


///////////MORPH

/obj/item/antag_spawner/morph
	name = "vial of ooze"
	desc = "A magically infused bottle of ooze, distilled by methods rather not be spoken of. Used to awaken an all-consuming monstrosity."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vialooze"
	var/shatter_msg = "<span class='notice'>You shatter the bottle, no \
		turning back now!</span>"
	var/veil_msg = "<span class='warning'>The sludge is awake and seeps \
		away...</span>"
	var/objective_verb = "Eat"
	var/mob/living/morph_type = /mob/living/simple_animal/hostile/morph

/obj/item/antag_spawner/morph/attack_self(mob/user)
	if(level_blocks_magic(user.z))//this is to make sure the wizard does NOT summon a morph from the Den..
		to_chat(user, "<span class='notice'>You should probably wait until you reach the station.</span>")
		return

	if(used)
		to_chat(user, "<span class='notice'>This bottle already has a broken seal.</span>")
		return
	used = TRUE
	to_chat(user, "<span class='notice'>You break the seal on the bottle, calling upon the dire sludge to awaken...</span>")

	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a magical morph awakened by [user.real_name]?", ROLE_MORPH, 1, 10 SECONDS, source = morph_type)

	if(candidates.len > 0)
		var/mob/C = pick(candidates)
		spawn_antag(C, get_turf(src.loc), initial(morph_type.name), user)
		to_chat(user, "[shatter_msg]")
		to_chat(user, "[veil_msg]")
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, TRUE)
		qdel(src)
	else
		used = FALSE
		to_chat(user, "<span class='notice'>The sludge does not respond to your attempt to awake it. Perhaps you should try again later.</span>")

/obj/item/antag_spawner/morph/spawn_antag(client/C, turf/T, type = "", mob/user)
	var/mob/living/simple_animal/hostile/morph/wizard/M = new /mob/living/simple_animal/hostile/morph/wizard(pick(GLOB.xeno_spawn))
	M.key = C.key
	M.mind.assigned_role = SPECIAL_ROLE_MORPH
	M.mind.special_role = SPECIAL_ROLE_MORPH
	to_chat(M, M.playstyle_string)
	SSticker.mode.traitors += M.mind
	var/datum/objective/assassinate/KillDaWiz = new /datum/objective/assassinate
	KillDaWiz.owner = M.mind
	KillDaWiz.target = user.mind
	KillDaWiz.explanation_text = "[objective_verb] [user.real_name], the one who was foolish enough to awake you."
	M.mind.objectives += KillDaWiz
	var/datum/objective/KillDaCrew = new /datum/objective
	KillDaCrew.owner = M.mind
	KillDaCrew.explanation_text = "[objective_verb] everyone and everything else while you're at it."
	KillDaCrew.completed = TRUE
	M.mind.objectives += KillDaCrew
	var/list/messages = M.mind.prepare_announce_objectives()
	to_chat(M, chat_box_red(messages.Join("<br>")))
	SEND_SOUND(src, sound('sound/magic/mutate.ogg'))


///////////Pulse Demon

/obj/item/antag_spawner/pulse_demon
	name = "living lightbulb"
	desc = "A magically sealed lightbulb confining some manner of electricity based creature."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lbulb"
	var/shatter_msg = "<span class='notice'>You shatter the bulb, no turning back now!</span>"
	var/veil_msg = "<span class='warning'>The creature sparks energetically and zips away...</span>"
	var/objective_verb = "Electrocute"
	var/mob/living/demon_type = /mob/living/simple_animal/demon/pulse_demon

/obj/item/antag_spawner/pulse_demon/attack_self(mob/user)
	if(level_blocks_magic(user.z))
		to_chat(user, "<span class='notice'>You should probably wait until you reach the station.</span>")
		return

	var/turf/T = get_turf(src)
	var/obj/structure/cable/wire = locate() in T
	if(!wire || wire.avail() <= 0)
		to_chat(user, "<span class='warning'>This is not a suitable place, the creature would die here. Find a powered cable to release it onto.</span>")
		return

	if(used)
		to_chat(user, "<span class='notice'>This bulb already has a broken seal.</span>")
		return

	used = TRUE
	to_chat(user, "<span class='notice'>You break the seal on the bulb, waiting for the creature to spark to life...</span>")

	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a pulse demon summoned by [user.real_name]?", ROLE_DEMON, TRUE, 10 SECONDS, source = demon_type)

	if(!length(candidates))
		used = FALSE
		to_chat(user, "<span class='notice'>The creature does not come to life. Perhaps you should try again later.</span>")
		return

	var/mob/C = pick(candidates)
	spawn_antag(C, T, user)
	to_chat(user, shatter_msg)
	to_chat(user, veil_msg)
	playsound(T, 'sound/effects/glassbr1.ogg', 100, TRUE)
	qdel(src)

/obj/item/antag_spawner/pulse_demon/spawn_antag(client/C, turf/T, mob/user)
	var/datum/mind/player_mind = new /datum/mind(C.key)
	player_mind.active = TRUE

	var/mob/living/simple_animal/demon/pulse_demon/demon = new(T)
	player_mind.transfer_to(demon)
	player_mind.assigned_role = SPECIAL_ROLE_DEMON
	player_mind.special_role = SPECIAL_ROLE_DEMON

	var/datum/objective/assassinate/kill_wiz = new /datum/objective/assassinate
	kill_wiz.owner = demon.mind
	kill_wiz.target = user.mind
	kill_wiz.explanation_text = "[objective_verb] [user.real_name], the one who was foolish enough to free you."
	demon.mind.objectives += kill_wiz

	var/datum/objective/kill_crew = new /datum/objective
	kill_crew.owner = demon.mind
	kill_crew.explanation_text = "[objective_verb] everyone else while you're at it."
	kill_crew.completed = TRUE
	demon.mind.objectives += kill_crew

	var/list/messages = demon.mind.prepare_announce_objectives()
	to_chat(demon, chat_box_red(messages.Join("<br>")))

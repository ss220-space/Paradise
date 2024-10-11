/datum/affiliate/mi13
	name = AFFIL_MI13
	affil_info = list("Агенство специализирующееся на добыче и продаже секретной информации и разработок.",
					"Стандартные цели:",
					"Украсть секретные документы",
					"Украсть определенное количество ценных вещей",
					"Убить определенное количество членов экипажа",
					"Обменяться секретными документами с другим агентом",
					"Выглядеть стильно")
	tgui_icon = "mi13"
	slogan = "Да, я Бонд. Джеймс Бонд."
	normal_objectives = 2
	objectives = list(
//					/datum/objective/steal/documents,
//					list(/datum/objective/steal = 30, /datum/objective/maroon/blueshield = 70), // blueshield also has CQC.
					/datum/objective/maroon/agent,
					/datum/objective/maroon/agent,
					/datum/objective/steal,
					/datum/objective/escape
					)

/proc/is_MI13_agent(mob/living/user)
	var/datum/antagonist/traitor/traitor = user?.mind?.has_antag_datum(/datum/antagonist/traitor)
	return istype(traitor?.affiliate, /datum/affiliate/mi13)

/datum/affiliate/mi13/finalize_affiliate(datum/mind/owner)
	. = ..()
	var/datum/antagonist/traitor/traitor = owner.has_antag_datum(/datum/antagonist/traitor)
	traitor.assign_exchange_role(SSticker.mode.exchange_red)
	uplink.get_intelligence_data = TRUE
	add_discount_item(/datum/uplink_item/stealthy_weapons/cqc, 0.8)

/datum/affiliate/mi13/give_bonus_objectives(datum/mind/mind)
	var/datum/antagonist/traitor/traitor = mind?.has_antag_datum(/datum/antagonist/traitor)

	traitor.add_objective(/datum/objective/steal)
	traitor.add_objective(/datum/objective/steal)

/obj/item/storage/box/bond_bundle
	icon = 'icons/obj/affiliates.dmi'
	desc = "Невероятно стильная коробка."
	icon_state = "bond_bundle"

/obj/item/storage/box/bond_bundle/populate_contents()
	new /obj/item/clothing/glasses/hud/security/chameleon(src)
	new /obj/item/pen/fancy/bomb(src)
	new /obj/item/gun/projectile/automatic/pistol(src)
	new /obj/item/suppressor(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm/hp(src)
	new /obj/item/ammo_box/magazine/m10mm/ap(src)
	new /obj/item/ammo_box/magazine/m10mm/ap(src)
	new /obj/item/clothing/under/suit_jacket/really_black(src)
	new /obj/item/card/id/syndicate(src)
	new /obj/item/clothing/suit/storage/lawyer/blackjacket/armored(src)
	new /obj/item/encryptionkey/syndicate(src)
	new /obj/item/reagent_containers/food/drinks/drinkingglass/alliescocktail(src)
	new /obj/item/storage/box/syndie_kit/emp(src)
	new /obj/item/CQC_manual(src)

/obj/item/storage/box/bond_bundle/New()
	if(prob(5))
		icon_state = "joker"
		new /obj/item/toy/plushie/blahaj/twohanded(src)

	. = ..()

/obj/item/storage/box/cool_clothes_kit
	icon = 'icons/obj/affiliates.dmi'
	desc = "Невероятно стильная коробка."
	icon_state = "bond_bundle"

/obj/item/storage/box/cool_clothes_kit/populate_contents()
	new /obj/item/clothing/under/suit_jacket/bond(src)
	new /obj/item/clothing/suit/storage/lawyer/blackjacket/bond(src)
	new /obj/item/clothing/gloves/combat/bond(src)
	new /obj/item/clothing/shoes/laceup/bond(src)
	new /obj/item/clothing/glasses/sunglasses(src)

/obj/item/storage/box/cool_clothes_kit/New()
	if(prob(5))
		icon_state = "joker"
		new /obj/item/toy/plushie/blahaj/twohanded(src)

	. = ..()

/obj/item/clothing/under/suit_jacket/bond
	armor = list(melee = 10, bullet = 20, laser = 10, energy = 10, bomb = 10, bio = 0, rad = 0, fire = 30, acid = 0)

/obj/item/clothing/gloves/combat/bond
	name = "black gloves"
	desc = "These gloves are fire-resistant."
	icon_state = "black"
	item_state = "bgloves"
	item_color = "black"
	armor = list(melee = 25, bullet = 25, laser = 15, energy = 15, bomb = 25, bio = 0, rad = 0, fire = 30, acid = 60)

/obj/item/clothing/suit/storage/lawyer/blackjacket/bond
	desc = "Стильная куртка, усиленная слоем брони, защищающим туловище."
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/gun/projectile/revolver, /obj/item/gun/projectile/automatic/pistol, /obj/item/twohanded/garrote, /obj/item/gun/projectile/automatic/toy/pistol/riot, /obj/item/gun/syringe/syndicate)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	armor = list(melee = 25, bullet = 25, laser = 15, energy = 15, bomb = 25, bio = 0, rad = 0, fire = 30, acid = 60)

/obj/item/clothing/shoes/laceup/bond
	armor = list(melee = 25, bullet = 25, laser = 15, energy = 15, bomb = 25, bio = 0, rad = 0, fire = 30, acid = 60)


/obj/item/paper/agent_info
	name = "Agent information"
	info = ""
	var/content

/obj/item/paper/agent_info/proc/choose_agent(mob/user)
	. = TRUE
	var/list/crew
	for (var/mob/living/carbon/human/H in GLOB.mob_list)
		if (H.mind.assigned_role)
			crew[H.mind.original_mob_name] = H

	var/choise = input(src, "О каком агенте написано в отчете?","Выбор агента",null) as null|anything in crew

	if (!choise)
		return FALSE

	var/mob/living/carbon/human/target = crew[choise]

	if (!target)
		to_chat(user, span_warning("Цель больше не существует."))
		return FALSE

	var/datum/antagonist/traitor/traitor = target?.mind?.has_antag_datum(/datum/antagonist/traitor)
	var/datum/antagonist/vampire/vampire = target?.mind?.has_antag_datum(/datum/antagonist/vampire)
	var/datum/antagonist/changeling/changeling = target?.mind?.has_antag_datum(/datum/antagonist/changeling)
	var/datum/antagonist/thief/thief = target?.mind?.has_antag_datum(/datum/antagonist/thief)

	if(!traitor && !vampire && !changeling)
		info = "Согласно последним разведданным, " + choise + " не имеет никаких прямых связей с синдикатом."
		return

	if(traitor)
		info += choise + " является агентом " + (traitor?.affiliate ? "нанятым " + traitor?.affiliate.name : "с неизвестным нанимателем") + ".<br>"
		info += "Назначеные " + (target.gender == FEMALE ? "ей " : "ему ") + "нанимателем цели следующие:"
		var/obj_num = 1
		for(var/datum/objective/objective in traitor.objectives)
			info += "<B>Objective #[obj_num]</B>: [objective.explanation_text]<br>"
			obj_num++

		var/TC_uses = 0
		var/used_uplink = FALSE
		var/purchases = ""
		for(var/obj/item/uplink/uplink in GLOB.world_uplinks)
			if(uplink?.uplink_owner && uplink.uplink_owner == target.mind.key)
				TC_uses += uplink.used_TC
				purchases += uplink.purchase_log
				used_uplink = TRUE

		if(used_uplink)
			text += " (использовал" + ((target.gender == FEMALE ? "a " : " ")) + "[TC_uses] TC) [purchases]<br>"

	if(vampire)
		info += choise + " обладает способностями " + (vampire.isAscended() ? "высшего " : "") + "вампира " + (vampire.subclass ? "подкласса \"" + vampire.subclass.name + "\"" : "без подкласса") + ".<br>"

	if(changeling)
		info += choise + " обладает способностями генокрада.<br>"

	if(thief)
		info += choise + " является членом гильдии воров.<br>"

/obj/item/paper/agent_info/examine(mob/user)
	if (!is_MI13_agent(user))
		to_chat(user, span_warning("Вы не можете разобрать содержимое."))
		return

	if (info)
		return ..()

	if(user.is_literate())
		if(in_range(user, src) || istype(user, /mob/dead/observer))
			if (choose_agent(user))
				show_content(user)
		else
			. += span_notice("Вам нужно подойти поближе, чтобы прочитать то что здесь написано.")
	else
		. += span_notice("Вы не умеете читать.")

/obj/item/pen/intel_data/proc/upgrade(obj/item/uplink/U)
	if(!istype(U) || QDELETED(U))
		return

	if(U.get_intelligence_data)
		usr.balloon_alert(usr, "Уже улучшено")
		return ATTACK_CHAIN_PROCEED

	usr.balloon_alert(usr, "Улучшено")
	playsound(src, "sound/machines/boop.ogg", 50, TRUE)
	U.get_intelligence_data = TRUE
	SStgui.update_uis(U)
	qdel(src)

/obj/item/pen/intel_data/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(target != user)
		return

	for(var/obj/item/implant/uplink/uplink_imp in user)
		if(uplink_imp.imp_in != user)
			continue

		to_chat(user, span_notice("You press [src] onto yourself and upgraded [uplink_imp.hidden_uplink]."))
		upgrade(uplink_imp.hidden_uplink)
		return ATTACK_CHAIN_BLOCKED_ALL

/obj/item/pen/intel_data/afterattack(obj/item/I, mob/user, proximity, params)
	if(!proximity)
		return

	if(istype(I) && I.hidden_uplink && I.hidden_uplink.active) //No metagaming by using this on every PDA around just to see if it gets used up.
		upgrade(I.hidden_uplink)

/obj/item/clothing/gloves/ring/gadget
	origin_tech = "magnets=3;combat=3;syndicate=2"
	var/changing = FALSE
	var/op_time = 2 SECONDS
	var/op_time_upgaded = 1 SECONDS
	var/op_cd_time = 5 SECONDS
	var/op_cd_time_upgaded = 3 SECONDS
	var/breaking = FALSE
	COOLDOWN_DECLARE(operation_cooldown)
	var/old_mclick_override

/obj/item/clothing/gloves/ring/gadget/attack_self(mob/user)
	. = ..()

	if(changing)
		user.balloon_alert(user, "Подождите")
		return

	changing = TRUE

	var/list/choices // only types that we can meet in the game

	if(!stud)
		choices = list(
			"iron" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "ironring"),
			"silver" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "silverring"),
			"gold" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "goldring"),
			"plasma" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "plasmaring"),
			"uranium" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "uraniumring")
		)
	else
		choices = list(
			"iron" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "d_ironring"),
			"silver" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "d_silverring"),
			"gold" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "d_goldring"),
			"plasma" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "d_plasmaring"),
			"uranium" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "d_uraniumring")
		)

	var/selected_chameleon = show_radial_menu(usr, loc, choices, require_near = TRUE)
	switch(selected_chameleon)
		if("iron")
			name =  "iron ring"
			icon_state = "ironring"
			material = "iron"
			ring_color = "iron"
		if("silver")
			name =  "silver ring"
			icon_state = "silverring"
			material = "silver"
			ring_color = "silver"
		if("gold")
			name =  "gold ring"
			icon_state = "goldring"
			material = "gold"
			ring_color = "gold"
		if("plasma")
			name = "plasma ring"
			icon_state = "plasmaring"
			material = "plasma"
			ring_color = "plasma"
		if("uranium")
			name = "uranium ring"
			icon_state = "uraniumring"
			material = "uranium"
			ring_color = "uranium"
		else
			changing = FALSE
			return

	usr.visible_message(span_warning("[usr] changes the look of his ring!"), span_notice("[selected_chameleon] selected."))
	playsound(loc, 'sound/items/screwdriver2.ogg', 50, 1)
	to_chat(usr, span_notice("Смена маскировки..."))
	update_icon(UPDATE_ICON_STATE)
	changing = FALSE

/obj/item/clothing/gloves/ring/gadget/Touch(atom/A, proximity)
	. = FALSE
	var/mob/living/carbon/human/user = loc

	if(user.a_intent != INTENT_DISARM)
		return

	if(get_dist(user, A) > 1)
		return

	if(user.incapacitated())
		return

	var/obj/item/clothing/gloves/ring/gadget/ring = user.gloves

	if(ring.breaking)
		return

	if(!istype(A, /obj/structure/window))
		return

	if(!COOLDOWN_FINISHED(ring, operation_cooldown))
		user.balloon_alert(user, "Идет перезарядка")
		return

	ring.breaking = TRUE
	if(do_after(user, ring.stud ? ring.op_time_upgaded : ring.op_time))
		COOLDOWN_START(ring, operation_cooldown, ring.stud ? ring.op_cd_time_upgaded : ring.op_cd_time)

		ring.visible_message(span_warning("BANG"))
		playsound(ring, 'sound/effects/bang.ogg', 100, TRUE)

		for (var/mob/living/M in range(A, 3))
			if(M.check_ear_prot() == HEARING_PROTECTION_NONE)
				M.Deaf(6 SECONDS)

		for (var/obj/structure/grille/grille in A.loc)
			grille.obj_break()

		for (var/obj/structure/window/window in range(A, 2))
			window.take_damage(window.max_integrity * rand(20, 60) / 100)

		var/obj/structure/window/window = A
		window.deconstruct()
		ring.breaking = FALSE
		return TRUE

	ring.breaking = FALSE

/obj/machinery/camera/emp_proof/mi13
	network = list("MI13")
	use_power = NO_POWER_USE

/obj/item/spy_bug
	name = "spy bug"
	desc = "Миниатюрное устройство с камерой и микрофоном. На обратной стороне можно заметить миниатюрную гравировку \"MI13\""
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "spy_bug"
	item_state = "nothing"
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_EARS
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=30, MAT_GLASS=20)
	var/list/network = list("MI13")
	var/c_tag
	var/obj/machinery/camera/emp_proof/mi13/camera

/obj/item/spy_bug/Initialize(mapload, list/network = list("MI13"), c_tag)
	. = ..()
	src.network = network
	if (c_tag)
		src.c_tag = pick("Альфа", "Бета", "Гамма", "Дельта") + " [rand(111111, 999999)]"
	else
		src.c_tag = c_tag

	name = "spy bug \"" + c_tag + "\""
	camera = new(src, network, c_tag)

/obj/item/spy_bug/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim)
	return ATTACK_CHAIN_BLOCKED

/obj/item/spy_bug/afterattack(atom/target, mob/user, proximity, params, status)
	. = ..()

	if (istype(target, /obj/item/camera_bug/spy_monitor))
		var/obj/item/camera_bug/spy_monitor/monitor = target
		network = monitor.network
		user.balloon_alert(user, "Подключено")
		return

	if (do_after(user, 3 SECONDS, target, max_interact_count = 1))
		hook(user, target)

/obj/item/spy_bug/proc/unhook(mob/user)
	qdel(loc.GetComponent(/datum/component/spy_bug))
	forceMove(get_turf(loc))

	if (user)
		to_chat(user, span_notice("You unhooked [src]."))
	else
		loc.visible_message(span_warning("[src] falls off the [loc]."))

/obj/item/spy_bug/proc/hook(mob/user, atom/I)
	if (!I)
		return

	if (!user.drop_transfer_item_to_loc(src, I))
		return

	I.AddComponent(/datum/component/spy_bug)
	to_chat(user, span_notice("You have silently attached [src] on [I]."))

/obj/item/spy_bug/strip_action(mob/user, mob/living/carbon/human/owner, atom/I)
	if (!I)
		return FALSE

	if (do_after(user, 3 SECONDS, I, max_interact_count = 1))
		hook(user, I)

	return TRUE

/obj/item/spy_bug/emp_act(severity)
	. = ..()
	do_sparks(3, TRUE, src.loc)
	unhook()

/obj/item/spy_bug/attack_self(mob/user)
	. = ..()
	var/new_name = tgui_input_text(src, "Назовите жучок.", "Смена имени", name)
	if (new_name)
		name = "spy bug \"" + new_name + "\""
		qdel(camera)
		c_tag = new_name
		camera = new(src, network, c_tag)

/datum/component/spy_bug
	var/obj/item/spy_bug/bug

/datum/component/spy_bug/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(on_altclick))
	RegisterSignal(parent, COMSIG_PREQDELETED, PROC_REF(deleted_handler))

/datum/component/spy_bug/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(parent, COMSIG_CLICK_ALT)
	RegisterSignal(parent, COMSIG_PREQDELETED)

/datum/component/spy_bug/_JoinParent()
	. = ..()
	var/atom/par = parent
	for (var/obj/item/spy_bug/spy_bug in par.contents)
		bug = spy_bug

/datum/component/spy_bug/proc/on_examine(datum/source, mob/living/carbon/human/user, list/examine_list)
	SIGNAL_HANDLER

	if(!istype(user))
		return

	if(!isstack(parent))
		examine_list += "Вы видите небольшое устройство с микрофоном и камерой."

/datum/component/spy_bug/proc/on_altclick(datum/source, mob/living/carbon/human/user)
	SIGNAL_HANDLER

	if(!istype(user))
		return

	INVOKE_ASYNC(bug, TYPE_PROC_REF(/datum/component/spy_bug, try_unhook), list(user, source))

/datum/component/spy_bug/proc/try_unhook(mob/user, obj/item/I)
	if(do_after(user, 1 SECONDS, I))
		bug.unhook(user)

/datum/component/spy_bug/proc/deleted_handler()
	bug.unhook()

/obj/item/camera_bug/spy_monitor
	name = "spy monitor"
	desc = ""
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "spy_monitor"
	item_state	= "qm_tablet"
	integrated_console_type = /obj/machinery/computer/security/camera_bug
	var/list/network = list("MI13")

/obj/item/camera_bug/spy_monitor/Initialize(mapload, list/network)
	. = ..()

	if (network)
		src.network = network

/obj/item/storage/box/syndie_kit/spy_bugs_kit

/obj/item/storage/box/syndie_kit/spy_bugs_kit/populate_contents()
	var/network = "MI13_[rand(111111, 999999)]"
	new /obj/item/camera_bug/spy_monitor(src, list(network))
	new /obj/item/spy_bug(src, list(network), "1")
	new /obj/item/spy_bug(src, list(network), "2")
	new /obj/item/spy_bug(src, list(network), "3")
	new /obj/item/spy_bug(src, list(network), "4")
	new /obj/item/spy_bug(src, list(network), "5")

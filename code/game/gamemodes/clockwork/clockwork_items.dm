// A Clockwork slab. Ratvar's tool to cast most of essential spells.
/obj/item/clockwork/clockslab
	name = "clockwork slab"
	desc = "Странная металлическая плита. Часы в центре тикают и шагают."
	icon = 'icons/obj/clockwork.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "clock_slab"
	w_class = WEIGHT_CLASS_SMALL
	var/list/plush_colors = list("red fox plushie" = "redfox", "black fox plushie" = "blackfox", "blue fox plushie" = "bluefox",
								"orange fox plushie" = "orangefox", "corgi plushie" = "corgi", "black cat plushie" = "blackcat",
								"deer plushie" = "deer", "octopus plushie" = "loveable", "facehugger plushie" = "huggable")
	var/plushy


/obj/item/clockwork/clockslab/Initialize(mapload)
	. = ..()
	enchants = GLOB.clockslab_spells


/obj/item/clockwork/clockslab/update_name(updates = ALL)
	. = ..()
	name = plushy ? plushy : initial(name)


/obj/item/clockwork/clockslab/update_desc(updates = ALL)
	. = ..()
	desc = plushy ? "An adorable, soft, and cuddly plushie." : initial(desc)


/obj/item/clockwork/clockslab/update_icon_state()
	icon = plushy ? 'icons/obj/toy.dmi' : 'icons/obj/clockwork.dmi'
	icon_state = plushy ? plush_colors[plushy] : initial(icon_state)


/obj/item/clockwork/clockslab/update_overlays()
	. = ..()
	if(enchant_type)
		. += "clock_slab_overlay_[enchant_type]"


/obj/item/clockwork/clockslab/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.) && plushy)
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 20, TRUE)	// Play the whoosh sound in local area


/obj/item/clockwork/clockslab/attack_self_tk(mob/user)
	return

/obj/item/clockwork/clockslab/attack_self(mob/user)
	. = ..()
	if(plushy)
		var/cuddle_verb = pick("hugs","cuddles","snugs")
		user.visible_message(span_notice("[user] [cuddle_verb] the [src]."))
		playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		if(!isclocker(user))
			return
		if(alert(user, "Do you want to reveal clockwork slab?","Revealing!","Yes","No") != "Yes")
			return
		attack_verb = null
		deplete_spell()
		plushy = null
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)

	if(!isclocker(user))
		to_chat(user, span_clocklarge("\"Это для моих слуг, не для тебя\""))
		if(iscarbon(user))
			var/mob/living/carbon/carbon = user
			carbon.Knockdown(10 SECONDS)
			carbon.Stuttering(20 SECONDS)
		return

	if(enchant_type == HIDE_SPELL)
		to_chat(user, span_notice("Ты замаскировал заводную плиту под некую маленькую игрушку."))
		playsound(user, 'sound/magic/cult_spell.ogg', 15, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		plushy = pick(plush_colors)
		attack_verb = list("тыкнул", "ударил", "шлёпнул")
		enchant_type = CASTING_SPELL
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)

	if(enchant_type == TELEPORT_SPELL)
		var/list/possible_altars = list()
		var/list/altars = list()
		var/list/duplicates = list()
		for(var/obj/structure/clockwork/functional/altar/altar as anything in GLOB.clockwork_altars)
			if(!altar.anchored)
				continue
			var/result_name = altar.locname
			if(result_name in altars)
				duplicates[result_name]++
				result_name = "[result_name] ([duplicates[result_name]])"
			else
				altars.Add(result_name)
				duplicates[result_name] = 1
			if(is_mining_level(altar.z))
				result_name += ", Lava"
			else if(!is_station_level(altar.z))
				result_name += ", [altar.z] [dir2text(get_dir(user,get_turf(altar)))] sector"
			possible_altars[result_name] = altar
		if(!length(possible_altars))
			to_chat(user, span_warning("Нет алтарей на которые можно телепорироваться"))
			return
		if(!is_level_reachable(user.z))
			to_chat(user, span_warning("Ты не в том измерении из которого можно телепортироваться!"))
			return

		var/selected_altar = tgui_input_list(user, "Pick a credence teleport to...", "Teleporation", possible_altars)
		if(!selected_altar)
			return
		var/turf/destination = possible_altars[selected_altar]
		to_chat(user, span_notice("Ты начинаешь кастовать заклинание телепортации..."))
		animate(user, color = COLOR_PURPLE, time = 1.5 SECONDS)
		if(do_after(user, 1.5 SECONDS, user) && destination)
			do_sparks(4, 0, user)
			user.forceMove(get_turf(destination))
			playsound(user, 'sound/effects/phasein.ogg', 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			add_attack_logs(user, destination, "Teleported to by [src]", ATKLOG_ALL)
			deplete_spell()
		user.color = null

/obj/item/clockwork/clockslab/afterattack(atom/target, mob/living/user, proximity, params)
	. = ..()
	if(!isclocker(user))
		if(plushy)
			return
		user.drop_item_ground(src, force = TRUE)
		user.emote("scream")
		to_chat(user, span_clocklarge("\"Это для моих слуг, не для тебя\""))
		if(iscarbon(user))
			var/mob/living/carbon/carbon = user
			carbon.Knockdown(10 SECONDS)
			carbon.Stuttering(20 SECONDS)
		return
	switch(enchant_type)
		if(STUN_SPELL)
			if(!isliving(target) || isclocker(target) || !proximity)
				return
			var/mob/living/living = target
			visible_message(span_warning("[src] [user.p_they()] на мгновение искрится ярким светом!"))
			user.mob_light(LIGHT_COLOR_HOLY_MAGIC, 3, _duration = 2) //No questions
			if(living.null_rod_check())
				visible_message(span_warning("[target] еретика поглощает праведный свет!"))
				deplete_spell()
				return
			living.Knockdown(3 SECONDS)
			living.apply_damage(30, STAMINA)
			living.apply_status_effect(STATUS_EFFECT_STAMINADOT)
			living.flash_eyes(1, TRUE)
			if(isrobot(living))
				var/mob/living/silicon/robot/robot = living
				robot.emp_act(EMP_HEAVY)
			else if(iscarbon(target))
				var/mob/living/carbon/carbon = living
				carbon.Silence(10 SECONDS)
				carbon.Stuttering(16 SECONDS)
				carbon.ClockSlur(20 SECONDS)
				carbon.Jitter(16 SECONDS)
			add_attack_logs(user, target, "Stunned by [src]")
			deplete_spell()
		if(KNOCK_SPELL)
			if(!proximity) //magical key only works if you're close enough
				return
			if(istype(target, /obj/machinery/door))
				var/obj/machinery/door/door = target
				if(istype(door, /obj/machinery/door/airlock/hatch/gamma))
					return
				if(istype(door, /obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/A = door
					A.unlock(TRUE)	//forced because it's magic!
				playsound(get_turf(usr), 'sound/magic/knock.ogg', 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				door.open()
				deplete_spell()
			else if(istype(target, /obj/structure/closet))
				var/obj/structure/closet/closet = target
				if(istype(closet, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = closet
					SC.locked = FALSE
				playsound(get_turf(usr), 'sound/magic/knock.ogg', 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				closet.open()
				deplete_spell()
			else
				to_chat(user, span_warning("Ты можешь использовать зачарование Стука только на шлюзах и закрытых шкафах!"))
		if(TELEPORT_SPELL)
			if(target.density && !proximity)
				to_chat(user, span_warning("Путь преграждён!"))
				return
			if(proximity)
				to_chat(user, span_warning("Ты слишком близко к конечной точке телепорта!"))
				return
			if(!(target in view(user)))
				return
			to_chat(user, span_notice("Ты начинаешь кастовать заклинание телепортации..."))
			animate(user, color = COLOR_PURPLE, time = 1.5 SECONDS)
			if(do_after(user, 1.5 SECONDS, user))
				do_sparks(4, FALSE, user)
				user.forceMove(get_turf(target))
				playsound(user, 'sound/effects/phasein.ogg', 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				add_attack_logs(user, target, "Teleported to by [src]", ATKLOG_ALL)
				deplete_spell()
			user.color = null
		if(HEAL_SPELL)
			if(!isliving(target) || !isclocker(target) || !proximity)
				return
			var/mob/living/living = target
			if(ishuman(living))
				living.heal_overall_damage(30, 30, affect_robotic = TRUE)
			else if(isanimal(living))
				var/mob/living/simple_animal/M = living
				if(M.health < M.maxHealth)
					M.adjustHealth(-50)
			add_attack_logs(user, target, "clockslab healed", ATKLOG_ALL)
			deplete_spell()


/obj/item/clockwork
	name = "clockwork item name"
	icon = 'icons/obj/clockwork.dmi'
	resistance_flags = FIRE_PROOF | ACID_PROOF

//Ratvarian spear
/obj/item/twohanded/ratvarian_spear
	name = "ratvarian spear"
	desc = "Бритвенно-острое копьё из латуни. Оно пульсирует едва сдерживаемой энергией."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "ratvarian_spear0"
	slot_flags = ITEM_SLOT_BACK
	force = 10
	force_unwielded = 10
	force_wielded = 20
	throwforce = 35
	armour_penetration = 40
	sharp = TRUE
	embed_chance = 70
	embedded_ignore_throwspeed_threshold = TRUE
	attack_verb = list("уколол", "ткнул", "полоснул")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_HUGE
	needs_permit = TRUE

/obj/item/twohanded/ratvarian_spear/Initialize(mapload)
	. = ..()
	enchants = GLOB.spear_spells

/obj/item/twohanded/ratvarian_spear/update_icon_state()
	icon_state = "ratvarian_spear[HAS_TRAIT(src, TRAIT_WIELDED)]"

/obj/item/twohanded/ratvarian_spear/update_overlays()
	. = ..()
	if(enchant_type)
		. += "ratvarian_spear0_overlay_[enchant_type]"

/obj/item/twohanded/ratvarian_spear/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()
	var/mob/living/living = hit_atom
	if(isclocker(living))
		if(ishuman(living) && living.put_in_active_hand(src))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
<<<<<<< Updated upstream
			living.visible_message(span_warning("[living] ловит [src] прямо из воздуха!"))
=======
			living.visible_message(span_warning("[living] ловит [src] прямо на лету!"))
>>>>>>> Stashed changes
		else
			do_sparks(5, TRUE, living)
			living.visible_message(span_warning("[src] отскакивает от [living], как будто бы отталкиваясь невидимой силой!"))
		return
	. = ..()


/obj/item/twohanded/ratvarian_spear/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!isclocker(user))
		user.emote("scream")
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			human.embed_item_inside(src)
<<<<<<< Updated upstream
			to_chat(user, span_clocklarge("\"И каково тебе чувствовать это?\""))
=======
			to_chat(user, span_clocklarge("\"Каково это – чувствовать такое?\""))
>>>>>>> Stashed changes
		else
			user.drop_item_ground(src, force = TRUE)
			to_chat(user, span_clocklarge("\"Это для моих слуг, не для тебя\""))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/twohanded/ratvarian_spear/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity || !wielded || !isliving(target))
		return
	if(isclocker(target))
		return

	switch(enchant_type)
		if(CONFUSE_SPELL)
			if(!iscarbon(target))
				return
			var/mob/living/carbon/carbon = target
			if(carbon.mind?.isholy)
				to_chat(carbon, span_danger("Ты чувствуешь, как чужие мысли пытаются проникнуть в ваш разум..."))
				deplete_spell()
				return
			carbon.AdjustConfused(30 SECONDS)
			to_chat(carbon, span_danger("Твой разум на мгновение отключается!"))
			add_attack_logs(user, carbon, "Inflicted confusion with [src]")
			deplete_spell()
		if(DISABLE_SPELL)
			new /obj/effect/temp_visual/emp/clock(get_turf(src))
			if(issilicon(target))
				var/mob/living/silicon/S = target
				S.emp_act(EMP_LIGHT)
			else
				target.emp_act(EMP_HEAVY)
			add_attack_logs(user, target, "Point-EMP with [src]")
			deplete_spell()

/obj/item/twohanded/ratvarian_spear/pickup(mob/living/user)
	. = ..()
	if(!isclocker(user))
		to_chat(user, span_clocklarge("\"Я бы не советовал этого делать.\""))
		to_chat(user, span_warning("Вас одолевает непреодолимое чувство тошноты!"))
		user.Confused(20 SECONDS)
		user.Jitter(12 SECONDS)

//Ratvarian borg spear
/obj/item/clock_borg_spear
	name = "ratvarian spear"
	desc = "Бритвенно-острое копьё из латуни. Оно пульсирует едва сдерживаемой энергией."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "ratvarian_spear0"
	force = 20
	armour_penetration = 30
	sharp = TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/clock_borg_spear/Initialize(mapload)
	. = ..()
	enchants = GLOB.spear_spells

/obj/item/clock_borg_spear/update_overlays()
	. = ..()
	if(enchant_type)
		. += "ratvarian_spear0_overlay_[enchant_type]"

/obj/item/clock_borg_spear/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity || !isliving(target))
		return
	if(isclocker(target))
		return

	switch(enchant_type)
		if(CONFUSE_SPELL)
			if(!iscarbon(target))
				return
			var/mob/living/carbon/carbon = target
			if(carbon.mind?.isholy)
				to_chat(carbon,  span_danger("Ты чувствуешь, как чужие мысли пытаются проникнуть в твой разум..."))
				deplete_spell()
				return
			carbon.AdjustConfused(30 SECONDS)
			to_chat(carbon, span_danger("Твой разум на мгновение отключается!"))
			add_attack_logs(user, carbon, "Inflicted confusion with [src]")
			deplete_spell()
		if(DISABLE_SPELL)
			new /obj/effect/temp_visual/emp/clock(get_turf(src))
			if(issilicon(target))
				var/mob/living/silicon/S = target
				S.emp_act(EMP_LIGHT)
			else
				target.emp_act(EMP_HEAVY)
			add_attack_logs(user, target, "Point-EMP with [src]")
			deplete_spell()

//Clock hammer
/obj/item/twohanded/clock_hammer
	name = "hammer clock"
	desc = "Тяжёлая кувалда древнего бога. Используется, чтобы блистать, как в былые времена."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clock_hammer0"
	slot_flags = ITEM_SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 20
	armour_penetration = 40
	throwforce = 30
	throw_range = 7
	w_class = WEIGHT_CLASS_HUGE
	needs_permit = TRUE

/obj/item/twohanded/clock_hammer/Initialize(mapload)
	. = ..()
	enchants = GLOB.hammer_spells

/obj/item/twohanded/clock_hammer/update_icon_state()
	icon_state = "clock_hammer[HAS_TRAIT(src, TRAIT_WIELDED)]"

/obj/item/twohanded/clock_hammer/update_overlays()
	. = ..()
	if(enchant_type)
		. += "clock_hammer0_overlay_[enchant_type]"

/obj/item/twohanded/clock_hammer/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()
	var/mob/living/living = hit_atom
	if(isclocker(living))
		if(ishuman(living) && living.put_in_active_hand(src))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
<<<<<<< Updated upstream
			living.visible_message(span_warning("[living] ловит [src] прямо из воздуха!"))
=======
			living.visible_message(span_warning("[living] ловит [src] прямо на лету!"))
>>>>>>> Stashed changes
		else
			do_sparks(5, TRUE, living)
			living.visible_message(span_warning("[src] отскакивает от [living], как будто бы отталкиваясь невидимой силой!"))
		return
	. = ..()


/obj/item/twohanded/clock_hammer/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!isclocker(user))
		user.Knockdown(10 SECONDS)
		user.drop_item_ground(src, force = TRUE)
		user.emote("scream")
		user.visible_message(
			span_warning("Мощная сила отбрасывает [user] от [target]!"),
			span_clocklarge("\"Не бей себя.\""),
		)
		user.apply_damage(rand(force_unwielded, force_wielded), BRUTE, BODY_ZONE_HEAD)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/twohanded/clock_hammer/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity || !wielded || !isliving(target))
		return
	if(isclocker(target))
		return
	var/mob/living/living = target
	switch(enchant_type)
		if(KNOCKOFF_SPELL)
			var/atom/throw_target = get_edge_target_turf(living, user.dir)
			living.throw_at(throw_target, 200, 20, user) // vroom
			add_attack_logs(user, target, "Knocked-off with [src]")
			deplete_spell()
		if(CRUSH_SPELL)
			if(ishuman(living))
				var/mob/living/carbon/human/human = living
				var/obj/item/rod = human.null_rod_check()
				if(rod)
					human.visible_message(span_danger("[rod] [human.p_their()] сияет, отражая магию [user]!"))
					deplete_spell()
					return
				var/obj/item/organ/external/BP = pick(human.bodyparts)
				BP.emp_act(EMP_HEAVY)
				BP.fracture()
			if(isanimal(living))
				var/mob/living/simple_animal/animal = living
				animal.adjustBruteLoss(force/2)
				animal.emp_act(EMP_LIGHT)
			if(isrobot(living))
				var/mob/living/silicon/robot/robot = living
				var/datum/robot_component/RC = robot.components[pick(robot.components)]
				RC.destroy()
			add_attack_logs(user, target, "Crushed with [src]")
			deplete_spell()

/obj/item/twohanded/clock_hammer/pickup(mob/living/user)
	. = ..()
	if(!isclocker(user))
		to_chat(user, span_clocklarge("\"Я бы не советовал этого делать.\""))
		to_chat(user, span_warning("Вас одолевает непреодолимое чувство тошноты!"))
		user.Confused(20 SECONDS)
		user.Jitter(12 SECONDS)

//Clock sword
/obj/item/melee/clock_sword
	name = "rustless sword"
	desc = "Простой меч, едва пригодный для боя, но всё же содержащий \"порох в пороховницах\"."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clock_sword"
	item_state = "clock_sword"
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 20
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration = 10
	sharp = TRUE
	attack_verb = list("полоснул", "уколол")
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/swordsman = FALSE

/obj/item/melee/clock_sword/Initialize(mapload)
	. = ..()
	enchants = GLOB.sword_spells

/obj/item/melee/clock_sword/update_overlays()
	. = ..()
	if(enchant_type)
		. += "clock_sword_overlay_[enchant_type]"

/obj/item/melee/clock_sword/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()
	var/mob/living/living = hit_atom
	if(isclocker(living))
		if(ishuman(living) && living.put_in_active_hand(src))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
<<<<<<< Updated upstream
			living.visible_message(span_warning("[living] ловит [src] прямо из воздуха!"))
=======
			living.visible_message(span_warning("[living] ловит [src] прямо на лету!"))
>>>>>>> Stashed changes
		else
			do_sparks(5, TRUE, living)
			living.visible_message(span_warning("[src] отскакивает от [living], как будто бы отталкиваясь невидимой силой!"))
		return
	. = ..()

/obj/item/melee/clock_sword/attack_self(mob/user)
	. = ..()
	if(!isclocker(user))
		user.drop_item_ground(src)
		user.emote("scream")
		to_chat(user, span_clocklarge("\"Это для моих слуг, не для тебя\""))
		return
	if(enchant_type == FASTSWORD_SPELL && src == user.get_active_hand())
		ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(FASTSWORD_SPELL))
		enchant_type = CASTING_SPELL
		force = 7
		swordsman = TRUE
		add_attack_logs(user, user, "Sworded [src]", ATKLOG_ALL)
<<<<<<< Updated upstream
		to_chat(user, span_danger("The blood inside your veind flows quickly, as you try to sharp someone by any means!"))
=======
		to_chat(user, span_danger("Кровь в твоих жилах бурлит, когда ты пытаешься поразить кого угодно любыми средствами!"))
>>>>>>> Stashed changes
		addtimer(CALLBACK(src, PROC_REF(reset_swordsman), user), 9 SECONDS)

/obj/item/melee/clock_sword/proc/reset_swordsman(mob/user)
	to_chat(user, span_notice("Хватка над [src] слабеет..."))
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(FASTSWORD_SPELL))
	force = initial(force)
	swordsman = FALSE
	deplete_spell()


/obj/item/melee/clock_sword/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!isclocker(user))
		user.emote("scream")
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			human.embed_item_inside(src)
<<<<<<< Updated upstream
			to_chat(user, span_clocklarge("\"И каково тебе чувствовать это?\""))
=======
			to_chat(user, span_clocklarge("\"Каково это – чувствовать такое?\""))
>>>>>>> Stashed changes
		else
			user.drop_item_ground(src, force = TRUE)
			to_chat(user, span_clocklarge("\"Это для моих слуг, не для тебя\""))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/melee/clock_sword/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !isliving(target))
		return
	if(isclocker(target))
		return
	if(ishuman(target) && enchant_type == BLOODSHED_SPELL)
		var/mob/living/carbon/human/human = target
		var/obj/item/organ/external/bodypart = pick(human.bodyparts)
		if(bodypart.internal_bleeding())
			to_chat(user, span_warning("Ты разрываешь кожу [human], выпуская кровь из [human.p_their()] [bodypart.name]!"))
			playsound(get_turf(human), 'sound/effects/pierce.ogg', 30, TRUE)
			human.setBlood(max(human.blood_volume - 100, 0))
			var/splatter_dir = get_dir(user, human)
			blood_color = human.dna.species.blood_color
			new /obj/effect/temp_visual/dir_setting/bloodsplatter(human.drop_location(), splatter_dir, blood_color)
			human.emote("scream")
			deplete_spell()
	if(swordsman)
		user.changeNext_move(CLICK_CD_RAPID)

/obj/item/melee/clock_sword/pickup(mob/living/user)
	. = ..()
	if(!isclocker(user))
		to_chat(user, span_clocklarge("\"Я бы не советовал этого делать.\""))
		to_chat(user, span_warning("Вас одолевает непреодолимое чувство тошноты!"))
		user.Confused(20 SECONDS)
		user.Jitter(12 SECONDS)

//Buckler
/obj/item/shield/clock_buckler
	name = "brass buckler"
	desc = "Маленький щит, который защищает только руку. Но при правильном использовании может защитить и всё тело."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "brass_buckler"
	item_state = "brass_buckler"
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 3
	attack_verb = list("стукнул", "толкнул", "долбанул", "ударил")
	hitsound = 'sound/weapons/smash.ogg'
	block_chance = 30

/obj/item/shield/clock_buckler/Initialize(mapload)
	. = ..()
	enchants = GLOB.shield_spells

/obj/item/shield/clock_buckler/update_overlays()
	. = ..()
	if(enchant_type)
		. += "brass_buckler_overlay_[enchant_type]"

/obj/item/shield/clock_buckler/attack_self(mob/user)
	. = ..()
	if(enchant_type == FLASH_SPELL)
		if(!user.is_in_hands(src))
			to_chat(user, span_notice("Ты должен держать [src] в руках!"))
			return
		playsound(loc, 'sound/effects/phasein.ogg', 100, TRUE)
		set_light_range_power_color(2, 1, COLOR_WHITE)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light), 0), 0.2 SECONDS)
		user.visible_message(span_disarm("[name] [user.p_their()] излучает ослепительную вспышку!"), span_danger("Твой [name] излучает ослепительную вспышку!"))
		for(var/mob/living/carbon/M in oviewers(3, user))
			if(isclocker(M))
				return
			if(M.flash_eyes(2, TRUE))
				M.AdjustConfused(10 SECONDS)
				add_attack_logs(user, M, "Flashed with [src]")
		deplete_spell()

/obj/item/shield/clock_buckler/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity || !isliving(target))
		return
	if(isclocker(target))
		return
	if(enchant_type == PUSHOFF_SPELL)
		var/mob/living/living = target
		if(prob(60))
			living.AdjustStunned(2 SECONDS)
		else
			var/atom/throw_target = get_edge_target_turf(target, user.dir)
			living.throw_at(throw_target, 2, 5, spin = FALSE)
			if(iscarbon(living))
				living.AdjustConfused(10 SECONDS)
		deplete_spell()

/obj/item/shield/clock_buckler/equipped(mob/living/user, slot, initial)
	. = ..()

	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, span_clocklarge("\"Это для моих слуг, не для тебя\""))
<<<<<<< Updated upstream
			user.visible_message(span_warning("Когда [user] поднимает [src], оно мерцает и исчезает с их рук!"), span_warning("Баклер мерцает и исчезает с твоих рук, оставляя лишь тошноту!"))
=======
			user.visible_message(span_warning("Когда [user] поднимает [src], оно мерцает и исчезает с [genderize_ru(user.gender, "его", "её", "их", "их")] рук!"), span_warning("Баклер мерцает и исчезает с твоих рук, оставляя лишь тошноту!"))
>>>>>>> Stashed changes
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
				C.Knockdown(10 SECONDS)
		else
			to_chat(user, span_clocklarge("\"У тебя вообще есть голова на плечах?\""))
			to_chat(user, span_userdanger("Баклер вдарил тебе в голову!"))
			user.emote("scream")
			user.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
		user.drop_item_ground(src)

// Clockwork robe. Basic robe from clockwork slab.
/obj/item/clothing/suit/hooded/clockrobe
	name = "clock robes"
<<<<<<< Updated upstream
	desc = "A set of robes worn by the followers of a clockwork cult."
=======
>>>>>>> Stashed changes
	desc = "Набор одежды, которые носят последователи культа Ратвара."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_robe"
	item_state = "clockwork_robe"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/clockhood
	allowed = list(/obj/item/clockwork, /obj/item/twohanded/ratvarian_spear, /obj/item/twohanded/clock_hammer, /obj/item/melee/clock_sword)
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDEJUMPSUIT
	flags_inv_transparent = HIDEJUMPSUIT
	magical = TRUE
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

/obj/item/clothing/suit/hooded/clockrobe_fake
	name = "clock robes"
	desc = "Набор одежды, которые носят последователи культа Ратвара. Но сейчас это просто хорошая броня."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_robe"
	item_state = "clockwork_robe"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/clockhood_fake
	allowed = list(/obj/item/flashlight, /obj/item/tank, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe) // some miners stuff
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDEJUMPSUIT
	flags_inv_transparent = HIDEJUMPSUIT
	magical = TRUE
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

/obj/item/clothing/suit/hooded/clockrobe/can_store_weighted()
	return TRUE

/obj/item/clothing/suit/hooded/clockrobe/Initialize(mapload)
	. = ..()
	enchants = GLOB.robe_spells

/obj/item/clothing/suit/hooded/clockrobe/update_overlays()
	. = ..()
	if(enchant_type)
		. += "clockwork_robe_overlay_[enchant_type]"

/obj/item/clothing/suit/hooded/clockrobe/ui_action_click(mob/user, datum/action/action, leftclick)
	if(istype(action, /datum/action/item_action/activate/enchant))
		if(!iscarbon(user))
			return
		var/mob/living/carbon/carbon = user
		if(carbon.wear_suit != src || !isclocker(carbon))
			return
		if(enchant_type == INVIS_SPELL)
			if(carbon.wear_suit != src)
				return
			playsound(get_turf(carbon), 'sound/magic/smoke.ogg', 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			enchant_type = CASTING_SPELL
			animate(carbon, alpha = 20, time = 1 SECONDS)
			ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(INVIS_SPELL))
			sleep(10)
			carbon.alpha_set(standartize_alpha(20), ALPHA_SOURCE_CLOCKROBE)
			add_attack_logs(user, user, "cloaked [src]", ATKLOG_ALL)
			addtimer(CALLBACK(src, PROC_REF(uncloak), carbon), 10 SECONDS)
		if(enchant_type == SPEED_SPELL)
			enchant_type = CASTING_SPELL
			ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(SPEED_SPELL))
			carbon.add_movespeed_modifier(/datum/movespeed_modifier/clock_robe)
			addtimer(CALLBACK(src, PROC_REF(unspeed), carbon), 8 SECONDS)
<<<<<<< Updated upstream
			to_chat(carbon, span_danger("Robe tightens, as it frees you to be flexible around!"))
=======
			to_chat(carbon, span_danger("Роба затягивается и больше не сковывает движения!"))
>>>>>>> Stashed changes
			add_attack_logs(user, user, "speed boosted with [src]", ATKLOG_ALL)
	else
		ToggleHood()

/obj/item/clothing/suit/hooded/clockrobe/proc/uncloak(mob/living/user)
	animate(user, alpha = 255, time = 1 SECONDS)
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(INVIS_SPELL))
	sleep(10)
	user.alpha_set(1, ALPHA_SOURCE_CLOCKROBE)
	deplete_spell()

/obj/item/clothing/suit/hooded/clockrobe/proc/unspeed(mob/living/carbon/carbon)
	carbon?.remove_movespeed_modifier(/datum/movespeed_modifier/clock_robe)
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(SPEED_SPELL))
	deplete_spell()

/obj/item/clothing/head/hooded/clockhood
	name = "clock hood"
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockhood"
	item_state = "clockhood"
	desc = "Капюшон, который носят последователи Ратвара."
	flags_inv = HIDENAME|HIDEHAIR
	flags_cover = HEADCOVERSEYES
	armor = list(melee = 30, bullet = 10, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0, fire = 10, acid = 10)
	magical = TRUE

/obj/item/clothing/head/hooded/clockhood_fake
	name = "clock hood"
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockhood"
	item_state = "clockhood"
	desc = "Капюшон, который носили последователи Ратвара. Но сейчас это просто капюшон."
	flags_inv = HIDENAME|HIDEHAIR
	flags_cover = HEADCOVERSEYES
	armor = list(melee = 30, bullet = 10, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0, fire = 10, acid = 10)
	magical = TRUE

/obj/item/clothing/suit/hooded/clockrobe/equipped(mob/living/user, slot, initial)
	. = ..()

	if(!isclocker(user))
		if(!iscultist(user))
<<<<<<< Updated upstream
			to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
			user.visible_message(span_warning("As [user] picks [src] up, it flickers off their arms!"), span_warning("The robe flicker off your arms, leaving only nausea!"))
=======
			to_chat(user, span_clocklarge("\"Это для моих слуг, не для тебя\""))
			user.visible_message(span_warning("Когда [user] поднимает [src], оно мерцает и исчезает с [genderize_ru(user.gender, "его", "её", "их", "их")] рук!"), span_warning("Капюшон мерцает и исчезает с твоих рук, оставляя лишь тошноту!"))
>>>>>>> Stashed changes
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
				C.Knockdown(10 SECONDS)
		else
<<<<<<< Updated upstream
			to_chat(user, span_clocklarge("\"I think this armor is too hot for you to handle.\""))
=======
			to_chat(user, span_clocklarge("\"Я думаю, что эта броня слишком горяча для тебя чтобы ты мог[genderize_ru(user.gender, "", "ла", "", "")]] её держать.\""))
>>>>>>> Stashed changes
			user.emote("scream")
			user.apply_damage(7, BURN, BODY_ZONE_CHEST)
			user.IgniteMob()
		user.drop_item_ground(src)

// Clockwork Armour. Basically greater robe with more and better spells.
/obj/item/clothing/suit/armor/clockwork
	name = "clockwork cuirass"
	desc = "Громоздкая кираса из латуни"
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_cuirass"
	item_state = "clockwork_cuirass"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 50, "bullet" = 40, "laser" = 50, "energy" = 30, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	flags_inv = HIDEJUMPSUIT
	flags_inv_transparent = HIDEGLOVES|HIDESHOES
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/clockwork, /obj/item/twohanded/ratvarian_spear, /obj/item/twohanded/clock_hammer, /obj/item/melee/clock_sword)
	hide_tail_by_species = list(SPECIES_VULPKANIN)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi'
		)
	var/reflect_uses = 4
	var/normal_armor
	var/harden_armor = list("melee" = 80, "bullet" = 70, "laser" = 80, "energy" = 60, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)

/obj/item/clothing/suit/armor/clockwork_fake
	name = "clockwork cuirass"
	desc = "Громоздкая кираса из латуни. Она выглядит потускневшей"
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_cuirass"
	item_state = "clockwork_cuirass"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FIRE_PROOF | ACID_PROOF
	allowed = list(/obj/item/flashlight, /obj/item/tank, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe) // some miners stuff
	flags_inv = HIDEJUMPSUIT
	flags_inv_transparent = HIDEGLOVES|HIDESHOES
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/clockwork, /obj/item/twohanded/ratvarian_spear, /obj/item/twohanded/clock_hammer, /obj/item/melee/clock_sword)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

/obj/item/clothing/suit/armor/clockwork/can_store_weighted()
	return TRUE

/obj/item/clothing/suit/armor/clockwork/Initialize(mapload)
	. = ..()
	enchants = GLOB.armour_spells
	normal_armor = armor //initialize, so it will be easier to change armors stats
	harden_armor = getArmor(arglist(harden_armor))

/obj/item/clothing/suit/armor/clockwork/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(enchant_type == ABSORB_SPELL && isclocker(owner))
<<<<<<< Updated upstream
		owner.visible_message(span_danger("[attack_text] is absorbed by [src] sparks!"))
=======
		owner.visible_message(span_danger("[attack_text] поглощется искрами [src]!"))
>>>>>>> Stashed changes
		playsound(loc, "sparks", 100, TRUE)
		new /obj/effect/temp_visual/ratvar/sparks(get_turf(owner))
		deplete_spell()
		return TRUE
	return FALSE

/obj/item/clothing/suit/armor/clockwork/IsReflect(def_zone)
	if(!ishuman(loc))
		return FALSE
	var/mob/living/carbon/human/owner = loc
	if(owner.wear_suit != src)
		return FALSE
	if(enchant_type == REFLECT_SPELL && isclocker(owner))
		playsound(loc, "sparks", 100, TRUE)
		new /obj/effect/temp_visual/ratvar/sparks(get_turf(owner))
		if(reflect_uses <= 0)
			reflect_uses = initial(reflect_uses)
			deplete_spell()
		else
			reflect_uses--
		return TRUE
	return FALSE

/obj/item/clothing/suit/armor/clockwork/attack_self(mob/user)
	. = ..()
	if(!isclocker(user))
		user.drop_item_ground(src)
		user.emote("scream")
<<<<<<< Updated upstream
		to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
=======
		to_chat(user, span_clocklarge("\"Это для моих слуг, не для тебя\""))
>>>>>>> Stashed changes
		return
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbon = user
	if(enchant_type == ARMOR_SPELL)
		if(carbon.wear_suit != src)
<<<<<<< Updated upstream
			to_chat(carbon, span_notice("You should wear [src]!"))
			return
		carbon.visible_message(span_danger("[carbon] concentrates as [carbon.p_their()] curiass shifts his plates!"),
		span_notice("The [src.name] becomes more hardened as the plates becomes to shift for any attack!"))
=======
			to_chat(carbon, span_notice("Ты должен одеть [src]!"))
			return
		carbon.visible_message(span_danger("[carbon] сосредотачивается, пока [carbon.p_their()] кирасса смещает свои пластины!"),
		span_notice("[src.name] становится более закалённым, так как пластины смещаются, чтобы отразить любую атаку!"))
>>>>>>> Stashed changes
		//armor = list("melee" = 80, "bullet" = 60, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
		armor = harden_armor
		ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(ARMOR_SPELL))
		enchant_type = CASTING_SPELL
		add_attack_logs(carbon, carbon, "Hardened [src]", ATKLOG_ALL)
		set_light_range_power_color(1.5, 0.8, COLOR_RED)
		addtimer(CALLBACK(src, PROC_REF(reset_armor), carbon), 12 SECONDS)

/obj/item/clothing/suit/armor/clockwork/proc/reset_armor(mob/user)
<<<<<<< Updated upstream
	to_chat(user, span_notice("The [src] stops shifting..."))
=======
	to_chat(user, span_notice("Пластины [src] замедляются, переставая смещаться..."))
>>>>>>> Stashed changes
	set_light_on(FALSE)
	armor = normal_armor
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(ARMOR_SPELL))
	deplete_spell()

/obj/item/clothing/suit/armor/clockwork/equipped(mob/living/user, slot, initial)
	. = ..()

	if(!isclocker(user))
		if(!iscultist(user))
<<<<<<< Updated upstream
			to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
			user.visible_message(span_warning("As [user] puts [src] on, it flickers off their body!"), span_warning("The curiass flickers off your body, leaving only nausea!"))
=======
			to_chat(user, span_clocklarge("\"Это для моих слуг, не для тебя\""))
			user.visible_message(span_warning("Когда [user] наряжается в [src], оно соскальзывает и исчезает с [genderize_ru(user.gender, "его", "её", "их", "их")] тела!"), span_warning("Кираса мерцает и исчезает с твоего тела, оставляя лишь тошноту!"))
>>>>>>> Stashed changes
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20)
				C.Knockdown(10 SECONDS)
		else
<<<<<<< Updated upstream
			to_chat(user, span_clocklarge("\"I think this armor is too hot for you to handle.\""))
=======
			to_chat(user, span_clocklarge("\"Я думаю, что эта броня слишком горяча для тебя чтобы ты мог[genderize_ru(user.gender, "", "ла", "", "")]] её держать.\""))
>>>>>>> Stashed changes
			user.emote("scream")
			user.apply_damage(15, BURN, BODY_ZONE_CHEST)
			user.adjust_fire_stacks(2)
			user.IgniteMob()
		user.drop_item_ground(src)

/obj/item/clothing/suit/armor/clockwork/update_icon_state()
	return

// Gloves
/obj/item/clothing/gloves/clockwork
	name = "clockwork gauntlets"
	desc = "Тяжёлые, огнеупорные руковицы с защитными латунными плитами."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_gauntlets"
	item_state = "clockwork_gauntlets"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 40, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	var/north_star = FALSE
	var/fire_casting = FALSE

/obj/item/clothing/gloves/clockwork_fake
	name = "clockwork gauntlets"
	desc = "Тяжёлые, огнеупорные руковицы с защитными латунными плитами. Даже без магии выглядят крутыми."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_gauntlets"
	item_state = "clockwork_gauntlets"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 40, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)

/obj/item/clothing/gloves/clockwork/Initialize(mapload)
	. = ..()
	enchants = GLOB.gloves_spell

/obj/item/clothing/gloves/clockwork/attack_self(mob/user)
	. = ..()
	if(!isclocker(user))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human = user
	switch(enchant_type)
		if(FASTPUNCH_SPELL)
			if(human.gloves != src)
<<<<<<< Updated upstream
				to_chat(human, span_notice("You should wear [src]!"))
				return
			if(human.mind.martial_art)
				to_chat(human, span_warning("You're too powerful to use it!"))
				return
			ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(FASTPUNCH_SPELL))
			to_chat(human, span_notice("You fastening gloves making your moves agile!"))
=======
				to_chat(human, span_notice("Ты должен одеть [src]!"))
				return
			if(human.mind.martial_art)
				to_chat(human, span_warning("Ты <b>слишком</b> силён чтобы пытаться использовать это!"))
				return
			ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(FASTPUNCH_SPELL))
			to_chat(human, span_notice("Ты застегиваешь руковицы, что делает твои движения более ловкими!"))
>>>>>>> Stashed changes
			enchant_type = CASTING_SPELL
			north_star = TRUE
			add_attack_logs(human, human, "North-starred [src]", ATKLOG_ALL)
			addtimer(CALLBACK(src, PROC_REF(reset_punch)), 6 SECONDS)
		if(FIRE_SPELL)
			if(human.gloves != src)
<<<<<<< Updated upstream
				to_chat(human, span_notice("You should wear [src]!"))
				return
			ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(FIRE_SPELL))
			to_chat(human, span_notice("Your gloves becomes in red flames ready to burn any enemy in sight!"))
=======
				to_chat(human, span_notice("Ты должен одеть [src]!"))
				return
			ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(FIRE_SPELL))
			to_chat(human, span_notice("Твои руковицы охватываются красным пламенем, готовым сжечь любого врага в поле зрения!"))
>>>>>>> Stashed changes
			enchant_type = CASTING_SPELL
			fire_casting = TRUE
			add_attack_logs(human, human, "Fire-casted [src]", ATKLOG_ALL)
			addtimer(CALLBACK(src, PROC_REF(reset_fire)), 5 SECONDS)

/obj/item/clothing/gloves/clockwork/Touch(atom/A, proximity)
	var/mob/living/user = loc
	if(!(user.a_intent == INTENT_HARM) || !enchant_type)
		return
	if(!proximity)
		return
	if(enchant_type == STUNHAND_SPELL && isliving(A))
		var/mob/living/living = A
		if(living.null_rod_check())
<<<<<<< Updated upstream
			src.visible_message(span_warning("[living]'s holy weapon absorbs the light!"))
=======
			src.visible_message(span_warning("Еретик [living] и его ложное оружие поглощает праведный свет!"))
>>>>>>> Stashed changes
			deplete_spell()
			return
		if(isclocker(living))
			return
		if(iscarbon(living))
			var/mob/living/carbon/carbon = living
			carbon.Weaken(1 SECONDS)
			carbon.Stuttering(2 SECONDS)
		if(isrobot(living))
			var/mob/living/silicon/robot/robot = living
			robot.Weaken(1 SECONDS)
		do_sparks(5, 0, loc)
		playsound(loc, 'sound/weapons/egloves.ogg', 50, 1, -1)
		add_attack_logs(user, living, "Stunned with [src]")
		deplete_spell()
	if(north_star && !user.mind.martial_art)
		user.changeNext_move(CLICK_CD_RAPID)
	if(fire_casting && iscarbon(A))
		var/mob/living/carbon/C = A
		if(isclocker(C))
			return
		C.adjust_fire_stacks(0.5)
		C.IgniteMob()

/obj/item/clothing/gloves/clockwork/proc/reset_punch()
	north_star = FALSE
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(FASTPUNCH_SPELL))
<<<<<<< Updated upstream
	to_chat(usr, span_notice(" [src] depletes last magic they had."))
=======
	to_chat(usr, span_notice("[src] истощает последнюю магию, которая у них была."))
>>>>>>> Stashed changes
	deplete_spell()


/obj/item/clothing/gloves/clockwork/proc/reset_fire()
	fire_casting = FALSE
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(FIRE_SPELL))
<<<<<<< Updated upstream
	to_chat(usr, span_notice(" [src] depletes last magic they had."))
=======
	to_chat(usr, span_notice("[src] истощает последнюю магию, которая у них была."))
>>>>>>> Stashed changes
	deplete_spell()


/obj/item/clothing/gloves/clockwork/equipped(mob/living/user, slot, initial)
	. = ..()

	if(!isclocker(user))
		if(!iscultist(user))
<<<<<<< Updated upstream
			to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
			user.visible_message(span_warning("As [user] puts [src] on, it flickers off their arms!"), span_warning("The gauntlets flicker off your arms, leaving only nausea!"))
=======
			to_chat(user, span_clocklarge("\"Это для моих слуг, не для тебя\""))
			user.visible_message(span_warning("Когда [user] надевает [src], оно соскальзывает и исчезает с [genderize_ru(user.gender, "его", "её", "их", "их")] рук!"), span_warning("Рукавицы мерцают и исчезают с твоего тела, оставляя лишь тошноту!"))
>>>>>>> Stashed changes
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
				C.Knockdown(10 SECONDS)
		else
<<<<<<< Updated upstream
			to_chat(user, span_clocklarge("\"Did you like having arms?\""))
			to_chat(user, span_userdanger("The gauntlets suddenly squeeze tight, crushing your arms before you manage to get them off!"))
=======
			to_chat(user, span_clocklarge("\"Тебе нравятся твои руки?\""))
			to_chat(user, span_userdanger("Перчатки внезапно сильно сжимаются, сдавливая руки, прежде чем ты успеваешь их снять!"))
>>>>>>> Stashed changes
			user.emote("scream")
			user.apply_damage(7, BRUTE, BODY_ZONE_L_ARM)
			user.apply_damage(7, BRUTE, BODY_ZONE_R_ARM)
		user.drop_item_ground(src)

// Shoes
/obj/item/clothing/shoes/clockwork
	name = "clockwork treads"
	desc = "Промышленные ботинки из латуни. Они очень тяжёлые."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_treads"
	item_state = "clockwork_treads"
	strip_delay = 60
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 40, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)

/obj/item/clothing/shoes/clockwork_fake
	name = "clockwork treads"
	desc = "Промышленные ботинки из латуни. Они очень тяжёлые, и магия не может этого отрицать."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_treads"
	item_state = "clockwork_treads"
	strip_delay = 60
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 40, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)

/obj/item/clothing/shoes/clockwork/equipped(mob/living/user, slot, initial)
	. = ..()

	if(!isclocker(user))
		if(!iscultist(user))
<<<<<<< Updated upstream
			to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
			user.visible_message(span_warning("As [user] puts [src] on, it flickers off their feet!"), span_warning("The treads flicker off your feet, leaving only nausea!"))
=======
			to_chat(user, span_clocklarge("\"Это для моих слуг, не для тебя\""))
			user.visible_message(span_warning("Когда [user] натягивает [src], оно соскальзывает и исчезает с [genderize_ru(user.gender, "его", "её", "их", "их")] стоп!"), span_warning("Ботинки мерцают и исчезают с твоих стоп, оставляя лишь тошноту!"))
>>>>>>> Stashed changes
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
				C.Knockdown(10 SECONDS)
		else
<<<<<<< Updated upstream
			to_chat(user, span_clocklarge("\"Let's see if you can dance with these.\""))
			to_chat(user, span_userdanger("The treads turn searing hot as you scramble to get them off!"))
=======
			to_chat(user, span_clocklarge("\"Давай посмотрим, сможешь ли ты танцевать с ними.\""))
			to_chat(user, span_userdanger("Шнурки становятся обжигающе горячими, когда ты пытаешься их снять"))
>>>>>>> Stashed changes
			user.emote("scream")
			user.apply_damage(7, BURN, BODY_ZONE_L_LEG)
			user.apply_damage(7, BURN, BODY_ZONE_R_LEG)
		user.drop_item_ground(src)

// Helmet
/obj/item/clothing/head/helmet/clockwork
	name = "clockwork helmet"
	desc = "Тяжёлый шлем из латуни."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_helmet"
	item_state = "clockwork_helmet"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEHEADSETS|HIDEGLASSES|HIDENAME
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES
	armor = list(melee = 45, bullet = 65, laser = 10, energy = 0, bomb = 60, bio = 0, rad = 0, fire = 100, acid = 100)
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/helmet.dmi'
		)

/obj/item/clothing/head/helmet/clockwork_fake
	name = "clockwork helmet"
	desc = "Тяжёлый шлем из латуни."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_helmet"
	item_state = "clockwork_helmet"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEHEADSETS|HIDEGLASSES|HIDENAME
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES
	armor = list(melee = 45, bullet = 65, laser = 10, energy = 0, bomb = 60, bio = 0, rad = 0, fire = 100, acid = 100)

/obj/item/clothing/head/helmet/clockwork/equipped(mob/living/user, slot, initial)
	. = ..()

	if(!isclocker(user))
		if(!iscultist(user))
<<<<<<< Updated upstream
			to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
			user.visible_message(span_warning("As [user] puts [src] on, it flickers off their head!"), span_warning("The helmet flickers off your head, leaving only nausea!"))
=======
			to_chat(user, span_clocklarge("\"Это для моих слуг, не для тебя\""))
			user.visible_message(span_warning("Когда [user] надевает [src], оно соскальзывает и исчезает с [genderize_ru(user.gender, "его", "её", "их", "их")] головы!"), span_warning("Шлем мерцает и исчезает с твоей головы, оставляя лишь тошноту!"))
>>>>>>> Stashed changes
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20)
				C.Knockdown(10 SECONDS)
		else
<<<<<<< Updated upstream
			to_chat(user, span_heavybrass("\"Do you have a hole in your head? You're about to.\""))
			to_chat(user, span_userdanger("The helmet tries to drive a spike through your head as you scramble to remove it!"))
=======
			to_chat(user, span_heavybrass("\"Видишь дырку в своей голове? А она есть.\""))
			to_chat(user, span_userdanger("Шлем пытается вонзить латунный шип тебе голову, когда ты пытаетешься его снять!"))
>>>>>>> Stashed changes
			user.emote("scream")
			user.apply_damage(30, BRUTE, BODY_ZONE_HEAD)
			user.adjustBrainLoss(30)
		user.drop_item_ground(src)

// Glasses
/obj/item/clothing/glasses/clockwork
	name = "judicial visor"
	desc = "Странный визор с фиолетовыми линзами. При взгляде на него возникает странное чувство вины."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "judicial_visor_0"
	item_state = "sunglasses"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/active = FALSE //If the visor is online
	actions_types = list(/datum/action/item_action/toggle)
	flash_protect = FLASH_PROTECTION_FLASH
	see_in_dark = 0
	lighting_alpha = null

/obj/item/clothing/glasses/clockwork/equipped(mob/living/user, slot, initial)
	. = ..()

	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, span_clocklarge("\"Я думаю тебе нужны немного другие очки. Праведный свет ослепит тебя.\""))
			user.flash_eyes()
			user.Knockdown(2 SECONDS)
			playsound(loc, 'sound/weapons/flash.ogg', 50, TRUE)
		else
			to_chat(user, span_clocklarge("\"Считай, что тебя осудили, щенок.\""))
			to_chat(user, span_userdanger("Ты внезапно загораешься!"))
			user.adjust_fire_stacks(5)
			user.IgniteMob()
		user.drop_item_ground(src)

/obj/item/clothing/glasses/clockwork/attack_self(mob/user)
	if(!isclocker(user))
<<<<<<< Updated upstream
		to_chat(user, span_warning("You fiddle around with [src], to no avail."))
=======
		to_chat(user, span_warning("Ты возишься с [src], но безрезультатно."))
>>>>>>> Stashed changes
		return
	active = !active

	icon_state = "judicial_visor_[active]"
	flash_protect = !active
	see_in_dark = active ? 8 : 0
	lighting_alpha = active ? LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE : null
	switch(active)
		if(TRUE)
<<<<<<< Updated upstream
			to_chat(user, span_notice("You toggle [src], its lens begins to glow."))
		if(FALSE)
			to_chat(user, span_notice("You toggle [src], its lens darkens once more."))
=======
			to_chat(user, span_notice("Ты приспускаешь [src], линзы визора светлеют."))
		if(FALSE)
			to_chat(user, span_notice("Ты приподнимаешь [src], линзы визора темнеют."))
>>>>>>> Stashed changes

	user.update_action_buttons_icon()
	user.update_inv_glasses()
	user.update_sight()

/*
 * Consumables.
 */

//Intergration Cog. Can be used on an open APC to replace its guts with clockwork variants, and begin passively siphoning power from it
/obj/item/clockwork/integration_cog
	name = "integration cog"
	desc = "Маленькая шестерёнка, помещающаяся на ладони."
	icon_state = "gear"
	w_class = WEIGHT_CLASS_TINY

/obj/item/clockwork/integration_cog/Initialize()
	. = ..()
	transform *= 0.5 //little cog!

/obj/machinery/integration_cog
	name = "integration cog"
	desc = span_dangerbigger("Ты не должен этого видеть. Если ты каким-то образом это увидел - напиши об этом разработчикам, возможно где-то затаилась ошибка в коде.")
	icon = null
	anchored = TRUE
	active_power_usage = 100 // In summary it costs 500 power. Most areas costs around 800, with top being medbay at around 8000. Fair number.
	var/obj/machinery/power/apc/apc
	var/next_whoosh = 120

/obj/machinery/integration_cog/Initialize(mapload)
	. = ..()
	if(isapc(loc))
		apc = loc
	else
		log_runtime(EXCEPTION("Invalid location for Integration cog"))

/obj/machinery/integration_cog/emp_act(severity)
	return

/obj/machinery/integration_cog/process(seconds_per_tick)
	if(apc.cell?.charge > 0 && apc.operating)
		adjust_clockwork_power(CLOCK_POWER_COG * seconds_per_tick)
		if(next_whoosh <= 0)
			playsound(apc, 'sound/machines/clockcult/steam_whoosh.ogg', 5, TRUE, SILENCED_SOUND_EXTRARANGE)
			new/obj/effect/temp_visual/small_smoke(get_turf(apc))
			next_whoosh = 60 + rand(60) // 1-2 minutes
		next_whoosh -= seconds_per_tick
		return TRUE
	return FALSE

/obj/machinery/integration_cog/auto_use_power()
	if(powered(EQUIP))
		use_power(active_power_usage, EQUIP)
	if(powered(LIGHT))
		use_power(active_power_usage, LIGHT)
	if(powered(ENVIRON))
		use_power(active_power_usage, ENVIRON)
	use_power(200)
	adjust_clockwork_power(CLOCK_POWER_COG)
	return 1

//Clockwork module
/obj/item/borg/upgrade/clockwork
	name = "Clockwork Module"
	desc = "Уникальная медная пластина, которой пользовались воины-борги."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clock_mod"
	var/free_VTEC = FALSE


/obj/item/borg/upgrade/clockwork/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE
	. = TRUE
	if(robot.module?.type == /obj/item/robot_module/clockwork)
		robot.pdahide = TRUE
	else
		robot.ratvar_act()
		robot.opened = FALSE
		robot.locked = TRUE
	if(!free_VTEC)
		return .
	var/obj/item/borg/upgrade/vtec/vtec_upgrade = locate() in robot.upgrades
	if(!vtec_upgrade)
		vtec_upgrade = new
		if(vtec_upgrade.action(robot))
			robot.install_upgrade(vtec_upgrade)
		else
			qdel(vtec_upgrade)


// A drone shell. Just click on it and it will boot up itself!
/obj/item/clockwork/cogscarab
	name = "unactivated cogscarab"
	desc = "Странный, похожий на дрона механизм. Он выглядит безжизненным."
	icon_state = "cogscarab_shell"
	var/searching = FALSE

/obj/item/clockwork/cogscarab/attack_self(mob/user)
	if(!isclocker(user))
<<<<<<< Updated upstream
		to_chat(user, span_warning("You fiddle around with [src], to no avail."))
=======
		to_chat(user, span_warning("Ты возишься с [src], но безрезультатно."))
>>>>>>> Stashed changes
		return FALSE
	if(searching)
		return
	searching = TRUE
<<<<<<< Updated upstream
	to_chat(user, span_notice("You're trying to boot up [src] as the gears inside start to hum."))
=======
	to_chat(user, span_notice("Ты пытаешься запустить [src], шестерёнки внутри начинают шуметь."))
>>>>>>> Stashed changes
	var/list/candidates = SSghost_spawns.poll_candidates("Would you like to play as a Servant of Ratvar?", ROLE_CLOCKER, FALSE, poll_time = 10 SECONDS, source = /mob/living/silicon/robot/cogscarab)
	if(candidates.len)
		var/mob/dead/observer/O = pick(candidates)
		var/mob/living/silicon/robot/cogscarab/cog = new /mob/living/silicon/robot/cogscarab(get_turf(src))
		cog.key = O.key
		if(SSticker.mode.add_clocker(cog.mind))
			cog.create_log(CONVERSION_LOG, "[cog.mind] became clock drone by [user.name]")
		user.drop_item_ground(src)
		qdel(src)
	else
<<<<<<< Updated upstream
		visible_message(span_notice("[src] stops to hum. Perhaps you could try again?"))
=======
		visible_message(span_notice("[src] перестаёт шуметь. Попробуешь еще раз?"))
>>>>>>> Stashed changes
		searching = FALSE
	return TRUE

// A real fighter. Doesn't have any ability except passive range reflect chance but a good soldier with solid speed and attack.
/obj/item/clockwork/marauder
	name = "unactivated marauder"
	desc = "Мужественный призрак солдата. Он выглядит безжизненным."
	icon_state = "marauder_shell"


/obj/item/clockwork/marauder/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/mmi/robotic_brain/clockwork))
		add_fingerprint(user)
		if(!isclocker(user))
			to_chat(user, span_danger("Тебя охватывает всепоглощающее чувство ужаса, когда ты пытаешься поместить хранилище души в оболочку мародёра."))
			user.Confused(10 SECONDS)
			user.Jitter(8 SECONDS)
			return ATTACK_CHAIN_BLOCKED_ALL
		if(isdrone(user))
			to_chat(user, span_warning("Ты недостаточно ловок, чтобы сделать это!"))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/mmi/robotic_brain/clockwork/soul = I
		if(!soul.brainmob?.mind)
			to_chat(user, span_warning("[soul.brainmob? "Душа в [I] не активна!" : "[I] пуст!"]"))
			return ATTACK_CHAIN_PROCEED
		if(!user.can_unEquip(src))
			return ..()
		if(!user.drop_transfer_item_to_loc(soul, src))
			return ..()
		var/mob/living/simple_animal/hostile/clockwork/marauder/cog = new(drop_location())
		soul.brainmob.mind.transfer_to(cog)
		playsound(cog, 'sound/effects/constructform.ogg', 50)
		qdel(soul)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


//Shard
/obj/item/clockwork/shard
	name = "A brass shard"
	desc = "Уникальный осколок заряженный некоторой неизведанной магией."
	icon_state = "shard"
	sharp = TRUE //youch!!
	force = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clockwork/shard/Initialize(mapload)
	. = ..()
	enchants = GLOB.shard_spells

/obj/item/clockwork/shard/update_overlays()
	. = ..()
	if(enchant_type)
		. += "shard_overlay_[enchant_type]"

/obj/item/clockwork/shard/attack_self(mob/user)
	if(!isclocker(user) && isliving(user))
		var/mob/living/L = user
		user.emote("scream")
		if(ishuman(L))
<<<<<<< Updated upstream
			to_chat(L, span_danger("[src] pierces into your hand!"))
			var/mob/living/carbon/human/H = L
			H.embed_item_inside(src)
			to_chat(user, span_clocklarge("\"How does it feel it now?\""))
		else
			to_chat(L, span_danger("[src] pierces into you!"))
			L.adjustBruteLoss(force)
		return
	if(!enchant_type)
		to_chat(user, span_warning("There is no spell stored!"))
		return
	else
		if(!ishuman(user))
			to_chat(user,span_warning("You are too weak to crush this massive shard!"))
			return
		user.visible_message(span_warning("[user] crushes [src] in his hands!"), span_notice("You crush [src] in your hand!"))
=======
			to_chat(L, span_danger("[src] вонзается в твою руку!"))
			var/mob/living/carbon/human/H = L
			H.embed_item_inside(src)
			to_chat(user, span_clocklarge("\"Каково это – чувствовать такое?\""))
		else
			to_chat(L, span_danger("[src] вонзается в тебя!"))
			L.adjustBruteLoss(force)
		return
	if(!enchant_type)
		to_chat(user, span_warning("Осколок не зачарован!"))
		return
	else
		if(!ishuman(user))
			to_chat(user,span_warning("Ты слишком слаб чтобы разрушить этот массивный осколок!"))
			return
		user.visible_message(span_warning("[user] сокрушается [src] в [genderize_ru(user.gender, "его", "её", "их", "их")] руках!"), span_notice("Ты сокрушаешь [src] в своих руках!"))
>>>>>>> Stashed changes
		playsound(src, "shatter", 50, TRUE)
		switch(enchant_type)
			if(EMP_SPELL)
				add_attack_logs(user, user, "Clock EMP with [src]")
				empulse(src, 4, 6, cause="clock")
				qdel(src)
			if(TIME_SPELL)
				add_attack_logs(user, user, "Time stopped with [src]")
				qdel(src)
				new /obj/effect/timestop/clockwork(get_turf(user))
			if(RECONSTRUCT_SPELL)
				add_attack_logs(user, user, "Reconstructed with [src]")
				qdel(src)
				new /obj/effect/temp_visual/ratvar/reconstruct(get_turf(user))
	return


/obj/item/clockwork/shard/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!isclocker(user))
		user.emote("scream")
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			human.embed_item_inside(src)
			to_chat(user, span_clocklarge("\"Каково это – чувствовать такое?\""))
		else
			user.drop_item_ground(src, force = TRUE)
			to_chat(user, span_clocklarge("\"Это для моих слуг, не для тебя\""))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/clockwork/shard/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!ishuman(target) || !isclocker(user))
		return
	if(!proximity)
		return
	var/mob/living/carbon/human/human = target
	if(human.stat == DEAD && isclocker(human)) // dead clocker
		user.temporarily_remove_item_from_inventory(src)
		qdel(src)
		if(!human.client)
			give_ghost(human)
		else
			human.revive()
			human.set_species(/datum/species/golem/clockwork)
<<<<<<< Updated upstream
			to_chat(human, span_clocklarge("<b>\"You are back once again.\"</b>"))
=======
			to_chat(human, span_clocklarge("<b>\"Ты снова в строю, вставай!\"</b>"))
>>>>>>> Stashed changes

/obj/item/clockwork/shard/pickup(mob/living/user)
	. = ..()
	if(!isclocker(user))
<<<<<<< Updated upstream
		to_chat(user, span_clocklarge("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
=======
		to_chat(user, span_clocklarge("\"Я бы не советовал этого делать.\""))
		to_chat(user, span_warning("Вас одолевает непреодолимое чувство тошноты!"))
>>>>>>> Stashed changes
		user.Confused(20 SECONDS)
		user.Jitter(12 SECONDS)

/obj/item/clockwork/shard/proc/give_ghost(var/mob/living/carbon/human/golem)
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Would you like to play as a Brass Golem?", ROLE_CLOCKER, TRUE, poll_time = 10 SECONDS, source = /obj/item/clockwork/clockslab)
	if(length(candidates))
		var/mob/dead/observer/C = pick(candidates)
		golem.ghostize(FALSE)
		golem.key = C.key
		golem.revive()
		golem.set_species(/datum/species/golem/clockwork)
		log_game("[golem.key] has become Brass Golem.")
		SEND_SOUND(golem, 'sound/ambience/antag/clockcult.ogg')
	else
<<<<<<< Updated upstream
		golem.visible_message(span_warning("[golem] twitches as their body twists and rapidly changes the form!"))
=======
		golem.visible_message(span_warning("[golem] дергается, когда его тело изгибается, и быстро меняет форму!"))
>>>>>>> Stashed changes
		new /obj/effect/mob_spawn/human/golem/clockwork(get_turf(golem))
		golem.dust()

/obj/effect/temp_visual/ratvar/reconstruct
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_active"
	layer = BELOW_OBJ_LAYER
	alpha = 128
	duration = 40
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/ratvar/reconstruct/Initialize(mapload)
	. = ..()
	transform = matrix() * 0.1
	reconstruct()

/obj/effect/temp_visual/ratvar/reconstruct/proc/reconstruct()
	playsound(src, 'sound/magic/clockwork/reconstruct.ogg', 50, TRUE)
	animate(src, transform = matrix() * 1, time = 2 SECONDS)
	sleep(20)
	for(var/atom/affected in range(4, get_turf(src)))
		if(isliving(affected))
			var/mob/living/living = affected
			living.ratvar_act(TRUE)
			if(!isclocker(living) || !ishuman(living))
				continue
			living.heal_overall_damage(60, 60, affect_robotic = TRUE)
			living.reagents?.add_reagent("epinephrine", 5)
			var/mob/living/carbon/human/H = living
			for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
				bodypart.stop_internal_bleeding()
				bodypart.mend_fracture()
		else
			affected.ratvar_act()
	animate(src, transform = matrix() * 0.1, time = 2 SECONDS)

/*
 * A Clockwork Spell Enchantment.
 * It is attached to an item that can be enchanted.
 */
/datum/component/spell_enchant
	/// Current item parent.
	var/obj/item/item
	/// The current enchantment for an item.
	var/current_enchant = NO_SPELL
	/// The enchant overlay.
	var/mutable_appearance/enchant_overlay = null
	/// A list of all possible enchantments item can get. Conatins a list of /datum/spell_enchant
	var/list/enchantments = list()
	/// Channeling used while enchanting.
	var/channeling = FALSE
	/// Possible plushie transformation. Used by HIDE_SPELL
	var/list/plush_colors = list("red fox plushie" = "redfox", "black fox plushie" = "blackfox", "blue fox plushie" = "bluefox",
								"orange fox plushie" = "orangefox", "corgi plushie" = "corgi", "black cat plushie" = "blackcat",
								"deer plushie" = "deer", "octopus plushie" = "loveable", "facehugger plushie" = "huggable")
	/// Reflect charges. Used by REFLECT_SPELL
	var/reflect_uses = 4

/datum/component/spell_enchant/Initialize(_enchantments)
	if(!isitem(parent) || !islist(_enchantments))
		return COMPONENT_INCOMPATIBLE
	item = parent
	enchantments = _enchantments
	enchant_overlay = mutable_appearance('icons/obj/clockwork.dmi', "_overlay_0")

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(attackself))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(afterattack))
	RegisterSignal(parent, COMSIG_ITEM_HIT_REACT, PROC_REF(hitreact))
	RegisterSignal(parent, COMSIG_CLOCK_ARMOR_REFLECT, PROC_REF(try_reflect))

/datum/component/spell_enchant/Destroy(force, silent)
	item = null
	return ..()

/datum/component/spell_enchant/proc/enchant(mob/user)
	if(current_enchant <= CASTING_SPELL) //CASTING_SPELL = -1, CASTING_FASTSWORD_SPELL = -2...
		to_chat(user, span_warning("You can't enchant [item] right now while spell is working!"))
		return
	if(current_enchant)
		to_chat(user, span_clockitalic("There is already prepared spell in [item]! If you choose another spell it will overwrite old one!"))
	var/entered_spell_name
	var/list/possible_enchants = list()
	var/list/possible_enchant_icons = list()
	for(var/datum/spell_enchant/S in enchantments)
		if(S.enchantment == current_enchant)
			continue
		possible_enchants[S.name] = S
		var/image/I = image(icon = item.icon, icon_state = initial(item.icon_state))
		I.add_overlay("[initial(item.icon_state)]_overlay_[S.enchantment]")
		possible_enchant_icons += list(S.name = I)
	entered_spell_name = show_radial_menu(user, user, possible_enchant_icons, require_near = TRUE)
	var/datum/spell_enchant/spell_enchant = possible_enchants[entered_spell_name]

	if(QDELETED(item) || user.incapacitated() || !spell_enchant)
		return
	if(!(item in user.contents))
		var/obj/item/gripper/G = locate() in user
		if(item != G?.gripped_item)
			return
		return

	if(!channeling)
		channeling = TRUE
		to_chat(user, span_clockitalic("You start to concentrate on your power to seal the magic in [item]."))
	else
		to_chat(user, span_warning("You are already invoking clock magic!"))
		return

	var/time_cast = spell_enchant.time SECONDS
	if(locate(/obj/structure/clockwork/functional) in range(1, user))
		time_cast /= 2

	if(do_after(user, time_cast, target = user))
		deplete_spell() // to clear up actions if have
		current_enchant = spell_enchant.enchantment
		if(spell_enchant.spell_action)
			var/datum/action/item_action/activate/enchant/E = new (item)
			E.owner = user
			item.actions += E
			user.update_action_buttons(TRUE)
		update_enchant_overlay()
		to_chat(user, span_clock("You sealed the power in [item], you have prepared a [spell_enchant.name] invocation!"))

	channeling = FALSE

/// Check for being a clocker
/datum/component/spell_enchant/proc/clocker_check(mob/user, self_attack = FALSE)
	if(isclocker(user))
		return TRUE
	user.drop_item_ground(item, force = TRUE)
	user.emote("scream")
	to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
	return FALSE

/datum/component/spell_enchant/proc/deplete_spell()
	current_enchant = NO_SPELL
	var/enchant_action = locate(/datum/action/item_action/activate/enchant) in item.actions
	if(enchant_action)
		qdel(enchant_action)
	update_enchant_overlay()

/datum/component/spell_enchant/proc/update_enchant_overlay()
	if(enchant_overlay in item.overlays)
		item.cut_overlay(enchant_overlay)
	if(current_enchant > NO_SPELL)
		enchant_overlay.icon_state = "[initial(item.icon_state)]_overlay_[current_enchant]"
		item.add_overlay(enchant_overlay)

/datum/component/spell_enchant/proc/afterattack(datum/source, atom/target, mob/user, proximity, params)
	if(!clocker_check(user))
		return

	switch(current_enchant)
		if(CASTING_FASTSWORD_SPELL)
			if(proximity)
				user.changeNext_move(CLICK_CD_RAPID)
		if(CASTING_FASTPUNCH_SPELL)
			if(!user.mind?.martial_art && proximity)
				user.changeNext_move(CLICK_CD_RAPID)
		if(CASTING_FIRE_SPELL)
			if(!iscarbon(target) || !proximity)
				return
			var/mob/living/carbon/C = target
			if(isclocker(C))
				return
			C.adjust_fire_stacks(0.5)
			C.IgniteMob()
		if(STUN_SPELL)
			if(!isliving(target) || isclocker(target) || !proximity)
				return
			var/mob/living/living = target
			item.visible_message(span_warning("[user]'s [item] sparks for a moment with bright light!"))
			var/mob/living/L = user
			L.mob_light(LIGHT_COLOR_HOLY_MAGIC, 3, _duration = 0.2 SECONDS) //No questions
			if(living.null_rod_check())
				item.visible_message(span_warning("[target]'s holy weapon absorbs the light!"))
				deplete_spell()
				return
			living.Weaken(4 SECONDS)
			living.adjustStaminaLoss(30)
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
			add_attack_logs(user, target, "stun by enchanted [item]")
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
				playsound(get_turf(user), 'sound/magic/knock.ogg', 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				door.open()
				deplete_spell()
			else if(istype(target, /obj/structure/closet))
				var/obj/structure/closet/closet = target
				if(istype(closet, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = closet
					SC.locked = FALSE
				playsound(get_turf(user), 'sound/magic/knock.ogg', 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				closet.open()
				deplete_spell()
			else
				to_chat(user, span_warning("You can use only on doors and closets!"))
		if(TELEPORT_SPELL)
			if(target.density)
				to_chat(user, span_warning("The path is blocked!"))
				return
			if(proximity)
				to_chat(user, span_warning("You too close to the path point!"))
				return
			if(!(target in view(user)))
				return
			to_chat(user, span_notice("You start invoking teleportation..."))
			animate(user, color = COLOR_PURPLE, time = 1.5 SECONDS)
			if(do_after(user, 1.5 SECONDS, target = user))
				do_sparks(4, 0, user)
				user.forceMove(get_turf(target))
				playsound(user, 'sound/effects/phasein.ogg', 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				add_attack_logs(user, target, "teleported to by enchanted [item]", ATKLOG_ALL)
				deplete_spell()
			user.color = null
		if(HEAL_SPELL)
			if(!isliving(target) || !isclocker(target) || !proximity)
				return
			var/mob/living/living = target
			if(ishuman(living))
				living.heal_overall_damage(30, 30, TRUE, FALSE, TRUE)
			else if(isanimal(living))
				var/mob/living/simple_animal/M = living
				if(M.health < M.maxHealth)
					M.adjustHealth(-50)
			add_attack_logs(user, target, "healed by enchanted [item]", ATKLOG_ALL)
			deplete_spell()
		if(REFORM_SPELL)
			if(target.type == /turf/simulated/wall) //fuck
				var/turf/simulated/wall/W = target
				deplete_spell()
				new /obj/structure/falsewall/clockwork(W) //special falsewalls
				W.ChangeTurf(/turf/simulated/floor/plating)
				playsound(src, 'sound/magic/cult_spell.ogg', 100, 1)
		if(CONFUSE_SPELL)
			if(!proximity || !iscarbon(target))
				return
			var/mob/living/carbon/carbon = target
			if(carbon.mind?.isholy)
				to_chat(carbon, span_danger("You feel as foreigner thoughts tries to pierce your mind..."))
				deplete_spell()
				return
			carbon.AdjustConfused(30 SECONDS)
			to_chat(carbon, span_danger("Your mind blanks for a moment!"))
			add_attack_logs(user, carbon, "confused with enchanted [item]")
			deplete_spell()
		if(DISABLE_SPELL)
			if(!proximity)
				return
			new /obj/effect/temp_visual/emp/clock(get_turf(item))
			if(issilicon(target))
				var/mob/living/silicon/S = target
				S.emp_act(EMP_LIGHT)
			else
				target.emp_act(EMP_HEAVY)
			add_attack_logs(user, target, "Point-EMP with enchanted [item]")
			deplete_spell()
		if(KNOCKOFF_SPELL)
			if(!proximity || !isliving(target))
				return
			var/mob/living/living = target
			var/atom/throw_target = get_edge_target_turf(living, user.dir)
			living.throw_at(throw_target, 200, 20, user) // vroom
			add_attack_logs(user, living, "Knocked-off with enchanted [item]")
			deplete_spell()
		if(CRUSH_SPELL)
			if(!proximity)
				return
			if(ishuman(target))
				var/mob/living/carbon/human/human = target
				var/obj/item/rod = human.null_rod_check()
				if(rod)
					human.visible_message(span_danger("[human]'s [rod] shines as it deflects magic from [user]!"))
					deplete_spell()
					return
				var/obj/item/organ/external/BP = pick(human.bodyparts)
				BP.emp_act(EMP_HEAVY)
				BP.fracture()
			if(isanimal(target))
				var/mob/living/simple_animal/animal = target
				animal.adjustBruteLoss(item.force/2)
				animal.emp_act(EMP_LIGHT)
			if(isrobot(target))
				var/mob/living/silicon/robot/robot = target
				var/datum/robot_component/RC = robot.components[pick(robot.components)]
				RC.destroy()
			add_attack_logs(user, target, "Crushed with enchanted [item]")
			deplete_spell()
		if(BLOODSHED_SPELL)
			if(!proximity || !ishuman(target))
				return
			var/mob/living/carbon/human/human = target
			var/obj/item/organ/external/bodypart = pick(human.bodyparts)
			if(!bodypart.internal_bleeding())
				return
			to_chat(user, span_warning("You tear through [human]'s skin releasing the blood from [human.p_their()] [bodypart.name]!"))
			playsound(get_turf(human), 'sound/effects/pierce.ogg', 30, TRUE)
			human.blood_volume = max(human.blood_volume - 100, 0)
			var/splatter_dir = get_dir(user, human)
			item.blood_color = human.dna.species.blood_color
			new /obj/effect/temp_visual/dir_setting/bloodsplatter(human.drop_location(), splatter_dir, item.blood_color)
			human.emote("scream")
			deplete_spell()
		if(PUSHOFF_SPELL)
			if(!proximity || !isliving(target) || isclocker(target))
				return
			var/mob/living/living = target
			if(prob(60))
				living.AdjustStunned(2 SECONDS)
			else
				var/atom/throw_target = get_edge_target_turf(target, user.dir)
				living.throw_at(throw_target, 2, 5, spin = FALSE)
				if(iscarbon(living))
					living.AdjustConfused(10 SECONDS)
			deplete_spell()
		if(STUNHAND_SPELL)
			if(!isliving(target))
				return
			var/mob/living/living = target
			if(living.null_rod_check())
				living.visible_message(span_warning("[living]'s holy weapon absorbs the light!"))
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
			do_sparks(5, 0, get_turf(user))
			playsound(user, 'sound/weapons/Egloves.ogg', 50, 1, -1)
			add_attack_logs(user, living, "glove-stun with enchanted [item]")
			deplete_spell()
		if(HIDE_SPELL)
			if(!istype(target, /obj/structure/clockwork/functional))
				return
			var/obj/structure/clockwork/functional/F = target
			if(!F.canbehidden)
				to_chat(user, span_warning("You can't hide this structure!"))
				return
			var/choice
			if(!F.hidden)
				choice = show_radial_menu(user, F, F.choosable_items, require_near = TRUE)
				if(current_enchant != HIDE_SPELL || !choice || !F.Adjacent(user) || user.incapacitated())
					return
			F.toggle_hide(choice)
			to_chat(user, span_notice("You [F.hidden ? "" : "un"]disguise [src]."))
			playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)
			deplete_spell()



/datum/component/spell_enchant/proc/attackself(datum/source, mob/user)
	if(!clocker_check(user, TRUE))
		return

	switch(current_enchant)
		if(HIDE_SPELL)
			to_chat(user, span_notice("You disguise your tool as some little toy."))
			playsound(user, 'sound/magic/cult_spell.ogg', 15, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			var/obj/item/toy/plushie/plush = new()
			var/plushy = pick(plush_colors)
			plush.name = plushy
			plush.icon_state = plush_colors[plushy]
			plush.AddElement(/datum/element/clocked_plushy)
			item.forceMove(plush)
			user.put_in_hands(plush)
			current_enchant = CASTING_SPELL
		if(TELEPORT_SPELL)
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
				to_chat(user, span_warning("You have no altars teleport to!"))
				return
			if(!is_level_reachable(user.z))
				to_chat(user, span_warning("You are not in the right dimension!"))
				return

			var/selected_altar = tgui_input_list(user, "Pick a credence teleport to...", "Teleporation", possible_altars)
			if(!selected_altar)
				return
			var/turf/destination = possible_altars[selected_altar]
			to_chat(user, span_notice("You start invoking teleportation..."))
			animate(user, color = COLOR_PURPLE, time = 1.5 SECONDS)
			if(do_after(user, 1.5 SECONDS, target = user) && destination)
				do_sparks(4, 0, user)
				user.forceMove(get_turf(destination))
				playsound(user, 'sound/effects/phasein.ogg', 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				add_attack_logs(user, destination, "Teleported to by enchanted [item]", ATKLOG_ALL)
				deplete_spell()
			user.color = null
		if(FASTSWORD_SPELL)
			if(item != user.get_active_hand())
				return
			item.flags |= NODROP
			current_enchant = CASTING_FASTSWORD_SPELL
			item.force = max(1, initial(item.force) - 13) // for clocksword is 7
			add_attack_logs(user, user, "fastsword enchanted [item]", ATKLOG_ALL)
			to_chat(user, span_danger("The blood inside your veind flows quickly, as you try to sharp someone by any means!"))
			addtimer(CALLBACK(src, PROC_REF(reset_fastsword), user), 9 SECONDS)
		if(FLASH_SPELL)
			if(!user.is_in_hands(item))
				to_chat(user, span_notice("You should wear [item]!"))
				return
			playsound(get_turf(user), 'sound/effects/phasein.ogg', 100, TRUE)
			item.set_light(2, 1, COLOR_WHITE)
			addtimer(CALLBACK(item, TYPE_PROC_REF(/atom, set_light), 0), 0.2 SECONDS)
			user.visible_message(span_disarm("[user]'s [item.name] emits a blinding light!"), span_danger("Your [item.name] emits a blinding light!"))
			for(var/mob/living/carbon/M in oviewers(3, user))
				if(isclocker(M))
					return
				if(M.flash_eyes(2, 1))
					M.AdjustConfused(10 SECONDS)
					add_attack_logs(user, M, "flashed with enchanted [item]")
			deplete_spell()
		if(INVIS_SPELL)
			if(!iscarbon(user))
				return
			var/mob/living/carbon/carbon = user
			if(carbon.wear_suit != item || !isclocker(carbon))
				return
			playsound(get_turf(carbon), 'sound/magic/smoke.ogg', 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			current_enchant = CASTING_SPELL
			animate(carbon, alpha = 20, time = 1 SECONDS)
			item.flags |= NODROP
			add_attack_logs(user, user, "cloaked by enchanted [item]", ATKLOG_ALL)
			addtimer(CALLBACK(src, PROC_REF(uncloak), carbon), 10 SECONDS)
			sleep(1 SECONDS)
			carbon.alpha = 20
		if(SPEED_SPELL)
			if(!iscarbon(user))
				return
			var/mob/living/carbon/carbon = user
			if(carbon.wear_suit != item)
				return
			current_enchant = CASTING_SPELL
			item.flags |= NODROP
			ADD_TRAIT(carbon, TRAIT_GOTTAGOFAST, "clockrobes[UID()]")
			addtimer(CALLBACK(src, PROC_REF(unspeed), carbon), 8 SECONDS)
			to_chat(carbon, span_danger("Robe tightens, as it frees you to be flexible around!"))
			add_attack_logs(user, user, "speed boosted with enchanted [item]", ATKLOG_ALL)
		if(ARMOR_SPELL)
			if(!iscarbon(user))
				return
			var/mob/living/carbon/carbon = user
			if(carbon.wear_suit != item)
				to_chat(carbon, span_notice("You should wear [item]!"))
				return
			carbon.visible_message(span_danger("[carbon] concentrates as [carbon.p_their()] curiass shifts his plates!"),
			span_notice("The [item.name] becomes more hardened as the plates becomes to shift for any attack!"))
			item.armor = getArmor(arglist(CLOCK_HARDEN_ARMOR))
			item.flags |= NODROP
			current_enchant = CASTING_SPELL
			add_attack_logs(carbon, carbon, "Hardened by enchanted [item]", ATKLOG_ALL)
			item.set_light(1.5, 0.8, COLOR_RED)
			addtimer(CALLBACK(src, PROC_REF(reset_armor), carbon), 12 SECONDS)
		if(FASTPUNCH_SPELL)
			if(!isclocker(user) || !ishuman(user))
				return
			var/mob/living/carbon/human/human = user
			if(human.gloves != item)
				to_chat(human, span_notice("You should wear [item]!"))
				return
			if(human.mind?.martial_art)
				to_chat(human, span_warning("You're too powerful to use it!"))
				return
			item.flags |= NODROP
			to_chat(human, span_notice("You fastening gloves making your moves agile!"))
			current_enchant = CASTING_FASTPUNCH_SPELL
			add_attack_logs(human, human, "fastpunched enchanted [item]", ATKLOG_ALL)
			addtimer(CALLBACK(src, PROC_REF(reset_gloves), human), 6 SECONDS)
		if(FIRE_SPELL)
			if(!isclocker(user) || !ishuman(user))
				return
			var/mob/living/carbon/human/human = user
			if(human.gloves != item)
				to_chat(human, span_notice("You should wear [item]!"))
				return
			item.flags |= NODROP
			to_chat(human, span_notice("Your gloves becomes in red flames ready to burn any enemy in sight!"))
			current_enchant = CASTING_FIRE_SPELL
			add_attack_logs(human, human, "Fire-casted enchanted [item]", ATKLOG_ALL)
			addtimer(CALLBACK(src, PROC_REF(reset_gloves), human), 5 SECONDS)
		if(EMP_SPELL)
			if(!ishuman(user))
				to_chat(user, span_warning("You are too weak to crush this [item]!"))
				return
			user.visible_message(span_warning("[user] crushes [item] in his hands!"), span_notice("You crush [item] in your hand!"))
			playsound(item, "shatter", 50, TRUE)
			add_attack_logs(user, user, "Clock EMP with enchanted [item]")
			empulse(item, 4, 6, cause="clock")
			qdel(item)
		if(TIME_SPELL)
			if(!ishuman(user))
				to_chat(user, span_warning("You are too weak to crush this [item]!"))
				return
			user.visible_message(span_warning("[user] crushes [item] in his hands!"), span_notice("You crush [item] in your hand!"))
			playsound(item, "shatter", 50, TRUE)
			add_attack_logs(user, user, "Time stopped with enchanted [item]")
			qdel(item)
			new /obj/effect/timestop/clockwork(get_turf(user))
		if(RECONSTRUCT_SPELL)
			if(!ishuman(user))
				to_chat(user, span_warning("You are too weak to crush this [item]!"))
				return
			user.visible_message(span_warning("[user] crushes [item] in his hands!"), span_notice("You crush [item] in your hand!"))
			playsound(item, "shatter", 50, TRUE)
			add_attack_logs(user, user, "Reconstructed with enchanted [item]")
			qdel(item)
			new /obj/effect/temp_visual/ratvar/reconstruct(get_turf(user))

/datum/component/spell_enchant/proc/hitreact(datum/source, mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(current_enchant == ABSORB_SPELL && isclocker(owner))
		owner.visible_message(span_danger("[attack_text] is absorbed by [item] sparks!"))
		playsound(get_turf(owner), "sparks", 100, TRUE)
		new /obj/effect/temp_visual/ratvar/sparks(get_turf(owner))
		deplete_spell()

/datum/component/spell_enchant/proc/try_reflect(datum/source, mob/living/carbon/human/user)
	if(user.wear_suit != item)
		return FALSE
	if(current_enchant == REFLECT_SPELL && isclocker(user))
		playsound(user, "sparks", 100, TRUE)
		new /obj/effect/temp_visual/ratvar/sparks(get_turf(user))
		if(reflect_uses <= 0)
			reflect_uses = initial(reflect_uses)
			deplete_spell()
		else
			reflect_uses--
		return TRUE
	return FALSE


/datum/component/spell_enchant/proc/reset_fastsword(mob/user)
	to_chat(user, span_notice("The grip on [item] looses..."))
	item.force = initial(item.force)
	item.flags &= ~NODROP
	deplete_spell()

/datum/component/spell_enchant/proc/uncloak(mob/living/carbon/carbon)
	animate(carbon, alpha = 255, time = 1 SECONDS)
	item.flags &= ~NODROP
	deplete_spell()
	sleep(1 SECONDS)
	carbon.alpha = 255

/datum/component/spell_enchant/proc/unspeed(mob/living/carbon/carbon)
	REMOVE_TRAIT(carbon, TRAIT_GOTTAGOFAST, "clockrobes[UID()]")
	item.flags &= ~NODROP
	deplete_spell()

/datum/component/spell_enchant/proc/reset_armor(mob/user)
	to_chat(user, span_notice("The [item] stops shifting..."))
	item.set_light(0)
	item.armor = initial(item.armor)
	item.flags &= ~NODROP
	deplete_spell()

/datum/component/spell_enchant/proc/reset_gloves(mob/user)
	item.flags &= ~NODROP
	to_chat(user, span_notice("[item] depletes last magic they had."))
	deplete_spell()

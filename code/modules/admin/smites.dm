/datum/smite
	var/name = SMITE_DEFAULT
	var/desc = "Если вы это увидели, пишите баг-репорт."
	var/logmsg


/datum/smite/proc/activate(mob/living/target, reason = "грехи")
	apply_effect(target, reason)
	if(!logmsg)
		return

	log_and_message_admins("smited [key_name_log(target)] with: [logmsg][reason != "грехи" ? "reason - \"[reason]\"" : ""]")


/datum/smite/proc/apply_effect(mob/living/target, reason)
	return


/// MARK: Burn (off)
/datum/smite/burn
	name = SMITE_BURN
	desc = "Грешник сгорит!"
	logmsg = "a firey death."


/datum/smite/burn/apply_effect(mob/living/target, reason)
	to_chat(target, span_userdanger("Вас охватывает пламя! Боги наказали вас за [reason]!"))
	var/turf/simulated/turf = get_turf(target)
	new /obj/effect/hotspot(turf)
	target.adjustFireLoss(150)


/// MARK: Lighting
/datum/smite/lighting
	name = SMITE_LIGHTING
	desc = "Грешник получит удар молнией!"
	logmsg = "a lightning bolt."


/datum/smite/lighting/apply_effect(mob/living/target, reason)
	var/datum/drop_lightning_bolt_ui/editor = new(target)
	editor.ui_interact(target)


/// MARK: Gib
/datum/smite/gib
	name = SMITE_GIB
	desc = "Разорвите грешника на кучу маленьких частей!"
	logmsg = "gibbed."


/datum/smite/gib/apply_effect(mob/living/target, reason)
	to_chat(target, span_userdanger("Невероятная сила разрывает вас изнутри! Боги наказали вас за [reason]!"))
	target.gib(FALSE)


/// MARK: Brainloss
/datum/smite/brainloss
	name = SMITE_BRAINLOSS
	desc = "Повредите мозг грешника!"


/datum/smite/brainloss/apply_effect(mob/living/target, reason)
	var/damage = tgui_input_number(
		usr, \
		"Сколько урона мозгу нанести?", \
		"Выбор урона мозгу", \
		75, \
		1000, \
		0
	)
	target.adjustBrainLoss(damage)
	to_chat(target, span_userdanger("Вы чувствуете как ваши мозги плавятся! Боги наказали вас за [reason]!"))
	logmsg = "[damage] brain damage."


/// MARK: Honk tumor
/datum/smite/honktumor
	name = SMITE_HONKTUMOR
	desc = "Подсадите в мозг грешника банановую опухоль!"
	logmsg = "a honk tumor."


/datum/smite/honktumor/apply_effect(mob/living/target, reason)
	if(target.get_int_organ(/obj/item/organ/internal/honktumor))
		return

	var/obj/item/organ/internal/organ = new /obj/item/organ/internal/honktumor
	organ.insert(target)
	to_chat(target, span_userdanger("Вы чувствуете как в вашем мозгу развивается нечто инородное. \
									Нечто со вкусом банана. Боги наказали вас за [reason]!"))

/// MARK: Hallucinate (off)
/datum/smite/hallucinate
	name = SMITE_HALLUCIONATE
	desc = "Нашлите на грешника галлюцинации!"
	logmsg = "hallucinations."


/datum/smite/hallucinate/apply_effect(mob/living/target, reason)
	to_chat(target, span_userdanger("Вы чувствуете как в вашем мозгу развивается нечто инородное. Нечто со вкусом банана. Боги наказали вас за [reason]!"))
	var/time = tgui_input_number(usr, "Сколько секунд жертву будут преследовать галлюцинации?", "Время галлюцинаций", 0)
	target.Hallucinate(time SECONDS)
	target.last_hallucinator_log = "Hallucination smite"


/// MARK: Cold (off)
/datum/smite/cold
	name = SMITE_COLD
	desc = "Заморозьте грешника!"
	logmsg = "cold."


/datum/smite/cold/apply_effect(mob/living/target, reason)
	to_chat(target, span_userdanger("Вы чувствуете как холод пронизывает ваше тело! Боги наказали вас за [reason]!"))
	target.reagents.add_reagent("frostoil", 40)
	target.reagents.add_reagent("ice", 40)


/// MARK: Hunger
/datum/smite/hunger
	name = SMITE_HUNGER
	desc = "Вызовите сильный голод у грешника, или сделайте его толстым. Выбор за вами."
	logmsg = "starvation."


/datum/smite/hunger/apply_effect(mob/living/target, reason)
	var/nutrition = tgui_input_number(usr, "Выберите значение насыщения, которое будет установленно у цели. ([NUTRITION_LEVEL_FULL] - сыт)", "Выбор насыщения", 0)
	var/old_nutrition = nutrition
	target.set_nutrition(nutrition)
	to_chat(target, span_userdanger("Вы чувствуете [nutrition < old_nutrition ? "голод" : "что съели слишком много"]. Боги наказали вас за [reason]!"))


/// MARK: Cluwne
/datum/smite/cluwne
	name = SMITE_CLUWNE
	desc = "Извратите сущность грешника, сделав его Клуней."
	logmsg = "cluwned."


/datum/smite/cluwne/apply_effect(mob/living/carbon/human/target, reason)
	to_chat(target, span_userdanger("Вы чувствуете как ваша сущность координально меняется. Боги наказали вас за [reason]!"))
	target.makeCluwne()
	ADD_TRAIT(target, TRAIT_NO_CLONE, ADMIN_TRAIT)


/// MARK: Cookie (off)
/datum/smite/cookie
	name = SMITE_COOKIE
	desc = "Выдайте жертве печенье с выбранным веществом, которое она не сможет выбросить."


/datum/smite/cookie/apply_effect(mob/living/carbon/human/target, reason)
	target.makeCluwne()
	ADD_TRAIT(target, TRAIT_NO_CLONE, ADMIN_TRAIT)

	var/obj/item/reagent_containers/food/snacks/cookie/empty/evilcookie = new()
	var/datum/reagent/reagent = tgui_input_list(usr, "Выберите реагент который будет находиться в печенье.", "Выбор вещества", subtypesof(/datum/reagent))
	var/amount = tgui_input_number(usr, "Выберите количество вещества в печенье.", "Выбор количества", 10, 100, 0)
	var/id = reagent::id ? reagent::id : "mutagen"
	evilcookie.reagents.add_reagent(id, 10)
	evilcookie.bitesize = 100
	evilcookie.item_flags |= DROPDEL
	ADD_TRAIT(evilcookie, TRAIT_NODROP, ADMIN_TRAIT)
	target.drop_l_hand()
	target.equip_to_slot_or_del(evilcookie, ITEM_SLOT_HAND_LEFT)
	to_chat(target, span_userdanger("В ваших руках появляется печенье. По воле божьей, вы должны его съесть. Это наказание за [reason]!"))
	logmsg = "an antidrop cookie with [reagent] units of [id]."


/// MARK: Hunter
/datum/smite/cluwne
	name = SMITE_HUNTER
	desc = "Отправьте за грешником охотника."
	logmsg = "hunter."


/datum/smite/cluwne/apply_effect(mob/living/carbon/human/target, reason) // silent
	ADD_TRAIT(target, TRAIT_NO_CLONE, ADMIN_TRAIT)
	usr.client.create_eventmob_for(target, 1)


/client/proc/smite(mob/living/mob as mob)
	set category = STATPANEL_ADMIN_FUN
	set name = "Smite"
	if(!check_rights(R_EVENT))
		return

	if(!istype(mob))
		to_chat(usr, span_warning("Покарать можно только существ с типом начинающимся на /mob/living"), confidential = TRUE)
		return

	var/list/possible = GLOB.smites_not_human
	if(ishuman(mob))
		possible += GLOB.smites_human

	// Здесь сделать вызов менюшки.
	var/punishment = tgui_input_list(usr, "How would you like to smite [mob]?", "Its good to be baaaad...", possible)
	if(!(punishment in possible))
		return


	var/logmsg = null
	switch(punishment)
		if("Crew Traitor")
			if(!target.mind)
				to_chat(usr, "<span class='warning'>ERROR: This mob ([target]) has no mind!</span>", confidential=TRUE)
				return
			var/list/possible_traitors = list()
			for(var/mob/living/player in GLOB.alive_mob_list)
				if(player.client && player.mind && player.stat != DEAD && player != target)
					if(ishuman(player) && !player.mind.special_role)
						if(player.client && (ROLE_TRAITOR in player.client.prefs.be_special) && !jobban_isbanned(player, ROLE_TRAITOR) && !jobban_isbanned(player, "Syndicate"))
							possible_traitors += player.mind
			for(var/datum/mind/player in possible_traitors)
				if(player.current)
					if(ismindshielded(player.current))
						possible_traitors -= player
			if(possible_traitors.len)
				var/datum/mind/newtraitormind = pick(possible_traitors)
				var/datum/objective/assassinate/kill_objective = new()
				kill_objective.target = target.mind
				kill_objective.owner = newtraitormind
				kill_objective.explanation_text = "Assassinate [target.mind.name], the [target.mind.assigned_role]"
				newtraitormind.objectives += kill_objective
				var/datum/antagonist/traitor/turf = new()
				turf.give_objectives = FALSE
				to_chat(newtraitormind.current, "<span class='danger'>ATTENTION:</span> It is time to pay your debt to the Syndicate...")
				to_chat(newtraitormind.current, "<b>Goal: <span class='danger'>KILL [target.real_name]</span>, currently in [get_area(target.loc)]</b>")
				newtraitormind.add_antag_datum(turf)
			else
				to_chat(usr, "<span class='warning'>ERROR: Unable to find any valid candidate to send after [target].</span>", confidential=TRUE)
				return
			logmsg = "crew traitor."
		if("Floor Cluwne")
			var/turf/turf = get_turf(mob)
			var/mob/living/simple_animal/hostile/floor_cluwne/FC = new /mob/living/simple_animal/hostile/floor_cluwne(turf)
			FC.smiting = TRUE
			FC.Acquire_Victim(mob)
			logmsg = "floor cluwne"
		if("Shamebrero")
			if(target.head)
				target.drop_item_ground(target.head, force = TRUE)
			var/obj/item/clothing/head/sombrero/shamebrero/S = new(target.loc)
			target.equip_to_slot_or_del(S, ITEM_SLOT_HEAD)
			logmsg = "shamebrero"

		if("Fat")
			target.set_nutrition(NUTRITION_LEVEL_FAT * 2)

		if("Fakebwoink")
			SEND_SOUND(target, sound('sound/effects/adminhelp.ogg'))

		if("Nugget")
			target.Weaken(12 SECONDS, TRUE)
			target.AdjustJitter(40 SECONDS)
			to_chat(target, span_danger("Вы чувствуете, как будто ваши конечности отрывают от вашего тела!"))
			addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living/carbon/target, make_nugget)), 6 SECONDS)
			logmsg = "nugget"

		if("Rod")

			var/starting_turf_x = mob.x + rand(10, 15) * pick(1, -1)
			var/starting_turf_y = mob.y + rand(10, 15) * pick(1, -1)
			var/turf/start = locate(starting_turf_x, starting_turf_y, mob.z)

			var/obj/effect/immovablerod/smite/rod = new (start, mob)
			rod.go_for_a_walk(mob)
			logmsg = "a rod"

		if("Dust")
			target.dust()
			logmsg = "dust"
		if("Shitcurity Goblin")
			var/turf/turf = get_turf(mob)
			var/mob/living/simple_animal/hostile/shitcur_goblin/goblin = new (turf)
			goblin.GiveTarget(mob)
			logmsg = "shitcurity goblin"
		if("High RP")
			var/obj/item/organ/internal/high_rp_tumor/hrp_tumor = target.get_int_organ(/obj/item/organ/internal/high_rp_tumor)
			if(!hrp_tumor)
				var/list/effect_variants = list("15 - 50", "30 - 45", "30 - 75",
				"30 - 100", "60 - 100", "60 - 150", "60 - 200", "custom")
				var/effect_strength = tgui_input_list(src, "What effect strength do you want?(delay in seconds -  oxy damage)", effect_variants)
				var/pdelay
				var/oxy_dmg
				if(effect_strength == "custom")
					pdelay = tgui_input_number(src, "Input pump delay.")
					oxy_dmg = tgui_input_number(src, "Input oxy damage.")
				else
					var/list/strength = text2numlist(effect_strength, " - ")
					pdelay = strength[1]
					oxy_dmg = strength[2]
				target.curse_high_rp(pdelay*10, oxy_dmg)
				LAZYADD(target.mind.curses, "high_rp")
				logmsg = "high rp([pdelay] - [oxy_dmg])"
			else
				hrp_tumor.remove(target)
				qdel(hrp_tumor)
				LAZYREMOVE(target.mind.curses, "high_rp")
				logmsg = "high rp(cure)"

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
	var/datum/drop_lightning_bolt_ui/preloaded_target/editor = new(target, reason)
	editor.ui_interact(target)


/// MARK: Gib
/datum/smite/gib
	name = SMITE_GIB
	desc = "Разорвите грешника на кучу маленьких частей!"
	logmsg = "gibbed."


/datum/smite/gib/apply_effect(mob/living/target, reason)
	to_chat(target, span_userdanger("Невероятная сила разрывает вас изнутри! Боги наказали вас за [reason]!"))
	target.gib(FALSE)


/// MARK: Dust
/datum/smite/dust
	name = SMITE_DUST
	desc = "Испепелите грешника!"
	logmsg = "dusted."


/datum/smite/dust/apply_effect(mob/living/target, reason)
	to_chat(target, span_userdanger("Вы чувствуете... нет, вы ничего не чувствуете! Боги наказали вас за [reason]!"))
	target.dust()


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
	var/permanent = tgui_alert(
		usr, \
		"Сделать ли повреждения не лечащимися?", \
		"Лечатся ли", \
		list("Да", "Нет")
	) == "Да"
	if(permanent)
		var/obj/item/organ/brain = target.get_int_organ(/obj/item/organ/internal/brain)
		brain.max_damage -= damage

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
	var/amount = tgui_input_number(usr, "Выберите количество вещества в печенье.", "Выбор количества", 10, 10000, 0)
	var/id = reagent::id ? reagent::id : "mutagen"
	evilcookie.volume = max(100, amount)
	evilcookie.reagents.add_reagent(id, amount)
	evilcookie.bitesize = evilcookie.volume
	evilcookie.item_flags |= DROPDEL
	ADD_TRAIT(evilcookie, TRAIT_NODROP, ADMIN_TRAIT)
	target.drop_l_hand()
	target.equip_to_slot_or_del(evilcookie, ITEM_SLOT_HAND_LEFT)
	to_chat(target, span_userdanger("В ваших руках появляется печенье. По воле божьей, вы должны его съесть. Это наказание за [reason]!"))
	logmsg = "an antidrop cookie with [reagent] units of [id]."


/// MARK: Hunter
/datum/smite/hunter
	name = SMITE_HUNTER
	desc = "Отправьте за грешником охотника."
	logmsg = "hunter."


/datum/smite/hunter/apply_effect(mob/living/carbon/human/target, reason) // silent
	ADD_TRAIT(target, TRAIT_NO_CLONE, ADMIN_TRAIT)
	usr.client.create_eventmob_for(target, 1)


/// MARK: Hunter-traitor
/datum/smite/traitor_hunter
	name = SMITE_TRAITORHUNTER
	desc = "Отправьте за грешником агента синдиката, созданного среди экипажа."
	logmsg = "crew traitor."


/datum/smite/traitor_hunter/apply_effect(mob/living/carbon/human/target, reason) // silent
	var/list/possible_traitors = list()
	for(var/mob/living/player in GLOB.alive_mob_list)
		if(!player.client || !player.mind || player.stat == DEAD || player == target)
			continue

		if(!ishuman(player) || player.mind.special_role)
			continue

		if(!(ROLE_TRAITOR in player.client.prefs.be_special) || jobban_isbanned(player, ROLE_TRAITOR) || jobban_isbanned(player, "Syndicate"))
			continue

		possible_traitors += player.mind

	for(var/datum/mind/player in possible_traitors)
		if(!player.current)
			continue

		if(!ismindshielded(player.current))
			continue

		possible_traitors -= player

	if(!possible_traitors.len)
		to_chat(usr, span_warning("Не удалось найти кандидатов на предателя - охотника."), confidential = TRUE)
		return

	var/datum/mind/newtraitormind = pick(possible_traitors)
	var/datum/objective/assassinate/kill_objective = new()
	kill_objective.target = target.mind
	kill_objective.owner = newtraitormind
	kill_objective.explanation_text = "Убейте [target.mind.name], [target.mind.assigned_role]."
	newtraitormind.objectives += kill_objective
	var/datum/antagonist/traitor/turf = new()
	turf.give_objectives = FALSE
	to_chat(newtraitormind.current, "[span_danger("ВНИМАНИЕ:")] [span_warning("Время отдать свой долг Синдикату!")]")
	to_chat(newtraitormind.current, span_boldwarning("Цель: УБЕЙТЕ [target.real_name]. Сейчас находится в [get_area(target.loc)].</b>"))
	newtraitormind.add_antag_datum(turf)


/// MARK: Transform
/datum/smite/transform
	name = SMITE_TRANSFORM
	desc = "Превратите грешника в выбранное существо."


/datum/smite/transform/apply_effect(mob/living/target, reason)
	var/turf/turf = get_turf(target)
	var/mob/living/type = tgui_input_list(usr, "Выберите в кого превратить жертву.", "Выбор новой формы", subtypesof(/mob/living))
	if(!type)
		type = /mob/living/simple_animal/pig

	var/mob/living/mob = new(turf)
	target.mind.transfer_to(mob)
	qdel(target)
	to_chat(mob, span_userdanger("Вы чувствуете как ваша сущность координально меняется. Боги наказали вас за [reason]!"))
	logmsg = "transformed into [mob]."


/// MARK: Honk tumor
/datum/smite/antidrop_equip
	name = SMITE_ANTIDROP_EQUIP
	desc = "Наденьте на грешника проклятый предмет одежды!"


/datum/smite/antidrop_equip/apply_effect(mob/living/carbon/human/target, reason)
	var/type = tgui_input_list(usr, "Выберите какую одежду надеть на цель.", "Выбор одежды", subtypesof(/obj/item/clothing))
	var/obj/item/clothing/clothing = new type(target.loc)
	var/slot = clothing.slot_flags
	var/obj/item/item = target.get_item_by_slot(slot)
	if(item)
		target.drop_item_ground(item, force = TRUE)

	ADD_TRAIT(item, TRAIT_NODROP, ADMIN_TRAIT)
	target.equip_to_slot_or_del(clothing, slot)
	to_chat(target, span_userdanger("[capitalize(clothing.declent_ru(NOMINATIVE))] возникш[genderize_ru(clothing.gender, "ий", "ая", "ее", "ие")] из пустоты прилипа[pluralize_ru(clothing.gender, "ет", "ют")] к вам. Боги наказали вас за [reason]!"))
	logmsg = "antidrop [clothing]."


/// MARK: Nugget
/datum/smite/nugget
	name = SMITE_NUGGET
	desc = "Оторвите руки и ноги грешника."
	logmsg = "nugget"


/datum/smite/nugget/apply_effect(mob/living/target, reason)
	target.Weaken(12 SECONDS, TRUE)
	target.AdjustJitter(40 SECONDS)
	to_chat(target, span_userdanger("Вы чувствуете резкую боль в руках и ногах! Что-то отрывает их от вашего тела! Боги наказали вас за [reason]!"))
	addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living/carbon/human, make_nugget)), 6 SECONDS)


/// MARK: Rod
/datum/smite/rod
	name = SMITE_ROD
	desc = "Отправьте несдвигаемый стержень убить грешника."
	logmsg = "a rod"


/datum/smite/rod/apply_effect(mob/living/target, reason)
	var/starting_turf_x = target.x + rand(10, 15) * pick(1, -1)
	var/starting_turf_y = target.y + rand(10, 15) * pick(1, -1)
	var/turf/start = locate(starting_turf_x, starting_turf_y, target.z)
	var/obj/effect/immovablerod/smite/rod = new (start, target)
	rod.go_for_a_walk(target)


/// MARK: Summon
/datum/smite/summon
	name = SMITE_SUMMON
	desc = "Призовите злобное существо около грешника!"


/datum/smite/summon/apply_effect(mob/living/target, reason)
	var/turf/turf = get_turf(target)
	var/mob/living/type = tgui_input_list(usr, "Выберите кого натравить на жертву.", "Выбор призываемого существа", subtypesof(/mob/living/simple_animal/hostile))
	if(!type)
		type = /mob/living/simple_animal/hostile/shitcur_goblin

	var/mob/living/simple_animal/hostile/mob = new type(turf)
	mob.GiveTarget(mob)
	to_chat(target, span_userdanger("[capitalize(mob.declent_ru(NOMINATIVE))] появляется из воздуха! Боги наказали вас за [reason]!"))
	logmsg = "summon angry [mob]."


/// MARK: HRP (off)
/datum/smite/hrp
	name = SMITE_HRP
	desc = "Подсадите в грешника опухоль ХРП."


/datum/smite/hrp/apply_effect(mob/living/carbon/human/target, reason) // silent
	var/obj/item/organ/internal/high_rp_tumor/hrp_tumor = target.get_int_organ(/obj/item/organ/internal/high_rp_tumor)
	if(hrp_tumor)
		hrp_tumor.remove(target)
		qdel(hrp_tumor)
		LAZYREMOVE(target.mind.curses, "high_rp")
		logmsg = "high rp(cure)"
		return

	var/list/effect_variants = list("15 - 50", "30 - 45", "30 - 75",
	"30 - 100", "60 - 100", "60 - 150", "60 - 200", "custom")
	var/effect_strength = tgui_input_list(src, "Какую силу эффекта вы хотите? (задержка в секундах - урон гипоксией)", effect_variants)
	var/pdelay
	var/oxy_dmg
	if(effect_strength == "custom")
		pdelay = tgui_input_number(src, "Выберите задержку между качанием крови.")
		oxy_dmg = tgui_input_number(src, "Выберите урон гипоксией.")
	else
		var/list/strength = text2numlist(effect_strength, " - ")
		pdelay = strength[1]
		oxy_dmg = strength[2]

	target.curse_high_rp(pdelay * 10, oxy_dmg)
	LAZYADD(target.mind.curses, "high_rp")
	logmsg = "high rp([pdelay] - [oxy_dmg])"


/// MARK: Admin proc
/client/proc/smite(mob/living/mob as mob)
	set category = STATPANEL_ADMIN_FUN
	set name = "Smite"
	if(!check_rights(R_EVENT))
		return

	if(!istype(mob))
		to_chat(usr, span_warning("Покарать можно только существ с типом начинающимся на /mob/living"), confidential = TRUE)
		return

	var/datum/smite_ui/ui = new(mob)
	ui.ui_interact(mob)


// _________________________________________TGUI_________________________________________
/// MARK: TGUI
/datum/smite_ui
	/// Name of choosen smite
	var/choosen = null
	/// Reason of smiting.
	var/reason = "грехи"
	/// Mob that we want to smite.
	var/mob/victim_mob


/datum/smite_ui/ui_state(mob/user)
	return GLOB.admin_state


/datum/smite_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return

	ui = new(user, src, "SmiteMenu", "Наказание [victim_mob.declent_ru(GENITIVE)]")
	ui.open()
	ui.set_autoupdate(TRUE)


/datum/smite_ui/ui_static_data(mob/user)
	. = ..()
	var/list/smites_paths = GLOB.smites_not_human
	if(!ishuman(user))
		smites_paths += GLOB.smites_human

	.["all_smites"] = list()
	for(var/name in smites_paths)
		var/datum/smite/type = smites_paths[name]
		.["all_smites"][name] = type::desc


/datum/smite_ui/ui_data(mob/user)
	. = ..()
	.["choosen"] = choosen
	.["reason"] = reason


/datum/smite_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		if("change_reason")
			reason = params["new_reason"]

		if("change_choosen")
			choosen = params["new_choosen"]

		if("activate")
			var/list/all_smites = GLOB.smites_not_human + GLOB.smites_human
			var/type = all_smites[choosen]
			if(!type)
				return FALSE

			var/datum/smite/smite = new type()
			smite.activate(victim_mob, reason)
			ui.close()

		else
			. = FALSE


/datum/smite_ui/ui_close(mob/user)
	qdel(src)


/datum/smite_ui/New(target)
	src.victim_mob = target


/datum/smite_ui/Destroy(force)
	victim_mob = null
	. = ..()

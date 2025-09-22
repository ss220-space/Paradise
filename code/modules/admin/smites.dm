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
	flame_radius(1, get_turf(target))
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
		usr,
		"Сколько урона мозгу нанести?",
		"Выбор урона мозгу",
		75,
		1000,
		0
	)
	var/permanent = tgui_alert(
		usr,
		"Сделать ли повреждения не лечащимися?",
		"Лечатся ли",
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
	var/old_nutrition = target.nutrition
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
	var/datum/reagent/reagent = tgui_input_list(usr, "Выберите реагент который будет находиться в печенье.", "Выбор вещества", GLOB.typecache_reagent)
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
	for(var/mob/living/carbon/human/player in GLOB.alive_player_list)
		if(player.mind.special_role)
			continue

		if(ismindshielded(player))
			continue

		if(!(ROLE_TRAITOR in player.client.prefs.be_special) || jobban_isbanned(player, ROLE_TRAITOR) || jobban_isbanned(player, ROLE_SYNDICATE))
			continue

		possible_traitors += player.mind

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
	var/mob/living/type = tgui_input_list(usr, "Выберите в кого превратить жертву.", "Выбор новой формы", GLOB.typecache_living)
	if(!type)
		type = /mob/living/simple_animal/pig

	var/mob/living/mob = new type(turf)
	target.mind.transfer_to(mob)
	qdel(target)
	to_chat(mob, span_userdanger("Вы чувствуете как ваша сущность координально меняется. Боги наказали вас за [reason]!"))
	logmsg = "transformed into [mob]."


/// MARK: Honk tumor
/datum/smite/antidrop_equip
	name = SMITE_ANTIDROP_EQUIP
	desc = "Наденьте на грешника проклятый предмет одежды!"


/datum/smite/antidrop_equip/apply_effect(mob/living/carbon/human/target, reason)
	var/type = tgui_input_list(usr, "Выберите какую одежду надеть на цель.", "Выбор одежды", GLOB.typecache_clothing)
	var/obj/item/clothing/clothing = new type(target.loc)
	var/slot = clothing.slot_flags
	var/obj/item/item = target.get_item_by_slot(slot)
	if(item)
		target.drop_item_ground(item, force = TRUE)

	ADD_TRAIT(clothing, TRAIT_NODROP, ADMIN_TRAIT)
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
	rod.reason = reason
	rod.go_for_a_walk(target)


/// MARK: Summon
/datum/smite/summon
	name = SMITE_SUMMON
	desc = "Призовите злобное существо около грешника!"


/datum/smite/summon/apply_effect(mob/living/target, reason)
	var/turf/turf = get_turf(target)
	var/mob/living/type = tgui_input_list(usr, "Выберите кого натравить на жертву.", "Выбор призываемого существа", GLOB.typecache_hostile)
	if(!type)
		type = /mob/living/simple_animal/hostile/shitcur_goblin

	var/mob/living/simple_animal/hostile/mob = new type(turf)
	mob.GiveTarget(mob)
	mob.toggle_ai(AI_ON)
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


/// MARK: Demote
/datum/smite/demote
	name = SMITE_DEMOTE
	desc = "Увольте грешника!"
	logmsg = "demote."


/datum/smite/demote/apply_effect(mob/living/target, reason)
	GLOB.major_announcement.announce(
		"[target.real_name] настоящим приказом был понижен до Гражданского. Немедленно обработайте этот запрос. Невыполнение этих распоряжений является основанием для расторжения контракта.",
		ANNOUNCE_CCDEMOTE_RU,
		'sound/AI/commandreport.ogg'
	)

	for(var/datum/data/record/record in sortRecord(GLOB.data_core.security))
		if(record.fields["name"] != target.real_name)
			continue

		record.fields["criminal"] = SEC_RECORD_STATUS_DEMOTE
		record.fields["last_modifier_level"] = LAW_LEVEL_CENTCOMM
		record.fields["comments"] += "Central Command Demotion Order, given on [GLOB.current_date_string] [station_time_timestamp()]<br> Process this demotion immediately. Failure to comply with these orders is grounds for termination."

	update_all_mob_security_hud()


/// MARK: Virus
/datum/smite/virus
	name = SMITE_VIRUS
	desc = "Заразите грешника выбранным вирусом! Если хотите, сделайте вирус незаразным."
	logmsg = "virus."


/datum/smite/virus/activate(mob/living/target, reason)
	var/type = tgui_input_list(usr, "Выберите вирус.", "Выбор вируса", GLOB.typecache_virus, /datum/disease/virus/nuclefication)
	var/cant_spread = tgui_alert(
		usr,
		"Сделать ли вирус незаразным?",
		"Сделать незаразным",
		list("Да", "Нет")
	) == "Да"

	var/datum/disease/virus/virus = new type()
	if(cant_spread != "Да")
		virus.spread_flags = NON_CONTAGIOUS

	virus.Contract(target)


/// MARK: Pod
/datum/smite/pod
	name = SMITE_POD
	desc = "Запустите по грешнику ракетой."
	logmsg = "supply pod."


/datum/smite/pod/activate(mob/living/target, reason)
	var/datum/centcom_podlauncher/launcher = new(usr, reason)
	launcher.specificTarget = target
	launcher.ui_interact(usr)


/// MARK: Global hunting
/datum/smite/global_hunting
	name = SMITE_GLOBALHUNTING
	desc = "Заставьте экипаж охотиться за грешником."
	logmsg = "global hunting."


/datum/smite/global_hunting/activate(mob/living/target, reason)
	var/bounty = tgui_input_number(usr, "Выберите денежное вознаграждение поделённое между исполнителями приговора.", "Выбор вознаграждения", 5000, INFINITY, 0)
	GLOB.major_announcement.announce(
		"[target.real_name] настоящим приказом был лишён защиты Космического Закона и приговорён к смертной казни. \
		Всему экипажу разрешено и рекомендуется исполнить приговор. Между членами экипажа принявшими участие в процессе казни \
		будет автоматически распределено денежное вознаграждение в размере [bounty] кредит[declension_ru(bounty, "", "а", "ов")].",
		ANNOUNCE_CCKILL_RU,
		'sound/AI/commandreport.ogg'
	)
	ADD_TRAIT(target, TRAIT_NO_CLONE, ADMIN_TRAIT)
	target.AddComponent(/datum/component/killing_reward, bounty)

	for(var/datum/data/record/record in sortRecord(GLOB.data_core.security))
		if(record.fields["name"] != target.real_name)
			continue

		record.fields["criminal"] = SEC_RECORD_STATUS_EXECUTE
		record.fields["last_modifier_level"] = LAW_LEVEL_CENTCOMM
		record.fields["comments"] += "Постановление Центрального Командования о казни, принятое [GLOB.current_date_string] [station_time_timestamp()]<br> Привести приговор в исполнение немедленн. Невыполнение этого распоряженя является основанием для увольнения."

	update_all_mob_security_hud()


/// MARK: Brainrot braindamage
/datum/smite/brainrot_braingamage
	name = SMITE_BRAINROTBRAINDAMAGE
	desc = "Мозг грешника будет повреждаться от глупых фраз."
	logmsg = "brainrot braindamage."


/datum/smite/brainrot_braingamage/activate(mob/living/target, reason)
	var/datum/component = target.GetComponent(/datum/component/brainrot_braingamage)
	if(component)
		to_chat(usr, span_warning("Старые ограничения сняты с грешника."))
		to_chat(target, span_notice("Ваш мозг расслабляется. Вы снова можете нести бред без вреда для себя."))
		qdel(component)
		logmsg = "brainrot braindamage cure."
		return

	var/damage = tgui_input_number(usr, "Настройте повреждения мозга за каждое запретное слово.", "Выбор повреждений", 5, 120, 0)
	var/list/bad_words = GLOB.default_brainrot.Copy()
	var/bad_words_string = tgui_input_text(usr, "Настройте список запретных слов, введя все слова списка через запятую без пробелов. Список по умолчанию: [list_to_string(bad_words)]", "Выбор запретных слов")
	if(bad_words_string)
		bad_words = string_to_list(bad_words_string)

	target.AddComponent(/datum/component/brainrot_braingamage, damage, bad_words)
	to_chat(target, span_userdanger("Ваш мозг напрягается. Вы чувствуете, что лучше больше не нести бред. Это кара за [reason]!"))


/datum/smite/brainrot_braingamage/proc/list_to_string(list/bad_words)
	var/result = ""
	for(var/word in bad_words)
		result += (result ? "," : "") + word

	return result


/datum/smite/brainrot_braingamage/proc/string_to_list(bad_words)
	return splittext(bad_words, ",")


/// MARK: Piano
/datum/smite/piano
	name = SMITE_PIANO
	desc = "Сбросьте на грешника пианино или вендомат."
	logmsg = "piano"


/datum/smite/piano/apply_effect(mob/living/target, reason)
	var/type = tgui_input_list(usr, "Выберите что именно упадёт на грешника.", "Выбор падающей стуктуры", GLOB.typecache_vending + list(/obj/structure/pianoclassic) + list(/obj/structure/piano))
	var/turf/target_turf = get_turf(target)
	var/obj/fallen = new type(target_turf)
	target_turf.zImpact(fallen, 1)
	to_chat(target, span_userdanger(
		"Откуда-то сверху на вас пада[pluralize_ru(fallen.gender, "ет", "ют")] [fallen.declent_ru(NOMINATIVE)]! \
		Вам почему-то кажется, что это наказание за [reason]." \
	))


/// MARK: Jackboots
/datum/smite/jackbots
	name = SMITE_JACKBOOTS
	desc = "Заставьте грешника до конца смены изредка слышать топот ботинков СБ."
	logmsg = "jackboots sounds"
	var/mob/target
	var/sound_chanse = 1


/datum/smite/jackbots/apply_effect(mob/living/target, reason)
	src.target = target
	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(try_hear_sound))


/datum/smite/jackbots/proc/try_hear_sound()
	SIGNAL_HANDLER
	if(!prob(4))
		return

	var/starting_turf_x = target.x + rand(5, 10) * pick(1, -1)
	var/starting_turf_y = target.y + rand(5, 10) * pick(1, -1)
	var/turf/start = locate(starting_turf_x, starting_turf_y, target.z)
	var/turf/end = locate(starting_turf_x + rand(5, 10) * pick(1, -1), starting_turf_y + rand(5, 10) * pick(1, -1), target.z)
	do_step(start, end)


/datum/smite/jackbots/proc/do_step(turf/now, turf/last, limit = 10)
	if(!now || !last || limit <= 0)
		return

	target.playsound_local(now, pick(list('sound/effects/jackboot1.ogg', 'sound/effects/jackboot2.ogg')), 20, TRUE, 0, falloff_exponent = 10)
	now = get_step(now, get_dir(now, last))
	addtimer(CALLBACK(src, PROC_REF(do_step), now, last, limit - 1), 0.3 SECONDS)


/// MARK: Machinery transformation
/datum/smite/machinery
	name = SMITE_MACHINERY
	desc = "Сбросьте на грешника пианино или вендомат."
	logmsg = "machinery transformation"


/datum/smite/machinery/apply_effect(mob/living/target, reason)
	var/type = tgui_input_list(usr, "Выберите в какую машинерию превратится грешник.", "Выбор новой формы", GLOB.typecache_machinery)
	var/obj/machinery/new_form = new type(get_turf(target))
	to_chat(target, span_userdanger( \
		"Ваши конечности немеют... По телу распространяется металлический холод... Это смерть? \
		Нет. Хуже. Это [new_form.declent_ru(NOMINATIVE)]. Похоже что ваша новая форма - наказание за [reason]." \
	))
	target.flash_eyes(2, TRUE)
	new_form.obj_flags |= NODECONSTRUCT
	var/mob/living/machinery_mind/machinery_mind = new(new_form)
	target.mind.transfer_to(machinery_mind)
	qdel(target)


/mob/living/machinery_mind

/mob/living/machinery_mind/Initialize(mapload)
	. = ..()
	var/obj/machinery/machinery = loc
	name = machinery.name
	desc = machinery.desc
	icon = machinery.icon // For correct ghost image.
	icon_state = machinery.icon_state
	maxHealth = machinery.max_integrity
	health = maxHealth
	RegisterSignal(machinery, COMSIG_QDELETING, PROC_REF(death))


/// MARK: Head hit
/datum/smite/headhit
	name = SMITE_HEADHIT
	desc = "Грешник будет периодически биться головой об шлюзы."
	logmsg = "airlock headhit."


/datum/smite/headhit/apply_effect(mob/living/target, reason)
	if(HAS_TRAIT_FROM(target, TRAIT_AIRLOCK_HIT, ADMIN_TRAIT))
		to_chat(usr, span_notice("Старая кара снята."))
		REMOVE_TRAIT(target, TRAIT_AIRLOCK_HIT, ADMIN_TRAIT)
		return

	ADD_TRAIT(target, TRAIT_AIRLOCK_HIT, ADMIN_TRAIT)
	to_chat(target, span_userdanger("Вы чувствуете что стали на пару сантиметров выше. К чему бы это? Может это наказание за [reason]?"))


/// MARK: Admin smite proc
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


/datum/smite_ui/ui_static_data(mob/user)
	. = ..()
	var/list/smites_paths = GLOB.smites_not_human.Copy()
	if(ishuman(user))
		smites_paths += GLOB.smites_human.Copy()

	.["all_smites"] = list()
	.["all_descs"] = list()
	for(var/name in smites_paths)
		var/datum/smite/smite_type = smites_paths[name]
		.["all_smites"] += name
		.["all_descs"] += smite_type::desc


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
			return

		if("change_choosen")
			choosen = params["new_choosen"]
			return

		if("activate")
			var/list/all_smites = GLOB.smites_not_human + GLOB.smites_human
			var/type = all_smites[choosen]
			if(!type)
				return FALSE

			var/datum/smite/smite = new type()
			smite.activate(victim_mob, reason)
			ui.close()
			return

	return FALSE


/datum/smite_ui/ui_close(mob/user)
	qdel(src)


/datum/smite_ui/New(target)
	src.victim_mob = target


/datum/smite_ui/Destroy(force)
	victim_mob = null
	. = ..()

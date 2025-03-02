/datum/outfit/admin/debug
	name = "Debug outfit"

	uniform = /obj/item/clothing/under/patriotsuit
	suit = /obj/item/clothing/suit/space/deathsquad/officer
	head = /obj/item/clothing/head/helmet/space/deathsquad/beret
	back = /obj/item/storage/backpack/ert/security
	backpack_contents = list(
		/obj/item/melee/energy/axe = 1,
		/obj/item/storage/part_replacer/bluespace/tier4 = 1,
		/obj/item/gun/magic/wand/resurrection/debug = 1,
		/obj/item/gun/magic/wand/death/debug = 1,
		/obj/item/debug/human_spawner = 1
	)
	belt = /obj/item/storage/belt/military/abductor/full
	l_ear = /obj/item/radio/headset/centcom/debug
	glasses = /obj/item/clothing/glasses/hud/debug
	mask = /obj/item/clothing/mask/gas/welding/advanced
	shoes = /obj/item/clothing/shoes/combat/swat

	// shit down here is mine
	box = /obj/item/storage/box/debug/debugtools
	suit_store = /obj/item/tank/internals/oxygen
	gloves = /obj/item/clothing/gloves/combat
	id = /obj/item/card/id/admin
	pda = /obj/item/pda/centcom

	toggle_helmet = TRUE

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/surgery/advanced,
		/obj/item/organ/internal/cyberimp/chest/nutriment_old/plus/hardened,
		/obj/item/organ/internal/cyberimp/arm/janitorial/advanced
	)


/datum/outfit/admin/debug/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Debugger", "admin")

/obj/item/radio/headset/centcom/debug
	name = "AVD-CNED bowman headset"
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура AVD-CNED",
		GENITIVE = "тактической гарнитуры AVD-CNED",
		DATIVE = "тактической гарнитуре AVD-CNED",
		ACCUSATIVE = "тактическую гарнитуру AVD-CNED",
		INSTRUMENTAL = "тактической гарнитурой AVD-CNED",
		PREPOSITIONAL = "тактической гарнитуре AVD-CNED",
	)
	ks2type = /obj/item/encryptionkey/all


/obj/item/encryptionkey/all
	name = "AVD-CNED Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ шифрования AVD-CNED",
		GENITIVE = "ключа шифрования AVD-CNED",
		DATIVE = "ключу шифрования AVD-CNED",
		ACCUSATIVE = "ключ шифрования AVD-CNED",
		INSTRUMENTAL = "ключом шифрования AVD-CNED",
		PREPOSITIONAL = "ключе шифрования AVD-CNED",
	)
	channels = list("Response Team" = TRUE, "Special Ops" = TRUE, "Science" = TRUE, "Command" = TRUE, "Medical" = TRUE, "Engineering" = TRUE, "Security" = TRUE, "Supply" = TRUE, "Service" = TRUE, "Procedure" = TRUE) // just in case
	syndie = TRUE
	change_voice = FALSE

/obj/item/encryptionkey/all/Initialize(mapload)
	. = ..()
	for(var/channel in SSradio.radiochannels)
		channels[channel] = TRUE // yeah, all channels, sure, probably fine


/obj/item/clothing/mask/gas/welding/advanced
	name = "AVD-CNED welding mask"
	desc = "Повреждение сетчатки – это не шутка."
	ru_names = list(
		NOMINATIVE = "сварочная маска AVD-CNED",
		GENITIVE = "сварочной маски AVD-CNED",
		DATIVE = "сварочной маске AVD-CNED",
		ACCUSATIVE = "сварочную маску AVD-CNED",
		INSTRUMENTAL = "сварочной маской AVD-CNED",
		PREPOSITIONAL = "сварочной маске AVD-CNED",
	)
	tint = FLASH_PROTECTION_NONE
	flags_cover = MASKCOVERSEYES|MASKCOVERSMOUTH // vomit prevention when being surrounded by tons of dead bodies

/obj/item/gun/magic/wand/resurrection/debug
	desc = "Возможно ли что-то более могущественное, чем обычная магия? Эта палочка."
	max_charges = 500
	variable_charges = FALSE
	can_charge = TRUE
	recharge_rate = 1

/obj/item/gun/magic/wand/death/debug
	desc = "В некоторых тёмных кругах это известно как «друг тестировщика-клонера»."
	max_charges = 500
	variable_charges = FALSE
	can_charge = TRUE
	recharge_rate = 1

/obj/item/clothing/glasses/hud/debug
	name = "AVD-CNED glasses"
	ru_names = list(
		NOMINATIVE = "очки AVD-CNED",
		GENITIVE = "очков AVD-CNED",
		DATIVE = "очкам AVD-CNED",
		ACCUSATIVE = "очки AVD-CNED",
		INSTRUMENTAL = "очками AVD-CNED",
		PREPOSITIONAL = "очках AVD-CNED",
	)
	desc = "Медицинский, охранно-диагностический худ."
	icon_state = "nvgmeson"
	flags_cover = GLASSESCOVERSEYES
	flash_protect = FLASH_PROTECTION_WELDER

	prescription_upgradable = FALSE

	HUDType = list(DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_ADVANCED, DATA_HUD_SECURITY_ADVANCED, DATA_HUD_HYDROPONIC)
	examine_extensions = EXAMINE_HUD_SECURITY_READ | EXAMINE_HUD_SECURITY_WRITE | EXAMINE_HUD_MEDICAL | EXAMINE_HUD_SKILLS

	var/xray = FALSE

/obj/item/clothing/glasses/hud/debug/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(xray)
		add_xray(user)

/obj/item/clothing/glasses/hud/debug/dropped(mob/living/carbon/human/user)
	. = ..()
	if(xray)
		remove_xray(user)

/obj/item/clothing/glasses/hud/debug/examine(mob/user)
	. = ..()
	. += span_info("Щелкните <b>Alt + ЛКМ</b>, чтобы переключить иксрей.")

/obj/item/clothing/glasses/hud/debug/click_alt(mob/user)
	if(!ishuman(user))
		return NONE
	var/mob/living/carbon/human/human_user = user
	if(human_user.glasses != src)
		return CLICK_ACTION_BLOCKING
	if(xray)
		remove_xray(human_user)
	else
		add_xray(human_user)
	xray = !xray
	balloon_alert(user, "рентген-зрение [!xray ? "де" : ""]активировано") // ctodo test
	human_user.update_sight()
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/glasses/hud/debug/visor_toggling(mob/living/carbon/human/user)
	return


/obj/item/clothing/glasses/hud/debug/proc/remove_xray(mob/user)
	see_in_dark = initial(see_in_dark)
	lighting_alpha = initial(lighting_alpha)
	REMOVE_TRAIT(user, TRAIT_XRAY, "debug_glasses[UID()]")

/obj/item/clothing/glasses/hud/debug/proc/add_xray(mob/user)
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	ADD_TRAIT(user, TRAIT_XRAY, "debug_glasses[UID()]")

/obj/item/debug/human_spawner
	name = "human spawner"
	ru_names = list(
		NOMINATIVE = "создатель гуманоидов",
		GENITIVE = "создателя гуманоидов",
		DATIVE = "создателю гуманоидов",
		ACCUSATIVE = "создатель гуманоидов",
		INSTRUMENTAL = "создателем гуманоидов",
		PREPOSITIONAL = "создателе гуманоидов",
	)
	desc = "Создайте гуманоида, нацелившись на турф и нажав ЛКМ. Используйте в руке, чтобы изменить расу."
	icon = 'icons/obj/weapons/magic.dmi'
	icon_state = "nothingwand"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/datum/species/selected_species
	var/valid_species = list()

/obj/item/debug/human_spawner/afterattack(atom/target, mob/user, proximity)
	..()
	if(isturf(target))
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(target)
		if(selected_species)
			H.setup_dna(selected_species.type)

/obj/item/debug/human_spawner/attack_self(mob/user)
	..()
	var/choice = tgui_input_list(user, "Выберите расу", "Создатель гуманоидов", GLOB.all_species, null)
	selected_species = GLOB.all_species[choice]

/obj/item/rcd/combat/admin
	name = "AVD-CNED RCD"
	ru_names = list(
		NOMINATIVE = "AVD-CNED УБС",
		GENITIVE = "AVD-CNED УБС",
		DATIVE = "AVD-CNED УБС",
		ACCUSATIVE = "AVD-CNED УБС",
		INSTRUMENTAL = "AVD-CNED УБС",
		PREPOSITIONAL = "AVD-CNED УБС",
	)
	max_matter = INFINITY
	matter = INFINITY
	locked = FALSE

/obj/item/stack/spacecash/debug
	amount = 50000
	max_amount = 50000

/obj/item/bodyanalyzer/debug
	name = "AVD-CNED handheld body analyzer"
	ru_names = list(
		NOMINATIVE = "портативный анализатор тела AVD-CNED",
		GENITIVE = "портативного анализатора тела AVD-CNED",
		DATIVE = "портативному анализатору тела AVD-CNED",
		ACCUSATIVE = "портативный анализатор тела AVD-CNED",
		INSTRUMENTAL = "портативным анализатором тела AVD-CNED",
		PREPOSITIONAL = "портативном анализаторе тела AVD-CNED",
	)
	cell_type = /obj/item/stock_parts/cell/infinite
	scan_time = 1 SECONDS
	scan_cd = 0 SECONDS

/obj/item/scalpel/laser/manager/debug
	name = "AVD-CNED IMS"
	ru_names = list(
		NOMINATIVE = "лазерный скальпель AVD-CNED",
		GENITIVE = "лазерного скальпеля AVD-CNED",
		DATIVE = "лазерному скальпелю AVD-CNED",
		ACCUSATIVE = "лазерный скальпель AVD-CNED",
		INSTRUMENTAL = "лазерным скальпелем AVD-CNED",
		PREPOSITIONAL = "лазерном скальпеле AVD-CNED",
	)
	desc = "Чудо современной медицины. Этот инструмент действует как любой другой хирургический инструмент и заканчиает операции в кратчайшие сроки. Эй, а как ты вообще это заполучил?"
	toolspeed = 0.01

/obj/item/scalpel/laser/manager/debug/attack_self(mob/user)
	. = ..()
	toolspeed = toolspeed == 0.5 ? 0.01 : 0.5
	to_chat(user, "Установленная скорость работы у [declent_ru(GENITIVE)] - [toolspeed].")
	balloon_alert(user, "скорость изменена")
	playsound(src, 'sound/effects/pop.ogg', 50, 0)		//Change the mode

/obj/item/organ/internal/cyberimp/arm/surgery/advanced
	name = "AVD-CNED surgical toolset implant"
	ru_names = list(
		NOMINATIVE = "хирургический имплант AVD-CNED",
		GENITIVE = "хирургического импланта AVD-CNED",
		DATIVE = "хирургическому импланту AVD-CNED",
		ACCUSATIVE = "хирургический имплант AVD-CNED",
		INSTRUMENTAL = "хирургическим имплантом AVD-CNED",
		PREPOSITIONAL = "хирургическом импланте AVD-CNED",
	)
	contents = newlist(
		/obj/item/scalpel/laser/manager/debug,
		/obj/item/hemostat/alien, // its needed specifically for some surgeries
		/obj/item/circular_saw/alien,
		/obj/item/healthanalyzer/advanced,
		/obj/item/gun/medbeam,
		/obj/item/handheld_defibrillator,
		/obj/item/bodyanalyzer/debug
	)

/obj/item/organ/internal/cyberimp/arm/janitorial/advanced
	name = "AVD-CNED janitorial toolset implant... is that a... tazer?"
	ru_names = list(
		NOMINATIVE = "имплант уборщика AVD-CNED",
		GENITIVE = "импланта уборщика AVD-CNED",
		DATIVE = "импланту уборщика AVD-CNED",
		ACCUSATIVE = "имплант уборщика AVD-CNED",
		INSTRUMENTAL = "имплантом уборщика AVD-CNED",
		PREPOSITIONAL = "импланте уборщика AVD-CNED",
	)
	desc = "Набор продвинутых инструментов для уборки, спрятанных за скрытой панелью на руке пользователя с электрошокером? Какого черта."
	parent_organ_zone = BODY_ZONE_L_ARM
	slot = INTERNAL_ORGAN_L_ARM_DEVICE

	contents = newlist(
		/obj/item/mop/advanced/debug,
		/obj/item/soap/syndie/debug,
		/obj/item/lightreplacer/bluespace/debug,
		/obj/item/reagent_containers/spray/cleaner/advanced/debug,
		/obj/item/gun/energy/gun/advtaser/mounted // yeah why not
	)

/obj/item/mop/advanced/debug
	name = "AVD-CNED mop"
	desc = "Я знаю, что ты хочешь это сделать. Сделайте дерьмо скользким."
	ru_names = list(
		NOMINATIVE = "швабра AVD-CNED",
		GENITIVE = "швабры AVD-CNED",
		DATIVE = "швабре AVD-CNED",
		ACCUSATIVE = "швабру AVD-CNED",
		INSTRUMENTAL = "шваброй AVD-CNED",
		PREPOSITIONAL = "швабре AVD-CNED",
	)
	mopcap = 100
	mopspeed = 1
	refill_rate = 50

/obj/item/soap/syndie/debug
	name = "super soap"
	ru_names = list(
		NOMINATIVE = "супер-мыло",
		GENITIVE = "супер-мыла",
		DATIVE = "супер-мылу",
		ACCUSATIVE = "супер-мыло",
		INSTRUMENTAL = "супер-мылом",
		PREPOSITIONAL = "супер-мыле",
	)
	desc = "Самое быстрое мыло на космическом западе."
	cleanspeed = 1

/obj/item/lightreplacer/bluespace/debug
	name = "AVD-CNED light... thingy. You know what it is."
	ru_names = list(
		NOMINATIVE = "заменитель ламп AVD-CNED",
		GENITIVE = "заменителя ламп AVD-CNED",
		DATIVE = "заменителю ламп AVD-CNED",
		ACCUSATIVE = "заменитель ламп AVD-CNED",
		INSTRUMENTAL = "заменителем ламп AVD-CNED",
		PREPOSITIONAL = "заменителе ламп AVD-CNED",
	)
	max_uses = 20000
	uses = 20000

/obj/item/reagent_containers/spray/cleaner/advanced/debug
	name = "AVD-CNED advanced space cleaner"
	ru_names = list(
		NOMINATIVE = "усовершенствованный космический очиститель AVD-CNED",
		GENITIVE = "усовершенствованного космического очистителя AVD-CNED",
		DATIVE = "усовершенствованному космическому очистителю AVD-CNED",
		ACCUSATIVE = "усовершенствованный космический очиститель AVD-CNED",
		INSTRUMENTAL = "усовершенствованным космическим очистителем AVD-CNED",
		PREPOSITIONAL = "усовершенствованном космическом очистителе AVD-CNED",
	)
	desc = "AVD-CNED! — непенящееся чистящее средство для помещений! Как чудесно."
	volume = 50000
	spray_maxrange = 10
	spray_currentrange = 10
	list_reagents = list("cleaner" = 50000)
	delay = 0.1 SECONDS // it costs 1000 reagents to fire this cleaner... for 12 seconds.


//
// Funny matryoshka doll boxes
//

/obj/item/storage/box/debug
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_combined_w_class = 1000
	storage_slots = 99

/obj/item/storage/box/debug/debugtools
	name = "debug tools"
	ru_names = list(
		NOMINATIVE = "инструменты отладки",
		GENITIVE = "инструментов отладки",
		DATIVE = "инструментам отладки",
		ACCUSATIVE = "инструменты отладки",
		INSTRUMENTAL = "инструментами отладки",
		PREPOSITIONAL = "инструментах отладки",
	)

/obj/item/storage/box/debug/debugtools/populate_contents()
	new /obj/item/card/emag(src)
	new /obj/item/rcd/combat/admin(src)
	new /obj/item/healthanalyzer/advanced(src)
	new /obj/item/rpd/bluespace(src)
	new /obj/item/stack/spacecash/debug(src)
	new /obj/item/storage/box/beakers/bluespace(src)
	new /obj/item/storage/box/debug/material(src)
	new /obj/item/storage/box/debug/misc_debug(src)
	new /obj/item/storage/box/centcomofficer(src)
	new /obj/item/radio/uplink/admin(src)

/obj/item/storage/box/debug/material
	name = "box of materials"
	ru_names = list(
		NOMINATIVE = "коробка с материалами",
		GENITIVE = "коробки с материалами",
		DATIVE = "коробке с материалами",
		ACCUSATIVE = "коробку с материалами",
		INSTRUMENTAL = "коробкой с материалами",
		PREPOSITIONAL = "коробке с материалами",
	)

/obj/item/storage/box/debug/material/populate_contents()
	new /obj/item/stack/sheet/metal/fifty(src)
	new /obj/item/stack/sheet/plasteel/fifty(src)
	new /obj/item/stack/sheet/plastic/fifty(src)
	new /obj/item/stack/sheet/runed_metal/fifty(src)
	new /obj/item/stack/sheet/glass/fifty(src)
	new /obj/item/stack/sheet/rglass/fifty(src)
	new /obj/item/stack/sheet/plasmaglass/fifty(src)
	new /obj/item/stack/sheet/plasmarglass/fifty(src)
	new /obj/item/stack/sheet/titaniumglass/fifty(src)
	new /obj/item/stack/sheet/plastitaniumglass/fifty(src)
	new /obj/item/stack/sheet/mineral/sandstone/fifty(src)
	new /obj/item/stack/sheet/mineral/diamond/fifty(src)
	new /obj/item/stack/sheet/mineral/uranium/fifty(src)
	new /obj/item/stack/sheet/mineral/plasma/fifty(src)
	new /obj/item/stack/sheet/mineral/gold/fifty(src)
	new /obj/item/stack/sheet/mineral/silver/fifty(src)
	new /obj/item/stack/sheet/mineral/bananium/fifty(src)
	new /obj/item/stack/sheet/mineral/tranquillite/fifty(src)
	new /obj/item/stack/sheet/mineral/titanium/fifty(src)
	new /obj/item/stack/sheet/mineral/plastitanium/fifty(src)
	new /obj/item/stack/sheet/mineral/abductor/fifty(src)
	new /obj/item/stack/sheet/mineral/adamantine/fifty(src)
	new /obj/item/stack/sheet/mineral/snow/fifty(src)
	new /obj/item/stack/sheet/mineral/mythril/fifty(src)

/obj/item/storage/box/debug/misc_debug
	name = "misc admin items"
	ru_names = list(
		NOMINATIVE = "прочие административные предметы",
		GENITIVE = "прочих административных предметов",
		DATIVE = "прочим административным предметам",
		ACCUSATIVE = "прочие административные предметы",
		INSTRUMENTAL = "прочими административными предметами",
		PREPOSITIONAL = "прочих административных предметах",
	)

// put cool admin-only shit here :)
/obj/item/storage/box/debug/misc_debug/populate_contents()
	new /obj/item/badminBook(src)
	new /obj/item/reagent_containers/food/drinks/bottle/vodka/badminka(src)
	new /obj/item/crowbar/power(src) // >admin only lol
	new /obj/item/clothing/gloves/fingerless/rapid/admin(src)
	new /obj/item/clothing/under/acj(src)
	new /obj/item/clothing/suit/advanced_protective_suit(src)
	new /obj/item/multitool/ai_detect/admin(src) // for giggles and shits
	new /obj/item/adminfu_scroll(src)
	new /obj/item/teleporter/admin(src)
	new /obj/item/storage/belt/bluespace/admin(src) // god i love storage nesting
	new /obj/item/mining_scanner/admin(src)
	new /obj/item/gun/energy/meteorgun/pen(src)

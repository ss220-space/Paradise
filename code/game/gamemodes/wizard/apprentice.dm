///////// MARK 1: CORE LOGIC //////////

// MARK: BLOCK 1.1: BASE CONTRACT & UI

/obj/item/contract
	name = "contract"
	desc = "A magic contract."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/used = 0
	var/infinity_uses = 0

/obj/item/contract/attack_self(mob/user)
	ui_interact(user)

/obj/item/contract/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/contract/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ApprenticeContract", name)
		ui.open()

/obj/item/contract/ui_data(mob/user)
	var/list/data = list()
	data["isUsed"] = used
	data["isBook"] = istype(src, /obj/item/contract/apprentice_choose_book)
	
	var/list/schools_data = list()
	var/datum/possible_schools/schools = new
	for(var/datum/magick_school/school in schools.schools_list)
		var/list/school_info = list(
			"id" = school.id,
			"name" = school.name,
			"desc" = school.desc
		)
		schools_data += list(school_info)
		
	data["schools"] = schools_data
	return data


// MARK: BLOCK 1.2: APPRENTICE CONTRACT 

/obj/item/contract/apprentice
	name = "apprentice contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."

/obj/item/contract/apprentice/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!ishuman(usr))
		to_chat(usr, "Вы даже не гуманоид... Вы не понимаете как этим пользоваться и что здесь написано.")
		return FALSE

	if(action != "choose_school")
		return TRUE

	handle_choose_school(usr, params["school"])
	return TRUE

/obj/item/contract/apprentice/proc/handle_choose_school(mob/living/carbon/human/teacher, school_id)
	if(used)
		to_chat(teacher, span_notice("You already used this contract!"))
		return

	if(!infinity_uses)
		used = TRUE

	to_chat(teacher, span_notice("Apprentice waiting..."))
	var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_wizard")
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as the wizard apprentice of [teacher.real_name]?", ROLE_WIZARD, TRUE, source = source)

	if(QDELETED(teacher))
		return

	if(length(candidates))
		var/mob/candidate = pick(candidates)
		new /obj/effect/particle_effect/fluid/smoke(teacher.loc)
		var/mob/living/carbon/human/apprentice = new(teacher.loc)
		apprentice.possess_by_player(candidate.key)
		to_chat(apprentice, span_notice("You are the [teacher.real_name]'s apprentice!\nYou are bound by magic contract to follow [teacher.p_their()] orders and help [teacher.p_them()] in accomplishing their goals."))
		var/list/href_list = list("school" = school_id)
		school_href_choose(href_list, teacher, apprentice)
		apprentice.equip_or_collect(new /obj/item/radio/headset(apprentice), ITEM_SLOT_EAR_LEFT)
		apprentice.equip_or_collect(new /obj/item/clothing/under/color/lightpurple(apprentice), ITEM_SLOT_CLOTH_INNER)
		apprentice.equip_or_collect(new /obj/item/clothing/shoes/sandal(apprentice), ITEM_SLOT_FEET)
		apprentice.equip_or_collect(new /obj/item/clothing/suit/wizrobe(apprentice), ITEM_SLOT_CLOTH_OUTER)
		apprentice.equip_or_collect(new /obj/item/clothing/head/wizard(apprentice), ITEM_SLOT_HEAD)
		apprentice.equip_or_collect(new /obj/item/storage/backpack/satchel(apprentice), ITEM_SLOT_BACK)
		apprentice.equip_or_collect(new /obj/item/storage/box/survival(apprentice), ITEM_SLOT_BACKPACK)
		apprentice.equip_or_collect(new /obj/item/teleportation_scroll/apprentice(apprentice), ITEM_SLOT_POCKET_RIGHT)
		var/wizard_name_first = pick(GLOB.wizard_first)
		var/wizard_name_second = pick(GLOB.wizard_second)
		var/randomname = "[wizard_name_first] [wizard_name_second]"
		var/newname = tgui_input_text(apprentice, "You are the wizard's apprentice.\nWould you like to change your name to something else?", "Name change", randomname, max_length = MAX_NAME_LEN)
		if(!newname)
			newname = randomname
		apprentice.mind.name = newname
		apprentice.real_name = newname
		apprentice.name = newname
		var/datum/objective/protect/new_objective = new /datum/objective/protect
		new_objective.owner = apprentice.mind
		new_objective:target = teacher.mind
		new_objective.explanation_text = "Protect [teacher.real_name], the wizard teacher."
		apprentice.mind.objectives += new_objective
		SSticker.mode.apprentices += apprentice.mind
		apprentice.mind.special_role = SPECIAL_ROLE_WIZARD_APPRENTICE
		SSticker.mode.update_wiz_icons_added(apprentice.mind)
		apprentice.faction = list("wizard")
		log_game("[apprentice.key] has become [teacher]'s (ckey: [teacher.key]) apprentice.")
	else
		used = FALSE
		log_game("[teacher] (ckey: [teacher.key]) has failed to spawn aprrentice.")
		to_chat(teacher, span_warning("Unable to reach your apprentice!\nYou can either attack the spellbook with the contract to refund your points, or wait and try again later."))


// MARK: BLOCK 1.3: APPRENTICE CHOOSE BOOK

/obj/item/contract/apprentice_choose_book
	name = "магический учебник"
	desc = "Магический учебник, позволяющий ученику-владельцу определиться в своем обучении."
	icon = 'icons/obj/library.dmi'
	icon_state = "book15"

	var/mob/living/carbon/human/owner

/obj/item/contract/apprentice_choose_book/infinity_book
	name = "магический учебник полукровки"
	desc = "Магический учебник с яркой выраженной подписью какой-то полукровки.\nПохоже он как-то переписал магию, из-за которой учебник не стирает буквы после использования.\nОткуда он у вас?!"
	infinity_uses = 1

/obj/item/contract/apprentice_choose_book/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!ishuman(usr))
		to_chat(usr, "Вы даже не гуманоид... Вы не понимаете как этим пользоваться и что здесь написано.")
		return FALSE

	var/mob/living/carbon/human/apprentice = usr

	if(action == "choose_school")
		var/school_id = params["school"]
		
		if(used)
			to_chat(apprentice, span_notice("Учебник уже был изучен!"))
			return TRUE
			
		if(!infinity_uses)
			used = TRUE

		var/list/href_list = list("school" = school_id)
		school_href_choose(href_list, null, apprentice)
		
	return TRUE


// MARK: BLOCK 1.4: SCHOOL APPLY LOGIC

/obj/item/contract/proc/school_href_choose(href_list, mob/living/carbon/human/teacher, mob/living/carbon/human/apprentice)
	var/school_id = href_list["school"]
	var/datum/possible_schools/schools = new
	for(var/datum/magick_school/school in schools.schools_list)
		if(school_id != school.id)
			continue
		school.owner = apprentice
		school.kit()
		if(teacher)
			to_chat(teacher, "<b>Ваш подопечный прибыл по первому вашему зову.\nПрилежно и усердно обучаясь у вас, он смог выучить одну из школ магии.\n[school.desc]</b>")
			to_chat(apprentice, "<b>Ваше служение не осталось незамеченный. Обучаясь у [teacher.real_name], вы смогли научиться одной из школ магии. [school.desc]</b>")
		else
			to_chat(apprentice, "<b>Выбрана [school.name]. [school.desc]</b>")
		break

/datum/magick_school
	var/name = "Школа Безымянности (перешлите это разработчику)"
	var/id = "no_name"
	var/desc = "Описание заклинаний"
	var/mob/living/carbon/human/owner

/datum/magick_school/proc/kit()
	return 0


// MARK 2: CONTENT & DATA

// MARK: BLOCK 2.1: SCHOOL REGISTRY

/datum/possible_schools
	var/list/datum/schools_list = list (
		new /datum/magick_school.fire,
		new /datum/magick_school.healer,
		new /datum/magick_school.motion,
		new /datum/magick_school.defense,
		new /datum/magick_school.stand,
		new /datum/magick_school.sabotage,
		new /datum/magick_school.sculpt,
		new /datum/magick_school.instability,
		new /datum/magick_school.vision,
		new /datum/magick_school.replace,
		new /datum/magick_school.destruction,
		new /datum/magick_school.singulo,
		new /datum/magick_school.blood,
		new /datum/magick_school.necromantic,
		new /datum/magick_school/lavaland,
	)


// MARK: BLOCK 2.2: Magick Schools & GEAR

// --- SCHOOL OF HEALING ---
/datum/magick_school/healer
	name = "Школа Исцеления"
	id = "healer"
	desc = "Школа, практикующие заклинания для выживания и исцеления травм, с созданием защитного барьера для самозащиты."
/datum/magick_school/healer/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/charge(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/summonitem(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/forcewall(null))
	owner.equip_or_collect(new /obj/item/gun/magic/staff/healing(owner), ITEM_SLOT_HAND_RIGHT)

	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/healmage(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/healmage(owner), ITEM_SLOT_HEAD)

// --- SCHOOL OF SPACE ---
/datum/magick_school/motion
	name = "Школа Пространства"
	id = "motion"
	desc = "Школа, практикующая разнообразные техники перемещения. Эфирный прыжок, телепортация и блинк заставят возненавидеть назойливого волшебника!"
/datum/magick_school/motion/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/ethereal_jaunt(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/area_teleport/teleport(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/turf_teleport/blink(null))

	owner.equip_or_collect(new /obj/item/clothing/suit/space/suit/psyamp, ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/helmet/space/head/psyamp, ITEM_SLOT_HEAD)

/obj/item/clothing/suit/space/suit/psyamp
	magical = TRUE
	slowdown = 0
	icon_state = "psyamp"
	name = "Роба межпространства"
	desc = "Магическая роба прислужника школы пространства, оберегающий владельца от перемещений в агрессивных средах."
	permeability_coefficient = 0.01
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 30, BOMB = 20, BIO = 20, FIRE = 100, ACID = 100)
	strip_delay = 5 SECONDS
	put_on_delay = 5 SECONDS
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/helmet/space/head/psyamp
	magical = TRUE
	icon_state = "amp"
	name = "Капюшон Межпространства"
	desc = "Магический головной убор робы прислужника школы пространства, оберегающий от перемещений в агрессивных средах."
	gas_transfer_coefficient = 0.01
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 30, BOMB = 20, BIO = 20, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF

// --- SCHOOL OF SABOTAGE ---
/datum/magick_school/sabotage
	name = "Школа Диверсии"
	id = "sabotage"
	desc = "Школа, практикующаяся в нанесении ущерба грязным технологиям магглов. Магглы не любят, когда технологии восстают против них самих."
/datum/magick_school/sabotage/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/emplosion/disable_tech(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/charge(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/summonitem(null))
	owner.equip_or_collect(new /obj/item/gun/magic/staff/animate(owner), ITEM_SLOT_HAND_RIGHT)
	owner.equip_or_collect(new /obj/item/clothing/suit/storage/blacktrenchcoat/suit/saboteur, ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/fedora/head/saboteur, ITEM_SLOT_HEAD)

/obj/item/clothing/suit/storage/blacktrenchcoat/suit/saboteur
	magical = TRUE
	name = "Роба саботёра"
	desc = "Магическая роба-саботёра. Стильная и приталенная!"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 30, BOMB = 20, BIO = 20, FIRE = 100, ACID = 100)
	strip_delay = 5 SECONDS
	put_on_delay = 5 SECONDS
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/fedora/head/saboteur
	magical = TRUE
	name = "Федора саботёра"
	desc = "Магическая федора-саботёра. Стильная и уважаемая!"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 30, BOMB = 20, BIO = 20, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	strip_delay = 5 SECONDS
	put_on_delay = 5 SECONDS

// --- SCHOOL OF DEFENSE ---
/datum/magick_school/defense
	name = "Школа Защиты"
	id = "defense"
	desc = "Школа, практикующая заклинания защиты, не допускающая допуск неприятеля и заставляющая его держать дистанцию!"
/datum/magick_school/defense/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/forcewall(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/forcewall/greater(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/repulse(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/sacred_flame(null))
	ADD_TRAIT(owner, TRAIT_RESIST_HEAT, MAGIC_TRAIT)
	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/magusdefender(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/magusdefender(owner), ITEM_SLOT_HEAD)

// --- SCHOOL OF FIRE ---
/datum/magick_school/fire
	name = "Школа Огня"
	id = "fire"
	desc = "Классическая школа огня, прислужники которой искусно владеют стихией огня!"
/datum/magick_school/fire/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/smoke(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/fireball(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/sacred_flame(null))
	ADD_TRAIT(owner, TRAIT_RESIST_HEAT, MAGIC_TRAIT)
	owner.equip_or_collect(new /obj/item/clothing/suit/victcoat/red/suit/fire_robe, ITEM_SLOT_CLOTH_OUTER)

/obj/item/clothing/suit/victcoat/red/suit/fire_robe
	name = "Роба огня"
	desc = "Магическая роба последователей школы огня."
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 30, BOMB = 20, BIO = 20, FIRE = 100, ACID = 100)
	strip_delay = 5 SECONDS
	put_on_delay = 5 SECONDS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	magical = TRUE

// --- SCHOOL OF SCULPTURE ---
/datum/magick_school/sculpt
	name = "Школа Ваяния"
	id = "sculpt"
	desc = "Школа, практикующая оживление статики, и каменение динамики."
/datum/magick_school/sculpt/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/touch/flesh_to_stone(null))
	owner.equip_or_collect(new /obj/item/gun/magic/staff/animate(owner), ITEM_SLOT_HAND_RIGHT)

	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/artmage(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/artmage(owner), ITEM_SLOT_HEAD)

// --- SCHOOL OF GUARDIANS ---
/datum/magick_school/stand
	name = "Школа Хранителей"
	id = "stand"
	desc = "Школа, практикующее владение собственным стендом-защитником с защитной стеной."
/datum/magick_school/stand/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/forcewall/greater(null))
	owner.equip_or_collect(new /obj/item/guardiancreator(owner), ITEM_SLOT_HAND_RIGHT)

	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/magusdefender(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/magusdefender(owner), ITEM_SLOT_HEAD)

// --- SCHOOL OF INSTABILITY ---
/datum/magick_school/instability
	name = "Школа Неустойчивости"
	id = "instability"
	desc = "Школа, не позволяющая магглам стоять в полный рост перед волшебниками. Ей даже интересовалась федерация Клоунов."
/datum/magick_school/instability/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/summonitem(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/repulse(null))
	owner.equip_or_collect(new /obj/item/gun/magic/staff/slipping(owner), ITEM_SLOT_HAND_RIGHT)
	owner.equip_or_collect(new /obj/item/bikehorn, ITEM_SLOT_BELT)

// --- SCHOOL OF BLOOD ---
/datum/magick_school/blood
	name = "Школа Крови"
	id = "blood"
	desc = "Запретная школа, вызывающая опасения у архимагов, но допущенная к изучению. Юный последователь крови получает собственную робу, цепь и камни душ."
/datum/magick_school/blood/kit()
	owner.equip_or_collect(new /obj/item/storage/belt/soulstone/full(owner), ITEM_SLOT_BELT)
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/conjure/construct(null))

	var/obj/item/melee/chainofcommand/chain = new
	chain.name = "Жертвенная Цепь"
	chain.desc = "Цепь последователя школы крови для нанесения увечий и пускания крови."
	chain.force = 15
	owner.equip_or_collect(chain, ITEM_SLOT_HAND_RIGHT)
	owner.equip_or_collect(new /obj/item/clothing/suit/hooded/cultrobes/suit/sacrificial_robe, ITEM_SLOT_CLOTH_OUTER)

/obj/item/clothing/suit/hooded/cultrobes/suit/sacrificial_robe
	name = "Жертвенная роба"
	desc = "Магическая роба последователей школы крови."
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 30, BOMB = 20, BIO = 20, FIRE = 100, ACID = 100)
	strip_delay = 5 SECONDS
	put_on_delay = 5 SECONDS
	resistance_flags = FIRE_PROOF | ACID_PROOF

// --- SCHOOL OF NECROMANCY ---
/datum/magick_school/necromantic
	name = "Школа Некромантии"
	id = "necro"
	desc = "Запретная школа, заставляющая мертвых служить некроманту, заключившему контракт души."
/datum/magick_school/necromantic/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/lichdom(null))
	owner.equip_or_collect(new /obj/item/necromantic_stone(owner), ITEM_SLOT_POCKET_LEFT)
	owner.equip_or_collect(new /obj/item/necromantic_stone(owner), ITEM_SLOT_POCKET_RIGHT)

	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/necromage(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/necromage(owner), ITEM_SLOT_HEAD)

// --- SCHOOL OF VISION ---
/datum/magick_school/vision
	name = "Школа Прозрения"
	id = "vision"
	desc = "Древняя школа, практикующее безмерное видение с лишением зрения недостойных. Послужники носят уникальные робы."
/datum/magick_school/vision/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/trigger/blind(null))
	owner.equip_or_collect(new /obj/item/scrying(owner), ITEM_SLOT_HAND_RIGHT)
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, MAGIC_TRAIT)
	ADD_TRAIT(owner, TRAIT_NIGHT_VISION, MAGIC_TRAIT)
	owner.update_sight()
	to_chat(owner, span_notice("The walls suddenly disappear."))

	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/visionmage(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/visionmage(owner), ITEM_SLOT_HEAD)

// --- SCHOOL OF SINGULARITY ---
/datum/magick_school/singulo
	name = "Школа Сингулярности"
	id = "singulo"
	desc = "Древняя школа, практикующая древние познания владения сингулярности."
/datum/magick_school/singulo/kit()
	owner.equip_or_collect(new /obj/item/twohanded/singularityhammer(owner), ITEM_SLOT_HAND_RIGHT)
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/repulse(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/summonitem(null))

	var/obj/item/clothing/suit/wizrobe/magusred/suit = new
	suit.magical = TRUE
	suit.icon_state = "hardsuit-singuloth"
	suit.item_state = "singuloth_hardsuit"
	suit.name = "Роба межпространства"
	suit.desc = "Древняя броня последователя школы сингулярности."
	owner.equip_or_collect(suit, ITEM_SLOT_CLOTH_OUTER)
	
	var/obj/item/clothing/head/wizard/magus/head = new
	head.magical = TRUE
	head.icon_state = "hardsuit0-singuloth"
	head.item_state = "singuloth_helm"
	head.name = "Капюшон межпространства"
	head.desc = "Древний шлем последователя школы сингулярности."
	owner.equip_or_collect(head, ITEM_SLOT_HEAD)

// --- SCHOOL OF REPLACE ---
/datum/magick_school/replace
	name = "Школа Подмены"
	id = "replace"
	desc = "Старая школа, практикующая заклинания для чтения без мантии с подменам разума и открытием закрытых дверей."
/datum/magick_school/replace/kit() 
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/knock(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/mind_transfer(null))

	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/psypurple(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/amp(owner), ITEM_SLOT_HEAD)

// --- SCHOOL OF DESTRUCTION ---
/datum/magick_school/destruction
	name = "Школа Разрушения"
	id = "destruction"
	desc = "Старая школа, практикующая заклинания на нанесении ущерба."
/datum/magick_school/destruction/kit() 
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/projectile/magic_missile(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/fireball(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/charge_up/bounce/lightning(null))

	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/magusred(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/magus(owner), ITEM_SLOT_HEAD)

// --- SCHOOL OF LAVALAND ---
/datum/magick_school/lavaland
	name = "Школа Лазиса"
	id = "lavaland"
	desc = "Школа, использующая традиции магии пеплоходцев."
/datum/magick_school/lavaland/kit()
	owner.faction += "mining"
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/conjure/legion_skulls)
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/goliath_tentacles)
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/goliath_dash)
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/watchers_look)
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/touch/healtouch/advanced)

	owner.equip_or_collect(new /obj/item/clothing/under/ash_walker(owner), ITEM_SLOT_CLOTH_INNER)
	owner.equip_or_collect(new /obj/item/clothing/gloves/color/black/goliath(owner), ITEM_SLOT_GLOVES)
	owner.equip_or_collect(new /obj/item/clothing/suit/hooded/goliath/wizard(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/twohanded/spear/bonespear, ITEM_SLOT_HAND_RIGHT)

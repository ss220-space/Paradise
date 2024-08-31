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

/////////Apprentice Contract//////////

/obj/item/contract/apprentice
	name = "apprentice contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."

/obj/item/contract/apprentice/Topic(href, href_list)
	..()
	if(!ishuman(usr))
		to_chat(usr, "Вы даже не гуманоид... Вы не понимаете как этим пользоваться и что здесь написано.")
		return FALSE

	var/mob/living/carbon/human/teacher = usr

	if(teacher.incapacitated() || HAS_TRAIT(teacher, TRAIT_HANDS_BLOCKED))
		return FALSE

	if(loc == teacher || (in_range(src, teacher) && isturf(loc)))
		teacher.set_machine(src)
		if(href_list["school"])
			if(used)
				to_chat(teacher, "<span class='notice'>You already used this contract!</span>")
				return
			if (!infinity_uses)
				used = 1
			to_chat(teacher, "<span class='notice'>Apprentice waiting...</span>")
			var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_wizard")
			var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as the wizard apprentice of [teacher.real_name]?", ROLE_WIZARD, TRUE, source = source)
			if(length(candidates))
				var/mob/C = pick(candidates)
				new /obj/effect/particle_effect/smoke(teacher.loc)
				var/mob/living/carbon/human/apprentice = new/mob/living/carbon/human(teacher.loc)
				apprentice.key = C.key
				to_chat(apprentice, "<span class='notice'>You are the [teacher.real_name]'s apprentice! You are bound by magic contract to follow [teacher.p_their()] orders and help [teacher.p_them()] in accomplishing their goals.</span>")

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
				var/newname = sanitize(copytext_char(input(apprentice, "You are the wizard's apprentice. Would you like to change your name to something else?", "Name change", randomname) as null|text,1,MAX_NAME_LEN))

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
				used = 0
				log_game("[teacher] (ckey: [teacher.key]) has failed to spawn aprrentice.")
				to_chat(teacher, "<span class='warning'>Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later.</span>")
	return

/////////Apprentice Choose Book//////////

/obj/item/contract/apprentice_choose_book
	name = "магический учебник"
	desc = "Магический учебник, позволяющий ученику-владельцу определиться в своем обучении."
	icon = 'icons/obj/library.dmi'
	icon_state = "book15"

	var/mob/living/carbon/human/owner

/obj/item/contract/apprentice_choose_book/infinity_book
	name = "магический учебник полукровки"
	desc = "Магический учебник с яркой выраженной подписью какой-то полукровки. Похоже он как-то переписал магию, из-за которой учебник не стирает буквы после использования. Откуда он у вас?!"
	infinity_uses = 1

/obj/item/contract/apprentice_choose_book/Topic(href, href_list)
	..()
	if(!ishuman(usr))
		to_chat(usr, "Вы даже не гуманоид... Вы не понимаете как этим пользоваться и что здесь написано.")
		return FALSE

	var/mob/living/carbon/human/apprentice = usr

	if(apprentice.incapacitated() || HAS_TRAIT(apprentice, TRAIT_HANDS_BLOCKED))
		return FALSE

	if(loc == apprentice || (in_range(src, apprentice) && isturf(loc)))
		apprentice.set_machine(src)
		if(href_list["school"])
			if(used)
				to_chat(apprentice, "<span class='notice'>Учебник уже был изучен!</span>")
				return
			if (!infinity_uses)
				used = 1

			school_href_choose(href_list, null, apprentice)
	return

/////////Choose Spells Pack//////////

/obj/item/contract/proc/school_href_choose(href_list, mob/living/carbon/human/teacher, mob/living/carbon/human/apprentice)
	var/school_id = href_list["school"]
	var/datum/possible_schools/schools = new
	for (var/datum/magick_school/school in schools.schools_list)
		if (school_id != school.id)
			continue
		school.owner = apprentice
		school.kit()
		if (teacher)
			to_chat(teacher, "<B>Ваш подопечный прибыл по первому вашему зову. Прилежно и усердно обучаясь у вас, он смог выучить одну из школ магии. [school.desc]")
			to_chat(apprentice, "<B>Ваше служение не осталось незамеченный. Обучаясь у [teacher.real_name], вы смогли научиться одной из школ магии. [school.desc]")
		else
			to_chat(apprentice, "<B>Выбрана [school.name]. [school.desc]")
		break

/obj/item/contract/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	if(used)
		dat += used_contract()
	else
		dat += tittle()

		var/datum/possible_schools/schools = new
		for (var/datum/magick_school/school in schools.schools_list)
			dat += "<A href='byond://?src=[UID()];school=[school.id]'>[school.name]</A><BR>"
			dat += "<I>[school.desc]</I><BR>"

	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

///Титульник в контракте
/obj/item/contract/proc/tittle()
	var/dat = "<B>Contract of apprenticeship:</B><BR>"
	dat += "<I>Using this contract, you may summon an apprentice to aid you on your mission.</I><BR>"
	dat += "<I>If you are unable to establish contact with your apprentice, you can feed the contract back to the spellbook to refund your points.</I><BR>"

	dat += "<B>Which school of magic is your apprentice studying?:</B><BR>"
	return dat

/obj/item/contract/apprentice_choose_book/tittle()
	var/dat = "<B>Магический учебник:</B><BR>"
	dat += "<I>Изучив этот учебник, вы определитесь в магии, которую будете практиковать.</I><BR>"
	dat += "<I>Перед тем как выбрать один из путей, хорошо подумайте и поговорите со своим учителем для получении рекомендаций.</I><BR>"
	dat += "<I>Если учитель не настроен на разговор - ничего страшного! В данном учебнике приведено краткое описание возможных путей.</I><BR>"

	dat += "<BR><B>Какую школу магии вы хотели бы изучать?:</B><BR>"
	return dat

///Сообщение выдаваемое при использовании использованных контрактов
/obj/item/contract/proc/used_contract()
	return "<span class='notice'>You have already summoned your apprentice.</span><BR>"

/obj/item/contract/apprentice_choose_book/used_contract()
	return "<span class='notice'>Письмена стерты, а все страницы пусты. Похоже учебник уже был изучен.</span><BR>"

/////////Magick Schools//////////

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


/datum/magick_school
	var/name = "Школа Безымянности (перешлите это разработчику)"
	var/id = "no_name"
	var/desc = "Описание заклинаний"
	var/mob/living/carbon/human/owner

/datum/magick_school/proc/kit()
	return 0


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
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 30, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 100)
	strip_delay = 5 SECONDS
	put_on_delay = 5 SECONDS
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/helmet/space/head/psyamp
	magical = TRUE
	icon_state = "amp"
	name = "Капюшон Межпространства"
	desc = "Магический головной убор робы прислужника школы пространства, оберегающий от перемещений в агрессивных средах."
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 30, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	strip_delay = 5 SECONDS
	put_on_delay = 5 SECONDS


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
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 30, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 100)
	strip_delay = 5 SECONDS
	put_on_delay = 5 SECONDS
	resistance_flags = FIRE_PROOF | ACID_PROOF


/obj/item/clothing/head/fedora/head/saboteur
	magical = TRUE
	name = "Федора саботёра"
	desc = "Магическая федора-саботёра. Стильная и уважаемая!"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 30, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	strip_delay = 5 SECONDS
	put_on_delay = 5 SECONDS


/datum/magick_school/defense
	name = "Школа Защиты"
	id = "defense"
	desc = "Школа, практикующая заклинания защиты, не допускающая допуск неприятеля и заставляющая его держать дистанцию!"

/datum/magick_school/defense/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/forcewall(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/forcewall/greater(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/repulse(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/sacred_flame(null))
	ADD_TRAIT(owner, TRAIT_RESIST_HEAT, MAGIC_TRAIT)	//sacred_flame из-за не совсем верной выдачи, без этого, не выдает защиту от огня.

	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/magusdefender(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/magusdefender(owner), ITEM_SLOT_HEAD)


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
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 30, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 100)
	strip_delay = 5 SECONDS
	put_on_delay = 5 SECONDS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	magical = TRUE

/datum/magick_school/sculpt
	name = "Школа Ваяния"
	id = "sculpt"
	desc = "Школа, практикующая оживление статики, и каменение динамики."

/datum/magick_school/sculpt/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/touch/flesh_to_stone(null))
	owner.equip_or_collect(new /obj/item/gun/magic/staff/animate(owner), ITEM_SLOT_HAND_RIGHT)

	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/artmage(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/artmage(owner), ITEM_SLOT_HEAD)

/datum/magick_school/stand
	name = "Школа Хранителей"
	id = "stand"
	desc = "Школа, практикующее владение собственным стендом-защитником с защитной стеной."

/datum/magick_school/stand/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/forcewall/greater(null))
	owner.equip_or_collect(new /obj/item/guardiancreator(owner), ITEM_SLOT_HAND_RIGHT)

	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/magusdefender(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/magusdefender(owner), ITEM_SLOT_HEAD)

/datum/magick_school/instability
	name = "Школа Неустойчивости"
	id = "instability"
	desc = "Школа, не позволяющая магглам стоять в полный рост перед волшебниками. Ей даже интересовалась федерация Клоунов."

/datum/magick_school/instability/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/summonitem(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/repulse(null))
	owner.equip_or_collect(new /obj/item/gun/magic/staff/slipping(owner), ITEM_SLOT_HAND_RIGHT)
	owner.equip_or_collect(new /obj/item/bikehorn, ITEM_SLOT_BELT)


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
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 30, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 100)
	strip_delay = 5 SECONDS
	put_on_delay = 5 SECONDS
	magical = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF

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


/datum/magick_school/vision
	name = "Школа Прозрения"
	id = "vision"
	desc = "Древняя школа, практикующее безмерное видение с лишением зрения недостойных. Послужники носят уникальные робы."

/datum/magick_school/vision/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/trigger/blind(null))
	owner.equip_or_collect(new /obj/item/scrying(owner), ITEM_SLOT_HAND_RIGHT)
	if(!HAS_TRAIT_FROM(owner, TRAIT_XRAY, SCRYING_ORB_TRAIT))
		ADD_TRAIT(owner, TRAIT_XRAY, SCRYING_ORB_TRAIT)
		owner.see_in_dark = 8
		owner.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		owner.update_sight()
		owner.update_misc_effects()
		to_chat(owner, span_notice("The walls suddenly disappear."))

	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/visionmage(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/visionmage(owner), ITEM_SLOT_HEAD)


/datum/magick_school/singulo
	name = "Школа Сингулярности"
	id = "singulo"
	desc = "Древняя школа, практикующая древние познания владения сингулярности."

/datum/magick_school/singulo/kit()
	owner.equip_or_collect(new /obj/item/twohanded/singularityhammer(owner), ITEM_SLOT_HAND_RIGHT)
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/repulse(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/summonitem(null))

	//Всё тот же костюм мага воителя, но с спрайтом сингулярного рыцаря.
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


/datum/magick_school/replace
	name = "Школа Подмены"
	id = "replace"
	desc = "Старая школа, практикующая заклинания для чтения без мантии с подменам разума и открытием закрытых дверей."

/datum/magick_school/replace/kit()		//старый набор
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/knock(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/mind_transfer(null))

	//Нацепляем простой фиолетовый балахон
	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/psypurple(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/amp(owner), ITEM_SLOT_HEAD)


/datum/magick_school/destruction
	name = "Школа Разрушения"
	id = "destruction"
	desc = "Старая школа, практикующая заклинания на нанесении ущерба."

/datum/magick_school/destruction/kit()	//старый набор
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/projectile/magic_missile(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/fireball(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/charge_up/bounce/lightning(null))

	//Стандартный костюм мага-воителя, который есть в башне волшебника и так.
	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/magusred(owner), ITEM_SLOT_CLOTH_OUTER)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/magus(owner), ITEM_SLOT_HEAD)

/datum/magick_school/lavaland
	name = "Школа Лаваленда"
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


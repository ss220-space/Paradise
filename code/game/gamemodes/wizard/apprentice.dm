/obj/item/contract
	name = "contract"
	desc = "A magic contract."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/used = 0

/////////apprentice Contract//////////

/obj/item/contract/apprentice
	name = "apprentice contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."

/obj/item/contract/apprentice/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/teacher = usr

	if(teacher.stat || teacher.restrained())
		return
	if(!ishuman(teacher))
		return 1

	if(loc == teacher || (in_range(src, teacher) && isturf(loc)))
		teacher.set_machine(src)
		if(href_list["school"])
			if(used)
				to_chat(teacher, "You already used this contract!")
				return
			used = 1
			to_chat(teacher, "apprentice waiting...")
			var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_wizard")
			var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as the wizard apprentice of [teacher.real_name]?", ROLE_WIZARD, TRUE, source = source)
			if(length(candidates))
				var/mob/C = pick(candidates)
				new /obj/effect/particle_effect/smoke(teacher.loc)
				var/mob/living/carbon/human/apprentice = new/mob/living/carbon/human(teacher.loc)
				apprentice.key = C.key
				to_chat(apprentice, "<B>You are the [teacher.real_name]'s apprentice! You are bound by magic contract to follow [teacher.p_their()] orders and help [teacher.p_them()] in accomplishing their goals.")

				school_href_choose(href_list, teacher, apprentice)

				apprentice.equip_to_slot_or_del(new /obj/item/radio/headset(apprentice), slot_l_ear)
				apprentice.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(apprentice), slot_w_uniform)
				apprentice.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(apprentice), slot_shoes)
				apprentice.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(apprentice), slot_wear_suit)
				apprentice.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(apprentice), slot_head)
				apprentice.equip_to_slot_or_del(new /obj/item/storage/backpack(apprentice), slot_back)
				apprentice.equip_to_slot_or_del(new /obj/item/storage/box(apprentice), slot_in_backpack)
				apprentice.equip_to_slot_or_del(new /obj/item/teleportation_scroll/apprentice(apprentice), slot_r_store)
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
				new_objective.owner = apprentice:mind
				new_objective:target = teacher:mind
				new_objective.explanation_text = "Protect [teacher.real_name], the wizard teacher."
				apprentice.mind.objectives += new_objective
				SSticker.mode.apprentices += apprentice.mind
				apprentice.mind.special_role = SPECIAL_ROLE_WIZARD_APPRENTICE
				SSticker.mode.update_wiz_icons_added(apprentice.mind)
				apprentice.faction = list("wizard")
			else
				used = 0
				to_chat(teacher, "Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later.")
	return

/////////apprentice Choose Book//////////

/obj/item/contract/apprentice_choose_book
	name = "Магический учебник"
	desc = "Магический учебник, позволяющий ученику-владельцу определиться в своем обучении."
	icon = 'icons/obj/library.dmi'
	icon_state = "book15"

	var/mob/living/carbon/human/owner

/obj/item/contract/apprentice_choose_book/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/apprentice = usr

	if(apprentice.stat || apprentice.restrained())
		return
	if(!ishuman(apprentice))
		return 1

	if(loc == apprentice || (in_range(src, apprentice) && isturf(loc)))
		apprentice.set_machine(src)
		if(href_list["school"])
			if(used)
				to_chat(apprentice, "Учебник уже был вами изучен!")
				return
			used = 1

			school_href_choose(href_list, null, apprentice)
	return

/////////Choose Spells Pack//////////

/obj/item/contract/proc/school_href_choose(href_list, mob/living/carbon/human/teacher, mob/living/carbon/human/apprentice)
	switch(href_list["school"])
		if("destruction")
			apprentice.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(null))
			apprentice.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/click/fireball(null))
			if (teacher)
				to_chat(teacher, "<B>Your service has not gone unrewarded, however. Studying under [teacher.real_name], you have learned powerful, destructive spells. You are able to cast magic missile and fireball.")
		if("bluespace")
			apprentice.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(null))
			apprentice.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null))
			if (teacher)
				to_chat(teacher, "<B>Your service has not gone unrewarded, however. Studying under [teacher.real_name], you have learned reality bending mobility spells. You are able to cast teleport and ethereal jaunt.")
		if("healing")
			apprentice.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/charge(null))
			apprentice.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall(null))
			apprentice.equip_to_slot_or_del(new /obj/item/gun/magic/staff/healing(apprentice), slot_r_hand)
			if (teacher)
				to_chat(teacher, "<B>Your service has not gone unrewarded, however. Studying under [teacher.real_name], you have learned livesaving survival spells. You are able to cast charge and forcewall.")
		if("robeless")
			apprentice.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(null))
			apprentice.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/click/mind_transfer(null))
			if (teacher)
				to_chat(teacher, "<B>Your service has not gone unrewarded, however. Studying under [teacher.real_name], you have learned stealthy, robeless spells. You are able to cast knock and mindswap.")

/obj/item/contract/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat = {"<meta charset="UTF-8">"}
	if(used)
		dat += used_contract()
	else
		dat += tittle()

		dat += "<A href='byond://?src=[UID()];school=destruction'>Destruction</A><BR>"
		dat += "<I>Your apprentice is skilled in offensive magic. They know Magic Missile and Fireball.</I><BR>"

		dat += "<A href='byond://?src=[UID()];school=bluespace'>Bluespace Manipulation</A><BR>"
		dat += "<I>Your apprentice is able to defy physics, melting through solid objects and travelling great distances in the blink of an eye. They know Teleport and Ethereal Jaunt.</I><BR>"

		dat += "<A href='byond://?src=[UID()];school=healing'>Healing</A><BR>"
		dat += "<I>Your apprentice is training to cast spells that will aid your survival. They know Forcewall and Charge and come with a Staff of Healing.</I><BR>"

		dat += "<A href='byond://?src=[UID()];school=robeless'>Robeless</A><BR>"
		dat += "<I>Your apprentice is training to cast spells without their robes. They know Knock and Mindswap.</I><BR>"
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

	dat += "<B>Какую школу магии вы хотели бы изучать?:</B><BR>"
	return dat

///Сообщение выдаваемое при использовании использованных контрактов
/obj/item/contract/proc/used_contract()
	return "<B>You have already summoned your apprentice.</B><BR>"

/obj/item/contract/apprentice_choose_book/used_contract()
	return "<B>Вами уже был изучен учебник.</B><BR>"


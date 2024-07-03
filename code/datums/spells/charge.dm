/obj/effect/proc_holder/spell/charge
	name = "Charge"
	desc = "Это заклинание можно использовать для подзарядки различных предметов, находящихся в ваших руках, от магических артефактов до электрических компонентов. Изобретательный волшебник может даже использовать его для наделения магической силой своего товарища по магии."
	school = "transmutation"
	base_cooldown = 1 MINUTES
	clothes_req = FALSE
	human_req = FALSE
	invocation = "DIRI CEL"
	invocation_type = "whisper"
	cooldown_min = 40 SECONDS //50 deciseconds reduction per rank
	action_icon_state = "charge"


/obj/effect/proc_holder/spell/charge/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/charge/cast(list/targets, mob/user = usr)
	for(var/mob/living/L in targets)
		var/list/hand_items = list(L.get_active_hand(),L.get_inactive_hand())
		var/charged_item = null
		var/burnt_out = FALSE

		if(L.pulling && (isliving(L.pulling)))
			var/mob/living/M =	L.pulling
			if(LAZYLEN(M.mob_spell_list) || (M.mind && LAZYLEN(M.mind.spell_list)))
				for(var/obj/effect/proc_holder/spell/spell as anything in M.mob_spell_list)
					spell.cooldown_handler.revert_cast()
				if(M.mind)
					for(var/obj/effect/proc_holder/spell/spell as anything in M.mind.spell_list)
						spell.cooldown_handler.revert_cast()
				to_chat(M, "<span class='notice'>Вы чувствуете, как через вас течет необузданная магическая энергия!</span>")
			else
				to_chat(M, "<span class='notice'>На мгновение вы чувствуете себя очень странно, но это ощущение быстро исчезает.</span>")
				burnt_out = TRUE
			charged_item = M
			break
		for(var/obj/item in hand_items)
			if(istype(item, /obj/item/spellbook))
				if(istype(item, /obj/item/spellbook/oneuse))
					var/obj/item/spellbook/oneuse/I = item
					if(prob(80))
						L.visible_message("<span class='warning'>[I] загорается! span>")
						qdel(I)
					else
						I.used = FALSE
						charged_item = I
						break
				else
					to_chat(L, "<span class='caution'>На лицевой стороне обложки появляются светящиеся красные буквы...</span>")
					to_chat(L, "<span class='warning'>[pick("ХОРОШАЯ ПОПЫТКА, НО НЕТ!","УМНО, НО НЕДОСТАТОЧНО УМНО!","ТАКОЙ ВОПИЮЩИЙ ЧИЗИНГ И СТАЛ ПРИЧИНОЙ ОДОБРЕНИЯ ВАШЕЙ ЗАЯВКИ!", "МИЛО!", "ТЫ ЖЕ НЕ ДУМАЛ, ЧТО БУДЕТ ТАК ПРОСТО?")]</span>")
					burnt_out = TRUE

			else if(istype(item, /obj/item/book/granter))
				var/obj/item/book/granter/I = item
				if(prob(80))
					L.visible_message("<span class='warning'>[I] загорается!</span>")
					qdel(I)
				else
					I.uses += 1
					charged_item = I
					break

			else if(istype(item, /obj/item/gun/magic))
				var/obj/item/gun/magic/I = item
				if(prob(80) && !I.can_charge)
					I.max_charges--
				if(I.max_charges <= 0)
					I.max_charges = 0
					burnt_out = TRUE
				I.charges = I.max_charges
				if(istype(item,/obj/item/gun/magic/wand) && I.max_charges != 0)
					var/obj/item/gun/magic/W = item
					W.icon_state = initial(W.icon_state)
				charged_item = I
				break

			else if(istype(item, /obj/item/stock_parts/cell/))
				var/obj/item/stock_parts/cell/C = item
				if(!C.self_recharge)
					if(prob(80))
						C.maxcharge -= 200
					if(C.maxcharge <= 1) //Div by 0 protection
						C.maxcharge = 1
						burnt_out = TRUE
				C.charge = C.maxcharge
				charged_item = C
				break

			else if(item.contents)
				var/obj/I = null
				for(I in item.contents)
					if(istype(I, /obj/item/stock_parts/cell/))
						var/obj/item/stock_parts/cell/C = I
						if(!C.self_recharge)
							if(prob(80))
								C.maxcharge -= 200
							if(C.maxcharge <= 1) //Div by 0 protection
								C.maxcharge = 1
								burnt_out = TRUE
						C.charge = C.maxcharge
						item.update_icon()
						charged_item = item
						break
		if(!charged_item)
			to_chat(L, "<span class='notice'>Вы чувствуете, как к вашим рукам приливает магическая сила, но это ощущение быстро исчезает...</span>")
		else if(burnt_out)
			to_chat(L, "<span class='caution'>[charged_item] не реагирует на заклинание...</span>")
		else

			to_chat(L, "<span class='notice'>[charged_item] внезапно становится очень тёплым!</span>")

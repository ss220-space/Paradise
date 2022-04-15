////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food/pill
	name = "таблетка"
	desc = "какая-то таблетка."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	item_state = "pill"
	possible_transfer_amounts = null
	volume = 100
	consume_sound = null
	can_taste = FALSE
	antable = FALSE

/obj/item/reagent_containers/food/pill/New()
	..()
	if(!icon_state)
		icon_state = "pill[rand(1,20)]"

/obj/item/reagent_containers/food/pill/attack_self(mob/user)
	return

/obj/item/reagent_containers/food/pill/attack(mob/living/carbon/M, mob/user, def_zone)
	if(!istype(M))
		return FALSE
	bitesize = reagents.total_volume
	if(M.eat(src, user))
		qdel(src)
		return TRUE
	return FALSE

/obj/item/reagent_containers/food/pill/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return

	if(target.is_open_container() != 0 && target.reagents)
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty. Cant dissolve [src].</span>")
			return

		to_chat(user, "<span class='notify'>You dissolve [src] in [target].</span>")
		reagents.trans_to(target, reagents.total_volume)
		for(var/mob/O in viewers(2, user))
			O.show_message("<span class='warning'>[user] puts something in [target].</span>", 1)
		spawn(5)
			qdel(src)

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

//Pills
/obj/item/reagent_containers/food/pill/tox
	name = "Таблетка с токсинами"
	desc = "Очень токсичная."
	icon_state = "pill21"
	list_reagents = list("toxin" = 50)

/obj/item/reagent_containers/food/pill/initropidril
	name = "Таблетка инитропидрила"
	desc = "Не глотать."
	icon_state = "pill21"
	list_reagents = list("initropidril" = 50)

/obj/item/reagent_containers/food/pill/fakedeath
	name = "Таблетка ложной смерти"
	desc = "Проглотите, затем прилягте, чтобы прикинуться мёртвым. Встаньте, чтобы прекратить. Немота прилагается."
	icon_state = "pill4"
	list_reagents = list("capulettium_plus" = 50)

/obj/item/reagent_containers/food/pill/adminordrazine
	name = "Таблетка админодразина"
	desc = "Это магия. Мы не собираемся это объяснять."
	icon_state = "pill16"
	list_reagents = list("adminordrazine" = 50)

/obj/item/reagent_containers/food/pill/morphine
	name = "Таблетка морфина"
	desc = "Обычно используется для лечения бессонницы."
	icon_state = "pill8"
	list_reagents = list("morphine" = 30)

/obj/item/reagent_containers/food/pill/methamphetamine
	name = "Таблетка метамфетамина"
	desc = "Улучшает концентрацию."
	icon_state = "pill8"
	list_reagents = list("methamphetamine" = 5)

/obj/item/reagent_containers/food/pill/haloperidol
	name = "Таблетка галоперидола"
	desc = "Haloperidol is an anti-psychotic use to treat psychiatric problems."
	icon_state = "pill8"
	list_reagents = list("haloperidol" = 15)

/obj/item/reagent_containers/food/pill/happy
	name = "Таблетка счастья"
	desc = "Happy happy joy joy!"
	icon_state = "pill18"
	list_reagents = list("space_drugs" = 15, "sugar" = 15)

// TODO: l10n
/obj/item/reagent_containers/food/pill/zoom
	name = "Zoom pill"
	desc = "Zoooom!"
	icon_state = "pill18"
	list_reagents = list("synaptizine" = 5, "methamphetamine" = 5)

/obj/item/reagent_containers/food/pill/charcoal
	name = "Таблетка активированного угля"
	desc = "Нейтрализует большинство распространённых токсинов."
	icon_state = "pill17"
	list_reagents = list("charcoal" = 50)

/obj/item/reagent_containers/food/pill/epinephrine
	name = "Таблетка эпинефрина"
	desc = "Used to provide shots of adrenaline."
	icon_state = "pill6"
	list_reagents = list("epinephrine" = 50)

/obj/item/reagent_containers/food/pill/salicylic
	name = "Таблетка салициловой кислота"
	desc = "Commonly used to treat moderate pain and fevers."
	icon_state = "pill4"
	list_reagents = list("sal_acid" = 20)

/obj/item/reagent_containers/food/pill/salbutamol
	name = "Таблетка сальбутамола"
	desc = "Used to treat respiratory distress."
	icon_state = "pill8"
	list_reagents = list("salbutamol" = 20)

/obj/item/reagent_containers/food/pill/hydrocodone
	name = "Таблетка гидрокодона"
	desc = "Used to treat extreme pain."
	icon_state = "pill6"
	list_reagents = list("hydrocodone" = 15)

/obj/item/reagent_containers/food/pill/calomel
	name = "Таблетка каломели"
	desc = "Can be used to purge impurities, but is highly toxic itself."
	icon_state = "pill3"
	list_reagents = list("calomel" = 15)

/obj/item/reagent_containers/food/pill/mutadone
	name = "Таблетка мутадона"
	desc = "Used to cure genetic abnormalities."
	icon_state = "pill18"
	list_reagents = list("mutadone" = 20)

/obj/item/reagent_containers/food/pill/mannitol
	name = "Таблетка маннитола"
	desc = "Used to treat cranial swelling."
	icon_state = "pill19"
	list_reagents = list("mannitol" = 20)

//Not to be confused with /obj/item/reagent_containers/food/drinks/bottle


/obj/item/reagent_containers/glass/bottle
	name = "флакон"
	desc = "Небольшая бутылочка."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "round_bottle"
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30)
	container_type = OPENCONTAINER
	volume = 30

/obj/item/reagent_containers/glass/bottle/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/glass/bottle/update_icon()
	overlays.Cut()
	underlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 24)
				filling.icon_state = "[icon_state]10"
			if(25 to 49)
				filling.icon_state = "[icon_state]25"
			if(50 to 74)
				filling.icon_state = "[icon_state]50"
			if(75 to 90)
				filling.icon_state = "[icon_state]75"
			if(91 to INFINITY)
				filling.icon_state = "[icon_state]100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		underlays += filling

	if(!is_open_container())
		var/image/lid = image(icon, src, "lid_bottle")
		overlays += lid

/obj/item/reagent_containers/glass/bottle/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!reagents.total_volume)
		C.stored_comms["glass"] += 3
		qdel(src)
		return TRUE
	return ..()

/obj/item/reagent_containers/glass/bottle/toxin
	name = "флакон токсинов"
	desc = "Небольшая бутылочка c токсичным веществом."
	icon_state = "small_bottle"
	list_reagents = list("toxin" = 30)

/obj/item/reagent_containers/glass/bottle/atropine
	name = "флакон атропина"
	desc = "Небольшая бутылочка c атропином. Используется для лечения сердечных приступов."
	icon_state = "small_bottle"
	list_reagents = list("atropine" = 30)

/obj/item/reagent_containers/glass/bottle/saline
	name = "флакон физраствора с глюкозой"
	desc = "Небольшая бутылочка физраствора с глюкозой."
	icon_state = "small_bottle"
	list_reagents = list("salglu_solution" = 30)

/obj/item/reagent_containers/glass/bottle/salicylic
	name = "флакон салициловой кислоты"
	desc = "Небольшая бутылочка c лекарством от боли и лихорадки."
	icon_state = "small_bottle"
	list_reagents = list("sal_acid" = 30)

/obj/item/reagent_containers/glass/bottle/cyanide
	name = "флакон цианида"
	desc = "Небольшая бутылочка цианида. Горький миндаль?"
	icon_state = "small_bottle"
	list_reagents = list("cyanide" = 30)

/obj/item/reagent_containers/glass/bottle/mutagen
	name = "флакон нестабильного мутагена"
	desc = "Небольшая бутылочка c нестабильным мутагеном. Он случайно изменяет ДНК всех, кого касается."
	icon_state = "bottle"
	list_reagents = list("mutagen" = 30)

/obj/item/reagent_containers/glass/bottle/ammonia
	name = "флакон аммиака"
	desc = "A small bottle."
	icon_state = "bottle"
	list_reagents = list("ammonia" = 30)

/obj/item/reagent_containers/glass/bottle/diethylamine
	name = "флакон диэтиламина"
	desc = "A small bottle."
	icon_state = "round_bottle"
	list_reagents = list("diethylamine" = 30)

/obj/item/reagent_containers/glass/bottle/facid
	name = "флакон фторсерной кислоты"
	desc = "Небольшая бутылочка. Содержит немного фторсерной кислоты"
	icon_state = "round_bottle"
	list_reagents = list("facid" = 30)

/obj/item/reagent_containers/glass/bottle/adminordrazine
	name = "флакон админодразина"
	desc = "Небольшая бутылочка. Содержит жидкую эссенцию богов."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	list_reagents = list("adminordrazine" = 30)

/obj/item/reagent_containers/glass/bottle/capsaicin
	name = "флакон каспаицина"
	desc = "Небольшая бутылочка. Содержит острый соус."
	icon_state = "round_bottle"
	list_reagents = list("capsaicin" = 30)

/obj/item/reagent_containers/glass/bottle/frostoil
	name = "флакон ледяного масла"
	desc = "Небольшая бутылочка. Содержит леденящий соус."
	icon_state = "round_bottle"
	list_reagents = list("frostoil" = 30)

/obj/item/reagent_containers/glass/bottle/morphine
	name = "флакон морфина"
	desc = "Небольшая бутылочка морфина, мощного обезболивающего."
	icon_state = "bottle"
	list_reagents = list("morphine" = 30)

/obj/item/reagent_containers/glass/bottle/ether
	name = "флакон эфира"
	desc = "Небольшая бутылочка эфира, сильного седатива и анестетика."
	icon_state = "round_bottle"
	list_reagents = list("ether" = 30)

/obj/item/reagent_containers/glass/bottle/charcoal
	name = "флакон активированного угля"
	desc = "Небольшая бутылочка. Содержит активированный уголь."
	icon_state = "wide_bottle"
	list_reagents = list("charcoal" = 30)

/obj/item/reagent_containers/glass/bottle/epinephrine
	name = "флакон эпинефрина"
	desc = "Небольшая бутылочка. Содержит эпинефрин — средство стабилизации пациентов."
	icon_state = "round_bottle"
	list_reagents = list("epinephrine" = 30)

/obj/item/reagent_containers/glass/bottle/pancuronium
	name = "флакон панкурония"
	desc = "Небольшая бутылочка панкурония."
	icon_state = "round_bottle"
	list_reagents = list("pancuronium" = 30)

/obj/item/reagent_containers/glass/bottle/sulfonal
	name = "флакон сульфонала"
	desc = "Небольшая бутылочка сульфонала."
	icon_state = "round_bottle"
	list_reagents = list("sulfonal" = 30)

//Reagent bottles

/obj/item/reagent_containers/glass/bottle/reagent
	name = "флакон для реагентов"
	desc = "Небольшая бутылочка для хранения реагентов"
	icon_state = "reagent_bottle"
	volume = 50

/obj/item/reagent_containers/glass/bottle/reagent/oil
	name = "флакон масла"
	desc = "Бутылочка c реагентами. Содержит масло."
	list_reagents = list("oil" = 50)
	pixel_x = -4
	pixel_y = 6

/obj/item/reagent_containers/glass/bottle/reagent/phenol
	name = "флакон фенола"
	desc = "Бутылочка c реагентами. Содержит фенол."
	list_reagents = list("phenol" = 50)
	pixel_x = 6
	pixel_y = 6

/obj/item/reagent_containers/glass/bottle/reagent/acetone
	name = "флакон ацетона"
	desc = "Бутылочка c реагентами. Содержит ацетон."
	list_reagents = list("acetone" = 50)
	pixel_x = -4

/obj/item/reagent_containers/glass/bottle/reagent/ammonia
	name = "флакон аммиака"
	desc = "Бутылочка c реагентами. Содержит аммиак."
	list_reagents = list("ammonia" = 50)
	pixel_x = 6

/obj/item/reagent_containers/glass/bottle/reagent/diethylamine
	name = "флакон диэтиламина"
	desc = "Бутылочка c реагентами. Содержит диэтиламин."
	list_reagents = list("diethylamine" = 50)
	pixel_x = -4
	pixel_y = -6

/obj/item/reagent_containers/glass/bottle/reagent/acid
	name = "флакон кислоты"
	desc = "Бутылочка c реагентами. Содержит серную кислоту."
	list_reagents = list("sacid" = 50)
	pixel_x = 6
	pixel_y = -6

/obj/item/reagent_containers/glass/bottle/reagent/formaldehyde
	name = "флакон формальдегида"
	desc = "Бутылочка c реагентами. Содержит формальдегид."
	list_reagents = list("formaldehyde" = 50)

/obj/item/reagent_containers/glass/bottle/reagent/synaptizine
	name = "флакон синаптизина"
	desc = "Бутылочка c реагентами. Содержит синаптизин."
	list_reagents = list("synaptizine" = 50)

/obj/item/reagent_containers/glass/bottle/reagent/morphine
	name = "флакон морфина"
	desc = "Бутылочка c реагентами. Содержит морфин."
	list_reagents = list("morphine" = 50)

/obj/item/reagent_containers/glass/bottle/reagent/insulin
	name = "флакон инсулина"
	desc = "Бутылочка c реагентами. Содержит инсулин."
	list_reagents = list("insulin" = 50)

/obj/item/reagent_containers/glass/bottle/reagent/hairgrownium
	name = "флакон геля для роста волос"
	desc = "Бутылочка, содержащая средство стимуляции роста волос"
	list_reagents = list("hairgrownium" = 50)

/obj/item/reagent_containers/glass/bottle/reagent/hair_dye
	name = "флакон квантовой краски для волос"
	desc = "Бутылочка, содержащая постоянно меняющуюся квантовую краску для волос."
	list_reagents = list("hair_dye" = 50)

/obj/item/reagent_containers/glass/bottle/reagent/omnizine
	name = "флакон омнизина" // Omnizine Bottle
	desc = "Бутылочка c реагентами. Содержит омнизин."
	list_reagents = list("omnizine" = 50)

/obj/item/reagent_containers/glass/bottle/reagent/strange_reagent
	name = "флакон странного реагента" // Strange Reagent Bottle
	desc = "Бутылочка со светящейся жидкостью."
	list_reagents = list("strange_reagent" = 30)

////////////////////Traitor Poison Bottle//////////////////////////////

/obj/item/reagent_containers/glass/bottle/traitor
	desc = "На нём изображён небольшой череп и кости. Ого."
	possible_transfer_amounts = list(5,10,15,25,30,40)
	volume = 40

/obj/item/reagent_containers/glass/bottle/traitor/New()
	..()
	reagents.add_reagent(pick_list("chemistry_tools.json", "traitor_poison_bottle"), 40)

/obj/item/reagent_containers/glass/bottle/plasma
	name = "флакон плазменного порошка"
	desc = "Небольшая бутылочка порошкообразной плазмы. Чрезвычайно токсична. Реагирует с микроорганизмами в крови."
	icon_state = "wide_bottle"
	list_reagents = list("plasma_dust" = 30)

/obj/item/reagent_containers/glass/bottle/diphenhydramine
	name = "флакон дифенгидрамина"
	desc = "Небольшая бутылочка с дифенгидрамином."
	icon_state = "round_bottle"
	list_reagents = list("diphenhydramine" = 30)

/obj/item/reagent_containers/glass/bottle/oculine
	name = "флакон окулина"
	desc = "Небольшая бутылочка со средством комбинированного лечения глаз и ушей."
	icon_state = "round_bottle"
	list_reagents = list("oculine" = 30)

/obj/item/reagent_containers/glass/bottle/potassium_iodide
	name = "флакон йодида калия"
	desc = "Небольшая бутылочка с йодидом калия."
	icon_state = "wide_bottle"
	list_reagents = list("potass_iodide" = 30)

/obj/item/reagent_containers/glass/bottle/flu_virion
	name = "флакон с культурой вириона гриппа"
	desc = "Небольшая бутылочка. Содержит культуру вириона гриппа H13N1 в среде синтетической крови."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/advance/flu

/obj/item/reagent_containers/glass/bottle/epiglottis_virion
	name = "флакон с культурой вириона «Надгортанника»"
	desc = "Небольшая бутылочка. Содержит культуру вириона «Надгортанника» в среде синтетической крови."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/advance/voice_change

/obj/item/reagent_containers/glass/bottle/liver_enhance_virion
	name = "флакон с культурой вириона «Усилителя печени»"
	desc = "Небольшая бутылочка. Содержит культуру вириона «Усилителя печени» в среде синтетической крови."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/advance/heal

/obj/item/reagent_containers/glass/bottle/hullucigen_virion
	name = "флакон с культурой вириона «Галлюцигена»"
	desc = "Небольшая бутылочка. Содержит культуру вириона «Галлюцигена» в среде синтетической крови."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/advance/hullucigen

/obj/item/reagent_containers/glass/bottle/pierrot_throat
	name = "флакон с культурой «Горла Пьеро»"
	desc = "Небольшая бутылочка. Содержит культуру вириона Х0Н1<42 в среде синтетической крови."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/pierrot_throat

/obj/item/reagent_containers/glass/bottle/cold
	name = "флакон с культурой риновируса"
	desc = "Небольшая бутылочка. Содержит культуру риновируса XY в среде синтетической крови."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/advance/cold

/obj/item/reagent_containers/glass/bottle/retrovirus
	name = "флакон с культурой «Ретровируса»"
	desc = "Небольшая бутылочка. Содержит культуру ретровируса в среде синтетической крови."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/dna_retrovirus

/obj/item/reagent_containers/glass/bottle/gbs
	name = "флакон с культурой «ГБС»"
	desc = "Небольшая бутылочка. Содержит культуру гравикинетического бипотенциального САДС+ в среде синтетической крови."//Or simply - General BullShit
	icon_state = "round_bottle"
	amount_per_transfer_from_this = 5
	spawned_disease = /datum/disease/gbs

/obj/item/reagent_containers/glass/bottle/fake_gbs
	name = "флакон с культурой «ГБС»"
	desc = "Небольшая бутылочка. Содержит культуру гравикинетического бипотенциального САДС− в среде синтетической крови."//Or simply - General BullShit
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/fake_gbs

/obj/item/reagent_containers/glass/bottle/brainrot
	name = "флакон с культурой «Мозговой гнили»"
	desc = "Небольшая бутылочка. Содержит культуру космического криптококка в среде синтетической крови."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/brainrot

/obj/item/reagent_containers/glass/bottle/magnitis
	name = "флакон с культурой «Магнитиса»"
	desc = "Небольшая бутылочка. Содержит небольшую дозу «Фуккоса Миракоса»."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/magnitis

/obj/item/reagent_containers/glass/bottle/wizarditis
	name = "флакон с культурой «Визардиса»"
	desc = "Небольшая бутылочка. Содержит образец «Ринсвиндия обыкновенного»."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/wizarditis

/obj/item/reagent_containers/glass/bottle/anxiety
	name = "флакон с культурой «Сильного беспокойства»"
	desc = "Небольшая бутылочка. Содержит образец лепидоптицидов."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/anxiety

/obj/item/reagent_containers/glass/bottle/beesease
	name = "флакон с культурой «Пчелоразы»"
	desc = "Небольшая бутылочка. Содержит образец агрессивных пчёл."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/beesease

/obj/item/reagent_containers/glass/bottle/fluspanish
	name = "флакон с культурой «Испанского инквизиционного гриппа»"
	desc = "Небольшая бутылочка. Содержит образец вириона uHKBu3uLIu9I."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/fluspanish

/obj/item/reagent_containers/glass/bottle/tuberculosis
	name = "флакон с культурой «Грибкового туберкулёза»"
	desc = "Небольшая бутылочка. Содержит образец грибковой туберкулезной бациллы."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/tuberculosis

/obj/item/reagent_containers/glass/bottle/regeneration
	name = "флакон с культурой «Регенерации»"
	desc = "Небольшая бутылочка. Содержит образец вируса, исцеляющего урон от токсинов."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/advance/heal

/obj/item/reagent_containers/glass/bottle/sensory_restoration
	name = "флакон с культурой «Сенсорного восстановления»"
	desc = "Небольшая бутылочка. Содержит образец вируса, исцеляющего повреждение органов чувств."
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/advance/sensory_restoration

/obj/item/reagent_containers/glass/bottle/tuberculosiscure
	name = "флакон БАВЛ" // BVAK bottle
	desc = "Небольшая бутылочка, содержащая Биокомплект АнтиВирусных Лекарств."
	icon_state = "wide_bottle"
	list_reagents = list("atropine" = 5, "epinephrine" = 5, "salbutamol" = 10, "spaceacillin" = 10)

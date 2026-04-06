/obj/structure/closet/secure_closet/medical1
	name = "medicine closet"
	desc = "Filled with medical junk."
	desc = "Забит медицинским хламом."
	icon_state = "medical"
	req_access = list(ACCESS_MEDICAL)

/obj/structure/closet/secure_closet/medical1/get_ru_names()
    return list(
        NOMINATIVE = "медицинский шкафчик",
        GENITIVE = "медицинского шкафчика",
        DATIVE = "медицинскому шкафчику",
        ACCUSATIVE = "медицинский шкафчик",
        INSTRUMENTAL = "медицинским шкафчиком",
        PREPOSITIONAL = "медицинском шкафчике",
    )

/obj/structure/closet/secure_closet/medical1/populate_contents()
	new /obj/item/storage/box/autoinjectors(src)
	new /obj/item/storage/box/syringes(src)
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/patch_packs(src)
	new /obj/item/storage/box/iv_bags(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/bottle/epinephrine(src)
	new /obj/item/reagent_containers/glass/bottle/epinephrine(src)
	new /obj/item/reagent_containers/glass/bottle/charcoal(src)
	new /obj/item/reagent_containers/glass/bottle/charcoal(src)

/obj/structure/closet/secure_closet/medical2
	name = "anesthetic locker"
	desc = "Used to knock people out."
	desc = "Используется для того, чтобы вырубать людей."
	icon_state = "medical"
	req_access = list(ACCESS_SURGERY)

/obj/structure/closet/secure_closet/medical2/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для анестезии",
        GENITIVE = "шкафчика для анестезии",
        DATIVE = "шкафчику для анестезии",
        ACCUSATIVE = "шкафчик для анестезии",
        INSTRUMENTAL = "шкафчиком для анестезии",
        PREPOSITIONAL = "шкафчике для анестезии",
    )

/obj/structure/closet/secure_closet/medical2/populate_contents()
	new /obj/item/tank/internals/anesthetic(src)
	new /obj/item/tank/internals/anesthetic(src)
	new /obj/item/tank/internals/anesthetic(src)
	new /obj/item/clothing/mask/breath/medical(src)
	new /obj/item/clothing/mask/breath/medical(src)
	new /obj/item/clothing/mask/breath/medical(src)

/obj/structure/closet/secure_closet/medical3
	name = "medical doctor's locker"
	req_access = list(ACCESS_SURGERY)
	icon_state = "med"

/obj/structure/closet/secure_closet/medical3/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик врача",
        GENITIVE = "шкафчика врача",
        DATIVE = "шкафчику врача",
        ACCUSATIVE = "шкафчик врача",
        INSTRUMENTAL = "шкафчиком врача",
        PREPOSITIONAL = "шкафчике врача",
    )

/obj/structure/closet/secure_closet/medical3/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/storage/backpack/duffel/medical(src)
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/radio/headset/headset_med(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/reagent_containers/hypospray/safety(src)

/obj/structure/closet/secure_closet/medical4
	name = "surgeon locker"
	req_access = list(ACCESS_SURGERY)
	icon_state = "med"

/obj/structure/closet/secure_closet/medical4/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик хирурга",
        GENITIVE = "шкафчика хирурга",
        DATIVE = "шкафчику хирурга",
        ACCUSATIVE = "шкафчик хирурга",
        INSTRUMENTAL = "шкафчиком хирурга",
        PREPOSITIONAL = "шкафчике хирурга",
    )

/obj/structure/closet/secure_closet/medical4/populate_contents()
	new /obj/item/storage/box/masks(src)
	new /obj/item/storage/box/gloves(src)
	new /obj/item/storage/box/bodybags(src)
	new /obj/item/storage/box/bodybags/biohazard(src)
	new /obj/item/storage/belt/medical/surgery/loaded(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/handheld_defibrillator(src)

//Exam Room
/obj/structure/closet/secure_closet/exam
	name = "exam room closet"
	desc = "Filled with exam room materials."
	desc = "Заполнено принадлежностями для проведения экзаменов."
	icon_state = "medical"
	req_access = list(ACCESS_MEDICAL)

/obj/structure/closet/secure_closet/exam/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик экзаменационной",
        GENITIVE = "шкафчика экзаменационной",
        DATIVE = "шкафчику экзаменационной",
        ACCUSATIVE = "шкафчик экзаменационной",
        INSTRUMENTAL = "шкафчиком экзаменационной",
        PREPOSITIONAL = "шкафчике экзаменационной",
    )

/obj/structure/closet/secure_closet/exam/populate_contents()
	new /obj/item/storage/box/syringes(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/clothing/accessory/stethoscope(src)
	new /obj/item/flashlight/pen(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/storage/firstaid/adv(src)
	new /obj/item/storage/firstaid/brute(src)
	new /obj/item/storage/firstaid/fire(src)
	new /obj/item/storage/firstaid/o2(src)
	new /obj/item/storage/firstaid/toxin(src)

// Psychiatrist's pill bottle
/obj/item/storage/pill_bottle/psychiatrist
	name = "psychiatrist's pill bottle"
	desc = "Contains various pills to calm or sedate patients."
	desc = "Содержит различные таблетки для успокоения или седации пациентов."
	wrapper_color = COLOR_IRISH_GREEN

/obj/item/storage/pill_bottle/psychiatrist/get_ru_names()
    return list(
        NOMINATIVE = "пузырёк для таблеток психолога",
        GENITIVE = "пузырька для таблеток психолога",
        DATIVE = "пузырьку для таблеток психолога",
        ACCUSATIVE = "пузырёк для таблеток психолога",
        INSTRUMENTAL = "пузырьком для таблеток психолога",
        PREPOSITIONAL = "пузырьке для таблеток психолога",
    )

// Why the hell is this in the closets folder?
/obj/item/storage/pill_bottle/psychiatrist/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/reagent_containers/food/pill/haloperidol(src)
		new /obj/item/reagent_containers/food/pill/methamphetamine(src)
		new /obj/item/reagent_containers/food/pill/patch/nicotine(src)
	new /obj/item/reagent_containers/food/pill/hydrocodone(src)
	new /obj/item/reagent_containers/food/pill/hydrocodone(src)

/obj/structure/closet/secure_closet/psychiatrist
	name = "psychiatrist's locker"
	req_access = list(ACCESS_PSYCHIATRIST)
	icon_state = "med"

/obj/structure/closet/secure_closet/psychiatrist/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик психолога",
        GENITIVE = "шкафчика психолога",
        DATIVE = "шкафчику психолога",
        ACCUSATIVE = "шкафчик психолога",
        INSTRUMENTAL = "шкафчиком психолога",
        PREPOSITIONAL = "шкафчике психолога",
    )

/obj/structure/closet/secure_closet/psychiatrist/populate_contents()
	new /obj/item/clothing/suit/straight_jacket(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/bottle/ether(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_med(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_med(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_med(src)
	new /obj/item/storage/pill_bottle/psychiatrist(src)
	new /obj/random/plushie(src)
	for(var/i in 0 to 3)
		var/candy = pick(subtypesof(/obj/item/reagent_containers/food/snacks/candy/fudge))
		new candy(src)

/obj/structure/closet/secure_closet/CMO
	name = "chief medical officer's locker"
	req_access = list(ACCESS_CMO)
	icon_state = "cmo"

/obj/structure/closet/secure_closet/CMO/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик главного врача",
        GENITIVE = "шкафчика главного врача",
        DATIVE = "шкафчику главного врача",
        ACCUSATIVE = "шкафчик главного врача",
        INSTRUMENTAL = "шкафчиком главного врача",
        PREPOSITIONAL = "шкафчике главного врача",
    )

/obj/structure/closet/secure_closet/CMO/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/storage/backpack/duffel/medical(src)
	switch(pick("blue", "green", "purple"))
		if("blue")
			new /obj/item/clothing/under/rank/medical/blue(src)
			new /obj/item/clothing/head/surgery/blue(src)
		if("green")
			new /obj/item/clothing/under/rank/medical/green(src)
			new /obj/item/clothing/head/surgery/green(src)
		if("purple")
			new /obj/item/clothing/under/rank/medical/purple(src)
			new /obj/item/clothing/head/surgery/purple(src)
	new /obj/item/radio/headset/heads/cmo(src)
	new /obj/item/defibrillator/compact/advanced/loaded(src)
	new /obj/item/handheld_defibrillator/advanced(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/storage/belt/medical/surgery/loaded(src)
	new /obj/item/flash(src)
	new /obj/item/reagent_containers/hypospray/CMO(src)
	new /obj/item/organ/internal/cyberimp/eyes/hud/medical(src)
	new /obj/item/autoimplanter/oneuse/med_hud(src)
	new /obj/item/door_remote/chief_medical_officer(src)
	new /obj/item/reagent_containers/food/drinks/mug/cmo(src)
	new /obj/item/clothing/accessory/medal/medical(src)
	new /obj/item/megaphone(src)	//added here deleted on maps
	new /obj/item/storage/garmentbag/CMO(src)
	new /obj/item/gun/energy/gun/mini(src)
	new /obj/item/clothing/accessory/holster(src)
	new /obj/item/storage/firstaid/premium(src)

/obj/structure/closet/secure_closet/animal
	name = "animal control locker"
	req_access = list(ACCESS_SURGERY)

/obj/structure/closet/secure_closet/animal/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик контроля за животными",
        GENITIVE = "шкафчика контроля за животными",
        DATIVE = "шкафчику контроля за животными",
        ACCUSATIVE = "шкафчик контроля за животными",
        INSTRUMENTAL = "шкафчиком контроля за животными",
        PREPOSITIONAL = "шкафчике контроля за животными",
    )

/obj/structure/closet/secure_closet/animal/populate_contents()
	new /obj/item/assembly/signaler(src)
	new /obj/item/radio/electropack(src)
	new /obj/item/radio/electropack(src)
	new /obj/item/radio/electropack(src)

/obj/structure/closet/secure_closet/chemical
	name = "chemical closet"
	desc = "Store dangerous chemicals in here."
	desc = "Здесь хранятся опасные химические вещества."
	icon_state = "medical"
	custom_door_overlay = "chemical"
	req_access = list(ACCESS_CHEMISTRY)

/obj/structure/closet/secure_closet/chemical/get_ru_names()
    return list(
        NOMINATIVE = "химический шкафчик",
        GENITIVE = "химического шкафчика",
        DATIVE = "химическому шкафчику",
        ACCUSATIVE = "химический шкафчик",
        INSTRUMENTAL = "химическим шкафчиком",
        PREPOSITIONAL = "химическом шкафчике",
    )

/obj/structure/closet/secure_closet/chemical/populate_contents()
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/patch_packs(src)
	new /obj/item/storage/box/patch_packs(src)

/obj/structure/closet/secure_closet/medical_wall
	name = "first aid closet"
	desc = "It's a secure wall-mounted storage unit for first aid supplies."
	desc = "Это защищённое настенное устройство для хранения принадлежностей для оказания первой помощи."
	icon_state = "medical_wall"
	overlay_sparking = "m_sparking"
	overlay_locked = "m_locked"
	overlay_locker = "m_locker"
	overlay_unlocked = "m_unlocked"
	anchored = TRUE
	density = FALSE
	wall_mounted = TRUE
	sparking_duration = 3 SECONDS
	req_access = list(ACCESS_MEDICAL)

/obj/structure/closet/secure_closet/medical_wall/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик первой помощи",
        GENITIVE = "шкафчика первой помощи",
        DATIVE = "шкафчику первой помощи",
        ACCUSATIVE = "шкафчик первой помощи",
        INSTRUMENTAL = "шкафчиком первой помощи",
        PREPOSITIONAL = "шкафчике первой помощи",
    )

/obj/structure/closet/secure_closet/paramedic
	name = "paramedic EVA gear"
	desc = "A locker with a Paramedic EVA suit."
	icon_state = "paramedEVA"
	req_access = list(ACCESS_PARAMEDIC)

/obj/structure/closet/secure_closet/paramedic/get_ru_names()
    return list(
        NOMINATIVE = "снаряжение парамедика для ВКД",
        GENITIVE = "снаряжения парамедика для ВКД",
        DATIVE = "снаряжению парамедика для ВКД",
        ACCUSATIVE = "снаряжение парамедика для ВКД",
        INSTRUMENTAL = "снаряжением парамедика для ВКД",
        PREPOSITIONAL = "снаряжении парамедика для ВКД",
    )

/obj/structure/closet/secure_closet/paramedic/populate_contents()
	new /obj/item/mod/control/pre_equipped/rescue(src)
	new /obj/item/mod/control/pre_equipped/rescue(src)
	new /obj/item/sensor_device(src)
	new /obj/item/key/ambulance(src)
	new /obj/item/pinpointer/crew(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/tank/jetpack/carbondioxide(src)

/obj/structure/closet/secure_closet/reagents
	name = "chemical storage closet"
	desc = "Здесь хранятся опасные химические вещества."
	icon_state = "medical"
	custom_door_overlay = "chemical"
	req_access = list(ACCESS_CHEMISTRY)

/obj/structure/closet/secure_closet/reagents/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для химикатов",
        GENITIVE = "шкафчика для химикатов",
        DATIVE = "шкафчику для химикатов",
        ACCUSATIVE = "шкафчик для химикатов",
        INSTRUMENTAL = "шкафчиком для химикатов",
        PREPOSITIONAL = "шкафчике для химикатов",
    )

/obj/structure/closet/secure_closet/reagents/populate_contents()
	new /obj/item/reagent_containers/glass/bottle/reagent/phenol(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/ammonia(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/oil(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/acetone(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/acid(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/diethylamine(src)

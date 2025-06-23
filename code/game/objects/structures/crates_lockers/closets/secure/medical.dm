/obj/structure/closet/secure_closet/medical1
	name = "medicine closet"
	ru_names = list(
		NOMINATIVE = "медицинский шкафчик",
		GENITIVE = "медицинского шкафчика",
		DATIVE = "медицинскому шкафчику",
		ACCUSATIVE = "медицинский шкафчик",
		INSTRUMENTAL = "медицинским шкафчиком",
		PREPOSITIONAL = "медицинском шкафчике"
	)
	icon_state = "medical"
	req_access = list(ACCESS_MEDICAL)

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
	ru_names = list(
		NOMINATIVE = "анестезиологический шкафчик",
		GENITIVE = "анестезиологического шкафчика",
		DATIVE = "анестезиологическому шкафчику",
		ACCUSATIVE = "анестезиологический шкафчик",
		INSTRUMENTAL = "анестезиологическим шкафчиком",
		PREPOSITIONAL = "анестезиологическом шкафчике"
	)
	icon_state = "medical"
	req_access = list(ACCESS_SURGERY)

/obj/structure/closet/secure_closet/medical2/populate_contents()
	new /obj/item/tank/internals/anesthetic(src)
	new /obj/item/tank/internals/anesthetic(src)
	new /obj/item/tank/internals/anesthetic(src)
	new /obj/item/clothing/mask/breath/medical(src)
	new /obj/item/clothing/mask/breath/medical(src)
	new /obj/item/clothing/mask/breath/medical(src)


/obj/structure/closet/secure_closet/medical3
	name = "medical doctor's locker"
	ru_names = list(
		NOMINATIVE = "шкафчик Врача",
		GENITIVE = "шкафчика Врача",
		DATIVE = "шкафчику Врача",
		ACCUSATIVE = "шкафчик Врача",
		INSTRUMENTAL = "шкафчиком Врача",
		PREPOSITIONAL = "шкафчике Врача"
	)
	req_access = list(ACCESS_SURGERY)
	icon_state = "med"

/obj/structure/closet/secure_closet/medical3/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/storage/backpack/duffel/medical(src)
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/radio/headset/headset_med(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/reagent_containers/hypospray/safety(src)

/obj/structure/closet/secure_closet/medical4
	name = "surgeon locker"
	ru_names = list(
		NOMINATIVE = "хирургический шкафчик",
		GENITIVE = "хирургического шкафчика",
		DATIVE = "хирургическому шкафчику",
		ACCUSATIVE = "хирургический шкафчик",
		INSTRUMENTAL = "хирургическим шкафчиком",
		PREPOSITIONAL = "хирургическом шкафчике"
	)
	req_access = list(ACCESS_SURGERY)
	icon_state = "med"

/obj/structure/closet/secure_closet/medical4/populate_contents()
	new /obj/item/storage/box/masks(src)
	new /obj/item/storage/box/gloves(src)
	new /obj/item/storage/box/bodybags(src)
	new /obj/item/storage/box/bodybags/biohazard(src)
	new /obj/item/storage/belt/medical/surgery/loaded(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/handheld_defibrillator(src)



/obj/structure/closet/secure_closet/psychiatrist
	name = "psychiatrist's locker"
	ru_names = list(
		NOMINATIVE = "шкафчик Психиатра",
		GENITIVE = "шкафчика Психиатра",
		DATIVE = "шкафчику Психиатра",
		ACCUSATIVE = "шкафчик Психиатра",
		INSTRUMENTAL = "шкафчиком Психиатра",
		PREPOSITIONAL = "шкафчике Психиатра"
	)
	req_access = list(ACCESS_PSYCHIATRIST)
	icon_state = "med"

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
	ru_names = list(
		NOMINATIVE = "шкафчик Главного врача",
		GENITIVE = "шкафчика Главного врача",
		DATIVE = "шкафчику Главного врача",
		ACCUSATIVE = "шкафчик Главного врача",
		INSTRUMENTAL = "шкафчиком Главного врача",
		PREPOSITIONAL = "шкафчике Главного врача"
	)
	req_access = list(ACCESS_CMO)
	icon_state = "cmo"

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
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/flash(src)
	new /obj/item/reagent_containers/hypospray/CMO(src)
	new /obj/item/organ/internal/cyberimp/eyes/hud/medical(src)
	new /obj/item/door_remote/chief_medical_officer(src)
	new /obj/item/reagent_containers/food/drinks/mug/cmo(src)
	new /obj/item/clothing/accessory/medal/medical(src)
	new /obj/item/megaphone(src)	//added here deleted on maps
	new /obj/item/storage/garmentbag/CMO(src)

/obj/structure/closet/secure_closet/chemical
	name = "chemical closet"
	ru_names = list(
		NOMINATIVE = "шкафчик для химикатов",
		GENITIVE = "шкафчика для химикатов",
		DATIVE = "шкафчику для химикатов",
		ACCUSATIVE = "шкафчик для химикатов",
		INSTRUMENTAL = "шкафчиком для химикатов",
		PREPOSITIONAL = "шкафчике для химикатов"
	)
	icon_state = "medical"
	custom_door_overlay = "chemical"
	req_access = list(ACCESS_CHEMISTRY)

/obj/structure/closet/secure_closet/chemical/populate_contents()
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/patch_packs(src)
	new /obj/item/storage/box/patch_packs(src)


/obj/structure/closet/secure_closet/medical_wall
	name = "first aid closet"
	desc = "Настенный металлический шкафчик, предназначенный для хранения медикаментов \
			и оказания первой помощи. Оборудован электронным замком."
	ru_names = list(
        NOMINATIVE = "настенная аптечка",
        GENITIVE = "настенной аптечки",
        DATIVE = "настенной аптечке",
        ACCUSATIVE = "настенную аптечку",
        INSTRUMENTAL = "настенной аптечкой",
        PREPOSITIONAL = "настенной аптечке"
	)
	gender = FEMALE
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

/obj/structure/closet/secure_closet/paramedic
	name = "paramedic EVA gear"
	ru_names = list(
		NOMINATIVE = "шкафчик (ВКД Парамедика)",
		GENITIVE = "шкафчика (ВКД Парамедика)",
		DATIVE = "шкафчику (ВКД Парамедика)",
		ACCUSATIVE = "шкафчик (ВКД Парамедика)",
		INSTRUMENTAL = "шкафчиком (ВКД Парамедика)",
		PREPOSITIONAL = "шкафчике (ВКД Парамедика)"
	)
	icon_state = "paramedEVA"
	req_access = list(ACCESS_PARAMEDIC)

/obj/structure/closet/secure_closet/paramedic/populate_contents()
	new /obj/item/clothing/suit/space/eva/paramedic(src)
	new /obj/item/clothing/head/helmet/space/eva/paramedic(src)
	new /obj/item/sensor_device(src)
	new /obj/item/key/ambulance(src)
	new /obj/item/pinpointer/crew(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/tank/jetpack/carbondioxide(src)

/obj/structure/closet/secure_closet/reagents
	name = "chemical storage closet"
	ru_names = list(
		NOMINATIVE = "шкафчик для химикатов",
		GENITIVE = "шкафчика для химикатов",
		DATIVE = "шкафчику для химикатов",
		ACCUSATIVE = "шкафчик для химикатов",
		INSTRUMENTAL = "шкафчиком для химикатов",
		PREPOSITIONAL = "шкафчике для химикатов"
	)
	icon_state = "medical"
	custom_door_overlay = "chemical"
	req_access = list(ACCESS_CHEMISTRY)

/obj/structure/closet/secure_closet/reagents/populate_contents()
	new /obj/item/reagent_containers/glass/bottle/reagent/phenol(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/ammonia(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/oil(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/acetone(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/acid(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/diethylamine(src)

// Plant analyzer
/obj/item/plant_analyzer
	name = "plant analyzer"
	desc = "A scanner used to evaluate a plant's various areas of growth."
	icon = 'icons/obj/device.dmi'
	icon_state = "hydro"
	item_state = "analyzer"
	belt_icon = "plant_analyzer"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	origin_tech = "magnets=2;biotech=2"
	materials = list(MAT_METAL=30, MAT_GLASS=20)

// *************************************
// Hydroponics Tools
// *************************************

/obj/item/reagent_containers/spray/weedspray // -- Skie
	name = "weed spray"
	desc = "Распылитель средства от сорняков - атразина."
	ru_names = list(
		NOMINATIVE = "распылитель средства от сорняков",
		GENITIVE = "распылителя средства от сорняков",
		DATIVE = "распылителю средства от сорняков",
		ACCUSATIVE = "распылитель средства от сорняков",
		INSTRUMENTAL = "распылителем средства от сорняков",
		PREPOSITIONAL = "распылителе средства от сорняков"
	)
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "weedspray"
	item_state = "plantbgone"
	volume = 100
	container_type = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 10
	list_reagents = list("atrazine" = 100)

/obj/item/reagent_containers/spray/weedspray/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] жадно вдыха[pluralize_ru(user.gender, "ет", "ют")] содержимое [declent_ru(GENITIVE)]! Кажется, что это попытка самоубийства!"))
	return TOXLOSS

/obj/item/reagent_containers/spray/pestspray // -- Skie
	name = "pest spray"
	desc = "Распылитель пестицидов для уничтожения вредителей."
	ru_names = list(
		NOMINATIVE = "распылитель пестицидов",
		GENITIVE = "распылителя пестицидов",
		DATIVE = "распылителю пестицидов",
		ACCUSATIVE = "распылитель пестицидов",
		INSTRUMENTAL = "распылителем пестицидов",
		PREPOSITIONAL = "распылителе пестицидов"
	)
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "pestspray"
	item_state = "plantbgone"
	volume = 100
	container_type = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 10
	list_reagents = list("pestkiller" = 100)

/obj/item/reagent_containers/spray/pestspray/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] жадно вдыха[pluralize_ru(user.gender, "ет", "ют")] содержимое [declent_ru(GENITIVE)]! Кажется, что это попытка самоубийства!"))
	return TOXLOSS

/obj/item/cultivator
	name = "cultivator"
	desc = "It's used for removing weeds or scratching your back."
	icon_state = "cultivator"
	item_state = "cultivator"
	belt_icon = "cultivator"
	origin_tech = "engineering=2;biotech=2"
	flags = CONDUCT
	force = 5
	throwforce = 7
	toolspeed = 0.5
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50)
	attack_verb = list("полоснул", "порезал", "поцарапал")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/cultivator/rake
	name = "rake"
	icon_state = "rake"
	toolspeed = 1
	belt_icon = null
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("полоснул", "ударил", "поцарапал")
	hitsound = null
	materials = null
	flags = NONE
	resistance_flags = FLAMMABLE

/obj/item/cultivator/wooden
	icon_state = "cultivator_wooden"
	hitsound = null
	materials = null
	flags = NONE
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	item_state = "cultivator"


/obj/item/hatchet
	name = "hatchet"
	desc = "A very sharp axe blade upon a short fibremetal handle. It has a long history of chopping things, but now it is used for chopping wood."
	icon_state = "hatchet"
	item_state = "hatchet"
	belt_icon = "hatchet"
	flags = CONDUCT
	force = 12
	w_class = WEIGHT_CLASS_TINY
	throwforce = 15
	throw_speed = 3
	throw_range = 4
	materials = list(MAT_METAL = 15000)
	origin_tech = "materials=2;combat=2"
	attack_verb = list("рубанул", "поранил", "порезал")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = 1
	embed_chance = 70
	embedded_ignore_throwspeed_threshold = TRUE

/obj/item/hatchet/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is chopping at [user.p_them()]self with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return BRUTELOSS

/obj/item/hatchet/unathiknife
	name = "duelling knife"
	desc = "A length of leather-bound wood studded with razor-sharp teeth. How crude."
	icon_state = "unathiknife"
	item_state = "unathiknife"
	belt_icon = null
	attack_verb = list("поранил", "порезал")

/obj/item/hatchet/wooden
	name = "wooden hatchet"
	desc = "A crude axe blade upon a short wooden handle."
	icon_state = "woodhatchet"
	belt_icon = "wooden_hatchet"
	materials = null
	flags = NONE
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	item_state = "small_shovel"

/obj/item/scythe
	icon_state = "scythe0"
	name = "scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	force = 13
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	flags = CONDUCT
	armour_penetration = 20
	slot_flags = ITEM_SLOT_BACK
	origin_tech = "materials=3;combat=2"
	attack_verb = list("рубанул", "порезал", "скосил")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = 1
	embed_chance = 15
	embedded_ignore_throwspeed_threshold = TRUE
	var/extend = 1
	var/swiping = FALSE

/obj/item/scythe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is beheading [user.p_them()]self with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/affecting = H.get_organ(BODY_ZONE_HEAD)
		if(affecting)
			affecting.droplimb(1, DROPLIMB_SHARP)
			playsound(loc, "desceration", 50, 1, -1)
	return BRUTELOSS


/obj/item/scythe/pre_attackby(atom/target, mob/living/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || swiping || !istype(target, /obj/structure/spacevine))
		return .

	swiping = TRUE
	var/turf/target_turf = get_turf(target)
	var/turf/user_turf = get_turf(user)
	if(target_turf == user_turf)
		swiping = FALSE
		return .

	var/dir_to_target = get_dir(user_turf, target_turf)
	var/static/list/scythe_slash_angles = list(0, 45, 90, -45, -90)
	for(var/i in scythe_slash_angles)
		var/turf/close_turf = get_step(user_turf, turn(dir_to_target, i))
		for(var/obj/structure/spacevine/spacevine in close_turf)
			if(user.Adjacent(close_turf))
				melee_attack_chain(user, close_turf, params)
	swiping = FALSE


/obj/item/scythe/tele
	icon_state = "tscythe0"
	item_state = null	//no sprite for folded version, like a tele-baton
	name = "telescopic scythe"
	desc = "A sharp and curved blade on a collapsable fibre metal handle, this tool is the pinnacle of covert reaping technology."
	force = 3
	sharp = 0
	w_class = WEIGHT_CLASS_SMALL
	extend = 0
	slot_flags = ITEM_SLOT_BELT
	origin_tech = "materials=3;combat=3"
	attack_verb = list("ударил", "ткнул")
	hitsound = "swing_hit"

/obj/item/scythe/tele/attack_self(mob/user)
	extend = !extend
	if(extend)
		to_chat(user, "<span class='warning'>With a flick of your wrist, you extend the scythe. It's reaping time!</span>")
		slot_flags = ITEM_SLOT_BACK	//won't fit on belt, but can be worn on belt when extended
		w_class = WEIGHT_CLASS_BULKY		//won't fit in backpacks while extended
		force = 15		//slightly better than normal scythe damage
		attack_verb = list("рубанул", "порезал", "скосил")
		hitsound = 'sound/weapons/bladeslice.ogg'
		//Extend sound (blade unsheath)
		playsound(src.loc, 'sound/weapons/blade_unsheath.ogg', 50, 1)	//Sound credit to Qat of Freesound.org
	else
		to_chat(user, "<span class='notice'>You collapse the scythe, folding it away for easy storage.</span>")
		slot_flags = ITEM_SLOT_BELT	//can be worn on belt again, but no longer makes sense to wear on the back
		w_class = WEIGHT_CLASS_SMALL
		force = 3
		attack_verb = list("ударил", "ткнул")
		hitsound = "swing_hit"
		//Collapse sound (blade sheath)
		playsound(src.loc, 'sound/weapons/blade_sheath.ogg', 50, 1)		//Sound credit to Q.K. of Freesound.org
	set_sharpness(extend)
	update_icon(UPDATE_ICON_STATE)
	update_equipped_item(update_speedmods = FALSE)
	add_fingerprint(user)


/obj/item/scythe/tele/update_icon_state()
	if(extend)
		icon_state = "tscythe1"
		item_state = "scythe0"	//use the normal scythe in-hands
	else
		icon_state = "tscythe0"
		item_state = null	//no sprite for folded version, like a tele-baton


// *************************************
// Nutrient defines for hydroponics
// *************************************


/obj/item/reagent_containers/glass/bottle/nutrient
	name = "jug of nutrient"
	desc = "Пластиковая канистра для различных жидкостей."
	ru_names = list(
        NOMINATIVE = "канистра",
        GENITIVE = "канистри",
        DATIVE = "канистре",
        ACCUSATIVE = "канистру",
        INSTRUMENTAL = "канистрой",
        PREPOSITIONAL = "канистре"
	)
	icon = 'icons/obj/chemical.dmi'
	icon_state = "plastic_jug"
	item_state = "plastic_jug"
	w_class = WEIGHT_CLASS_TINY
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,5,10,20,40,80)
	container_type = OPENCONTAINER
	volume = 80
	hitsound = 'sound/weapons/jug_empty_impact.ogg'
	mob_throw_hit_sound = 'sound/weapons/jug_empty_impact.ogg'
	force = 0.2
	throwforce = 0.2

/obj/item/reagent_containers/glass/bottle/nutrient/New()
	..()
	add_lid()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/reagent_containers/glass/bottle/nutrient/on_reagent_change()
	. = ..()
	update_icon(UPDATE_OVERLAYS)
	if(reagents.total_volume)
		hitsound = 'sound/weapons/jug_filled_impact.ogg'
		mob_throw_hit_sound = 'sound/weapons/jug_filled_impact.ogg'
	else
		hitsound = 'sound/weapons/jug_empty_impact.ogg'
		mob_throw_hit_sound = 'sound/weapons/jug_empty_impact.ogg'


/obj/item/reagent_containers/glass/bottle/nutrient/update_overlays()
	. = ..()
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "plastic_jug10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 10)
				filling.icon_state = "plastic_jug-10"
			if(11 to 29)
				filling.icon_state = "plastic_jug25"
			if(30 to 45)
				filling.icon_state = "plastic_jug40"
			if(46 to 61)
				filling.icon_state = "plastic_jug55"
			if(62 to 77)
				filling.icon_state = "plastic_jug70"
			if(78 to 92)
				filling.icon_state = "plastic_jug85"
			if(93 to INFINITY)
				filling.icon_state = "plastic_jug100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		. += filling

	if(!is_open_container())
		. += "lid_jug"


/obj/item/reagent_containers/glass/bottle/nutrient/ez
	name = "jug of E-Z-Nutrient"
	desc = "Пластиковая канистра для различных жидкостей. В ней содержится И-ЗИ-Нутриент."
	ru_names = list(
        NOMINATIVE = "канистра (И-ЗИ-Нутриент)",
        GENITIVE = "канистри (И-ЗИ-Нутриент)",
        DATIVE = "канистре (И-ЗИ-Нутриент)",
        ACCUSATIVE = "канистру (И-ЗИ-Нутриент)",
        INSTRUMENTAL = "канистрой (И-ЗИ-Нутриент)",
        PREPOSITIONAL = "канистре (И-ЗИ-Нутриент)"
	)
	icon = 'icons/obj/chemical.dmi'
	icon_state = "plastic_jug_ez"
	list_reagents = list("eznutriment" = 80)

/obj/item/reagent_containers/glass/bottle/nutrient/l4z
	name = "jug of Left 4 Zed"
	desc = "Пластиковая канистра для различных жидкостей. В ней содержится Лефт-Фо-Зед."
	ru_names = list(
        NOMINATIVE = "канистра (Лефт-Фо-Зед)",
        GENITIVE = "канистри (Лефт-Фо-Зед)",
        DATIVE = "канистре (Лефт-Фо-Зед)",
        ACCUSATIVE = "канистру (Лефт-Фо-Зед)",
        INSTRUMENTAL = "канистрой (Лефт-Фо-Зед)",
        PREPOSITIONAL = "канистре (Лефт-Фо-Зед)"
	)
	icon = 'icons/obj/chemical.dmi'
	icon_state = "plastic_jug_l4z"
	list_reagents = list("left4zednutriment" = 80)

/obj/item/reagent_containers/glass/bottle/nutrient/rh
	name = "jug of Robust Harvest"
	desc = "Пластиковая канистра для различных жидкостей. В ней содержится Робаст-Харвест."
	ru_names = list(
        NOMINATIVE = "канистра (Робаст-Харвест)",
        GENITIVE = "канистри (Робаст-Харвест)",
        DATIVE = "канистре (Робаст-Харвест)",
        ACCUSATIVE = "канистру (Робаст-Харвест)",
        INSTRUMENTAL = "канистрой (Робаст-Харвест)",
        PREPOSITIONAL = "канистре (Робаст-Харвест)"
	)
	icon = 'icons/obj/chemical.dmi'
	icon_state = "plastic_jug_rh"
	list_reagents = list("robustharvestnutriment" = 80)

/obj/item/reagent_containers/glass/bottle/nutrient/empty
	icon = 'icons/obj/chemical.dmi'
	icon_state = "plastic_jug"

/obj/item/reagent_containers/glass/bottle/nutrient/killer
	icon = 'icons/obj/chemical.dmi'
	icon_state = "plastic_jug_k"
	w_class = WEIGHT_CLASS_TINY

/obj/item/reagent_containers/glass/bottle/nutrient/killer/New()
	..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/reagent_containers/glass/bottle/nutrient/killer/weedkiller
	name = "jug of weed killer"
	desc = "Пластиковая канистра для различных жидкостей. В ней содержится атразин."
	ru_names = list(
        NOMINATIVE = "канистра (Атразин)",
        GENITIVE = "канистри (Атразин)",
        DATIVE = "канистре (Атразин)",
        ACCUSATIVE = "канистру (Атразин)",
        INSTRUMENTAL = "канистрой (Атразин)",
        PREPOSITIONAL = "канистре (Атразин)"
	)
	icon = 'icons/obj/chemical.dmi'
	icon_state = "plastic_jug_wk"
	list_reagents = list("atrazine" = 80)

/obj/item/reagent_containers/glass/bottle/nutrient/killer/pestkiller
	name = "jug of pest spray"
	desc = "Пластиковая канистра для различных жидкостей. В ней содержатся пестициды."
	ru_names = list(
        NOMINATIVE = "канистра (Пестициды)",
        GENITIVE = "канистри (Пестициды)",
        DATIVE = "канистре (Пестициды)",
        ACCUSATIVE = "канистру (Пестициды)",
        INSTRUMENTAL = "канистрой (Пестициды)",
        PREPOSITIONAL = "канистре (Пестициды)"
	)
	icon = 'icons/obj/chemical.dmi'
	icon_state = "plastic_jug_pk"
	list_reagents = list("pestkiller" = 80)

/obj/item/conductive_organ
	name = "conductive organ"
	desc = "небольшой желтоватый мешочек, добываемый из лавового панцирника. Является мощным удобрением, значительно повышающим урожай и уровень нутриментов растения."
	ru_names = list(
		NOMINATIVE = "проводящий орган",
		GENITIVE = "проводящего органа",
		DATIVE = "проводящему органу",
		ACCUSATIVE = "проводящий орган",
		INSTRUMENTAL = "проводящим органом",
		PREPOSITIONAL = "проводящем органе",
	)
	gender = MALE
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "conductive_organ"
	lefthand_file = 'icons/mob/inhands/lavaland/fish_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/fish_items_righthand.dmi'
	item_state = "acid_bladder" //yeah
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "biotech=6"

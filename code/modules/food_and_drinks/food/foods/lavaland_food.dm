/obj/item/reagent_containers/food/snacks/lavaland
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	var/overlay_sprite
	list_reagents = list("nutriment" = 2, "vitamin" = 4, "protein" = 2)

/obj/item/reagent_containers/food/snacks/lavaland/soft_meat
	name = "soft meat cut"
	desc = "Нежная мясная вырезка. Сырая в текущем виде, однако с правильными ингридиентами её можно превратить в прекрасное блюдо."
	icon_state = "soft_meat_cut"
	list_reagents = list("nutriment" = 1, "vitamin" = 3, "protein" = 3)
	bitesize = 2
	filling_color = "#D49284"
	tastes = list("raw meat" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/lavaland/eel_filet
	name = "eel filet"
	desc = "Сырое филе донного угря. Хоть оно съедобно и в сыром виде, с правильными ингридиентами, ее можно превратить в прекрасное блюдо."
	icon_state = "eel_filet"
	list_reagents = list("nutriment" = 2, "menthol" = 3, "protein" = 4)
	bitesize = 2
	filling_color = "#414F71"
	tastes = list("raw meat" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/lavaland/predator_meat
	name = "predatory fish slice"
	desc = "Достаточно большой кусок мяса, добытый из хищной рыбы. Не рекомендуется к употреблению в сыром виде."
	icon_state = "predatory_fish_slice"
	list_reagents = list("nutriment" = 2, "toxin" = 2, "protein" = 4)
	bitesize = 3
	filling_color = "#BE7C64"
	tastes = list("toxin meat" = 1)
	foodtype = MEAT | TOXIC | RAW

/obj/item/reagent_containers/food/snacks/lavaland/soft_meat_cubes
	name = "soft meat cubes"
	desc = "Филе рыбы, порезанное на маленькие кубики и обжаренное в печи. Выглядит аппетитно."
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "soft_meat_cubes"
	list_reagents = list("nutriment" = 2, "vitamin" = 3, "protein" = 3)
	bitesize = 3
	filling_color = "#BE7C64"
	tastes = list("soft meat" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/predatory_fish_slab
	name = "cooked predatory fish slab"
	desc = "Кусок мяса хищной рыбы, обжаренный в печи. Пригоден к употреблению."
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "predatory_fish_slab"
	list_reagents = list("nutriment" = 4, "protein" = 6)
	bitesize = 3
	filling_color = "#BE7C64"
	tastes = list("meat" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/eel_ringlets
	name = "eel ringlets"
	desc = "Обжаренное в печи филе донного угря. Невероятно вкусное."
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "eel_ringlets"
	list_reagents = list("nutriment" = 4, "protein" = 6)
	bitesize = 3
	filling_color = "#BE7C64"
	tastes = list("meat" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bacon
	name = "thali lazis bacon part"
	desc = "Небольшая порция бекона, взятая из тарелки Тали Лазис."
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "thali_lazis_bacon"
	overlay_sprite = "thali_lazis_bacon_overlay"
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_cacti
	name = "thali lazis cacti part"
	desc = "Небольшой кактус, взятый из тарелки Тали Лазис."
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "thali_lazis_cacti"
	overlay_sprite = "thali_lazis_cacti_overlay"
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_wing
	name = "thali lazis wing part"
	desc = "Небольшое крыло, взятое из тарелки Тали Лазис."
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "thali_lazis_wing"
	overlay_sprite = "thali_lazis_wing_overlay"
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_fish
	name = "thali lazis fish part"
	desc = "Небольшая порция рыбы, взятая из тарелки Тали Лазис."
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "thali_lazis_fish"
	overlay_sprite = "thali_lazis_fish_overlay"
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_crunchie
	name = "thali lazis crunchie part"
	desc = "Небольшая хрустящая порция, взятая из тарелки Тали Лазис."
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "thali_lazis_crunchie"
	overlay_sprite = "thali_lazis_crunchie_overlay"
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bungus
	name = "thali lazis bungus part"
	desc = "Небольшая порция грибов, взятая из тарелки Тали Лазис."
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "thali_lazis_bungus"
	overlay_sprite = "thali_lazis_bungus_overlay"
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/lavaland_food
	name = "generic lavaland food"
	desc = "самое обычное блюдо. Если вы это видите, то зюзя напортачил"
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "fine_meal"
	bitesize = 100 //eat whole thing down
	list_reagents = list("nutriment" = 6, "protein" = 6)
	tastes = list("good food" = 1)
	has_special_eating_effects = TRUE
	eat_time = 5 SECONDS
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland_food/fine_meal
	name = "fine meal"
	icon_state = "fine_meal"
	desc = "Мясо голиафа, обжаренное в соку кактусового фрукта. Невероятно вкусное и питательное."
	list_reagents = list("vitfro" = 6, "protein" = 7, "vitamin" = 3)
	tastes = list("well-balanced food" = 1)
	foodtype = MEAT|FRUIT

/obj/item/reagent_containers/food/snacks/lavaland_food/fine_meal/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_FORCED_RUMBLE)

/obj/item/reagent_containers/food/snacks/lavaland_food/freaky_leg
	name = "freaky leg"
	icon_state = "freaky_leg"
	desc = "Многие народы галактики расценивают поедание себе подобных как ужасающее преступление. Однако эти стопы вышли слишком питательными.."
	tastes = list("bad times" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland_food/freaky_leg/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_NO_PAIN)

/obj/item/reagent_containers/food/snacks/lavaland_food/veggie_meal
	name = "veggie meal"
	icon_state = "veggie_meal"
	desc = "Обычно пеплоходцы питаются мясом местной фауны, однако, если правильно смешать нужные реагенты, то получится крайне полезное, хоть не очень вкусное блюдо."
	list_reagents = list("spaceacillin" = 10, "lavaland_extract" = 2, "vitfro" = 20, "sal_acid" = 15)
	tastes = list("herbs" = 1)
	foodtype = FRUIT|VEGETABLES

/obj/item/reagent_containers/food/snacks/lavaland_food/veggie_meal/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_FORCED_SNEEZE)

/obj/item/reagent_containers/food/snacks/lavaland_food/hunters_treat
	name = "hunter's treat"
	icon_state = "hunters_treat"
	desc = "Человеческое сердце, обжаренное в соку мяса голиафа. Легенды говорят, что если сьесть сердце поверженного врага, то обретешь невероятную силу."

/obj/item/reagent_containers/food/snacks/lavaland_food/hunters_treat/on_mob_eating_effect(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		human.force_gene_block(GLOB.strongblock, TRUE)

/obj/item/reagent_containers/food/snacks/lavaland_food/yum_grub
	name = "yum-grub"
	icon_state = "yum_grub"
	desc = "Мясо златожора, обжаренное вместе с грибами. Крайне полезно для зрения и мозга."
	list_reagents = list("oculine" = 12, "mannitol" = 12, "vitamin" = 3)

/obj/item/reagent_containers/food/snacks/lavaland_food/ashie_kebab
	name = "ashie-kebab"
	icon_state = "ashie_kebab"
	desc = "Несколько жизненно-важных органов, грубо удаленных из тела и насаженных на железный стержень. Выглядит вкусно!"
	list_reagents = list("nutriment" = 6, "protein" = 6, "ephedrine" = 10)

/obj/item/reagent_containers/food/snacks/lavaland_food/ashie_kebab/on_mob_eating_effect(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		human.add_blood()

/obj/item/reagent_containers/food/snacks/lavaland_food/tail_o_dead
	name = "tail'o'dead"
	icon_state = "tail_o_dead"
	desc = "Массивный хвост унати, запечённый в соку фруктовых кактусов. Выглядит аппетитно!"

/obj/item/reagent_containers/food/snacks/lavaland_food/tail_o_dead/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_VISION)

/obj/item/reagent_containers/food/snacks/lavaland_food/cure_curse
	name = "cure curse"
	icon_state = "cure_curse"
	desc = "Два проткнутых сердца, одно из которых проклято. Что может пойти не так?"
	var/active = FALSE

/obj/item/reagent_containers/food/snacks/lavaland_food/cure_curse/examine(mob/user)
	. = ..()
	if(active)
		. += span_notice("проклятое сердце бьётся.")
	else
		. += span_danger("проклятое сердце неподвижно.")

/obj/item/reagent_containers/food/snacks/lavaland_food/cure_curse/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/melee/touch_attack/healtouch))
		return ..()
	if(active)
		balloon_alert(user, "уже активно!")
		return ..()
	user.say("NWOC EGEVNER")
	active = TRUE
	qdel(I)
	update_icon(UPDATE_ICON_STATE)
	return ATTACK_CHAIN_PROCEED

/obj/item/reagent_containers/food/snacks/lavaland_food/cure_curse/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][active ? "_active" : ""]"

/obj/item/reagent_containers/food/snacks/lavaland_food/cure_curse/on_mob_eating_effect(mob/user)
	if(!active)
		return
	if(isliving(user))
		var/mob/living/living_user = user
		if(!living_user.get_int_organ(/obj/item/organ/internal/regenerative_core/legion))
			new /obj/item/organ/internal/regenerative_core/legion/pre_preserved(living_user)

/obj/item/reagent_containers/food/snacks/lavaland_food/wings_n_fangs_n_tentacles
	name = "wings'n'fangs'n'tentacles"
	icon_state = "wings_n_fangs_n_tentacles"
	desc = "Одно из щупалец голиафа, крыло наблюдателя и жвало ткача, запеченные вместе. На вкус оно так же ужасно, как и на вид."

/obj/item/reagent_containers/food/snacks/lavaland_food/wings_n_fangs_n_tentacles/on_mob_eating_effect(mob/user)
	if(isunathi(user))
		var/mob/living/carbon/human/human_unathi = user
		var/obj/item/organ/internal/cyberimp/tail/blade/organic_upgrade/tumour = human_unathi.get_organ_slot(INTERNAL_ORGAN_TAIL_DEVICE)
		if(!tumour)
			tumour = new
			to_chat(human_unathi, span_warning("Вы чувствуете сильное покалывание в вашем хвосте."))
			tumour.insert(human_unathi)

/obj/item/reagent_containers/food/snacks/lavaland_food/goli_kernels
	name = "goli-kernels"
	icon_state = "goli_kernels"
	desc = "небольшой мясной шарик на \"подносе\" из грибной шляпки. Вкуснятина!"
	list_reagents = list("nutriment" = 2, "protein" = 2)
	eat_time = 0 SECONDS

/obj/item/reagent_containers/food/snacks/lavaland_food/goli_kernels/triple/Initialize(mapload)
	. = ..()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/food/snacks/lavaland_food/goli_kernels(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/item/reagent_containers/food/snacks/lavaland_food/goli_kernels/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()

	if(..() || !ishuman(hit_atom))//if it gets caught or the target aren't human
		return TRUE	//abort

	var/mob/living/carbon/human/target = hit_atom
	target.eat(src, target)
	qdel(src)

/obj/item/reagent_containers/food/snacks/lavaland_food/grace_of_lazis
	name = "grace of lazis portion"
	desc = "Кусок мяса, срезанный с массивного постамента в честь славной охоты. Невероятно вкусно."
	icon_state = "grace_of_lazis"
	list_reagents = list("protein" = 4, "vitamin" = 2)
	eat_time = 0 SECONDS

/obj/item/reagent_containers/food/snacks/lavaland_food/beer_grub_stew
	name = "beer grub stew"
	desc = "Алкогольное рагу, приготовленное с использованием мяса златожора. Питательно!"
	icon_state = "beer_grub_stew"
	list_reagents = list("nutriment" = 4, "protein" = 6, "beer" = 7)

/obj/item/reagent_containers/food/snacks/lavaland_food/beer_grub_stew/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_TEMPERATURE_STABILIZE)

/obj/item/reagent_containers/food/snacks/lavaland_food/thick_red_paste
	name = "thick red paste"
	desc = "Отвратительно выглядящая на вид вязкая красная паста, сделанная из ошмётков тел. На вкус невероятно отвратительно."
	icon_state = "thick_red_paste"
	list_reagents = list("protein" = 2)

/obj/item/reagent_containers/food/snacks/lavaland_food/thick_red_paste/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_ETERNAL_BLEEDING_FIX)

/obj/item/reagent_containers/food/snacks/lavaland_food/black_blood_sausage
	name = "black blood sausage"
	desc = "Небольшая кровяная колбаска, сделанная из мяса голиафа и... настоящей крови. Крайне полезно, если вы в критическом состоянии."
	icon_state = "black_blood_sausage"
	list_reagents = list("nutriment" = 4, "protein" = 3, "ashiezine" = 6)

/obj/item/reagent_containers/food/snacks/lavaland_food/xeno_sticks
	name = "xeno sticks"
	desc = "Мясо ксеноморфа на палочках, украшенное грибами рейши. На удивление довольно вкусное!"
	icon_state = "xeno_sticks"

/obj/item/reagent_containers/food/snacks/lavaland_food/xeno_sticks/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_NIGHT_VISION)

/obj/item/reagent_containers/food/snacks/lavaland_food/filet_madras
	name = "filet madras"
	desc = "Нежное филе рыбы, обжаренное вместе с грибами. Невероятно вкусно."
	icon_state = "filet_madras"
	list_reagents = list("nutriment" = 3, "protein" = 2, "pen_acid" = 4)

/obj/item/reagent_containers/food/snacks/lavaland_food/eel_katigo
	name = "eel katigo"
	desc = "Филе донного угря с травяными приправами и \"соусом\" в виде собранных кусков мяса. Питательно!"
	icon_state = "eel_katigo"
	list_reagents = list("nutriment" = 3, "protein" = 2, "nicotine" = 6, "menthol" = 15)

/obj/item/reagent_containers/food/snacks/lavaland_food/predatory_chowder
	name = "predatory chowder"
	desc = "Суп, приготовленный с использованием рыбного мяса, приправ и человеческих органов. Вкусно!"
	icon_state = "predatory_chowder"
	list_reagents = list("nutriment" = 3, "protein" = 2, "godblood" = 20)

/obj/item/reagent_containers/food/snacks/lavaland_food/abu_ghosh
	name = "abu ghosh"
	desc = "Суп, приготовленный с использованием молока гатланчей и местных ингридиентов. Вкуснятина!"
	icon_state = "abu_ghosh"

/obj/item/reagent_containers/food/snacks/lavaland_food/abu_ghosh/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_BLOOD_REGEN)

/obj/item/storage/bag/tray/lava_tray
	name = "thali lazis plate"
	desc = "Большой поднос, сделанный из дерева. Предназначен для хранения огромного количества съестного."
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "thali_lazis_plate"
	flags = NONE
	materials = null
	can_hold = list(
		/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bacon,
		/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_cacti,
		/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_wing,
		/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_fish,
		/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_crunchie,
		/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bungus,
	)
	display_contents_with_number = TRUE
	storage_slots = 12
	max_combined_w_class = 30
	slot_flags = NONE

/obj/item/storage/bag/tray/lava_tray/update_overlays()
	for(var/obj/item/reagent_containers/food/snacks/lavaland/snack in contents)
		. += image(icon = snack.icon, icon_state = snack.overlay_sprite)

/obj/item/storage/bag/tray/lava_tray/full/populate_contents()
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bacon(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_cacti(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_wing(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_fish(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_crunchie(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bungus(src)
	update_icon()

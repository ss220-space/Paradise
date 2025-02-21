/obj/item/reagent_containers/food/snacks/lavaland
	gender = MALE
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	lefthand_file = 'icons/mob/inhands/lavaland/fish_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/fish_items_righthand.dmi'
	item_state = "food"
	var/overlay_sprite
	list_reagents = list("nutriment" = 2, "vitamin" = 4, "protein" = 2)

/obj/item/reagent_containers/food/snacks/lavaland/soft_meat
	name = "soft meat cut"
	desc = "Нежное филе лавовой рыбы. Сырое в текущем виде, однако с помощью правильных ингридиентов её можно будет превратить в прекрасное блюдо."
	ru_names = list(
		NOMINATIVE = "нежная мясная вырезка",
		GENITIVE = "нежной мясной вырезки",
		DATIVE = "нежной мясной вырезке",
		ACCUSATIVE = "нежную мясную вырезку",
		INSTRUMENTAL = "нежной мясной вырезкой",
		PREPOSITIONAL = "нежной мясной вырезке",
	)
	gender = FEMALE
	icon_state = "soft_meat_cut"
	item_state = "soft_meat_cut"
	list_reagents = list("nutriment" = 1, "vitamin" = 3, "protein" = 3)
	bitesize = 2
	filling_color = "#D49284"
	tastes = list("сырого мяса" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/lavaland/eel_filet
	name = "eel filet"
	desc = "Сырое филе донного угря. Хоть оно съедобно и в сыром виде, однако с помощью правильных ингридиентов её можно будет превратить в прекрасное блюдо."
	ru_names = list(
		NOMINATIVE = "филе угря",
		GENITIVE = "филе угря",
		DATIVE = "филе угря",
		ACCUSATIVE = "филе угря",
		INSTRUMENTAL = "филе угря",
		PREPOSITIONAL = "филе угря",
	)
	gender = NEUTER
	icon_state = "eel_filet"
	item_state = "eel_filet"
	list_reagents = list("nutriment" = 2, "menthol" = 3, "protein" = 4)
	bitesize = 2
	filling_color = "#414F71"
	tastes = list("сырого мяса" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/lavaland/predator_meat
	name = "predatory fish slice"
	desc = "Достаточно большой кусок мяса, добытый из хищной рыбы. Не рекомендуется к употреблению в сыром виде."
	ru_names = list(
		NOMINATIVE = "кусок мяса хищной рыбы",
		GENITIVE = "куска мяса хищной рыбы",
		DATIVE = "куску мяса хищной рыбы",
		ACCUSATIVE = "кусок мяса хищной рыбы",
		INSTRUMENTAL = "куском мяса хищной рыбы",
		PREPOSITIONAL = "куске мяса хищной рыбы",
	)
	icon_state = "predatory_fish_slice"
	item_state = "predatory_fish_slice"
	list_reagents = list("nutriment" = 2, "toxin" = 2, "protein" = 4)
	bitesize = 3
	filling_color = "#BE7C64"
	tastes = list("очень горького мяса" = 1)
	foodtype = MEAT | TOXIC | RAW

/obj/item/reagent_containers/food/snacks/lavaland/soft_meat_cubes
	name = "soft meat cubes"
	desc = "Филе рыбы, порезанное на маленькие кубики и обжаренное в печи. Выглядит аппетитно."
	ru_names = list(
		NOMINATIVE = "нежные мясные кубики",
		GENITIVE = "нежных мясных кубиков",
		DATIVE = "нежным мясным кубикам",
		ACCUSATIVE = "нежные мясные кубики",
		INSTRUMENTAL = "нежными мясными кубиками",
		PREPOSITIONAL = "нежных мясных кубиках",
	)
	gender = PLURAL
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "soft_meat_cubes"
	list_reagents = list("nutriment" = 2, "vitamin" = 3, "protein" = 3)
	bitesize = 3
	filling_color = "#BE7C64"
	tastes = list("нежного мяса" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/predatory_fish_slab
	name = "cooked predatory fish slab"
	desc = "Кусок мяса хищной рыбы, обжаренный в печи. Пригоден к употреблению."
	ru_names = list(
		NOMINATIVE = "жаренный кусок мяса хищной рыбы",
		GENITIVE = "жаренного куска мяса хищной рыбы",
		DATIVE = "жаренному куску мяса хищной рыбы",
		ACCUSATIVE = "жаренный кусок мяса хищной рыбы",
		INSTRUMENTAL = "жаренным куском мяса хищной рыбы",
		PREPOSITIONAL = "жаренном куске мяса хищной рыбы",
	)
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "predatory_fish_slab"
	list_reagents = list("nutriment" = 4, "protein" = 6)
	bitesize = 3
	filling_color = "#BE7C64"
	tastes = list("мяса" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/eel_ringlets
	name = "eel ringlets"
	desc = "Обжаренное в печи филе донного угря. Невероятно вкусное."
	ru_names = list(
		NOMINATIVE = "колечки из угря",
		GENITIVE = "колечек из угря",
		DATIVE = "колечкам из угря",
		ACCUSATIVE = "колечки из угря",
		INSTRUMENTAL = "колечками из угря",
		PREPOSITIONAL = "колечках из угря",
	)
	gender = PLURAL
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "eel_ringlets"
	list_reagents = list("nutriment" = 4, "protein" = 6)
	bitesize = 3
	filling_color = "#BE7C64"
	tastes = list("нежного мяса" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bacon
	name = "thali lazis bacon part"
	desc = "Небольшая порция бекона, взятая из тарелки Тали Лазис."
	ru_names = list(
		NOMINATIVE = "кусочек бекона Тали Лазис",
		GENITIVE = "кусочка бекона Тали Лазис",
		DATIVE = "кусочку бекона Тали Лазис",
		ACCUSATIVE = "кусочек бекона Тали Лазис",
		INSTRUMENTAL = "кусочком бекона Тали Лазис",
		PREPOSITIONAL = "кусочке бекона Тали Лазис",
	)
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "thali_lazis_bacon"
	overlay_sprite = "thali_lazis_bacon_overlay"
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_cacti
	name = "thali lazis cacti part"
	desc = "Небольшой кактус, взятый из тарелки Тали Лазис."
	ru_names = list(
		NOMINATIVE = "кусочек кактуса Тали Лазис",
		GENITIVE = "кусочка кактуса Тали Лазис",
		DATIVE = "кусочку кактуса Тали Лазис",
		ACCUSATIVE = "кусочек кактуса Тали Лазис",
		INSTRUMENTAL = "кусочком кактуса Тали Лазис",
		PREPOSITIONAL = "кусочке кактуса Тали Лазис",
	)
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "thali_lazis_cacti"
	overlay_sprite = "thali_lazis_cacti_overlay"
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_wing
	name = "thali lazis wing part"
	desc = "Небольшое крыло, взятое из тарелки Тали Лазис."
	ru_names = list(
		NOMINATIVE = "кусочек крылышка Тали Лазис",
		GENITIVE = "кусочка крылышка Тали Лазис",
		DATIVE = "кусочку крылышка Тали Лазис",
		ACCUSATIVE = "кусочек крылышка Тали Лазис",
		INSTRUMENTAL = "кусочком крылышка Тали Лазис",
		PREPOSITIONAL = "кусочке крылышка Тали Лазис",
	)
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "thali_lazis_wing"
	overlay_sprite = "thali_lazis_wing_overlay"
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_fish
	name = "thali lazis fish part"
	desc = "Небольшая порция рыбы, взятая из тарелки Тали Лазис."
	ru_names = list(
		NOMINATIVE = "кусочек рыбы Тали Лазис",
		GENITIVE = "кусочка рыбы Тали Лазис",
		DATIVE = "кусочку рыбы Тали Лазис",
		ACCUSATIVE = "кусочек рыбы Тали Лазис",
		INSTRUMENTAL = "кусочком рыбы Тали Лазис",
		PREPOSITIONAL = "кусочке рыбы Тали Лазис",
	)
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "thali_lazis_fish"
	overlay_sprite = "thali_lazis_fish_overlay"
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_crunchie
	name = "thali lazis crunchie part"
	desc = "Небольшая хрустящая порция, взятая из тарелки Тали Лазис."
	ru_names = list(
		NOMINATIVE = "хрустящий кусочек Тали Лазис",
		GENITIVE = "хрустящего кусочка Тали Лазис",
		DATIVE = "хрустящему кусочку Тали Лазис",
		ACCUSATIVE = "хрустящий кусочек Тали Лазис",
		INSTRUMENTAL = "хрустящим кусочком Тали Лазис",
		PREPOSITIONAL = "хрустящем кусочке Тали Лазис",
	)
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "thali_lazis_crunchie"
	overlay_sprite = "thali_lazis_crunchie_overlay"
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bungus
	name = "thali lazis bungus part"
	desc = "Небольшая порция грибов, взятая из тарелки Тали Лазис."
	ru_names = list(
		NOMINATIVE = "грибной кусочек Тали Лазис",
		GENITIVE = "грибного кусочка Тали Лазис",
		DATIVE = "грибному кусочку Тали Лазис",
		ACCUSATIVE = "грибной кусочек Тали Лазис",
		INSTRUMENTAL = "грибном кусочком Тали Лазис",
		PREPOSITIONAL = "грибном кусочке Тали Лазис",
	)
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "thali_lazis_bungus"
	overlay_sprite = "thali_lazis_bungus_overlay"
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/lavaland_food
	name = "generic lavaland food"
	desc = "самое обычное блюдо. Если вы это видите, то Зюзя напортачил"
	ru_names = list(
		NOMINATIVE = "блюдо Лазиса",
		GENITIVE = "блюда Лазиса",
		DATIVE = "блюду Лазиса",
		ACCUSATIVE = "блюдо Лазиса",
		INSTRUMENTAL = "блюдом Лазиса",
		PREPOSITIONAL = "блюде Лазиса",
	)
	gender = NEUTER
	icon = 'icons/obj/lavaland/ashie_food.dmi'
	icon_state = "fine_meal"
	lefthand_file = 'icons/mob/inhands/lavaland/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/food_righthand.dmi'
	item_state = "food"
	bitesize = 100 //eat whole thing down
	list_reagents = list("nutriment" = 6, "protein" = 6)
	tastes = list("вкусной еды" = 1)
	has_special_eating_effects = TRUE
	eat_time = 5 SECONDS
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland_food/fine_meal
	name = "fine meal"
	desc = "Мясо Голиафа, обжаренное в соку кактусового фрукта. Невероятно вкусное и питательное."
	ru_names = list(
		NOMINATIVE = "изысканная еда Лазиса",
		GENITIVE = "изысканной еды Лазиса",
		DATIVE = "изысканной еде Лазиса",
		ACCUSATIVE = "изысканную еду Лазиса",
		INSTRUMENTAL = "изысканной едой Лазиса",
		PREPOSITIONAL = "изысканное еде Лазиса",
	)
	gender = FEMALE
	icon_state = "fine_meal"
	list_reagents = list("vitfro" = 6, "protein" = 7, "vitamin" = 3)
	tastes = list("сбалансированной еды" = 1)
	foodtype = MEAT|FRUIT

/obj/item/reagent_containers/food/snacks/lavaland_food/fine_meal/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_FORCED_RUMBLE)

/obj/item/reagent_containers/food/snacks/lavaland_food/freaky_leg
	name = "freaky leg"
	desc = "Многие народы галактики расценивают поедание себе подобных как ужасающее преступление. Однако эти стопы вышли уж слишком питательными..."
	ru_names = list(
		NOMINATIVE = "блюдо \"Причудливые Ноги\"",
		GENITIVE = "блюда \"Причудливые Ноги\"",
		DATIVE = "блюду \"Причудливые Ноги\"",
		ACCUSATIVE = "блюдо\"Причудливые Ноги\"",
		INSTRUMENTAL = "блюдом \"Причудливые Ноги\"",
		PREPOSITIONAL = "блюде \"Причудливые Ноги\"",
	)
	icon_state = "freaky_leg"
	tastes = list("тяжёлых времён" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lavaland_food/freaky_leg/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_NO_PAIN)

/obj/item/reagent_containers/food/snacks/lavaland_food/veggie_meal
	name = "veggie meal"
	desc = "Обычно пеплоходцы питаются мясом местной фауны, однако, если правильно смешать нужные вещества, то получится крайне полезное растительное блюдо. Хотя на вкус оно так себе."
	ru_names = list(
		NOMINATIVE = "вегетарианское блюдо Лазиса",
		GENITIVE = "вегетарианского блюда Лазиса",
		DATIVE = "вегетарианскому блюду Лазиса",
		ACCUSATIVE = "вегетарианское блюдо Лазиса",
		INSTRUMENTAL = "вегетарианским блюдом Лазиса",
		PREPOSITIONAL = "вегетарианском блюде Лазиса",
	)
	icon_state = "veggie_meal"
	list_reagents = list("spaceacillin" = 10, "lavaland_extract" = 2, "vitfro" = 20, "sal_acid" = 15)
	tastes = list("трав" = 1)
	foodtype = FRUIT|VEGETABLES

/obj/item/reagent_containers/food/snacks/lavaland_food/veggie_meal/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_FORCED_SNEEZE)

/obj/item/reagent_containers/food/snacks/lavaland_food/hunters_treat
	name = "hunter's treat"
	desc = "Человеческое сердце, обжаренное в соку мяса Голиафа. Легенды говорят, что если сьесть сердце поверженного врага, то обретёшь невероятную силу."
	ru_names = list(
		NOMINATIVE = "блюдо \"Угощение Охотника\"",
		GENITIVE = "блюда \"Угощение Охотника\"",
		DATIVE = "блюду \"Угощение Охотника\"",
		ACCUSATIVE = "блюдо\"Угощение Охотника\"",
		INSTRUMENTAL = "блюдом \"Угощение Охотника\"",
		PREPOSITIONAL = "блюде \"Угощение Охотника\"",
	)
	icon_state = "hunters_treat"

/obj/item/reagent_containers/food/snacks/lavaland_food/hunters_treat/on_mob_eating_effect(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		human.force_gene_block(GLOB.strongblock, TRUE)

/obj/item/reagent_containers/food/snacks/lavaland_food/yum_grub
	name = "yum-grub"
	desc = "Мясо златожора, обжаренное вместе с грибами. Говорят, что оно благотворно воздействует на здоровье нервной системы и сенсорных органов."
	ru_names = list(
		NOMINATIVE = "блюдо \"Ям-Граб\"",
		GENITIVE = "блюда \"Ям-Граб\"",
		DATIVE = "блюду \"Ям-Граб\"",
		ACCUSATIVE = "блюдо\"Ям-Граб\"",
		INSTRUMENTAL = "блюдом \"Ям-Граб\"",
		PREPOSITIONAL = "блюде \"Ям-Граб\"",
	)
	icon_state = "yum_grub"
	list_reagents = list("oculine" = 12, "mannitol" = 12, "vitamin" = 3)

/obj/item/reagent_containers/food/snacks/lavaland_food/ashie_kebab
	name = "ashie-kebab"
	desc = "Несколько жизненно-важных органов, грубо удаленных из тела и насаженных на железный стержень. Настолько же первобытно, насколько и вкусно!"
	ru_names = list(
		NOMINATIVE = "пепло-кебаб Лазиса",
		GENITIVE = "пепло-кебаба Лазиса",
		DATIVE = "пепло-кебАбу Газиса",
		ACCUSATIVE = "пепло-кебаб Лазиса",
		INSTRUMENTAL = "пепло-кебабом Лазиса",
		PREPOSITIONAL = "пепло-кебабе Лазиса",
	)
	icon_state = "ashie_kebab"
	item_state = "ashie_kebab"
	list_reagents = list("nutriment" = 6, "protein" = 6, "ephedrine" = 10)

/obj/item/reagent_containers/food/snacks/lavaland_food/ashie_kebab/on_mob_eating_effect(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		human.add_blood()

/obj/item/reagent_containers/food/snacks/lavaland_food/tail_o_dead
	name = "tail'o'dead"
	desc = "Массивный хвост унатха, запечённый в соку фруктовых кактусов. Выглядит аппетитно!"
	ru_names = list(
		NOMINATIVE = "блюдо \"Отрезанный Хвост\"",
		GENITIVE = "блюда \"Отрезанный Хвост\"",
		DATIVE = "блюду \"Отрезанный Хвост\"",
		ACCUSATIVE = "блюдо\"Отрезанный Хвост\"",
		INSTRUMENTAL = "блюдом \"Отрезанный Хвост\"",
		PREPOSITIONAL = "блюде \"Отрезанный Хвост\"",
	)
	icon_state = "tail_o_dead"

/obj/item/reagent_containers/food/snacks/lavaland_food/tail_o_dead/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_VISION)

/obj/item/reagent_containers/food/snacks/lavaland_food/cure_curse
	name = "cure curse"
	desc = "Два проткнутых сердца, одно из которых проклято. Что может пойти не так?"
	ru_names = list(
		NOMINATIVE = "блюдо \"Проклятое Лечение\"",
		GENITIVE = "блюда \"Проклятое Лечение\"",
		DATIVE = "блюду \"Проклятое Лечение\"",
		ACCUSATIVE = "блюдо\"Проклятое Лечение\"",
		INSTRUMENTAL = "блюдом \"Проклятое Лечение\"",
		PREPOSITIONAL = "блюде \"Проклятое Лечение\"",
	)
	icon_state = "cure_curse"
	var/active = FALSE

/obj/item/reagent_containers/food/snacks/lavaland_food/cure_curse/examine(mob/user)
	. = ..()
	if(active)
		. += span_notice("Проклятое сердце бьётся.")
	else
		. += span_danger("Проклятое сердце неподвижно.")

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
	desc = "Одно из щупалец Голиафа, крыло наблюдателя и жвало ткача, запеченные вместе. На вкус оно так же ужасно, как и на вид."
	ru_names = list(
		NOMINATIVE = "блюдо \"Крылья, клыки и щупальца\"",
		GENITIVE = "блюда \"Крылья, клыки и щупальца\"",
		DATIVE = "блюду \"Крылья, клыки и щупальца\"",
		ACCUSATIVE = "блюдо\"Крылья, клыки и щупальца\"",
		INSTRUMENTAL = "блюдом \"Крылья, клыки и щупальца\"",
		PREPOSITIONAL = "блюде \"Крылья, клыки и щупальца\"",
	)
	icon_state = "wings_n_fangs_n_tentacles"

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
	desc = "небольшой мясной шарик на \"подносе\" из грибной шляпки. Вкуснятина!"
	ru_names = list(
		NOMINATIVE = "блюдо \"Голи-кернельс\"",
		GENITIVE = "блюда \"Голи-кернельс\"",
		DATIVE = "блюду \"Голи-кернельс\"",
		ACCUSATIVE = "блюдо\"Голи-кернельс\"",
		INSTRUMENTAL = "блюдом \"Голи-кернельс\"",
		PREPOSITIONAL = "блюде \"Голи-кернельс\"",
	)
	icon_state = "goli_kernels"
	list_reagents = list("nutriment" = 2, "protein" = 2)
	eat_time = 0 SECONDS

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
	ru_names = list(
		NOMINATIVE = "порция с постамента \"Благодать Лазис Ардакса\"",
		GENITIVE = "порции с постамента \"Благодать Лазис Ардакса\"",
		DATIVE = "порции с постамента \"Благодать Лазис Ардакса\"",
		ACCUSATIVE = "порцию с постамента \"Благодать Лазис Ардакса\"",
		INSTRUMENTAL = "порцией с постамента \"Благодать Лазис Ардакса\"",
		PREPOSITIONAL = "порции с постамента \"Благодать Лазис Ардакса\"",
	)
	gender = FEMALE
	icon_state = "grace_of_lazis"
	list_reagents = list("protein" = 4, "vitamin" = 2)
	eat_time = 0 SECONDS

/obj/item/reagent_containers/food/snacks/lavaland_food/beer_grub_stew
	name = "beer grub stew"
	desc = "Алкогольное рагу, приготовленное с использованием мяса златожора. Питательно!"
	ru_names = list(
		NOMINATIVE = "тушёное рагу",
		GENITIVE = "тушёного рагу",
		DATIVE = "тушёному рагу",
		ACCUSATIVE = "тушёное рагу",
		INSTRUMENTAL = "тушёным рагу",
		PREPOSITIONAL = "тушёном рагу",
	)
	icon_state = "beer_grub_stew"
	list_reagents = list("nutriment" = 4, "protein" = 6, "beer" = 7)

/obj/item/reagent_containers/food/snacks/lavaland_food/beer_grub_stew/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_TEMPERATURE_STABILIZE)

/obj/item/reagent_containers/food/snacks/lavaland_food/thick_red_paste
	name = "thick red paste"
	desc = "Отвратительно выглядящая на вид вязкая красная паста, сделанная из ошмётков тел. На вкус невероятно омерзительно."
	ru_names = list(
		NOMINATIVE = "густая красная паста",
		GENITIVE = "густой красной пасты",
		DATIVE = "густой красной пасте",
		ACCUSATIVE = "густую красную пасту",
		INSTRUMENTAL = "густой красной пастой",
		PREPOSITIONAL = "густой красной пасте",
	)
	gender = FEMALE
	icon_state = "thick_red_paste"
	list_reagents = list("protein" = 2)

/obj/item/reagent_containers/food/snacks/lavaland_food/thick_red_paste/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_ETERNAL_BLEEDING_FIX)

/obj/item/reagent_containers/food/snacks/lavaland_food/black_blood_sausage
	name = "black blood sausage"
	desc = "Небольшая кровяная колбаска, сделанная из мяса Голиафа и... настоящей крови. Крайне полезно, если вы в критическом состоянии."
	ru_names = list(
		NOMINATIVE = "черная кровяная колбаска",
		GENITIVE = "черной кровяной колбаски",
		DATIVE = "черной кровяной колбаске",
		ACCUSATIVE = "черную кровяную колбаску",
		INSTRUMENTAL = "черной кровяной колбаской",
		PREPOSITIONAL = "черной кровяной колбаске",
	)
	gender = FEMALE
	icon_state = "black_blood_sausage"
	item_state = "black_blood_sausage"
	list_reagents = list("nutriment" = 4, "protein" = 3, "ashiezine" = 6)

/obj/item/reagent_containers/food/snacks/lavaland_food/xeno_sticks
	name = "xeno sticks"
	desc = "Мясо ксеноморфа на палочках, украшенное грибами рейши. На удивление довольно вкусное!"
	ru_names = list(
		NOMINATIVE = "ксено-палочки",
		GENITIVE = "ксено-палочек",
		DATIVE = "ксено-палочкам",
		ACCUSATIVE = "ксено-палочки",
		INSTRUMENTAL = "ксено-палочками",
		PREPOSITIONAL = "ксено-палочках",
	)
	gender = PLURAL
	icon_state = "xeno_sticks"
	item_state = "xeno_sticks"

/obj/item/reagent_containers/food/snacks/lavaland_food/xeno_sticks/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_NIGHT_VISION)

/obj/item/reagent_containers/food/snacks/lavaland_food/filet_madras
	name = "filet madras"
	desc = "Нежное филе рыбы, обжаренное вместе с грибами. Невероятно вкусно."
	ru_names = list(
		NOMINATIVE = "блюдо \"Филе Мадрас\"",
		GENITIVE = "блюда \"Филе Мадрас\"",
		DATIVE = "блюду \"Филе Мадрас\"",
		ACCUSATIVE = "блюдо\"Филе Мадрас\"",
		INSTRUMENTAL = "блюдом \"Филе Мадрас\"",
		PREPOSITIONAL = "блюде \"Филе Мадрас\"",
	)
	icon_state = "filet_madras"
	list_reagents = list("nutriment" = 3, "protein" = 2, "pen_acid" = 4)

/obj/item/reagent_containers/food/snacks/lavaland_food/eel_katigo
	name = "eel katigo"
	desc = "Филе донного угря с травяными приправами и \"соусом\" в виде собранных кусков мяса. Питательно!"
	ru_names = list(
		NOMINATIVE = "блюдо \"Угорь Катиго\"",
		GENITIVE = "блюда \"Угорь Катиго\"",
		DATIVE = "блюду \"Угорь Катиго\"",
		ACCUSATIVE = "блюдо\"Угорь Катиго\"",
		INSTRUMENTAL = "блюдом \"Угорь Катиго\"",
		PREPOSITIONAL = "блюде \"Угорь Катиго\"",
	)
	icon_state = "eel_katigo"
	list_reagents = list("nutriment" = 3, "protein" = 2, "nicotine" = 6, "menthol" = 15)

/obj/item/reagent_containers/food/snacks/lavaland_food/predatory_chowder
	name = "predatory chowder"
	desc = "Суп, приготовленный с использованием рыбного мяса, приправ и человеческих органов. Вкусно!"
	ru_names = list(
		NOMINATIVE = "блюдо \"Похлёбка Хищника\"",
		GENITIVE = "блюда \"Похлёбка Хищника\"",
		DATIVE = "блюду \"Похлёбка Хищника\"",
		ACCUSATIVE = "блюдо\"Похлёбка Хищника\"",
		INSTRUMENTAL = "блюдом \"Похлёбка Хищника\"",
		PREPOSITIONAL = "блюде \"Похлёбка Хищника\"",
	)
	icon_state = "predatory_chowder"
	list_reagents = list("nutriment" = 3, "protein" = 2, "godblood" = 20)

/obj/item/reagent_containers/food/snacks/lavaland_food/abu_ghosh
	name = "abu ghosh"
	desc = "Суп, приготовленный с использованием молока гатланчей и местных ингридиентов. Вкуснятина!"
	ru_names = list(
		NOMINATIVE = "блюдо \"Абу Гош\"",
		GENITIVE = "блюда \"Абу Гош\"",
		DATIVE = "блюду \"Абу Гош\"",
		ACCUSATIVE = "блюдо\"Абу Гош\"",
		INSTRUMENTAL = "блюдом \"Абу Гош\"",
		PREPOSITIONAL = "блюде \"Абу Гош\"",
	)
	icon_state = "abu_ghosh"

/obj/item/reagent_containers/food/snacks/lavaland_food/abu_ghosh/on_mob_eating_effect(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(STATUS_EFFECT_LAVALAND_BLOOD_REGEN)

/obj/item/storage/lava_tray
	name = "thali lazis plate"
	desc = "Большой поднос, сделанный из дерева. Предназначен для хранения огромного количества съестного."
	ru_names = list(
		NOMINATIVE = "поднос \"Тали Лазис\"",
		GENITIVE = "подноса \"Тали Лазис\"",
		DATIVE = "подносу \"Тали Лазис\"",
		ACCUSATIVE = "поднос \"Тали Лазис\"",
		INSTRUMENTAL = "подносом \"Тали Лазис\"",
		PREPOSITIONAL = "подносе \"Тали Лазис\"",
	)
	gender = MALE
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

/obj/item/storage/lava_tray/update_overlays()
	. = ..()
	for(var/obj/item/reagent_containers/food/snacks/lavaland/snack in contents)
		. += mutable_appearance(icon = snack.icon, icon_state = snack.overlay_sprite)

/obj/item/storage/lava_tray/full/populate_contents()
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bacon(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_cacti(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_wing(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_fish(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_crunchie(src)
		new /obj/item/reagent_containers/food/snacks/lavaland/thali_lazis_bungus(src)
	update_icon(UPDATE_OVERLAYS)

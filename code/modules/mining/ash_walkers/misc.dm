//********** Acid Bladder **********//
/obj/item/acid_bladder
	name = "acid bladder"
	desc = "Небольшой кислотный мешочек, добытый с тела сернистого странника. Оболочка данного пузыря достаточно слабая и вероятнее всего разорвётся при броске во что-то. Или в кого-то."
	ru_names = list(
		NOMINATIVE = "кислотный мешочек",
		GENITIVE = "кислотного мешочка",
		DATIVE = "кислотному мешочку",
		ACCUSATIVE = "кислотный мешочек",
		INSTRUMENTAL = "кислотным мешочком",
		PREPOSITIONAL = "кислотном мешочке"
	)
	gender = MALE
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "acid_bladder"
	lefthand_file = 'icons/mob/inhands/lavaland/fish_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/fish_items_righthand.dmi'
	item_state = "acid_bladder"
	w_class = WEIGHT_CLASS_TINY

/obj/item/acid_bladder/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(hit_atom))
		var/mob/living/living = hit_atom
		var/datum/reagents/reagents_list = new (50)
		reagents_list.add_reagent("facid", 40)
		living.visible_message(span_danger("Кислотный пузырек разрывается при попадании на [living], разбрызгивая кислоту по [genderize_ru(living.gender, "его", "её", "его", "их")] телу!"))
		reagents_list.reaction(living, REAGENT_TOUCH)
		reagents_list.clear_reagents()
	else if(iswallturf(hit_atom))
		var/turf/simulated/wall/wall_target = hit_atom
		hit_atom.visible_message(span_danger("Кислотный пузырек разрывается при попадании на стену, медленно её расплавляя!"))
		wall_target.rot()
	else
		var/datum/reagents/reagents_list = new (100)
		reagents_list.add_reagent("facid", 80)
		reagents_list.reaction(hit_atom, REAGENT_TOUCH)
	qdel(src)

//********** Saw Blade **********//
/obj/item/circular_saw_blade
	name = "circular saw blade"
	desc = "Костный нарост, похожий на лезвие циркулярной пилы, вырванный из черепа ослеплённого жнеца. Может быть использован для улучшения костяного топора."
	ru_names = list(
		NOMINATIVE = "лезвие дисковой пилы",
		GENITIVE = "лезвия дисковой пилы",
		DATIVE = "лезвию дисковой пилы",
		ACCUSATIVE = "лезвие дисковой пилы",
		INSTRUMENTAL = "лезвием дисковой пилы",
		PREPOSITIONAL = "лезвии дисковой пилы"
	)
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "circular_saw_blade"
	lefthand_file = 'icons/mob/inhands/lavaland/fish_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/fish_items_righthand.dmi'
	item_state = "circular_saw_blade"
	w_class = WEIGHT_CLASS_TINY

//**********Grace of Lazis **********//
/obj/structure/grace_of_lazis
	name = "grace of lazis"
	desc = "Огромное количество мяса, насаженного на костяное копье. Символ невероятно удачного сезона охоты."
	ru_names = list(
		NOMINATIVE = "благодать Лазис Ардакса",
		GENITIVE = "благодати Лазис Ардакса",
		DATIVE = "благодати Лазис Ардакса",
		ACCUSATIVE = "благодать Лазис Ардакса",
		INSTRUMENTAL = "благодатью Лазис Ардакса",
		PREPOSITIONAL = "благодати Лазис Ардакса"
	)
	gender = FEMALE
	icon = 'icons/obj/lavaland/grace_of_lazis.dmi'
	icon_state = "grace_of_lazis4"
	anchored = TRUE
	density = TRUE
	max_integrity = 1000
	var/meat_parts = 40

/obj/structure/grace_of_lazis/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/kitchen/knife))
		return ..()

	to_chat(user, span_notice("Вы начинаете отрезать порцию мяса от постамента."))

	if(!do_after(user, 3 SECONDS, src, max_interact_count = 1))
		return ..()

	meat_parts--
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_notice("Вы отрезаете порцию мяса с постамента."))
	var/obj/item/reagent_containers/food/snacks/lavaland_food/grace_of_lazis/food = new()
	user.put_in_hands(food)
	if(meat_parts == 0)
		visible_message(span_warning("От постамента остаётся лишь одно копье!"))
		new /obj/item/twohanded/spear/bonespear(src.loc)
		qdel(src)
		return ATTACK_CHAIN_PROCEED
	return ATTACK_CHAIN_BLOCKED

/obj/structure/grace_of_lazis/update_icon_state()
	switch(meat_parts)
		if(1 to 10)
			icon_state = "grace_of_lazis1"
		if(11 to 20)
			icon_state = "grace_of_lazis2"
		if(21 to 30)
			icon_state = "grace_of_lazis3"
		if(31 to INFINITY)
			icon_state = "grace_of_lazis4"

//**********Food Scroll**********//
/obj/item/book/manual/lavaland_scroll
	name = "cooking scroll"
	desc = "Пергамент, изготовленный из человеческой кожи. На нём нанесена информация о том, как прокормить голодное племя."
	ru_names = list(
		NOMINATIVE = "свиток готовки",
		GENITIVE = "свитка готовки",
		DATIVE = "свитку готовки",
		ACCUSATIVE = "свиток готовки",
		INSTRUMENTAL = "свитком готовки",
		PREPOSITIONAL = "свитке готовки"
	)
	gender = MALE
	icon_state = "food_scroll"
	item_state = "food_scroll"
	author = "Шаман голодного племени"
	title = "Руководство по Готовке"
	wiki_title = "Еда_пеплоходцев"

/obj/structure/fluff/ash_statue //used to mark point of interest
	name = "тотем"
	desc = "Массивный каменный столб с прикреплённым к нему черепом убитого зверя. Кажется, вы зашли в охотничьи угодья пеплоходцев."
	ru_names = list(
		NOMINATIVE = "пепельный тотем",
		GENITIVE = "пепельного тотема",
		DATIVE = "пепельному тотему",
		ACCUSATIVE = "пепельный тотем",
		INSTRUMENTAL = "пепельным тотемом",
		PREPOSITIONAL = "пепельном тотеме"
	)
	icon = 'icons/obj/lavaland/grace_of_lazis.dmi'
	icon_state = "totem_stone"
	anchored = TRUE
	density = TRUE
	deconstructible = FALSE
	/// Used in shaman spell. Perfect for finding stuff ic
	var/special_name = "точка интереса"

/obj/structure/fluff/ash_statue/Initialize(mapload)
	name = "тотем - [special_name]"
	GLOB.lavaland_points_of_interest += src
	. = ..()

/obj/structure/fluff/ash_statue/Destroy(force)
	GLOB.lavaland_points_of_interest -= src
	. = ..()


/obj/structure/ash_totem
	name = "totem"
	desc = "Совершенно обычный тотем! Выглядит прикольно. Вы не должны видеть это."
	ru_names = list(
		NOMINATIVE = "тотем",
		GENITIVE = "тотема",
		DATIVE = "тотему",
		ACCUSATIVE = "тотем",
		INSTRUMENTAL = "тотемом",
		PREPOSITIONAL = "тотеме"
	)
	gender = MALE
	icon = 'icons/obj/lavaland/grace_of_lazis.dmi'
	icon_state = "totem_wooden"
	max_integrity = 1000
	anchored = TRUE
	density = TRUE
	var/applied_dye = null
	var/applied_dye_fluff_name = null

/obj/structure/ash_totem/examine(mob/user)
	. = ..()
	. += span_notice("Эта статуя может использоваться вместо полноценного пеплоходца, если будет построена у ритуальной руны.")

	if(applied_dye && applied_dye_fluff_name) //jeez this is so hard to make it in russian holy fuck
		. += span_notice("На эту статую нанесена [applied_dye_fluff_name] краска.")

/obj/structure/ash_totem/update_overlays()
	. = ..()
	if(applied_dye)
		. += "[icon_state]_[applied_dye]"


/obj/structure/ash_totem/wooden
	name = "wooden totem"
	desc = "Массивная статуя, сделанная из цельного куска древесины. Рисунок на статуе отдалённо напоминает человеческое лицо, искаженное в гримасе ужаса."
	ru_names = list(
		NOMINATIVE = "деревянный тотем",
		GENITIVE = "деревянного тотема",
		DATIVE = "деревянному тотему",
		ACCUSATIVE = "деревянный тотем",
		INSTRUMENTAL = "деревянным тотемом",
		PREPOSITIONAL = "деревянном тотеме"
	)
	icon_state = "totem_wooden"

/obj/structure/ash_totem/stone
	name = "stone totem"
	desc = "Массивная каменная статуя с прикреплённым к ней черепом убитого животного. Сухожилия, держащие череп на месте, медленно покачиваются на ветру."
	ru_names = list(
		NOMINATIVE = "каменный тотем",
		GENITIVE = "каменного тотема",
		DATIVE = "каменному тотему",
		ACCUSATIVE = "каменный тотем",
		INSTRUMENTAL = "каменным тотемом",
		PREPOSITIONAL = "каменном тотеме"
	)
	icon_state = "totem_stone"

/obj/structure/ash_totem/bone
	name = "bone totem"
	desc = "Массивная статуя, сделанная из огромной кости. Вы не знаете, какому именно животному принадлежит эта кость, и вы явно не хотите это узнавать."
	ru_names = list(
		NOMINATIVE = "костяной тотем",
		GENITIVE = "костяного тотема",
		DATIVE = "костяному тотему",
		ACCUSATIVE = "костяной тотем",
		INSTRUMENTAL = "костяным тотемом",
		PREPOSITIONAL = "костяном тотеме"
	)
	icon_state = "totem_bone"

/obj/structure/chair/stool/wooden
	name = "wooden stool"
	desc = "Деревянная табуретка. Достаточно удобная, чтобы на ней сидеть."
	ru_names = list(
		NOMINATIVE = "деревянная табуретка",
		GENITIVE = "деревянной табуретки",
		DATIVE = "деревянной табуретке",
		ACCUSATIVE = "деревянную табуретку",
		INSTRUMENTAL = "деревянной табуреткой",
		PREPOSITIONAL = "деревянной табуретке"
	)
	gender = FEMALE
	icon_state = "wooden_stool"
	item_chair = /obj/item/chair/stool/wooden

/obj/item/chair/stool/wooden
	name = "wooden stool"
	desc = "Деревянная табуретка. Достаточно удобная, чтобы держать её в руках."
	ru_names = list(
		NOMINATIVE = "деревянная табуретка",
		GENITIVE = "деревянной табуретки",
		DATIVE = "деревянной табуретке",
		ACCUSATIVE = "деревянную табуретку",
		INSTRUMENTAL = "деревянной табуреткой",
		PREPOSITIONAL = "деревянной табуретке"
	)
	gender = FEMALE
	icon = 'icons/obj/chairs.dmi'
	icon_state = "wooden_stool_toppled"
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	item_state = "wooden_stool"
	force = 8
	origin_type = /obj/structure/chair/stool/wooden
	break_chance = 10

/obj/structure/rack/wooden
	name = "wooden rack"
	desc = "Небольшой стеллаж, сделанный из дерева. Вы можете хранить на нём вещи!"
	ru_names = list(
		NOMINATIVE = "деревянный стеллаж",
		GENITIVE = "деревянного стеллажа",
		DATIVE = "деревянному стеллажу",
		ACCUSATIVE = "деревянный стеллаж",
		INSTRUMENTAL = "деревянным стеллажом",
		PREPOSITIONAL = "деревянном стеллаже"
	)
	icon_state = "wooden_rack"
	wooden_version = TRUE
	obj_flags = NODECONSTRUCT

/obj/structure/rack/wooden/Initialize(mapload)
	. = ..()
	update_overlays()

/obj/structure/rack/wooden/wrench_act(mob/user, obj/item/I)
	return

/obj/structure/rack/wooden/MouseDrop_T(obj/item/dropping, mob/user, params)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/rack/wooden/update_overlays()
	overlays.Cut()
	overlays += image('icons/obj/objects.dmi', src, "wooden_rack_overlay", ABOVE_OBJ_LAYER)

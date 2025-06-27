////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food/pill
	name = "pill"
	desc = "Небольшая таблетка, предназначенная для введения веществ в организм субъекта пероральным путём."
	ru_names = list(
        NOMINATIVE = "таблетка",
        GENITIVE = "таблетки",
        DATIVE = "таблетке",
        ACCUSATIVE = "таблетку",
        INSTRUMENTAL = "таблеткой",
        PREPOSITIONAL = "таблетке"
	)
	gender = FEMALE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill"
	item_state = "pill"
	possible_transfer_amounts = null
	volume = 100
	consume_sound = null
	can_taste = FALSE
	antable = FALSE
	pickup_sound = 'sound/items/handling/generic_small_pickup.ogg'
	drop_sound = 'sound/items/handling/generic_small_drop.ogg'

/obj/item/reagent_containers/food/pill/Initialize(mapload)
	if(icon_state == "pill")
		icon_state = "pill[rand(1,20)]"
	. = ..()

/obj/item/reagent_containers/food/pill/attack_self(mob/user)
	return


/obj/item/reagent_containers/food/pill/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(!iscarbon(target))
		return .
	if(!get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		if(target == user)
			balloon_alert(user, "ваш рот закрыт!")
		else
			balloon_alert(user, "рот цели закрыт!")
		return .
	if(!user.can_unEquip(src))
		return .
	bitesize = reagents.total_volume
	if(!target.eat(src, user) || !user.can_unEquip(src))
		return .
	user.drop_transfer_item_to_loc(src, target)
	qdel(src)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/item/reagent_containers/food/pill/afterattack(obj/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(target.is_open_container() != 0 && target.reagents)
		if(!target.reagents.total_volume)
			balloon_alert(user, "не в чем растворять!")
			return
		balloon_alert(user, "таблетка растворена")
		reagents.trans_to(target, reagents.total_volume)
		for(var/mob/O in viewers(2, user))
			O.show_message(span_warning("[user] броса[pluralize_ru(user.gender, "ет", "ют")] что-то в [target.declent_ru(ACCUSATIVE)]."), 1)
		spawn(5)
			qdel(src)

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

//Pills
/obj/item/reagent_containers/food/pill/tox
	name = "Toxins pill"
	desc = "Очень токсично."
	ru_names = list(
        NOMINATIVE = "таблетка (Токсины)",
        GENITIVE = "таблетки (Токсины)",
        DATIVE = "таблетке (Токсины)",
        ACCUSATIVE = "таблетку (Токсины)",
        INSTRUMENTAL = "таблеткой (Токсины)",
        PREPOSITIONAL = "таблетке (Токсины)"
	)
	icon_state = "pill21"
	list_reagents = list("toxin" = 50)

/obj/item/reagent_containers/food/pill/initropidril
	name = "initropidril pill"
	desc = "Не глотайте это."
	ru_names = list(
        NOMINATIVE = "таблетка (Инитропидрил)",
        GENITIVE = "таблетки (Инитропидрил)",
        DATIVE = "таблетке (Инитропидрил)",
        ACCUSATIVE = "таблетку (Инитропидрил)",
        INSTRUMENTAL = "таблеткой (Инитропидрил)",
        PREPOSITIONAL = "таблетке (Инитропидрил)"
	)
	icon_state = "pill21"
	list_reagents = list("initropidril" = 50)

/obj/item/reagent_containers/food/pill/fakedeath
	name = "fake death pill"
	desc = "Проглотите, чтобы скрыть свой пульс и прикинуться мёртвым. Побочный эффект - вы не сможете говорить во время действия вещества."
	ru_names = list(
        NOMINATIVE = "таблетка (Капулеттий+)",
        GENITIVE = "таблетки (Капулеттий+)",
        DATIVE = "таблетке (Капулеттий+)",
        ACCUSATIVE = "таблетку (Капулеттий+)",
        INSTRUMENTAL = "таблеткой (Капулеттий+)",
        PREPOSITIONAL = "таблетке (Капулеттий+)"
	)
	icon_state = "pill4"
	list_reagents = list("capulettium_plus" = 50)

/obj/item/reagent_containers/food/pill/adminordrazine
	name = "Adminordrazine pill"
	desc = "Магия. Тут нечего объяснять."
	ru_names = list(
        NOMINATIVE = "таблетка (Админордразин)",
        GENITIVE = "таблетки (Админордразин)",
        DATIVE = "таблетке (Админордразин)",
        ACCUSATIVE = "таблетку (Админордразин)",
        INSTRUMENTAL = "таблеткой (Админордразин)",
        PREPOSITIONAL = "таблетке (Админордразин)"
	)
	icon_state = "pill16"
	list_reagents = list("adminordrazine" = 50)

/obj/item/reagent_containers/food/pill/morphine
	name = "Morphine pill"
	desc = "Опиат, оказывающий обезболивающее и седативное действие на организм."
	ru_names = list(
        NOMINATIVE = "таблетка (Морфин)",
        GENITIVE = "таблетки (Морфин)",
        DATIVE = "таблетке (Морфин)",
        ACCUSATIVE = "таблетку (Морфин)",
        INSTRUMENTAL = "таблеткой (Морфин)",
        PREPOSITIONAL = "таблетке (Морфин)"
	)
	icon_state = "pill8"
	list_reagents = list("morphine" = 30)

/obj/item/reagent_containers/food/pill/methamphetamine
	name = "Methamphetamine pill"
	desc = "Бодрит, пробуждает, увеличивает концентрацию и улучшает мышечный тонус. Вызывает сильное привыкание, негативно сказывается на функциях мозга при длительном применении."
	ru_names = list(
        NOMINATIVE = "таблетка (Метамфетамин)",
        GENITIVE = "таблетки (Метамфетамин)",
        DATIVE = "таблетке (Метамфетамин)",
        ACCUSATIVE = "таблетку (Метамфетамин)",
        INSTRUMENTAL = "таблеткой (Метамфетамин)",
        PREPOSITIONAL = "таблетке (Метамфетамин)"
	)
	icon_state = "pill8"
	list_reagents = list("methamphetamine" = 5)

/obj/item/reagent_containers/food/pill/lsd
	name = "LSD pill"
	desc = "Быстрый способ кайфануть."
	ru_names = list(
        NOMINATIVE = "таблетка (ЛСД)",
        GENITIVE = "таблетки (ЛСД)",
        DATIVE = "таблетке (ЛСД)",
        ACCUSATIVE = "таблетку (ЛСД)",
        INSTRUMENTAL = "таблеткой (ЛСД)",
        PREPOSITIONAL = "таблетке (ЛСД)"
	)
	icon_state = "pill4"
	list_reagents = list("lsd" = 5)

/obj/item/reagent_containers/food/pill/rum
	name = "rum pill"
	desc = "Суровая пиратская медицина, надо полагать..?"
	ru_names = list(
        NOMINATIVE = "таблетка (Ром)",
        GENITIVE = "таблетки (Ром)",
        DATIVE = "таблетке (Ром)",
        ACCUSATIVE = "таблетку (Ром)",
        INSTRUMENTAL = "таблеткой (Ром)",
        PREPOSITIONAL = "таблетке (Ром)"
	)
	icon_state = "pill8"
	list_reagents = list("rum" = 25)

/obj/item/reagent_containers/food/pill/stimulative_agent
	name = "combat stimulant pill"
	desc = "Обычно используется бойцами элитных сил дял кратковременного улучшения возможностей организма во время боя."
	ru_names = list(
        NOMINATIVE = "таблетка (Боевой Стимулятор)",
        GENITIVE = "таблетки (Боевой Стимулятор)",
        DATIVE = "таблетке (Боевой Стимулятор)",
        ACCUSATIVE = "таблетку (Боевой Стимулятор)",
        INSTRUMENTAL = "таблеткой (Боевой Стимулятор)",
        PREPOSITIONAL = "таблетке (Боевой Стимулятор)"
	)
	icon_state = "pill15"
	list_reagents = list("stimulative_agent" = 5)

/obj/item/reagent_containers/food/pill/haloperidol
	name = "Haloperidol pill"
	desc = "Антипсихотическое средство, используемое для лечения психиатрических проблем."
	ru_names = list(
        NOMINATIVE = "таблетка (Галоперидол)",
        GENITIVE = "таблетки (Галоперидол)",
        DATIVE = "таблетке (Галоперидол)",
        ACCUSATIVE = "таблетку (Галоперидол)",
        INSTRUMENTAL = "таблеткой (Галоперидол)",
        PREPOSITIONAL = "таблетке (Галоперидол)"
	)
	icon_state = "pill8"
	list_reagents = list("haloperidol" = 15)

/obj/item/reagent_containers/food/pill/happy
	name = "Happy pill"
	desc = "Счастливая радость!"
	ru_names = list(
        NOMINATIVE = "таблетка счастья",
        GENITIVE = "таблетки счастья",
        DATIVE = "таблетке счастья",
        ACCUSATIVE = "таблетку счастья",
        INSTRUMENTAL = "таблеткой счастья",
        PREPOSITIONAL = "таблетке счастья"
	)
	icon_state = "pill18"
	list_reagents = list("space_drugs" = 15, "sugar" = 15)

/obj/item/reagent_containers/food/pill/zoom
	name = "Zoom pill"
	desc = "Быстрее, быстрее, ещё быстрее!"
	ru_names = list(
        NOMINATIVE = "таблетка бодрости",
        GENITIVE = "таблетки бодрости",
        DATIVE = "таблетке бодрости",
        ACCUSATIVE = "таблетку бодрости",
        INSTRUMENTAL = "таблеткой бодрости",
        PREPOSITIONAL = "таблетке бодрости"
	)
	icon_state = "pill18"
	list_reagents = list("synaptizine" = 5, "methamphetamine" = 5)

/obj/item/reagent_containers/food/pill/charcoal
	name = "Charcoal pill"
	desc = "Стандартное лекарство от отравлений."
	ru_names = list(
        NOMINATIVE = "таблетка (Активированный уголь)",
        GENITIVE = "таблетки (Активированный уголь)",
        DATIVE = "таблетке (Активированный уголь)",
        ACCUSATIVE = "таблетку (Активированный уголь)",
        INSTRUMENTAL = "таблеткой (Активированный уголь)",
        PREPOSITIONAL = "таблетке (Активированный уголь)"
	)
	icon_state = "pill17"
	list_reagents = list("charcoal" = 50)

/obj/item/reagent_containers/food/pill/epinephrine
	name = "Epinephrine pill"
	desc = "Для стабилизации пациентов в критическом состоянии."
	ru_names = list(
        NOMINATIVE = "таблетка (Эпинефрин)",
        GENITIVE = "таблетки (Эпинефрин)",
        DATIVE = "таблетке (Эпинефрин)",
        ACCUSATIVE = "таблетку (Эпинефрин)",
        INSTRUMENTAL = "таблеткой (Эпинефрин)",
        PREPOSITIONAL = "таблетке (Эпинефрин)"
	)
	icon_state = "pill6"
	list_reagents = list("epinephrine" = 50)

/obj/item/reagent_containers/food/pill/salicylic
	name = "Salicylic Acid pill"
	desc = "Стандартное обезболивающее и жаропонижающее средство."
	ru_names = list(
        NOMINATIVE = "таблетка (Салициловая кислота)",
        GENITIVE = "таблетки (Салициловая кислота)",
        DATIVE = "таблетке (Салициловая кислота)",
        ACCUSATIVE = "таблетку (Салициловая кислота)",
        INSTRUMENTAL = "таблеткой (Салициловая кислота)",
        PREPOSITIONAL = "таблетке (Салициловая кислота)"
	)
	icon_state = "pill4"
	list_reagents = list("sal_acid" = 20)

/obj/item/reagent_containers/food/pill/salbutamol
	name = "Salbutamol pill"
	desc = "Используется для лечения проблем с дыханием."
	ru_names = list(
        NOMINATIVE = "таблетка (Сальбутамол)",
        GENITIVE = "таблетки (Сальбутамол)",
        DATIVE = "таблетке (Сальбутамол)",
        ACCUSATIVE = "таблетку (Сальбутамол)",
        INSTRUMENTAL = "таблеткой (Сальбутамол)",
        PREPOSITIONAL = "таблетке (Сальбутамол)"
	)
	icon_state = "pill8"
	list_reagents = list("salbutamol" = 20)

/obj/item/reagent_containers/food/pill/hydrocodone
	name = "Hydrocodone pill"
	desc = "Сильное обезболивающее для самых крайних случаев."
	ru_names = list(
        NOMINATIVE = "таблетка (Гидрокодон)",
        GENITIVE = "таблетки (Гидрокодон)",
        DATIVE = "таблетке (Гидрокодон)",
        ACCUSATIVE = "таблетку (Гидрокодон)",
        INSTRUMENTAL = "таблеткой (Гидрокодон)",
        PREPOSITIONAL = "таблетке (Гидрокодон)"
	)
	icon_state = "pill6"
	list_reagents = list("hydrocodone" = 15)

/obj/item/reagent_containers/food/pill/calomel
	name = "calomel pill"
	desc = "Может использоваться для выведения токсинов из организма, но сам по себе очень токсичен."
	ru_names = list(
        NOMINATIVE = "таблетка (Каломель)",
        GENITIVE = "таблетки (Каломель)",
        DATIVE = "таблетке (Каломель)",
        ACCUSATIVE = "таблетку (Каломель)",
        INSTRUMENTAL = "таблеткой (Каломель)",
        PREPOSITIONAL = "таблетке (Каломель)"
	)
	icon_state = "pill3"
	list_reagents = list("calomel" = 15)

/obj/item/reagent_containers/food/pill/mutadone
	name = "mutadone pill"
	desc = "Для лечения генетических отклонений."
	ru_names = list(
        NOMINATIVE = "таблетка (Мутадон)",
        GENITIVE = "таблетки (Мутадон)",
        DATIVE = "таблетке (Мутадон)",
        ACCUSATIVE = "таблетку (Мутадон)",
        INSTRUMENTAL = "таблеткой (Мутадон)",
        PREPOSITIONAL = "таблетке (Мутадон)"
	)
	icon_state = "pill18"
	list_reagents = list("mutadone" = 20)

/obj/item/reagent_containers/food/pill/mannitol
	name = "mannitol pill"
	desc = "Для восстановления повреждённых тканей мозга."
	ru_names = list(
        NOMINATIVE = "таблетка (Маннитол)",
        GENITIVE = "таблетки (Маннитол)",
        DATIVE = "таблетке (Маннитол)",
        ACCUSATIVE = "таблетку (Маннитол)",
        INSTRUMENTAL = "таблеткой (Маннитол)",
        PREPOSITIONAL = "таблетке (Маннитол)"
	)
	icon_state = "pill19"
	list_reagents = list("mannitol" = 20)

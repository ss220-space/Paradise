/obj/item/organ/external/chest/diona
	species_type = /datum/species/diona
	name = "core trunk"
	desc = "Основной ствол - ядро."
	ru_names = list(
		NOMINATIVE = "основной ствол",
		GENITIVE = "основного ствола",
		DATIVE = "основному стволу",
		ACCUSATIVE = "основной ствол",
		INSTRUMENTAL = "основным стволом",
		PREPOSITIONAL = "основном стволе"
	)
	gender = MALE
	max_damage = 200
	min_broken_damage = 50
	amputation_point = "ствол"
	encased = null
	gendered_icon = FALSE

/obj/item/organ/external/groin/diona
	species_type = /datum/species/diona
	name = "fork"
	desc = "Нижнее разветвление ствола."
	ru_names = list(
		NOMINATIVE = "нижнее разветвление",
		GENITIVE = "нижнего разветвления",
		DATIVE = "нижнему разветвлению",
		ACCUSATIVE = "нижнее разветвление",
		INSTRUMENTAL = "нижним разветвлением",
		PREPOSITIONAL = "нижнем разветвлении"
	)
	gender = NEUTER
	min_broken_damage = 50
	amputation_point = "нижний ствол"
	gendered_icon = FALSE

/obj/item/organ/external/arm/diona
	species_type = /datum/species/diona
	name = "left upper tendril"
	desc = "Верхнее левое ответвление ствола."
	ru_names = list(
		NOMINATIVE = "левый верхний отросток",
		GENITIVE = "левого верхнего отростка",
		DATIVE = "левому верхнему отростку",
		ACCUSATIVE = "левый верхний отросток",
		INSTRUMENTAL = "левым верхним отростоком",
		PREPOSITIONAL = "левом верхнем отростке"
	)
	gender = MALE
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "левый верхний отросток"
	convertable_children = list(/obj/item/organ/external/hand/diona)

/obj/item/organ/external/arm/right/diona
	species_type = /datum/species/diona
	name = "right upper tendril"
	desc = "Верхнее правое ответвление ствола."
	ru_names = list(
		NOMINATIVE = "правый верхний отросток",
		GENITIVE = "правого верхнего отростка",
		DATIVE = "правому верхнему отростку",
		ACCUSATIVE = "правый верхний отросток",
		INSTRUMENTAL = "правым верхним отростоком",
		PREPOSITIONAL = "правом верхнем отростке"
	)
	gender = MALE
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "правый верхний отросток"
	convertable_children = list(/obj/item/organ/external/hand/right/diona)

/obj/item/organ/external/leg/diona
	species_type = /datum/species/diona
	name = "left lower tendril"
	desc = "Нижнее левое ответвление ствола."
	ru_names = list(
		NOMINATIVE = "левый нижний отросток",
		GENITIVE = "левого нижнего отростка",
		DATIVE = "левому нижнему отростку",
		ACCUSATIVE = "левый нижний отросток",
		INSTRUMENTAL = "левым нижним отростоком",
		PREPOSITIONAL = "левом нижнем отростке"
	)
	gender = MALE
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "левый нижний отросток"
	convertable_children = list(/obj/item/organ/external/foot/diona)

/obj/item/organ/external/leg/right/diona
	species_type = /datum/species/diona
	name = "right lower tendril"
	desc = "Нижнее правое ответвление ствола."
	ru_names = list(
		NOMINATIVE = "правый нижний отросток",
		GENITIVE = "правого нижнего отростка",
		DATIVE = "правому нижнему отростку",
		ACCUSATIVE = "правый нижний отросток",
		INSTRUMENTAL = "правым нижним отростоком",
		PREPOSITIONAL = "правом нижнем отростке"
	)
	gender = MALE
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "правый нижний отросток"
	convertable_children = list(/obj/item/organ/external/foot/right/diona)

/obj/item/organ/external/foot/diona
	species_type = /datum/species/diona
	max_damage = 20
	min_broken_damage = 10
	amputation_point = "левую нижнюю ветку"

/obj/item/organ/external/foot/right/diona
	species_type = /datum/species/diona
	max_damage = 20
	min_broken_damage = 10
	amputation_point = "правую нижнюю ветку"

/obj/item/organ/external/hand/diona
	species_type = /datum/species/diona
	name = "left grasper"
	desc = "Левый верхняя ветка, выполняющая хватательную функцию."
	ru_names = list(
		NOMINATIVE = "левый захват",
		GENITIVE = "левого захвата",
		DATIVE = "левому захвату",
		ACCUSATIVE = "левый захват",
		INSTRUMENTAL = "левым захватом",
		PREPOSITIONAL = "левом захвате"
	)
	gender = MALE
	amputation_point = "левую верхнюю ветку"

/obj/item/organ/external/hand/right/diona
	species_type = /datum/species/diona
	name = "right grasper"
	desc = "Правая верхняя ветка, выполняющая хватательную функцию."
	ru_names = list(
		NOMINATIVE = "правый захват",
		GENITIVE = "правого захвата",
		DATIVE = "правому захвату",
		ACCUSATIVE = "правый захват",
		INSTRUMENTAL = "правым захватом",
		PREPOSITIONAL = "правом захвате"
	)
	gender = MALE
	amputation_point = "правую верхнюю ветку"

/obj/item/organ/external/head/diona
	species_type = /datum/species/diona
	name = "upper trunk"
	desc = "Верхнее ответвление ствола."
	ru_names = list(
		NOMINATIVE = "верхнее ответвление",
		GENITIVE = "верхнего ответвления",
		DATIVE = "верхнему ответвлению",
		ACCUSATIVE = "верхнее ответвление",
		INSTRUMENTAL = "верхним ответвлением",
		PREPOSITIONAL = "верхнем ответвлении"
	)
	gender = NEUTER
	max_damage = 50
	min_broken_damage = 25
	encased = null
	amputation_point = "верхний ствол"
	gendered_icon = FALSE

/obj/item/organ/diona/process()
	return

/obj/item/organ/internal/brain/diona
	species_type = /datum/species/diona
	name = "neural strata"
	desc = "Прослойка из нейронной ткани, центральный орган нервной системы гештальта. Эта принадлежала дионе."
	ru_names = list(
		NOMINATIVE = "нейронная прослойка дионы",
		GENITIVE = "нейронной прослойки дионы",
		DATIVE = "нейронной прослойке дионы",
		ACCUSATIVE = "нейронную прослойку дионы",
		INSTRUMENTAL = "нейронной прослойкой дионы",
		PREPOSITIONAL = "нейронной прослойке дионы"
	)
	gender = FEMALE
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	dead_icon = null
	parent_organ_zone = BODY_ZONE_CHEST
	actions_types = list(/datum/action/item_action/organ_action/diona_brain_evacuation)

/obj/item/organ/internal/brain/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

/datum/action/item_action/organ_action/diona_brain_evacuation
	name = "Эвакуации"
	check_flags = 0
	desc = "Покинуть тело в форме нимфы."

/datum/action/item_action/organ_action/diona_brain_evacuation/IsAvailable()
	. = ..()
	if((!owner.mind) || owner.mind.suicided)
		return FALSE


/datum/action/item_action/organ_action/diona_brain_evacuation/Trigger(left_click = TRUE)
	. = ..()
	if(tgui_alert(src, "Вы уверены, что хотите покинуть своё тело как нимфа? (Если использовать, пока вы живы, вас лишит роли антагониста!)", "Подтверждение эвакуации", list("Да", "Нет")) == "Нет")
		return

	if(. && istype(target, /obj/item/organ/internal/brain/diona))
		var/is_dead = owner.is_dead()
		if(is_dead || do_after(owner, 1 MINUTES, owner))
			var/obj/item/organ/internal/brain/diona/brain = target
			var/loc = owner.loc
			var/datum/mind/mind = owner.mind
			if(!is_dead)
				mind.remove_all_antag_roles(FALSE)
				log_and_message_admins("diona-evacuated into nymph and lost all possible antag roles.")
			brain.remove(owner)

			for(var/mob/living/simple_animal/diona/nymph in get_turf(loc))
				var/throw_dir = pick(GLOB.alldirs)
				var/throwtarget = get_edge_target_turf(nymph, throw_dir)
				nymph.throw_at(throwtarget, 3, 1, owner)

/obj/item/organ/internal/kidneys/diona
	species_type = /datum/species/diona
	name = "filtrating vacuoles"
	desc = "Парный орган, отвечающий за выведение токсинов и вредных веществ из биомассы гештальта. Эти принадлежали дионе."
	ru_names = list(
		NOMINATIVE = "фильтрационные вакуоли",
		GENITIVE = "фильтрационных вакуолей",
		DATIVE = "фильтрационным вакуолям",
		ACCUSATIVE = "фильтрационные вакуоли",
		INSTRUMENTAL = "фильтрационными вакуолями",
		PREPOSITIONAL = "фильтрационных вакуолях"
	)
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/kidneys/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

/obj/item/organ/internal/lungs/diona
	species_type = /datum/species/diona
	name = "gas bladder"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и биомассой гештальта. Эти принадлежали дионе."
	ru_names = list(
		NOMINATIVE = "газовые пузыри",
		GENITIVE = "газовых пузырей",
		DATIVE = "газовым пузырям",
		ACCUSATIVE = "газовые пузыри",
		INSTRUMENTAL = "газовыми пузырями",
		PREPOSITIONAL = "газовых пузырях"
	)
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/lungs/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

/obj/item/organ/internal/appendix/diona
	species_type = /datum/species/diona
	name = "polyp segment"
	desc = "Наслоение биомассы. Является рудиментарным органом и не несёт полезной функции для гештальта. Этот принадлежал дионе."
	ru_names = list(
		NOMINATIVE = "сегментированный отросток",
		GENITIVE = "сегментированного отростка",
		DATIVE = "сегментированному отростку",
		ACCUSATIVE = "сегментированный отросток",
		INSTRUMENTAL = "сегментированным отростком",
		PREPOSITIONAL = "сегментированном отростке"
	)
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/appendix/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

/obj/item/organ/internal/heart/diona
	species_type = /datum/species/diona
	name = "anchoring ligament"
	desc = "Орган, связывающий части гештальта воедино. Этот принадлежал дионе."
	ru_names = list(
		NOMINATIVE = "якорная связка",
		GENITIVE = "якорной связки",
		DATIVE = "якорной связке",
		ACCUSATIVE = "якорную связку",
		INSTRUMENTAL = "якорной связкой",
		PREPOSITIONAL = "якорной связке"
	)
	gender = FEMALE
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN

/obj/item/organ/internal/heart/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

/obj/item/organ/internal/heart/diona/update_icon_state()
	return

/obj/item/organ/internal/eyes/diona
	species_type = /datum/species/diona
	name = "receptor node"
	desc = "Светочувстительные мембраны, выполняющие зрительную функцию. Этот принадлежал дионе."
	ru_names = list(
		NOMINATIVE = "рецепторный узел",
		GENITIVE = "рецепторного узла",
		DATIVE = "рецепторному узлу",
		ACCUSATIVE = "рецепторный узел",
		INSTRUMENTAL = "рецепторным узлом",
		PREPOSITIONAL = "рецепторном узле"
	)
	gender = MALE
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	parent_organ_zone = BODY_ZONE_CHEST

/obj/item/organ/internal/eyes/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

/obj/item/organ/internal/liver/diona
	species_type = /datum/species/diona
	name = "nutrient vessel"
	desc = "Железа, отвечающая за метаболизацию поступающих в гештальт веществ. Эта принадлежала дионе."
	ru_names = list(
		NOMINATIVE = "питательная железа",
		GENITIVE = "питательной железы",
		DATIVE = "питательной железе",
		ACCUSATIVE = "питательную железа",
		INSTRUMENTAL = "питательной железой",
		PREPOSITIONAL = "питательной железе"
	)
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	alcohol_intensity = 0.5

/obj/item/organ/internal/liver/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

/obj/item/organ/internal/ears/diona
	species_type = /datum/species/diona
	name = "oscillatory catcher"
	desc = "Сгусток биомассы, улавливающий колебания в окружающей среде и отвечающий за ориентацию гештальта в пространстве. Этот принадлежал дионе."
	ru_names = list(
		NOMINATIVE = "колебательный уловитель",
		GENITIVE = "колебательного уловителя",
		DATIVE = "колебательному уловителю",
		ACCUSATIVE = "колебательный уловитель",
		INSTRUMENTAL = "колебательным уловителем",
		PREPOSITIONAL = "колебательном уловителе"
	)
	gender = MALE
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN

/obj/item/organ/internal/ears/diona/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diona_internals)

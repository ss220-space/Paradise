/obj/item/organ/internal/liver/kidan
	species_type = /datum/species/kidan
	name = "kidan liver"
	desc = "Орган, выполняющий множество функций, таких как фильтрация кровотока от вредных веществ, синтез необходимых белков и ферментов и удаление токсинов из организма. Эта принадлежала кидану."
	ru_names = list(
		NOMINATIVE = "печень кидана",
		GENITIVE = "печени кидана",
		DATIVE = "печени кидана",
		ACCUSATIVE = "печень кидана",
		INSTRUMENTAL = "печенью кидана",
		PREPOSITIONAL = "печени кидана"
	)
	icon = 'icons/obj/species_organs/kidan.dmi'
	item_state = "kidan_liver"
	alcohol_intensity = 0.5


#define KIDAN_LANTERN_HUNGERCOST 0.5
#define KIDAN_LANTERN_MINHUNGER 150
#define KIDAN_LANTERN_LIGHT 5

/obj/item/organ/internal/lantern
	species_type = /datum/species/kidan
	name = "Bioluminescent Lantern"
	desc = "Специальная железа, состоящая из ткани, которая воспроизводит свет за счёт химической реакции с кислородом, белками и плазмой крови. Эта принадлежала кидану."
	ru_names = list(
		NOMINATIVE = "биолюминесцентная железа",
		GENITIVE = "биолюминесцентной железы",
		DATIVE = "биолюминесцентной железе",
		ACCUSATIVE = "биолюминесцентную железу",
		INSTRUMENTAL = "биолюминесцентной железй",
		PREPOSITIONAL = "биолюминесцентной железе"
	)
	gender = FEMALE
	icon = 'icons/obj/species_organs/kidan.dmi'
	icon_state = "kid_lantern"
	item_state = "kidan_lantern"
	origin_tech = "biotech=2"
	w_class = WEIGHT_CLASS_TINY
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN
	slot = INTERNAL_ORGAN_LANTERN
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/colour
	var/glowing = 0

/obj/item/organ/internal/lantern/ui_action_click(mob/user, datum/action/action, leftclick)
	if(toggle_biolum())
		if(glowing)
			owner.visible_message(span_notice("[owner] начина[pluralize_ru(owner.gender, "ет", "ют")] светиться."))
			balloon_alert(owner, "световая железа активирована")
		else
			owner.visible_message(span_notice("[owner] переста[pluralize_ru(owner.gender, "ёт", "ют")] светиться."))
			balloon_alert(owner, "световая железа деактивирована")

/obj/item/organ/internal/lantern/on_life()
	..()
	if(glowing)//i hate this but i couldnt figure out a better way
		if(owner.nutrition < KIDAN_LANTERN_MINHUNGER)
			toggle_biolum(1)
			balloon_alert(owner, "организм слишком истощён!")
			return

		if(owner.stat)
			toggle_biolum(1)
			owner.visible_message(span_notice("[owner] переста[pluralize_ru(owner.gender, "ёт", "ют")] светиться."))
			return

		owner.set_nutrition(max(owner.nutrition - KIDAN_LANTERN_HUNGERCOST, KIDAN_LANTERN_HUNGERCOST))

		var/new_light = calculate_glow(KIDAN_LANTERN_LIGHT)

		if(!colour)																		//this should never happen in theory
			colour = BlendRGB(owner.m_colours["body"], owner.m_colours["head"], 0.65)	//then again im pretty bad at theoretics

		if(new_light != glowing)
			var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ_zone))
			lbody.set_light_range_power_color(new_light, color = colour)
			glowing = new_light

	return

/obj/item/organ/internal/lantern/on_owner_death()
	if(glowing)
		toggle_biolum(1)

/obj/item/organ/internal/lantern/proc/toggle_biolum(statoverride)
	if(!statoverride && owner.incapacitated())
		balloon_alert(owner, "невозможно сейч!ас")
		return 0

	if(!statoverride && owner.nutrition < KIDAN_LANTERN_MINHUNGER)
		balloon_alert(owner, "организм слишком истощён!")
		return 0

	if(!colour)
		colour = BlendRGB(owner.m_colours["head"], owner.m_colours["body"], 0.65)

	if(!glowing)
		var/light = calculate_glow(KIDAN_LANTERN_LIGHT)
		var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ_zone))
		lbody.set_light_range_power_color(light, color = colour)
		lbody.set_light_on(TRUE)
		glowing = light
		return 1

	else
		var/obj/item/organ/external/groin/lbody = owner.get_organ(check_zone(parent_organ_zone))
		lbody.set_light_on(FALSE)
		glowing = 0
		return 1

/obj/item/organ/internal/lantern/proc/calculate_glow(light)
	if(!light)
		light = KIDAN_LANTERN_LIGHT //should never happen but just to prevent things from breaking

	var/occlusion = 0 //clothes occluding light

	if(!get_location_accessible(owner, BODY_ZONE_HEAD))
		occlusion++
	if(owner.w_uniform && copytext(owner.w_uniform.item_color,-2) != "_d") //jumpsuit not rolled down
		occlusion++
	if(owner.wear_suit)
		occlusion++

	return light - occlusion

/obj/item/organ/internal/lantern/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(!colour)								//if its removed before used save the color
			colour = BlendRGB(H.m_colours["body"], H.m_colours["head"], 0.65)

		if(glowing)
			toggle_biolum(1)

	. = ..()

/obj/item/organ/internal/eyes/kidan
	species_type = /datum/species/kidan
	name = "kidan eyeballs"
	desc = "Парный орган, отвечающий за зрение - восприятие света и его трансформацию в видимое изображение. Эти принадлежали кидану."
	ru_names = list(
		NOMINATIVE = "глаза",
		GENITIVE = "глаз",
		DATIVE = "глазам",
		ACCUSATIVE = "глаза",
		INSTRUMENTAL = "глазами",
		PREPOSITIONAL = "глазах"
	)
	icon = 'icons/obj/species_organs/kidan.dmi'
	item_state = "kidan_eyes"

/obj/item/organ/internal/ears/kidan
	species_type = /datum/species/kidan
	name = "kidan ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали кидану."
	ru_names = list(
		NOMINATIVE = "уши кидана",
		GENITIVE = "ушей кидана",
		DATIVE = "ушам кидана",
		ACCUSATIVE = "уши кидана",
		INSTRUMENTAL = "ушами кидана",
		PREPOSITIONAL = "ушах кидана"
	)

/obj/item/organ/internal/heart/kidan
	species_type = /datum/species/kidan
	name = "kidan heart"
	desc = "Орган, качающий кровь или её заменяющую субстанцию по организму гуманоида. Это принадлежало кидану."
	ru_names = list(
		NOMINATIVE = "сердце",
		GENITIVE = "сердца",
		DATIVE = "сердцу",
		ACCUSATIVE = "сердце",
		INSTRUMENTAL = "сердцем",
		PREPOSITIONAL = "сердце"
	)
	icon = 'icons/obj/species_organs/kidan.dmi'
	item_state = "kidan_heart-on"
	item_base = "kidan_heart"

/obj/item/organ/internal/brain/kidan
	species_type = /datum/species/kidan
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Этот принадлежал кидану."
	ru_names = list(
		NOMINATIVE = "мозг кидана",
		GENITIVE = "мозга кидана",
		DATIVE = "мозгу кидана",
		ACCUSATIVE = "мозг кидана",
		INSTRUMENTAL = "мозгом кидана",
		PREPOSITIONAL = "мозге кидана"
	)
	icon = 'icons/obj/species_organs/kidan.dmi'
	icon_state = "brain2"
	item_state = "kidan_brain"
	mmi_icon = 'icons/obj/species_organs/kidan.dmi'
	mmi_icon_state = "mmi_full"
	parent_organ_zone = BODY_ZONE_CHEST

/obj/item/organ/internal/brain/kidan/on_life()
	. = ..()
	var/obj/item/organ/external/organ = owner.get_organ(BODY_ZONE_HEAD)
	if(!istype(organ))
		owner.SetSlowed(40 SECONDS)
		owner.SetConfused(80 SECONDS)
		owner.SetSilence(40 SECONDS)
		owner.SetStuttering(80 SECONDS)
		owner.SetEyeBlind(10 SECONDS)
		owner.SetEyeBlurry(40 SECONDS)

/obj/item/organ/internal/lungs/kidan
	species_type = /datum/species/kidan
	name = "kidan lungs"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и кровотоком организма гуманоида. Эти принадлежали кидану."
	ru_names = list(
		NOMINATIVE = "лёгкие",
		GENITIVE = "лёгких",
		DATIVE = "лёгким",
		ACCUSATIVE = "лёгкие",
		INSTRUMENTAL = "лёгкими",
		PREPOSITIONAL = "лёгких"
	)
	icon = 'icons/obj/species_organs/kidan.dmi'
	item_state = "kidan_lungs"

/obj/item/organ/internal/kidneys/kidan
	species_type = /datum/species/kidan
	name = "kidan kidneys"
	desc = "Парный орган, отвечающий за фильтрацию кровотока и выведение токсинов и отходов из организма. Эти принадлежали кидану."
	ru_names = list(
		NOMINATIVE = "почки",
		GENITIVE = "почек",
		DATIVE = "почкам",
		ACCUSATIVE = "почки",
		INSTRUMENTAL = "почками",
		PREPOSITIONAL = "почках"
	)
	icon = 'icons/obj/species_organs/kidan.dmi'
	item_state = "kidan_kidneys"

/obj/item/organ/external/head/kidan
	species_type = /datum/species/kidan
	encased = "хитиновую оболочку на голове"

/obj/item/organ/external/head/kidan/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT, ignore_children = FALSE)
	if(iskidan(owner))
		owner.adjustBrainLoss(60)

	. = ..()

/obj/item/organ/external/head/kidan/replaced(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(iskidan(target))
		target.adjustBrainLoss(30)

/obj/item/organ/external/chest/kidan
	encased = "хитиновую оболочку на груди"
	convertable_children = list(/obj/item/organ/external/groin/kidan)

/obj/item/organ/external/groin/kidan
	encased = "хитиновую оболочку на животе"

#undef KIDAN_LANTERN_HUNGERCOST
#undef KIDAN_LANTERN_MINHUNGER
#undef KIDAN_LANTERN_LIGHT

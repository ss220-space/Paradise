/*********************Hivelord stabilizer****************/
/obj/item/hivelordstabilizer
	name = "hivelord stabilizer"
	desc = "Введите стабилизатор в ядро легиона, чтобы предотвратить его гниение, сохраняя исцеляющие свойства."
	gender = MALE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "biotech=3"

/obj/item/hivelordstabilizer/get_ru_names()
	return list(
		NOMINATIVE = "стабилизатор ядра",
		GENITIVE = "стабилизатора ядра",
		DATIVE = "стабилизатору ядра",
		ACCUSATIVE = "стабилизатор ядра",
		INSTRUMENTAL = "стабилизатором ядра",
		PREPOSITIONAL = "стабилизаторе ядра",
	)

/obj/item/hivelordstabilizer/molten_mass
	name = "gooey molten mass"
	desc = "Странноватые сгустки, снятые с головы магмового рыбы-молота. Являются природным аналогом стабилизатора регенеративных ядер."
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "gooey_molten_mass"
	lefthand_file = 'icons/mob/inhands/lavaland/fish_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/fish_items_righthand.dmi'
	item_state = "acid_bladder"
	origin_tech = "biotech=5"
	light_range = 2
	light_power = 3
	light_color = "#FFBF00"
	light_system = MOVABLE_LIGHT

/obj/item/hivelordstabilizer/molten_mass/get_ru_names()
	return list(
		NOMINATIVE = "сплавленный сгусток",
		GENITIVE = "сплавленного сгустка",
		DATIVE = "сплавленному сгустку",
		ACCUSATIVE = "сплавленный сгусток",
		INSTRUMENTAL = "сплавленным сгустком",
		PREPOSITIONAL = "сплавленном сгустке",
	)

/obj/item/hivelordstabilizer/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	. = ..()
	if(!proximity_flag)
		return
	var/obj/item/organ/internal/regenerative_core/C = target
	if(!istype(C))
		to_chat(user, span_warning("Стабилизатор работает только с определёнными типами органов монстров, обычно регенеративной природы."))
		return ..()

	C.preserved()
	balloon_alert(user, "ядро стабилизировано!") //replace to "organ" when there is more than one kind of regenerative organ
	qdel(src)

/************************Hivelord core*******************/
/obj/item/organ/internal/regenerative_core
	name = "regenerative core"
	desc = "Всё, что осталось от легиона. Может поддерживать ваше тело, но быстро сгниёт."
	icon_state = "roro core 2"
	item_flags = NOBLUDGEON
	slot = INTERNAL_ORGAN_HIVECORE
	force = 0
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/inert = 0
	var/preserved = 0

/obj/item/organ/internal/regenerative_core/get_ru_names()
	return list(
		NOMINATIVE = "регенеративное ядро",
		GENITIVE = "регенеративного ядра",
		DATIVE = "регенеративному ядру",
		ACCUSATIVE = "регенеративное ядро",
		INSTRUMENTAL = "регенеративным ядром",
		PREPOSITIONAL = "регенеративном ядре",
	)

/obj/item/organ/internal/regenerative_core/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(inert_check)), 4 MINUTES)

/obj/item/organ/internal/regenerative_core/proc/inert_check()
	if(!preserved)
		go_inert()

/obj/item/organ/internal/regenerative_core/proc/after_use()
	qdel(src)

/obj/item/organ/internal/regenerative_core/proc/preserved(implanted = 0)
	preserved = TRUE
	update_icon()
	desc = "Все, что осталось от легиона. Оно стабилизированно, и можно не бояться, что оно сгниёт."
	if(implanted)
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "implanted"))
	else
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "stabilizer"))

/obj/item/organ/internal/regenerative_core/proc/go_inert()
	inert = TRUE
	name = "decayed regenerative core"
	desc = "Всё, что осталось от легиона. Оно сгнило и совершенно бесполезно."
	ru_names = list(
		NOMINATIVE = "сгнившее регенеративное ядро",
		GENITIVE = "сгнившего регенеративного ядра",
		DATIVE = "сгнившему регенеративному ядру",
		ACCUSATIVE = "сгнившее регенеративное ядро",
		INSTRUMENTAL = "сгнившим регенеративным ядром",
		PREPOSITIONAL = "сгнившем регенеративном ядре",
	)
	SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "inert"))
	update_icon()

/obj/item/organ/internal/regenerative_core/ui_action_click(mob/user, datum/action/action, leftclick)
	if(inert)
		to_chat(owner, span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] рассыпается при попытке активации."))
	else
		owner.revive()
	after_use()

/obj/item/organ/internal/regenerative_core/on_life()
	..()
	if(owner.health < HEALTH_THRESHOLD_CRIT)
		ui_action_click()

///Handles applying the core, logging and status/mood events.
/obj/item/organ/internal/regenerative_core/proc/applyto(atom/target, mob/user)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(inert)
			balloon_alert(user, "ядро сгнило!")
			return
		else
			if(H.stat == DEAD)
				balloon_alert(user, "не сработает на трупах!")
				return
			if(H != user)
				H.visible_message("[user] заставля[PLUR_ET_YUT(user)] [H.declent_ru(ACCUSATIVE)] применить [declent_ru(ACCUSATIVE)]... Чёрные щупальца опутывают и укрепляют [GEND_HIS_HER(H)]!")
				SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "other"))
			else
				to_chat(user, span_notice("Вы начинаете наносить [declent_ru(ACCUSATIVE)] на себя. Мерзкие щупальца скрепляют ваше тело, но как долго это продлится?"))
				SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "self"))
			H.apply_status_effect(STATUS_EFFECT_REGENERATIVE_CORE)
			user.temporarily_remove_item_from_inventory(src)
			after_use()

/obj/item/organ/internal/regenerative_core/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	. = ..()
	if(proximity_flag)
		applyto(target, user)

/obj/item/organ/internal/regenerative_core/attack_self(mob/user)
	applyto(user, user)

/obj/item/organ/internal/regenerative_core/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(!preserved && !inert)
		preserved(TRUE)
		owner.visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] стабилизируется при введении."))

/obj/item/organ/internal/regenerative_core/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	if(!inert && !special)
		owner.visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] быстро разлагается при извлечении."))
		go_inert()
	return ..()

/obj/item/organ/internal/regenerative_core/prepare_eat()
	return null

#define INFINITY_CORE_COOLDOWN 15 MINUTES

/obj/item/organ/internal/regenerative_core/cooldown
	COOLDOWN_DECLARE(core_use_cooldown)

/obj/item/organ/internal/regenerative_core/cooldown/after_use()
	COOLDOWN_START(src, core_use_cooldown, INFINITY_CORE_COOLDOWN)

/obj/item/organ/internal/regenerative_core/cooldown/ui_action_click(mob/user, datum/action/action, leftclick)
	if(!COOLDOWN_FINISHED(src, core_use_cooldown))
		if(!user)
			return
		user.balloon_alert(user, "ядро не восстановилось")
		return
	return ..()

/obj/item/organ/internal/regenerative_core/cooldown/applyto(atom/target, mob/user)
	if(!COOLDOWN_FINISHED(src, core_use_cooldown))
		if(!user)
			return
		user.balloon_alert(user, "ядро не восстановилось")
		return
	return ..()

#undef INFINITY_CORE_COOLDOWN

/*************************Legion core********************/
/obj/item/organ/internal/regenerative_core/legion
	desc = "Странный камень, испускающий разряды энергии. Может полностью исцелить, но быстро разложится."
	icon_state = "legion_soul"

/obj/item/organ/internal/regenerative_core/legion/pre_preserved
	preserved = TRUE

/obj/item/organ/internal/regenerative_core/legion/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/organ/internal/regenerative_core/legion/update_icon_state()
	icon_state = inert ? "legion_soul_inert" : "legion_soul"

/obj/item/organ/internal/regenerative_core/legion/update_overlays()
	. = ..()
	if(!inert && !preserved)
		. += "legion_soul_crackle"
	addtimer(CALLBACK(src, PROC_REF(buttons_update)), 0.1 SECONDS)

/obj/item/organ/internal/regenerative_core/legion/proc/buttons_update()
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()

/obj/item/organ/internal/regenerative_core/legion/go_inert()
	..()
	desc = "[DECLENT_RU_CAP(src, NOMINATIVE)] утратило силу. Оно сгнило и совершенно бесполезно."

/obj/item/organ/internal/regenerative_core/legion/preserved(implanted = 0)
	..()
	desc = "[DECLENT_RU_CAP(src, NOMINATIVE)] стабилизированно. Теперь его можно безопасно использовать для полного исцеления."


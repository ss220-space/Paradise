/obj/item/organ/internal/cyberimp
	name = "cybernetic implant"
	desc = "a state-of-the-art implant that improves a baseline's functionality."
	status = ORGAN_ROBOT
	tough = TRUE // Immune to damage
	pickup_sound = 'sound/items/handling/pickup/component_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/component_drop.ogg'
	lefthand_file = 'icons/mob/inhands/implants_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/implants_righthand.dmi'
	abstract_type = /obj/item/organ/internal/cyberimp
	augment_icon ='icons/mob/human_races/robotic.dmi'
	var/implant_color = "#FFFFFF"
	var/implant_overlay

/obj/item/organ/internal/cyberimp/Initialize(mapload, mob/M = null)
	. = ..()
	if(implant_overlay)
		var/image/overlay = new /image(icon, implant_overlay)
		overlay.color = implant_color
		overlays |= overlay

/obj/item/organ/internal/cyberimp/can_insert(mob/living/user, mob/living/carbon/target, fail_message = "Данное устройство не предусмотрено для существ с подобной анатомией.")
	. = ..()

//[[[[BRAIN]]]]

/obj/item/organ/internal/cyberimp/brain
	name = "cybernetic brain implant"
	desc = "injectors of extra sub-routines for the brain."
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	parent_organ_zone = BODY_ZONE_HEAD

/obj/item/organ/internal/cyberimp/brain/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!owner)
		return
	var/stun_amount = (5 + (severity-1 ? 0 : 5)) STATUS_EFFECT_CONSTANT
	owner.Stun(stun_amount)
	to_chat(owner, span_warning("Your body seizes up!"))
	return stun_amount

/obj/item/organ/internal/cyberimp/brain/anti_drop
	name = "Anti-drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	icon_state = "brain_implant_antidrop"
	slot = INTERNAL_ORGAN_BRAIN_ANTIDROP
	origin_tech = "materials=4;programming=5;biotech=4"
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	implant_overlay = null
	var/active = FALSE
	var/l_hand_ignore = FALSE
	var/r_hand_ignore = FALSE
	var/obj/item/l_hand_obj = null
	var/obj/item/r_hand_obj = null

/obj/item/organ/internal/cyberimp/brain/anti_drop/hardened
	name = "Hardened Anti-drop implant"
	desc = "A military-grade version of the standard implant, for NT's more elite forces."
	origin_tech = "materials=6;programming=5;biotech=5"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/brain/anti_drop/hardened/get_ru_names()
	return alist(
		NOMINATIVE = "укрепленный имплант анти-дроп",
		GENITIVE = "укрепленного импланта анти-дропа",
		DATIVE = "укрепленному импланту анти-дропа",
		ACCUSATIVE = "укрепленный имплант анти-дропа",
		INSTRUMENTAL = "укрепленным имплантом анти-дропа",
		PREPOSITIONAL = "укрепленном импланте анти-дропа",
	)

/obj/item/organ/internal/cyberimp/brain/anti_drop/ui_action_click(mob/user, datum/action/action, leftclick)
	active = !active
	if(active)
		l_hand_obj = owner.l_hand
		r_hand_obj = owner.r_hand
		if(l_hand_obj)
			if(HAS_TRAIT_FROM(l_hand_obj, TRAIT_NODROP, ANTIDROP_TRAIT))
				l_hand_ignore = TRUE
			else
				ADD_TRAIT(l_hand_obj, TRAIT_NODROP, ANTIDROP_TRAIT)
				RegisterSignal(l_hand_obj, COMSIG_ITEM_DROPPED, PROC_REF(on_held_item_dropped))
				l_hand_ignore = FALSE

		if(r_hand_obj)
			if(HAS_TRAIT_FROM(r_hand_obj, TRAIT_NODROP, ANTIDROP_TRAIT))
				r_hand_ignore = TRUE
			else
				ADD_TRAIT(r_hand_obj, TRAIT_NODROP, ANTIDROP_TRAIT)
				RegisterSignal(r_hand_obj, COMSIG_ITEM_DROPPED, PROC_REF(on_held_item_dropped))
				r_hand_ignore = FALSE

		if(!l_hand_obj && !r_hand_obj)
			to_chat(owner, span_notice("You are not holding any items, your hands relax..."))
			active = 0
		else
			var/msg = 0
			msg += !l_hand_ignore && l_hand_obj ? 1 : 0
			msg += !r_hand_ignore && r_hand_obj ? 2 : 0
			switch(msg)
				if(1)
					to_chat(owner, span_notice("Your left hand's grip tightens."))
				if(2)
					to_chat(owner, span_notice("Your right hand's grip tightens."))
				if(3)
					to_chat(owner, span_notice("Both of your hand's grips tighten."))
	else
		release_items()
		to_chat(owner, span_notice("Your hands relax..."))
		l_hand_obj = null
		r_hand_obj = null

/obj/item/organ/internal/cyberimp/brain/anti_drop/proc/on_held_item_dropped(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER

	REMOVE_TRAIT(source, TRAIT_NODROP, ANTIDROP_TRAIT)
	UnregisterSignal(source, COMSIG_ITEM_DROPPED)

	if(l_hand_obj == source)
		l_hand_obj = null
		l_hand_ignore = FALSE
	else if(r_hand_obj == source)
		r_hand_obj = null
		r_hand_ignore = FALSE

	if(!l_hand_obj && !r_hand_obj)
		active = FALSE

/obj/item/organ/internal/cyberimp/brain/anti_drop/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || !owner)
		return
	var/range = severity ? 10 : 5
	var/atom/A
	var/obj/item/L_item = owner.l_hand
	var/obj/item/R_item = owner.r_hand

	release_items()
	var/list/surrounds = oview(range)
	if(L_item)
		A = pick(surrounds)
		L_item.throw_at(A, range, 2)
		to_chat(owner, span_notice("Your left arm spasms and throws the [L_item.name]!"))
		l_hand_obj = null
	if(R_item)
		A = pick(surrounds)
		R_item.throw_at(A, range, 2)
		to_chat(owner, span_notice("Your right arm spasms and throws the [R_item.name]!"))
		r_hand_obj = null

/obj/item/organ/internal/cyberimp/brain/anti_drop/proc/release_items()
	active = FALSE
	if(!l_hand_ignore && (l_hand_obj in owner.contents))
		REMOVE_TRAIT(l_hand_obj, TRAIT_NODROP, ANTIDROP_TRAIT)
	if(!r_hand_ignore && (r_hand_obj in owner.contents))
		REMOVE_TRAIT(r_hand_obj, TRAIT_NODROP, ANTIDROP_TRAIT)

/obj/item/organ/internal/cyberimp/brain/anti_drop/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	if(active)
		ui_action_click()
	return ..()

/obj/item/organ/internal/cyberimp/brain/anti_stun
	name = "CNS Rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned. Incompatible with the Neural Jumpstarter."
	icon_state = "brain_implant_rebooter"
	implant_overlay = null
	slot = INTERNAL_ORGAN_BRAIN_ANTISTUN
	origin_tech = "materials=5;programming=4;biotech=5"

/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened
	name = "Hardened CNS Rebooter implant"
	desc = "A military-grade version of the standard implant, for NT's more elite forces."
	origin_tech = "materials=6;programming=5;biotech=5"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened/Initialize(mapload)
	. = ..()
	desc += " The implant has been hardened. It is invulnerable to EMPs."

/obj/item/organ/internal/cyberimp/brain/anti_stun/on_life()
	..()
	if(crit_fail)
		return
	if(owner.getStaminaLoss() > 60)
		owner.adjustStaminaLoss(-9)

/obj/item/organ/internal/cyberimp/brain/anti_stun/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || crit_fail)
		return
	crit_fail = TRUE
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/internal/cyberimp/brain/anti_stun/proc/reboot()
	crit_fail = FALSE

/obj/item/organ/internal/cyberimp/brain/anti_sleep
	name = "Neural Jumpstarter implant"
	desc = "This implant will automatically attempt to jolt you awake when it detects you have fallen unconscious. Has a short cooldown, incompatible with the CNS Rebooter."
	implant_color = "#0356fc"
	slot = INTERNAL_ORGAN_BRAIN_ANTISTUN //one or the other not both.
	origin_tech = "materials=5;programming=4;biotech=5"
	var/cooldown = FALSE

/obj/item/organ/internal/cyberimp/brain/anti_sleep/on_life()
	..()
	if(crit_fail)
		return
	if(owner.stat == UNCONSCIOUS && cooldown == FALSE)
		owner.AdjustSleeping(-200 SECONDS)
		owner.AdjustParalysis(-200 SECONDS)
		to_chat(owner, span_notice("You feel a rush of energy course through your body!"))
		cooldown = TRUE
		addtimer(CALLBACK(src, PROC_REF(sleepy_timer_end)), 50)

/obj/item/organ/internal/cyberimp/brain/anti_sleep/proc/sleepy_timer_end()
		cooldown = FALSE
		to_chat(owner, span_notice("You hear a small beep in your head as your Neural Jumpstarter finishes recharging."))

/obj/item/organ/internal/cyberimp/brain/anti_sleep/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || crit_fail)
		return
	crit_fail = TRUE
	owner.AdjustSleeping(400 SECONDS)
	cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/internal/cyberimp/brain/anti_sleep/proc/reboot()
	crit_fail = FALSE
	cooldown = FALSE

/obj/item/organ/internal/cyberimp/brain/anti_sleep/hardened
	name = "Hardened Neural Jumpstarter implant"
	desc = "A military-grade version of the standard implant, for NT's more elite forces."
	origin_tech = "materials=6;programming=5;biotech=5"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/brain/anti_sleep/hardened/compatible
	desc = "A military-grade version of the standard implant, for NT's more elite forces. This one is compatible with the CNS Rebooter implant."
	slot = INTERNAL_ORGAN_BRAIN_ANTISLEEP

/obj/item/organ/internal/cyberimp/brain/clown_voice
	name = "Comical implant"
	desc = span_sans_alt("Uh oh.")
	implant_color = "#DEDE00"
	slot = INTERNAL_ORGAN_BRAIN_CLOWNVOICE
	origin_tech = "materials=2;biotech=2"

/obj/item/organ/internal/cyberimp/brain/wire_interface
	name = "Wire interface implant"
	desc = "Этот кибернетический имплант мозга позволит вам взаимодействовать с электрическими токами, чтобы определять назначение проводов."
	implant_color = "#fff782"
	slot = INTERNAL_ORGAN_WIRE_INTERFACE
	origin_tech = "materials=5;programming=4;biotech=4"
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 400, MAT_GOLD = 400)

/obj/item/organ/internal/cyberimp/brain/wire_interface/get_ru_names()
	return alist(
		NOMINATIVE = "имплант проводного интерфейса",
		GENITIVE = "импланта проводного интерфейса",
		DATIVE = "импланту проводного интерфейса",
		ACCUSATIVE = "имплант проводного интерфейса",
		INSTRUMENTAL = "имплантом проводного интерфейса",
		PREPOSITIONAL = "импланте проводного интерфейса",
	)

/obj/item/organ/internal/cyberimp/brain/wire_interface/insert(mob/living/carbon/target, special = FALSE)
	..()
	ADD_TRAIT(target, TRAIT_SHOW_WIRE_INFO, UNIQUE_TRAIT_SOURCE(src))

/obj/item/organ/internal/cyberimp/brain/wire_interface/remove(mob/living/carbon/target, special = FALSE)
	REMOVE_TRAIT(target, TRAIT_SHOW_WIRE_INFO, UNIQUE_TRAIT_SOURCE(src))
	return ..()

#define EMP_TRAIT_SOURCE(time) "emp'd_at_[time]"
/obj/item/organ/internal/cyberimp/brain/wire_interface/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!owner)
		return
	var/time_of_emp = world.time // This lets us be emp'd multiple times, applying the trait multiple times, extending the cooldown
	ADD_TRAIT(owner, TRAIT_WIRE_BLIND, EMP_TRAIT_SOURCE(time_of_emp))
	addtimer(TRAIT_CALLBACK_REMOVE(owner, TRAIT_WIRE_BLIND, EMP_TRAIT_SOURCE(time_of_emp)), (2 MINUTES / severity))
#undef EMP_TRAIT_SOURCE

/obj/item/organ/internal/cyberimp/brain/wire_interface/hardened
	name = "Hardened Wire interface implant"
	desc = "Этот имплант проводного интерфейса на самом деле беспроводной, чтобы избежать проблем с электромагнитными импульсами."
	origin_tech = "materials=6;programming=6;biotech=6"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/brain/wire_interface/hardened/get_ru_names()
	return alist(
		NOMINATIVE = "защищённый имплант проводного интерфейса",
		GENITIVE = "защищённого импланта проводного интерфейса",
		DATIVE = "защищённому импланту проводного интерфейса",
		ACCUSATIVE = "защищённый имплант проводного интерфейса",
		INSTRUMENTAL = "защищённым имплантом проводного интерфейса",
		PREPOSITIONAL = "защищённом импланте проводного интерфейса",
	)

// An implant that injects you with mephedrone on demand, acting like a bootleg sandevistan

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer
	name = "Qani-Laaca sensory computer"
	desc = "Экспериментальный имплант, заменяющий позвоночник органиков. При активации он даёт временный прирост скорости умственной обработки, \
		который многие пользователи воспринимают как замедление времени и ускорение способности действовать. Из-за своей природы он несовместим с \
		системами, сильно влияющими на нервную систему пользователя, такими как перезагрузчик центральной нервной системы. \
		В качестве бонусного эффекта вы невосприимчивы к всплеску урона сердцу в конце действия мефедрона, поскольку компьютер способен регулировать \
		ритм вашего сердца обратно до нормы после его использования."
	icon_state = "sandy"
	implant_overlay = null
	implant_color = null
	slot = INTERNAL_ORGAN_BRAIN_ANTISTUN
	emp_proof = TRUE
	actions_types = list(/datum/action/item_action/organ_action/toggle/sensory_enhancer)
	origin_tech = "combat=6;biotech=6;syndicate=4"
	materials = list(MAT_METAL = 10000, MAT_SILVER = 2000, MAT_PLASMA = 10000, MAT_DIAMOND = 4000, MAT_BLUESPACE = 4000)
	augment_state = "sandy"
	///The icon state used for the on mob sprite. Default is sandy. Drask and vox have their own unique sprites
	var/custom_mob_sprite = "sandy"
	COOLDOWN_DECLARE(sensory_enhancer_cooldown)

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/get_ru_names()
	return alist(
		NOMINATIVE = "сенсорный компьютер \"Кани-Лаака\"",
		GENITIVE = "сенсорного компьютера \"Кани-Лаака\"",
		DATIVE = "сенсорному компьютеру \"Кани-Лаака\"",
		ACCUSATIVE = "сенсорный компьютер \"Кани-Лаака\"",
		INSTRUMENTAL = "сенсорным компьютером \"Кани-Лаака\"",
		PREPOSITIONAL = "сенсорном компьютере \"Кани-Лаака\"",
	)

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/rnd
	emp_proof = FALSE

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/examine(mob/user)
	. = ..()
	. += span_userdanger("Предупреждение об эпилепсии: наркотик имеет яркие визуальные эффекты!")

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/examine_more(mob/user)
	. = ..()
	. += "<i>Разработанный компанией \"Биотек\", этот революционный имплант полной замены спинного мозга использует встроенный химический синтезатор, предназначенный для введения мефедрона: \
	мощного стимулятора и наркотика гипердвижения. Этот имплант резко усиливает рефлексы пользователя, и многие сообщают о почти замедляющем время эффекте во время его работы.</i>"
	. += "<i>Эксперименты \"Биотек\" с исследованиями стимуляторов давно были краеугольным камнем их конкурентного преимущества, особенно против их соперника: \
	\"Интердайн\", чьи усилия дали наркотик, способный усиливать рефлексы, хотя они так и не смогли смягчить побочные эффекты этого продукта. \
	Преждевременная утечка прототипа импланта заставила компанию ускорить его разработку, оставив побочные эффекты наркотика нерешёнными. \
	Они завершили спинной имплант, который уникально оснащён встроенными флаконами для доставки мефедрона. \
	Его материал — прочный пластитаниум, и хотя он прочен по материалу, он на удивление лёгок, учитывая его интеграцию в позвоночник.</i>"
	. += "<i>Имплант высоко ценится из-за его экстремальных боевых возможностей. Многие военные группы платят щедрые суммы просто за лицензирование предмета. \
	Несмотря на это, недавние поставки \"Биотек\" подверглись пиратским нападениям, и компания поспешила обвинить \"Интердайн\" в этих атаках. Указанные обвинения остаются неподтверждёнными.</i>"


/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/insert(mob/living/carbon/target, special = 0)
	. = ..()
	ADD_TRAIT(target, TRAIT_MEPHEDRONE_ADAPTED, UNIQUE_TRAIT_SOURCE(src))

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/remove(mob/living/carbon/target, special = 0)
	. = ..()
	REMOVE_TRAIT(target, TRAIT_MEPHEDRONE_ADAPTED, UNIQUE_TRAIT_SOURCE(src))

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/render()
	var/mutable_appearance/custom_appearance = ..()
	if(!custom_appearance)
		return FALSE

	if(isvox(owner))
		custom_mob_sprite = "vox_sandy"
	else if(isdrask(owner))
		custom_mob_sprite = "drask_sandy"
	else
		custom_mob_sprite = "sandy"

	custom_appearance.icon_state = custom_mob_sprite
	return custom_appearance

/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/emp_act(severity)
	. = ..()
	if(!.)
		return
	if(!COOLDOWN_FINISHED(src, sensory_enhancer_cooldown)) //Not on cooldown? Drug them up. Heavily. We don't want people self emping to bypass cooldown.
		return
	if(!prob(100 / severity) || !owner)
		return

	for(var/datum/action/item_action/organ_action/toggle/sensory_enhancer/action in owner.actions)
		action.Trigger(owner, TRIGGER_SECONDARY_ACTION, TRUE)

/datum/action/item_action/organ_action/toggle/sensory_enhancer
	name = "активация системы \"Кани-Лаака\""
	desc = "Активирует ваш компьютер \"Кани-Лаака\" и дарует вам его силы. ЛКМ: короткая, более безопасная активация. ALT/ПКМ: более длительная, более мощная, более опасная активация."
	button_icon = 'icons/obj/surgery.dmi'
	button_icon_state = "sandy"
	/// Keeps track of how much mephedrone we inject into people on activation
	var/injection_amount = 10

/datum/action/item_action/organ_action/toggle/sensory_enhancer/AltTrigger(mob/clicker, trigger_flags)
	Trigger(clicker, trigger_flags|TRIGGER_SECONDARY_ACTION)

/datum/action/item_action/organ_action/toggle/sensory_enhancer/Trigger(mob/clicker, trigger_flags, emp_triggered = FALSE)
	. = ..()
	if(istype(target, /obj/item/organ/internal/cyberimp/brain/sensory_enhancer))
		var/obj/item/organ/internal/cyberimp/brain/sensory_enhancer/ourtarget = target
		if(!COOLDOWN_FINISHED(ourtarget, sensory_enhancer_cooldown))
			to_chat(owner, span_warning(to_chat(owner, span_warning("[DECLENT_RU_CAP(ourtarget, NOMINATIVE)] всё ещё на перезарядке. Она продлится ещё [round(COOLDOWN_TIMELEFT(ourtarget, sensory_enhancer_cooldown), 1 SECONDS) / 10] секунд!"))))
			return

		COOLDOWN_START(ourtarget, sensory_enhancer_cooldown, 5 MINUTES)

		injection_amount = 10

		if(trigger_flags & TRIGGER_SECONDARY_ACTION)
			injection_amount = 20
		if(emp_triggered)
			injection_amount = 40 //Time for a quick medical visit
		Activate()

/datum/action/item_action/organ_action/toggle/sensory_enhancer/proc/Activate(atom/target)

	var/mob/living/carbon/human/human_owner = owner

	human_owner.reagents.add_reagent(/datum/reagent/mephedrone, injection_amount)

	owner.visible_message(span_danger("[DECLENT_RU_CAP(owner, NOMINATIVE)] внезапно дёрга[PLUR_ET_YUT(owner)]ся, когда два маленьких стеклянных флакона вылетают из портов импланта на [owner.p_their()] позвоночнике и разбиваются при падении."), \
			span_userdanger("Вы внезапно дёргаетесь, когда ваша система \"Кани-Лаака\" выбрасывает два пустых стеклянных флакона назад, и они разбиваются при падении."))
	playsound(human_owner, 'sound/goonstation/items/hypo.ogg', 80, TRUE)

	var/obj/item/telegraph_vial = new /obj/item/qani_laaca_telegraph(get_turf(owner))
	var/turf/turf_we_throw_at = get_edge_target_turf(owner, REVERSE_DIR(owner.dir))
	telegraph_vial.throw_at(turf_we_throw_at, 5, 1)

	// Safety net in case the injection amount doesn't get reset. Apparently it happened to someone in a round.
	injection_amount = initial(injection_amount)

/obj/item/qani_laaca_telegraph
	name = "spent Qani-Laaca cartridge"
	desc = "Маленький стеклянный флакон, обычно хранящийся большой стопкой внутри импланта \"Кани-Лаака\", который разбивается и выбрасывается \
		каждый раз при использовании импланта. Если вы смотрите на один из них достаточно долго, чтобы так долго о нём думать, у вас либо быстрые глаза, \
		либо вам повезло поймать один до того, как он разбился."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "blastoff_ampoule_empty"
	w_class = WEIGHT_CLASS_TINY

/obj/item/qani_laaca_telegraph/get_ru_names()
	return alist(
		NOMINATIVE = "использованный картридж \"Кани-Лаака\"",
		GENITIVE = "использованного картриджа \"Кани-Лаака\"",
		DATIVE = "использованному картриджу \"Кани-Лаака\"",
		ACCUSATIVE = "использованный картридж \"Кани-Лаака\"",
		INSTRUMENTAL = "использованным картриджем \"Кани-Лаака\"",
		PREPOSITIONAL = "использованном картридже \"Кани-Лаака\"",
	)

/obj/item/qani_laaca_telegraph/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/shatters_when_thrown, /obj/effect/decal/cleanable/glass, 1, "shatter")
	transform = transform.Scale(0.75, 0.75)

/obj/item/organ/internal/cyberimp/brain/hackerman_deck
	name = "Binyat wireless hacking system"
	desc = "Редко встречающийся нейронный чип, позволяющий пользователю взаимодействовать с ближайшей техникой на расстоянии \
		и влиять на неё (обычно) полезными способами. Из-за беспроводного соединения тонкое манипулирование \
		невозможно, однако дек отправит в системы цели полезную нагрузку, которая попытается \
		взломать их за вас."
	icon_state = "hackerman"
	implant_overlay = null
	implant_color = null
	slot = INTERNAL_ORGAN_BRAIN_ANTISTUN
	origin_tech = "materials=4;combat=6;biotech=6;powerstorage=2;syndicate=3"
	actions_types = list(/datum/action/cooldown/spell/pointed/hackerman_deck)

/obj/item/organ/internal/cyberimp/brain/hackerman_deck/get_ru_names()
	return alist(
		NOMINATIVE = "беспроводная система взлома \"Бинят\"",
		GENITIVE = "беспроводной системы взлома \"Бинят\"",
		DATIVE = "беспроводной системе взлома \"Бинят\"",
		ACCUSATIVE = "беспроводную систему взлома \"Бинят\"",
		INSTRUMENTAL = "беспроводной системой взлома \"Бинят\"",
		PREPOSITIONAL = "беспроводной системе взлома \"Бинят\"",
	)

/obj/item/organ/internal/cyberimp/brain/hackerman_deck/examine_more(mob/user)
	. = ..()
	. += "<i>Считающаяся самым последним и развитым имплантом корпорации \"Киберсан\", ориентированным на взлом с расстояния при невозможности обнаружения обычными средствами. \
	Беспроводная система взлома \"Бинят\" (BWHS) — это имплант скрытого ношения, дающий пользователю рудиментарный электронный интерфейс ко всему, что можно воспринять. \
	Он использует микроглушитель, чтобы скрыть своё существование даже от самых продвинутых систем сканирования.</i>"
	. += "<i>Изначально разработанный как портативное устройство для дальнего тестирования электронных систем безопасности \"Киберсан\", \
	лёгкая интеграция компонентов в нейронный имплант привела к переоценке потенциала устройства. \
	Разработка должна была начаться для создания первых наборов прототипов, сосредоточенных на обмане сканеров без ложных срабатываний \
	и возможности взлома издалека. Однако у системы есть серьёзный недостаток, поскольку R&D \"Киберсан\" так и не смогли миниатюризировать её системы охлаждения до практического уровня. \
	Повторное использование приведёт к раздражению кожи, внутренним ожогам и даже серьёзному повреждению нервов в крайних случаях.</i>"
	. += "<i>В наше время BWHS тщательно проверяется \"Киберсан\" из-за её опасной природы и довольно сложной обнаружимости. \
	Однако это не остановило поток этих имплантов на чёрный рынок, будь то из-за внутренних или внешних влияний.</i>"

/obj/item/organ/internal/cyberimp/brain/hackerman_deck/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	owner.adjustStaminaLoss(40 / severity)
	owner.adjust_bodytemperature(400 / severity)
	to_chat(owner, span_warning("Ваша [declent_ru(NOMINATIVE)] резко нагрева[PLUR_ET_YUT(src)]ся!"))

/datum/action/cooldown/spell/pointed/hackerman_deck
	name = "Aтивация дистанционного взлома"
	desc = "Нажмите на любую машину, чтобы взломать её. Имеет небольшую дальность всего в пять тайлов."
	spell_requirements = NONE
	invocation = "none"
	antimagic_flags = NONE
	active_msg = "Вы разогреваете свою систему \"Бинят\"; в глубине вашего разума раздаётся праздное жужжание, пока он ожидает цель."
	deactive_msg = "Ваша система для взлома издаёт почти разочарованное жужжание в глубине вашего разума, отключаясь."
	button_icon_state = "hackerman"
	background_icon_state = "bg_pulsedemon"
	cast_range = 5
	/// How many times have we successfully hacked in the last minute? Increases burn damage by 3 for each value above 0.
	var/recent_hacking = 0

/datum/action/cooldown/spell/pointed/hackerman_deck/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(get_dist(user, cast_on) > 5) //fucking cameras holy shit
		to_chat(user, span_warning(span_warning("Ваш имплант недостаточно мощён, чтобы взламывать на таком расстоянии!")))
		StartCooldown(cooldown_time * 0.3)
		return
	if(istype(user.loc, /obj/machinery/atmospherics)) //Come now, no emaging all the doors on station from a pipe
		to_chat(user, span_warning("Ваш имплант не может захватить цель в трубах!"))
		return
	var/beam
	if(!isturf(user.loc)) //Using it inside a locker or stealth box is fine! Let us make sure the beam can be seen though.
		beam = user.loc.Beam(cast_on, icon_state = "sm_arc_supercharged", time = 3 SECONDS)
	else
		beam = user.Beam(cast_on, icon_state = "sm_arc_supercharged", time = 3 SECONDS)

	user.visible_message(span_warning("[DECLENT_RU_CAP(user, NOMINATIVE)] издаёт необычный жужжащий звук, когда воздух между [GEND_NIM_NEI_NIMI(user)] и [cast_on.declent_ru(INSTRUMENTAL)] потрескивает."), \
			span_warning("Воздух между вами и [cast_on.declent_ru(INSTRUMENTAL)] начинает слышно потрескивать, когда \"Бинят\" принимается за работу и нагревается в вашей голове!"))

	if(!do_after(user, 3 SECONDS, cast_on))
		qdel(beam)
		StartCooldown(cooldown_time* 0.3)
		return

	if(!cast_on.emag_act(user))
		to_chat(user, span_warning("Вы не можете взломать это!"))
		StartCooldown(cooldown_time* 0.3)
		return

	cast_on.add_hiddenprint(user)

	playsound(cast_on, 'sound/machines/terminal_processing.ogg', 15, TRUE)

	var/mob/living/carbon/human/human_owner = user
	human_owner.adjustFireLoss(5 + (recent_hacking * 3))
	recent_hacking++
	addtimer(CALLBACK(src, PROC_REF(lower_recent_hacking)), 1 MINUTES)

/datum/action/cooldown/spell/pointed/hackerman_deck/proc/lower_recent_hacking()
	recent_hacking--

//[[[[MOUTH]]]]
/obj/item/organ/internal/cyberimp/mouth
	parent_organ_zone = BODY_ZONE_PRECISE_MOUTH

/obj/item/organ/internal/cyberimp/mouth/breathing_tube
	name = "breathing tube implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	icon_state = "implant_mask"
	slot = INTERNAL_ORGAN_BREATHING_TUBE
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=2;biotech=3"
	augment_state = "breathing_tube"

/obj/item/organ/internal/cyberimp/mouth/breathing_tube/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(60/severity) && owner)
		to_chat(owner, span_warning("Your breathing tube suddenly closes!"))
		owner.AdjustLoseBreath(4 SECONDS)

//[[[[CHEST]]]]
/obj/item/organ/internal/cyberimp/chest
	name = "cybernetic torso implant"
	desc = "implants for the organs in your torso."
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	abstract_type = /obj/item/organ/internal/cyberimp/chest

/obj/item/organ/internal/cyberimp/chest/nutriment
	name = "Nutriment pump implant"
	desc = "This implant will synthesize a small amount of nutriment and pumps it directly into your bloodstream when you are starving."
	icon_state = "nutriment_implant"
	implant_overlay = null
	slot = INTERNAL_ORGAN_STOMACH
	origin_tech = "materials=2;powerstorage=2;biotech=2"
	augment_state = "nutripump"
	var/hunger_modificator = 0.7
	var/poison_amount = 5

/obj/item/organ/internal/cyberimp/chest/nutriment/insert(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(. && ishuman(target))
		target.physiology.hunger_mod *= hunger_modificator

/obj/item/organ/internal/cyberimp/chest/nutriment/remove(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(. && ishuman(target))
		target.physiology.hunger_mod /= hunger_modificator

/obj/item/organ/internal/cyberimp/chest/nutriment/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || !owner)
		return
	owner.reagents.add_reagent(/datum/reagent/questionmark, poison_amount / severity) //food poisoning
	to_chat(owner, span_warning("You feel like your insides are burning."))

/obj/item/organ/internal/cyberimp/chest/nutriment/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize a small amount of nutriment and pumps it directly into your bloodstream when you are hungry."
	icon_state = "adv_nutriment_implant"
	implant_overlay = null
	hunger_modificator = 0.5
	poison_amount = 10
	origin_tech = "materials=4;powerstorage=3;biotech=3"
	augment_state = "nutripump_adv"

/obj/item/organ/internal/cyberimp/chest/nutriment/plus/insert(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	if(HAS_TRAIT(target, TRAIT_ADVANCED_CYBERIMPLANTS))
		hunger_modificator = 0.2
		ADD_TRAIT(target, TRAIT_CYBERIMP_IMPROVED, UNIQUE_TRAIT_SOURCE(src))

	return ..()

/obj/item/organ/internal/cyberimp/chest/nutriment/plus/remove(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	if(HAS_TRAIT_FROM(target, TRAIT_CYBERIMP_IMPROVED, UNIQUE_TRAIT_SOURCE(src)))
		hunger_modificator = initial(hunger_modificator)
		REMOVE_TRAIT(target, TRAIT_CYBERIMP_IMPROVED, UNIQUE_TRAIT_SOURCE(src))

	return ..()

/obj/item/organ/internal/cyberimp/chest/nutriment_old
	name = "Nutriment pump implant"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	implant_color = "#00AA00"
	slot = INTERNAL_ORGAN_STOMACH
	origin_tech = "materials=2;powerstorage=2;biotech=2"
	augment_state = "nutripump"
	var/hunger_threshold = NUTRITION_LEVEL_STARVING
	var/synthesizing = 0
	var/poison_amount = 5

/obj/item/organ/internal/cyberimp/chest/nutriment_old/on_life()
	if(!owner)
		return
	if(synthesizing)
		return
	if(owner.stat == DEAD)
		return
	if(ismachineperson(owner))
		return
	if(isvampire(owner))
		return
	if(owner.nutrition <= hunger_threshold)
		synthesizing = TRUE
		to_chat(owner, span_notice("You feel less hungry..."))
		owner.adjust_nutrition(50)
		addtimer(CALLBACK(src, PROC_REF(synth_cool)), 50)

/obj/item/organ/internal/cyberimp/chest/nutriment_old/proc/synth_cool()
	synthesizing = FALSE

/obj/item/organ/internal/cyberimp/chest/nutriment_old/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || !owner)
		return
	owner.reagents.add_reagent(/datum/reagent/questionmark, poison_amount / severity) //food poisoning
	to_chat(owner, span_warning("You feel like your insides are burning."))

/obj/item/organ/internal/cyberimp/chest/nutriment_old/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	implant_color = "#006607"
	hunger_threshold = NUTRITION_LEVEL_HUNGRY
	poison_amount = 10
	origin_tech = "materials=4;powerstorage=3;biotech=3"
	augment_state = "nutripump_adv"

/obj/item/organ/internal/cyberimp/chest/nutriment_old/plus/hardened
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/chest/reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	icon_state = "reviver_implant"
	implant_overlay = null
	origin_tech = "materials=5;programming=4;biotech=4"
	slot = INTERNAL_ORGAN_HEART_DRIVE
	augment_state = "reviver"
	var/revive_cost = 0
	var/reviving = FALSE
	var/cooldown = 0

/obj/item/organ/internal/cyberimp/chest/reviver/hardened
	name = "Hardened reviver implant"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/chest/reviver/hardened/Initialize(mapload)
	. = ..()
	desc += " The implant has been hardened. It is invulnerable to EMPs."

/obj/item/organ/internal/cyberimp/chest/reviver/on_life()
	if(cooldown > world.time || owner.suiciding) // don't heal while you're in cooldown!
		return
	if(reviving)
		if(owner.health <= HEALTH_THRESHOLD_CRIT)
			addtimer(CALLBACK(src, PROC_REF(heal)), 30)
		else
			reviving = FALSE
			return
	cooldown = revive_cost + world.time
	revive_cost = 0
	reviving = TRUE

/obj/item/organ/internal/cyberimp/chest/reviver/proc/heal()
	if(QDELETED(owner))
		return
	var/heal_brute = 0
	var/heal_burn = 0
	var/heal_tox = 0
	var/heal_oxy = 0
	if(prob(75) && owner.getBruteLoss())
		heal_brute += 1
		revive_cost += 20
	if(prob(75) && owner.getFireLoss())
		heal_burn += 1
		revive_cost += 20
	if(prob(40) && owner.getToxLoss())
		heal_tox += 1
		revive_cost += 50
	if(prob(90) && owner.getOxyLoss())
		heal_oxy += 3
		revive_cost += 5
	owner.heal_damages(heal_brute, heal_burn, heal_tox, heal_oxy)

/obj/item/organ/internal/cyberimp/chest/reviver/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || !owner)
		return
	if(reviving)
		revive_cost += 200
	else
		cooldown += 200
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.stat != DEAD && prob(50 / severity))
			H.set_heartattack(TRUE)
			addtimer(CALLBACK(src, PROC_REF(undo_heart_attack)), 600 / severity)

/obj/item/organ/internal/cyberimp/chest/reviver/proc/undo_heart_attack()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	H.set_heartattack(FALSE)
	if(H.stat == CONSCIOUS)
		to_chat(H, span_notice("You feel your heart beating again!"))

/obj/item/organ/internal/cyberimp/chest/bluespace_anchor
	name = "bluespace anchor implant"
	desc = "Этот крупный кибернетический имплант удерживает вас в блюспейсе, предотвращая почти любые эффекты телепортации. Однако он нарушает работу GPS-систем."
	icon_state = "bluespace_anchor"
	implant_overlay = null
	slot = INTERNAL_ORGAN_CHEST_EXOFRAME
	origin_tech = "bluespace=6;biotech=4"
	materials = list(MAT_METAL = 10000, MAT_BLUESPACE = 2000)

/obj/item/organ/internal/cyberimp/chest/bluespace_anchor/get_ru_names()
	return alist(
		NOMINATIVE = "имплант блюспейс-якоря",
		GENITIVE = "импланта блюспейс-якоря",
		DATIVE = "импланту блюспейс-якоря",
		ACCUSATIVE = "имплант блюспейс-якоря",
		INSTRUMENTAL = "имплантом блюспейс-якоря",
		PREPOSITIONAL = "импланте блюспейс-якоря",
	)

/obj/item/organ/internal/cyberimp/chest/bluespace_anchor/insert(mob/living/carbon/target, special = FALSE)
	..()
	RegisterSignal(target, COMSIG_MOVABLE_TELEPORTING, PROC_REF(on_teleport))
	RegisterSignal(target, COMSIG_MOB_PRE_JAUNT, PROC_REF(on_jaunt))
	for(var/obj/item/implant/tracking/tracker in target)
		if(tracker && tracker.implanted)
			qdel(tracker)

/obj/item/organ/internal/cyberimp/chest/bluespace_anchor/remove(mob/living/carbon/target, special = FALSE)
	UnregisterSignal(target, COMSIG_MOVABLE_TELEPORTING)
	UnregisterSignal(target, COMSIG_MOB_PRE_JAUNT)
	return ..()

/// Blocks teleports and stuns the would-be-teleportee.
/obj/item/organ/internal/cyberimp/chest/bluespace_anchor/proc/on_teleport(mob/living/teleportee, atom/destination, channel)
	SIGNAL_HANDLER  // COMSIG_MOVABLE_TELEPORTED

	to_chat(teleportee,  span_userdanger("Вы чувствуете, что телепортируетесь, но внезапно вас отбрасывает обратно туда, где вы только что были!"))

	teleportee.Weaken(5 SECONDS)
	var/datum/effect_system/spark_spread/spark_system = new()
	spark_system.set_up(5, TRUE, teleportee)
	spark_system.start()
	return COMPONENT_BLOCK_TELEPORT

/// Prevents a user from entering a jaunt.
/obj/item/organ/internal/cyberimp/chest/bluespace_anchor/proc/on_jaunt(mob/living/jaunter)
	SIGNAL_HANDLER  // COMSIG_MOB_PRE_JAUNT

	to_chat(jaunter, span_userdanger("Пытаясь совершить переход в другое измерение, вы врезаетесь прямо в барьер между реальностями, и вас отбрасывает обратно в материальный мир!"))

	jaunter.Weaken(5 SECONDS)
	var/datum/effect_system/spark_spread/spark_system = new()
	spark_system.set_up(5, TRUE, jaunter)
	spark_system.start()
	return COMPONENT_BLOCK_JAUNT

/obj/item/organ/internal/cyberimp/chest/exoframe
	name = "Exoframe"
	desc = "Несущая опора, выполняющая роль \"скелета\" в конструкции гуманоидных роботов. Стандартная модель, не отличающаяся выдающимися характеристиками."
	implant_color = "#3a3a3aff"
	implant_overlay = null
	origin_tech = "materials=3;engineering=4"
	slot = INTERNAL_ORGAN_CHEST_EXOFRAME
	species_restrictions = list(SPECIES_MACHINEPERSON)
	var/id = "EXO_DEFAULT"
	var/given_health = 0
	var/repair_time = 1 SECONDS
	var/list/traits_added
	var/strength_gain = 1
	var/internal_emp_damage = 1
	var/external_emp_damage = 1
	var/low_pressure_hazard = HAZARD_LOW_PRESSURE
	var/low_pressure_warning = WARNING_LOW_PRESSURE
	var/coldmod = 1

/obj/item/organ/internal/cyberimp/chest/exoframe/get_ru_names()
	return alist(
		NOMINATIVE = "стандартный каркас экзоскелета",
		GENITIVE = "стандартного каркаса экзоскелета",
		DATIVE = "стандартному каркасу экзоскелета",
		ACCUSATIVE = "стандартный каркас экзоскелета",
		INSTRUMENTAL = "стандартным каркасом экзоскелета",
		PREPOSITIONAL = "стандартном каркасе экзоскелета",
	)

/obj/item/organ/internal/cyberimp/chest/exoframe/insert(mob/living/carbon/human/target)
	if(!crit_fail)
		target.add_traits(traits_added, UNIQUE_TRAIT_SOURCE(src))
		target.maxHealth += given_health
		target.health += given_health
		target.dna.species.hazard_low_pressure = low_pressure_hazard
		target.dna.species.warning_low_pressure = low_pressure_warning
		target.dna.species.coldmod = coldmod
	target.robotic_limb_repair_time = repair_time
	target.emp_damage_multiplier_external = external_emp_damage
	target.emp_damage_multiplier_internal = internal_emp_damage
	SEND_SIGNAL(target, COMSIG_STRENGTH_LEVEL_UP, strength_gain)
	return ..()

/obj/item/organ/internal/cyberimp/chest/exoframe/remove(mob/living/carbon/human/target)
	if(!crit_fail)
		target.remove_traits(traits_added, UNIQUE_TRAIT_SOURCE(src))
		target.health -= given_health
		target.maxHealth -= given_health
		target.dna.species.hazard_low_pressure = initial(target.dna.species.hazard_low_pressure)
		target.dna.species.warning_low_pressure = initial(target.dna.species.warning_low_pressure)
		target.dna.species.coldmod = initial(target.dna.species.coldmod)
	target.robotic_limb_repair_time = initial(target.robotic_limb_repair_time)
	target.emp_damage_multiplier_external = initial(target.emp_damage_multiplier_external)
	target.emp_damage_multiplier_internal = initial(target.emp_damage_multiplier_internal)
	SEND_SIGNAL(target, COMSIG_STRENGTH_LEVEL_UP, 1)
	return ..()

/obj/item/organ/internal/cyberimp/chest/exoframe/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || crit_fail)
		return

	if(!ishuman(owner))
		return

	if(!prob(30))
		return

	to_chat(owner, span_warning("Приводы вашего экзоскелета перестают двигаться!"))
	crit_fail = TRUE
	var/mob/living/carbon/human/human = owner
	human.health -= given_health
	human.maxHealth -= given_health
	human.dna.species.hazard_low_pressure = initial(human.dna.species.hazard_low_pressure)
	human.dna.species.warning_low_pressure = initial(human.dna.species.warning_low_pressure)
	human.dna.species.coldmod = initial(human.dna.species.coldmod)
	human.remove_traits(traits_added, UNIQUE_TRAIT_SOURCE(src))
	damage = 1

/obj/item/organ/internal/cyberimp/chest/exoframe/surgeryize()
	if(crit_fail && owner)
		to_chat(owner, span_notice("Приводы вашего экзоскелета вновь активны."))
	crit_fail = FALSE

	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/human = owner
	human.add_traits(traits_added, UNIQUE_TRAIT_SOURCE(src))
	human.maxHealth += given_health
	human.health += given_health
	human.dna.species.hazard_low_pressure = low_pressure_hazard
	human.dna.species.warning_low_pressure = low_pressure_warning
	human.dna.species.coldmod = coldmod

/obj/item/organ/internal/cyberimp/chest/exoframe/reinforced
	name = "Reinforced exoframe"
	desc = "Несущая опора, выполняющая роль \"скелета\" в конструкции гуманоидных роботов. Укреплённая модель, способная выдержать больше повреждений."
	id = "EXO_REINFORCED"
	icon_state = "exoframe_reinforced"
	given_health = 20
	repair_time = 2 SECONDS
	traits_added = list(TRAIT_IGNOREDAMAGESLOWDOWN)
	strength_gain = 3

/obj/item/organ/internal/cyberimp/chest/exoframe/reinforced/get_ru_names()
	return alist(
			NOMINATIVE = "укрепленный каркас экзоскелета",
			GENITIVE = "укрепленного каркаса экзоскелета",
			DATIVE = "укрепленному каркасу экзоскелета",
			ACCUSATIVE = "укрепленный каркас экзоскелета",
			INSTRUMENTAL = "укрепленным каркасом экзоскелета",
			PREPOSITIONAL = "укрепленном каркасе экзоскелета",
		)

/obj/item/organ/internal/cyberimp/chest/exoframe/industrial
	name = "Industrial exoframe"
	desc = "Несущая опора, выполняющая роль \"скелета\" в конструкции гуманоидных роботов. Промышленная модель, созданная специально для работ в открытом космосе."
	id = "EXO_INDUSTRIAL"
	icon_state = "exoframe_industrial"
	traits_added = list(TRAIT_SHOCKIMMUNE)
	strength_gain = 4
	low_pressure_hazard = 1
	low_pressure_warning = -300
	coldmod = -1
	external_emp_damage = 1.5

/obj/item/organ/internal/cyberimp/chest/exoframe/industrial/get_ru_names()
	return alist(
		NOMINATIVE = "промышленный каркас экзоскелета",
		GENITIVE = "промышленного каркаса экзоскелета",
		DATIVE = "промышленному каркасу экзоскелета",
		ACCUSATIVE = "промышленный каркас экзоскелета",
		INSTRUMENTAL = "промышленным каркасом экзоскелета",
		PREPOSITIONAL = "промышленном каркасе экзоскелета",
	)

/obj/item/organ/internal/cyberimp/chest/exoframe/combat
	name = "Combat exoframe"
	desc = "Несущая опора, выполняющая роль \"скелета\" в конструкции гуманоидных роботов. Облегченная модель из пластитанового сплава с повышенной прочностью конструкции."
	id = "EXO_COMBAT"
	icon_state = "exoframe_combat"
	origin_tech = "materials=4;engineering=4;syndicate=3;combat=4"
	given_health = 40
	repair_time = 4 SECONDS
	traits_added = list(TRAIT_IGNOREDAMAGESLOWDOWN)
	strength_gain = 4
	internal_emp_damage = 0.25
	external_emp_damage = 0.5
	var/active = FALSE
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/internal/cyberimp/chest/exoframe/combat/get_ru_names()
	return alist(
		NOMINATIVE = "боевой каркас экзоскелета",
		GENITIVE = "боевого каркаса экзоскелета",
		DATIVE = "боевому каркасу экзоскелета",
		ACCUSATIVE = "боевой каркас экзоскелета",
		INSTRUMENTAL = "боевым каркасом экзоскелета",
		PREPOSITIONAL = "боевом каркасе экзоскелета",
	)

/obj/item/organ/internal/cyberimp/chest/exoframe/combat/insert(mob/living/carbon/human/target)
	. = ..()
	if(.)
		ADD_TRAIT(target, TRAIT_COMBAT_EXOFRAME_EMP_SHIELD, UNIQUE_TRAIT_SOURCE(src))
	return .

/obj/item/organ/internal/cyberimp/chest/exoframe/combat/remove(mob/living/carbon/human/target)
	if(active)
		ui_action_click()
	REMOVE_TRAIT(target, TRAIT_COMBAT_EXOFRAME_EMP_SHIELD, UNIQUE_TRAIT_SOURCE(src))
	return ..()

/obj/item/organ/internal/cyberimp/chest/exoframe/combat/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(active)
		ui_action_click()
	if(owner && crit_fail)
		REMOVE_TRAIT(owner, TRAIT_COMBAT_EXOFRAME_EMP_SHIELD, UNIQUE_TRAIT_SOURCE(src))
	return .

/obj/item/organ/internal/cyberimp/chest/exoframe/combat/surgeryize()
	. = ..()
	if(owner)
		ADD_TRAIT(owner, TRAIT_COMBAT_EXOFRAME_EMP_SHIELD, UNIQUE_TRAIT_SOURCE(src))
	return .

/obj/item/organ/internal/cyberimp/chest/exoframe/combat/ui_action_click(mob/user, datum/action/action, leftclick)
	if(crit_fail)
		owner.balloon_alert(owner, "каркас не отвечает!")
		return

	if(active)
		to_chat(owner, span_notice("Ваши движения замедляются!"))
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/increaserun)
		owner.dna.species.hunger_drain_mod /= 4
		active = FALSE
		return

	to_chat(owner, span_notice("Ваши движения ускоряются!"))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/increaserun)
	owner.dna.species.hunger_drain_mod *= 4
	active = TRUE

//BOX O' IMPLANTS

/obj/item/storage/box/cyber_implants
	name = "boxed cybernetic implant"
	desc = "A sleek, sturdy box."
	icon_state = "box_implants"
	item_state = "spec"

/obj/item/storage/box/cyber_implants/populate_contents()
	new /obj/item/autoimplanter(src)

/obj/item/storage/box/cyber_implants/thermals/populate_contents()
	..()
	new /obj/item/organ/internal/cyberimp/eyes/thermals(src)

/obj/item/storage/box/cyber_implants/xray/populate_contents()
	..()
	new /obj/item/organ/internal/cyberimp/eyes/xray(src)

/obj/item/storage/box/cyber_implants/reviver_hardened/populate_contents()
	..()
	new /obj/item/organ/internal/cyberimp/chest/reviver/hardened(src)

/obj/item/storage/box/cyber_implants/anti_stun_hardened/populate_contents()
	..()
	new /obj/item/organ/internal/cyberimp/brain/anti_stun/hardened(src)

/obj/item/storage/box/cyber_implants/anti_sleep_hardened/populate_contents()
	..()
	new /obj/item/organ/internal/cyberimp/brain/anti_sleep/hardened(src)

/obj/item/storage/box/cyber_implants/nuke_map/populate_contents()
	..()
	new /obj/item/organ/internal/cyberimp/eyes/map/nuke(src)

/obj/item/storage/box/cyber_implants/bundle
	name = "boxed cybernetic implants"
	var/list/boxed = list(/obj/item/organ/internal/cyberimp/eyes/xray,/obj/item/organ/internal/cyberimp/eyes/thermals,
						/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened, /obj/item/organ/internal/cyberimp/chest/reviver/hardened)
	var/amount = 5

/obj/item/storage/box/cyber_implants/bundle/populate_contents()
	..()
	var/implant
	while(amount > 0)
		implant = pick(boxed)
		new implant(src)
		amount--

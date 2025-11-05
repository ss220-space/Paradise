/datum/martial_art/krav_maga
	name = "Крав-мага"
	has_dirslash = FALSE
	change_musculs = FALSE
	block_chance = 40
	weight = 9 //Higher weight, since you can choose to put on or take off the gloves
	var/datum/action/neck_chop/neckchop = new/datum/action/neck_chop()
	var/datum/action/leg_sweep/legsweep = new/datum/action/leg_sweep()
	var/datum/action/lung_punch/lungpunch = new/datum/action/lung_punch()
	var/datum/action/neutral_stance/neutral = new/datum/action/neutral_stance()

/datum/action/neutral_stance
	name = "Нейтральная стойка. При атаке не применяются никакие приёмы."
	button_icon_state = "neutralstance"

/datum/action/neutral_stance/Trigger(left_click = TRUE)
	var/mob/living/carbon/human/H = owner
	if(!H.mind.martial_art.in_stance)
		owner.balloon_alert(owner, "нельзя отменить неактивный приём")
		return
	owner.balloon_alert_to_viewers("расслабля[PLUR_ET_YUT(owner)] боевую стойку", "приём отменен", COMBAT_MESSAGE_RANGE)
	H.mind.martial_art.combos.Cut()
	H.mind.martial_art.in_stance = FALSE

/datum/action/neck_chop
	name = "Удар по шее — травмирует и ослепляет цель, от чего она будет некоторое время промахиваться при попытке атаковать."
	button_icon_state = "neckchop"

/datum/action/neck_chop/Trigger(left_click = TRUE)
	var/mob/living/carbon/human/H = owner
	if(!istype(H.mind.martial_art, /datum/martial_art/krav_maga))
		owner.balloon_alert(owner, "приём недоступен")
		return
	if(owner.incapacitated())
		owner.balloon_alert(owner, "нельзя провести приём")
		return
	owner.balloon_alert_to_viewers("принима[PLUR_ET_YUT(owner)] боевую стойку", "приём подготовлен", COMBAT_MESSAGE_RANGE)
	H.mind.martial_art.combos.Cut()
	H.mind.martial_art.combos.Add(/datum/martial_combo/krav_maga/neck_chop)
	H.mind.martial_art.reset_combos()
	H.mind.martial_art.in_stance = TRUE

/datum/action/leg_sweep
	name = "Подсечка — травмирует ногу цели, ненадолго замедляя её движение."
	button_icon_state = "legsweep"

/datum/action/leg_sweep/Trigger(left_click = TRUE)
	var/mob/living/carbon/human/H = owner
	if(!istype(H.mind.martial_art, /datum/martial_art/krav_maga))
		owner.balloon_alert(owner, "приём недоступен")
		return
	if(owner.incapacitated())
		owner.balloon_alert(owner, "нельзя провести приём")
		return
	owner.balloon_alert_to_viewers("принима[PLUR_ET_YUT(owner)] боевую стойку", "приём подготовлен", COMBAT_MESSAGE_RANGE)
	H.mind.martial_art.combos.Cut()
	H.mind.martial_art.combos.Add(/datum/martial_combo/krav_maga/leg_sweep)
	H.mind.martial_art.reset_combos()
	H.mind.martial_art.in_stance = TRUE

/datum/action/lung_punch//referred to internally as 'quick choke'
	name = "Удар по лёгким — сильный удар по торсу цели, на некоторое время восстановление её выносливости будет замедлено."
	button_icon_state = "lungpunch"

/datum/action/lung_punch/Trigger(left_click = TRUE)
	var/mob/living/carbon/human/H = owner
	if(!istype(H.mind.martial_art, /datum/martial_art/krav_maga))
		owner.balloon_alert(owner, "приём недоступен")
		return
	if(owner.incapacitated())
		owner.balloon_alert(owner, "нельзя провести приём")
		return
	owner.balloon_alert_to_viewers("принима[PLUR_ET_YUT(owner)] боевую стойку", "приём подготовлен", COMBAT_MESSAGE_RANGE)
	H.mind.martial_art.combos.Cut()
	H.mind.martial_art.combos.Add(/datum/martial_combo/krav_maga/lung_punch)
	H.mind.martial_art.reset_combos()
	H.mind.martial_art.in_stance = TRUE

/datum/martial_art/krav_maga/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	if(HAS_TRAIT(H, TRAIT_PACIFISM))
		to_chat(H, span_warning("Техники Крав-мага отдаются пустым эхом в вашей голове, мысль об их жестокости отвратительна вам!"))
		return
	to_chat(H, span_userdanger("Вы узнали техники Крав-мага!"))
	to_chat(H, span_danger("Наведите курсор на приём наверху экрана, чтобы узнать что он делает."))
	neutral.Grant(H)
	neckchop.Grant(H)
	legsweep.Grant(H)
	lungpunch.Grant(H)

/datum/martial_art/krav_maga/remove(mob/living/carbon/human/H)
	..()
	to_chat(H, span_userdanger("Вы внезапно забываете техники Крав-мага..."))
	neutral.Remove(H)
	neckchop.Remove(H)
	legsweep.Remove(H)
	lungpunch.Remove(H)

/datum/martial_art/krav_maga/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	add_attack_logs(A, D, "Melee attacked with [src]")
	var/picked_hit_type = pick("бь[PLUR_YOT_YUT(A)]", "пина[PLUR_ET_YUT(A)]")
	var/bonus_damage = 15
	if(IS_HORIZONTAL(D))
		bonus_damage += 5
		picked_hit_type = "топч[PLUR_ET_UT(A)]"

	D.apply_damage(bonus_damage, BRUTE)
	objective_damage(A, D, bonus_damage, BRUTE)

	if(picked_hit_type == "пина[PLUR_ET_YUT(A)]" || picked_hit_type == "топч[PLUR_ET_UT(A)]")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	else
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	D.visible_message(
		span_danger("[capitalize(A.declent_ru(NOMINATIVE))] [picked_hit_type] [D.declent_ru(ACCUSATIVE)]!"), \
		span_userdanger("[capitalize(A.declent_ru(NOMINATIVE))] [picked_hit_type] вас!")
	)
	return TRUE

//Krav Maga Gloves

/obj/item/clothing/gloves/color/black/krav_maga
	var/datum/martial_art/krav_maga/style
	can_be_cut = FALSE

/obj/item/clothing/gloves/color/black/krav_maga/Initialize(mapload)
	. = ..()
	style = new()

/obj/item/clothing/gloves/color/black/krav_maga/Destroy()
	QDEL_NULL(style)

	return ..()

/obj/item/clothing/gloves/color/black/krav_maga/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(!ishuman(user) || slot != ITEM_SLOT_GLOVES)
		return .
	style.teach(user, TRUE)


/obj/item/clothing/gloves/color/black/krav_maga/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(!ishuman(user) || slot != ITEM_SLOT_GLOVES)
		return .
	style.remove(user)


/obj/item/clothing/gloves/color/black/krav_maga/sec//more obviously named, given to sec
	name = "перчатки крав-мага"
	desc = "Особые наночипы в этих перчатках позволят вам использовать техники Крав-мага."
	icon_state = "fightgloves"
	item_state = "fightgloves"

/datum/martial_art/krav_maga
	name = "Крав Мага"
	var/datum/action/neck_chop/neckchop = new/datum/action/neck_chop()
	var/datum/action/leg_sweep/legsweep = new/datum/action/leg_sweep()
	var/datum/action/lung_punch/lungpunch = new/datum/action/lung_punch()

/datum/action/neck_chop
	name = "Удар по горлу - Повреждает шею, временно лишая жертву возможности говорить."
	button_icon_state = "neckchop"

/datum/action/neck_chop/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>Вы не можете использовать Крав Мага пока выведены из строя.</span>")
		return
	to_chat(owner, "<b><i>Ваша следующая атака будет Ударом в Горло.</i></b>")
	owner.visible_message("<span class='danger'>[owner] принимает стойку для удара в горло!</span>")
	var/mob/living/carbon/human/H = owner
	H.mind.martial_art.combos.Cut()
	H.mind.martial_art.combos.Add(/datum/martial_combo/krav_maga/neck_chop)
	H.mind.martial_art.reset_combos()

/datum/action/leg_sweep
	name = "Подножка - Выбивает ноги жертвы, в результате чего она падает и не может двигаться в течении короткого времени."
	button_icon_state = "legsweep"

/datum/action/leg_sweep/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>Вы не можете использовать Крав Мага пока выведены из строя.</span>")
		return
	to_chat(owner, "<b><i>Ваша следующая атаку будет Подножкой.</i></b>")
	owner.visible_message("<span class='danger'>[owner] принимает стойку для выбивания ноги!</span>")
	var/mob/living/carbon/human/H = owner
	H.mind.martial_art.combos.Cut()
	H.mind.martial_art.combos.Add(/datum/martial_combo/krav_maga/leg_sweep)
	H.mind.martial_art.reset_combos()

/datum/action/lung_punch//referred to internally as 'quick choke'
	name = "Удар под дых - наносит сильный удар под дых, сдавливая лёгкие, отчего жертва временно не может дышать."
	button_icon_state = "lungpunch"

/datum/action/lung_punch/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>Вы не можете использовать Крав Мага пока выведены из строя.</span>")
		return
	to_chat(owner, "<b><i>Ваша следующая атака будет Ударом под дых.</i></b>")
	owner.visible_message("<span class='danger'>[owner] принимает стойку для удара по солнечному сплетению!</span>")
	var/mob/living/carbon/human/H = owner
	H.mind.martial_art.combos.Cut()
	H.mind.martial_art.combos.Add(/datum/martial_combo/krav_maga/lung_punch)
	H.mind.martial_art.reset_combos()

/datum/martial_art/krav_maga/teach(var/mob/living/carbon/human/H,var/make_temporary=0)
	..()
	to_chat(H, "<span class = 'userdanger'>Вами изучено искусство Крав Мага!</span>")
	to_chat(H, "<span class = 'danger'>Наведите курсор на способность в верхней части экрана, чтобы увидеть, что она делает.</span>")
	neckchop.Grant(H)
	legsweep.Grant(H)
	lungpunch.Grant(H)

/datum/martial_art/krav_maga/remove(var/mob/living/carbon/human/H)
	..()
	to_chat(H, "<span class = 'userdanger'>Вы забываете искусство Крав Мага...</span>")
	neckchop.Remove(H)
	legsweep.Remove(H)
	lungpunch.Remove(H)

/datum/martial_art/krav_maga/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	add_attack_logs(A, D, "Melee attacked with [src]")
	var/picked_hit_type = pick("пробил в шею", "пнул", "пнул в колено", "ударил коленом", "пробил")
	var/bonus_damage = 10
	if(D.IsWeakened() || D.resting || D.lying)
		bonus_damage += 5
		picked_hit_type = "пробил"
	D.apply_damage(bonus_damage, BRUTE)
	if(picked_hit_type == "пнул" || picked_hit_type == "пробил")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	else
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] вас!</span>")
	return TRUE

/datum/martial_art/krav_maga/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	if(prob(60))
		if(D.hand)
			if(istype(D.l_hand, /obj/item))
				var/obj/item/I = D.l_hand
				if(D.drop_item())
					A.put_in_hands(I)
		else
			if(istype(D.r_hand, /obj/item))
				var/obj/item/I = D.r_hand
				if(D.drop_item())
					A.put_in_hands(I)
		D.visible_message("<span class='danger'>[A] обезоружил [D]!</span>", \
							"<span class='userdanger'>[A] обезоружил [D]!</span>")
		playsound(D, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	else
		D.visible_message("<span class='danger'>[A] попытался обезоружить [D]!</span>", \
							"<span class='userdanger'>[A] попытался обезоружить [D]!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	return TRUE

//Krav Maga Gloves - Перчатки Крав Мага --- зачем я это перевел??? Ну я же Пупс.

/obj/item/clothing/gloves/color/black/krav_maga
	var/datum/martial_art/krav_maga/style = new
	can_be_cut = FALSE
	resistance_flags = NONE

/obj/item/clothing/gloves/color/black/krav_maga/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_gloves)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)

/obj/item/clothing/gloves/color/black/krav_maga/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_gloves) == src)
		style.remove(H)

/obj/item/clothing/gloves/color/black/krav_maga/sec//more obviously named, given to sec
	name = "Перчатки Крав Мага"
	desc = "Наночипы печаток позволят вам овладеть искусством Крав Мага."
	icon_state = "fightgloves"
	item_state = "fightgloves"

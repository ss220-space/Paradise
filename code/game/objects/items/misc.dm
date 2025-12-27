//MISC items
//These items don't belong anywhere else, so they have this file.

//Current contents:
/*
	Cursor Drag Pointer
	Beach Ball
	Mouse Jetpack
	Electronic Cigarette
*/

// E-cig defines
#define MAX_AMOUNT 600
#define SAFE_THRESHOLD 10
#define AWARD_THRESHOLD 60

/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/item/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "beachball"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 20
	flags = CONDUCT
	item_flags = NO_PIXEL_RANDOM_DROP

/obj/item/mouse_jetpack
	name = "improvised mouse jetpack"
	desc = "A roughly made jetpack designed for satisfy extremely small persons."
	icon_state = "jetpack_mouse"
	icon = 'icons/obj/tank.dmi'
	w_class = WEIGHT_CLASS_SMALL

/obj/item/syndicate_reverse_card
	name = "playing card"
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_down_syndicate"
	desc = "A playing card. You can only see the back."
	w_class = WEIGHT_CLASS_TINY
	var/used = FALSE //has this been used before? If not, give no hints about it's nature
	description_antag = "Hold this in your hand when you are getting shot at to steal your opponent's gun. You'll lose this, so be careful!"

/obj/item/syndicate_reverse_card/update_icon_state()
	. = ..()
	if(used)
		icon_state = "reverse_card"

/obj/item/syndicate_reverse_card/update_name()
	. = ..()
	if(used)
		name = "'Red Reverse' card"

/obj/item/syndicate_reverse_card/examine(mob/user)
	. = ..()
	if(used)
		. += span_warning("Something sinister is strapped to this card. It looks like it was once masked with some sort of cloaking field, which is now nonfunctional.")

/obj/item/syndicate_reverse_card/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(attack_type != PROJECTILE_ATTACK)
		return FALSE //this means the attack goes through
	if(istype(hitby, /obj/projectile))
		var/obj/projectile/P = hitby
		if(P?.firer && P.firer_source_atom && (P.firer != P.firer_source_atom)) //if the projectile comes from YOU, like your spit or some shit, you can't steal that bro. Also protects mechs
			if(iscarbon(P.firer)) //You can't switcharoo with turrets or simplemobs, or borgs
				return switcharoo(P.firer, owner, P.firer_source_atom)
	return FALSE

/obj/item/syndicate_reverse_card/proc/switcharoo(mob/firer, mob/user, obj/item/gun/target_gun) //this proc teleports the target_gun out of the firer's hands and into the user's. The firer gets the card.
	if(!user.drop_item_ground(src)) //firstly, check for ani-drop on card owner
		return FALSE

	if(!firer.drop_item_ground(target_gun)) //then, check for anti-drop on gun owner. Don't do it in the same proc
		user.put_in_hands(src)
		return FALSE
	//first, the sparks!
	do_sparks(12, TRUE, user)
	//next, we move the gun to the user and the card to the firer
	to_chat(user, span_warning("The [src] vanishes from your hands, and [target_gun] appears in them!"))
	to_chat(firer, span_warning("[target_gun] vanishes from your hands, and a [src] appears in them!"))
	user.put_in_hands(target_gun)
	firer.put_in_hands(src)
	used = TRUE
	update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
	return TRUE


/obj/item/ecig
	name = "electronic cigarette"
	desc = "Гладкий никотиновый испаритель в сдержанном зелёном корпусе. Создаёт плотное, но быстро рассеивающееся облако пара. Одобрен для рабочих зон: дым без пепла и характерного запаха."
	gender = FEMALE
	icon = 'icons/obj/device.dmi'
	icon_state = "ecig"
	item_state = "ecig"
	w_class = WEIGHT_CLASS_TINY
	var/amount_left = 600
	var/applying = FALSE
	var/list/reagent = list("nicotine")

/obj/item/ecig/get_ru_names()
	return list(
		NOMINATIVE = "электронная сигарета",
		GENITIVE = "электронной сигареты",
		DATIVE = "электронной сигарете",
		ACCUSATIVE = "электронную сигарету",
		INSTRUMENTAL = "электронной сигаретой",
		PREPOSITIONAL = "электронной сигарете"
	)

/obj/item/ecig/emag_act(mob/user)
	if(emagged)
		return

	add_attack_logs(user, src, "emagged")
	emagged = TRUE

	if(!user)
		return

	balloon_alert(user, "протоколы безопасности взломаны")

/obj/item/ecig/examine(mob/user)
	. = ..()

	if(amount_left <= 0)
		. += span_warning("Жидкость полностью исчерпана.")
		return

	var/percentage = round((amount_left / MAX_AMOUNT) * 100)
	. += span_notice("Осталось жидкости: <b>[percentage]%</b>")

/obj/item/ecig/attack_self(mob/user)
	if(!ishuman(user) || ismachineperson(user))
		balloon_alert(user, "ошибка совместимости!")
		return

	if(!get_location_accessible(user, BODY_ZONE_PRECISE_MOUTH))
		balloon_alert(user, "ваш рот закрыт!")
		return

	if(amount_left <= 0)
		playsound(loc, 'sound/machines/lightswitch.ogg', 25, TRUE)
		balloon_alert(user, "жидкость закончилась!")
		return

	if(applying)
		applying = FALSE
		return

	user.visible_message(
		span_notice("[user] начина[PLUR_ET_YUT(user)] затягиваться [declent_ru(INSTRUMENTAL)]."),
		span_notice("Вы начинаете затягиваться [declent_ru(INSTRUMENTAL)]."),
	)

	applying = TRUE
	var/cycle_count = 0

	while(amount_left > 0 && applying)
		if(!do_after(user, 1 SECONDS, user, progress = TRUE, max_interact_count = 1))
			break

		cycle_count++
		inject_nicotine(user, cycle_count)

		if(QDELETED(src))
			applying = FALSE
			return

	applying = FALSE

	if(cycle_count > 0)
		user.visible_message(
			span_notice("[user] выпуска[PLUR_ET_YUT(user)] облако пара."),
			span_notice("Вы выпускаете облако пара."),
		)
		if(cycle_count > SAFE_THRESHOLD && prob(20))
			if(user.gender == FEMALE)
				playsound(loc, 'sound/misc/ecig_female.ogg', 5, TRUE)
			else
				playsound(loc, 'sound/misc/ecig_male.ogg', 5, TRUE)
		create_smoke(cycle_count)

/obj/item/ecig/proc/inject_nicotine(mob/living/carbon/user, cycle_count)
	if(!user.reagents)
		return

	for(var/chem in reagent)
		user.reagents.add_reagent(chem, 1)

	playsound(loc, 'sound/misc/ecig.ogg', 50, TRUE)
	amount_left = max(0, amount_left - 1)

	if(cycle_count >= SAFE_THRESHOLD)
		user.adjustToxLoss(2)
		if(prob(10))
			to_chat(user, span_warning("Голова кружится от такой долгой затяжки..."))

	if(cycle_count >= AWARD_THRESHOLD)
		user.client?.give_award(/datum/award/achievement/misc/deep_draw, user)

	if(emagged && cycle_count >= SAFE_THRESHOLD)
		applying = FALSE
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] становится обжигающе горячей!"))
		addtimer(CALLBACK(src, PROC_REF(perform_sparks)), 15)
		addtimer(CALLBACK(src, PROC_REF(play_buzz_sound)), 30)
		addtimer(CALLBACK(src, PROC_REF(explode_ecig), user), 40)
		return

/obj/item/ecig/proc/perform_sparks()
	if(!src)
		return

	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] начинает пищать и искрить!"))
	do_sparks(4, TRUE, src)
	playsound(loc, 'sound/machines/defib_saftyon.ogg', 25, TRUE)

/obj/item/ecig/proc/play_buzz_sound()
	if(!src)
		return

	playsound(loc, 'sound/machines/buzz-sigh.ogg', 25, TRUE)

/obj/item/ecig/proc/explode_ecig(mob/user)
	if(!src)
		return

	visible_message(span_userdanger("[capitalize(declent_ru(NOMINATIVE))] взрывается!"))
	explosion(loc, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 1, flame_range = 1, adminlog = TRUE, cause = user)
	qdel(src)

/obj/item/ecig/proc/create_smoke(cycle_count)
	if(!src)
		return

	var/datum/effect_system/fluid_spread/smoke/chem/quick/vapor/smoke = new
	smoke.set_up(range = round(clamp(cycle_count/10, 0, 4)), location = loc)
	smoke.start()

/obj/item/ecig/syndi
	name = "suspicious e-cigarette"
	desc = "Гладкий никотиновый испаритель в подозрительном красном корпусе. Выдаёт плотное облако пара с лёгким химическим оттенком."
	icon_state = "ecig_syndi"
	item_state = "ecig_syndi"
	reagent = list("nicotine", "syndiezine")

/obj/item/ecig/syndi/get_ru_names()
	return list(
		NOMINATIVE = "подозрительная электронная сигарета",
		GENITIVE = "подозрительной электронной сигареты",
		DATIVE = "подозрительной электронной сигарете",
		ACCUSATIVE = "подозрительную электронную сигарету",
		INSTRUMENTAL = "подозрительной электронной сигаретой",
		PREPOSITIONAL = "подозрительной электронной сигарете"
	)

#undef MAX_AMOUNT
#undef SAFE_THRESHOLD
#undef AWARD_THRESHOLD

/obj/item/krampus_bag
	name = "krampus bag"
	desc = "Старый потрепаный мешок. На нем видны следы засохшей крови и ... угля?"
	icon_state = "krampus_bag"
	COOLDOWN_DECLARE(coal_cooldown)

/obj/item/krampus_bag/equipped(mob/user, slot, initial)
	if(!iskrampus(user))
		user.drop_item_ground()
		return
	. = ..()


/obj/item/krampus_bag/get_ru_names()
	return list(
		NOMINATIVE = "мешок Крампуса",
		GENITIVE = "мешка Крампуса",
		DATIVE = "мешку Крампуса",
		ACCUSATIVE = "мешок Крампуса",
		INSTRUMENTAL = "мешком Крампуса",
		PREPOSITIONAL = "мешке Крампуса",
	)

/obj/item/krampus_bag/attack_self(mob/user)
	var/mob/living/carbon/true_devil/krampus/krampus = user

	if(!istype(krampus) || !COOLDOWN_FINISHED(src, coal_cooldown))
		balloon_alert(user, "невозможно использовать")
		return ..()

	COOLDOWN_START(src, coal_cooldown, 1 MINUTES)
	new /obj/item/toy/pet_rock/naughty_coal(get_turf(user))
	. = ..()


/obj/item/krampus_bag/attack(mob/living/M, mob/user, params, def_zone, skip_attack_anim = FALSE)
	if((M.stat || M?.health <= (HEALTH_THRESHOLD_CRIT + 30)) && do_after(user, 5 SECONDS, M))
		consume(M, user)
		return
	..()

/obj/item/krampus_bag/proc/consume(mob/living/victim, mob/user)
	if(QDELETED(victim))
		return

	var/mob/living/carbon/true_devil/krampus/krampus = user

	if(!istype(krampus))
		balloon_alert(user, "невозможно использовать")
		return

	victim.visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] открывается нараспашку и захватывает [victim.declent_ru(ACCUSATIVE)]!"), span_his_grace("[span_big("[declent_ru(NOMINATIVE)] захватывает вас!")]"))
	victim.death()

	LAZYADD(krampus.bag_content, victim)
	victim.forceMove(krampus)

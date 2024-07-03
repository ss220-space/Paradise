/obj/effect/proc_holder/spell/rathens
	name = "Rathen's Secret"
	desc = "Создает вокруг вас мощную ударную волну, которая вырывает у врагов аппендикс, а иногда и конечности."
	base_cooldown = 50 SECONDS
	cooldown_min = 20 SECONDS
	clothes_req = TRUE
	invocation = "APPEN NATH!"
	invocation_type = "shout"
	action_icon_state = "lungpunch"


/obj/effect/proc_holder/spell/rathens/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.max_targets = INFINITY
	return T


/obj/effect/proc_holder/spell/rathens/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/human/H in targets)
		var/datum/effect_system/smoke_spread/s = new
		s.set_up(5, FALSE, H)
		s.start()
		var/obj/item/organ/internal/appendix/A = H.get_int_organ(/obj/item/organ/internal/appendix)
		if(A)
			A.remove(H)
			A.forceMove(get_turf(H))
			spawn()
				A.throw_at(get_edge_target_turf(H, pick(GLOB.alldirs)), rand(1, 10), 5)
			H.visible_message("<span class='danger'>[H]'s [A.name] вылетает из твоего тела из-за магического взрыва!</span>",\
							  "<span class='danger'>Your [A.name] вылетает из твоего тела из-за магического взрыва!</span>")
			H.Weaken(4 SECONDS)
		else
			var/obj/effect/decal/cleanable/blood/gibs/G = new/obj/effect/decal/cleanable/blood/gibs(get_turf(H))
			spawn()
				G.throw_at(get_edge_target_turf(H, pick(GLOB.alldirs)), rand(1, 10), 5)
			H.apply_damage(10, BRUTE, BODY_ZONE_CHEST)
			to_chat(H, "<span class='userdanger'>У тебя нет аппендикса, но что-то должно было измениться! Черт возьми, что это было?</span>")
			H.Weaken(6 SECONDS)
			for(var/obj/item/organ/external/E as anything in H.bodyparts)
				if(istype(E, /obj/item/organ/external/head))
					continue
				if(istype(E, /obj/item/organ/external/chest))
					continue
				if(istype(E, /obj/item/organ/external/groin))
					continue
				if(prob(7))
					to_chat(H, "<span class='userdanger'>Ваш [E] был отделён магическим взрывом!</span>")
					E.droplimb(1, DROPLIMB_SHARP, 0, 1)

/obj/item/beach_ball/football
	name = "football ball"
	icon = 'icons/obj/football.dmi'
	icon_state = "football"
	item_state = "football"
	var/kick_speed = 0.25

/obj/item/beach_ball/football/attack_hand(mob/user)
	if(user.a_intent == INTENT_HARM || user.a_intent == INTENT_DISARM)
		kicked(user, get_dir(user, src))
		return
	. = ..()

/obj/item/beach_ball/football/proc/kicked(mob/user, dir)
	var/turf/throw_target = get_edge_target_turf(user, dir)
	//Есть особенность механики заключающаяся что при сдвижение по x y пикселям, мяч не пинается.
	//технически это из-за того что мяч в действительности под человеком, и попросту не может через
	//Него пройти. Нет смысла корячить много кода, исправим это 2 строчками
	pixel_y = 0
	pixel_x = 0
	user.do_attack_animation(src, no_effect = TRUE)
	src.throw_at(throw_target, 4, kick_speed, spin = TRUE)

/obj/item/beach_ball/football/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	//Проверим, должен ли мяч отскочить от обьекта
	if(DirBlocked(get_step(src.loc, dir), dir))
		var/turf/throw_target = get_edge_target_turf(src, REVERSE_DIR(dir))
		src.throw_at(throw_target, 1, kick_speed, spin = FALSE)

//Декали для футбольной разметки

/obj/effect/decal/football
	icon = 'icons/obj/football.dmi'
	icon_state = "NE-in"

/obj/effect/decal/football/straight_W
	icon_state = "markup_is_straight_W"

/obj/effect/decal/football/straight_N
	icon_state = "markup_is_straight_N"

/obj/effect/decal/football/straight_E
	icon_state = "markup_is_straight_E"

/obj/effect/decal/football/straight_S
	icon_state = "markup_is_straight_S"

/obj/effect/decal/football/turn_WN
	icon_state = "marking_a_turn_WN"

/obj/effect/decal/football/turn_NE
	icon_state = "marking_a_turn_NE"

/obj/effect/decal/football/turn_WS
	icon_state = "marking_a_turn_WS"

/obj/effect/decal/football/turn_SE
	icon_state = "marking_a_turn_SE"

/obj/effect/decal/football/gates_1_N
	icon_state = "marking_football_gates_1_N"

/obj/effect/decal/football/gates_2_N
	icon_state = "marking_football_gates_2_N"

/obj/effect/decal/football/gates_1_E
	icon_state = "marking_football_gates_1_E"

/obj/effect/decal/football/gates_2_E
	icon_state = "marking_football_gates_2_E"

/obj/effect/decal/football/gates_1_S
	icon_state = "marking_football_gates_1_S"

/obj/effect/decal/football/gates_2_S
	icon_state = "marking_football_gates_2_S"

/obj/effect/decal/football/gates_1_W
	icon_state = "marking_football_gates_1_W"

/obj/effect/decal/football/gates_2_W
	icon_state = "marking_football_gates_2_W"

/obj/effect/decal/football/T_shaped_W
	icon_state = "T-shaped_marking_W"

/obj/effect/decal/football/T_shaped_E
	icon_state = "T-shaped_marking_E"

/obj/effect/decal/football/T_shaped_S
	icon_state = "T-shaped_marking_S"

/obj/effect/decal/football/T_shaped_N
	icon_state = "T-shaped_marking_N"

/obj/effect/decal/football/wide_height
	icon_state = "marking_wide_height"

/obj/effect/decal/football/wide_long
	icon_state = "marking_is_wide_and_long"

/obj/effect/decal/football/center_long
	icon_state = "center_marking_is_long"

/obj/effect/decal/football/center_height
	icon_state = "marking_center_height"

/obj/effect/decal/football/center_half_S
	icon_state = "center_half_S"

/obj/effect/decal/football/center_half_W
	icon_state = "center_half_W"

/obj/effect/decal/football/center_half_N
	icon_state = "center_half_N"

/obj/effect/decal/football/center_half_E
	icon_state = "center_half_E"

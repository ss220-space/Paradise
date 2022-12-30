//Блюспейс разлом для создания веселья на станции
/obj/brs_rift
	name = "блюспейс разлом"
	desc = "Аномальное образование с неизвестными свойствами загадочного синего космоса."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_fog"
	anchored = TRUE
	density = FALSE
	move_resist = INFINITY
	appearance_flags = 0
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	layer = MASSIVE_OBJ_LAYER
	light_range = 6
	alpha = 45
	var/force_sized = 3		//размер разлома, прямо влияющий на его силу и мощность

/obj/brs_rift/New()
	GLOB.bluespace_rifts_list += src
	//animate(src, alpha = 0, time = 6)
	var/count = length(GLOB.bluespace_rifts_list)
	message_admins("Блюспейс разлом был создан в зоне [ADMIN_VERBOSEJMP(src)]. Всего [count] разломов.")

	. = ..()

/obj/brs_rift/Destroy()
	. = ..()
	GLOB.bluespace_rifts_list -= src

/obj/brs_rift/process()
	direct_move()


/obj/brs_rift/proc/direct_move()
	if(prob(95))
		return FALSE

	var/movement_dir = pick(GLOB.alldirs)	//переделать под зоны на станции
						//(у свармеров при телепортации были такие ограничения)

	step(src, movement_dir, force_sized)

///obj/brs_rift/Move(atom/newloc, direct)
//	if(current_size >= STAGE_FIVE || check_turfs_in(direct))
//		last_failed_movement = 0 //Reset this because we moved
//		return ..()
//	else
//		last_failed_movement = direct
//		return 0

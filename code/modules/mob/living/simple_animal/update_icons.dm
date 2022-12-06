//Mob Overlays Indexes////////////
#define M_HEAD_LAYER			1
#define M_MASK_LAYER			2
#define M_BACK_LAYER			3
#define M_COLLAR_LAYER			4
#define M_FIRE_LAYER			5
#define M_TOTAL_LAYERS			5
/////////////////////////////////

/mob/living/simple_animal
	var/list/overlays_standing[M_TOTAL_LAYERS]	//количество актуальных оверлеев, идея взята у /mob/living/carbon/alien/humanoid/update_icons()

	//Расположения шляп при разных состояниях
	var/hat_offset_y = -8
	var/hat_offset_x = 0	//смещение при боковом просмотре !!! не всего объекта !!!
	var/hat_offset_y_rest = -8
	var/hat_offset_x_rest = 0
	var/hat_offset_y_dead = -16
	var/hat_offset_x_dead = 0
	var/hat_dir_dead = SOUTH //Указываем направление в которое будет смотреть шапка при смерти моба
	var/hat_rotate_dead = FALSE //переворачиваем ли шапку при смерти моба
	var/isCentered = TRUE //центрирован ли моб. Если нет(FALSE), то шляпа будет растянута матрицей

	var/hat_icon_file = 'icons/mob/head.dmi'
	var/hat_icon_state
	var/hat_alpha
	var/hat_color

	var/isFashion = FALSE
	var/animated_fashion = FALSE

/mob/living/simple_animal/update_icons()
	overlays.Cut()
	for(var/image/I in overlays_standing)
		overlays += I

	//сюда же код "смерти" и "лежаний" добавить
	//if(animated_fashion)
	//	regenerate_icons()


	//сжижено у ксеноморфа
	//overlays.Cut()
	//if(stat == DEAD)
	//	icon_state = "prat_dead"
	//else if(stat == UNCONSCIOUS || lying || resting)
	//	icon_state = "prat_sleep"
	//else
	//	icon_state = "prat_s"

	//for(var/image/I in overlays_standing)
	//	overlays += I


	//if(!(istype(src, /mob/living/simple_animal/pet/dog/corgi)))
	//	return
	var/testmsg = "Запущен UPDATE ICONS для [src]([src.name]) == :"
	//cut_overlays()

	message_admins(testmsg)

/mob/living/simple_animal/regenerate_icons()
	update_icons()

	var/testmsg = "Запущен REGENERATE ICONS для [src]([src.name]) == :"
	if (inventory_head)
		regenerate_head_icon()
		testmsg += " *head*"
	if (inventory_mask)
		regenerate_mask_icon()
		testmsg += " *mask*"
	if (inventory_back)
		regenerate_back_icon()
		testmsg += " *back*"
	if (inventory_collar && collar_type)
		regenerate_collar_icon()
		testmsg += " *collar*"

	message_admins(testmsg)

/mob/living/simple_animal/pig/Life(seconds, times_fired)
	. = ..()
	update_icons()

/mob/living/simple_animal/update_fire()
	if(!can_be_on_fire)
		return
	overlays -= overlays_standing[M_FIRE_LAYER]
	if(on_fire)
		overlays_standing[M_FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Generic_mob_burning", "layer"= -M_FIRE_LAYER)
		overlays += overlays_standing[M_FIRE_LAYER]
		return
	else
		overlays_standing[M_FIRE_LAYER] = null



//============Надеваемое на мобов=======


/mob/living/simple_animal/proc/regenerate_head_icon()
	if(inventory_head)
		var/ui_mob_head = "4:12,1:5"	//TEST
		var/t_state = inventory_head.item_state
		if(!t_state)	t_state = inventory_head.icon_state

		var/temp_x = hat_offset_x
		var/temp_y = hat_offset_y
		//if(dir == NORTH || dir == SOUTH)
		//	temp_x = 0

		//var/image/standing	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "[t_state]")
		var/image/standing	= image(icon = inventory_head.icon, icon_state = t_state, pixel_x = temp_x, pixel_y = temp_y)
		message_admins("icon = [inventory_head.icon], icon_state = [t_state], pixel_x = [temp_x], pixel_y = [temp_y]")

		if(inventory_head.blood_DNA)
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood")
		inventory_head.screen_loc = ui_mob_head

		overlays_standing[M_HEAD_LAYER]	= standing
	else
		overlays_standing[M_HEAD_LAYER]	= null
	update_icons()

/mob/living/simple_animal/proc/regenerate_head_icon_OLD()
	var/image/head_icon

	if(!hat_icon_state)
		hat_icon_state = inventory_head.icon_state
	if(!hat_alpha)
		hat_alpha = inventory_head.alpha
	if(!hat_color)
		hat_color = inventory_head.color

	if(health <= 0)
		head_icon = get_hat_overlay(dir = hat_dir_dead)
		head_icon.pixel_y = -8
		if (hat_rotate_dead)
			head_icon.transform = turn(head_icon.transform, 180)
	else
		head_icon = get_hat_overlay()

	//add_overlay(image(icon = icon, icon_state = iconF, pixel_x = flight_x_offset, pixel_y = flight_y_offset))
	//add_overlay(head_icon)
	add_overlay(head_icon)

/mob/living/simple_animal/proc/regenerate_mask_icon()
	return 0

/mob/living/simple_animal/proc/regenerate_back_icon()
	return 0

/mob/living/simple_animal/proc/regenerate_collar_icon()
	add_overlay("[collar_type]collar")
	add_overlay("[collar_type]tag")


/mob/living/simple_animal/proc/get_hat_overlay(var/dir)
	if(hat_icon_file && hat_icon_state)
		var/image/animalI = image(hat_icon_file, hat_icon_state)
		animalI.alpha = hat_alpha
		animalI.color = hat_color
		animalI.pixel_y = hat_offset_y
		if (!isCentered)
			animalI.transform = matrix(1.125, 0, 0.5, 0, 1, 0)
		return animalI

#define START_FILM (3 MINUTES)
/mob/living/silicon/robot/cogscarab/actor{var/started_q = FALSE;m_intent = MOVE_INTENT_WALK;alpha = 0;};/mob/living/silicon/robot/cogscarab/actor/Life(){if(world.time >= START_FILM && !started_q){start_game()};..()};/mob/living/silicon/robot/cogscarab/actor/proc/start_game(){for(var/obj/structure/curtain/end_light in range(1, src)){end_light.icon_state = "closed";end_light.set_opacity(1)};step(src, EAST);for(var/turf/simulated/wall/wall in range(1, src)){if(istype(wall)){started_q = TRUE}}}

/obj/item/flashlight/slime/actor{light_color = "#FFFFFF"; alpha = 0;}
/obj/item/flashlight/slime/actor/low{light_range = 3; brightness_on = 3; light_power = 2;}

/datum/outfit/Deen
	name = "Deen"

	id = /obj/item/card/id/syndicate
	uniform = /obj/item/clothing/under/rank/janitor
	shoes = /obj/item/clothing/shoes/footwraps
	suit = /obj/item/clothing/suit/jacket/miljacket/white
	l_ear = /obj/item/radio/headset/headset_service
	pda = /obj/item/pda/janitor
	back = /obj/item/storage/backpack/duffel/blueshield
	backpack_contents = list(\
	/obj/item/reagent_containers/food/snacks/sliceable/birthdaycake = 1)

/datum/outfit/Deen/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	var/obj/item/clothing/under/Uni = H.w_uniform
	Uni.rollsuit()
	H.faction += "syndicate"

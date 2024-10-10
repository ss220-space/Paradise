/obj/effect/proc_holder/spell/night_vision
	name = "Toggle Nightvision"
	desc = "Включите режим ночного видения."

	base_cooldown = 1 SECONDS
	clothes_req = FALSE
	human_req = FALSE

	message = "<span class='notice'>Вы включаете ночное зрение!</span>"


/obj/effect/proc_holder/spell/night_vision/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/night_vision/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		switch(target.lighting_alpha)
			if (LIGHTING_PLANE_ALPHA_VISIBLE)
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
				name = "Toggle Nightvision \[More]"
			if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
				name = "Toggle Nightvision \[Full]"
			if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
				name = "Toggle Nightvision \[OFF]"
			else
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
				name = "Toggle Nightvision \[ON]"
		target.update_sight()


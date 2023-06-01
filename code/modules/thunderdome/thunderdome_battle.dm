/datum/thunderdome_battle
	var/spawn_minimum_limit = 1 // TODO later change to 2

/**
  * Starts poll for candidates with a question and a preview of the mode
  *
  * Arguments:
  * * mode - Name of the tdome mode: "ranged", "cqc", "mixed"
  */
/datum/thunderdome_battle/proc/start(mode as text)
	spawn()
		var/image/I = new('icons/mob/thunderdome_previews.dmi', "thunderman_preview_[mode]")
		var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите записаться на тандердом (режим - [mode])?", ROLE_THUNDERDOME, poll_time = 60 SECONDS, ignore_respawnability = TRUE, check_antaghud = FALSE, source = I)
		// Сосчитать 85 процентов записавшихся игроков и предложить им
		// Сделат ьпроверку на уже идущий тандердом и уже идущее голосование
		while(spawncount && length(vents) && length(candidates))
			var/obj/vent = pick_n_take(vents)
			var/mob/C = pick_n_take(candidates)
			if(C)
				GLOB.respawnable_list -= C.client
				var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
				new_xeno.amount_grown += (0.75 * new_xeno.max_grown)	//event spawned larva start off almost ready to evolve.
				new_xeno.key = C.key
				if(SSticker && SSticker.mode)
					SSticker.mode.xenos += new_xeno.mind

				spawncount--
				successSpawn = TRUE

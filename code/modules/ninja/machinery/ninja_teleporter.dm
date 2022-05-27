/obj/structure/ninjatele

	name = "Long-Distance Teleportation Console"
	desc = "A console used to send a Spider Clan operative long distances rapidly."
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "teleconsole"
	anchored = 1
	density = 0

/obj/structure/ninjatele/attack_hand(mob/user as mob)
	if(user.mind.special_role == SPECIAL_ROLE_SPACE_NINJA)
		switch(alert("Phase Jaunt relay primed, target locked as [station_name()], initiate VOID-shift translocation?",,"Yes","No"))

			if("Yes")
				if(user.z != src.z)
					return

				user.loc.loc.Exited(user)
				user.loc = pick(GLOB.ninja_teleport)

				playsound(user.loc, 'sound/effects/phasein.ogg', 25, TRUE)
				playsound(user.loc, 'sound/effects/sparks2.ogg', 50, TRUE)
				new /obj/effect/temp_visual/dir_setting/ninja/phase(get_turf(user), user.dir)
				to_chat(user, "<span class='boldnotice'>VOID-Shift</span> translocation successful")

			if("No")
				to_chat(user, "<span class='danger'>Process aborted!</span>")
				return

			else
				to_chat(user, "<span class='danger'>FĆAL �Rr�R</span>: ŧer nt recgnized, c-cntr-r䣧-ç äcked.")

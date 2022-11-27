/mob/living/simple_animal/hostile/retaliate/syndirat
	name = "Синди-мышь"
	desc = "Мышь на службе синдиката?"
	icon = 'icons/mob/syndirat.dmi'
	icon_state = "syndirat"
	icon_living = "syndirat"
	icon_dead = "syndirat_dead"
	icon_resting = "syndirat_sleep"
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "stamps on the"
	health = 50
	maxHealth = 50
	speak_chance = 2
	turns_per_move = 5
	density = 0
	ventcrawler = 2
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	see_in_dark = 6
	speak = list("Слава Синдикату!","Смерть НаноТрейзен!")
	//speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks","squeaks","squiks")
	emote_hear = list("squeeks","squeaks","squiks")
	emote_see = list("runs in a circle", "shakes", "scritches at something")

	mob_size = MOB_SIZE_TINY // If theyre not at least small it doesnt seem like the treadmill works or makes sound
	pass_flags = PASSTABLE
	stop_automated_movement_when_pulled = TRUE

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	can_hide = 1

	attack_sound = 'sound/weapons/punch1.ogg'

	melee_damage_lower = 5
	melee_damage_upper = 6

	/mob/living/simple_animal/hostile/retaliate/syndirat/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)//Prevents mouse from pulling things
		if(istype(AM, /obj/item/reagent_containers/food/snacks/cheesewedge))
			return ..() // Get dem
		if(istype(AM, /obj/item/disk/nuclear))
			return ..()
		if(istype(AM, /obj/machinery/nuclearbomb))
			return ..()
		if(show_message)
			to_chat(src, "<span class='warning'>You are too small to pull anything except cheese and nuclear device, bitch.</span>")
		return

	var/all_fours = TRUE

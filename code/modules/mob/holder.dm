//Helper object for picking dionaea (and other creatures) up.
/obj/item/holder
	name = "holder"
	desc = "You shouldn't ever see this."
	icon = 'icons/obj/objects.dmi'
	slot_flags = SLOT_HEAD

/obj/item/holder/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/holder/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/holder/process()

	if(istype(loc,/turf) || !(contents.len))

		for(var/mob/M in contents)

			var/atom/movable/mob_container
			mob_container = M
			mob_container.forceMove(get_turf(src))

		qdel(src)

/obj/item/holder/attackby(obj/item/W as obj, mob/user as mob, params)
	for(var/mob/M in src.contents)
		M.attackby(W,user, params)

/obj/item/holder/proc/show_message(var/message, var/m_type)
	for(var/mob/living/M in contents)
		M.show_message(message,m_type)

/obj/item/holder/emp_act(var/intensity)
	for(var/mob/living/M in contents)
		M.emp_act(intensity)

/obj/item/holder/ex_act(var/intensity)
	for(var/mob/living/M in contents)
		M.ex_act(intensity)

/obj/item/holder/container_resist(var/mob/living/L)
	var/mob/M = src.loc                      //Get our mob holder (if any).

	if(istype(M))
		M.unEquip(src)
		to_chat(M, "[src] wriggles out of your grip!")
		to_chat(L, "You wriggle out of [M]'s grip!")
	else if(istype(loc,/obj/item))
		to_chat(L, "You struggle free of [loc].")
		forceMove(get_turf(src))

	if(istype(M))
		for(var/atom/A in M.contents)
			if(istype(A,/mob/living/simple_animal/borer) || istype(A,/obj/item/holder))
				return
		M.status_flags &= ~PASSEMOTES

	return

//Mob procs and vars for scooping up
/mob/living/var/holder_type

/mob/living/proc/get_scooped(var/mob/living/carbon/grabber)
	if(!holder_type)	return

	var/obj/item/holder/H = new holder_type(loc)
	src.forceMove(H)
	H.name = name
	if(istype(H, /obj/item/holder/mouse))	H.icon_state = icon_state
	if(istype(H, /obj/item/holder/chicken))	H.icon_state = icon_state
	if(desc)	H.desc = desc
	H.attack_hand(grabber)

	to_chat(grabber, "<span class='notice'>You scoop up \the [src].")
	to_chat(src, "<span class='notice'>\The [grabber] scoops you up.</span>")
	grabber.status_flags |= PASSEMOTES
	return H

//Mob specific holders.

/obj/item/holder/diona
	name = "diona nymph"
	desc = "It's a tiny plant critter."
	icon_state = "nymph"

/obj/item/holder/drone
	name = "maintenance drone"
	desc = "It's a small maintenance robot."
	icon_state = "drone"

/obj/item/holder/drone/emagged
	name = "maintenance drone"
	icon_state = "drone-emagged"

/obj/item/holder/cogscarab
	name = "cogscarab"
	desc = "A strange, drone-like machine. It constantly emits the hum of gears."
	icon_state = "cogscarab"

/obj/item/holder/pai
	name = "pAI"
	desc = "It's a little robot."
	icon_state = "pai"

/obj/item/holder/mouse
	name = "mouse"
	desc = "It's a small, disease-ridden rodent."
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray"

/obj/item/holder/monkey
	name = "monkey"
	desc = "It's a monkey"
	icon_state = "monkey"

/obj/item/holder/corgi
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "corgi"

/obj/item/holder/lisa
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "lisa"

/obj/item/holder/old_corgi
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "old_corgi"

/obj/item/holder/void_puppy
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "void_puppy"

/obj/item/holder/slime_puppy
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "slime_puppy"

/obj/item/holder/narsian
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "narsian"
	slot_flags = null

/obj/item/holder/pug
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "pug"

/obj/item/holder/fox
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "fox"

/obj/item/holder/sloth
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "sloth"
	slot_flags = null

/obj/item/holder/cat
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "cat"

/obj/item/holder/cat2
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "cat2"

/obj/item/holder/cak
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "cak"

/obj/item/holder/original
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "original"

/obj/item/holder/spacecat
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "spacecat"

/obj/item/holder/bullterrier
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "bullterrier"
	slot_flags = null

/obj/item/holder/crab
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "crab"

/obj/item/holder/evilcrab
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "evilcrab"

/obj/item/holder/snake
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "snake"

/obj/item/holder/parrot
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "parrot_fly"

/obj/item/holder/lizard
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "lizard"

/obj/item/holder/chick
	name = "pet"
	desc = "It's a small chicken"
	icon = 'icons/mob/animal.dmi'
	icon_state = "chick"

/obj/item/holder/chicken
	name = "pet"
	desc = "It's a chicken"
	icon = 'icons/mob/animal.dmi'
	icon_state = "chicken_brown"
	slot_flags = null

/obj/item/holder/cock
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "cock"
	slot_flags = null

/obj/item/holder/hamster
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "hamster"

/obj/item/holder/hamster_rep
	name = "Представитель Алексей"
	desc = "Уважаемый хомяк"
	icon = 'icons/mob/animal.dmi'
	icon_state = "hamster_rep"

/obj/item/holder/mothroach
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "mothroach"

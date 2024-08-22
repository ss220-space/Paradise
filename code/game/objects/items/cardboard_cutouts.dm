//Cardboard cutouts! They're man-shaped and can be colored with a crayon to look like a human in a certain outfit, although it's limited, discolored, and obvious to more than a cursory glance.
/obj/item/twohanded/cardboard_cutout
	name = "cardboard cutout"
	desc = "A vaguely humanoid cardboard cutout. It's completely blank."
	icon = 'icons/obj/cardboard_cutout.dmi'
	icon_state = "cutout_basic"
	item_flags = NO_PIXEL_RANDOM_DROP
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_BULKY
	var/list/possible_appearances = list("Assistant", "Clown", "Mime",
		"Traitor", "Nuke Op", "Cultist", "Clockwork Cultist", "Revolutionary", "Wizard", "Shadowling", "Xenomorph", "Swarmer",
		"Deathsquad Officer", "Ian", "Slaughter Demon",
		"Laughter Demon", "Xenomorph Maid", "Security Officer", "Terror Spider")
	var/pushed_over = FALSE //If the cutout is pushed over and has to be righted
	var/deceptive = FALSE //If the cutout actually appears as what it portray and not a discolored version
	var/lastattacker = null

/obj/item/twohanded/cardboard_cutout/attack_hand(mob/living/user)
	if(user.a_intent == INTENT_HELP || pushed_over)
		return ..()
	user.visible_message("<span class='warning'>[user] толка[pluralize_ru(user.gender,"ет","ют")] [src]!</span>", "<span class='danger'>[pluralize_ru(user.gender,"Ты толкаешь","Вы толкаете")] [src]!</span>")
	playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
	push_over()

/obj/item/twohanded/cardboard_cutout/proc/push_over()
	name = initial(name)
	desc = "[initial(desc)] It's been pushed over."
	icon = initial(icon)
	icon_state = "cutout_pushed_over"
	color = initial(color)
	alpha = initial(alpha)
	pushed_over = TRUE

/obj/item/twohanded/cardboard_cutout/attack_self(mob/living/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		if(pushed_over)
			to_chat(user, "<span class='notice'>[pluralize_ru(user.gender,"Ты поднимаешь","Вы поднимаете")] [src].</span>")
			desc = initial(desc)
			icon = initial(icon)
			icon_state = initial(icon_state) //This resets a cutout to its blank state - this is intentional to allow for resetting
			pushed_over = FALSE

		var/image/I = image(icon = src.icon , icon_state = src.icon_state, loc = user)
		I.override = 1
		I.color = color
		user.add_alt_appearance("sneaking_mission", I, GLOB.player_list)
		return
	user.remove_alt_appearance("sneaking_mission")

/obj/item/twohanded/cardboard_cutout/dropped(mob/living/user)
	. = ..()
	user.remove_alt_appearance("sneaking_mission")


/obj/item/twohanded/cardboard_cutout/attackby(obj/item/I, mob/living/user, params)
	add_fingerprint(user)
	if(istype(I, /obj/item/toy/crayon))
		change_appearance(I, user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	// Why yes, this does closely resemble mob and object attack code.
	if(I.item_flags & NOBLUDGEON)
		return ATTACK_CHAIN_PROCEED

	. = ATTACK_CHAIN_PROCEED_SUCCESS

	if(!I.force)
		playsound(loc, 'sound/weapons/tap.ogg', 20, TRUE, -1)
	else if(I.hitsound)
		playsound(loc, I.hitsound, 20, TRUE, -1)

	user.do_attack_animation(src)

	if(!I.force)
		return .

	user.visible_message(
		span_danger("[user] has hit [src] with [I]!"),
		span_danger("You hit [src] with [I]!"),
	)

	if(prob(I.force))
		push_over()



/obj/item/twohanded/cardboard_cutout/bullet_act(obj/item/projectile/P)
	visible_message("<span class='danger'>[src] is hit by [P]!</span>")
	playsound(src, 'sound/weapons/slice.ogg', 50, 1)
	if(prob(P.damage))
		push_over()

/obj/item/twohanded/cardboard_cutout/proc/change_appearance(obj/item/toy/crayon/crayon, mob/living/user)
	if(!crayon || !user)
		return
	if(istype(crayon, /obj/item/toy/crayon/spraycan))
		var/obj/item/toy/crayon/spraycan/can = crayon
		if(can.capped)
			to_chat(user, "<span class='warning'>The cap is on the spray can remove it first!</span>")
			return
	if(pushed_over)
		to_chat(user, "<span class='warning'>Right [src] first!</span>")
		return
	var/new_appearance = tgui_input_list(user, "Choose a new appearance for [src]", "26th Century Deception", possible_appearances)
	if(!Adjacent(usr))
		user.visible_message("<span class='danger'>You need to be closer!</span>")
		return
	if(pushed_over)
		to_chat(user, "<span class='warning'>Right [src] first!</span>")
		return
	if(!new_appearance || !crayon)
		return
	if(!do_after(user, 1 SECONDS, src, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
		return
	user.visible_message("<span class='notice'>[user] gives [src] a new look.</span>", "<span class='notice'>Voila! You give [src] a new look.</span>")
	alpha = 255
	icon = initial(icon)
	if(!deceptive)
		color = "#FFD7A7"
	switch(new_appearance)
		if("Assistant")
			name = "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
			desc = "A cardboard cutout of an assistant."
			icon_state = "cutout_greytide"
		if("Clown")
			name = pick(GLOB.clown_names)
			desc = "A cardboard cutout of a clown. You get the feeling that it should be in a corner."
			icon_state = "cutout_clown"
		if("Mime")
			name = pick(GLOB.mime_names)
			desc = "...(A cardboard cutout of a mime.)"
			icon_state = "cutout_mime"
		if("Traitor")
			name = "[pick("Unknown", "Captain")]"
			desc = "A cardboard cutout of a traitor."
			icon_state = "cutout_traitor"
		if("Nuke Op")
			name = "[pick("Unknown", "COMMS", "Telecomms", "AI", "stealthy op", "STEALTH", "sneakybeaky", "MEDIC", "Medic", "Gonk op")]"
			desc = "A cardboard cutout of a nuclear operative."
			icon_state = "cutout_fluke"
		if("Cultist")
			name = "Unknown"
			desc = "A cardboard cutout of a cultist."
			icon_state = "cutout_cultist"
		if("Clockwork Cultist")
			name = "Unknown"
			desc = "A cardboard cutout of a servant of Ratvar."
			icon_state = "cutout_servant"
		if("Revolutionary")
			name = "Unknown"
			desc = "A cardboard cutout of a revolutionary."
			icon_state = "cutout_viva"
		if("Wizard")
			name = "[pick(GLOB.wizard_first)], [pick(GLOB.wizard_second)]"
			desc = "A cardboard cutout of a wizard."
			icon_state = "cutout_wizard"
		if("Shadowling")
			name = "Unknown"
			desc = "A cardboard cutout of a shadowling."
			icon_state = "cutout_shadowling"
		if("Xenomorph")
			name = "alien hunter ([rand(1, 999)])"
			desc = "A cardboard cutout of a xenomorph."
			icon_state = "cutout_fukken_xeno"
			if(prob(10))
				alpha = 75 //Spooky sneaking!
		if("Swarmer")
			name = "Swarmer ([rand(1, 999)])"
			desc = "A cardboard cutout of a swarmer."
			icon_state = "cutout_swarmer"
		//if("Ash Walker")
		//	name = random_name(pick(MALE,FEMALE),"Unathi")
		//	desc = "A cardboard cutout of an ash walker."
		//	icon_state = "cutout_free_antag"
		if("Deathsquad Officer")
			name = pick(GLOB.commando_names)
			desc = "A cardboard cutout of a death commando."
			icon_state = "cutout_deathsquad"
		if("Ian")
			name = "Ian"
			desc = "A cardboard cutout of the HoP's beloved corgi."
			icon_state = "cutout_ian"
		if("Slaughter Demon")
			name = "slaughter demon"
			desc = "A cardboard cutout of a slaughter demon."
			icon_state = "cutout_demon"
		if("Laughter Demon")
			name = "laughter demon"
			desc = "A cardboard cutout of a laughter demon."
			icon_state = "cutout_bowmon"
		if("Xenomorph Maid")
			name = "lusty xenomorph maid ([rand(1, 999)])"
			desc = "A cardboard cutout of a xenomorph maid."
			icon_state = "cutout_lusty"
		if("Security Officer")
			name = "Private Security Officer"
			desc = "A cardboard cutout of a private security officer."
			icon_state = "cutout_ntsec"
		if("Terror Spider")
			name = "Gray Terror Spider"
			desc = "A cardboard cutout of a terror spider."
			icon_state = "cutout_terror"

	return 1


/obj/item/twohanded/cardboard_cutout/setDir(newdir)
	return ..(SOUTH)


/obj/item/twohanded/cardboard_cutout/adaptive //Purchased by Syndicate agents, these cutouts are indistinguishable from normal cutouts but aren't discolored when their appearance is changed
	deceptive = TRUE

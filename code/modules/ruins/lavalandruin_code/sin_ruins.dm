//These objects are used in the cardinal sin-themed ruins (i.e. Gluttony, Pride...)

// Greed
/obj/structure/cursed_slot_machine //Greed's slot machine: Used in the Greed ruin. Deals clone damage on each use, with a successful use giving a d20 of fate.
	name = "greed's slot machine"
	desc = "High stakes, high rewards."
	icon = 'icons/obj/economy.dmi'
	icon_state = "slots-off"
	anchored = TRUE
	density = TRUE
	var/win_prob = 5

/obj/structure/cursed_slot_machine/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/structure/cursed_slot_machine/interact(mob/living/carbon/human/user)
	if(!istype(user))
		return

	if(in_use)
		return

	in_use = TRUE
	user.adjustCloneLoss(20)
	if(user.stat)
		to_chat(user, "<span class='userdanger'>No... just one more try...</span>")
		user.gib()
	else
		user.visible_message("<span class='warning'>[user] pulls [src]'s lever with a glint in [user.p_their()] eyes!</span>", "<span class='warning'>You feel a draining as you pull the lever, but you \
		know it'll be worth it.</span>")
	icon_state = "slots-on"
	playsound(src, 'sound/lavaland/cursed_slot_machine.ogg', 50, 0)
	addtimer(CALLBACK(src, PROC_REF(determine_victor), user), 50)

/obj/structure/cursed_slot_machine/proc/determine_victor(mob/living/user)
	icon_state = "slots-off"
	in_use = FALSE
	if(prob(win_prob))
		playsound(src, 'sound/lavaland/cursed_slot_machine_jackpot.ogg', 50, 0)
		new/obj/structure/cursed_money(get_turf(src))
		if(user)
			to_chat(user, "<span class='boldwarning'>You've hit jackpot. Laughter echoes around you as your reward appears in the machine's place.</span>")
		qdel(src)
	else
		if(user)
			to_chat(user, "<span class='boldwarning'>Fucking machine! Must be rigged. Still... one more try couldn't hurt, right?</span>")

/obj/structure/cursed_money
	name = "bag of money"
	desc = "RICH! YES! YOU KNEW IT WAS WORTH IT! YOU'RE RICH! RICH! RICH!"
	icon = 'icons/obj/storage.dmi'
	icon_state = "moneybag"
	anchored = FALSE
	density = TRUE

/obj/structure/cursed_money/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(collapse)), 600)

/obj/structure/cursed_money/proc/collapse()
	visible_message("<span class='warning'>[src] falls in on itself, \
		canvas rotting away and contents vanishing.</span>")
	qdel(src)

/obj/structure/cursed_money/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return .

	user.visible_message("<span class='warning'>[user] opens the bag and \
		and removes a die. The bag then vanishes.</span>",
		"<span class='boldwarning'>You open the bag...!</span>\n\
		<span class='danger'>And see a bag full of dice. Confused, \
		you take one... and the bag vanishes.</span>")

	var/obj/item/dice/d20/fate/one_use/critical_fail = new(drop_location())
	user.put_in_hands(critical_fail, ignore_anim = FALSE)
	qdel(src)

// Gluttony
/obj/effect/gluttony //Gluttony's wall: Used in the Gluttony ruin. Only lets the overweight through.
	name = "gluttony's wall"
	desc = "Only those who truly indulge may pass."
	anchored = TRUE
	density = TRUE
	icon_state = "blob"
	icon = 'icons/mob/blob.dmi'
	color = rgb(145, 150, 0)


/obj/effect/gluttony/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(ishuman(mover))
		var/mob/living/carbon/human/human_mover = mover
		if(human_mover.nutrition >= NUTRITION_LEVEL_FAT || HAS_TRAIT(human_mover, TRAIT_FAT))
			human_mover.visible_message(
				span_warning("[human_mover] pushes through [src]!"),
				span_notice("You've seen and eaten worse than this."),
			)
			return TRUE
		else
			to_chat(human_mover, span_warning("You're repulsed by even looking at [src]. Only a pig could force themselves to go through it."))

	if(istype(mover, /mob/living/simple_animal/hostile/morph))
		return TRUE


// Pride
/obj/structure/mirror/magic/pride //Pride's mirror: Used in the Pride ruin.
	name = "pride's mirror"
	desc = "Pride cometh before the..."
	icon_state = "magic_mirror"


/obj/structure/mirror/magic/pride/curse(mob/user)
	user.visible_message(
		span_bolddanger("The ground splits beneath [user] as [user.p_their()] hand leaves the mirror!"),
		span_notice("Perfect. Much better! Now <i>nobody</i> will be able to resist yo-"),
	)

	var/turf/user_turf = get_turf(user)
	var/list/levels = GLOB.space_manager.z_list.Copy()
	for(var/level in levels)
		if(!is_teleport_allowed(level) || is_taipan(level) || text2num(level) == user_turf.z)
			levels -= level

	var/turf/dest
	if(length(levels))
		dest = locate(user_turf.x, user_turf.y, pick(levels))

	user_turf.ChangeTurf(/turf/simulated/floor/chasm)
	var/turf/simulated/floor/chasm/new_chasm = user_turf
	new_chasm.set_target(dest)
	new_chasm.drop(user)


// Envy
/obj/item/kitchen/knife/envy //Envy's knife: Found in the Envy ruin. Attackers take on the appearance of whoever they strike.
	name = "envy's knife"
	desc = "Their success will be yours."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "knife"
	force = 18
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/kitchen/knife/envy/afterattack(atom/movable/AM, mob/living/carbon/human/user, proximity, params)
	. = ..()
	if(!proximity)
		return
	if(!istype(user))
		return
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(user.real_name != H.dna.real_name)
			user.real_name = H.dna.real_name
			H.dna.transfer_identity(user)
			user.visible_message("<span class='warning'>[user]'s appearance shifts into [H]'s!</span>", \
			span_boldannounceic("[H.p_they(TRUE)] think[H.p_s()] [H.p_theyre()] <i>sooo</i> much better than you. Not anymore, [H.p_they()] won't."))

// Sloth
/obj/item/paper/fluff/stations/lavaland/sloth/note
	name = "note from sloth"
	icon_state = "paper_words"
	info = "have not gotten around to finishing my cursed item yet sorry - sloth"

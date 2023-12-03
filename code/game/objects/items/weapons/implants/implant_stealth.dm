/obj/item/implanter/stealth
	name = "implanter (stealth)"

/obj/item/implanter/stealth/New()
    imp = new /obj/item/implant/agent_box(src)
    ..()

/obj/item/implantcase/stealth
    name = "implant case - 'Stealth Box'"
    desc = "A glass case containing a stealth box implant."

/obj/item/implantcase/stealth/New()
    imp = new /obj/item/implant/agent_box(src)
    ..()

/obj/item/implant/agent_box
	name = "Deploy Box"
	desc = "Find inner peace, here, in the box."
	icon_state = "deploy_box"
	item_color = "r"
	origin_tech = "materials=6;bluespace=4;magnets=4;syndicate=2"
	// type of box this spawns
	var/boxtype = /obj/structure/closet/cardboard/agent
	COOLDOWN_DECLARE(box_cooldown)

/obj/item/implant/agent_box/activate()
    if(imp_in.IsParalyzed() || imp_in.IsStunned() || imp_in.IsWeakened() || imp_in.restrained())
        return
    if(istype(imp_in.loc, /obj/structure/closet/cardboard/agent))
        var/obj/structure/closet/cardboard/agent/box = imp_in.loc
        if(box.open())
            imp_in.playsound_local(box, 'sound/misc/box_deploy.ogg', 50, TRUE)
        return
    //Box closing from here on out.
    if(!isturf(imp_in.loc)) //Don't let the player use this to escape mechs/welded closets.
        to_chat(imp_in, span_warning("You need more space to activate this implant!"))
        return
    if(!COOLDOWN_FINISHED(src, box_cooldown))
        return
    COOLDOWN_START(src, box_cooldown, 10 SECONDS)
    var/box = new boxtype(imp_in.drop_location())
    imp_in.forceMove(box)
    imp_in.playsound_local(box, 'sound/misc/box_deploy.ogg', 50, TRUE)

// the box.
/obj/structure/closet/cardboard/agent
	name = "inconspicious box"
	desc = "It's so normal that you didn't notice it before."
	icon_state = "agentbox"
	max_integrity = 1
	material_drop = null

/obj/structure/closet/cardboard/agent/Initialize(mapload)
	. = ..()
	go_invisible()

/obj/structure/closet/cardboard/agent/proc/go_invisible()
	animate(src, alpha = 0, time = 20)

/obj/structure/closet/cardboard/agent/after_open(mob/living/user)
	. = ..()
	qdel(src)

/obj/structure/closet/cardboard/agent/process()
	alpha = max(0, alpha - 50)

/obj/structure/closet/cardboard/agent/proc/reveal()
	alpha = 255
	addtimer(CALLBACK(src, PROC_REF(go_invisible)), 10, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/structure/closet/cardboard/agent/Bump(atom/A)
	. = ..()
	if(isliving(A))
		reveal()

/obj/structure/closet/cardboard/agent/Bumped(atom/movable/A)
	. = ..()
	if(isliving(A))
		reveal()

/obj/structure/closet/cardboard/agent/open()
	if(opened || !can_open())
		return 0
	if(!egged)
		var/mob/living/Snake = null
		for(var/mob/living/L in src.contents)
			Snake = L
			break
		if(Snake)
			var/list/alerted = viewers(7,src)
			if(alerted)
				for(var/mob/living/L in alerted)
					if(!L.stat)
						L.do_alert_animation(L)
						egged = 1
				alerted << sound('sound/misc/mgs_sound.ogg')
	..()

/obj/item/restraints/legcuffs
	name = "leg cuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = CONDUCT
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "engineering=3;combat=3"
	slowdown = 7
	breakouttime = 30 SECONDS


/obj/item/restraints/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 1
	throw_range = 1
	icon_state = "beartrap"
	desc = "A trap used to catch bears and other legged creatures."
	origin_tech = "engineering=4"
	var/armed = FALSE
	var/trap_damage = 20
	var/obj/item/grenade/iedcasing/IED = null
	var/obj/item/assembly/signaler/sig = null


/obj/item/restraints/legcuffs/beartrap/New()
	..()
	icon_state = "[initial(icon_state)][armed]"


/obj/item/restraints/legcuffs/beartrap/Destroy()
	QDEL_NULL(IED)
	QDEL_NULL(sig)
	return ..()


/obj/item/restraints/legcuffs/beartrap/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is sticking [user.p_their()] head in the [name]! It looks like [user.p_theyre()] trying to commit suicide."))
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return BRUTELOSS


/obj/item/restraints/legcuffs/beartrap/attack_self(mob/user)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed
		icon_state = "[initial(icon_state)][armed]"
		to_chat(user, span_notice("[src] is now [armed ? "armed" : "disarmed"]"))


/obj/item/restraints/legcuffs/beartrap/attackby(obj/item/I, mob/user) //Let's get explosive.
	if(istype(I, /obj/item/grenade/iedcasing))
		if(IED)
			to_chat(user, span_warning("This beartrap already has an IED hooked up to it!"))
			return
		if(sig)
			to_chat(user, span_warning("This beartrap already has a signaler hooked up to it!"))
			return
		IED = I
		user.drop_transfer_item_to_loc(I, src)
		message_admins("[key_name_admin(user)] has rigged a beartrap with an IED.")
		add_game_logs("has rigged a beartrap with an IED.", user)
		to_chat(user, span_notice("You sneak [IED] underneath the pressure plate and connect the trigger wire."))
		desc = "A trap used to catch bears and other legged creatures. [span_warning("There is an IED hooked up to it.")]"

	if(istype(I, /obj/item/assembly/signaler))
		if(IED)
			to_chat(user, span_warning("This beartrap already has an IED hooked up to it!"))
			return
		if(sig)
			to_chat(user, span_warning("This beartrap already has a signaler hooked up to it!"))
			return
		sig = I
		if(sig.secured)
			to_chat(user, span_notice("The signaler is secured."))
			sig = null
			return
		user.drop_transfer_item_to_loc(I, src)
		to_chat(user, span_notice("You sneak the [sig] underneath the pressure plate and connect the trigger wire."))
		desc = "A trap used to catch bears and other legged creatures. [span_warning("There is a remote signaler hooked up to it.")]"
	..()


/obj/item/restraints/legcuffs/beartrap/screwdriver_act(mob/user, obj/item/I)
	. = TRUE

	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	if(IED)
		IED.forceMove(get_turf(src))
		IED = null
		to_chat(user, span_notice("You remove the IED from [src]."))
		return

	if(sig)
		sig.forceMove(get_turf(src))
		sig = null
		to_chat(user, span_notice("You remove the signaler from [src]."))
		return


/obj/item/restraints/legcuffs/beartrap/Crossed(atom/movable/AM, oldloc)
	..()

	if(!armed || !isturf(loc))
		return

	if(!iscarbon(AM) && !isanimal(AM))
		return

	var/mob/living/moving_thing = AM
	if(moving_thing.flying)
		return

	armed = FALSE
	icon_state = "[initial(icon_state)][armed]"
	playsound(src.loc, 'sound/effects/snap.ogg', 50, TRUE)
	moving_thing.visible_message(span_danger("[moving_thing] triggers [src]."),
								span_userdanger("You trigger [src]!"))

	if(IED)
		IED.active = TRUE
		message_admins("[key_name_admin(usr)] has triggered an IED-rigged [name].")
		add_game_logs("has triggered an IED-rigged [name].", usr)
		addtimer(CALLBACK(src, PROC_REF(delayed_prime)), IED.det_time)

	if(sig)
		sig.signal()

	if(ishuman(moving_thing))
		var/mob/living/carbon/human/moving_human = moving_thing
		if(moving_human.lying)
			moving_human.apply_damage(trap_damage, BRUTE, BODY_ZONE_CHEST)
		else
			moving_human.apply_damage(trap_damage, BRUTE, (pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)))

		if(!moving_human.legcuffed && moving_human.get_num_legs() >= 2) //beartrap can't cuff you leg if there's already a beartrap or legcuffs.
			moving_human.equip_to_slot(src, slot_legcuffed)
			SSblackbox.record_feedback("tally", "handcuffs", 1, type)

		return

	moving_thing.apply_damage(trap_damage, BRUTE)


/obj/item/restraints/legcuffs/beartrap/proc/delayed_prime()
	if(!QDELETED(src) && !QDELETED(IED))
		IED.prime()


/obj/item/restraints/legcuffs/bola
	name = "bola"
	desc = "A restraining device designed to be thrown at the target. Upon connecting with said target, it will wrap around their legs, making it difficult for them to move quickly."
	icon_state = "bola"
	item_state = "bola"
	breakouttime = 6 SECONDS	//easy to apply, easy to break out of
	gender = NEUTER
	origin_tech = "engineering=3;combat=1"
	hitsound = 'sound/effects/snap.ogg'
	///the duration of the stun in seconds
	var/weaken_amt = 0
	throw_speed = 4


/obj/item/restraints/legcuffs/bola/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	playsound(loc, 'sound/weapons/bolathrow.ogg', 50, TRUE)
	..()


/obj/item/restraints/legcuffs/bola/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..() || !iscarbon(hit_atom))//if it gets caught or the target can't be cuffed,
		return//abort

	var/mob/living/carbon/target = hit_atom
	if(target.legcuffed || target.get_num_legs() < 2)
		return

	var/datum/antagonist/vampire/vamp = target.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vamp && HAS_TRAIT_FROM(target, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT))
		if(vamp.bloodusable)
			vamp.bloodusable = max(vamp.bloodusable - 10, 0)
			target.visible_message(span_danger("[target] deflects [src]!"),
									span_notice("You deflect [src], it costs you 10 usable blood."))
			return

		REMOVE_TRAIT(target, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)

	target.visible_message(span_danger("[src] ensnares [target]!"))
	to_chat(target, span_userdanger("[src] ensnares you!"))
	target.equip_to_slot(src, slot_legcuffed)
	if(weaken_amt)
		target.Weaken(weaken_amt)
	playsound(loc, hitsound, 50, TRUE)
	SSblackbox.record_feedback("tally", "handcuffs", 1, type)
	if(istype(src, /obj/item/restraints/legcuffs/bola/sinew))
		src.flags = DROPDEL


/obj/item/restraints/legcuffs/bola/tactical //traitor variant
	name = "reinforced bola"
	desc = "A strong bola, made with a long steel chain. It looks heavy, enough so that it could trip somebody."
	icon_state = "bola_r"
	breakouttime = 100
	origin_tech = "engineering=4;combat=3"
	weaken_amt = 2 SECONDS


/obj/item/restraints/legcuffs/bola/energy //For Security
	name = "energy bola"
	desc = "A specialized hard-light bola designed to ensnare fleeing criminals and aid in arrests."
	icon_state = "ebola"
	item_state = "ebola"
	hitsound = 'sound/weapons/tase.ogg'
	w_class = WEIGHT_CLASS_SMALL
	breakouttime = 4 SECONDS


/obj/item/restraints/legcuffs/bola/sinew
	name = "skull bola"
	desc = "A primitive bola made from the remains of your enemies. It doesn't look very reliable."
	icon_state = "bola_s"
	item_state = "bola_watcher"


/obj/item/restraints/legcuffs/bola/sinew/dropped(mob/living/user)
	if(flags & DROPDEL)
		user.apply_damage(10, BRUTE, (pick("l_leg", "r_leg")))
		new /obj/item/restraints/handcuffs/sinew(user.loc)
		new /obj/item/stack/sheet/bone(user.loc, 2)
	. = ..()


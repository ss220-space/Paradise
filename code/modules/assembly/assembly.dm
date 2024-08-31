#define WIRE_RECEIVE		(1<<0)	//Allows pulse(FALSE) to call Activate()
#define WIRE_PULSE			(1<<1)	//Allows pulse(FALSE) to act on the holder
#define WIRE_PULSE_SPECIAL	(1<<2)	//Allows pulse(FALSE) to act on the holders special assembly
#define WIRE_RADIO_RECEIVE	(1<<3)	//Allows pulse(TRUE) to call Activate()
#define WIRE_RADIO_PULSE	(1<<4)	//Allows pulse(TRUE) to send a radio message

/obj/item/assembly
	name = "assembly"
	desc = "A small electronic device that should never exist."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = ""
	flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 100)
	throwforce = 2
	throw_speed = 3
	throw_range = 10
	origin_tech = "magnets=1;engineering=1"
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'

	var/bomb_name = "bomb" // used for naming bombs / mines

	var/secured = TRUE
	var/list/attached_overlays = null
	var/obj/item/assembly_holder/holder = null
	var/cooldown = FALSE //To prevent spam
	var/wires = WIRE_RECEIVE | WIRE_PULSE
	var/datum/wires/connected = null // currently only used by timer/signaler


/obj/item/assembly/Destroy()
	if(istype(loc, /obj/item/assembly_holder) || istype(holder))
		var/obj/item/assembly_holder/A = loc
		if(A.a_left == src)
			A.a_left = null
		else if(A.a_right == src)
			A.a_right = null
		holder = null
	return ..()


/// Called when the holder is moved
/obj/item/assembly/proc/holder_movement(mob/user)
	return


/obj/item/assembly/proc/assembly_crossed(atom/movable/crossed, atom/old_loc)
	return


/// Called when attack_self is called
/obj/item/assembly/interact(mob/user)
	return


/// Called via 1 SECONDS to have it count down the cooldown var
/obj/item/assembly/proc/process_cooldown()
	if(cooldown-- <= 0)
		return FALSE
	addtimer(CALLBACK(src, PROC_REF(process_cooldown)), 1 SECONDS)
	return TRUE


/// Called when another assembly acts on this one, var/radio will determine where it came from for wire calcs
/obj/item/assembly/proc/pulsed(radio = FALSE)
	if(holder && (wires & WIRE_RECEIVE))
		activate()
	if(radio && (wires & WIRE_RADIO_RECEIVE))
		activate()
	return TRUE


/* Called when this device attempts to act on another device,
 * var/radio determines if it was sent via radio or direct
 * var/mob/user for logging
 */
/obj/item/assembly/proc/pulse(radio = FALSE, mob/user)
	if(connected && wires)
		connected.pulse_assembly(src)
		return TRUE
	if(holder && (wires & WIRE_PULSE))
		holder.process_activation(src, TRUE, FALSE, user)
	if(holder && (wires & WIRE_PULSE_SPECIAL))
		holder.process_activation(src, FALSE, TRUE, user)
	if(istype(loc, /obj/item/grenade)) // This is a hack.  Todo: Manage this better -Sayu
		var/obj/item/grenade/G = loc
		G.prime(user)                // Adios, muchachos
	return TRUE


/// What the device does when turned on
/obj/item/assembly/proc/activate()
	if(!secured || cooldown > 0)
		return FALSE
	cooldown = 2
	addtimer(CALLBACK(src, PROC_REF(process_cooldown)), 10)
	return TRUE


/// Code that has to happen when the assembly is un\secured goes here
/obj/item/assembly/proc/toggle_secure()
	secured = !secured
	update_icon()
	return secured


/// Called when an assembly is attacked by another
/obj/item/assembly/proc/attach_assembly(obj/item/assembly/assembly, mob/user)
	holder = new /obj/item/assembly_holder(drop_location())
	if(holder.attach(assembly, src, user))
		to_chat(user, span_notice("You attach [assembly] to [src]!"))
		user?.put_in_hands(holder, ignore_anim = FALSE)
		return TRUE
	QDEL_NULL(holder)
	return FALSE


/obj/item/assembly/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(isassembly(I))
		add_fingerprint(user)
		var/obj/item/assembly/assembly = I
		if(assembly.secured)
			to_chat(user, span_warning("The [assembly.name] should not be secured."))
			return ATTACK_CHAIN_PROCEED
		if(secured)
			to_chat(user, span_warning("The [name] should not be secured."))
			return ATTACK_CHAIN_PROCEED
		attach_assembly(assembly, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/assembly/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(toggle_secure())
		to_chat(user, span_notice("[src] is ready!"))
	else
		to_chat(user, span_notice("[src] can now be attached!"))


/obj/item/assembly/process()
	return PROCESS_KILL


/obj/item/assembly/examine(mob/user)
	. = ..()
	if(in_range(src, user))
		if(secured)
			. += span_notice("[src] need to be secured!")
		else
			. += span_notice("[src] can be attached!")


/obj/item/assembly/attack_self(mob/user)
	if(!user)
		return
	user.set_machine(src)
	interact(user)
	return TRUE


/obj/item/implantcase/emp_shield
	name = "implant case - 'EMP Shield'"
	desc = "A glass case containing an EMP Shield implant."

/obj/item/implantcase/emp_shield/New()
	imp = new /obj/item/implant/emp_shield(src)
	. = ..()

/obj/item/implanter/emp_shield
	name = "implanter (EMP Shield)"

/obj/item/implanter/emp_shield/New()
	imp = new /obj/item/implant/emp_shield(src)
	. = ..()

/datum/uplink_item/implants/emp_shield
	name = "EMP Shield Implant"
	desc = "Nullifies EMP effects, protecting user's organs. Tested on non-combat organs only. Three time use, recharges slowly overtime."
	reference = "ESI"
	item = /obj/item/implanter/emp_shield
	cost = 2

/obj/item/implant/emp_shield
	name = "EMP Shield implant"
	desc = "Protects the user from three EMPs. Recharges fast after a long delay."
	icon_state = "lighting_bolt"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=2"
	activated = TRUE
	allow_multiple = FALSE
	var/list/restricted_organs = list(
		/obj/item/organ/internal/cyberimp/brain/anti_drop,
		/obj/item/organ/internal/cyberimp/brain/anti_stun,
		/obj/item/organ/internal/cyberimp/brain/anti_sleep)
	var/active = FALSE
	var/current_charges = 3
	var/max_charges = 3 //How many charges total the shielding has
	var/recharge_delay = 30 SECONDS //How long after we've been EMPd before we can start recharging
	var/recharge_cooldown = 0 //Time since we've last been EMPd
	var/recharge_rate = 1 //How quickly the shield recharges once it starts charging

/obj/item/implant/emp_shield/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Cybersun Industries EMP Shield Implant<BR>
				<b>Life:</b> Three days.<BR>
				<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
				<HR>
				<b>Implant Details:</b> Subjects injected with implant are more resistable to EMPs. Need to be reactivated for new organs.<BR>
				<b>Function:</b> Nullifies EMP effects, protecting user's organs. Tested on non-combat organs only.<BR>
				<b>Integrity:</b> Implant can only be used three times before reserves are depleted. Recharges overtime slowly."}
	return dat

/obj/item/implant/emp_shield/proc/enable_shielding(mob/user, intentional = FALSE)
	if(active && !intentional)
		return
	if(iscarbon(user))
		var/mob/living/carbon/implanted_user = user
		for(var/obj/item/organ/internal/i_organ in implanted_user.internal_organs)
			if(locate(i_organ) in restricted_organs)
				continue
			i_organ.emp_proof = TRUE
	active = TRUE

/obj/item/implant/emp_shield/proc/disable_shielding(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/implanted_user = user
		for(var/obj/item/organ/internal/i_organ in implanted_user.internal_organs)
			i_organ.emp_proof = initial(i_organ.emp_proof)
	active = FALSE

/obj/item/implant/emp_shield/activate()
	if(!imp_in)
		return
	if(current_charges)
		to_chat(imp_in, "<span class='syndradio'>[current_charges] charges left.</span>")
		to_chat(imp_in, "<span class='syndradio'>Updating a list of protected organs.</span>")
		enable_shielding(imp_in, intentional = TRUE)
	else
		to_chat(imp_in, "<span class='syndradio'>Implant is depleted, wait for a recharge.</span>")

/obj/item/implant/emp_shield/emp_act(severity)
	. = ..()
	recharge_cooldown = world.time + recharge_delay
	if(current_charges > 0)
		current_charges--
	if(recharge_rate)
		START_PROCESSING(SSobj, src)
	if(current_charges <= 0 && active)
		to_chat(imp_in, "<span class='syndradio'>EMP Shield depleted!</span>")
		addtimer(CALLBACK(src, .proc/disable_shielding, imp_in), 1)

/obj/item/implant/emp_shield/process()
	if(world.time > recharge_cooldown && current_charges < max_charges)
		current_charges = clamp((current_charges + recharge_rate), 0, max_charges)
		enable_shielding(imp_in)
		playsound(loc, 'sound/magic/charge.ogg', 50, TRUE)
		if(current_charges == max_charges)
			playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
			to_chat(imp_in, "<span class='syndradio'>EMP Shield fully recharged.")
			STOP_PROCESSING(SSobj, src)

/obj/item/implant/emp_shield/removed(mob/source)
	. = ..()
	disable_shielding(source)
	src.audible_message("EMP Shield removed. Thank you for using our services.", "", 1)

/obj/item/implant/emp_shield/implant(mob/source, mob/user)
	. = ..()
	enable_shielding(source)
	to_chat(source, "<span class='syndradio'>EMP Shield implanted. Thank you for using Cybersun Industries!</span>")

/obj/item/implant/emp_shield/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

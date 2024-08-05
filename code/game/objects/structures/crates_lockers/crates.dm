/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	climbable = TRUE
	open_sound = 'sound/machines/crate_open.ogg'
	close_sound = 'sound/machines/crate_close.ogg'
	open_sound_volume = 35
	close_sound_volume = 50
	pass_flags_self = PASSSTRUCTURE|LETPASSTHROW
	var/rigged = FALSE
	var/obj/item/paper/manifest/manifest
	// A list of beacon names that the crate will announce the arrival of, when delivered.
	var/list/announce_beacons = list()


/obj/structure/closet/crate/update_icon_state()
	icon_state = "[initial(icon_state)][opened ? "open" : ""]"


/obj/structure/closet/crate/update_overlays()
	// . = ..() is not needed here because of different overlay handling logic for crates
	. = list()
	if(manifest)
		. += "manifest"


/obj/structure/closet/crate/can_open()
	return TRUE

/obj/structure/closet/crate/can_close()
	return TRUE

/obj/structure/closet/crate/open(by_hand = FALSE)
	if(opened)
		return FALSE
	if(!can_open())
		return FALSE

	if(by_hand)
		for(var/obj/O in src)
			if(O.density)
				var/response = tgui_alert(usr, "This crate has been packed with bluespace compression, an item inside won't fit back inside. Are you sure you want to open it?", "Bluespace Compression Warning", list("Yes", "No"))
				if(response != "Yes" || !Adjacent(usr))
					return FALSE
				break

	if(rigged && locate(/obj/item/radio/electropack) in src)
		if(isliving(usr))
			var/mob/living/L = usr
			if(L.electrocute_act(17, "электропака в ящике"))
				do_sparks(5, 1, src)
				return 2

	playsound(loc, open_sound, open_sound_volume, TRUE, -3)
	for(var/obj/O in src) //Objects
		O.forceMove(loc)
	for(var/mob/M in src) //Mobs
		M.forceMove(loc)

	opened = TRUE
	update_icon()

	if(climbable)
		structure_shaken()

	return TRUE


/obj/structure/closet/crate/close()
	if(!opened || !can_close())
		return FALSE

	playsound(loc, close_sound, close_sound_volume, TRUE, -3)
	var/itemcount = 0
	for(var/atom/movable/O in get_turf(src))
		if(itemcount >= storage_capacity)
			break
		if(O.density || O.anchored || istype(O,/obj/structure/closet) || isobserver(O))
			continue
		if(istype(O, /obj/structure/bed)) //This is only necessary because of rollerbeds and swivel chairs.
			var/obj/structure/bed/B = O
			if(B.has_buckled_mobs())
				continue
		O.forceMove(src)
		itemcount++

	opened = FALSE
	update_icon()
	return TRUE


/obj/structure/closet/crate/attackby(obj/item/I, mob/user, params)
	if(!opened && try_rig(I, user))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/structure/closet/crate/toggle(mob/user, by_hand = FALSE)
	if(!(opened ? close() : open(by_hand)))
		to_chat(user, "<span class='notice'>It won't budge!</span>")

/obj/structure/closet/crate/proc/try_rig(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(rigged)
			to_chat(user, "<span class='notice'>[src] is already rigged!</span>")
			return TRUE
		if(C.use(15))
			to_chat(user, "<span class='notice'>You rig [src].</span>")
			rigged = TRUE
		else
			to_chat(user, "<span class='warning'>You need atleast 15 wires to rig [src]!</span>")
		return TRUE
	if(istype(W, /obj/item/radio/electropack))
		if(rigged)
			if(!user.drop_transfer_item_to_loc(W, src))
				to_chat(user, "<span class='warning'>[W] seems to be stuck to your hand!</span>")
				return TRUE
			to_chat(user, "<span class='notice'>You attach [W] to [src].</span>")
		return TRUE

/obj/structure/closet/crate/wirecutter_act(mob/living/user, obj/item/I)
	if(opened)
		return
	if(!rigged)
		return

	if(I.use_tool(src, user))
		to_chat(user, "<span class='notice'>You cut away the wiring.</span>")
		playsound(loc, I.usesound, 100, 1)
		rigged = FALSE
		return TRUE

/obj/structure/closet/crate/welder_act()
	return

/obj/structure/closet/crate/attack_hand(mob/user)
	if(manifest)
		add_fingerprint(user)
		to_chat(user, "<span class='notice'>You tear the manifest off of the crate.</span>")
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 75, 1)
		manifest.forceMove_turf()
		if(ishuman(user))
			user.put_in_hands(manifest, ignore_anim = FALSE)
		manifest = null
		update_icon()
		return
	else
		if(rigged && locate(/obj/item/radio/electropack) in src)
			if(isliving(user))
				var/mob/living/L = user
				if(L.electrocute_act(17, "электропака в ящике"))
					do_sparks(5, 1, src)
					return
		add_fingerprint(user)
		toggle(user, by_hand = TRUE)

// Called when a crate is delivered by MULE at a location, for notifying purposes
/obj/structure/closet/crate/proc/notifyRecipient(var/destination)
	var/msg = "[capitalize(name)] has arrived at [destination]."
	if(destination in announce_beacons)
		for(var/obj/machinery/requests_console/D in GLOB.allRequestConsoles)
			if(D.department in src.announce_beacons[destination])
				D.createMessage(name, "Your Crate has Arrived!", msg, 1)

/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "securecrate"
	overlay_locked = "securecrater"
	overlay_unlocked = "securecrateg"
	overlay_sparking = "securecratesparks"
	/// Overlay for crate with broken lock
	var/overlay_broken = "securecrateemag"
	max_integrity = 500
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	damage_deflection = 25
	var/tamperproof = FALSE
	broken = FALSE
	locked = TRUE
	can_be_emaged = TRUE


/obj/structure/closet/crate/secure/update_overlays()
	. = ..()
	if(locked)
		. += overlay_locked
	else if(broken && overlay_broken)
		. += overlay_broken
	else
		. += overlay_unlocked


/obj/structure/closet/crate/secure/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	if(prob(tamperproof) && damage_amount >= DAMAGE_PRECISION)
		boom()
	else
		return ..()

/obj/structure/closet/crate/secure/proc/boom(mob/user)
	if(user)
		to_chat(user, "<span class='danger'>The crate's anti-tamper system activates!</span>")
		investigate_log("[key_name_log(user)] has detonated a [src]", INVESTIGATE_BOMB)
		add_attack_logs(user, src, "has detonated", ATKLOG_MOST)
	for(var/atom/movable/AM in src)
		qdel(AM)
	explosion(get_turf(src), 0, 1, 5, 5, cause = src)
	qdel(src)


/obj/structure/closet/crate/secure/can_open()
	return !locked


/obj/structure/closet/crate/secure/AltClick(mob/living/user)
	if(Adjacent(user))
		togglelock(user)


/obj/structure/closet/crate/secure/proc/togglelock(mob/living/user)
	if(!istype(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(opened)
		to_chat(user, "<span class='notice'>Close the crate first.</span>")
		return
	if(broken)
		to_chat(user, "<span class='warning'>The crate appears to be broken.</span>")
		return
	if(allowed(user))
		locked = !locked
		playsound(loc, pick(togglelock_sound), 15, TRUE, -3)
		visible_message("<span class='notice'>The crate has been [locked ? null : "un"]locked by [user].</span>")
		update_icon()
	else
		to_chat(user, "<span class='notice'>Access Denied</span>")
	add_fingerprint(user)

/obj/structure/closet/crate/secure/attack_hand(mob/user)
	if(manifest)
		add_fingerprint(user)
		to_chat(user, "<span class='notice'>You tear the manifest off of the crate.</span>")
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 75, 1)
		manifest.forceMove_turf()
		if(ishuman(user))
			user.put_in_hands(manifest, ignore_anim = FALSE)
		manifest = null
		update_icon()
		return
	if(locked)
		togglelock(user)
	else
		add_fingerprint(user)
		toggle(user, by_hand = TRUE)


/obj/structure/closet/crate/secure/closed_item_click(mob/user)
	togglelock(user)


/obj/structure/closet/crate/secure/emag_act(mob/user)
	if(locked)
		add_attack_logs(user, src, "emagged")
		locked = FALSE
		broken = TRUE
		playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		flick_overlay_view(image(icon, src, overlay_sparking), sparking_duration)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), sparking_duration)
		if(user)
			to_chat(user, span_notice("You unlock [src]."))


/obj/structure/closet/crate/secure/emp_act(severity)
	for(var/obj/object in src)
		object.emp_act(severity)

	if(broken || opened)
		return

	if(prob(50 / severity))
		locked = !locked
		playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		flick_overlay_view(image(icon, src, overlay_sparking), sparking_duration)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), sparking_duration)

	if(prob(20 / severity))
		if(locked)
			req_access = list()
			req_access += pick(get_all_accesses())
		else
			open()


/obj/structure/closet/crate/plastic
	name = "plastic crate"
	desc = "A rectangular plastic crate."
	icon_state = "plasticcrate"

/obj/structure/closet/crate/internals
	desc = "A internals crate."
	name = "internals crate"
	icon_state = "o2crate"

/obj/structure/closet/crate/trashcart
	desc = "A heavy, metal trashcart with wheels."
	name = "trash Cart"
	icon_state = "trashcart"

/obj/structure/closet/crate/trashcart/NTdelivery
	name = "Special Delivery from Central Command"

/obj/structure/closet/crate/trashcart/gibs
	desc = "A heavy, metal trashcart with wheels. You better don't ask."
	name = "trash cart with gibs"
	icon_state = "trashcartgib"

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "medical crate"
	icon_state = "medicalcrate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of the RCD."
	name = "\improper RCD crate"
	icon_state = "crate"

/obj/structure/closet/crate/rcd/populate_contents()
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd(src)

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "Freezer"
	icon_state = "freezer"
	var/target_temp = T0C - 40
	var/cooling_power = 40

/obj/structure/closet/crate/freezer/return_air()
	var/datum/gas_mixture/gas = (..())
	if(!gas)	return null
	var/datum/gas_mixture/newgas = new/datum/gas_mixture()
	newgas.oxygen = gas.oxygen
	newgas.carbon_dioxide = gas.carbon_dioxide
	newgas.nitrogen = gas.nitrogen
	newgas.toxins = gas.toxins
	newgas.volume = gas.volume
	newgas.temperature = gas.temperature
	if(newgas.temperature <= target_temp)	return

	if((newgas.temperature - cooling_power) > target_temp)
		newgas.temperature -= cooling_power
	else
		newgas.temperature = target_temp
	return newgas

/obj/structure/closet/crate/can
	desc = "A large can, looks like a bin to me."
	name = "garbage can"
	icon_state = "largebin"
	anchored = TRUE

/obj/structure/closet/crate/can/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I, 40)

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "radioactive gear crate"
	icon_state = "radiation"

/obj/structure/closet/crate/radiation/populate_contents()
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)

/obj/structure/closet/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "weapons crate"
	icon_state = "weaponcrate"

/obj/structure/closet/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "plasma crate"
	icon_state = "plasmacrate"

/obj/structure/closet/crate/secure/gear
	desc = "A secure gear crate."
	name = "gear crate"
	icon_state = "secgearcrate"

/obj/structure/closet/crate/secure/hydrosec
	desc = "A crate with a lock on it, painted in the scheme of the station's botanists."
	name = "secure hydroponics crate"
	icon_state = "hydrosecurecrate"

/obj/structure/closet/crate/secure/bin
	desc = "A secure bin."
	name = "secure bin"
	icon_state = "largebins"
	overlay_locked = "largebinr"
	overlay_unlocked = "largebing"
	overlay_sparking = "largebinsparks"
	overlay_broken = "largebinemag"

/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty metal crate."
	icon_state = "largemetal"
	pass_flags_self = PASSSTRUCTURE
	integrity_failure = 0 //Makes the crate break when integrity reaches 0, instead of opening and becoming an invisible sprite.

/obj/structure/closet/crate/large/close()
	. = ..()
	if(.)//we can hold up to one large item
		var/found = FALSE
		for(var/obj/structure/S in src.loc)
			if(S == src)
				continue
			if(!S.anchored)
				found = TRUE
				S.forceMove(src)
				break
		if(!found)
			for(var/obj/machinery/M in src.loc)
				if(!M.anchored)
					M.forceMove(src)
					break

/obj/structure/closet/crate/secure/large
	name = "large crate"
	desc = "A hefty metal crate with an electronic locking system."
	icon_state = "largemetal"
	overlay_locked = "largemetalr"
	overlay_unlocked = "largemetalg"
	overlay_broken = ""

/obj/structure/closet/crate/secure/large/close()
	. = ..()
	if(.)//we can hold up to one large item
		var/found = 0
		for(var/obj/structure/S in src.loc)
			if(S == src)
				continue
			if(!S.anchored)
				found = 1
				S.forceMove(src)
				break
		if(!found)
			for(var/obj/machinery/M in src.loc)
				if(!M.anchored)
					M.forceMove(src)
					break

//fluff variant
/obj/structure/closet/crate/secure/large/reinforced
	desc = "A hefty, reinforced metal crate with an electronic locking system."
	icon_state = "largermetal"

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydrocrate"

/obj/structure/closet/crate/hydroponics/prespawned
	//This exists so the prespawned hydro crates spawn with their contents.

// Do I need the definition above? Who knows!
/obj/structure/closet/crate/hydroponics/prespawned/populate_contents()
	new /obj/item/reagent_containers/glass/bucket(src)
	new /obj/item/reagent_containers/glass/bucket(src)
	new /obj/item/screwdriver(src)
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/wrench(src)
	new /obj/item/wirecutters(src)
	new /obj/item/wirecutters(src)
	new /obj/item/shovel/spade(src)
	new /obj/item/shovel/spade(src)
	new /obj/item/storage/box/beakers(src)
	new /obj/item/storage/box/beakers(src)
	new /obj/item/hand_labeler(src)
	new /obj/item/hand_labeler(src)

/obj/structure/closet/crate/sci
	name = "science crate"
	desc = "A science crate."
	icon_state = "scicrate"

/obj/structure/closet/crate/secure/scisec
	name = "secure science crate"
	desc = "A crate with a lock on it, painted in the scheme of the station's scientists."
	icon_state = "scisecurecrate"

/obj/structure/closet/crate/engineering
	name = "engineering crate"
	desc = "An engineering crate."
	icon_state = "engicrate"

/obj/structure/closet/crate/secure/engineering
	name = "secure engineering crate"
	desc = "A crate with a lock on it, painted in the scheme of the station's engineers."
	icon_state = "engisecurecrate"

/obj/structure/closet/crate/engineering/electrical
	name = "electrical engineering crate"
	desc = "An electrical engineering crate."
	icon_state = "electricalcrate"

/obj/structure/closet/crate/tape/populate_contents()
	if(prob(10))
		new /obj/item/bikehorn/rubberducky(src)

/obj/structure/closet/crate/secure/biohazard
	name = "secure biohazard crate"
	desc = "An protected biohazard crate."
	icon_state = "biohazard"

//crates of gear in the free golem ship
/obj/structure/closet/crate/golemgear/populate_contents()
	new /obj/item/storage/backpack/industrial(src)
	new /obj/item/shovel(src)
	new /obj/item/pickaxe(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/card/id/golem(src)
	new /obj/item/flashlight/lantern(src)

//syndie crates by Furukai
/obj/structure/closet/crate/syndicate
	desc = "Definitely a property of an evil corporation!"
	icon_state = "syndiecrate"
	material_drop = /obj/item/stack/sheet/mineral/plastitanium

/obj/structure/closet/crate/secure/syndicate
	name = "Secure suspicious crate"
	desc = "Definitely a property of an evil corporation! And it has a hardened lock! And a microphone?"
	icon_state = "syndiesecurecrate"
	material_drop = /obj/item/stack/sheet/mineral/plastitanium
	can_be_emaged = FALSE

/obj/structure/closet/crate/secure/syndicate/emag_act(mob/user)
	if(locked && !broken)
		if(user)
			to_chat(user, span_notice("Отличная попытка, но нет!"))
		playsound(src.loc, "sound/misc/sadtrombone.ogg", 60, 1)


/obj/structure/closet/crate/vault
	desc = "A vault crate."
	name = "vault crate"
	icon_state = "vaultcrate"

/obj/structure/closet/crate/secure/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && broken == 0 && user.a_intent != INTENT_HARM) // Stage one
		to_chat(user, span_notice("Вы начинаете откручивать панель замка [src]..."))
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(95)) // EZ
				if(broken != 3)
					to_chat(user, span_notice("Вы успешно открутили и сняли панель с замка [src]!"))
					desc += " Панель управления снята."
					broken = 3
				//icon_state = icon_off // Crates has no icon_off :(
			else // Bad day)
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
				user.apply_damage(5, BRUTE , affecting)
				user.emote("scream")
				to_chat(user, span_warning("Проклятье! [I] сорвалась и повредила [affecting.name]!"))
		return TRUE

/obj/structure/closet/crate/secure/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && broken == 3 && user.a_intent != INTENT_HARM) // Stage two
		to_chat(user, span_notice("Вы начинаете подготавливать провода панели [src]..."))
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(80)) // Good hacker!
				if(broken != 2)
					to_chat(user, span_notice("Вы успешно подготовили провода панели замка [src]!"))
					desc += " Провода отключены и торчат наружу."
					broken = 2
			else // woopsy
				to_chat(user, span_warning("Черт! Не тот провод!"))
				do_sparks(5, 1, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

/obj/structure/closet/crate/secure/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && broken == 2 && user.a_intent != INTENT_HARM) // Stage three
		to_chat(user, span_notice("Вы начинаете подключать провода панели замка [src] к [I]..."))
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(80)) // Good hacker!
				if(broken != 0 && broken != 1)
					desc += " Замок отключен."
					broken = 0 // Can be emagged
					emag_act(user)
			else // woopsy
				to_chat(user, span_warning("Черт! Не тот провод!"))
				do_sparks(5, 1, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

// A Clockwork slab. Ratvar's tool to cast most of essential spells.
/obj/item/clockwork/clockslab
	name = "Clockwork slab"
	desc = "A strange metal tablet. A clock in the center turns around and around."
	icon = 'icons/obj/clockwork.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "clock_slab"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clockwork/clockslab/Initialize(mapload)
	. = ..()
	enchants = GLOB.clockslab_spells

/obj/item/clockwork/clockslab/update_icon()
	update_overlays()
	//if(enchant_type)
	//	add_overlay("overlay_temp")
	..()

/obj/item/clockwork/clockslab/proc/update_overlays()
	cut_overlays()
	if(enchant_type)
		overlays += "clock_slab_overlay_[enchant_type]"

/obj/item/clockwork/clockslab/attack_self(mob/user)
	. = ..()
	switch(enchant_type)
		if(EMP_SPELL)
			src.visible_message("<span class='warning'>[src] glows with shining blue!</span>")
			empulse(src, 3, 1, cause="clock")
			deplete_spell()
		if(TIME_SPELL)
			deplete_spell()
			new/obj/effect/timestop/clockwork(get_turf(src))

/obj/item/clockwork/clockslab/afterattack(atom/target, mob/living/user, proximity, params)
	. = ..()
	switch(enchant_type)
		if(STUN_SPELL)
			if(!isliving(target) || isclocker(target) || !proximity)
				return
			var/mob/living/L = target
			var/atom/N = L.null_rod_check()
			src.visible_message("<span class='warning'>[user]'s [src] sparks for a moment with bright light!</span>")
			user.mob_light(LIGHT_COLOR_HOLY_MAGIC, 3, _duration = 2) //No questions
			if(N)
				src.visible_message("<span class='warning'>[target]'s holy weapon absorbs the light!</span>")
			else
				L.Weaken(5)
				L.Stun(5)
				if(issilicon(L))
					var/mob/living/silicon/S = L
					S.emp_act(EMP_HEAVY)
				else if(iscarbon(target))
					var/mob/living/carbon/C = L
					C.Stuttering(10)
					C.ClockSlur(10)
			deplete_spell()
		if(KNOCK_SPELL)
			if(istype(target, /obj/machinery/door))
				var/obj/machinery/door/door = target
				if(istype(door, /obj/machinery/door/airlock/hatch/gamma))
					return
				if(istype(door, /obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/A = door
					A.unlock(TRUE)	//forced because it's magic!
				door.open()
				deplete_spell()
			else if(istype(target, /obj/structure/closet))
				var/obj/structure/closet/closet = target
				if(istype(closet, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = closet
					SC.locked = FALSE
				closet.open()
				deplete_spell()
			else
				to_chat(user, "<span class='warning'>You can use only on doors and closets!</span>")
		if(TELEPORT_SPELL)
			if(!target.density && !proximity)
				to_chat(user, "<span class='notice'> You start invoking teleportation...</span>")
				if(do_after(user, 50, target = src))
					//fade out anim
					do_teleport(user, get_turf(target), asoundin = 'sound/effects/phasein.ogg')
					//fade in anim
					deplete_spell()

/obj/item/clockwork
	name = "Clockwork item name"
	icon = 'icons/obj/clockwork.dmi'

//Ratvarian spear
/obj/item/twohanded/ratvarian_spear
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "ratvarian_spear"
	force_unwielded = 12
	force_wielded = 20
	throwforce = 40
	armour_penetration = 30
	sharp = TRUE
	embed_chance = 70
	embedded_ignore_throwspeed_threshold = TRUE
	attack_verb = list("stabbed", "poked", "slashed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_BULKY

/obj/item/twohanded/ratvarian_spear/Initialize(mapload)
	. = ..()
	enchants = GLOB.spear_spells

/obj/item/twohanded/ratvarian_spear/update_icon()
	. = ..()
	update_overlays()

/obj/item/twohanded/ratvarian_spear/proc/update_overlays()
	cut_overlays()
	if(enchant_type)
		overlays += "ratvarian_spear_overlay_[enchant_type]"

/obj/item/twohanded/ratvarian_spear/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(wielded && istype(target, /mob/living))
		var/mob/living/L = target
		if(enchant_type == CONFUSE_SPELL)
			L.SetConfused(4)
			deplete_spell()
		if(enchant_type == DISABLE_SPELL)
			if(issilicon(L))
				var/mob/living/silicon/S = L
				S.emp_act(EMP_LIGHT)
			else
				L.emp_act(EMP_HEAVY)
			deplete_spell()


/obj/item/twohanded/clock_hammer
	name = "hammer clock"
	desc = "A heavy hammer of an elder god. Used to shine like in past times."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clock_hammer"
	slot_flags = SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 25
	throwforce = 30
	throw_range = 7
	w_class = WEIGHT_CLASS_HUGE

/obj/item/twohanded/clock_hammer/Initialize(mapload)
	. = ..()
	enchants = GLOB.hammer_spells

/obj/item/twohanded/clock_hammer/update_icon()
	. = ..()
	update_overlays()

/obj/item/twohanded/clock_hammer/proc/update_overlays()
	cut_overlays()
	if(enchant_type)
		overlays += "clock_hammer_overlay_[enchant_type]"

/obj/item/twohanded/clock_hammer/attack(mob/living/M, mob/living/user, def_zone)
	. = ..()
	var/atom/throw_target = get_edge_target_turf(M, user.dir)

	if(!enchant_type == KNOCKOFF_SPELL)
		M.throw_at(throw_target, rand(1, 2), 7, user)
	else
		M.throw_at(throw_target, 200, 20, user) // vroom
		deplete_spell()
	if(enchant_type == CRUSH_SPELL && istype(user,/mob/living/carbon/human))
		user.apply_damage(25, BRUTE, def_zone)
		var/obj/item/organ/external/BP = M.get_organ(def_zone)
		BP.fracture()
		deplete_spell()

// Clockwork robe. Basic robe from clockwork slab.
/obj/item/clothing/suit/hooded/clockrobe
	name = "clock robes"
	desc = "A set of robes worn by the followers of a clockwork cult."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_robe"
	item_state = "clockwork_robe"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/clockhood
	allowed = list(/obj/item/clockwork)
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDEJUMPSUIT
	magical = TRUE
	var/hit_reflect_chance = 40

/obj/item/clothing/suit/hooded/clockrobe/Initialize(mapload)
	. = ..()
	enchants = GLOB.robe_spells

/obj/item/clothing/suit/hooded/clockrobe/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(enchant_type == WEAK_REFLECT_SPELL)
		playsound(loc, "sparks", 100, TRUE)
		new /obj/effect/temp_visual/ratvar/sparks(get_turf(owner))
		if(!prob(hit_reflect_chance))
			return FALSE
		owner.visible_message("<span class='danger'>[attack_text] is deflected by [src]'s sparks!</span>")
		return TRUE


/obj/item/clothing/head/hooded/clockhood
	name = "clock hood"
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockhood"
	item_state = "clockhood"
	desc = "A hood worn by the followers of ratvar."
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	flags_cover = HEADCOVERSEYES
	armor = list(melee = 30, bullet = 10, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0, fire = 10, acid = 10)
	magical = TRUE

// Clockwork Armour. Basically greater robe with more and better spells.
/obj/item/clothing/suit/armor/clockwork
	name = "clockwork cuirass"
	desc = "A bulky cuirass made of brass."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_cuirass"
	item_state = "clockwork_cuirass"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 60, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	flags_inv = HIDEJUMPSUIT
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/clockwork)

/obj/item/clothing/suit/armor/clockwork/Initialize(mapload)
	. = ..()
	enchants = GLOB.armour_spells

/obj/item/clothing/suit/armor/clockwork/IsReflect()
	var/mob/living/carbon/human/user = loc
	if(enchant_type != REFLECT_SPELL)
		return
	if(user.wear_suit == src)
		return TRUE

/obj/item/clothing/suit/armor/clockwork/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(enchant_type == REFLECT_SPELL)
		owner.visible_message("<span class='danger'>[attack_text] is deflected by [src]'s sparks!</span>")
		playsound(loc, "sparks", 100, TRUE)
		new /obj/effect/temp_visual/ratvar/sparks(get_turf(owner))
		return TRUE

/obj/item/clothing/suit/armor/clockwork/attack_self(mob/user)
	. = ..()
	if(enchant_type == ARMOR_SPELL && isclocker(user))
		to_chat(user, "<span class='notice'>the [src] becomes more hardened as the plates becomes to shift for any attack!</span>")
		armor = list("melee" = 70, "bullet" = 60, "laser" = 60, "energy" = 60, "bomb" = 90, "bio" = 50, "rad" = 50, "fire" = 100, "acid" = 100)
		enchant_type = CASTING_SPELL
		addtimer(CALLBACK(src, .proc/reset_armor), 10)
	if(enchant_type == FLASH_SPELL && isclocker(user))
		playsound(loc, 'sound/effects/phasein.ogg', 100, 1)
		set_light(2, 1, COLOR_WHITE)
		addtimer(CALLBACK(src, /atom./proc/set_light, 0), 2)
		usr.visible_message("<span class='disarm'>[usr]'s [src] emits a blinding light!</span>", "<span class='danger'>Your [src] emits a blinding light!</span>")
		for(var/mob/living/carbon/M in oviewers(3, null))
			if(isclocker(M))
				return
			if(M.flash_eyes(2, 1))
				M.AdjustConfused(5)
				M.Stun(2)
		deplete_spell()

/obj/item/clothing/suit/armor/clockwork/proc/reset_armor()
	to_chat(usr, "<span class='notice>The [src] stops to shifting...</span>")
	armor = initial(armor)
	deplete_spell()


/obj/item/clothing/suit/armor/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == slot_wear_suit && !isclocker(user))
		if(!iscultist(user))
			to_chat(user, "<span class='heavy_brass'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their body!</span>", "<span class='warning'>The curiass flickers off your body, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20)
				C.Stuttering(5)
		else
			to_chat(user, "<span class='heavy_brass'>\"I think this armor is too hot for you to handle.\"</span>")
			to_chat(user, "<span class='userdanger'>The curiass emits a burst of flame as you scramble to get it off!</span>")
			user.emote("scream")
			user.apply_damage(15, BURN, "chest")
			user.adjust_fire_stacks(2)
			user.IgniteMob()
		user.unEquip(src)

// Gloves
/obj/item/clothing/gloves/clockwork
	name = "clockwork gauntlets"
	desc = "Heavy, shock-resistant gauntlets with brass reinforcement."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_gauntlets"
	item_state = "clockwork_gauntlets"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 40, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	var/north_star = FALSE
	var/fire_casting = FALSE

/obj/item/clothing/gloves/clockwork/Initialize(mapload)
	. = ..()
	enchants = GLOB.gloves_spell

/obj/item/clothing/gloves/clockwork/attack_self(mob/user)
	. = ..()
	if(enchant_type == FASTPUNCH_SPELL)
		if(user.mind.martial_art)
			to_chat(user, "<span class='warning'>You're too powerful to use it!</span>")
			return
		to_chat(user, "<span class='notice'>You fastening gloves making your moves agile!</span>")
		enchant_type = CASTING_SPELL
		north_star = TRUE
		addtimer(CALLBACK(src, .proc/reset), 80)
	if(enchant_type == FIRE_SPELL)
		to_chat(user, "<span class='notice>Your gloves becomes in red flames ready to burn any enemy in sight!</span>")
		enchant_type = CASTING_SPELL
		fire_casting = TRUE
		addtimer(CALLBACK(src, .proc/reset), 50)


/obj/item/clothing/gloves/clockwork/Touch(atom/A, proximity)
	var/mob/living/M = loc
	if(M.a_intent == INTENT_HARM)
		if(enchant_type == STUNHAND_SPELL)
			if(iscarbon(A))
				var/mob/living/carbon/C = A
				if(isclocker(C))
					return
				C.Weaken(5)
				C.Stuttering(10)
			else if(isrobot(A))
				var/mob/living/silicon/robot/R = A
				if(isclocker(R))
					return
				R.Weaken(5)
			else
				return
			do_sparks(5, 0, loc)
			playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
			deplete_spell()
		if(north_star && !M.mind.martial_art)
			M.changeNext_move(CLICK_CD_RAPID)
		if(fire_casting && iscarbon(A))
			var/mob/living/carbon/C = A
			if(isclocker(C))
				return
			C.adjust_fire_stacks(0.3)
			C.IgniteMob()

/obj/item/clothing/gloves/clockwork/proc/reset()
	north_star = FALSE
	fire_casting = FALSE
	to_chat(user, "<span class='notice'> [src] depletes last magic they had.</span>")
	deplete_spell()

/obj/item/clothing/gloves/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == slot_gloves && !isclocker(user))
		if(!iscultist(user))
			to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their arms!</span>", "<span class='warning'>The gauntlets flicker off your arms, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
				C.Stuttering(5)
		else
			to_chat(user, "<span class='clocklarge'>\"Did you like having arms?\"</span>")
			to_chat(user, "<span class='userdanger'>The gauntlets suddenly squeeze tight, crushing your arms before you manage to get them off!</span>")
			user.emote("scream")
			user.apply_damage(7, BRUTE, "l_arm")
			user.apply_damage(7, BRUTE, "r_arm")
		user.unEquip(src)

// Shoes
/obj/item/clothing/shoes/clockwork
	name = "clockwork treads"
	desc = "Industrial boots made of brass. They're very heavy."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_treads"
	item_state = "clockwork_treads"
	strip_delay = 60
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == slot_shoes && !isclocker(user))
		if(!iscultist(user))
			to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their feet!</span>", "<span class='warning'>The treads flicker off your feet, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
				C.Stuttering(5)
		else
			to_chat(user, "<span class='clocklarge'>\"Let's see if you can dance with these.\"</span>")
			to_chat(user, "<span class='userdanger'>The treads turn searing hot as you scramble to get them off!</span>")
			user.emote("scream")
			user.apply_damage(7, BURN, "l_leg")
			user.apply_damage(7, BURN, "r_leg")
		user.unEquip(src)

// Helmet
/obj/item/clothing/head/helmet/clockwork
	name = "clockwork helmet"
	desc = "A heavy helmet made of brass."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_helmet"
	item_state = "clockwork_helmet"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	armor = list(melee = 50, bullet = 70, laser = 10, energy = 0, bomb = 60, bio = 0, rad = 0, fire = 100, acid = 100)

/obj/item/clothing/head/helmet/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == slot_head && !isclocker(user))
		if(!iscultist(user))
			to_chat(user, "<span class='heavy_brass'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their head!</span>", "<span class='warning'>The helmet flickers off your head, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20)
				C.Stuttering(5)
		else
			to_chat(user, "<span class='heavy_brass'>\"Do you have a hole in your head? You're about to.\"</span>")
			to_chat(user, "<span class='userdanger'>The helmet tries to drive a spike through your head as you scramble to remove it!</span>")
			user.emote("scream")
			user.apply_damage(30, BRUTE, "head")
			user.adjustBrainLoss(30)
		user.unEquip(src)

/*
 * Consumables.
 */

//Intergration Cog. Can be used on an open APC to replace its guts with clockwork variants, and begin passively siphoning power from it
/obj/item/clockwork/integration_cog
	name = "integration cog"
	desc = "A small cogwheel that fits in the palm of your hand."
	icon_state = "gear"
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/power/apc/apc

/obj/item/clockwork/integration_cog/Initialize()
	. = ..()
	transform *= 0.5 //little cog!
	START_PROCESSING(SSobj, src)

/obj/item/clockwork/integration_cog/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clockwork/integration_cog/process()
	if(!apc)
		if(istype(loc, /obj/machinery/power/apc))
			apc = loc
		else
			STOP_PROCESSING(SSobj, src)
	else
		var/obj/item/stock_parts/cell/cell = apc.get_cell()
		if(cell && (cell.charge / cell.maxcharge > COG_MAX_SIPHON_THRESHOLD))
			cell.use(round(0.001*cell.maxcharge,1))
			adjust_clockwork_power(CLOCK_POWER_COG) //Power is shared, so only do it once; this runs very quickly so it's about CLOCK_POWER_COG(1)/second
			if(prob(2))
				playsound(apc, 'sound/machines/clockcult/steam_whoosh.ogg', 10, TRUE)
				new/obj/effect/temp_visual/small_smoke(get_turf(apc))

// Soul vessel (Posi Brain)
/obj/item/mmi/robotic_brain/clockwork
	name = "soul vessel"
	desc = "A heavy brass cube, three inches to a side, with a single protruding cogwheel."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "soul_vessel"
	blank_icon = "soul_vessel"
	searching_icon = "soul_vessel_search"
	occupied_icon = "soul_vessel_occupied"
	requires_master = FALSE
	ejected_flavor_text = "brass cube"
	dead_icon = "soul_vessel"


/obj/item/mmi/robotic_brain/clockwork/proc/try_to_transfer(mob/target)
	var/mob/living/T = target
	if(T.client && T.ghost_can_reenter())
		transfer_personality(T)
		to_chat(T, "<span class='clocklarge'><b>\"You belong to me now.\"</b></span>")
	else
		icon_state = searching_icon
		searching = TRUE
		var/list/candidates = SSghost_spawns.poll_candidates("Would you like to play as a Servant of Ratvar?", ROLE_CLOCKER, FALSE, poll_time = 10 SECONDS, source = /obj/item/mmi/robotic_brain/clockwork)
		if(candidates.len)
			transfer_personality(pick(candidates))
		reset_search()


/obj/item/mmi/robotic_brain/clockwork/transfer_personality(mob/candidate)
	searching = FALSE
	brainmob.key = candidate.key
	brainmob.name = "[pick(list("Nycun", "Oenib", "Havsbez", "Ubgry", "Fvreen"))]-[rand(10, 99)]"
	name = "[src] ([brainmob.name])"
	brainmob.mind.assigned_role = "Soul Vessel Cube"
	visible_message("<span class='notice'>[src] chimes quietly.</span>")
	become_occupied(occupied_icon)
	if(SSticker.mode.add_clocker(brainmob.mind))
		brainmob.create_log(CONVERSION_LOG, "[brainmob.mind] been converted by [src.name]")

/obj/item/mmi/robotic_brain/clockwork/attack_self(mob/living/user)
	if(!isclocker(user))
		to_chat(user, "<span class='warning'>You fiddle around with [src], to no avail.</span>")
		return FALSE
	if(brainmob && !brainmob.key && !searching)
		//Start the process of searching for a new user.
		to_chat(user, "<span class='notice'>You carefully locate the manual activation switch and start [src]'s boot process.</span>")
		icon_state = searching_icon
		searching = TRUE
		var/list/candidates = SSghost_spawns.poll_candidates("Would you like to play as a Servant of Ratvar?", ROLE_CLOCKER, FALSE, poll_time = 10 SECONDS, source = /obj/item/mmi/robotic_brain/clockwork)
		if(candidates.len)
			transfer_personality(pick(candidates))
		reset_search()

/obj/item/mmi/robotic_brain/attack_ghost(mob/dead/observer/O)
	if(brainmob?.key)
		return
	if(check_observer(O) && (world.time >= next_ping_at))
		next_ping_at = world.time + (20 SECONDS)
		playsound(get_turf(src), 'sound/items/posiping.ogg', 80, 0)
		visible_message("<span class='notice'>[src] pings softly.</span>")

/obj/item/mmi/robotic_brain/clockwork/attack(mob/living/M, mob/living/user, def_zone)
	if(!isclocker(user))
		user.Weaken(5)
		user.emote("scream")
		to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
		to_chat(user, "<span class='clocklarge'>\"Don't even try.\"</span>")
		return

	if(!ishuman(M))
		..()
		return

	if(brainmob.key)
		to_chat(user, "<span class='clock'>\"This vessel is filled, friend. Provide it with a body.\"</span>")
		return
	if(isclocker(M))
		to_chat(user, "<span class='clocklarge'>\"It would be more wise to revive your allies, friend.\"</span>")
		return
	if(jobban_isbanned(M, ROLE_CLOCKER) || jobban_isbanned(M, ROLE_SYNDICATE))
		to_chat(user, "<span class='warning'>A mysterious force prevents you from claiming [M]'s mind.</span>")
		return
	var/mob/living/carbon/human/H = M
	if(H.stat == CONSCIOUS)
		to_chat(user, "<span class='warning'>[H] must be dead or unconscious for you to claim [H.p_their()] mind!</span>")
		return
	if(H.has_brain_worms())
		to_chat(user, "<span class='warning'>[H] is corrupted by an alien intelligence and cannot claim [H.p_their()] mind!</span>")
		return
	if(!H.bodyparts_by_name["head"])
		to_chat(user, "<span class='warning'>[H] has no head, and thus no mind to claim!</span>")
		return
	if(!H.get_int_organ(/obj/item/organ/internal/brain))
		to_chat(user, "<span class='warning'>[H] has no brain, and thus no mind to claim!</span>")
		return
	if(!H.key)
		to_chat(user, "<span class='warning'>[H] has no mind to claim!</span>")
		return


	user.visible_message("<span class='warning'>[user] starts pressing [src] to [H]'s head, ripping through the skull</span>", \
	"<span class='clock'>You start extracting [H]'s consciousness from [H.p_their()] body.</span>")
	if(do_after(user, 40, target = src))
		user.visible_message("<span class='warning'>[user] pressed [src] through [H]'s skull and extracted the brain!", \
		"<span class='clock'>You extracted [H]'s consciousness, trapping it in the soul vessel.")
		try_to_transfer(H)

// A drone shell. Just click on it and it will boot up itself!
/obj/item/clockwork/cogscarab
	name = "unactivated cogscarab"
	desc = "A strange, drone-like machine. It looks lifeless."
	icon_state = "cogscarab_shell"
	var/searching = FALSE

/obj/item/clockwork/cogscarab/attack_self(mob/user)
	if(!isclocker(user))
		to_chat(user, "<span class='warning'>You fiddle around with [src], to no avail.</span>")
		return FALSE
	if(searching)
		return
	searching = TRUE
	to_chat(user, "<span class='notice'>You're trying to boot up [src] as the gears inside start to hum.</span>")
	var/list/candidates = SSghost_spawns.poll_candidates("Would you like to play as a Servant of Ratvar?", ROLE_CLOCKER, FALSE, poll_time = 10 SECONDS, source = /mob/living/silicon/robot/cogscarab)
	if(candidates.len)
		var/mob/dead/observer/O = pick(candidates)
		var/mob/living/silicon/robot/cogscarab/cog = new /mob/living/silicon/robot/cogscarab(get_turf(src))
		cog.key = O.key
		if(SSticker.mode.add_clocker(cog.mind))
			cog.create_log(CONVERSION_LOG, "[cog.mind] became clock drone by [user.name]")
		user.unEquip()
		qdel(src)
	else
		visible_message("<span class='notice'>[src] stops to hum. Perhaps you could try again?</span>")
		searching = FALSE

// A real fighter. Doesn't have any ability except passive range reflect chance but a good soldier with solid speed and attack.
/obj/item/clockwork/marauder
	name = "unactivated marauder"
	desc = "The stalwart apparition of a soldier. It looks lifeless."
	icon_state = "marauder_shell"

/obj/item/clockwork/marauder/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/mmi/robotic_brain/clockwork))
		var/obj/item/mmi/robotic_brain/clockwork/soul = I
		if(!soul.brainmob.mind)
			to_chat(user, "<span class='warning'> There is no soul in [I]!</span>")
		var/mob/living/simple_animal/hostile/clockwork/marauder/cog = new /mob/living/simple_animal/hostile/clockwork/marauder(get_turf(src))
		soul.brainmob.mind.transfer_to(cog)
		playsound(cog, 'sound/effects/constructform.ogg', 50)
		qdel(soul)
		user.unEquip(soul)
		qdel(src)

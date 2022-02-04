// A Clockwork slab. Ratvar's tool to cast most of essential spells.
/obj/item/clockwork/clockslab
	name = "Clockwork slab"
	desc = "A strange metal tablet. A clock in the center turns around and around."
	icon = 'icons/obj/clockwork.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "clock_slab"
	w_class = WEIGHT_CLASS_SMALL
	enchant_type = NO_SPELL

/obj/item/clockwork/clockslab/New()
	enchants = GLOB.clockslab_spells
	..()

/obj/item/clockwork/clockslab/update_icon()
	cut_overlays()
	if(enchanted)
		add_overlay("overlay_temp")
	..()

/obj/item/clockwork/clockslab/attack_self(mob/user)
	. = ..()
	if(enchant_type == EMP_SPELL)
		src.visible_message("<span class='warning'>[src] glows with shining blue!</span>")
		empulse(src, 3, 1)
		enchant_type = NO_SPELL
		enchanted = FALSE

/obj/item/clockwork/clockslab/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(enchant_type == STUN_SPELL)
		if(!isliving(target) || isclocker(target) || !proximity)
			return
		var/mob/living/L = target
		var/atom/N = L.null_rod_check()
		if(N)
			src.visible_message("<span class='warning'>[target]'s holy weapon absorbs the light!</span>")
		L.Weaken(5)
		L.Stun(5)
		if(issilicon(L))
			var/mob/living/silicon/S = L
			S.emp_act(EMP_HEAVY)
		else if(iscarbon(target))
			var/mob/living/carbon/C = L
			C.Stuttering(10)
			C.ClockSlur(10)
		src.visible_message("<span class='warning'>[src] sparks as the [target] falls!</span>")
		enchant_type = NO_SPELL
		enchanted = FALSE

/obj/item/clockwork
	name = "Clockwork item name"
	icon = 'icons/obj/clockwork.dmi'
	var/prepared_spell = null

//Ratvarian spear
/obj/item/clockwork/weapon/ratvarian_spear
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	icon_state = "ratvarian_spear"
	item_state = "ratvarian_spear"
	force = 15 //Extra damage is dealt to targets in attack()
	throwforce = 25
	armour_penetration = 10
	sharp = TRUE
	embed_chance = 70
	embedded_ignore_throwspeed_threshold = TRUE
	attack_verb = list("stabbed", "poked", "slashed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_BULKY

/obj/item/clockwork/weapon/ratvarian_spear/New()
	enchants = GLOB.spear_spells
	..()

/obj/item/clockwork/weapon/ratvarian_spear/afterattack(atom/target, mob/user, proximity, params)
	. = ..()


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

/obj/item/clothing/suit/hooded/clockrobe/New()
	enchants = GLOB.robe_spells
	..()

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
	armor = list("melee" = 60, "bullet" = 50, "laser" = 40, "energy" = 30, "bomb" = 60, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/clockwork)

/obj/item/clothing/suit/armor/clockwork/New()
	enchants = GLOB.armour_spells
	..()

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
	strip_delay = 50
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/clockwork/New()
	enchants = GLOB.shoes_spells
	..()

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
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "soul_vessel"
	blank_icon = "soul_vessel"
	searching_icon = "soul_vessel_search"
	occupied_icon = "soul_vessel_occupied"
	desc = "A heavy brass cube, three inches to a side, with a single protruding cogwheel."
	silenced = TRUE
	requires_master = FALSE
	ejected_flavor_text = "brass cube"
	dead_icon = "soul_vessel"

/obj/item/mmi/robotic_brain/clockwork/transfer_personality(mob/candidate)
	. = ..()
	if(.)
		if(SSticker.mode.add_clocker(brainmob.mind))
			brainmob.create_log(CONVERSION_LOG, "[brainmob.mind] been converted by [src.name]")

/obj/item/mmi/robotic_brain/clockwork/attack_self(mob/living/user)
	if(!isclocker(user))
		to_chat(user, "<span class='warning'>You fiddle around with [src], to no avail.</span>")
		return FALSE
	..()

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
		transfer_personality(H)
		qdel()
		add_attack_logs(user, H, "Soul vessel'd with [name]")

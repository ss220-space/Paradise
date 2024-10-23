/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "Plain black gloves without fingertips for the hard working."
	icon_state = "fingerless"
	item_state = "fingerless"
	item_color = null	//So they don't wash.
	transfer_prints = TRUE
	clothing_flags = NONE
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	strip_delay = 40
	put_on_delay = 20
	clipped = 1
	undyeable = TRUE

/obj/item/clothing/gloves/fingerless/weaver
	name = "weaver chitin gloves"
	desc = "Grey gloves without fingertips made from the hide of a dead arachnid found on lavaland. Makes wearer stronger in disarming ability."
	icon_state = "weaver_chitin"
	item_state = "weaver_chitin"
	extra_knock_chance = 20
	var/stamdamage_low = 10
	var/stamdamage_high = 15

/obj/item/clothing/gloves/fingerless/weaver/Touch(atom/A, proximity)
	. = FALSE
	if(!ishuman(loc))
		return FALSE

	var/mob/living/carbon/human/user = loc
	if(!user.mind || user.mind.martial_art)
		return FALSE

	if(!(user.a_intent == INTENT_HARM) || !proximity || isturf(A))
		return FALSE

	var/damage = rand(user.dna.species.punchdamagelow + user.physiology.punch_damage_low, user.dna.species.punchdamagehigh + user.physiology.punch_damage_high)
	var/stamindamage = rand(stamdamage_low, stamdamage_high)
	if(ishuman(A))
		user.do_attack_animation(A, "kick")
		playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, 1, -1)
		var/mob/living/carbon/human/target = A
		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		add_attack_logs(user, target, "Melee attacked with weaver gloves")

		target.visible_message(span_danger("[user] smash [target] with weaver gloves!"))

		target.apply_damage(damage, BRUTE, affecting)
		target.apply_damage(stamindamage, STAMINA, affecting)
		return TRUE

/obj/item/clothing/gloves/cyborg
	desc = "beep boop borp"
	name = "cyborg gloves"
	icon_state = "black"
	item_state = "r_hands"


/obj/item/clothing/gloves/color/black/forensics
	name = "forensics gloves"
	desc = "These high-tech gloves don't leave any material traces on objects they touch. Perfect for leaving crime scenes undisturbed...both before and after the crime."
	icon_state = "forensics"
	can_leave_fibers = FALSE
	transfer_prints = FALSE

/obj/item/clothing/gloves/combat
	desc = "These tactical gloves are both insulated and offer protection from heat sources."
	name = "combat gloves"
	icon_state = "combat"
	item_state = "swat_gl"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 50)

/obj/item/clothing/gloves/bracer
	name = "bone bracers"
	desc = "For when you're expecting to get slapped on the wrist. Offers modest protection to your arms."
	icon_state = "bracers"
	item_state = "bracers"
	item_color = null	//So they don't wash.
	transfer_prints = TRUE
	strip_delay = 40
	body_parts_covered = ARMS
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list("melee" = 15, "bullet" = 25, "laser" = 15, "energy" = 15, "bomb" = 20, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/gloves/botanic_leather
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin."
	name = "botanist's leather gloves"
	icon_state = "leather"
	item_state = "ggloves"
	permeability_coefficient = 0.9
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 30)

/obj/item/clothing/gloves/batmangloves
	desc = "Used for handling all things bat related."
	name = "batgloves"
	icon_state = "bmgloves"
	item_state = "bmgloves"
	item_color="bmgloves"

/obj/item/clothing/gloves/cursedclown
	name = "cursed white gloves"
	desc = "These things smell terrible, and they're all lumpy. Gross."
	icon_state = "latex"
	item_state = "lgloves"


/obj/item/clothing/gloves/cursedclown/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/gloves/color/yellow/stun
	name = "stun gloves"
	desc = "Horrendous and awful. It smells like cancer. The fact it has wires attached to it is incidental."
	var/obj/item/stock_parts/cell/cell = null
	var/stun_strength = 2 SECONDS
	var/stun_cost = 1500

/obj/item/clothing/gloves/color/yellow/stun/get_cell()
	return cell

/obj/item/clothing/gloves/color/yellow/stun/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/gloves/color/yellow/stun/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/clothing/gloves/color/yellow/stun/Touch(atom/A, proximity)
	if(!ishuman(loc))
		return FALSE //Only works while worn
	if(!iscarbon(A))
		return FALSE
	if(!proximity)
		return FALSE
	if(cell)
		var/mob/living/carbon/human/H = loc
		if(H.a_intent == INTENT_HARM)
			var/mob/living/carbon/C = A
			if(cell.use(stun_cost))
				do_sparks(5, 0, loc)
				playsound(loc, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
				H.do_attack_animation(C)
				visible_message("<span class='danger'>[C] has been touched with [src] by [H]!</span>")
				add_attack_logs(H, C, "Touched with stun gloves")
				C.Weaken(stun_strength)
				C.Stuttering(stun_strength)
				C.apply_damage(20, STAMINA)
			else
				to_chat(H, "<span class='notice'>Not enough charge!</span>")
			return TRUE
	return FALSE


/obj/item/clothing/gloves/color/yellow/stun/update_overlays()
	. = ..()
	. += "gloves_wire"
	if(cell)
		. += "gloves_cell"


/obj/item/clothing/gloves/color/yellow/stun/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		add_fingerprint(user)
		if(cell)
			to_chat(user, span_warning("The [name] already has a cell."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You attach [I] to [src]."))
		cell = I
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/clothing/gloves/color/yellow/stun/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(cell)
		to_chat(user, "<span class='notice'>You cut [cell] away from [src].</span>")
		cell.forceMove(get_turf(loc))
		cell = null
		update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/gloves/color/yellow/stun/emp_act()
	if(!ishuman(loc))
		return ..()
	var/mob/living/carbon/human/H = loc
	if(cell?.use(stun_cost))
		H.Weaken(8 SECONDS)
		H.adjustFireLoss(rand(10, 25))
		H.apply_effect(STUTTER, 5 SECONDS)

/obj/item/clothing/gloves/fingerless/rapid
	var/accepted_intents = list(INTENT_HARM)
	var/click_speed_modifier = CLICK_CD_RAPID
	var/mob/living/owner

/obj/item/clothing/gloves/fingerless/rapid/equipped(mob/user, slot, initial)
	owner = user
	if(istype(owner) && slot == ITEM_SLOT_GLOVES)
		owner.dirslash_enabled = TRUE
		add_verb(owner, /obj/item/clothing/gloves/fingerless/rapid/proc/dirslash_enabling)
	. = ..()

/obj/item/clothing/gloves/fingerless/rapid/dropped(mob/user, slot, silent = FALSE)
	remove_verb(owner, /obj/item/clothing/gloves/fingerless/rapid/proc/dirslash_enabling)
	owner.dirslash_enabled = initial(owner.dirslash_enabled)
	. = ..()

/obj/item/clothing/gloves/fingerless/rapid/proc/dirslash_enabling()
	set name = "Enable/Disable direction slash"
	set desc = "If direction slash is enabled, you can attack mobs, by clicking behind their backs"
	set category = "Object"
	var/mob/living/L = usr
	L.dirslash_enabled = !L.dirslash_enabled
	to_chat(src, span_notice("Directrion slash is [L.dirslash_enabled? "enabled" : "disabled"] now."))


/obj/item/clothing/gloves/fingerless/rapid/Touch(mob/living/target, proximity = TRUE)
	var/mob/living/M = loc

	if(M.a_intent in accepted_intents)
		if(M.mind.martial_art)
			M.changeNext_move(CLICK_CD_MELEE)//normal attack speed for hulk, CQC and Carp.
		else
			M.changeNext_move(click_speed_modifier)
	.= FALSE

/obj/item/clothing/gloves/fingerless/rapid/admin
	name = "Advanced Interactive Gloves"
	desc = "The gloves are covered in indecipherable buttons and dials, your mind warps by merely looking at them."
	accepted_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM)
	click_speed_modifier = 0
	siemens_coefficient = 0

/obj/item/clothing/gloves/fingerless/rapid/headpat
	name = "Gloves of Headpats"
	desc = "You feel the irresistable urge to give headpats by merely glimpsing these."
	accepted_intents = list(INTENT_HELP)

/obj/item/clothing/gloves/color/black/razorgloves
	name = "Razor gloves"
	desc = "These are razorgloves! You gotta show these tajarans who are the real deal on this station!"
	icon_state = "razor"
	item_state = "razorgloves"
	can_be_cut = FALSE
	resistance_flags = FLAMMABLE
	sharp = TRUE
	extra_knock_chance = 5
	var/razor_damage_low = 8
	var/razor_damage_high = 9


/obj/item/clothing/gloves/color/black/razorgloves/sharpen_act(obj/item/whetstone/whetstone, mob/user)
	if(razor_damage_low > initial(razor_damage_low))
		to_chat(user, span_warning("[src] has already been refined before. It cannot be sharpened further!"))
		return FALSE
	razor_damage_low = clamp(razor_damage_low + whetstone.increment, 0, whetstone.max)
	razor_damage_high = clamp(razor_damage_high + whetstone.increment, 0, whetstone.max)
	return TRUE


/obj/item/clothing/gloves/color/black/razorgloves/Touch(atom/A, proximity)
	. = FALSE
	if(!ishuman(loc))
		return FALSE

	var/mob/living/carbon/human/user = loc
	if(!user.mind || user.mind.martial_art)
		return FALSE

	if(!(user.a_intent == INTENT_HARM) || !proximity || isturf(A))
		return FALSE

	var/damage = rand(razor_damage_low, razor_damage_high)
	if(ishuman(A))
		user.do_attack_animation(A, "claw")
		var/mob/living/carbon/human/target = A
		add_attack_logs(user, target, "Melee attacked with razor gloves")
		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		var/armor_block = target.run_armor_check(affecting, "melee")
		playsound(target.loc, 'sound/weapons/slice.ogg', 25, 1, -1)

		target.visible_message("<span class='danger'>[user] cuts [target] with razor gloves!</span>")

		var/all_objectives = user?.mind?.get_all_objectives()
		if(target.mind && all_objectives)
			for(var/datum/objective/pain_hunter/objective in all_objectives)
				if(target.mind == objective.target)
					objective.take_damage(damage, BRUTE)

		target.apply_damage(damage, BRUTE, affecting, armor_block, sharp = TRUE)
		return TRUE

	if(isliving(A))
		user.do_attack_animation(A, "claw")
		var/mob/living/living = A
		playsound(living.loc, 'sound/weapons/slice.ogg', 25, 1, -1)
		living.visible_message("<span class='danger'>[user] cuts [living] with razor gloves!</span>")
		living.apply_damage(damage, BRUTE)
		return TRUE

	if(isobj(A) && !isitem(A))
		var/obj/obj = A
		user.do_attack_animation(A, "claw")
		user.changeNext_move(CLICK_CD_MELEE)
		user.visible_message("<span class='danger'>[user] has hit [obj] with razor gloves!</span>", "<span class='danger'>You hit [obj] with razor gloves!</span>")
		obj.take_damage(damage, BRUTE, "melee", 1, get_dir(src, user))
		return TRUE

/obj/item/clothing/gloves/knuckles
	name = "knuckles"
	desc = "The choice of the professional to beat the shit out of some jerk!"
	icon_state = "knuckles"
	item_state = "knuckles"
	sharp = FALSE
	extra_knock_chance = 15 //20% overall
	var/knuckle_damage = 5 //additional fists damage
	var/knock_damage_low = 5 // stamina damage
	var/knock_damage_high = 10 // min and max
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 0)
	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/gloves.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/gloves.dmi')

/obj/item/clothing/gloves/knuckles/Touch(atom/A, proximity)
	. = FALSE
	if(!ishuman(loc))
		return FALSE

	var/mob/living/carbon/human/user = loc
	if(!user.mind || user.mind.martial_art)
		return FALSE

	if(!(user.a_intent == INTENT_HARM) || !proximity || isturf(A))
		return FALSE

	var/damage = knuckle_damage + rand(user.dna.species.punchdamagelow + user.physiology.punch_damage_low, user.dna.species.punchdamagehigh + user.physiology.punch_damage_high)
	var/staminadamage = rand(knock_damage_low, knock_damage_high)
	var/knobj_damage = knuckle_damage + user.dna.species.obj_damage + user.physiology.punch_obj_damage
	if(ishuman(A))
		user.do_attack_animation(A, "kick")
		playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, 1, -1)
		var/mob/living/carbon/human/target = A
		add_attack_logs(user, target, "Melee attacked with knuckles")
		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))

		target.visible_message("<span class='danger'>[user] smash [target] with knuckles!</span>")

		var/all_objectives = user?.mind?.get_all_objectives()
		if(target.mind && all_objectives)
			for(var/datum/objective/pain_hunter/objective in all_objectives)
				if(target.mind == objective.target)
					objective.take_damage(damage, BRUTE)

		target.apply_damage(damage, BRUTE, affecting)
		target.apply_damage(staminadamage, STAMINA, affecting)
		return TRUE

	if(isliving(A))
		var/mob/living/living = A
		user.do_attack_animation(A, "kick")
		playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, 1, -1)
		living.visible_message("<span class='danger'>[user] smash [living] with knuckles!</span>")
		living.apply_damage(damage, BRUTE)
		return TRUE

	if(isobj(A) && !isitem(A))
		var/obj/obj = A
		user.do_attack_animation(A, "kick")
		user.changeNext_move(CLICK_CD_MELEE)
		user.visible_message("<span class='danger'>[user] has hit [obj] with knuckles!</span>", "<span class='danger'>You hit [obj] with knuckles!</span>")
		obj.take_damage(knobj_damage, BRUTE, "melee", 1, get_dir(src, user))
		return TRUE

/obj/item/clothing/gloves/brown_short_gloves
	name = "short leather gloves"
	desc = "Короткие облегающие перчатки из кожи."
	icon_state = "brown_short_gloves"
	item_state = "brown_short_gloves"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/gloves.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/gloves.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/gloves.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/gloves.dmi'
		)

/obj/item/clothing/gloves/combat/swat
	desc = "A pair of gloves made of the best reinforced materials. Protects against the effects of electricity, as well as partially acid and fire. Such gloves cost a fortune, you can say that wearing them, you literally have golden hands!"
	name = "SWAT gloves"
	icon_state = "swat_gloves"
	item_state = "nt_swat_gl"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 50)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/gloves.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/gloves.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/gloves.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/gloves.dmi'
		)


/obj/item/clothing/gloves/combat/swat/syndicate
	desc = "A pair of gloves made of the best reinforced materials. Protects against the effects of electricity, as well as partially acid and fire. Show these NT pigs on your fingers who's the boss here!"
	name = "syndicate armored gloves"
	icon_state = "syndicate_swat"
	item_state = "syndicate_swat_gl"

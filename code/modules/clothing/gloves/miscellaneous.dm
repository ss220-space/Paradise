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
	desc = "Серые беспалые перчатки, сделанные из шкуры мёртвого паукообразного, найденного на Лазисе. Лёгкие и удобные, они позволяют владельцу драться эффективнее в рукопашном бою."
	icon_state = "weaver_chitin"
	item_state = "weaver_chitin"
	extra_knock_chance = 20
	var/stamdamage_low = 10
	var/stamdamage_high = 15

/obj/item/clothing/gloves/fingerless/weaver/get_ru_names()
	return list(
		NOMINATIVE = "перчатки из хитина ткача",
		GENITIVE = "перчаток из хитина ткача",
		DATIVE = "перчаткам из хитина ткача",
		ACCUSATIVE = "перчатки из хитина ткача",
		INSTRUMENTAL = "перчатками из хитина ткача",
		PREPOSITIONAL = "перчатках из хитина ткача"
	)

/obj/item/clothing/gloves/fingerless/weaver/Touch(atom/A, proximity)
	. = FALSE
	if(!ishuman(loc))
		return FALSE

	var/mob/living/carbon/human/user = loc
	if(!user.mind || user.mind.martial_art)
		return FALSE

	if(user.a_intent != INTENT_HARM || !proximity || isturf(A))
		return FALSE

	var/damage = rand(user.dna.species.punchdamagelow + user.physiology.punch_damage_low, user.dna.species.punchdamagehigh + user.physiology.punch_damage_high)
	var/stamindamage = rand(stamdamage_low, stamdamage_high)
	if(ishuman(A))
		user.do_attack_animation(A, "kick")
		playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
		var/mob/living/carbon/human/target = A
		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		add_attack_logs(user, target, "Melee attacked with weaver gloves")

		target.visible_message(span_danger("[user] сокруша[pluralize_ru(user.gender, "ет", "ют")] [target] [declent_ru(INSTRUMENTAL)]!"))

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
	name = "combat gloves"
	desc = "These tactical gloves are both insulated and offer melee protection."
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
	armor = list(MELEE = 25, BULLET = 5, LASER = 5, ENERGY = 10, BOMB = 10, BIO = 0, RAD = 0, FIRE = 70, ACID = 70)

/obj/item/clothing/gloves/combat/riot
	name = "riot gloves"
	desc = "These riot gloves are both insulated and offer melee protection."
	icon_state = "riotgloves"
	item_state = "riotgloves"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/gloves.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/gloves.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/gloves.dmi'
	)

/obj/item/clothing/gloves/bracer
	name = "bone bracers"
	desc = "На случай, если вы ожидаете удара в руку. Обеспечивает достаточную защиту для ваших рук."
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
	armor = list(MELEE = 25, BULLET = 30, LASER = 20, ENERGY = 25, BOMB = 35, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/gloves/bracer/get_ru_names()
	return list(
		NOMINATIVE = "костяные наручи",
		GENITIVE = "костяных наручей",
		DATIVE = "костяным наручам",
		ACCUSATIVE = "костяные наручи",
		INSTRUMENTAL = "костяными наручами",
		PREPOSITIONAL = "костяных наручах"
	)

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
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 70, ACID = 30)

/obj/item/clothing/gloves/batmangloves
	desc = "Used for handling all things bat related."
	name = "batgloves"
	icon_state = "bmgloves"
	item_state = "bmgloves"
	item_color = "bmgloves"

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
	desc = "Эти перчатки не защитят ваших врагов от электрического удара."
	gender = PLURAL
	var/obj/item/stock_parts/cell/cell = null
	var/stun_strength = 2 SECONDS
	var/stun_cost = 1500

/obj/item/clothing/gloves/color/yellow/stun/get_ru_names()
	return list(
		NOMINATIVE = "оглушающие перчатки",
		GENITIVE = "оглушающих перчаток",
		DATIVE = "оглушающим перчаткам",
		ACCUSATIVE = "оглушающие перчатки",
		INSTRUMENTAL = "оглушающими перчатками",
		PREPOSITIONAL = "оглушающих перчатках"
	)

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
				do_sparks(5, FALSE, loc)
				playsound(loc, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
				H.do_attack_animation(C)
				visible_message(span_danger("[H] дотрагива[pluralize_ru(H.gender, "ет", "ют")]ся [declent_ru(INSTRUMENTAL)] до [C]!"))
				add_attack_logs(H, C, "Touched with stun gloves")
				C.Weaken(stun_strength)
				C.Stuttering(stun_strength)
				C.apply_damage(20, STAMINA)
			else
				balloon_alert(H, "недостаточно заряда!")
			return TRUE
	return FALSE


/obj/item/clothing/gloves/color/yellow/stun/update_overlays()
	. = ..()
	. += "gloves_wire"
	if(cell)
		. += "gloves_cell"


/obj/item/clothing/gloves/color/yellow/stun/attackby(obj/item/I, mob/living/user, params)
	if(iscell(I))
		add_fingerprint(user)
		if(cell)
			balloon_alert(user, "батарея уже установлена!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		balloon_alert(user, "присоединено")
		cell = I
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/clothing/gloves/color/yellow/stun/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(cell)
		balloon_alert(user, "отсоединено")
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
	set name = "Атака по направлению"
	set desc = "If direction slash is enabled, you can attack mobs, by clicking behind their backs"
	set category = STATPANEL_OBJECT
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
		var/armor_block = target.run_armor_check(affecting, MELEE)
		playsound(target.loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)

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
		playsound(living.loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
		living.visible_message("<span class='danger'>[user] cuts [living] with razor gloves!</span>")
		living.apply_damage(damage, BRUTE)
		return TRUE

	if(isobj(A) && !isitem(A))
		var/obj/obj = A
		user.do_attack_animation(A, "claw")
		user.changeNext_move(CLICK_CD_MELEE)
		user.visible_message("<span class='danger'>[user] has hit [obj] with razor gloves!</span>", "<span class='danger'>You hit [obj] with razor gloves!</span>")
		obj.take_damage(damage, BRUTE, MELEE, 1, get_dir(src, user))
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
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 0)
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
		playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
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
		playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
		living.visible_message("<span class='danger'>[user] smash [living] with knuckles!</span>")
		living.apply_damage(damage, BRUTE)
		return TRUE

	if(isobj(A) && !isitem(A))
		var/obj/obj = A
		user.do_attack_animation(A, "kick")
		user.changeNext_move(CLICK_CD_MELEE)
		user.visible_message("<span class='danger'>[user] has hit [obj] with knuckles!</span>", "<span class='danger'>You hit [obj] with knuckles!</span>")
		obj.take_damage(knobj_damage, BRUTE, MELEE, 1, get_dir(src, user))
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
	armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 0, RAD = 0, FIRE = 75, ACID = 75)
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

/obj/item/clothing/gloves/reflector
	name = "reflector gloves"
	desc = "Высокотехнологичные перчатки, изготовленные из светоотражающего материала, предназначены для отражения энергетических лучей. Носить их — настоящее испытание для рук!"
	icon_state = "reflector"
	item_state = "reflector"
	armor = list(MELEE = 0, BULLET = 0, LASER = 50, ENERGY = 50, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/gloves.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/gloves.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/gloves.dmi',
		)
	var/list/reflect_zones = list(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
	var/hit_reflect_chance = 50

/obj/item/clothing/gloves/reflector/get_ru_names()
	return list(
		NOMINATIVE = "рефлекторные перчатки",
		GENITIVE = "рефлекторных перчаток",
		DATIVE = "рефлекторнным перчаткам",
		ACCUSATIVE = "рефлекторнные перчатки",
		INSTRUMENTAL = "рефлекторными перчатками",
		PREPOSITIONAL = "рефлекторных перчатках"
	)

/obj/item/clothing/gloves/reflector/IsReflect(def_zone)
	if(!(def_zone in reflect_zones))
		return FALSE
	if(prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/head/helmet/reflector
	name = "reflector hat"
	desc = "Высокотехнологичная шляпа, изготовленная из светоотражающего материала, предназначена для отражения энергетических лучей. В неё встроен защитный визор, который обладает повышенной устойчивостью к кислотам."
	icon_state = "reflector"
	item_state = "reflector"
	flags_inv = HIDEHEADSETS
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH
	dog_fashion = null
	armor = list(MELEE = 10, BULLET = 10, LASER = 60, ENERGY = 60, BOMB = 0, BIO = 0, RAD = 0, FIRE = 90, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/helmet.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/helmet.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/helmet.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/helmet.dmi',
		)
	var/list/reflect_zones = list(BODY_ZONE_HEAD)
	var/hit_reflect_chance = 50

/obj/item/clothing/head/helmet/reflector/get_ru_names()
	return list(
		NOMINATIVE = "рефлекторная шляпа",
		GENITIVE = "рефлекторную шляпу",
		DATIVE = "рефлекторной шляпе",
		ACCUSATIVE = "рефлекторную шляпу",
		INSTRUMENTAL = "рефлекторной шляпой",
		PREPOSITIONAL = "рефлекторной шляпе"
	)

/obj/item/clothing/head/helmet/reflector/IsReflect(def_zone)
	if(!(def_zone in reflect_zones))
		return FALSE
	if(prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/shoes/reflector
	name = "reflector boots"
	desc = "Высокотехнологичные ботинки, изготовленные из светоотражающего материала, предназначены для отражения энергетических лучей. Довольно лёгкая, но не очень удобная обувь."
	icon_state = "reflector"
	item_state = "reflector"
	armor = list(MELEE = 0, BULLET = 0, LASER = 50, ENERGY = 50, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/shoes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/shoes.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/shoes.dmi',
		)
	var/list/reflect_zones = list(BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	var/hit_reflect_chance = 50

/obj/item/clothing/shoes/reflector/get_ru_names()
	return list(
		NOMINATIVE = "рефлекторные ботинки",
		GENITIVE = "рефлекторных ботинок",
		DATIVE = "рефлекторным ботинкам",
		ACCUSATIVE = "рефлекторные ботинки",
		INSTRUMENTAL = "рефлекторными ботинками",
		PREPOSITIONAL = "рефлекторных ботинках"
	)

/obj/item/clothing/shoes/reflector/IsReflect(def_zone)
	if(!(def_zone in reflect_zones))
		return FALSE
	if(prob(hit_reflect_chance))
		return TRUE

#define GIBTONITE_QUALITY_LOW 1
#define GIBTONITE_QUALITY_MEDIUM 2
#define GIBTONITE_QUALITY_HIGH 3
#define PROBABILITY_REFINE_BY_FIRE 50
#define ORESTACK_OVERLAYS_MAX 10
/**********************Mineral ores**************************/

/obj/item/stack/ore
	name = "rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore"
	max_amount = 50
	full_w_class = WEIGHT_CLASS_BULKY
	singular_name = "ore chunk"
	var/points = 0 //How many points this ore gets you from the ore redemption machine
	var/refined_type = null //What this ore defaults to being refined into
	var/list/stack_overlays


/obj/item/stack/ore/update_overlays()
	. = ..()

	if(!stack_overlays)
		stack_overlays = list()

	var/overlays_length = length(stack_overlays)
	var/difference = min(ORESTACK_OVERLAYS_MAX, amount) - (overlays_length + 1)

	if(!difference)
		if(overlays_length)
			. += stack_overlays
		return .

	if(difference < 0)
		var/cut_diff = overlays_length - abs(difference)
		if(cut_diff <= 0)
			stack_overlays.Cut()
			return .
		stack_overlays.Cut(cut_diff, overlays_length)
	else
		for(var/i in 1 to difference)
			var/mutable_appearance/newore = mutable_appearance(icon, icon_state)
			newore.pixel_x = rand(-8,8)
			newore.pixel_y = rand(-8,8)
			stack_overlays += newore

	if(length(stack_overlays))
		. += stack_overlays


/obj/item/stack/ore/Initialize(mapload, new_amount , merge = TRUE)
	. = ..()
	pixel_x = rand(0, 16) - 8
	pixel_y = rand(0, 8) - 8


/obj/item/stack/ore/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!refined_type)
		balloon_alert(usr, "нельзя расплавить!")
		return
	if(!I.use_tool(src, user, 0, 15, volume = I.tool_volume))
		return
	new refined_type(drop_location(), amount)
	balloon_alert(usr, "переплавлено!")
	qdel(src)


/obj/item/stack/ore/on_movable_entered_occupied_turf(atom/movable/arrived)
	if(!istype(loc, /turf/simulated/floor/plating/asteroid) || (!ishuman(arrived) && !isrobot(arrived)))
		return ..()

	var/mob/arrived_mob = arrived
	for(var/obj/item/storage/bag/ore/bag in arrived_mob.get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
		loc.attackby(bag, arrived)
		// Then, if the user is dragging an ore box, empty the satchel into the box.
		if(istype(arrived_mob.pulling, /obj/structure/ore_box))
			arrived_mob.pulling.attackby(bag, arrived)


/obj/item/stack/ore/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	. = ..()
	if(isnull(refined_type))
		return
	else
		var/amountrefined = round((PROBABILITY_REFINE_BY_FIRE / 100) * amount, 1)
		if(amountrefined < 1)
			qdel(src)
		else
			new refined_type(get_turf(loc), amountrefined)
			qdel(src)

/obj/item/stack/ore/uranium
	name = "uranium ore"
	icon_state = "Uranium ore"
	origin_tech = "materials=5"
	singular_name = "uranium ore chunk"
	points = 30
	refined_type = /obj/item/stack/sheet/mineral/uranium
	materials = list(MAT_URANIUM=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/iron
	name = "iron ore"
	icon_state = "Iron ore"
	origin_tech = "materials=1"
	singular_name = "iron ore chunk"
	points = 1
	refined_type = /obj/item/stack/sheet/metal
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/glass
	name = "sand pile"
	icon_state = "Glass ore"
	origin_tech = "materials=1"
	singular_name = "sand pile"
	points = 1
	refined_type = /obj/item/stack/sheet/glass
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)

GLOBAL_LIST_INIT(sand_recipes, list(\
		new /datum/stack_recipe("sandstone", /obj/item/stack/sheet/mineral/sandstone, 1, 1, 50), \
		null, \
		new /datum/stack_recipe("puddle", /obj/structure/sink/puddle, 30, 1, 1, 10 SECONDS, 1, 1)\
		))

/obj/item/stack/ore/glass/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.sand_recipes

/obj/item/stack/ore/glass/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..() || !ishuman(hit_atom))
		return
	var/mob/living/carbon/human/C = hit_atom
	if(C.head && C.head.flags_cover & HEADCOVERSEYES)
		visible_message("<span class='danger'>[C]'s headgear blocks the sand!</span>")
		return
	if(C.wear_mask && C.wear_mask.flags_cover & MASKCOVERSEYES)
		visible_message("<span class='danger'>[C]'s mask blocks the sand!</span>")
		return
	if(C.glasses && C.glasses.flags_cover & GLASSESCOVERSEYES)
		visible_message("<span class='danger'>[C]'s glasses block the sand!</span>")
		return
	C.EyeBlurry(12 SECONDS)
	C.apply_damage(15, STAMINA)//the pain from your eyes burning does stamina damage
	C.AdjustConfused(10 SECONDS)
	to_chat(C, "<span class='userdanger'>[src] gets into your eyes! The pain, it burns!</span>")
	qdel(src)

/obj/item/stack/ore/glass/ex_act(severity)
	if(severity == EXPLODE_NONE)
		return
	qdel(src)

/obj/item/stack/ore/glass/basalt
	name = "volcanic ash"
	icon_state = "volcanic_sand"
	icon_state = "volcanic_sand"
	singular_name = "volcanic ash pile"
	desc = "Looks like you could shove some on a girder to make a false rock wall"

/obj/item/stack/ore/glass/basalt/ancient
	name = "ancient sand"
	icon_state = "volcanic_sand"
	item_state = "volcanic_sand"
	singular_name = "ancient sand pile"

/obj/item/stack/ore/plasma
	name = "plasma ore"
	icon_state = "Plasma ore"
	origin_tech = "plasmatech=2;materials=2"
	singular_name = "plasma ore chunk"
	points = 15
	refined_type = /obj/item/stack/sheet/mineral/plasma
	materials = list(MAT_PLASMA=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/silver
	name = "silver ore"
	icon_state = "Silver ore"
	origin_tech = "materials=3"
	singular_name = "silver ore chunk"
	points = 16
	refined_type = /obj/item/stack/sheet/mineral/silver
	materials = list(MAT_SILVER=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/gold
	name = "gold ore"
	icon_state = "Gold ore"
	origin_tech = "materials=4"
	singular_name = "gold ore chunk"
	points = 18
	refined_type = /obj/item/stack/sheet/mineral/gold
	materials = list(MAT_GOLD=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/diamond
	name = "diamond ore"
	icon_state = "Diamond ore"
	origin_tech = "materials=6"
	singular_name = "diamond ore chunk"
	points = 50
	refined_type = /obj/item/stack/sheet/mineral/diamond
	materials = list(MAT_DIAMOND=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/bananium
	name = "bananium ore"
	icon_state = "Clown ore"
	origin_tech = "materials=4"
	singular_name = "bananium ore chunk"
	points = 60
	refined_type = /obj/item/stack/sheet/mineral/bananium
	materials = list(MAT_BANANIUM=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/tranquillite
	name = "tranquillite ore"
	icon_state = "Mime ore"
	origin_tech = "materials=4"
	singular_name = "transquillite ore chunk"
	points = 60
	refined_type = /obj/item/stack/sheet/mineral/tranquillite
	materials = list(MAT_TRANQUILLITE=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/titanium
	name = "titanium ore"
	icon_state = "Titanium ore"
	singular_name = "titanium ore chunk"
	points = 50
	materials = list(MAT_TITANIUM=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/titanium

/obj/item/stack/ore/slag
	name = "slag"
	desc = "Completely useless"
	icon_state = "slag"
	singular_name = "slag chunk"

/obj/item/twohanded/required/gibtonite
	name = "gibtonite ore"
	desc = "Extremely explosive if struck with mining equipment, Gibtonite is often used by miners to speed up their work by using it as a mining charge. This material is illegal to possess by unauthorized personnel under space law."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Gibtonite ore"
	item_state = "Gibtonite ore"
	w_class = WEIGHT_CLASS_BULKY
	throw_range = 0
	var/primed = FALSE
	var/det_time = 10 SECONDS
	var/quality = GIBTONITE_QUALITY_LOW //How pure this gibtonite is, determines the explosion produced by it and is derived from the det_time of the rock wall it was taken from, higher value = better
	var/attacher = "UNKNOWN"
	var/datum/wires/explosive/gibtonite/wires


/obj/item/twohanded/required/gibtonite/Destroy()
	if(wires)
		SStgui.close_uis(wires)
		QDEL_NULL(wires)
	return ..()


/obj/item/twohanded/required/gibtonite/can_be_pulled(atom/movable/puller, grab_state, force, supress_message)
	if(!supress_message && ismob(puller))
		balloon_alert(puller, "слишком тяжело!")
	return FALSE // must be carried in two hands or be picked up with ripley


/obj/item/twohanded/required/gibtonite/update_icon_state()
	switch(quality)
		if(GIBTONITE_QUALITY_LOW)
			icon_state = "Gibtonite ore"
		if(GIBTONITE_QUALITY_MEDIUM)
			icon_state = "Gibtonite ore 2"
		if(GIBTONITE_QUALITY_HIGH)
			icon_state = "Gibtonite ore 3"


/obj/item/twohanded/required/gibtonite/update_overlays()
	. = ..()
	if(wires)
		. += "Gibtonite_igniter"


/obj/item/twohanded/required/gibtonite/attackby(obj/item/I, mob/user, params)
	if(isigniter(I))
		add_fingerprint(user)
		if(wires)
			to_chat(user, span_warning("Already installed."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		user.visible_message(
			span_warning("[user] has attached [I] to [src]."),
			span_notice("You have attached [I] to [src]."),
		)
		wires = new(src)
		attacher = key_name(user)
		update_icon(UPDATE_OVERLAYS)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(primed)
		var/static/list/prime_stoppers = typecacheof(list(
			/obj/item/mining_scanner,
			/obj/item/t_scanner/adv_mining_scanner,
			/obj/item/mecha_parts/mecha_equipment/mining_scanner,
		))
		if(is_type_in_typecache(I, prime_stoppers))
			add_fingerprint(user)
			primed = FALSE
			user.visible_message(
				span_notice("The chain reaction has been stopped! ...The ore's quality looks diminished though."),
				span_notice("You have stopped the chain reaction. ...The ore's quality looks diminished though."),
			)
			quality = GIBTONITE_QUALITY_LOW
			update_icon(UPDATE_ICON_STATE)
			return ATTACK_CHAIN_PROCEED_SUCCESS

	if(wires && !primed && issignaler(I))
		wires.Interact(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(I.force >= 10 || istype(I, /obj/item/pickaxe) || istype(I, /obj/item/resonator))
		GibtoniteReaction(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/twohanded/required/gibtonite/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!wires || primed)
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	wires.Interact(user)


/obj/item/twohanded/required/gibtonite/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(primed)
		if(!I.use_tool(src, user, volume = I.tool_volume))
			return .
		primed = FALSE
		user.visible_message(
			span_notice("The chain reaction has been stopped! ...The ore's quality looks diminished though."),
			span_notice("You have stopped the chain reaction. ...The ore's quality looks diminished though."),
		)
		quality = GIBTONITE_QUALITY_LOW
		update_icon(UPDATE_ICON_STATE)
		return .
	if(!wires)
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	wires.Interact(user)


/obj/item/twohanded/required/gibtonite/attack_ghost(mob/user)
	if(wires)
		wires.Interact(user)

/obj/item/twohanded/required/gibtonite/attack_self(mob/user)
	if(wires)
		wires.Interact(user)
	else
		..()

/obj/item/twohanded/required/gibtonite/bullet_act(var/obj/item/projectile/P)
	GibtoniteReaction(P.firer)
	..()

/obj/item/twohanded/required/gibtonite/ex_act()
	GibtoniteReaction(null, 1)

/obj/item/twohanded/required/gibtonite/proc/GibtoniteReaction(mob/user, triggered_by = 0)
	if(!primed)
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		primed = 1
		icon_state = "Gibtonite active"
		var/turf/bombturf = get_turf(src)
		var/notify_admins = 0
		if(!is_mining_level(z))//Only annoy the admins ingame if we're triggered off the mining zlevel
			notify_admins = 1

		if(notify_admins)
			if(triggered_by == 1)
				message_admins("An explosion has triggered a [name] to detonate at [ADMIN_COORDJMP(bombturf)].")
			else if(triggered_by == 2)
				message_admins("A signal has triggered a [name] to detonate at [ADMIN_COORDJMP(bombturf)]. Igniter attacher: [key_name_admin(attacher)]")
			else
				message_admins("[key_name_admin(user)] has triggered a [name] to detonate at [ADMIN_COORDJMP(bombturf)].")
		if(triggered_by == 1)
			add_game_logs("An explosion has primed a [name] for detonation at [AREACOORD(bombturf)]")
		else if(triggered_by == 2)
			add_game_logs("A signal has primed a [name] for detonation at [AREACOORD(bombturf)]). Igniter attacher: [key_name(attacher)].")
		else
			user.visible_message("<span class='warning'>[user] strikes \the [src], causing a chain reaction!</span>", "<span class='danger'>You strike \the [src], causing a chain reaction.</span>")
			add_game_logs("has primed a [name] for detonation at [AREACOORD(bombturf)])", user)
		spawn(det_time)
		if(primed)
			switch(quality)
				if(GIBTONITE_QUALITY_HIGH)
					explosion(src.loc,2,4,9,adminlog = notify_admins, cause = src)
				if(GIBTONITE_QUALITY_MEDIUM)
					explosion(src.loc,1,2,5,adminlog = notify_admins, cause = src)
				if(GIBTONITE_QUALITY_LOW)
					explosion(src.loc,-1,1,3,adminlog = notify_admins, cause = src)
			if(!QDELETED(src))
				qdel(src)


/obj/item/stack/ore/ex_act(severity)
	if(!severity || severity >= 2)
		return
	qdel(src)


/*****************************Coin********************************/

/obj/item/coin
	icon = 'icons/obj/economy.dmi'
	name = "coin"
	icon_state = "coin__heads"
	flags = CONDUCT
	force = 1
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	pickup_sound = 'sound/items/handling/ring_pickup.ogg'
	drop_sound = 'sound/items/handling/ring_drop.ogg'
	var/string_attached = FALSE
	var/list/sideslist = list("heads","tails")
	var/cmineral = null
	var/name_by_cmineral = TRUE
	var/cooldown = 0
	var/credits = 10

/obj/item/coin/New()
	..()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

	icon_state = "coin_[cmineral]_[sideslist[1]]"
	if(cmineral && name_by_cmineral)
		name = "[cmineral] coin"

/obj/item/coin/gold
	cmineral = "gold"
	icon_state = "coin_gold_heads"
	materials = list(MAT_GOLD = 400)
	credits = 160

/obj/item/coin/silver
	cmineral = "silver"
	icon_state = "coin_silver_heads"
	materials = list(MAT_SILVER = 400)
	credits = 40

/obj/item/coin/diamond
	cmineral = "diamond"
	icon_state = "coin_diamond_heads"
	materials = list(MAT_DIAMOND = 400)
	credits = 120

/obj/item/coin/iron
	cmineral = "iron"
	icon_state = "coin_iron_heads"
	materials = list(MAT_METAL = 400)
	credits = 20

/obj/item/coin/plasma
	cmineral = "plasma"
	icon_state = "coin_plasma_heads"
	materials = list(MAT_PLASMA = 400)
	credits = 80

/obj/item/coin/uranium
	cmineral = "uranium"
	icon_state = "coin_uranium_heads"
	materials = list(MAT_URANIUM = 400)
	credits = 160

/obj/item/coin/clown
	cmineral = "bananium"
	icon_state = "coin_bananium_heads"
	materials = list(MAT_BANANIUM = 400)
	credits = 600 //makes the clown cri

/obj/item/coin/mime
	cmineral = "tranquillite"
	icon_state = "coin_tranquillite_heads"
	materials = list(MAT_TRANQUILLITE = 400)
	credits = 600 //makes the mime cri

/obj/item/coin/adamantine
	cmineral = "adamantine"
	icon_state = "coin_adamantine_heads"
	credits = 400

/obj/item/coin/mythril
	cmineral = "mythril"
	icon_state = "coin_mythril_heads"
	credits = 400

/obj/item/coin/twoheaded
	cmineral = "iron"
	icon_state = "coin_iron_heads"
	desc = "Hey, this coin's the same on both sides!"
	sideslist = list("heads")
	credits = 20

/obj/item/coin/twoheaded/thief
	name = "монета Гильдии Воров"
	icon_state = "coin_thief_heads"
	cmineral = "thief"
	desc = "Монета Гильдии Воров, которую выдают каждому уважающему себя члену гильдии для взаимной идентификации. Странный сплав с изображением бюстов черной и белой кошки, стоящих спиной к спине. Ценится коллекционерами, и как правило у них же и возвращают."
	credits = 600

/obj/item/coin/antagtoken
	name = "antag token"
	icon_state = "coin_valid_valid"
	cmineral = "valid"
	desc = "A novelty coin that helps the heart know what hard evidence cannot prove."
	sideslist = list("valid", "salad")
	credits = 20
	name_by_cmineral = FALSE

/obj/item/coin/antagtoken/syndicate
	name = "syndicate coin"
	credits = 160


/obj/item/coin/update_overlays()
	. = ..()
	if(string_attached)
		. += "coin_string_overlay"


/obj/item/coin/attackby(obj/item/I, mob/user, params)
	if(iscoil(I))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(string_attached)
			balloon_alert(user, "уже прикреплено!")
			return ATTACK_CHAIN_PROCEED
		if(!coil.use(1))
			balloon_alert(user, "недостаточно кабеля")
			return ATTACK_CHAIN_PROCEED
		string_attached = TRUE
		update_icon(UPDATE_OVERLAYS)
		balloon_alert(user, "прикреплено!")
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return  ..()


/obj/item/coin/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!string_attached)
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	balloon_alert(user, "кабель срезан")
	string_attached = FALSE
	update_icon(UPDATE_OVERLAYS)
	var/obj/item/stack/cable_coil/coil = new(drop_location(), 1)
	transfer_fingerprints_to(coil)
	coil.add_fingerprint(user)


/obj/item/coin/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/typelist = list("iron" = /obj/item/clothing/gloves/ring,
						"silver" = /obj/item/clothing/gloves/ring/silver,
						"gold" = /obj/item/clothing/gloves/ring/gold,
						"plasma" = /obj/item/clothing/gloves/ring/plasma,
						"uranium" = /obj/item/clothing/gloves/ring/uranium)
	var/typekey = typelist[cmineral]
	if(ispath(typekey))
		to_chat(user, "<span class='notice'>You make [src] into a ring.</span>")
		new typekey(get_turf(loc))
		qdel(src)


/obj/item/coin/attack_self(mob/user)
	if(cooldown < world.time - 15)
		var/coinflip = pick(sideslist)
		cooldown = world.time
		flick("coin_[cmineral]_flip", src)
		icon_state = "coin_[cmineral]_[coinflip]"
		playsound(user.loc, 'sound/items/coinflip.ogg', 50, 1)
		if(do_after(user, 1.5 SECONDS, src))
			user.visible_message("<span class='notice'>[user] has flipped [src]. It lands on [coinflip].</span>", \
								 "<span class='notice'>You flip [src]. It lands on [coinflip].</span>", \
								 "<span class='notice'>You hear the clattering of loose change.</span>")

/obj/item/coin/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(istype(throwingdatum?.thrower?.mind?.martial_art, /datum/martial_art/mr_chang))
		throwingdatum.thrower.say(pick("Сдачу, пожалуйста!", "За сущие копейки!", "Сдачу!", "Кэшбек в кредит!"))
		embed_chance = 30
		embedded_impact_pain_multiplier = 2
		embedded_ignore_throwspeed_threshold = TRUE
		sharp = TRUE
	. = ..()

/obj/item/coin/after_throw(datum/callback/callback)
	embed_chance = initial(embed_chance)
	embedded_impact_pain_multiplier = initial(embedded_impact_pain_multiplier)
	embedded_ignore_throwspeed_threshold = initial(embedded_ignore_throwspeed_threshold)
	sharp = initial(sharp)
	. = ..()

#undef GIBTONITE_QUALITY_LOW
#undef GIBTONITE_QUALITY_MEDIUM
#undef GIBTONITE_QUALITY_HIGH
#undef PROBABILITY_REFINE_BY_FIRE
#undef ORESTACK_OVERLAYS_MAX

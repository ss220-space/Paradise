/* Kitchen tools
 * Contains:
 *		Utensils
 *		Spoons
 *		Forks
 *		Knives
 *		Kitchen knives
 *		Butcher's cleaver
 *		Rolling Pins
 *		Candy Moulds
 *		Sushi Mat
 *		Circular cutter
 */

/obj/item/kitchen
	icon = 'icons/obj/kitchen.dmi'
	origin_tech = "materials=1"




/*
 * Utensils
 */
/obj/item/kitchen/utensil
	force = 5.0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0.0
	throw_speed = 3
	throw_range = 5
	flags = CONDUCT
	attack_verb = list("attacked", "stabbed", "poked")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	sharp = 0
	var/max_contents = 1


/obj/item/kitchen/utensil/Initialize(mapload)
	. = ..()

	if(prob(60))
		set_base_pixel_y(rand(0, 4))

	create_reagents(5)


/obj/item/kitchen/utensil/update_overlays()
	. = ..()
	var/obj/item/reagent_containers/food/snack = locate() in src
	if(snack)
		var/mutable_appearance/food_olay = mutable_appearance('icons/obj/kitchen.dmi', "loadedfood", color = snack.filling_color)
		food_olay.pixel_w = pixel_x
		food_olay.pixel_z = pixel_y
		. += food_olay


/obj/item/kitchen/utensil/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!iscarbon(target))
		return ..()

	if(user.a_intent != INTENT_HELP)
		if(user.zone_selected == BODY_ZONE_HEAD || user.zone_selected == BODY_ZONE_PRECISE_EYES)
			if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
				target = user
			return eyestab(target, user)
		return ..()

	. = ATTACK_CHAIN_PROCEED
	if(!length(contents))
		return .

	var/obj/item/reagent_containers/food/snacks/toEat = contents[1]
	if(!istype(toEat))
		return .

	if(!get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		if(target == user)
			to_chat(user, span_warning("Your face is obscured."))
		else
			to_chat(user, span_warning("[target]'s face is obscured."))
		return .

	if(target.eat(toEat, user))
		toEat.On_Consume(target, user)
		update_icon(UPDATE_OVERLAYS)
		return .|ATTACK_CHAIN_SUCCESS


/obj/item/kitchen/utensil/fork
	name = "fork"
	desc = "It's a fork. Sure is pointy."
	icon_state = "fork"

/obj/item/kitchen/utensil/pfork
	name = "plastic fork"
	desc = "Yay, no washing up to do."
	icon_state = "pfork"

/obj/item/kitchen/utensil/spoon
	name = "spoon"
	desc = "It's a spoon. You can see your own upside-down face in it."
	icon_state = "spoon"
	attack_verb = list("attacked", "poked")

/obj/item/kitchen/utensil/pspoon
	name = "plastic spoon"
	desc = "It's a plastic spoon. How dull."
	icon_state = "pspoon"
	attack_verb = list("attacked", "poked")

/obj/item/kitchen/utensil/spork
	name = "spork"
	desc = "It's a spork. Marvel at its innovative design."
	icon_state = "spork"
	attack_verb = list("attacked", "sporked")

/obj/item/kitchen/utensil/pspork
	name = "plastic spork"
	desc = "It's a plastic spork. It's the fork side of the spoon!"
	icon_state = "pspork"
	attack_verb = list("attacked", "sporked")

/*
 * Knives
 */
/obj/item/kitchen/knife
	name = "kitchen knife"
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags = CONDUCT
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	pickup_sound = 'sound/items/handling/knife_pickup.ogg'
	drop_sound = 'sound/items/handling/knife_drop.ogg'
	throw_speed = 3
	throw_range = 6
	materials = list(MAT_METAL=12000)
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = TRUE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	embed_chance = 45
	embedded_ignore_throwspeed_threshold = TRUE
	/// Can this item be attached as a bayonet to the gun?
	var/bayonet_suitable = FALSE
	/// Used in combination with throwing martial art, to avoid sharpening checks overhead
	var/default_force
	/// Same as above
	var/default_throwforce


/obj/item/kitchen/knife/Initialize(mapload)
	. = ..()
	default_force = force
	default_throwforce = throwforce


/obj/item/kitchen/knife/sharpen_act(obj/item/whetstone/whetstone, mob/user)
	. = ..()
	default_force = force
	default_throwforce = throwforce


/obj/item/kitchen/knife/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting [user.p_their()] wrists with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting [user.p_their()] throat with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku.</span>"))
	return BRUTELOSS

/obj/item/kitchen/knife/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = INFINITY, dodgeable = TRUE)
	. = ..()
	playsound(src, 'sound/weapons/knife_holster/knife_throw.ogg', 30, 1)


/obj/item/kitchen/knife/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/datum/martial_art/throwing/MA = throwingdatum?.thrower?.mind?.martial_art
	if(istype(MA) && is_type_in_list(src, MA.knife_types, FALSE))
		embed_chance = MA.knife_embed_chance
		throwforce = default_throwforce + MA.knife_bonus_damage
		shields_penetration = initial(shields_penetration) + MA.shields_penetration_bonus
	return ..()


/obj/item/kitchen/knife/after_throw(datum/callback/callback)
	embed_chance = initial(embed_chance)
	throwforce = default_throwforce
	shields_penetration = initial(shields_penetration)
	return ..()


/obj/item/kitchen/knife/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	var/datum/martial_art/throwing/MA = user?.mind?.martial_art
	if(istype(MA) && is_type_in_list(src, MA.knife_types, FALSE))
		force = default_force + MA.knife_bonus_damage
		if(user.zone_selected == BODY_ZONE_HEAD && user.a_intent == INTENT_HARM)
			if(MA.neck_cut(target, user))
				return ATTACK_CHAIN_PROCEED_SUCCESS
	. = ..()
	force = default_force


/obj/item/kitchen/knife/attack_obj(obj/object, mob/living/user, params)
	var/datum/martial_art/throwing/MA = user?.mind?.martial_art
	if(istype(MA) && is_type_in_list(src, MA.knife_types, FALSE))
		force = default_force + MA.knife_bonus_damage
	. = ..()
	force = default_force


/obj/item/kitchen/knife/plastic
	name = "plastic knife"
	desc = "The bluntest of blades."
	icon_state = "pknife"
	item_state = "knife"
	sharp = 0
	pickup_sound = 'sound/items/handling/bone_pickup.ogg'
	drop_sound = 'sound/items/handling/bone_drop.ogg'

/obj/item/kitchen/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/kitchen/knife/butcher
	name = "butcher's cleaver"
	icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	flags = CONDUCT
	force = 15
	throwforce = 8
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/kitchen/knife/butcher/meatcleaver
	name = "meat cleaver"
	icon_state = "mcleaver"
	item_state = "mcleaver"
	force = 25
	throwforce = 15

/obj/item/kitchen/knife/combat
	name = "combat knife"
	icon_state = "combatknife"
	item_state = "knife"
	belt_icon = "combat_knife"
	desc = "A military combat utility survival knife."
	force = 20
	throwforce = 20
	origin_tech = "materials=3;combat=4"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "cut")
	bayonet_suitable = TRUE
	embed_chance = 90

/obj/item/kitchen/knife/combat/survival
	name = "survival knife"
	icon_state = "survivalknife"
	belt_icon = "survival_knife"
	desc = "A hunting grade survival knife."
	force = 15
	throwforce = 15

/obj/item/kitchen/knife/combat/throwing
	name = "throwing knife"
	desc = "A well-sharpened black knife. Designed to be thrown. It is made from a single piece of metal. The markings are scratched.\nAn excellent solution for live problems and cake cutting."
	icon_state = "throwingknife"
	item_state = "throwingknife"
	belt_icon = "survival_knife"
	force = 15
	throwforce = 15

/obj/item/kitchen/knife/combat/survival/bone
	name = "bone dagger"
	item_state = "bone_dagger"
	icon_state = "bone_dagger"
	belt_icon = "bone_dagger"
	desc = "A sharpened bone. The bare minimum in survival."
	materials = list()
	pickup_sound = 'sound/items/handling/bone_pickup.ogg'
	drop_sound = 'sound/items/handling/bone_drop.ogg'

/obj/item/kitchen/knife/combat/cyborg
	name = "cyborg knife"
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "knife"
	desc = "A cyborg-mounted plasteel knife. Extremely sharp and durable."
	origin_tech = null

/obj/item/kitchen/knife/combat/cyborg/mecha
	force = 25
	armour_penetration = 20
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	materials = null

/obj/item/kitchen/knife/carrotshiv
	name = "carrot shiv"
	icon_state = "carrotshiv"
	item_state = "carrotshiv"
	desc = "Unlike other carrots, you should probably keep this far away from your eyes."
	force = 8
	throwforce = 12 //fuck git
	materials = list()
	origin_tech = "biotech=3;combat=2"
	attack_verb = list("shanked", "shivved")
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	pickup_sound = 'sound/items/handling/bone_pickup.ogg'
	drop_sound = 'sound/items/handling/bone_drop.ogg'

/obj/item/kitchen/knife/glassshiv
	name = "glass shiv"
	icon_state = "glass_shiv"
	item_state = "knife"
	desc = "A glass shard with some cloth wrapped around it"
	force = 7
	throwforce = 8
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	attack_verb = list("shanked", "shivved")
	armor = list("melee" = 100, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 100)
	pickup_sound = 'sound/items/handling/bone_pickup.ogg'
	drop_sound = 'sound/items/handling/bone_drop.ogg'
	var/size


/obj/item/kitchen/knife/glassshiv/Initialize(mapload, obj/item/shard/sh)
	. = ..()
	if(sh)
		size = sh.icon_state
	if(!size)
		size = pick("large", "medium", "small")
	update_icon(UPDATE_ICON_STATE)


/obj/item/kitchen/knife/glassshiv/update_icon_state()
	icon_state = "[size]_[initial(icon_state)]"


/obj/item/kitchen/knife/glassshiv/plasma
	name = "plasma glass shiv"
	desc = "A plasma glass shard with some cloth wrapped around it"
	force = 9
	throwforce = 11
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT * 0.5, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)

/*
 * Rolling Pins
 */

/obj/item/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	force = 8.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")

/* Trays moved to /obj/item/storage/bag */

/*
 * Candy Moulds
 */

/obj/item/kitchen/mould
	name = "generic candy mould"
	desc = "You aren't sure what it's supposed to be."
	icon_state = "mould"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")

/obj/item/kitchen/mould/bear
	name = "bear-shaped candy mould"
	desc = "It has the shape of a small bear imprinted into it."
	icon_state = "mould_bear"

/obj/item/kitchen/mould/worm
	name = "worm-shaped candy mould"
	desc = "It has the shape of a worm imprinted into it."
	icon_state = "mould_worm"

/obj/item/kitchen/mould/bean
	name = "bean-shaped candy mould"
	desc = "It has the shape of a bean imprinted into it."
	icon_state = "mould_bean"

/obj/item/kitchen/mould/ball
	name = "ball-shaped candy mould"
	desc = "It has a small sphere imprinted into it."
	icon_state = "mould_ball"

/obj/item/kitchen/mould/cane
	name = "cane-shaped candy mould"
	desc = "It has the shape of a cane imprinted into it."
	icon_state = "mould_cane"

/obj/item/kitchen/mould/cash
	name = "cash-shaped candy mould"
	desc = "It has the shape and design of fake money imprinted into it."
	icon_state = "mould_cash"

/obj/item/kitchen/mould/coin
	name = "coin-shaped candy mould"
	desc = "It has the shape of a coin imprinted into it."
	icon_state = "mould_coin"

/obj/item/kitchen/mould/loli
	name = "sucker mould"
	desc = "It has the shape of a sucker imprinted into it."
	icon_state = "mould_loli"

/*
 * Sushi Mat
 */
/obj/item/kitchen/sushimat
	name = "Sushi Mat"
	desc = "A wooden mat used for efficient sushi crafting."
	icon_state = "sushi_mat"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("rolled", "cracked", "battered", "thrashed")



/// circular cutter by Ume

/obj/item/kitchen/cutter
	name = "generic circular cutter"
	desc = "A generic circular cutter for cookies and other things."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "circular_cutter"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bashed", "slashed", "pricked", "thrashed")

/* Two-handed Weapons
 * Contains:
 * 		Twohanded
 *		Fireaxe
 *		Double-Bladed Energy Swords
 *		Spears
 *		Kidan spear
 *		Chainsaw
 *		Singularity hammer
 * 		Mjolnnir
 *		Knighthammer
 *      Pyro Claws
 */

/*##################################################################
##################### TWO HANDED WEAPONS BE HERE~ -Agouri :3 ########
####################################################################*/

//Rewrote TwoHanded weapons stuff and put it all here. Just copypasta fireaxe to make new ones ~Carn
//This rewrite means we don't have two variables for EVERY item which are used only by a few weapons.
//It also tidies stuff up elsewhere.
//
//										ALL TWOHANDED WEAPONS ARE BASED ON COMPONENT FROM NOW ON
//												SEE TWOHANDED.DM FOR DOCUMENTATION
//

/*
 * Twohanded
 */
/obj/item/twohanded
	//All these vars used only for component initialization (twohanded.dm)
	//`wielded` is actually changed in component, because i'm too lazy to replace it everywhere. At least for now.
	//But you can use HAS_TRAIT(src, TRAIT_WIELDED) to emulate same behavior.
	var/wielded = FALSE
	var/force_unwielded = 0
	var/force_wielded = 0
	var/wieldsound = FALSE
	var/unwieldsound = FALSE
	var/sharp_when_wielded = FALSE


/obj/item/twohanded/Initialize(mapload)
	. = ..()
	apply_twohanded_component()


/**
 * Proc handles adding component during Initialize()
 *
 * Applies general twohanded component based on item vars. You can easily override this proc for child items to avoid inheritance.
 * Component is flexible and will rewrite old initial values to new ones if needed.
 */
/obj/item/twohanded/proc/apply_twohanded_component()
	AddComponent(/datum/component/two_handed, \
		force_unwielded = src.force_unwielded, \
		force_wielded = src.force_wielded, \
		wieldsound = src.wieldsound, \
		unwieldsound = src.unwieldsound, \
		sharp_when_wielded = src.sharp_when_wielded, \
		wield_callback = CALLBACK(src, PROC_REF(wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(unwield)) \
	)


/**
 * Generic CALLBACK when twohanded item get `wielded`. Avoid inheritance unless you know what you are doing.
 *
 * Parameters actually useless since you can use `src` and `usr` already.
 */
/obj/item/twohanded/proc/wield(obj/item/source, mob/living/carbon/user)


/**
 * Generic CALLBACK when twohanded item get `UNwielded`. Avoid inheritance unless you know what you are doing.
 *
 * Parameters actually useless since you can use `src` and `usr` already.
 */
/obj/item/twohanded/proc/unwield(obj/item/source, mob/living/carbon/user)


///////////Two hand required objects///////////////
//This is for objects that require two hands to even pick up
/obj/item/twohanded/required
	w_class = WEIGHT_CLASS_HUGE


//We are adding new parameter to old component
/obj/item/twohanded/required/apply_twohanded_component()
	..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)


/*
 * Fireaxe
 */
/obj/item/twohanded/fireaxe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	throwforce = 15
	sharp = TRUE
	embed_chance = 25
	embedded_ignore_throwspeed_threshold = TRUE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force_unwielded = 5
	force_wielded = 24
	toolspeed = 0.25
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = 'sound/items/crowbar.ogg'
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 30)
	resistance_flags = FIRE_PROOF


/obj/item/twohanded/fireaxe/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	icon_state = "fireaxe[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/fireaxe/afterattack(atom/A, mob/user, proximity, params)
	if(!proximity)
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED)) //destroys windows and grilles in one hit
		if(istype(A, /obj/structure/window) || istype(A, /obj/structure/grille))
			var/obj/structure/W = A
			W.obj_destruction("fireaxe")

/obj/item/twohanded/fireaxe/boneaxe  // Blatant imitation of the fireaxe, but made out of bone.
	icon_state = "bone_axe0"
	name = "bone axe"
	desc = "A large, vicious axe crafted out of several sharpened bone plates and crudely tied together. Made of monsters, by killing monsters, for killing monsters."
	force_wielded = 23
	needs_permit = TRUE


/obj/item/twohanded/fireaxe/boneaxe/update_icon_state()
	icon_state = "bone_axe[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/fireaxe/energized
	desc = "Someone with a love for fire axes decided to turn this one into a high-powered energy weapon. Seems excessive."
	force_wielded = 30
	armour_penetration = 20
	var/charge = 30
	var/max_charge = 30


/obj/item/twohanded/fireaxe/energized/update_icon_state()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		icon_state = "fireaxe2"
	else
		icon_state = "fireaxe0"


/obj/item/twohanded/fireaxe/energized/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/twohanded/fireaxe/energized/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/twohanded/fireaxe/energized/process()
	charge = min(charge + 1, max_charge)


/obj/item/twohanded/fireaxe/energized/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !HAS_TRAIT(src, TRAIT_WIELDED) || charge != max_charge)
		return .

	charge = 0
	playsound(loc, 'sound/magic/lightningbolt.ogg', 5, TRUE)
	user.visible_message(
		span_danger("[user] slams the charged axe into [target.name] with all [user.p_their()] might!"),
		span_warning("You have slammed the charged axe into [target.name] with all your might!"),
	)
	do_sparks(1, 1, src)
	target.Weaken(6 SECONDS)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	INVOKE_ASYNC(target, TYPE_PROC_REF(/atom/movable, throw_at), throw_target, 5, 1)


/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/twohanded/dualsaber
	var/hacked = FALSE
	var/blade_color
	icon_state = "dualsaber0"
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/w_class_on = WEIGHT_CLASS_BULKY
	item_flags = NOSHARPENING
	force_unwielded = 3
	force_wielded = 34
	wieldsound = 'sound/weapons/saberon.ogg'
	unwieldsound = 'sound/weapons/saberoff.ogg'
	armour_penetration = 35
	origin_tech = "magnets=4;syndicate=5"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 75
	sharp_when_wielded = TRUE // only sharp when wielded
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70)
	resistance_flags = FIRE_PROOF
	light_power = 2
	light_range = 2
	light_on = FALSE
	light_system = MOVABLE_LIGHT
	needs_permit = TRUE
	var/colormap = list(red=LIGHT_COLOR_RED, blue=LIGHT_COLOR_LIGHTBLUE, green=LIGHT_COLOR_GREEN, purple=LIGHT_COLOR_PURPLE, yellow=LIGHT_COLOR_RED, pink =LIGHT_COLOR_PURPLE, orange =LIGHT_COLOR_RED, darkblue=LIGHT_COLOR_LIGHTBLUE, rainbow=LIGHT_COLOR_WHITE)


/obj/item/twohanded/dualsaber/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, PROC_REF(on_wield))	//We need to listen for item wield
	if(!blade_color)
		blade_color = pick("red", "blue", "green", "purple", "yellow", "pink", "orange", "darkblue")


/obj/item/twohanded/dualsaber/proc/on_wield(obj/item/source, mob/living/carbon/user)
	if(HAS_TRAIT(user, TRAIT_HULK))
		to_chat(user, span_warning("You lack the grace to wield this!"))
		return COMPONENT_TWOHANDED_BLOCK_WIELD


//Specific wield () hulk checks due to reflection chance for balance
/obj/item/twohanded/dualsaber/wield(obj/item/source, mob/living/carbon/user)
	hitsound = 'sound/weapons/blade1.ogg'
	w_class = w_class_on


/obj/item/twohanded/dualsaber/unwield(obj/item/source, mob/living/carbon/user)
	hitsound = "swing_hit"
	w_class = initial(w_class)


/obj/item/twohanded/dualsaber/IsReflect()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		return TRUE


/obj/item/twohanded/dualsaber/update_icon_state()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		icon_state = "dualsaber[blade_color]1"
		set_light_on(TRUE)
		set_light_color(colormap[blade_color])
	else
		icon_state = "dualsaber0"
		set_light_on(FALSE)


/obj/item/twohanded/dualsaber/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !HAS_TRAIT(src, TRAIT_WIELDED))
		return .

	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(40))
		to_chat(user, span_warning("You twirl around a bit before losing your balance and impaling yourself on the [src]."))
		user.take_organ_damage(20, 25)
		return .

	if(prob(50))
		INVOKE_ASYNC(src, GLOBAL_PROC_REF(jedi_spin), user)


/proc/jedi_spin(mob/living/user)
	for(var/i in list(NORTH, SOUTH, EAST, WEST, EAST, SOUTH, NORTH, SOUTH, EAST, WEST, EAST, SOUTH))
		user.setDir(i)
		if(i == WEST)
			user.SpinAnimation(7, 1)
		sleep(1)


/obj/item/twohanded/dualsaber/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		return ..()
	return FALSE


/obj/item/twohanded/dualsaber/green
	blade_color = "green"

/obj/item/twohanded/dualsaber/red
	blade_color = "red"

/obj/item/twohanded/dualsaber/purple
	blade_color = "purple"

/obj/item/twohanded/dualsaber/blue
	blade_color = "blue"

/obj/item/twohanded/dualsaber/orange
	blade_color = "orange"

/obj/item/twohanded/dualsaber/darkblue
	blade_color = "darkblue"

/obj/item/twohanded/dualsaber/pink
	blade_color = "pink"

/obj/item/twohanded/dualsaber/yellow
	blade_color = "yellow"


/obj/item/twohanded/dualsaber/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!hacked)
		hacked = TRUE
		to_chat(user, "<span class='warning'>2XRNBW_ENGAGE</span>")
		blade_color = "rainbow"
		update_icon()
	else
		to_chat(user, "<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>")


//spears
/obj/item/twohanded/spear
	icon_state = "spearglass0"
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force_unwielded = 10
	force_wielded = 18
	throwforce = 20
	throw_speed = 4
	armour_penetration = 10
	materials = list(MAT_METAL = 1150, MAT_GLASS = 2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharp = TRUE
	embed_chance = 50
	embedded_ignore_throwspeed_threshold = TRUE
	no_spin_thrown = TRUE
	var/obj/item/grenade/explosive = null
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	needs_permit = TRUE
	var/icon_prefix = "spearglass"


/obj/item/twohanded/spear/update_icon_state()
	icon_state = "[icon_prefix][HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/spear/CheckParts(list/parts_list)
	var/obj/item/shard/tip = locate() in parts_list
	if(istype(tip, /obj/item/shard/plasma))
		force_wielded = 19
		force_unwielded = 11
		throwforce = 21
		icon_prefix = "spearplasma"
	update_icon()
	qdel(tip)
	..()


/obj/item/twohanded/spear/afterattack(atom/movable/AM, mob/user, proximity, params)
	if(!proximity)
		return
	if(isturf(AM)) //So you can actually melee with it
		return
	if(explosive && HAS_TRAIT(src, TRAIT_WIELDED))
		explosive.forceMove(AM)
		explosive.prime()
		qdel(src)


/obj/item/twohanded/spear/throw_impact(atom/target, datum/thrownthing/throwingdatum)
	. = ..()
	if(explosive)
		explosive.prime()
		qdel(src)


/obj/item/twohanded/spear/bonespear	//Blatant imitation of spear, but made out of bone. Not valid for explosive modification.
	icon_state = "bone_spear0"
	name = "bone spear"
	desc = "A haphazardly-constructed yet still deadly weapon. The pinnacle of modern technology."
	force = 11
	force_unwielded = 11
	force_wielded = 20					//I have no idea how to balance
	throwforce = 22
	armour_penetration = 15				//Enhanced armor piercing
	icon_prefix = "bone_spear"

/obj/item/twohanded/spear/bonespear/chitinspear //like a mix of a bone spear and bone axe, but more like a bone spear. And better.
	icon_state = "chitin_spear0"
	name = "chitin spear"
	desc = "A well constructed spear with a sharpened edge akin to a naginata, making it equally great for slicing and throwing."
	force = 14
	force_unwielded = 14
	force_wielded = 24 // I have no idea about balance too
	throwforce = 26
	icon_prefix = "chitin_spear"


/obj/item/twohanded/spear/plasma
	name = "plasma spear"
	icon_state = "spearplasma0"
	force = 11
	force_wielded = 19
	force_unwielded = 11
	throwforce = 21
	icon_prefix = "spearplasma"


//GREY TIDE
/obj/item/twohanded/spear/grey_tide
	icon_state = "spearglass0"
	name = "\improper Grey Tide"
	desc = "Recovered from the aftermath of a revolt aboard Defense Outpost Theta Aegis, in which a seemingly endless tide of Assistants caused heavy casualities among Nanotrasen military forces."
	force_unwielded = 15
	force_wielded = 25
	throwforce = 20
	throw_speed = 4
	attack_verb = list("gored")

/obj/item/twohanded/spear/grey_tide/afterattack(atom/movable/AM, mob/living/user, proximity, params)
	..()
	if(!proximity)
		return
	user.faction |= "greytide(\ref[user])"
	if(isliving(AM))
		var/mob/living/L = AM
		if(istype (L, /mob/living/simple_animal/hostile/illusion))
			return
		if(!L.stat && prob(50))
			var/mob/living/simple_animal/hostile/illusion/M = new(user.loc)
			M.faction = user.faction.Copy()
			M.attack_sound = hitsound
			M.Copy_Parent(user, 100, user.health/2.5, 12, 30)
			M.GiveTarget(L)


/obj/item/twohanded/spear/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/organ/external/head))	//Putting heads on spears
		add_fingerprint(user)
		if(loc == user && !user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		user.visible_message(
			span_warning("[user] stick [I] onto the spear just in front of you!"),
			span_notice("You stick [I] onto the spear and stand it upright on the ground."),
		)
		var/obj/structure/headspear/trophy = new(get_turf(src))
		trophy.add_fingerprint(user)
		I.transform = matrix()
		var/image/head_olay = image(I.icon, I.icon_state)
		head_olay.copy_overlays(I)
		trophy.add_overlay(head_olay)
		I.forceMove(trophy)
		if(loc == user)
			user.temporarily_remove_item_from_inventory(src)
		forceMove(trophy)
		trophy.mounted_head = I
		trophy.contained_spear = src
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/headspear
	name = "head on a spear"
	desc = "How barbaric."
	icon_state = "headspear"
	density = FALSE
	anchored = TRUE
	var/obj/item/organ/external/head/mounted_head = null
	var/obj/item/twohanded/spear/contained_spear = null

/obj/structure/headspear/Destroy()
	if(!obj_integrity)
		mounted_head.forceMove(loc)
		mounted_head = null
	else
		QDEL_NULL(mounted_head)
	QDEL_NULL(contained_spear)
	return ..()

/obj/structure/headspear/attack_hand(mob/living/user)
	user.visible_message("<span class='warning'>[user] kicks over [src]!</span>", "<span class='danger'>You kick down [src]!</span>")
	playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
	var/turf/T = get_turf(src)
	if(contained_spear)
		contained_spear.forceMove(T)
		contained_spear = null
	if(mounted_head)
		mounted_head.forceMove(T)
		mounted_head = null
	qdel(src)

/obj/item/twohanded/spear/kidan
	icon_state = "kidanspear0"
	name = "Kidan spear"
	desc = "A spear brought over from the Kidan homeworld."


// DIY CHAINSAW
/obj/item/twohanded/required/chainsaw
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon_state = "gchainsaw_off"
	flags = CONDUCT
	force = 13
	var/force_on = 24
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 13
	throw_speed = 2
	throw_range = 4
	materials = list(MAT_METAL = 13000)
	origin_tech = "materials=3;engineering=4;combat=2"
	attack_verb = list("sawed", "cut", "hacked", "carved", "cleaved", "butchered", "felled", "timbered")
	hitsound = "swing_hit"
	sharp = TRUE
	embed_chance = 10
	embedded_ignore_throwspeed_threshold = TRUE
	actions_types = list(/datum/action/item_action/startchainsaw)
	var/on = FALSE


/obj/item/twohanded/required/chainsaw/attack_self(mob/user)
	on = !on
	to_chat(user, "As you pull the starting cord dangling from [src], [on ? "it begins to whirr." : "the chain stops moving."]")
	if(on)
		playsound(loc, 'sound/weapons/chainsawstart.ogg', 50, 1)
	force = on ? force_on : initial(force)
	throwforce = on ? force_on : initial(throwforce)
	icon_state = "gchainsaw_[on ? "on" : "off"]"

	if(hitsound == "swing_hit")
		hitsound = 'sound/weapons/chainsaw.ogg'
	else
		hitsound = "swing_hit"

	if(src == user.get_active_hand()) //update inhands
		user.update_inv_l_hand()
		user.update_inv_r_hand()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/twohanded/required/chainsaw/attack_hand(mob/user)
	. = ..()
	force = on ? force_on : initial(force)
	throwforce = on ? force_on : initial(throwforce)

/obj/item/twohanded/required/chainsaw/on_give(mob/living/carbon/giver, mob/living/carbon/receiver)
	. = ..()
	force = on ? force_on : initial(force)
	throwforce = on ? force_on : initial(throwforce)

/obj/item/twohanded/required/chainsaw/doomslayer
	name = "OOOH BABY"
	desc = "<span class='warning'>VRRRRRRR!!!</span>"
	armour_penetration = 100
	force_on = 30

/obj/item/twohanded/required/chainsaw/doomslayer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		owner.visible_message("<span class='danger'>Ranged attacks just make [owner] angrier!</span>")
		playsound(src, pick('sound/weapons/bulletflyby.ogg','sound/weapons/bulletflyby2.ogg','sound/weapons/bulletflyby3.ogg'), 75, 1)
		return TRUE
	return FALSE


///CHAINSAW///
/obj/item/twohanded/chainsaw
	icon_state = "chainsaw0"
	name = "Chainsaw"
	desc = "Perfect for felling trees or fellow spacemen."
	force = 15
	throwforce = 15
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_BULKY // can't fit in backpacks
	force_unwielded = 15 //still pretty robust
	force_wielded = 40  //you'll gouge their eye out! Or a limb...maybe even their entire body!
	hitsound = null // Handled in the snowflaked attack proc
	wieldsound = 'sound/weapons/chainsawstart.ogg'
	hitsound = null
	armour_penetration = 35
	origin_tech = "materials=6;syndicate=4"
	attack_verb = list("sawed", "cut", "hacked", "carved", "cleaved", "butchered", "felled", "timbered")
	sharp = TRUE
	embed_chance = 10
	embedded_ignore_throwspeed_threshold = TRUE
	wielded = FALSE


/obj/item/twohanded/chainsaw/wield(obj/item/source, mob/living/carbon/user)
	ADD_TRAIT(src, TRAIT_NODROP, CHAINSAW_TRAIT)


/obj/item/twohanded/chainsaw/unwield(obj/item/source, mob/living/carbon/user)
	REMOVE_TRAIT(src, TRAIT_NODROP, CHAINSAW_TRAIT)


/obj/item/twohanded/chainsaw/update_icon_state()
	icon_state = "chainsaw[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/chainsaw/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !HAS_TRAIT(src, TRAIT_WIELDED))
		return .

	//incredibly loud; you ain't goin' for stealth with this thing. Credit to Lonemonk of Freesound for this sound.
	playsound(loc, 'sound/weapons/chainsaw.ogg', 100, TRUE, -1)
	if(!isrobot(target))
		target.Weaken(2 SECONDS)


// SINGULOHAMMER
/obj/item/twohanded/singularityhammer
	name = "singularity hammer"
	desc = "The pinnacle of close combat technology, the hammer harnesses the power of a miniaturized singularity to deal crushing blows."
	icon_state = "mjollnir0"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 20
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/charged = 5
	origin_tech = "combat=4;bluespace=4;plasmatech=7"


/obj/item/twohanded/singularityhammer/Initialize(mapload)
	. = ..()

	START_PROCESSING(SSobj, src)


/obj/item/twohanded/singularityhammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/twohanded/singularityhammer/process()
	if(charged < 5)
		charged++

/obj/item/twohanded/singularityhammer/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	icon_state = "mjollnir[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/singularityhammer/proc/vortex(turf/pull, mob/wielder)
	for(var/atom/movable/X in orange(5, pull))
		if(X == wielder)
			continue
		if((X) && (!X.anchored) && (!ishuman(X)))
			step_towards(X, pull)
			step_towards(X, pull)
			step_towards(X, pull)
		else if(ishuman(X))
			var/mob/living/carbon/human/H = X
			if(istype(H.shoes, /obj/item/clothing/shoes/magboots))
				var/obj/item/clothing/shoes/magboots/M = H.shoes
				if(M.magpulse)
					continue
			H.Weaken(2 SECONDS)
			step_towards(H, pull)
			step_towards(H, pull)
			step_towards(H, pull)

/obj/item/twohanded/singularityhammer/afterattack(atom/A, mob/user, proximity, params)
	if(!proximity)
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		if(charged == 5)
			charged = 0
			if(isliving(A))
				var/mob/living/Z = A
				Z.take_organ_damage(20, 0)
			playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			var/turf/target = get_turf(A)
			vortex(target, user)

/obj/item/twohanded/mjollnir
	name = "Mjolnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	icon_state = "mjollnir0"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 25
	throwforce = 30
	throw_range = 7
	w_class = WEIGHT_CLASS_HUGE
	//var/charged = 5
	origin_tech = "combat=4;powerstorage=7"


/obj/item/twohanded/mjollnir/proc/shock(mob/living/target)
	target.Stun(4 SECONDS)
	do_sparks(5, 1, target.loc)
	target.visible_message(
		"<span class='danger'>[target.name] was shocked by the [name]!</span>",
		"<span class='userdanger'>You feel a powerful shock course through your body sending you flying!</span>",
		"<span class='italics'>You hear a heavy electrical crack!</span>",
	)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	INVOKE_ASYNC(target, TYPE_PROC_REF(/atom/movable, throw_at), throw_target, 200, 4)


/obj/item/twohanded/mjollnir/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !HAS_TRAIT(src, TRAIT_WIELDED))
		return .
	shock(target)



/obj/item/twohanded/mjollnir/throw_impact(atom/target, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(target))
		shock(target)


/obj/item/twohanded/mjollnir/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	icon_state = "mjollnir[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/knighthammer
	name = "singuloth knight's hammer"
	desc = "A hammer made of sturdy metal with a golden skull adorned with wings on either side of the head. <br>This weapon causes devastating damage to those it hits due to a power field sustained by a mini-singularity inside of the hammer."
	icon_state = "knighthammer0"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 30
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	var/charged = 5
	origin_tech = "combat=5;bluespace=4"

/obj/item/twohanded/knighthammer/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/twohanded/knighthammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/twohanded/knighthammer/process()
	if(charged < 5)
		charged++

/obj/item/twohanded/knighthammer/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	icon_state = "knighthammer[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/knighthammer/afterattack(atom/A, mob/user, proximity, params)
	if(!proximity)
		return
	if(charged == 5)
		charged = 0
		if(isliving(A))
			var/mob/living/Z = A
			if(Z.health >= 1)
				Z.visible_message("<span class='danger'>[Z.name] was sent flying by a blow from the [name]!</span>", \
					"<span class='userdanger'>You feel a powerful blow connect with your body and send you flying!</span>", \
					"<span class='danger'>You hear something heavy impact flesh!.</span>")
				var/atom/throw_target = get_edge_target_turf(Z, get_dir(src, get_step_away(Z, src)))
				Z.throw_at(throw_target, 200, 4)
				playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			else if(HAS_TRAIT(src, TRAIT_WIELDED) && Z.health < 1)
				Z.visible_message("<span class='danger'>[Z.name] was blown to pieces by the power of [name]!</span>", \
					"<span class='userdanger'>You feel a powerful blow rip you apart!</span>", \
					"<span class='danger'>You hear a heavy impact and the sound of ripping flesh!.</span>")
				Z.gib()
				playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
		if(HAS_TRAIT(src, TRAIT_WIELDED))
			if(iswallturf(A))
				var/turf/simulated/wall/Z = A
				Z.ex_act(2)
				charged = 3
				playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			else if(isstructure(A) || ismecha(A))
				var/obj/Z = A
				Z.ex_act(2)
				charged = 3
				playsound(user, 'sound/weapons/marauder.ogg', 50, 1)

/obj/item/twohanded/pitchfork
	icon_state = "pitchfork0"
	name = "pitchfork"
	desc = "A simple tool used for moving hay."
	force = 7
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	force_unwielded = 7
	force_wielded = 15
	attack_verb = list("attacked", "impaled", "pierced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 30)
	resistance_flags = FIRE_PROOF

/obj/item/twohanded/pitchfork/demonic
	name = "demonic pitchfork"
	desc = "A red pitchfork, it looks like the work of the devil."
	force = 19
	throwforce = 24
	force_unwielded = 19
	force_wielded = 25

/obj/item/twohanded/pitchfork/demonic/greater
	force = 24
	throwforce = 50
	force_unwielded = 24
	force_wielded = 34

/obj/item/twohanded/pitchfork/demonic/ascended
	force = 100
	throwforce = 100
	force_unwielded = 100
	force_wielded = 500000 // Kills you DEAD.

/obj/item/twohanded/pitchfork/update_icon_state()
	icon_state = "pitchfork[HAS_TRAIT(src, TRAIT_WIELDED)]"

/obj/item/twohanded/pitchfork/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] impales \himself in \his abdomen with [src]! It looks like \he's trying to commit suicide...</span>")
	return BRUTELOSS

/obj/item/twohanded/pitchfork/demonic/pickup(mob/user)
	. = ..()
	if(isliving(user))
		var/mob/living/U = user
		if(U.mind && !U.mind.devilinfo && (U.mind.soulOwner == U.mind)) //Burn hands unless they are a devil or have sold their soul
			U.visible_message("<span class='warning'>As [U] picks [src] up, [U]'s arms briefly catch fire.</span>", \
				"<span class='warning'>\"As you pick up the [src] your arms ignite, reminding you of all your past sins.\"</span>")
			if(ishuman(U))
				var/mob/living/carbon/human/H = U
				H.apply_damage(rand(force/2, force), BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
			else
				U.adjustFireLoss(rand(force/2,force))


/obj/item/twohanded/pitchfork/demonic/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !HAS_TRAIT(src, TRAIT_WIELDED))
		return .

	if(!user.mind || user.mind.devilinfo || (user.mind.soulOwner == user.mind))
		return .

	to_chat(user, span_warning("The [name] burns in your hands!"))
	user.apply_damage(rand(force/2, force), BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))



// It's no fun being the lord of all hell if you can't get out of a simple room
/obj/item/twohanded/pitchfork/demonic/ascended/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity || !HAS_TRAIT(src, TRAIT_WIELDED))
		return
	if(iswallturf(target))
		var/turf/simulated/wall/W = target
		user.visible_message("<span class='danger'>[user] blasts \the [target] with \the [src]!</span>")
		playsound(target, 'sound/magic/Disintegrate.ogg', 100, 1)
		W.devastate_wall(TRUE)
		return 1
	..()

/obj/item/twohanded/bamboospear
	icon_state = "bamboo_spear0"
	name = "bamboo spear"
	desc = "A haphazardly-constructed bamboo stick with a sharpened tip, ready to poke holes into unsuspecting people."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force_unwielded = 10
	force_wielded = 18
	throwforce = 22
	throw_speed = 4
	armour_penetration = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "tore", "gored")
	sharp = TRUE
	embed_chance = 50
	embedded_ignore_throwspeed_threshold = TRUE

/obj/item/twohanded/bamboospear/update_icon_state()
	icon_state = "bamboo_spear[HAS_TRAIT(src, TRAIT_WIELDED)]"

//pyro claws
/obj/item/twohanded/required/pyro_claws
	name = "hardplasma energy claws"
	desc = "The power of the sun, in the claws of your hand."
	icon_state = "pyro_claws"
	item_flags = ABSTRACT|DROPDEL
	force = 25
	force_wielded = 25
	damtype = BURN
	armour_penetration = 40
	block_chance = 50
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut", "savaged", "clawed")
	toolspeed = 0.5

/obj/item/twohanded/required/pyro_claws/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	START_PROCESSING(SSobj, src)

/obj/item/twohanded/required/pyro_claws/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/twohanded/required/pyro_claws/process()
	if(prob(15))
		do_sparks(rand(1,6), 1, loc)

/obj/item/twohanded/required/pyro_claws/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(prob(60))
		do_sparks(rand(1,6), 1, loc)
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if(!A.requiresID() || A.allowed(user))
			return

		if(A.locked)
			to_chat(user, "<span class='notice'>The airlock's bolts prevent it from being forced.</span>")
			return

		if(A.arePowerSystemsOn())
			user.visible_message("<span class='warning'>[user] jams [user.p_their()] [name] into the airlock and starts prying it open!</span>", "<span class='warning'>You start forcing the airlock open.</span>", "<span class='warning'>You hear a metal screeching sound.</span>")
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 150, 1)
			if(!do_after(user, 2.5 SECONDS, A))
				return
		user.visible_message("<span class='warning'>[user] forces the airlock open with [user.p_their()] [name]!</span>", "<span class='warning'>You force open the airlock.</span>", "<span class='warning'>You hear a metal screeching sound.</span>")
		A.open(2)

/obj/item/clothing/gloves/color/black/pyro_claws
	name = "Fusion gauntlets"
	desc = "Cybersun Industries developed these gloves after a grifter fought one of their soldiers, who attached a pyro core to an energy sword, and found it mostly effective."
	item_state = "pyro"
	item_color = "pyro"
	icon_state = "pyro"
	can_be_cut = FALSE
	actions_types = list(/datum/action/item_action/toggle)
	var/on_cooldown = FALSE
	var/used = FALSE
	var/obj/item/assembly/signaler/anomaly/pyro/core

/obj/item/clothing/gloves/color/black/pyro_claws/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/clothing/gloves/color/black/pyro_claws/examine(mob/user)
	. = ..()
	if(core)
		. += "<span class='notice'>[src] are fully operational!</span>"
	else
		. += "<span class='warning'>It is missing a pyroclastic anomaly core.</span>"

/obj/item/clothing/gloves/color/black/pyro_claws/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_GLOVES)
		return TRUE

/obj/item/clothing/gloves/color/black/pyro_claws/ui_action_click(mob/user, datum/action/action, leftclick)
	if(!core)
		to_chat(user, "<span class='notice'>[src] has no core to power it!</span>")
		return
	if(on_cooldown)
		to_chat(user, "<span class='notice'>[src] is on cooldown!</span>")
		do_sparks(rand(1,6), 1, loc)
		return
	if(used)
		visible_message("<span class='warning'>Energy claws slides back into the depths of [loc]'s wrists.</span>")
		user.drop_from_active_hand(force = TRUE)//dropdel stuff. only ui act, without hotkeys
		do_sparks(rand(1,6), 1, loc)
		on_cooldown = TRUE
		addtimer(CALLBACK(src, PROC_REF(reboot)), 1 MINUTES)
		return
	if(user.get_active_hand() && !user.drop_from_active_hand())
		to_chat(user, "<span class='notice'>[src] are unable to deploy the blades with the items in your hands!</span>")
		return
	var/obj/item/W = new /obj/item/twohanded/required/pyro_claws
	user.visible_message("<span class='warning'>[user] deploys [W] from [user.p_their()] wrists in a shower of sparks!</span>", "<span class='notice'>You deploy [W] from your wrists!</span>", "<span class='warning'>You hear the shower of sparks!</span>")
	user.put_in_hands(W)
	ADD_TRAIT(src, TRAIT_NODROP, PYRO_CLAWS_TRAIT)
	used = TRUE
	do_sparks(rand(1,6), 1, loc)


/obj/item/clothing/gloves/color/black/pyro_claws/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/assembly/signaler/anomaly/pyro))
		add_fingerprint(user)
		if(core)
			to_chat(user, span_warning("The [core.name] is already installed."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You insert [I] into [src], and it starts to warm up."))
		core = I
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/clothing/gloves/color/black/pyro_claws/proc/reboot()
	on_cooldown = FALSE
	used = FALSE
	REMOVE_TRAIT(src, TRAIT_NODROP, PYRO_CLAWS_TRAIT)
	atom_say("Internal plasma canisters recharged. Gloves sufficiently cooled")

/obj/item/twohanded/fishingrod
	name = "ol' reliable"
	desc = "Hey! I caught a miner!"
	icon_state = "fishing_rod0"
	item_state = ""
	w_class = WEIGHT_CLASS_SMALL
	var/w_class_on = WEIGHT_CLASS_BULKY

/obj/item/twohanded/fishingrod/wield()
	w_class = w_class_on
	item_state = "fishing_rod"

/obj/item/twohanded/fishingrod/unwield()
	w_class = initial(w_class)
	item_state = ""

/obj/item/twohanded/fishingrod/update_icon_state()
	icon_state = "fishing_rod[HAS_TRAIT(src, TRAIT_WIELDED)]"


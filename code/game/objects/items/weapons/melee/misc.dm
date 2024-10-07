/obj/item/melee
	needs_permit = 1

/obj/item/melee/proc/check_martial_counter(mob/living/carbon/human/target, mob/living/carbon/human/user)
	var/message = "<span class='danger'>[target.name] blocks [src] and twists [user]'s arm behind [user.p_their()] back!</span>"
	var/self_message = "<span class='userdanger'>You block the attack!</span>"
	if(target.check_martial_art_defense(target, user, src, message, self_message))
		user.Stun(4 SECONDS)
		return TRUE

/obj/item/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=5"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/slash.ogg' //pls replace


/obj/item/melee/chainofcommand/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='suicide'>[user] is strangling [user.p_them()]self with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return OXYLOSS

/obj/item/melee/rapier
	name = "rapier"
	desc = "If you see this, it means there's a bug."
	icon_state = "rods-1"
	item_state = "rods"
	flags = CONDUCT
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	block_chance = 50
	armour_penetration = 75
	sharp = TRUE
	origin_tech = "combat=5"
	attack_verb = list("lunged at", "stabbed")
	pickup_sound = 'sound/items/handling/knife_pickup.ogg'
	drop_sound = 'sound/items/handling/knife_drop.ogg'
	hitsound = 'sound/weapons/rapierhit.ogg'
	materials = list(MAT_METAL = 1000)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF // Theft targets should be hard to destroy

/obj/item/melee/rapier/captain
	name = "captain's rapier"
	desc = "An elegant weapon, for a more civilized age."
	icon_state = "rapier"
	item_state = "rapier"
	block_type = MELEE_ATTACKS

/obj/item/melee/rapier/syndie
	name = "plastitanium rapier"
	desc = "A thin blade made of plastitanium with a diamond tip. It appears to be coated in a persistent layer of an unknown substance."
	icon_state = "syndie_rapier"
	item_state = "syndie_rapier"
	origin_tech = "combat=5;biotech=5;syndicate=4"
	materials = null
	resistance_flags = FIRE_PROOF | ACID_PROOF


/obj/item/melee/rapier/syndie/ComponentInitialize()
	AddElement(/datum/element/after_attack/attack_effect_sleep, 30, 10 SECONDS)


/obj/item/melee/rapier/centcomm
	name = "centcomm plastitanium rapier"
	desc = "Симбиоз непозволительной роскоши и статуса с титановым лезвием на вашем поясе, обладатель этого шедевра оружейного дела может похвастаться тем, что постиг корпоративную вершину."
	icon_state = "centcomm_rapier"
	item_state = "centcomm_rapier"
	origin_tech = "combat=5;biotech=5;syndicate=4"
	materials = null
	force = 25
	throwforce = 20
	block_chance = 95
	armour_penetration = 100
	actions_types = list(/datum/action/item_action/toggle_rapier_nodrop)

/obj/item/melee/rapier/centcomm/ComponentInitialize()
	AddElement(/datum/element/after_attack/attack_effect_sleep, 100, 10 SECONDS)


/obj/item/melee/rapier/centcomm/attack_self(mob/user)
	. = ..()

	if(!usr.is_in_hands(src))
		return .

	if(HAS_TRAIT_FROM(src, TRAIT_NODROP, CENTCOMM_RAPIER_TRAIT))
		REMOVE_TRAIT(src, TRAIT_NODROP, CENTCOMM_RAPIER_TRAIT)
		to_chat(usr, span_warning("Вы расслабляете руку и отпускаете рукоятку [src]."))
	else
		ADD_TRAIT(src, TRAIT_NODROP, CENTCOMM_RAPIER_TRAIT)
		to_chat(usr, span_warning("Вы сжимаете рукоятку [src] со всей силы. Теперь ничто не может выбить у вас оружие из рук!"))


/obj/item/melee/mantisblade
	name = "Gorlex mantis blade"
	desc = "A blade designed to be hidden just beneath the skin. The brain is directly linked to this bad boy, allowing it to spring into action."
	icon_state = "syndie_mantis"
	item_state = "syndie_mantis"
	force = 25
	throwforce = 20
	w_class = WEIGHT_CLASS_NORMAL
	block_chance = 35
	armour_penetration = 40
	sharp = TRUE
	item_flags = NOSHARPENING
	origin_tech = "combat=5"
	attack_verb = list("slashed", "stabbed", "sliced", "caned")
	hitsound = 'sound/weapons/bladeslice.ogg'
	materials = list(MAT_METAL = 1000)
	/// Whether we are currently performing double attack
	var/attack_in_progress = FALSE


/obj/item/melee/mantisblade/equipped(mob/user, slot, initial = FALSE)
	. = ..()

	if(slot == ITEM_SLOT_HAND_LEFT)
		transform = null
	else
		transform = matrix(-1, 0, 0, 0, 1, 0)


/obj/item/melee/mantisblade/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || attack_in_progress || user.a_intent != INTENT_HARM)
		return .
	var/obj/item/melee/mantisblade/secondsword = user.get_inactive_hand()
	if(!istype(secondsword, /obj/item/melee/mantisblade))
		return .
	addtimer(CALLBACK(secondsword, PROC_REF(mantis_attack), target, user, params, def_zone), 0.2 SECONDS)


/obj/item/melee/mantisblade/proc/mantis_attack(mob/living/target, mob/living/user, params, def_zone)
	if(QDELETED(src) || QDELETED(target) || !user.is_in_hands(src) || !user.Adjacent(target))
		return
	attack_in_progress = TRUE
	attack(target, user, params, def_zone)
	attack_in_progress = FALSE



/obj/item/melee/mantisblade/afterattack(atom/target, mob/user, proximity)
    if(!proximity)
        return
    if(prob(25))
        do_sparks(rand(1,6), 1, loc)
    if(istype(target, /obj/machinery/door/airlock))
        var/obj/machinery/door/airlock/A = target

        if(!A.requiresID() || A.allowed(user))
            return

        if(A.locked)
            to_chat(user, "<span class='notice'>The airlock's bolts prevent it from being forced.</span>")
            return

        if(A.arePowerSystemsOn())
            user.visible_message(span_warning("[user] jams [user.p_their()] [name] into the airlock and starts prying it open!"), span_warning("You start forcing the airlock open."), span_warning("You hear a metal screeching sound."))
            playsound(A, 'sound/machines/airlock_alien_prying.ogg', 150, 1)
            if(!do_after(user, 2.5 SECONDS, A))
                return
        user.visible_message("<span class='warning'>[user] forces the airlock open with [user.p_their()] [name]!</span>", "<span class='warning'>You force open the airlock.</span>", "<span class='warning'>You hear a metal screeching sound.</span>")
        A.open(TRUE)

/obj/item/melee/mantisblade/shellguard
	name = "Shellguard mantis blade"
	force = 15
	armour_penetration = 20
	block_chance = 20
	block_type = MELEE_ATTACKS
	icon_state = "mantis"
	item_state = "mantis"

/obj/item/melee/icepick
	name = "ice pick"
	desc = "Used for chopping ice. Also excellent for mafia esque murders."
	icon_state = "icepick"
	item_state = "icepick"
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("stabbed", "jabbed", "iced,")

/obj/item/melee/candy_sword
	name = "candy cane sword"
	desc = "A large candy cane with a sharpened point. Definitely too dangerous for schoolchildren."
	icon_state = "candy_sword"
	item_state = "candy_sword"
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("slashed", "stabbed", "sliced", "caned")

/obj/item/melee/flyswatter
	name = "flyswatter"
	desc = "Useful for killing insects of all sizes."
	icon_state = "flyswatter"
	item_state = "flyswatter"
	force = 1
	throwforce = 1
	attack_verb = list("swatted", "smacked")
	hitsound = 'sound/effects/snap.ogg'
	w_class = WEIGHT_CLASS_SMALL
	//Things in this list will be instantly splatted.  Flyman weakness is handled in the flyman species weakness proc.
	var/list/strong_against

/obj/item/melee/flyswatter/Initialize(mapload)
	. = ..()
	strong_against = typecacheof(list(
					/mob/living/simple_animal/hostile/poison/bees/,
					/mob/living/simple_animal/butterfly,
					/mob/living/simple_animal/cockroach,
					/obj/item/queen_bee
	))

/obj/item/melee/flyswatter/afterattack(atom/target, mob/user, proximity_flag, params)
	. = ..()
	if(proximity_flag)
		if(is_type_in_typecache(target, strong_against))
			new /obj/effect/decal/cleanable/insectguts(target.drop_location())
			to_chat(user, "<span class='warning'>You easily splat the [target].</span>")
			if(istype(target, /mob/living/))
				var/mob/living/bug = target
				bug.death(1)
			else
				qdel(target)

/obj/item/melee/bigiron
	name = "Big Iron"
	desc = "It is a very old rusty and racist iron. Used to beat the living shit out of these filthy xenos."
	w_class = WEIGHT_CLASS_NORMAL
	force = 8
	throwforce = 8
	var/bonus_damage = 10
	icon_state = "big_iron"
	item_state = "big_iron"
	attack_verb = list("burned", "dominated", "robusted")

/obj/item/melee/bigiron/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity)
		return
	if(ishuman(target))
		if(!ishumanbasic(target))
			var/mob/living/victim = target
			victim.apply_damage(bonus_damage, BURN)


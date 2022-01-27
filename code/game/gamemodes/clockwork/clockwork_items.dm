#define COG_MAX_SIPHON_THRESHOLD 0.25 //The cog will not siphon power if the APC's cell is at this % of power

GLOBAL_LIST_INIT(clockslab_spells, list(
	new /datum/spell_enchant("Stun", STUN_SPELL, 125),
	new /datum/spell_enchant("Electromagnetic Pulse", EMP_SPELL, 200)
))

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
		if(!isliving(target) || !proximity)
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
			C.CultSlur(10)
		src.visible_message("<span class='warning'>[src] sparks as the [target] falls!</span>")
		enchant_type = NO_SPELL
		enchanted = FALSE

/obj/item/clockwork
	name = "Clockwork item name"
	icon = 'icons/obj/clockwork.dmi'
	var/prepared_spell = null

//Can be used on an open APC to replace its guts with clockwork variants, and begin passively siphoning power from it
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

//Ratvarian spear
/obj/item/clockwork/weapon/ratvarian_spear
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	icon = 'icons/obj/clockwork_objects.dmi'
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



#undef COG_MAX_SIPHON_THRESHOLD

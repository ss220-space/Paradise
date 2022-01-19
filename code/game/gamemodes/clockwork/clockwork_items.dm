#define COG_MAX_SIPHON_THRESHOLD 0.25 //The cog will not siphon power if the APC's cell is at this % of power

/obj/item/melee/clockslab
	name = "Clockwork slab"
	desc = "A strange metal tablet. A clock in the center turns around and around."
	icon = "icons/obj/clockwork_objects.dmi"
	icon_state = "dread_ipad"
	w_class = WEIGHT_CLASS_SMALL
	var/prepared_spell = ""


//Can be used on an open APC to replace its guts with clockwork variants, and begin passively siphoning power from it
/obj/item/clockwork/integration_cog
	name = "integration cog"
	desc = "A small cogwheel that fits in the palm of your hand."
	icon_state = "wall_gear"
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/power/apc/apc

/obj/item/clockwork/integration_cog/Initialize()
	. = ..()
	transform *= 0.5 //little cog!

/obj/item/clockwork/integration_cog/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/item/clockwork/integration_cog/process()
	if(!apc)
		if(istype(loc, /obj/machinery/power/apc))
			apc = loc
		else
			STOP_PROCESSING(SSfastprocess, src)
	else
		var/obj/item/stock_parts/cell/cell = apc.get_cell()
		if(cell && (cell.charge / cell.maxcharge > COG_MAX_SIPHON_THRESHOLD))
			cell.use(1)
			adjust_clockwork_power(CLOCK_POWER_COG) //Power is shared, so only do it once; this runs very quickly so it's about 1W/second
		if(prob(1))
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
	var/bonus_burn = 5



#undef COG_MAX_SIPHON_THRESHOLD

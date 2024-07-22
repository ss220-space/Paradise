
////HUD NONSENSE////
/atom/movable/screen/swarmer
	icon = 'icons/mob/swarmer.dmi'

/atom/movable/screen/swarmer/FabricateTrap
	icon_state = "ui_trap"
	name = "Create trap (Costs 5 Resources)"
	desc = "Creates a trap that will nonlethally shock any non-swarmer that attempts to cross it. (Costs 5 resources)"

/atom/movable/screen/swarmer/FabricateTrap/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateTrap()

/atom/movable/screen/swarmer/Barricade
	icon_state = "ui_barricade"
	name = "Create barricade (Costs 5 Resources)"
	desc = "Creates a destructible barricade that will stop any non swarmer from passing it. Also allows disabler beams to pass through. (Costs 5 resources)"

/atom/movable/screen/swarmer/Barricade/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateBarricade()

/atom/movable/screen/swarmer/Replicate
	icon_state = "ui_replicate"
	name = "Replicate (Costs 100 Resources)"
	desc = "Creates a another of our kind."

/atom/movable/screen/swarmer/Replicate/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateSwarmer()

/atom/movable/screen/swarmer/RepairSelf
	icon_state = "ui_self_repair"
	name = "Repair self"
	desc = "Repairs damage to our body."

/atom/movable/screen/swarmer/RepairSelf/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.RepairSelf()

/atom/movable/screen/swarmer/ToggleLight
	icon_state = "ui_light"
	name = "Toggle light"
	desc = "Toggles our inbuilt light on or off."

/atom/movable/screen/swarmer/ToggleLight/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/swarmer = usr
		swarmer.ToggleLight()

/atom/movable/screen/swarmer/ContactSwarmers
	icon_state = "ui_contact_swarmers"
	name = "Contact swarmers"
	desc = "Sends a message to all other swarmers, should they exist."

/atom/movable/screen/swarmer/ContactSwarmers/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.ContactSwarmers()

/mob/living/simple_animal/hostile/swarmer/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/swarmer(src)

/datum/hud/swarmer/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/swarmer/FabricateTrap(null, src)
	using.screen_loc = ui_rhand
	static_inventory += using

	using = new /atom/movable/screen/swarmer/Barricade(null, src)
	using.screen_loc = ui_lhand
	static_inventory += using

	using = new /atom/movable/screen/swarmer/Replicate(null, src)
	using.screen_loc = ui_zonesel
	static_inventory += using

	using = new /atom/movable/screen/swarmer/RepairSelf(null, src)
	using.screen_loc = ui_storage1
	static_inventory += using

	using = new /atom/movable/screen/swarmer/ToggleLight(null, src)
	using.screen_loc = ui_back
	static_inventory += using

	using = new /atom/movable/screen/swarmer/ContactSwarmers(null, src)
	using.screen_loc = ui_inventory
	static_inventory += using


/mob/dead/observer/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/ghost(src)
		SEND_SIGNAL(src, COMSIG_MOB_HUD_CREATED)

/atom/movable/screen/ghost
	icon = 'icons/mob/screen_ghost.dmi'

/atom/movable/screen/ghost/MouseEntered()
	flick(icon_state + "_anim", src)

/atom/movable/screen/ghost/jumptomob
	name = "Jump to mob"
	icon_state = "jumptomob"

/atom/movable/screen/ghost/jumptomob/Click()
	var/mob/dead/observer/G = usr
	G.jumptomob()

/atom/movable/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"

/atom/movable/screen/ghost/orbit/Click()
	var/mob/dead/observer/G = usr
	G.follow()

/atom/movable/screen/ghost/reenter_corpse
	name = "Re-enter corpse"
	icon_state = "reenter_corpse"

/atom/movable/screen/ghost/reenter_corpse/Click()
	var/mob/dead/observer/G = usr
	G.reenter_corpse()

/atom/movable/screen/ghost/teleport
	name = "Teleport"
	icon_state = "teleport"

/atom/movable/screen/ghost/teleport/Click()
	var/mob/dead/observer/G = usr
	G.dead_tele()

/atom/movable/screen/ghost/respawn_list
	name = "Ghost spawns"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "template"

/atom/movable/screen/ghost/respawn_list/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	update_hidden_state()

/atom/movable/screen/ghost/respawn_list/Click()
	var/client/C = hud.mymob.client
	hud.inventory_shown = !hud.inventory_shown
	if(hud.inventory_shown)
		C.screen += hud.toggleable_inventory
	else
		C.screen -= hud.toggleable_inventory
	update_hidden_state()

/atom/movable/screen/ghost/respawn_list/proc/update_hidden_state()
	var/matrix/M = matrix(transform)
	M.Turn(-90)

	cut_overlays()
	var/image/img = image('icons/mob/actions/actions.dmi', src, (hud && hud.inventory_shown) ? "hide" : "show")
	img.transform = M
	add_overlay(img)

/atom/movable/screen/ghost/respawn_mob
	name = "Mob spawners"
	icon_state = "mob_spawner"

/atom/movable/screen/ghost/respawn_mob/Click()
	var/mob/dead/observer/G = usr
	G.open_spawners_menu()

/atom/movable/screen/ghost/mini_games
	name = "Mini games"
	icon_state = "minigames"

/atom/movable/screen/ghost/Click()
	var/mob/dead/observer/G = usr
	G.open_minigames_menu()

/atom/movable/screen/ghost/respawn_pai
	name = "Configure pAI"
	icon_state = "pai"

/atom/movable/screen/ghost/respawn_pai/Click()
	var/mob/dead/observer/G = usr
	if(!GLOB.paiController.check_recruit(G))
		to_chat(G, "<span class='warning'>You are not eligible to become a pAI.</span>")
		return
	GLOB.paiController.recruitWindow(G)

/datum/hud/ghost
	inventory_shown = FALSE

/datum/hud/ghost/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/ghost/jumptomob(null, src)
	using.screen_loc = ui_ghost_jumptomob
	static_inventory += using

	using = new /atom/movable/screen/ghost/orbit(null, src)
	using.screen_loc = ui_ghost_orbit
	static_inventory += using

	using = new /atom/movable/screen/ghost/reenter_corpse(null, src)
	using.screen_loc = ui_ghost_reenter_corpse
	static_inventory += using

	using = new /atom/movable/screen/ghost/teleport(null, src)
	using.screen_loc = ui_ghost_teleport
	static_inventory += using
	static_inventory += using

	using = new /atom/movable/screen/ghost/respawn_list(null, src)
	using.screen_loc = ui_ghost_respawn_list
	static_inventory += using

	using = new /atom/movable/screen/ghost/respawn_mob(null, src)
	using.screen_loc = ui_ghost_respawn_mob
	toggleable_inventory += using

	using = new /atom/movable/screen/ghost/mini_games(null, src)
	using.screen_loc = ui_ghost_minigames
	toggleable_inventory += using

	using = new /atom/movable/screen/ghost/respawn_pai(null, src)
	using.screen_loc = ui_ghost_respawn_pai
	toggleable_inventory += using

/datum/hud/ghost/show_hud()
	mymob.client.screen = list()
	mymob.client.screen += static_inventory
	..()

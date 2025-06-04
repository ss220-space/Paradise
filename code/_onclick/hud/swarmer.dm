
////HUD NONSENSE////
/atom/movable/screen/swarmer
	icon = 'icons/mob/swarmer.dmi'

/atom/movable/screen/swarmer/FabricateTrap
	icon_state = "ui_trap"
	name = "Создать ловушку (Стоимость: 5 ресурсов)"
	desc = "Создаёт ловушку, которая наносит нелетальный разряд всем не-свармерам, при попытке пройти через неё. (Стоимость: 5 ресурсов)"

/atom/movable/screen/swarmer/FabricateTrap/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateTrap()

/atom/movable/screen/swarmer/Barricade
	icon_state = "ui_barricade"
	name = "Создать баррикаду (Стоимость: 5 ресурсов)"
	desc = "Создаёт разрушаемую баррикаду, которая блокирует проход для всех, кроме роевиков. Также пропускает лучи дизейблера. (Стоимость: 5 ресурсов)"

/atom/movable/screen/swarmer/Barricade/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateBarricade()

/atom/movable/screen/swarmer/Replicate
	icon_state = "ui_replicate"
	name = "Репликация (Стоимость: 100 ресурсов)"
	desc = "Создаёт ещё одного представителя нашего вида."

/atom/movable/screen/swarmer/Replicate/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateSwarmer()

/atom/movable/screen/swarmer/RepairSelf
	icon_state = "ui_self_repair"
	name = "Самовосстановление"
	desc = "Чинит повреждения нашего тела."

/atom/movable/screen/swarmer/RepairSelf/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.RepairSelf()

/atom/movable/screen/swarmer/ToggleLight
	icon_state = "ui_light"
	name = "Переключить свет"
	desc = "Включает или выключает встроенную подсветку."

/atom/movable/screen/swarmer/ToggleLight/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/swarmer = usr
		swarmer.ToggleLight()

/atom/movable/screen/swarmer/ContactSwarmers
	icon_state = "ui_contact_swarmers"
	name = "Связь роя"
	desc = "Отправить сообщение всем свармерам, если они, конечно, есть."

/atom/movable/screen/swarmer/ContactSwarmers/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.ContactSwarmers()


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


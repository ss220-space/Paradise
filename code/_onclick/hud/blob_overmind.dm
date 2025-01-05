/atom/movable/screen/blob
	icon = 'icons/hud/blob.dmi'

/atom/movable/screen/blob/MouseEntered(location,control,params)
	openToolTip(usr,src,params,title = name,content = desc, theme = "blob")

/atom/movable/screen/blob/MouseExited()
	closeToolTip(usr)

/atom/movable/screen/blob/BlobHelp
	icon_state = "ui_help"
	name = "Помощь"
	desc = "Помощь по игре за блоба!"

/atom/movable/screen/blob/BlobHelp/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.blob_help()

/atom/movable/screen/blob/JumpToNode
	icon_state = "ui_tonode"
	name = "К узлу"
	desc = "Перемещает вашу камеру к выбранному узлу."

/atom/movable/screen/blob/JumpToNode/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.jump_to_node()

/atom/movable/screen/blob/JumpToCore
	icon_state = "ui_tocore"
	name = "К ядру"
	desc = "Перемещает вашу камеру к вашему ядру."

/atom/movable/screen/blob/JumpToCore/MouseEntered(location,control,params)
	if(hud && hud.mymob && isovermind(hud.mymob))
		name = initial(name)
		desc = initial(desc)
	..()

/atom/movable/screen/blob/JumpToCore/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.transport_core()

/atom/movable/screen/blob/Blobbernaut
	icon_state = "ui_blobbernaut"
	name = "Создать блобернаута (ERROR)"
	desc = "Создает сильного и умного блоббернаута из фабрики за ERROR ресурсов.<br>Фабрика станет хрупкой и не сможет производить споры."

/atom/movable/screen/blob/Blobbernaut/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	name = "Создать блобернаута ([BLOBMOB_BLOBBERNAUT_RESOURCE_COST])"
	desc = "Создает сильного и умного блоббернаута из фабрики за [BLOBMOB_BLOBBERNAUT_RESOURCE_COST] ресурсов.<br>Фабрика станет хрупкой и не сможет производить споры."

/atom/movable/screen/blob/Blobbernaut/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_blobbernaut()

/atom/movable/screen/blob/StorageBlob
	icon_state = "ui_storage"
	name = "Создать хранилище (ERROR)"
	desc = "Создает хранилище за ERROR ресурсов.<br>Хранилища увеличивают ваш максимальный лимит ресурсов на ERROR."

/atom/movable/screen/blob/StorageBlob/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	name = "Создать хранилище ([BLOB_STRUCTURE_STORAGE_COST])"
	desc = "Создает хранилище за [BLOB_STRUCTURE_STORAGE_COST] ресурсов.<br>Хранилища увеличивают ваш максимальный лимит ресурсов на [BLOB_STORAGE_MAX_POINTS_BONUS]."

/atom/movable/screen/blob/StorageBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_special(BLOB_STRUCTURE_STORAGE_COST, /obj/structure/blob/storage, BLOB_STORAGE_MIN_DISTANCE, TRUE)

/atom/movable/screen/blob/ResourceBlob
	icon_state = "ui_resource"
	name = "Создать ресурсную плитку (ERROR)"
	desc = "Создает ресурсную плитку за ERROR ресурсов.<br>Ресурсные плитки будут приносить вам ресурсы каждые несколько секунд."

/atom/movable/screen/blob/ResourceBlob/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	name = "Создать ресурсную плитку ([BLOB_STRUCTURE_RESOURCE_COST])"
	desc = "Создает ресурсную плитку за [BLOB_STRUCTURE_RESOURCE_COST] ресурсов.<br>Ресурсные плитки будут приносить вам ресурсы каждые несколько секунд."

/atom/movable/screen/blob/ResourceBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_special(BLOB_STRUCTURE_RESOURCE_COST, /obj/structure/blob/special/resource, BLOB_RESOURCE_MIN_DISTANCE, TRUE)

/atom/movable/screen/blob/NodeBlob
	icon_state = "ui_node"
	name = "Создать узел (ERROR)"
	desc = "Создает узел за ERROR ресурсов.<br>Узлы будут расширяться и активировать ближайшие ресурсные плитки и фабрики."

/atom/movable/screen/blob/NodeBlob/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	name = "Создать узел ([BLOB_STRUCTURE_NODE_COST])"
	desc = "Создает узел за [BLOB_STRUCTURE_NODE_COST] ресурсов.<br>Узлы будут расширяться и активировать ближайшие ресурсные плитки и фабрики."

/atom/movable/screen/blob/NodeBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_special(BLOB_STRUCTURE_NODE_COST, /obj/structure/blob/special/node, BLOB_NODE_MIN_DISTANCE, FALSE)

/atom/movable/screen/blob/FactoryBlob
	icon_state = "ui_factory"
	name = "Создать фабрику (ERROR)"
	desc = "Производит фабрику за ERROR ресурсов.<br>Фабрики будут производить споры каждые несколько секунд."


/atom/movable/screen/blob/FactoryBlob/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	name = "Создать фабрику ([BLOB_STRUCTURE_FACTORY_COST])"
	desc = "Создает фабрику за [BLOB_STRUCTURE_FACTORY_COST] ресурсов.<br>Фабрики будут производить споры каждые несколько секунд."

/atom/movable/screen/blob/FactoryBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_special(BLOB_STRUCTURE_FACTORY_COST, /obj/structure/blob/special/factory, BLOB_FACTORY_MIN_DISTANCE, TRUE)


/atom/movable/screen/blob/ReadaptStrain
	icon_state = "ui_chemswap"
	name = "Реадаптация штамма"
	desc = "Позволяет вам выбрать новый штамм из случайных вариантов за Error ресурсов."

/atom/movable/screen/blob/ReadaptStrain/MouseEntered(location,control,params)
	if(hud && hud.mymob && isovermind(hud.mymob))
		var/mob/camera/blob/B = hud.mymob
		var/cost = (B.free_strain_rerolls)? "FREE" : BLOB_POWER_REROLL_COST
		name = "[initial(name)] ([cost])"
		desc = "Позволяет вам выбрать новый штамм из [BLOB_POWER_REROLL_CHOICES] случайных вариантов за [cost] ресурсов."
	..()

/atom/movable/screen/blob/ReadaptStrain/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.strain_reroll()

/atom/movable/screen/blob/RelocateCore
	icon_state = "ui_swap"
	name = "Переместить ядро (ERROR)"
	desc = "Меняет местами узел и ваше ядро за ERROR ресурсов."

/atom/movable/screen/blob/RelocateCore/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	name = "Переместить ядро ([BLOB_POWER_RELOCATE_COST])"
	desc = "Меняет местами узел и ваше ядро за [BLOB_POWER_RELOCATE_COST] ресурсов."

/atom/movable/screen/blob/RelocateCore/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.relocate_core()

/atom/movable/screen/blob/Split
	icon_state = "ui_split"
	name = "Разделить сознание (ERROR)"
	desc = "Создаёт ещё одного блоба на выбранном узле. Может быть использовано 1 раз.<br>Потомки не могут использовать это умение."

/atom/movable/screen/blob/Split/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	name = "Разделить сознание ([BLOB_CORE_SPLIT_COST])"

/atom/movable/screen/blob/Split/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.split_consciousness()

/datum/hud/blob_overmind/New(mob/user)
	..()
	var/atom/movable/screen/using

	blobpwrdisplay = new /atom/movable/screen(null, src)
	blobpwrdisplay.name = "blob power"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blobpwrdisplay.layer = ABOVE_HUD_LAYER
	SET_PLANE_EXPLICIT(blobpwrdisplay, ABOVE_HUD_PLANE, mymob)
	static_inventory += blobpwrdisplay

	blobhealthdisplay = new /atom/movable/screen/healths/blob(null, src)
	static_inventory += blobhealthdisplay

	using = new /atom/movable/screen/blob/BlobHelp(null, src)
	using.screen_loc = "WEST:6,NORTH:-3"
	static_inventory += using

	using = new /atom/movable/screen/blob/JumpToNode(null, src)
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /atom/movable/screen/blob/JumpToCore(null, src)
	using.screen_loc = ui_zonesel
	static_inventory += using

	using = new /atom/movable/screen/blob/Blobbernaut(null, src)
	using.screen_loc = ui_id
	static_inventory += using

	using = new /atom/movable/screen/blob/StorageBlob(null, src)
	using.screen_loc = ui_belt
	static_inventory += using

	using = new /atom/movable/screen/blob/ResourceBlob(null, src)
	using.screen_loc = ui_back
	static_inventory += using

	using = new /atom/movable/screen/blob/NodeBlob(null, src)
	using.screen_loc = using.screen_loc = ui_rhand
	static_inventory += using

	using = new /atom/movable/screen/blob/FactoryBlob(null, src)
	using.screen_loc = using.screen_loc = ui_lhand
	static_inventory += using

	using = new /atom/movable/screen/blob/ReadaptStrain(null, src)
	using.screen_loc = ui_storage1
	static_inventory += using

	using = new /atom/movable/screen/blob/RelocateCore(null, src)
	using.screen_loc = ui_storage2
	static_inventory += using

	using = new /atom/movable/screen/blob/Split(null, src)
	using.screen_loc = ui_acti
	static_inventory += using

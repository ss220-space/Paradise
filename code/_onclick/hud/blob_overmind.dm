/mob/camera/blob/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/blob_overmind(src)

/obj/screen/blob
	icon = 'icons/mob/blob.dmi'

/obj/screen/blob/MouseEntered(location,control,params)
	openToolTip(usr,src,params,title = name,content = desc, theme = "blob")

/obj/screen/blob/MouseExited()
	closeToolTip(usr)

/obj/screen/blob/BlobHelp
	icon_state = "ui_help"
	name = "Справка Блоба"
	desc = "Помощь в игре за Блоба!"

/obj/screen/blob/BlobHelp/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.blob_help()

/obj/screen/blob/JumpToNode
	icon_state = "ui_tonode"
	name = "Переместиться к Узлу"
	desc = "Перемещает камеру к выбранному Узлу Блоба."

/obj/screen/blob/JumpToNode/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.jump_to_node()

/obj/screen/blob/JumpToCore
	icon_state = "ui_tocore"
	name = "Переместиться к Ядру"
	desc = "Перемещает камеру к вашему Ядру Блоба."

/obj/screen/blob/JumpToCore/MouseEntered(location,control,params)
	if(hud && hud.mymob && isovermind(hud.mymob))
		name = initial(name)
		desc = initial(desc)
	..()

/obj/screen/blob/JumpToCore/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.transport_core()

/obj/screen/blob/Blobbernaut
	icon_state = "ui_blobbernaut"
	name = "Создать Блоббернаута (60)"
	desc = "Произвести сильное разумное порождение Блоба на Фабрике Блоба за 60 ресурсов.<br>Фабрика Блоба уничтожается в процессе."

/obj/screen/blob/Blobbernaut/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_blobbernaut()

/obj/screen/blob/StorageBlob
	icon_state = "ui_storage"
	name = "Сохдать Хранилище Блоба (40)"
	desc = "Создать Хранилище за 40 ресурсов.<br>Увеличиваем максимальную вместимость ресурсов на 50."

/obj/screen/blob/StorageBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_storage()

/obj/screen/blob/ResourceBlob
	icon_state = "ui_resource"
	name = "Создать Ресурсного Блоба (40)"
	desc = "Создает Ресурсного Блоба за 40 ресурсов.<br>Ресурсные Блобы будут давать вам ресурсы каждые несколько секунд ."

/obj/screen/blob/ResourceBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_resource()

/obj/screen/blob/NodeBlob
	icon_state = "ui_node"
	name = "Создать Узел Блоба (60)"
	desc = "Создает Узел Блоба за 60 ресурсов.<br>Узел Блоба позволит вам размещать вблизи Фабрику и Ресурсного Блоба."

/obj/screen/blob/NodeBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_node()

/obj/screen/blob/FactoryBlob
	icon_state = "ui_factory"
	name = "Создать Фабрику Блоба (60)"
	desc = "Создает Фабрику Блоба за 60 ресурсов.<br>Фабрика Блоба будет выпускать Споровиков каждые несколько секунд."

/obj/screen/blob/FactoryBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_factory()

/obj/screen/blob/ReadaptChemical
	icon_state = "ui_chemswap"
	name = "Химическая Адаптация (50)"
	desc = "Заменяет ваше химическое вещество на другое случайное за 50 ресурсов."

/obj/screen/blob/ReadaptChemical/MouseEntered(location,control,params)
	if(hud && hud.mymob && isovermind(hud.mymob))
		name = initial(name)
		desc = initial(desc)
	..()

/obj/screen/blob/ReadaptChemical/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.chemical_reroll()

/obj/screen/blob/RelocateCore
	icon_state = "ui_swap"
	name = "Переместить Ядро (80)"
	desc = "Меняет местами ваше Ядро и Узел за 80 ресурсов."

/obj/screen/blob/RelocateCore/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.relocate_core()

/obj/screen/blob/Split
	icon_state = "ui_split"
	name = "Разделение Сознания (100)"
	desc = "Создает еще одного разумного Сверхразума Блоба на выбронном Узле. Только одно использование.<br>Потомок не может использовать эту способность."

/obj/screen/blob/Split/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.split_consciousness()

/datum/hud/blob_overmind/New(mob/user)
	..()
	var/obj/screen/using

	blobpwrdisplay = new /obj/screen()
	blobpwrdisplay.name = "Мощь Блоба"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blobpwrdisplay.layer = ABOVE_HUD_LAYER
	blobpwrdisplay.plane = ABOVE_HUD_PLANE
	static_inventory += blobpwrdisplay

	blobhealthdisplay = new /obj/screen()
	blobhealthdisplay.name = "Здоровье Блоба"
	blobhealthdisplay.icon_state = "block"
	blobhealthdisplay.screen_loc = ui_internal
	static_inventory += blobhealthdisplay

	using = new /obj/screen/blob/BlobHelp()
	using.screen_loc = "WEST:6,NORTH:-3"
	static_inventory += using

	using = new /obj/screen/blob/JumpToNode()
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /obj/screen/blob/JumpToCore()
	using.screen_loc = ui_zonesel
	using.hud = src
	static_inventory += using

	using = new /obj/screen/blob/Blobbernaut()
	using.screen_loc = ui_id
	static_inventory += using

	using = new /obj/screen/blob/StorageBlob()
	using.screen_loc = ui_belt
	static_inventory += using

	using = new /obj/screen/blob/ResourceBlob()
	using.screen_loc = ui_back
	static_inventory += using

	using = new /obj/screen/blob/NodeBlob()
	using.screen_loc = using.screen_loc = ui_rhand
	static_inventory += using

	using = new /obj/screen/blob/FactoryBlob()
	using.screen_loc = using.screen_loc = ui_lhand
	static_inventory += using

	using = new /obj/screen/blob/ReadaptChemical()
	using.screen_loc = ui_storage1
	using.hud = src
	static_inventory += using

	using = new /obj/screen/blob/RelocateCore()
	using.screen_loc = ui_storage2
	static_inventory += using

	using = new /obj/screen/blob/Split()
	using.screen_loc = ui_acti
	static_inventory += using

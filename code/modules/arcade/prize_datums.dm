GLOBAL_DATUM_INIT(global_prizes, /datum/prizes, new())

/datum/prizes
	var/list/prizes = list()

/datum/prizes/New()
	for(var/itempath in subtypesof(/datum/prize_item))
		prizes += new itempath()

/datum/prizes/proc/PlaceOrder(var/obj/machinery/prize_counter/prize_counter, var/itemID)
	if(!prize_counter.Adjacent(usr))
		to_chat(usr, "<span class='warning'>You need to be closer!</span>")
		return
	if(!prize_counter)
		return 0
	var/datum/prize_item/item = GLOB.global_prizes.prizes[itemID]
	if(!item)
		return 0
	if(prize_counter.tickets >= item.cost)
		new item.typepath(prize_counter.loc)
		prize_counter.tickets -= item.cost
		prize_counter.visible_message("<span class='notice'>Enjoy your prize!</span>")
		return 1
	else
		prize_counter.visible_message("<span class='warning'>Not enough tickets!</span>")
		return 0

//////////////////////////////////////
//			prize_item datum		//
//////////////////////////////////////

/datum/prize_item
	var/name = "Prize"
	var/desc = "This shouldn't show up..."
	var/typepath = /obj/item/toy/prizeball
	var/cost = 0

//////////////////////////////////////
//			    Prizes		    	//
//////////////////////////////////////

/datum/prize_item/balloon
	name = "Water Balloon"
	desc = "Воздушный шарик, наполняемый водой. Можно кинуть в другого человека!"
	typepath = /obj/item/toy/balloon
	cost = 10

/datum/prize_item/spinningtoy
	name = "Spinning Toy"
	desc = "Выглядит прям как Сингулярность!"
	typepath = /obj/item/toy/spinningtoy
	cost = 15

/datum/prize_item/blinktoy
	name = "Blink Toy"
	desc = "Blink. Blink. Blink."
	typepath = /obj/item/toy/blink
	cost = 15

/datum/prize_item/foam_darts
	name = "Pack of Foam Darts"
	desc = "Безвредный боезапас для донксофт оружия."
	typepath = /obj/item/ammo_box/foambox
	cost = 20

/datum/prize_item/snappops
	name = "Snap-Pops"
	desc = "Коробка взрывоопасных фейерверков Snap-Pops."
	typepath = /obj/item/storage/box/snappops
	cost = 20

/datum/prize_item/cards
	name = "Deck of Cards"
	desc = "Кто-нибудь хочет сыграть в дурака на 52 карты?"
	typepath = /obj/item/deck/cards
	cost = 25

/datum/prize_item/eight_ball
	name = "Magic Eight Ball"
	desc = "Мистический шар, способный предсказывать будущее!"
	typepath = /obj/item/toy/eight_ball
	cost = 40

/datum/prize_item/unum
	name = "Deck of UNUM! Cards"
	desc = "Всеми любимая карточная игра!"
	typepath = /obj/item/deck/unum
	cost = 45

/datum/prize_item/wallet
	name = "Colored Wallet"
	desc = "Стильный цветной кошелек для хранения вашей ID карты."
	typepath = /obj/item/storage/wallet/color
	cost = 50

/datum/prize_item/id_sticker
	name = "Prisoner ID Sticker"
	desc = "Наклейка, которая сделает любую ID-карту похожей на ID-карту заключенного."
	typepath = /obj/item/id_decal/prisoner
	cost = 50

/datum/prize_item/id_sticker/silver
	name = "Silver ID Sticker"
	desc = "Наклейка, которая сделает любую ID серебряной."
	typepath = /obj/item/id_decal/silver

/datum/prize_item/id_sticker/gold
	name = "Gold ID Sticker"
	desc = "Наклейка, которая сделает любую ID золотой."
	typepath = /obj/item/id_decal/gold

/datum/prize_item/id_sticker/centcom
	name = "Centcomm ID Sticker"
	desc = "Наклейка, которая сделает любую ID карту похожей на ID Центрального командования."
	typepath = /obj/item/id_decal/centcom

/datum/prize_item/id_sticker/emag
	name = "Suspicious ID Sticker"
	desc = "Наклейка, которая превращает вашу ID карту в нечто подозрительное..."
	typepath = /obj/item/id_decal/emag

/datum/prize_item/flash
	name = "Toy Flash"
	desc = "ААААА! МОИ ГЛАЗА!!!"
	typepath = /obj/item/toy/flash
	cost = 50

/datum/prize_item/minimeteor
	name = "Mini-Meteor"
	desc = "Обнаружены метеоры, идущие на столкновение с вашим весёлым временем!"
	typepath = /obj/item/toy/minimeteor
	cost = 50

/datum/prize_item/minigibber
	name = "Minigibber Toy"
	desc = "Миниатюрная копия кухонного гибера. Наверное, не стоит совать в это пальцы."
	typepath = /obj/item/toy/minigibber
	cost = 60

/datum/prize_item/confetti
	name = "Confetti Grenade"
	desc = "Время тусовок!"
	typepath = /obj/item/grenade/confetti
	cost = 50

/datum/prize_item/AI
	name = "Toy AI Unit"
	desc = "1. Доставьте максимум удовольствия экипажу."
	typepath = /obj/item/toy/AI
	cost = 75

/datum/prize_item/mech_toy
	name = "Random Mecha"
	desc = "Случайная фигурка мехов!"
	typepath = /obj/item/toy/prizeball/mech
	cost = 75

/datum/prize_item/capgun
	name = "Capgun Revolver"
	desc = "Ты, наверное, думаешь, что тебе выпало .357 карат невезения?"
	typepath = /obj/item/gun/projectile/revolver/capgun
	cost = 75

/datum/prize_item/codex_gigas
	name = "Toy Codex Gigas"
	desc = "Книга, способная хранить имена самых ужасных демонов в галактике. Стоит записать в неё имя вашего клоуна."
	typepath = /obj/item/toy/codex_gigas/
	cost = 75

/datum/prize_item/rubberducky
	name = "Rubber Ducky"
	desc = "Ваш любимый друг во время купания, лучшая пищялка-крякалка для ванной."
	typepath = /obj/item/bikehorn/rubberducky
	cost = 80

/datum/prize_item/spacesuit
	name = "Fake Spacesuit"
	desc = "Реплика скафандра синдиката. Не пригоден для использования в космосе."
	typepath = /obj/item/storage/box/fakesyndiesuit
	cost = 90

/datum/prize_item/owl
	name = "Owl Action Figure"
	desc = "Помните: герои не становятся ГРИФонами!"
	typepath = /obj/item/toy/owl
	cost = 100

/datum/prize_item/griffin
	name = "Griffin Action Figure"
	desc = "Если вы не можете быть лучшим, вы всегда можете быть ХУДШИМ."
	typepath = /obj/item/toy/griffin
	cost = 100

/datum/prize_item/fakespell
	name = "Fake Spellbook"
	desc = "Абсолютно настоящая магия дезинтеграции человека на мелкие кусочки!"
	typepath = /obj/item/spellbook/oneuse/fake_gib
	cost = 100

/datum/prize_item/fakefingergun
	name = "Miming Manual : Finger Gun"
	desc = "..."
	typepath = /obj/item/spellbook/oneuse/mime/fingergun/fake
	cost = 100

/datum/prize_item/magic_conch
	name = "Magic Conch Shell"
	desc = "Если приложить к уху, то можно услышать космо-море!"
	typepath = /obj/item/toy/eight_ball/conch
	cost = 100

/datum/prize_item/foamblade
	name = "Foam Arm Blade"
	desc = "Идеально подходит для воспроизведения голо-фильмов ужасов."
	typepath = /obj/item/toy/foamblade
	cost = 100

/datum/prize_item/redbutton
	name = "Shiny Red Button"
	desc = "НАЖМИ НА ЭТО!"
	typepath = /obj/item/toy/redbutton
	cost = 100

/datum/prize_item/nuke
	name = "Nuclear Fun Device"
	desc = "Помнит кто коды для активации?"
	typepath = /obj/item/toy/nuke
	cost = 100

/datum/prize_item/blobhat
	name = "Blob Hat"
	desc = "У тебя... Что-то... На голове..."
	typepath = /obj/item/clothing/head/blob
	cost = 125

/datum/prize_item/esword
	name = "Toy Energy Sword"
	desc = "A plastic replica of an energy blade."
	typepath = /obj/item/toy/sword
	cost = 150

/datum/prize_item/fakespace
	name = "Space Carpet"
	desc = "Стопка напольных плиток с ковровым покрытием, напоминающих космос."
	typepath = /obj/item/stack/tile/fakespace/loaded
	cost = 150

/datum/prize_item/arcadecarpet
	name = "Arcade Carpet"
	desc = "Стопка настоящих аркадных ковровых плиток с подлинными пятнами от прохладительных напитков!"
	typepath = /obj/item/stack/tile/arcade_carpet/loaded
	cost = 150

/datum/prize_item/tommygun
	name = "Tommy Gun"
	desc = "Реплика Томми-гана, стреляющего дротиками из пенопласта."
	typepath = /obj/item/gun/projectile/shotgun/toy/tommygun
	cost = 175

/datum/prize_item/chainsaw
	name = "Toy Chainsaw"
	desc = "Полноразмерная модель бензопилы, основанная на той самой Техасской космо-резне бензопилой."
	typepath = /obj/item/twohanded/toy/chainsaw
	cost = 200

/datum/prize_item/headpat
	name = "Gloves of Headpats"
	desc = "Перчатки, которые наполняют вас непреодолимым желанием погладить кого нибудь по голове."
	typepath = /obj/item/clothing/gloves/fingerless/rapid/headpat
	cost = 150

/datum/prize_item/rubbertoolbox
	name = "Rubber Toolbox"
	desc = "Тренируйте свой робаст!"
	typepath = /obj/item/toy/toolbox
	cost = 200

/datum/prize_item/crossbow
	name = "Toy Energy Crossbow"
	desc = "Игрушечное оружие, сделанное из тагерного пистолета со стильным дизайном контрабандного арбалета."
	typepath = /obj/item/gun/energy/kinetic_accelerator/crossbow/toy
	cost = 300

/datum/prize_item/enforce
	name = "Foam Force Enforce"
	desc = "Точная копия стандартного вооружения службы безопасности НТ."
	typepath = /obj/item/gun/projectile/automatic/toy/pistol/enforcer
	cost = 350

/datum/prize_item/shotgun
	name = "Foam Force Shotgun"
	desc = "Помповый донксофт дробовик со скользящим цевьём для быстрой стрельбы."
	typepath = /obj/item/gun/projectile/shotgun/toy
	cost = 400

/datum/prize_item/bike
	name = "Awesome Bike!"
	desc = "Я прикупил огромный байк..."
	typepath = /obj/vehicle/motorcycle
	cost = 2500

/datum/prize_item/speedbike
	name = "Awesome Speedbike!"
	desc = "Спорим, что вы не сможете его купить? XD"
	typepath =/obj/vehicle/space/speedbike/red
	cost = 10000	//max stack + 1 tickets.

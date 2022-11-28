/datum/training_task/basic_1_1
	description = list("Здравствуйте и добро пожаловать на начальный курс обучения СС220, где вас научат начальным навыкам управления.",
	"Я ваш интеллектуальный помощник в этом нелегком деле.",
	"Давайте начнем с основ передвижения!",
	"Для перемещния используюся клавиши WASD",
	"На клавишу TAB вы можете переключить режим хоткеев.",
	"Переключите режим если вам не удается перемещаться с помощью WASD",
	"По началу двигаться в этой гравитационной среде, может показаться довольно сложным и дезориентирующим.",
	"Уделите минутку что бы привыкнуть к этому и скоро вы заметите как это легко, ожидаем вас в следующей комнате.")
	var/obj/machinery/door/airlock/glass/airlock
	var/turf/final_turf
	user_start_x = 2

/datum/training_task/basic_1_1/init_task()
	spawn_window(get_center().x, master.y + 1)
	spawn_window(get_center().x, master.y + 2)
	airlock = spawn_airlock(get_center().x, master.y + 3)
	spawn_window(get_center().x, master.y + 4)
	spawn_window(get_center().x, master.y + 5)
	airlock.lock()

	final_turf = get_turf(locate(master.get_max_coordinate().x - 2, master.get_center().y, master.z))
	final_turf.icon = 'icons/turf/decals.dmi'
	final_turf.icon_state = "delivery"
	..()

/datum/training_task/basic_1_1/instruction_end()
	airlock.unlock()

/datum/training_task/basic_1_1/check_func()
	if (user.x == final_turf.x && user.y == final_turf.y)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

/datum/training_task/basic_2_1
	description = list("В этой комнате вы научитесь базовому взаимодействию с вещами, перед вами стоит стул",
	"Попробуйте сесть на стул",
	"Для этого достаточно встать на клетку со стулом и <strong>перетащить с помощью ЛКМ</strong> своего персонажа на стул",
	"Перетащить нужно на любой видимый кусочек стула")
	var/obj/structure/chair/chair

	user_start_x = 2

datum/training_task/basic_2_1/init_task()
	chair = new /obj/structure/chair(locate(get_center().x, get_center().y, master.z))
	..()

datum/training_task/basic_2_1/check_func()
	if (user.buckled == chair)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_2_2
	description = list("Чтобы встать со стула достаточно нажать <strong>B</strong>",
		"Помните, что если вы связаны и прикованы к стулу, то у вас не получится встать быстро",
		"Встаньте со стула, нажав <strong>B</strong>")

datum/training_task/basic_2_2/check_func()
	if (!user.buckled)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_3_1
	description = list("У вас есть 2 руки (иконки внизу по центру экрана). Одна из них - активная",
	"Поменяйте активную руку с помощью клавиши <strong>X</strong>")
	var/saved_hand

datum/training_task/basic_3_1/init_task()
	saved_hand = user.hand
	..()

datum/training_task/basic_3_1/check_func()
	if (user.hand != saved_hand)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

datum/training_task/basic_3_2
	description = list("Вам выдан ваш ПДА. Он находится в вашем кармане (ячейка внизу справа)",
		"В карманах своего персонажа вы можете носить самые разные вещи",
		"Для того, чтобы достать предмет из кармана в руки вам требуется нажать ЛКМ по предмету, не имея вещей в активной руке",
		"Возьмите ПДА в вашу руку нажатием на него ЛКМ")

datum/training_task/basic_3_2/init_task()
	user.equip_to_slot_if_possible(new /obj/item/pda, slot_wear_pda)
	..()

datum/training_task/basic_3_2/check_func()
	if (istype(user.get_active_hand(), /obj/item/pda))
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_3_3
	description = list("Имея в активной руке предмет вы можете его 'использовать'",
		"К примеру, имея в руке ПДА, вы можете его открыть",
		"Для этого используется клавиша <strong>Z</strong>",
		"Правило не распространяется на еду, напитки, шприцы и некоторые другие вещи",
		"Для их использования нажмите <strong>ЛКМ</strong> на своего персонажа, держа в активной руке предмет",
		"Важно понимать, когда предмет <i>просто используется</i>, а когда <i>используется на персонажа</i>",
		"В первом случае используйте <strong>Z</strong>, во втором <strong>ЛКМ</strong> на персонажа",
		"Попробуйте открыть ПДА с помощью клавиши <strong>Z</strong>, держа ПДА в активной руке")

datum/training_task/basic_3_3/check_func()
	var/datum/tgui/active_ui = SStgui.get_open_ui(user, user.find_item(/obj/item/pda), "main")
	if (active_ui)
		on_task_success()
		master.task_completed()
	else
		..()


datum/training_task/basic_3_4
	description = list("Как видите, ПДА еще не активирован",
		"На обычной смене вам изначально будет выдан ваш ПДА",
		"Однако сейчас вам нужно будет активировать ПДА самому",
		"Закройте окно ПДА и найдите свою новую ID карту в левом нижнем углу экрана",
		"Возьмите ID карту в руку так, чтобы в активной руке лежала ваша ID карта, а в неактивной - PDA")

datum/training_task/basic_3_4/init_task()
	user.equip_to_slot_if_possible(new /obj/item/card/id/captains_spare, slot_wear_id)
	..()

datum/training_task/basic_3_4/check_func()
	if (istype(user.get_inactive_hand(), /obj/item/pda) && istype(user.get_active_hand(), /obj/item/card/id/captains_spare))
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_3_5
	description = list("А теперь, держа ID карту в активной руке, нажмите <strong>ЛКМ</strong> по ПДА, чтобы активировать его")

datum/training_task/basic_3_5/check_func()
	if (user.find_item(/obj/item/pda)?.owner)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_3_6
	description = list("Теперь, держа карту в активной руке, нажмите клавишу <strong>Е</strong> для того, чтобы быстро экипировать ее в нужный слот",
		"Горячая клавиша <strong>E</strong> подходит для почти любых предметов и позволяет быстро поместить их в нужное место",
		"После этого снова возьмите ПДА в активную руку и 'используйте' его клавишей <strong>Z</strong>",
		"На этот раз у вас будет открыто меню ПДА",
		"В ПДА есть немало полезных вещей, однако это вы узнаете позднее",
		"Сейчас закройте окно ПДА и поместите ПДА в ваш слот для ПДА. Используйте клавишу <strong>E</strong>)",
		"Для продолжения карта и ПДА должны лежать в соответствующих слотах")

datum/training_task/basic_3_6/check_func()
	if (istype(user.get_item_by_slot(slot_wear_id), /obj/item/card/id) && istype(user.get_item_by_slot(slot_wear_pda), /obj/item/pda))
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_4_1
	description = list("А сейчас жизненно важная задача",
		"Иногда (почти всегда) на станции не все идет гладко",
		"Если вы увидели космос там, где его быть не должно, совет один - бегите оттуда",
		"А вот если вы вдруг оказались в зоне, где просто нет воздуха (бывает и такое) - вам помогут маска и баллон с воздухом",
		"Вам выдан рюкзак, содержащий ту самую маску и тот самый баллон",
		"Сначала вам нужно надеть маску на лицо",
		"Для этого откройте рюкзак, нажав на него <strong>ЛКМ</strong>",
		"Откроется панель с вещами, лежащими в рюкзаке. Нажмите на маску <strong>ЛКМ</strong> чтобы взять ее в руку")
	var/obj/item/clothing/mask/breath/mask
	var/obj/item/tank/internals/emergency_oxygen/engi/oxygen
	var/obj/item/storage/backpack/backpack

datum/training_task/basic_4_1/init_task()
	mask = new()
	oxygen = new()
	backpack = new()
	user.equip_to_slot_if_possible(backpack, slot_back)
	backpack.contents.Add(mask)
	backpack.contents.Add(oxygen)
	. = ..()

datum/training_task/basic_4_1/check_func()
	if (istype(user.get_active_hand(), /obj/item/clothing/mask/breath))
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_4_2
	description = list("Хорошо, теперь наденьте маску на лицо",
		"Сделать это можно двумя способами",
		"1 - держа маску в активной руке нажмите <strong>E</strong>. Она автоматически наденется на лицо, если сейчас на нем ничего нет",
		"2 - откойте панель экипировки нажав на значок сумки в левом нижнем углу и, держа маску в активной руке, нажмите на слот маски",
		"Так или иначе, наденьте маску на лицо")

datum/training_task/basic_4_2/check_func()
	if (istype(user.get_item_by_slot(slot_wear_mask), /obj/item/clothing/mask/breath))
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_4_3
	description = list("Одной маски будет недостаточно",
		"Достаньте из рюкзака баллон и наденьте его в подходящий слот (можно и с помощью клавиши <strong>E</strong>)",
		"Данный баллон может поместиться и в карман, однако баллоны бывают разных размеров",
		"Наденьте баллон на себя")
	var/obj/item/storage/backpack/backpack
	var/obj/item/tank/internals/emergency_oxygen/engi/oxygen

datum/training_task/basic_4_3/init_task()
	backpack = user.get_item_by_slot(slot_back)
	oxygen = user.find_item(/obj/item/tank/internals/emergency_oxygen/engi)
	..()


datum/training_task/basic_4_3/check_func()
	if (!user.get_active_hand() && !user.get_inactive_hand() && !backpack.contents.len)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_4_4
	description = list("Осталось последнее - включить баллон",
		"Конечно можно взять баллон в руку, нажать <strong>Z</strong>, чтобы открылось меню баллона, и там нажать 'Set internals', но можно и проще",
		"Если у вас в руких или на себе есть баллон, в левом верхнем углу появляется иконка баллона",
		"Чтобы включить или отключить подачу газа достаточно нажать на эту кнопку",
		"Включите подачу воздуха в маску")
	var/obj/item/tank/internals/emergency_oxygen/engi/oxygen

datum/training_task/basic_4_4/init_task()
	oxygen = user.find_item(/obj/item/tank/internals/emergency_oxygen/engi)
	..()

datum/training_task/basic_4_4/check_func()
	if (user.internal == oxygen)
		on_task_success()
		master.task_completed()
	else
		..()

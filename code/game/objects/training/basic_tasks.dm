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
	var/datum/training_coords/center = get_center()
	var/datum/training_coords/max_coordinate = get_max_coordinate()
	spawn_window(center.x, master.y + 1)
	spawn_window(center.x, master.y + 2)
	airlock = spawn_airlock(center.x, master.y + 3)
	spawn_window(center.x, master.y + 4)
	spawn_window(center.x, master.y + 5)
	airlock.lock()

	final_turf = get_turf(locate(max_coordinate.x - 2, center.y, master.z))
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

/datum/training_task/basic_2_1/init_task()
	var/datum/training_coords/center = get_center()
	chair = new /obj/structure/chair(locate(center.x, center.y, master.z))
	..()

/datum/training_task/basic_2_1/check_func()
	if (user.buckled == chair)
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_2_2
	description = list("Чтобы встать со стула достаточно нажать <strong>B</strong>",
		"Помните, что если вы связаны и прикованы к стулу, то у вас не получится встать быстро",
		"Встаньте со стула, нажав <strong>B</strong>")

/datum/training_task/basic_2_2/check_func()
	if (!user.buckled)
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_3_1
	description = list("У вас есть 2 руки (иконки внизу по центру экрана). Одна из них - активная",
	"Поменяйте активную руку с помощью клавиши <strong>X</strong>")
	var/saved_hand

/datum/training_task/basic_3_1/init_task()
	saved_hand = user.hand
	..()

/datum/training_task/basic_3_1/check_func()
	if (user.hand != saved_hand)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

/datum/training_task/basic_3_2
	description = list("Вам выдан ваш ПДА. Он находится в вашем кармане (ячейка внизу справа)",
		"В карманах своего персонажа вы можете носить самые разные вещи",
		"Для того, чтобы достать предмет из кармана в руки вам требуется нажать ЛКМ по предмету, не имея вещей в активной руке",
		"Возьмите ПДА в вашу руку нажатием на него ЛКМ")

/datum/training_task/basic_3_2/init_task()
	user.equip_to_slot_if_possible(new /obj/item/pda, slot_wear_pda)
	..()

/datum/training_task/basic_3_2/check_func()
	if (istype(user.get_active_hand(), /obj/item/pda))
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_3_3
	description = list("Имея в активной руке предмет вы можете его 'использовать'",
		"К примеру, имея в руке ПДА, вы можете его открыть",
		"Для этого используется клавиша <strong>Z</strong>",
		"Правило не распространяется на еду, напитки, шприцы и некоторые другие вещи",
		"Для их использования нажмите <strong>ЛКМ</strong> на своего персонажа, держа в активной руке предмет",
		"Важно понимать, когда предмет <i>просто используется</i>, а когда <i>используется на персонажа</i>",
		"В первом случае используйте <strong>Z</strong>, во втором <strong>ЛКМ</strong> на персонажа",
		"Попробуйте открыть ПДА с помощью клавиши <strong>Z</strong>, держа ПДА в активной руке")

/datum/training_task/basic_3_3/check_func()
	var/datum/tgui/active_ui = SStgui.get_open_ui(user, user.find_item(/obj/item/pda), "main")
	if (active_ui)
		on_task_success()
		master.task_completed()
	else
		..()


/datum/training_task/basic_3_4
	description = list("Как видите, ПДА еще не активирован",
		"На обычной смене вам изначально будет выдан ваш ПДА",
		"Однако сейчас вам нужно будет активировать ПДА самому",
		"Закройте окно ПДА и найдите свою новую ID карту в левом нижнем углу экрана",
		"Возьмите ID карту в руку так, чтобы в активной руке лежала ваша ID карта, а в неактивной - PDA")

/datum/training_task/basic_3_4/init_task()
	user.equip_to_slot_if_possible(new /obj/item/card/id/captains_spare, slot_wear_id)
	..()

/datum/training_task/basic_3_4/check_func()
	if (istype(user.get_inactive_hand(), /obj/item/pda) && istype(user.get_active_hand(), /obj/item/card/id/captains_spare))
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_3_5
	description = list("А теперь, держа ID карту в активной руке, нажмите <strong>ЛКМ</strong> по ПДА, чтобы активировать его")

/datum/training_task/basic_3_5/check_func()
	var/obj/item/pda/pda = user.find_item(/obj/item/pda)
	if (pda && pda.owner)
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_3_6
	description = list("Теперь, держа карту в активной руке, нажмите клавишу <strong>Е</strong> для того, чтобы быстро экипировать ее в нужный слот",
		"Горячая клавиша <strong>E</strong> подходит для почти любых предметов и позволяет быстро поместить их в нужное место",
		"После этого снова возьмите ПДА в активную руку и 'используйте' его клавишей <strong>Z</strong>",
		"На этот раз у вас будет открыто меню ПДА",
		"В ПДА есть немало полезных вещей, однако это вы узнаете позднее",
		"Сейчас закройте окно ПДА и поместите ПДА в ваш слот для ПДА. Используйте клавишу <strong>E</strong>)",
		"Для продолжения карта и ПДА должны лежать в соответствующих слотах")

/datum/training_task/basic_3_6/check_func()
	if (istype(user.get_item_by_slot(slot_wear_id), /obj/item/card/id) && istype(user.get_item_by_slot(slot_wear_pda), /obj/item/pda))
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_4_1
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

/datum/training_task/basic_4_1/init_task()
	mask = new()
	oxygen = new()
	backpack = new()
	user.equip_to_slot_if_possible(backpack, slot_back)
	backpack.contents.Add(mask)
	backpack.contents.Add(oxygen)
	. = ..()

/datum/training_task/basic_4_1/check_func()
	if (istype(user.get_active_hand(), /obj/item/clothing/mask/breath))
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_4_2
	description = list("Хорошо, теперь наденьте маску на лицо",
		"Сделать это можно двумя способами",
		"1 - держа маску в активной руке нажмите <strong>E</strong>. Она автоматически наденется на лицо, если сейчас на нем ничего нет",
		"2 - откойте панель экипировки нажав на значок сумки в левом нижнем углу и, держа маску в активной руке, нажмите на слот маски",
		"Так или иначе, наденьте маску на лицо")

/datum/training_task/basic_4_2/check_func()
	if (istype(user.get_item_by_slot(slot_wear_mask), /obj/item/clothing/mask/breath))
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_4_3
	description = list("Одной маски будет недостаточно",
		"Достаньте из рюкзака баллон и наденьте его в подходящий слот (можно и с помощью клавиши <strong>E</strong>)",
		"Данный баллон может поместиться и в карман, однако баллоны бывают разных размеров",
		"Наденьте баллон на себя")
	var/obj/item/storage/backpack/backpack
	var/obj/item/tank/internals/emergency_oxygen/engi/oxygen

/datum/training_task/basic_4_3/init_task()
	backpack = user.get_item_by_slot(slot_back)
	oxygen = user.find_item(/obj/item/tank/internals/emergency_oxygen/engi)
	..()


/datum/training_task/basic_4_3/check_func()
	if (!user.get_active_hand() && !user.get_inactive_hand() && !backpack.contents.len)
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_4_4
	description = list("Осталось последнее - включить баллон",
		"Конечно можно взять баллон в руку, нажать <strong>Z</strong>, чтобы открылось меню баллона, и там нажать 'Set internals', но можно и проще",
		"Если у вас в руких или на себе есть баллон, в левом верхнем углу появляется иконка баллона",
		"Чтобы включить или отключить подачу газа достаточно нажать на эту кнопку",
		"Включите подачу воздуха в маску")
	var/obj/item/tank/internals/emergency_oxygen/engi/oxygen

/datum/training_task/basic_4_4/init_task()
	oxygen = user.find_item(/obj/item/tank/internals/emergency_oxygen/engi)
	..()

/datum/training_task/basic_4_4/check_func()
	if (user.internal == oxygen)
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_5_1
	description = list("Теперь, когда вы здесь, единственный путь отсюда это пройти через этот огонь.",
	"Пройдите через него и потушитесь, вы все-таки хотите сбить с себя огонь, дабы не умереть в адских муках и агонии!",
	"Нажмите клавишу «B» или значок огня в правом верхнем углу. Возможно вам придется «потушиться» несколько раз.")
	var/turf/final_turf
	user_start_x = 2

/datum/training_task/basic_5_1/init_task()
	var/datum/training_coords/center = get_center()
	var/datum/training_coords/max_coordinate = get_max_coordinate()
	spawn_window(center.x, master.y + 1)
	new /turf/simulated/floor/plating/lava/smooth(locate(center.x, master.y + 2, master.z))
	new /turf/simulated/floor/plating/lava/smooth(locate(center.x, master.y + 3, master.z))
	new /turf/simulated/floor/plating/lava/smooth(locate(center.x, master.y + 4, master.z))
	spawn_window(center.x, master.y + 5)

	final_turf = get_turf(locate(max_coordinate.x - 2, center.y, master.z))
	final_turf.icon = 'icons/turf/decals.dmi'
	final_turf.icon_state = "delivery"
	..()

/datum/training_task/basic_5_1/check_func()
	if (user.x == final_turf.x && user.y == final_turf.y && !user.on_fire)
		on_task_success("Отлично. После такого рекомендуется обратиться за помощью в медицинский отдел, конечно если кто-то там будет свободен и жив")
		master.task_completed()
	else
		..()

/datum/training_task/basic_6_1
	description = list("Иногда некоторые зоны куда вы хотите попасть закрыты препятствиями, некоторые можно убрать, а с некоторыми придется повозиться.",
	"Сейчас перед вами коробка, попробуйте ее оттолкнуть с прохода.",
	"Толкать легко, просто подвиньтесь вперед к коробке, и вы сможете ее оттолкнуть")
	var/turf/final_turf
	user_start_x = 2

/datum/training_task/basic_6_1/init_task()
	var/datum/training_coords/center = get_center()
	var/datum/training_coords/max_coordinate = get_max_coordinate()
	spawn_window(center.x, master.y + 1)
	spawn_window(center.x, master.y + 2)
	new /obj/structure/ore_box(locate(center.x, master.y + 3, master.z))
	spawn_window(center.x, master.y + 4)
	spawn_window(center.x, master.y + 5)

	final_turf = get_turf(locate(max_coordinate.x - 2, center.y, master.z))
	final_turf.icon = 'icons/turf/decals.dmi'
	final_turf.icon_state = "delivery"
	..()

/datum/training_task/basic_6_1/check_func()
	if (user.x == final_turf.x && user.y == final_turf.y)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

/datum/training_task/basic_7_1
	description = list("Если вы не можете оттолкнуть препятствие со своего пути, вы можете попробовать потянуть его.",
	"Чтобы потянуть коробку, подойдите к ней и нажмите сочетание клавиш Ctrl+ЛКМ.!")
	var/turf/final_turf
	var/obj/structure/ore_box/ore_box
	user_start_x = 2

/datum/training_task/basic_7_1/init_task()
	var/datum/training_coords/center = get_center()
	var/datum/training_coords/max_coordinate = get_max_coordinate()
	spawn_window(center.x, master.y + 1)
	spawn_window(center.x, master.y + 2)
	spawn_window(center.x + 1, master.y + 2)
	spawn_window(center.x + 1, master.y + 3)
	ore_box = new (locate(center.x, master.y + 3, master.z))
	spawn_window(center.x - 1, master.y + 4)
	spawn_window(center.x, master.y + 5)
	spawn_window(center.x - 1, master.y + 5)

	final_turf = get_turf(locate(max_coordinate.x - 2, center.y, master.z))
	final_turf.icon = 'icons/turf/decals.dmi'
	final_turf.icon_state = "delivery"
	..()

/datum/training_task/basic_7_1/check_func()
	if (user.pulling == ore_box)
		on_task_success("Поздравляю, вы тащите коробку!")
		master.task_completed()
	else
		..()

/datum/training_task/basic_7_2
	description = list("Теперь оттащите коробку чтобы освободить проход.",
	"Что бы ее отпустить коробку нажмите клавишу «C»")
	var/turf/final_turf
	var/obj/structure/ore_box/ore_box

/datum/training_task/basic_7_2/init_task()
	var/datum/training_coords/center = get_center()
	var/datum/training_coords/max_coordinate = get_max_coordinate()
	final_turf = get_turf(locate(max_coordinate.x - 2, center.y, master.z))
	..()

/datum/training_task/basic_7_2/check_func()
	if (user.x == final_turf.x && user.y == final_turf.y)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

/datum/training_task/basic_8_1
	description = list("И наконец, если уже ничего не помогает, вы можете попробовать сломать объект на вашем пути.",
	"Возьмите эту монтировку и сломайте это стекло, чтобы проложить себе путь дальше..",
	"Не волнуйтесь, мы не вычтем это из вашей зарплаты!",
	"Возьмите монтировку в активную руку и нажмите ЛКМ по стеклу")
	var/turf/final_turf
	user_start_x = 2

/datum/training_task/basic_8_1/init_task()
	var/datum/training_coords/center = get_center()
	var/datum/training_coords/max_coordinate = get_max_coordinate()
	spawn_window(center.x, master.y + 1)
	spawn_window(center.x, master.y + 2)
	new /obj/structure/window/full(locate(center.x, master.y + 3, master.z))
	spawn_window(center.x, master.y + 4)
	spawn_window(center.x, master.y + 5)
	new /obj/item/crowbar/large(locate(center.x - 1, master.y + 3, master.z))

	final_turf = get_turf(locate(max_coordinate.x - 2, center.y, master.z))
	final_turf.icon = 'icons/turf/decals.dmi'
	final_turf.icon_state = "delivery"
	..()

/datum/training_task/basic_8_1/check_func()
	if (user.x == final_turf.x && user.y == final_turf.y)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

/datum/training_task/basic_9_1
	description = list("Чтобы попасть в следующую комнату, вам нужно будет пройти через зону космического пространства.",
	"Перед вами находится труп члена экипажа, который не смог пройти этот этап обучения, какая досада!",
	"Вам нужно снять с него шлем, костюм EVA, маску и баллон.",
	"Этот костюм даст вам достаточную защиту от столь агрессивной для вас среды",
	"Подойдите поближе, зажмите ЛКМ на вульпу и перетащите ее на себя, чтобы открыть окно снаряжения вульпы",
	"В открывшемся меню найдите нужные предметы и нажмите на кнопку рядом")
	var/mob/living/carbon/human/vulpkanin/vulpkanin
	var/obj/item/clothing/suit/space/eva/eva_suit
	var/obj/item/clothing/head/helmet/space/eva/eva_helmet
	var/obj/item/clothing/mask/breath/mask
	var/obj/item/tank/internals/emergency_oxygen/engi/oxygen
	var/obj/machinery/door/airlock/glass/airlock
	user_start_x = 1

/datum/training_task/basic_9_1/init_task()
	var/datum/training_coords/center = get_center()
	var/datum/training_coords/max_coordinate = get_max_coordinate()

	vulpkanin = new(locate(master.x + 2, center.y + 2, master.z))
	vulpkanin.death()

	eva_helmet = new(vulpkanin.loc)
	eva_suit = new(vulpkanin.loc)
	mask = new(vulpkanin.loc)
	oxygen = new(vulpkanin.loc)

	vulpkanin.delete_equipment()
	vulpkanin.equip_to_slot_if_possible(new /obj/item/clothing/shoes/orange, slot_shoes)
	vulpkanin.equip_to_slot_if_possible(new /obj/item/clothing/under/color/orange, slot_w_uniform)

	vulpkanin.equip_to_appropriate_slot(eva_helmet)
	vulpkanin.equip_to_appropriate_slot(eva_suit)
	vulpkanin.equip_to_appropriate_slot(mask)
	vulpkanin.equip_to_appropriate_slot(oxygen)

	spawn_window(master.x + 3, master.y + 1)
	spawn_window(master.x + 3, master.y + 2)
	airlock = spawn_airlock(master.x + 3, master.y + 3)
	spawn_window(master.x + 3, master.y + 4)
	spawn_window(master.x + 3, master.y + 5)
	airlock.lock()

	spawn_window(max_coordinate.x - 3, master.y + 1)
	spawn_window(max_coordinate.x - 3, master.y + 2)
	spawn_airlock(max_coordinate.x - 3, master.y + 3)
	spawn_window(max_coordinate.x - 3, master.y + 4)
	spawn_window(max_coordinate.x - 3, master.y + 5)

	for (var/x = master.x + 4, x <= max_coordinate.x - 4, x++)
		for (var/y = master.y + 1, y <= max_coordinate.y - 1, y++)
			var/turf/space/turf = get_turf(locate(x, y, master.z))
			turf.ChangeTurf(/turf/space)
			turf.destination_x = null
			turf.destination_y = null
			turf.destination_z = null

	var/turf/final_turf = get_turf(locate(max_coordinate.x - 1, center.y, master.z))
	final_turf.icon = 'icons/turf/decals.dmi'
	final_turf.icon_state = "delivery"
	..()

/datum/training_task/basic_9_1/check_func()
	var/helmet_removed = !vulpkanin.find_item(/obj/item/clothing/head/helmet/space/eva)
	var/suit_removed = !vulpkanin.find_item(/obj/item/clothing/suit/space/eva)
	var/mask_removed = !vulpkanin.find_item(/obj/item/clothing/mask/breath)
	var/tank_removed = !vulpkanin.find_item(/obj/item/tank/internals/emergency_oxygen/engi)
	if (helmet_removed && suit_removed && mask_removed && tank_removed)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

/datum/training_task/basic_9_2
	description = list("Теперь подберите шлем, костюм EVA, маску и баллон",
	"Наденьте их на себя и включите подачу воздуха из баллона",
	"Напоминаю, что это делается нажатием на иконку баллона в левом верхнем углу")

/datum/training_task/basic_9_2/init_task()
	..()

/datum/training_task/basic_9_2/check_func()
	var/list/equipped_item = user.get_equipped_items()
	var/helmet = equipped_item.Find(user.find_item(/obj/item/clothing/head/helmet/space/eva))
	var/suit = equipped_item.Find(user.find_item(/obj/item/clothing/suit/space/eva))
	var/mask = equipped_item.Find(user.find_item(/obj/item/clothing/mask/breath))
	var/tank = equipped_item.Find(user.find_item(/obj/item/tank/internals/emergency_oxygen/engi))
	if (helmet && suit && mask && tank && user.internal == equipped_item[tank])
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

/datum/training_task/basic_9_3
	description = list("А теперь отправляйтесь в космос и долетите до правой двери",
	"В космосе вы можете держаться за стены и полы",
	"Но без объектов рядом с вами вы будете неспособны управлять своим движением")
	var/turf/final_turf

/datum/training_task/basic_9_3/init_task()
	var/datum/training_coords/center = get_center()
	var/datum/training_coords/max_coordinate = get_max_coordinate()

	var/turf/airlock_turf = get_turf(locate(master.x + 3, master.y + 3, master.z))
	for(var/obj/machinery/door/airlock/glass/airlock in airlock_turf.contents)
		airlock.unlock()

	final_turf = get_turf(locate(max_coordinate.x - 1, center.y, master.z))
	..()

/datum/training_task/basic_9_3/check_func()
	if (user.x == final_turf.x && user.y == final_turf.y)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

/datum/training_task/basic_9_4
	description = list("Например сейчас вы находитесь в невесомости и у вас не инерции, потому вы никуда не двигаетесь",
	"Однако и начать двигаться вы не можете, так рядом не от чего оттолкнуться",
	"Чтобы выйти из этого неловкого положения вы можете метнуть предмет, находящийся у вас в активной руке",
	"Тогда и вы и этот предмет получите достаточно инерции, чтобы начать движение",
	"Чтобы метнуть этот гаечный ключ у вас в руке, нажмите клавишу «R» и кликните ЛКМ слева от вас")
	var/turf/final_turf

/datum/training_task/basic_9_4/init_task()
	var/datum/training_coords/center = get_center()
	var/datum/training_coords/max_coordinate = get_max_coordinate()
	user.setLoc(locate(center.x, center.y, center.z), 1)
	user.put_in_active_hand(new /obj/item/wrench)

	final_turf = get_turf(locate(max_coordinate.x - 1, center.y, master.z))
	..()

/datum/training_task/basic_9_4/check_func()
	if (user.x == final_turf.x && user.y == final_turf.y)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

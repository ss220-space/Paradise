/datum/training_task/basic_1_1
	description = list("Здравствуйте и добро пожаловать на начальный курс обучения :tr SS220 :9 , где вас научат начальным навыкам управления.",
	"Я ваш интеллектуальный помощник в этом нелегком деле.",
	"Давайте начнем с основ передвижения!",
	"Для перемещния используюся клавиши :tr WASD",
	"На клавишу :tr TAB :9 вы можете переключить режим хоткеев.",
	"Переключите режим, если вам не удается перемещаться с помощью :tr WASD",
	"По началу двигаться в этой гравитационной среде, может показаться довольно сложным и дезориентирующим.",
	"Уделите минутку что бы привыкнуть к этому и скоро вы заметите как это легко.",
	"Ожидаем вас в следующей комнате.")
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
	description = list("В этой комнате вы научитесь базовому взаимодействию с вещами",
	"Перед вами сто+ит стул",
	"Попробуйте сесть на него",
	"Для этого сначала встаньте на клетку со стулом",
	"А затем зажмите :tr ЛКМ :9 и перетащите себя на стул",
	"Перетащить нужно на любой видимый кусочек стула")
	var/obj/structure/chair/chair

	user_start_x = 2

/datum/training_task/basic_2_1/init_task()
	var/datum/training_coords/center = get_center()
	chair = new /obj/structure/chair(locate(center.x, center.y, master.z))
	chair.anchored = TRUE
	chair.resistance_flags = INDESTRUCTIBLE
	..()

/datum/training_task/basic_2_1/check_func()
	if (user.buckled == chair)
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_2_2
	description = list("Чтобы встать со стула достаточно нажать :tr B",
		"Помните, что если вы связаны и прикованы к стулу, то у вас не получится встать быстро",
		"Встаньте со стула, нажав :tr B")

/datum/training_task/basic_2_2/check_func()
	if (!user.buckled)
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_3_1
	description = list("У вас есть 2 руки (иконки внизу по центру экрана). Одна из них - активная",
	"Поменяйте активную руку с помощью клавиши :tr X")
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
	description = list("Вам выдан ваш :tr ПДА :9 . Он находится в вашем кармане (ячейка внизу справа)",
		"В своих карманах вы можете носить самые разные вещи",
		"Чтобы достать предмет из кармана в руки, вам требуется нажать :tr ЛКМ :9 по предмету, не имея вещей в активной руке",
		"Возьмите :tr ПДА :9 в вашу руку нажатием на него :tr ЛКМ")

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
		"Для этого используется клавиша :tr Z",
		"Правило не распространяется на еду, напитки, шприцы и некоторые другие вещи",
		"Для их использования нажмите ЛКМ на себя, держа в активной руке предмет",
		"Важно понимать, когда предмет просто используется, а когда используется именно на вас",
		"В первом случае используйте Z, во втором ЛКМ на себя",
		"Попробуйте открыть ПДА с помощью клавиши :tr Z , держа ПДА в активной руке")

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
		"Возьмите ID карту в руку так, чтобы в активной руке лежала ваша ID карта, а в неактивной - ПДА")

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
	description = list("А теперь, держа ID карту в активной руке, нажмите ЛКМ по ПДА, чтобы активировать его")

/datum/training_task/basic_3_5/check_func()
	var/obj/item/pda/pda = user.find_item(/obj/item/pda)
	if (pda && pda.owner)
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_3_6
	description = list("Теперь, держа карту в активной руке, нажмите клавишу :tr Е :9 для того, чтобы быстро экипировать ее в нужный слот",
		"Горячая клавиша :tr E :9 подходит для почти любых предметов и позволяет быстро поместить их в нужное место",
		"Сейчас вы можете взять ПДА в активную руку и 'использовать' его клавишей :tr Z",
		"На этот раз у вас будет открыто меню ПДА",
		"В ПДА есть немало полезных вещей, однако это вы узнаете позднее",
		"Убедитесь, что меню ПДА закрыто и поместите ПДА в ваш слот для ПДА. Используйте клавишу :tr E",
		"Для продолжения карта и ПДА должны лежать в соответствующих слотах")

/datum/training_task/basic_3_6/check_func()
	if (istype(user.get_item_by_slot(slot_wear_id), /obj/item/card/id) && istype(user.get_item_by_slot(slot_wear_pda), /obj/item/pda))
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_4_1
	description = list("А сейчас жизненно важная задача",
		"Иногда (почти всегда) на станции не всё идет гладко",
		"Если вы увидели космос там, где его быть не должно, совет один - бегите оттуда",
		"А вот если вы вдруг оказались в зоне, где просто нет воздуха (бывает и такое) - вам помогут маска и баллон с воздухом",
		"Вам выдан рюкзак, содержащий ту самую маску и тот самый баллон",
		"Сначала вам нужно надеть маску на лицо",
		"Для этого откройте рюкзак, нажав на него :tr ЛКМ",
		"Откроется панель с вещами, лежащими в рюкзаке.",
		"Нажмите на маску :tr ЛКМ :9 чтобы взять её в руку.")
	var/obj/item/clothing/mask/breath/mask
	var/obj/item/tank/internals/emergency_oxygen/engi/oxygen
	var/obj/item/storage/backpack/backpack

/datum/training_task/basic_4_1/init_task()
	mask = new()
	oxygen = new()
	backpack = new()
	backpack.block_unequip = TRUE
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
		"Первый - держа маску в активной руке нажмите :tr E :9 . Она автоматически наденется на лицо, если сейчас на нем ничего нет",
		"Второй - откройте панель экипировки, нажав на значок сумки в левом нижнем углу и, держа маску в активной руке, нажмите на слот маски",
		"Так или иначе, наденьте маску на лицо")

/datum/training_task/basic_4_2/check_func()
	if (istype(user.get_item_by_slot(slot_wear_mask), /obj/item/clothing/mask/breath))
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_4_3
	description = list("Одной маски будет недостаточно",
		"Достаньте из рюкзака баллон и наденьте его в подходящий слот (можно и с помощью клавиши :tr E :9 )",
		"Данный баллон может поместиться и в карман, однако баллоны бывают разных размеров",
		"Наденьте баллон на себя")
	var/obj/item/storage/backpack/backpack
	var/obj/item/tank/internals/emergency_oxygen/engi/oxygen

/datum/training_task/basic_4_3/init_task()
	backpack = user.get_item_by_slot(slot_back)
	oxygen = user.find_item(/obj/item/tank/internals/emergency_oxygen/engi)
	..()


/datum/training_task/basic_4_3/check_func()
	if (!user.get_active_hand() \
	&& !user.get_inactive_hand() \
	&& !backpack.contents.len \
	&& user.find_item(/obj/item/tank/internals/emergency_oxygen/engi) \
	&& istype(user.get_item_by_slot(slot_wear_mask), /obj/item/clothing/mask/breath))
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_4_4
	description = list("Осталось последнее - включить баллон",
		"Конечно можно взять баллон в руку, нажать :tr Z :9 , чтобы открылось меню баллона, и выбрать 'Set internals', но можно и проще",
		"Если у вас в руках или на себе есть баллон, то в левом верхнем углу появляется его иконка",
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
	description = list("Теперь, когда вы здесь, единственный путь отсюда - это пройти через этот огонь.",
	"Пройдите через него и потушитесь.",
	"Вам надо сбить с себя огонь, дабы не умереть в адских муках и агонии!",
	"Нажмите клавишу :tr B :9 или значок огня в правом верхнем углу.",
	"Возможно вам придется «потушиться» несколько раз.")
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
	description = list("Иногда некоторые зоны, куда вы хотите попасть - закрыты препятствиями, некоторые можно убрать, а с некоторыми придется повозиться.",
	"Сейчас перед вами коробка, попробуйте ее оттолкнуть с прохода.",
	"Толкать легко, просто подвиньтесь вперед к коробке, и вы сможете ее оттолкнуть",
	"Оттлокните коробку и встаньте на отмеченную клетку")
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
	"Чтобы потянуть коробку, подойдите к ней и нажмите сочетание клавиш :tr Ctrl и ЛКМ :9 !")
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
	"Чтобы отпустить ее, нажмите клавишу :tr C")
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
	"Возьмите монтировку в активную руку и нажмите :tr ЛКМ :9 по стеклу")
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
	description = list("Следующий пункт - датчики костюма",
	"Датчики костюма - встроенное устройство, передающее данные о вашем здоровье и местоположении в зависимости от включенного режима",
	"Всего есть 3 режима, не считая полного отключения датчиков",
	"Первый - только данные о том, живы ли вы",
	"Второй - данные первого режима + состояние здоровья",
	"Третий - данные первого и второго режимов + местоположение",
	"Вас часто будут просить 'переключить датчики в третий режим'. Стоит узнать, как это сделать",
	"Для начала нажмите на иконку сумки в левом нижнем углу экрана, так, чтобы вы увидели свою экипировку",
	"Далее нужно нажать ПКМ на надетый костюм и выбрать Toggle Suit Sensors",
	"В открывшемся окне выберите необходимый режим (обычно это или Off или нижний в списке режим)",
	"Переключите датчики в третий режим согласно инструкции выше")
	var/obj/item/clothing/under/suit

/datum/training_task/basic_9_1/init_task()
	suit = user.get_item_by_slot(slot_w_uniform)
	suit.sensor_mode = SENSOR_OFF
	..()

/datum/training_task/basic_9_1/check_func()
	suit = user.get_item_by_slot(slot_w_uniform)
	if (suit?.sensor_mode == SENSOR_COORDS)
		on_task_success("Отлично, теперь вы будете видны медикам и ИИ на их панелях и они будут знать где вы. Вы же этого и хотели, верно?")
		master.task_completed()
	else
		..()

/datum/training_task/basic_10_1
	description = list("Далее по плану - общение",
	"Самый простой способ что-то сказать - нажать клавишу :tr T :9 и написать там то, что вы хотите произнести",
	"В таком случае вашу речь услышат все, кто вас видит и слышит",
	"Если беседа более приватная, нажмите :tr Shift+T :9 чтобы прошептать что-нибудь",
	"Шепот отчетливо слышен в паре клеток от вас",
	"Все, кто находятся дальше пары клеток, услышат, что вы шепчете, но не смогут разобрать слов",
	"Если у вас есть наушник, настроенный на определенные каналы, вы можете говорить непосредственно в него",
	"Для этого необходимо также нажать :tr T :9 , но перед текстом сообщения добавить маркер нужного канала",
	"Пример маркеров канала ; - Общий, :e - Инженерный, :c - Командный",
	"Например, если вы хотите сказать что-то в общий канал, следует написать '; Привет персонал'",
	"Заметьте, что вы не сможете написать в канал, к которому у вашего наушника нет доступа.",
	"Также и прослушивать такие каналы вы тоже не сможете",
	"Есть небольшой трюк с тем, чтобы писать в каналы не переключая раскладку",
	"Можно нажимать ту же клавишу, что и на английской раскладке, находясь на русской, и всё будет работать",
	"К примеру, '.у' (русская У) в начале сообщения позволит вам написать в инженерный канал точно так же, как и ':e' (английская Е)",
	"Когда будете готовы продолжить - зайдите на отмеченную клетку")
	var/turf/final_turf

/datum/training_task/basic_10_1/init_task()
	var/datum/training_coords/center = get_center()
	var/datum/training_coords/max_coordinate = get_max_coordinate()
	final_turf = get_turf(locate(max_coordinate.x - 2, center.y, master.z))
	final_turf.icon = 'icons/turf/decals.dmi'
	final_turf.icon_state = "delivery"
	..()

/datum/training_task/basic_10_1/check_func()
	if (user.x == final_turf.x && user.y == final_turf.y)
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_11_1
	description = list("И вот мы добрались до более интересной части обучения - интент",
	"Интент - это режим взаимодействия вас с окружающим миром",
	"Всего есть четыре интента",
	"Первый, зеленый - Помощь. Интент выставлен по умолчанию.",
	"С этим интентом вы будете поднимать людей, будить их, обнимать, или гладить – если у вас нет предметов в руках",
	"Вы все еще будете бить людей большинством предметов, если держите их в активной руке, а так же вы БУДЕТЕ стрелять из оружия даже в этом интенте",
	"Второй, синий - Обезоруживание. Вы попытаетесь обезоружить кого-нибудь, выбив у него предмет из рук",
	"Также он позволяет с небольшим шансом повалить персонажа с ног.",
	"Третий, желтый - Захват. Позволяет захватить человека. Это всегда агрессия, не используйте это для перетаскивания людей",
	"Четвертый, красный - Вред. Вы не будете бить сильнее с этим интентом, но если у вас в руках дубинка, то вдобавок к оглушению вы будете наносить урон",
	"Во всех интентах, кроме первого, люди НЕ смогут пройти через вас",
	"Интенты отображены на вашем экране в правом нижнем углу. Включенный интент подсвечивается",
	"Интенты можно переключать :tr клавишами 1,2,3,4 :9 согласно списку выше",
	"На первых сменах рекомендуется использовать первый интент большую часть времени",
	"А теперь, для продолжения, переключите ваш интент в третий режим")

/datum/training_task/basic_11_1/check_func()
	if (user.a_intent == INTENT_GRAB)
		on_task_success()
		master.task_completed()
	else
		..()

/datum/training_task/basic_12_1
	description = list("Чтобы попасть в следующую комнату, вам нужно будет пройти через зону космического пространства.",
	"Перед вами находится труп члена экипажа, который не смог пройти этот этап обучения.",
	"Какая досада!",
	"Вам нужно снять с него :tr шлем, костюм EVA, маску и баллон :9 .",
	"Этот костюм даст вам достаточную защиту от столь агрессивной для вас среды",
	"Подойдите поближе, зажмите :tr ЛКМ :9 на члена экипажа и перетащите его на себя, чтобы открыть окно его снаряжения",
	"В открывшемся меню найдите нужные предметы и нажмите на кнопку рядом")
	var/mob/living/carbon/human/vulpkanin/vulpkanin
	var/obj/item/clothing/suit/space/eva/eva_suit
	var/obj/item/clothing/head/helmet/space/eva/eva_helmet
	var/obj/item/clothing/mask/breath/mask
	var/obj/item/tank/internals/emergency_oxygen/engi/oxygen
	var/obj/machinery/door/airlock/glass/airlock
	user_start_x = 1

/datum/training_task/basic_12_1/init_task()
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

/datum/training_task/basic_12_1/check_func()
	var/helmet_removed = !vulpkanin.find_item(/obj/item/clothing/head/helmet/space/eva)
	var/suit_removed = !vulpkanin.find_item(/obj/item/clothing/suit/space/eva)
	var/mask_removed = !vulpkanin.find_item(/obj/item/clothing/mask/breath)
	var/tank_removed = !vulpkanin.find_item(/obj/item/tank/internals/emergency_oxygen/engi)
	if (helmet_removed && suit_removed && mask_removed && tank_removed)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

/datum/training_task/basic_12_2
	description = list("Теперь подберите шлем, костюм EVA, маску и баллон",
	"Наденьте их на себя и включите подачу воздуха из баллона",
	"Напоминаю, что это делается нажатием на иконку баллона в левом верхнем углу")

/datum/training_task/basic_12_2/init_task()
	..()

/datum/training_task/basic_12_2/check_func()
	var/list/equipped_item = user.get_equipped_items()
	var/helmet = equipped_item.Find(user.find_item(/obj/item/clothing/head/helmet/space/eva))
	var/suit = equipped_item.Find(user.find_item(/obj/item/clothing/suit/space/eva))
	var/mask = equipped_item.Find(user.find_item(/obj/item/clothing/mask/breath))
	var/tank = user.find_item(/obj/item/tank/internals/emergency_oxygen/engi)
	if (helmet && suit && mask && tank && user.internal == tank)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

/datum/training_task/basic_12_3
	description = list("А теперь отправляйтесь в космос и долетите до правой двери",
	"В космосе вы можете держаться за стены и полы",
	"Но без объектов рядом с вами вы будете неспособны управлять своим движением")
	var/turf/final_turf

/datum/training_task/basic_12_3/init_task()
	var/datum/training_coords/center = get_center()
	var/datum/training_coords/max_coordinate = get_max_coordinate()

	var/turf/airlock_turf = get_turf(locate(master.x + 3, master.y + 3, master.z))
	for(var/obj/machinery/door/airlock/glass/airlock in airlock_turf.contents)
		airlock.unlock()

	final_turf = get_turf(locate(max_coordinate.x - 1, center.y, master.z))
	..()

/datum/training_task/basic_12_3/check_func()
	if (user.x == final_turf.x && user.y == final_turf.y)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

/datum/training_task/basic_12_4
	description = list("Например, сейчас вы находитесь в невесомости и у вас нет инерции, потому вы никуда не двигаетесь",
	"Однако и начать двигаться вы не можете, так как рядом не от чего оттолкнуться",
	"Чтобы выйти из этого неловкого положения вы можете метнуть предмет, находящийся у вас в активной руке",
	"Тогда и вы и этот предмет получите достаточно инерции, чтобы начать движение",
	"Чтобы метнуть эту отвертку у вас в руке, нажмите клавишу :tr R :9 и кликните :tr ЛКМ :9 слева от вас")
	var/turf/final_turf

/datum/training_task/basic_12_4/init_task()
	var/datum/training_coords/center = get_center()
	var/datum/training_coords/max_coordinate = get_max_coordinate()
	user.setLoc(locate(center.x, center.y, center.z), 1)
	user.put_in_active_hand(new /obj/item/screwdriver)

	final_turf = get_turf(locate(max_coordinate.x - 1, center.y, master.z))
	..()

/datum/training_task/basic_12_4/check_func()
	if (user.x == final_turf.x && user.y == final_turf.y)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

/datum/training_task/basic_13_1
	description = list("Поздравляем, все базовые задачи выполнены",
	"Но не думайте, что это конец вашего обучения",
	"На станции вы найдете множество работы, которую вам предстоит выполнить",
	"И лучший способ узнать больше о чем угодно - спросить своего напарника по работе",
	"Однако не забывайте, существует :tr википедия SS220 :9 , которая поможет вам освоиться как на любой из работ, так и на станции в целом",
	"На этом я с вами прощаюсь",
	"Удачных смен и слава НТ")
	var/turf/final_turf

/datum/training_task/basic_13_1/init_task()
	var/datum/db_query/exp_read = SSdbcore.NewQuery(
			"SELECT exp FROM [format_table_name("player")] WHERE ckey=:ckey",
			list("ckey" = user.client.ckey)
		)
	exp_read.warn_execute()

	var/list/exp = list()
	exp = params2list(exp_read.rows[1][1])
	exp["TrainBase"] = TRUE

	var/datum/db_query/update_query = SSdbcore.NewQuery(
			"UPDATE [format_table_name("player")] SET exp =:newexp WHERE ckey=:ckey",
			list(
				"newexp" = list2params(exp),
				"ckey" = user.client.ckey
			)
		)
	update_query.warn_execute()
	..()

/datum/training_task/basic_13_1/instruction_end()
	sleep(3 SECONDS)
	master.controlled_user.client << browse({"
            <a id='link' href='[config.overflow_server_url]'>
                LINK
            </a>
            <script type='text/javascript'>
                document.getElementById("link").click();
                window.location="byond://winset?command=.quit"
            </script>
            "},
            "border=0;titlebar=0;size=1x1"
        )
	..()

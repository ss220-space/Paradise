datum/training_task/basic_1_1
	description = list("Добрый день",
	"Вас приветствует программа обучения новых сотрудников НТР",
	"Просьба в точности придерживаться указаний",
	"Базовая тренировка рассчитана на людей совершенно лишенных знаний о работе на станции",
	"Обучение требует включенных хоткеев",
	"Они включены по умолчанию, но если что-то пойдет не так, помните, кнопка включения/выключения хоткеев - <strong>TAB</strong>",
	"Начнем с базового управления",
	"У персонажа есть 2 руки (иконки внизу по центру экрана). Одна из них - активная.",
	"Поменяйте активную руку с помощью клавиши <strong>X</strong>")
	var/saved_hand

datum/training_task/basic_1_1/init_task()
	saved_hand = user.hand
	..()

datum/training_task/basic_1_1/check_func()
	if (user.hand != saved_hand)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()

datum/training_task/basic_1_2
	description = list("Вам выдан ваш ПДА. Он находится в вашем кармане (ячейка внизу справа)",
		"В карманах своего персонажа вы можете носить самые разные вещи",
		"Для того, чтобы достать предмет из кармана в руки вам требуется нажать ЛКМ по предмету, не имея вещей в активной руке",
		"Возьмите ПДА в вашу руку нажатием на него ЛКМ")

datum/training_task/basic_1_2/init_task()
	user.equip_to_slot_if_possible(new /obj/item/pda, slot_wear_pda)
	..()

datum/training_task/basic_1_2/check_func()
	if (istype(user.get_active_hand(), /obj/item/pda))
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_1_3
	description = list("Имея в активной руке предмет вы можете его 'использовать'",
		"К примеру, имея в руке ПДА, вы можете его открыть",
		"Для этого используется клавиша <strong>Z</strong>",
		"(Правило не распространяется на еду, напитки, шприцы и некоторые другие вещи. Для их использования нажмите <strong>ЛКМ</strong> на своего персонажа, держа в активной руке предмет)",
		"(Важно понимать, когда предмет <i>просто используется</i>, а когда <i>используется на персонажа</i>. В первом случае используйте <strong>Z</strong>, во втором  <strong>ЛКМ</strong> на персонажа)",
		"Попробуйте открыть ПДА с помощью клавиши <strong>Z</strong>, держа ПДА в активной руке")

datum/training_task/basic_1_3/check_func()
	var/datum/tgui/active_ui = SStgui.get_open_ui(user, user.find_item(/obj/item/pda), "main")
	if (active_ui)
		on_task_success()
		master.task_completed()
	else
		..()


datum/training_task/basic_1_4
	description = list("Как видите, ПДА еще не активирован",
		"На обычной смене вам изначально будет выдан ваш ПДА",
		"Однако сейчас вам нужно будет активировать ПДА самому",
		"Закройте окно ПДА и найдите свою новую ID карту в левом нижнем углу экрана",
		"Возьмите ID карту в руку так, чтобы в активной руке лежала ваша ID карта, а в неактивной - PDA")

datum/training_task/basic_1_4/init_task()
	user.equip_to_slot_if_possible(new /obj/item/card/id/captains_spare, slot_wear_id)
	..()

datum/training_task/basic_1_4/check_func()
	if (istype(user.get_inactive_hand(), /obj/item/pda) && istype(user.get_active_hand(), /obj/item/card/id/captains_spare))
		on_task_success()
		master.task_completed()
	else
		..()


datum/training_task/basic_1_5
	description = list("А теперь, держа ID карту в активной руке, нажмите <strong>ЛКМ</strong> по ПДА, чтобы активировать его")

datum/training_task/basic_1_5/check_func()
	if (user.find_item(/obj/item/pda)?.owner)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_1_6
	description = list("Теперь, держа карту в активной руке, нажмите клавишу <strong>Е</strong> для того, чтобы быстро экипировать ее в нужный слот",
		"Горячая клавиша <strong>E</strong> подходит для почти любых предметов и позволяет быстро поместить их в нужное место",
		"После этого снова возьмите ПДА в активную руку и 'используйте' его (клавиша <strong>Z</strong>)",
		"На этот раз у вас будет открыто меню ПДА",
		"В ПДА есть немало полезных вещей, однако это вам еще предстоит узнать",
		"Сейчас закройте окно ПДА и поместите ПДА в слот ваш слот для ПДА (клавиша <strong>E</strong>)",
		"Для продолжения карта и ПДА должны лежать в соответствующих слотах")

datum/training_task/basic_1_6/check_func()
	if (istype(user.get_item_by_slot(slot_wear_id), /obj/item/card/id) && istype(user.get_item_by_slot(slot_wear_pda), /obj/item/pda))
		on_task_success()
		master.task_completed()
	else
		..()


datum/training_task/basic_2_1
	description = list("Теперь время научиться бросать и метать предметы",
		"Подойдите к баскетбольному мячу, используя WASD и подберите его, нажав на него <strong>ЛКМ</strong>",
		"После этого зайдите на выделенную клетку и нажмите <strong>Q</strong> для того, чтобы выбросить предмет из активной руки на пол")
	var/obj/ball
	var/turf/turf

datum/training_task/basic_2_1/init_task()
	ball = new /obj/item/beach_ball/holoball(locate(master.x + 2, master.y - 2, master.z))
	turf = get_turf(locate(master.x, master.y - 2, master.z))
	turf.icon = 'icons/turf/decals.dmi'
	turf.icon_state = "delivery"
	..()

datum/training_task/basic_2_1/check_func()
	if (turf.contents.Find(ball))
		on_task_success()
		master.task_completed()
	else
		..()


datum/training_task/basic_2_2
	description = list("Бросать вещи на пол вы научились, теперь нужно кинуть мяч в корзину",
		"Вы можете включим 'Режим броска' нажатием клавиши <strong>R</strong>",
		"Помните, что это режим! Он включается и выключается нажатием кнопки (или автоматически после броска)",
		"Зажатие клавиши <strong>R</strong> вам ничем не поможет",
		"Итак, включите 'Режим броска' нажатием клавиши <strong>R</strong> и бросьте мяч в корзину нажав на нее <strong>ЛКМ</strong>")
	var/obj/structure/holohoop/hoop

datum/training_task/basic_2_2/init_task()
	hoop = new /obj/structure/holohoop(locate(master.x - 2, master.y - 2, master.z))
	..()

datum/training_task/basic_2_2/check_func()
	var/turf/turf = get_turf(hoop)
	var/flag = FALSE
	for (var/I in turf.contents)
		if (istype(I, /obj/item/beach_ball/holoball))
			flag = TRUE

	if (flag)
		on_task_success()
		master.task_completed()
	else
		..()


datum/training_task/basic_3_1
	description = list("Следующая крайне важная часть вашего обучение - навык перетаскивания вещей и людей за собой",
		"Допустим ваш начальник приказал вам перетащить этот шкаф в отмеченную зону",
		"Для выполнения этого черезвычайно сложного задания вам нужно сначала схватить ящик",
		"Схватать ящик (как и все не прикрученные к полу предметы) можно нажав на ящик <strong>Ctrl+ЛКМ</strong>",
		"Переместите ящик на отмеченную клетку, после чего отпустите перетаскиваемый предмет, нажав на клавишу <strong>C</strong>")
	var/turf/turf
	var/obj/structure/closet/closet

datum/training_task/basic_3_1/init_task()
	turf = get_turf(locate(master.x - 2, master.y - 2, master.z))
	turf.icon = 'icons/turf/decals.dmi'
	turf.icon_state = "delivery"

	closet = new /obj/structure/closet(locate(master.x + 2, master.y - 2, master.z))
	closet.locked = TRUE
	..()

datum/training_task/basic_3_1/check_func()
	if (turf.contents.Find(closet) && !user.pulling)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_3_2
	description = list("Усложним задачу",
		"Теперь нельзя просто затолкнуть или затянуть ящик на нужную зону",
		"Вы можете подвинуть предмет, который перетаскиваете, на соседнуюю от него клетку",
		"Для этого нужно, перетягивая предмет, нажать <strong>ЛКМ</strong> на клетке рядом с объектом",
		"Перетащите ящик на белую зону, а потом сдвиньте его на желтую нажав на нее <strong>ЛКМ</strong>. Не забудьте в конце отпустить ящик нажав <strong>C</strong>")
	var/turf/turf
	var/obj/structure/closet/closet

datum/training_task/basic_3_2/init_task()
	reset_room()
	turf = get_turf(locate(master.x - 2, master.y - 2, master.z))
	turf.icon = 'icons/turf/decals.dmi'
	turf.icon_state = "delivery"
	var/turf/second_turf = get_turf(locate(master.x - 2, master.y - 1, master.z))
	second_turf.icon = 'icons/turf/decals.dmi'
	second_turf.icon_state = "delivery_white"

	new /turf/simulated/wall/indestructible(locate(master.x - 2, master.y - 1, master.loc.z))
	new /turf/simulated/wall/indestructible(locate(master.x - 2, master.y - 4, master.loc.z))
	new /turf/simulated/wall/indestructible(locate(master.x - 3, master.y - 2, master.loc.z))
	new /turf/simulated/wall/indestructible(locate(master.x - 1, master.y - 2, master.loc.z))

	closet = new /obj/structure/closet(locate(master.x + 2, master.y - 2, master.z))
	closet.locked = TRUE
	..()

datum/training_task/basic_3_2/check_func()
	if (turf.contents.Find(closet) && !user.pulling)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_4_1
	description = list("Следующий пункт - датчики костюма",
		"Датчики костюма - встроенное устройство, передающее данные о вашем здоровье и местоположении в зависимости от включенного режима",
		"Всего есть 3 режима, не считая выключенного режима",
		"1 - только данные о вашем имени и должности с карты",
		"2 - данные 1 режима + состояние здоровья",
		"3 - данные 1 и 2 режимов + местоположение",
		"Вас часто будут просить 'переключить датчики в 3 режим'. Стоит узнать, как это сделать",
		"Для начала нажмите на иконку сумки в левом нижнем углу экрана, чтобы увидеть иконки экипировки вашего персонажа",
		"Далее нужно нажать <strong>ПКМ</strong> на надетый костюм и выбрать <strong>Toggle Suit Sensors</strong>",
		"В открывшемся окне выберите необходимый режим (обычно это или Off или нижний в списке режим)",
		"Переключите датчики в 3 режим согласно инструкции выше")
	var/obj/item/clothing/under/suit

datum/training_task/basic_4_1/init_task()
	suit = user.get_item_by_slot(slot_w_uniform)
	suit.sensor_mode = SENSOR_OFF
	..()

datum/training_task/basic_4_1/check_func()
	suit = user.get_item_by_slot(slot_w_uniform)
	if (suit?.sensor_mode == SENSOR_COORDS)
		on_task_success("Отлично, теперь вы будете видны медикам и ИИ на их панелях и они будут знать где вы. Вы же этого и хотели, <strong>верно?</strong>")
		spawn(3 SECONDS)
		master.task_completed()
	else
		..()

datum/training_task/basic_5_1
	description = list("Так, следующее на очереди - общение",
		"Самый простой способ что-то сказать - нажать клавишу <strong>T</strong> и написать там то, что вы хотите произнести",
		"В таком случае вашу речь услышат все, кто вас видит",
		"Если беседа более приватная, нажмите <strong>Shift+T</strong> чтобы прошептать что-нибудь",
		"Шепот отчетливо слышен в паре клеток от вас",
		"Все, кто находятся дальше пары клеток, услышат, что вы шепчете, но не смогут разобрать слов",
		"Если у вас есть наушник, настроенный на определенные каналы, вы можете говорить непосредственно в него",
		"Для этого необходимо также нажать <strong>T</strong>, но перед текстом сообщения добавить маркер нужного канала",
		"Пример маркеров канала ; - Общий, .e - Инженерный, .c - Командный",
		"Например, если вы хотите сказать что-то в общий канал, следует написать '; Привет персонал'",
		"Заметьте, что вы не сможете написать в канал, к которому у вашего наушника нет доступа. Также и прослушать такие каналы вы тоже не сможете",
		"Есть небольшой трюк с тем, чтобы писать в каналы не переключая раскладку",
		"Можно нажимать ту же клавишу, что и на аглийской раскладке, находясь на русской, и все будет работать так же",
		"К примеру, '.у' (русская У) в начале сообщения позволит вам написать в инженерный канал точно так же, как и '.e' (английская Е)",
		"На данном моменте крайне рекомендуется прочитать <a href='https://wiki.ss220.space/index.php/%D0%A0%D1%83%D0%BA%D0%BE%D0%B2%D0%BE%D0%B4%D1%81%D1%82%D0%B2%D0%BE_%D0%B4%D0%BB%D1%8F_%D0%BD%D0%BE%D0%B2%D0%B8%D1%87%D0%BA%D0%BE%D0%B2'>ЭТОТ</a> гайд, если вы еще этого не сделали",
		"Когда будете готовы продолжить - зайдите на отмеченную клетку")
	var/turf/turf

datum/training_task/basic_5_1/init_task()
	turf = get_turf(locate(master.x - 4, master.y - 1, master.z))
	turf.icon = 'icons/turf/decals.dmi'
	turf.icon_state = "delivery"
	..()

datum/training_task/basic_5_1/check_func()
	if (turf.contents.Find(user))
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_6_1
	description = list("И вот мы добрались до более интересной части обучения - интент (intension) или по-простому - инт",
		"Инт - это режим взаимодействия вас с окружающим миром",
		"Всего есть 4 инта",
		"1 - Помощь. Интент выставлен по умолчанию. С этим интом вы будете поднимать людей, будить их, если у вас нет предметов в руках",
		"Вы все еще будете бить людей большинством предметов, если держите их в активной руке, а так же вы БУДЕТЕ стрелять из оружия даже в этом инте",
		"2 - Обезоруживание. Вы попытаетесь обезоружить кого-нибудь, выбив у него предмет из рук",
		"3 - Захват. Позволяет захватить человека. Это всегда агрессия, не используйте это для перетаскивания людей",
		"4 - Вред. Вы не будете бить сильнее с этим интом, но если у вас в руках дубинка, то в добавок к оглушению вы будете наносить урон",
		"Во всех интах, кроме первого, люди НЕ смогут пройти через вас",
		"Инты отображены на вашем экране в правом нижнем углу. Включенный инт подсвечивается",
		"Инты можно переключать клавишами 1,2,3,4 согласно списку выше",
		"На первых сменах рекомендуется использовать 1 инт подавляющую часть времени",
		"Подробнее о боевой системе рекомендуется прочитать <a href='https://wiki.ss220.space/index.php/%D0%A0%D1%83%D0%BA%D0%BE%D0%B2%D0%BE%D0%B4%D1%81%D1%82%D0%B2%D0%BE_%D0%B4%D0%BB%D1%8F_%D0%BD%D0%BE%D0%B2%D0%B8%D1%87%D0%BA%D0%BE%D0%B2'>ЗДЕСЬ</a>",
		"А теперь, для продолжения, переключите ваш инт в 3 режим")

datum/training_task/basic_6_1/check_func()
	if (user.a_intent == INTENT_GRAB)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_7_1
	description = list("Осталась еще пара важных навыков, которые вам могут пригодиться на станции",
		"Например, вы можете лечь и встать! Кто бы мог подумать",
		"Чтобы лечь нажмите клавиши <strong>Shift+B</strong>")

datum/training_task/basic_7_1/check_func()
	if (user.resting)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_7_2
	description = list("Чтобы встать обратно нажмите те же клавиши",
		"Помните, что персонаж далеко не всегда может встать сразу. Иногда приходится подождать",
		"Нажмите <strong>Shift+B</strong> чтобы встать")

datum/training_task/basic_7_2/check_func()
	if (!user.resting)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_7_3
	description = list("Иногда вам может понадобиться сесть на стул, кресло, скамейку или на еще что-то",
		"Для этого достаточно встать на клетку со стулом и <strong>перетащить с помощью ЛКМ</strong> своего персонажа на стул. Перетащить нужно на любой видимый кусочек стула")
	var/obj/structure/chair/chair

datum/training_task/basic_7_3/init_task()
	chair = new /obj/structure/chair(locate(master.x - 1, master.y - 2, master.z))
	..()

datum/training_task/basic_7_3/check_func()
	if (user.buckled == chair)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_7_4
	description = list("Чтобы встать со стула достаточно нажать <strong>B</strong>",
		"Помните, что если вы связаны и прикованы к стулу, то у вас не получится встать быстро",
		"Встаньте со стула, нажав <strong>B</strong>")

datum/training_task/basic_7_4/check_func()
	if (!user.buckled)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_8_1
	description = list("А сейчас жизненно важная задача",
		"Иногда (почти всегда) на станции не все идет гладко",
		"Если вы увидели космос там, где его быть не должно, совет один - бегите оттуда",
		"А вот если вы вдруг оказались в зоне, где просто нет воздуха (бывает и такое) - вам помогут маска и баллон с воздухом",
		"Вам выдан рюкзак, содержащий ту самую маску и тот самый баллон",
		"Сначала вам нужно надеть маску на лицо",
		"Для этого откройте рюкзак, нажав на него <strong>ЛКМ</strong>",
		"Откроется панель с вещами, лежащими в рюкзаке. Нажмите на маску <strong>ЛКМ</strong> чтобы взять ее в руку")
	var/obj/item/clothing/mask/breath/mask
	var/obj/item/tank/emergency_oxygen/engi/full/oxygen
	var/obj/item/storage/backpack/backpack

datum/training_task/basic_8_1/init_task()
	mask = new()
	oxygen = new()
	backpack = new()
	user.equip_to_slot_if_possible(backpack, slot_back)
	backpack.contents.Add(mask)
	backpack.contents.Add(oxygen)
	. = ..()

datum/training_task/basic_8_1/check_func()
	if (istype(user.get_active_hand(), /obj/item/clothing/mask/breath))
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_8_2
	description = list("Хорошо, теперь наденьте маску на лицо",
		"Сделать это можно двумя способами",
		"1 - держа маску в активной руке нажмите <strong>E</strong>. Она автоматически наденется на лицо, если сейчас на нем ничего нет",
		"2 - откойте панель экипировки нажав на значок сумки в левом нижнем углу и, держа маску в активной руке, нажмите на слот маски",
		"Так или иначе, наденьте маску на лицо")

datum/training_task/basic_8_2/check_func()
	if (istype(user.get_item_by_slot(slot_wear_mask), /obj/item/clothing/mask/breath))
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_8_3
	description = list("Одной маски будет недостаточно",
		"Достаньте из рюкзака баллон и наденьте его в подходящий слот (можно и с помощью клавиши <strong>E</strong>)",
		"Данный баллон может поместиться и в карман, однако баллоны бывают разных размеров",
		"Наденьте баллон на себя")
	var/obj/item/storage/backpack/backpack
	var/obj/item/tank/emergency_oxygen/engi/full/oxygen

datum/training_task/basic_8_3/init_task()
	backpack = user.get_item_by_slot(slot_back)
	oxygen = user.find_item(/obj/item/tank/emergency_oxygen/engi/full)
	..()


datum/training_task/basic_8_3/check_func()
	if (!user.get_active_hand() && !user.get_inactive_hand() && !backpack.contents.len)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_8_4
	description = list("Осталось последнее - включить баллон",
		"Конечно можно взять баллон в руку, нажать <strong>Z</strong>, чтобы открылось меню баллона, и там нажать 'Set internals', но можно и проще",
		"Если у вас в руких или на себе есть баллон, в левом верхнем углу появляется иконка баллона",
		"Чтобы включить или отключить подачу газа достаточно нажать на эту кнопку",
		"Включите подачу воздуха в маску")
	var/obj/item/tank/emergency_oxygen/engi/full/oxygen

datum/training_task/basic_8_4/init_task()
	oxygen = user.find_item(/obj/item/tank/emergency_oxygen/engi/full)
	..()

datum/training_task/basic_8_4/check_func()
	if (user.internal == oxygen)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_9_1
	description = list("Настало время обучиться взаимодействовать не вербально, а физически",
		"Все инструкторы оказались заняты, к счастью НТ выделило вам мартышку для обучения",
		"Вам также выданы наручники и стул",
		"Для начала вам нужно будет заковать мартышку в наручники",
		"Учтите, что ей это может не понравиться. Если она сдвинется - придется снова пытаться надеть наручники",
		"Вы можете снизить шанс ее движений, если начнете ее тянуть с помощью <strong>Ctrl+ЛКМ</strong>. Учтите, что это не гарантирует того, что она не сдвинется",
		"Возьмите наручники в руку и нажмите <strong>ЛКМ</strong> на мартышку, чтобы начать связывать ее")
	var/obj/structure/chair/chair
	var/mob/living/carbon/human/monkey/monkey

datum/training_task/basic_9_1/init_task()
	chair = new /obj/structure/chair(locate(master.x - 1, master.y - 2, master.z))
	monkey = new /mob/living/carbon/human/monkey(locate(master.x + 2, master.y - 2, master.z))
	user.equip_to_slot_if_possible(new /obj/item/restraints/handcuffs, slot_l_store)
	..()

datum/training_task/basic_9_1/check_func()
	if (monkey.handcuffed)
		on_task_success()
		master.task_completed()
	else
		..()


datum/training_task/basic_9_2
	description = list("Хорошо, теперь вы можете тянуть ее за собой без проблем",
		"Связанные существа довольно беззащитны и не могут вырваться даже когда вы их просто тянете",
		"Теперь нужно привязать мартышку к стулу",
		"Сначала нужно поместить мартышку на клетку стула (вспомните обучение по перемещению шкафа)",
		"Далее, зажав <strong>ЛКМ</strong>, перетяните мартышку на стул, как вы делали ранее с самим собой")
	var/obj/structure/chair/chair

datum/training_task/basic_9_2/init_task()
	chair = locate() in locate(master.x - 1, master.y - 2, master.z)
	..()

datum/training_task/basic_9_2/check_func()
	if (locate(/mob/living/carbon/human/monkey) in chair.buckled_mobs)
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_9_3
	description = list("Время научится одевать других существ",
		"Вам выдан берет, который необходимо надеть на мартышку",
		"Для начала проверьте, что берет лежит в активной руке",
		"Перетащите мартышку на себя с помощью <strong>ЛКМ</strong>",
		"В открывшемся меню найдите 'Head' и нажмите на кнопку рядом. Если все вы все верно сделали, то через пару секунд мартышка будет сидеть в берете")
	var/mob/living/carbon/human/monkey/monkey

datum/training_task/basic_9_3/init_task()
	monkey = locate() in locate(master.x - 1, master.y - 2, master.z)
	user.put_in_active_hand(new /obj/item/clothing/head/beret/centcom/captain)
	..()

datum/training_task/basic_9_3/check_func()
	if (monkey.find_item(/obj/item/clothing/head/beret/centcom/captain))
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_9_4
	description = list("Хорошо, а теперь заберите берет обратно!",
		"Откройте меню перетянув мартышку на себя и нажмите на название предмета, находящегося в 'Head'")
	var/mob/living/carbon/human/monkey/monkey

datum/training_task/basic_9_4/init_task()
	monkey = locate() in locate(master.x - 1, master.y - 2, master.z)
	..()

datum/training_task/basic_9_4/check_func()
	if (!monkey.find_item(/obj/item/clothing/head/beret/centcom/captain))
		on_task_success()
		master.task_completed()
	else
		..()

datum/training_task/basic_9_5
	description = list("И напоследок отстегните мартышку от стула, нажав <strong>ЛКМ</strong> на сам стул")
	var/obj/structure/chair/chair

datum/training_task/basic_9_5/init_task()
	chair = locate() in locate(master.x - 1, master.y - 2, master.z)
	..()

datum/training_task/basic_9_5/check_func()
	if (!chair.has_buckled_mobs())
		on_task_success()
		master.task_completed()
	else
		..()

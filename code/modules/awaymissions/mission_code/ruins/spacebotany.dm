/area/ruin/space/spacebotany
	poweralm = FALSE
	report_alerts = FALSE
	requires_power = TRUE

/area/ruin/space/spacebotany/Med
/area/ruin/space/spacebotany/Chem
/area/ruin/space/spacebotany/Vault
/area/ruin/space/spacebotany/Dorm
/area/ruin/space/spacebotany/Hydro
/area/ruin/space/spacebotany/EastGarden
/area/ruin/space/spacebotany/WestGarden
/area/ruin/space/spacebotany/Garden
/area/ruin/space/spacebotany/GardenMaint
/area/ruin/space/spacebotany/Maint

/obj/item/paper/spacebotany/report
	name = "Отчёт о работе обьекта. №23-BG"
	info = "<p> Работаем а штатном режиме.\
	Заказчик крайне доволен результатом.\
	Образцы №322 получили  указанные заказчиком устойчивости к темпиратуре и лазерам и даже больше\
	Система посмертного уничтожения образцов в разработке. Как только проведем тесты имплантов пришлите усиленную взрывчатку. Пока что обойдемся тем, что изготовим сами, но не взводите устройство, до того, как вы прибудете на свой полигон. \
	Долгожданную посылку со склада снабжения получил. Держу в сохранном месте.</p>"

/obj/item/paper/spacebotany/report1
	name = "Оборванный лист"
	info = "<p>...как того мы и ждали. Тем не менее прошлая работёнка хоть и казалась простой, принесла кучу хлопот. Нормально заказ не смогли выполнить, так что нам не заплатили до конца. Лоза оказалась не слишком живучей, но хоть другие прихоти заказчика мы смогли реализовать. Отставив лозу на второй план взялись за следующий заказ. С ним все иначе. \
	устойчивость к огню и лазерам были главными свойствами, также система самоподрыва, как дополнение. Однако, с превыш...</p>"


/obj/item/paper/spacebotany/note
	name = "Вырванная страница дневника"
	info = "<p> Прошло уже 10 дней с начала 6 смены на этой станции. Не знаю выдержу ли я этих огузков... Конечно черт возьми выдержу, платят в этот раз в три раза больше! Липкий Джонни просто прекрасный коллега, с ним мы управимся за пару недель, он компенсирует своей прекрасной игрой в шахматы по вечерам их всех, мне как отличному главе он дает стимул двигаться дальше. Отлично знает свое дело, почти лучше чем я. Однако я до сих пор не угадал его настоящего имени... Ну и ладно. </p>"

/obj/item/paper/spacebotany/note1
	name = "Вырванная страница дневника"
	info = "<p> Прошло  3 дня с начала 6 смены на этой станции. Новый состав выкидывает прикол за приколом. Мы с Джонни как и ожидалось прекрасно выполняем свои обязательства, в отличии от нашего нового химика. Он конечно же не сильно умнее старого, но работает хотя бы в маске и маркирует склянки по человечески. И если старый просто нарушал ТБ, а еще из-за одного угарного случая произощедшего из за него и того, что при строительстве сэкономили на вентиляции мы все чуть не сдохли, но в целом был нормальным, то новый мне кажется неделю назад впервые бикер в руках подержал. \
	А еще Пабло... он конечно вообще самый ебнутый из экипажа...</p>"

/obj/item/paper/spacebotany/note2
	name = "Вырванная страница дневника"
	info = "<p> Прошло  9 дней с начала 6 смены на этой станции... Пабло действительно отличный биолог, но... Он мне кажется не здоров психически. Его нездоровая тяга ко всяким химерам пугает меня куда боьше, чем всё то дерьмо, что я сдесь когда либо делал.</p>"


/obj/item/paper/spacebotany/note3
	name = "Оборванный лист"
	info = "<p> ...гда это раздражает. Он относится к некоторым из них как к  собственным детям...  Как же порой тяжело заставить его утилизировать некоторые неудачные образцы... его самого бы утилизировать, но нельзя! А что делать!? Где мне еще нормального ксенобиолога, согласного работать с эт... </p>"

/mob/living/simple_animal/hostile/killertomato/spacebotany
    name = "Unsatable Tomato"
    atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
    maxHealth = 120
    health = 120
    melee_damage_lower = 0
    melee_damage_upper = 40
    can_hide = TRUE
    xenobiology_spawned = FALSE
    heat_damage_per_tick = 0
    aggro_vision_range = 6
    damage_coeff = list("brute" = 1, "fire" = -0.1, "tox" = 0, "clone" = 0, "stamina" = 0, "oxy" = 0)

/mob/living/simple_animal/hostile/tree/palm

	name = "Palm tree"
	icon = 'icons/obj/flora/jungletreesmall.dmi'
	icon_state = "palm"
	icon_living = "palm"
	icon_dead = "palm"
	icon_gib = "palm"
	aggro_vision_range = 3
	damage_coeff = list("brute" = 1, "fire" = 0.5, "tox" = 0, "clone" = 0, "stamina" = 0, "oxy" = 0)
	obj_damage = 0

/mob/living/simple_animal/hostile/tree/jungle
	name = "Tree"
	icon = 'icons/obj/flora/jungletreesmall.dmi'
	icon_state = "tree2"
	icon_living = "tree2"
	icon_dead = "tree2"
	icon_gib = "tree2"
	aggro_vision_range = 3
	damage_coeff = list("brute" = 0.3, "fire" = 2, "tox" = 0, "clone" = 0, "stamina" = 0, "oxy" = 0)
	obj_damage = 0

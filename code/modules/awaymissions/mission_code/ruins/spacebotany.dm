/area/ruin/space/spacebotany
	poweralm = FALSE
	report_alerts = FALSE

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
	name = "Отчёт о работе объекта. №23-BG"
	info = "<p> Работаем в штатном режиме. \
	Заказчик крайне доволен результатом. \
	Образцы №322 получили указанные заказчиком устойчивость к температуре и лазерному воздействию, и даже превзошли ожидания. \
	Система посмертного уничтожения образцов в разработке. Как только проведём тесты имплантов, пришлите усиленную взрывчатку. Пока что обойдёмся тем, что изготовим сами, но не взводите устройство до прибытия на полигон. \
	Долгожданную посылку со склада снабжения получил. Держу в сохранном месте. </p>"

/obj/item/paper/spacebotany/report1
	name = "Оборванный лист"
	info = "<p> ...как того мы и ждали. Тем не менее прошлая работёнка, хоть и казалась простой, принесла кучу хлопот. Нормально заказ не смогли выполнить, так что нам не заплатили до конца. Лоза оказалась не слишком живучей, но другие прихоти заказчика мы всё же смогли реализовать. Отставив лозу на второй план, взялись за следующий заказ. С ним всё иначе. \
	Устойчивость к огню и лазерам были главными свойствами, а также система самоподрыва, как дополнение. Однако, с превыш... </p>"

/obj/item/paper/spacebotany/note
	name = "Вырванная страница дневника"
	info = "<p> Прошло уже 10 дней с начала 6 смены на этой станции. Не знаю, выдержу ли я этих огузков... Конечно, чёрт возьми, выдержу. В этот раз платят в три раза больше! Липкий Джонни — просто прекрасный коллега! С ним мы управимся за пару недель. Он компенсирует их всех своей прекрасной игрой в шахматы по вечерам и, как отличному главе, он даёт мне стимул двигаться дальше. Отлично знает своё дело — почти лучше, чем я. Однако я до сих пор не угадал его настоящего имени... Ну и ладно. </p>"

/obj/item/paper/spacebotany/note1
	name = "Вырванная страница дневника"
	info = "<p> Прошло 3 дня с начала 6 смены на этой станции. Новый состав выкидывает прикол за приколом. Мы с Джонни, как и ожидалось, прекрасно выполняем свои обязательства, в отличие от нашего нового химика. Он, конечно, не сильно умнее старого, но хотя бы работает в маске и маркирует склянки по-человечески. И если старый просто нарушал технику безопасности, а ещё из-за одного угарного случая, произощедшего по его вине и из-за того, что при строительстве сэкономили на вентиляции, мы все чуть не сдохли. Но в целом он был нормальным... То новый, мне кажется, неделю назад впервые мерный стакан в руках подержал. \
	А ещё Пабло... он вообще самый ебнутый из экипажа... </p>"

/obj/item/paper/spacebotany/note2
	name = "Вырванная страница дневника"
	info = "<p> Прошло 9 дней с начала 6 смены на этой станции... Пабло действительно отличный биолог, но, мне кажется, он не совсем здоров психически. Его нездоровая тяга ко всяким химерам пугает меня куда больше, чем всё то дерьмо, что я здесь когда-либо видел. </p>"

/obj/item/paper/spacebotany/note3
	name = "Оборванный лист"
	info = "<p> ...иногда это раздражает. Он относится к некоторым из них как к собственным детям... Как же порой тяжело заставить его утилизировать некоторые неудачные образцы... Его самого бы утилизировать, но нельзя! А что делать?! Где мне ещё нормального ксенобиолога, согласного работать с эт... </p>"

/mob/living/simple_animal/hostile/killertomato/spacebotany
	name = "Unsatable Tomato"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	maxHealth = 120
	health = 120
	melee_damage_lower = 0
	melee_damage_upper = 40
	can_hide = TRUE
	aggro_vision_range = 6
	damage_coeff = list(BRUTE = 1, FIRE = -0.1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)

/mob/living/simple_animal/hostile/killertomato/spacebotany/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = 500, \
		minbodytemp = 150, \
		heat_damage = 0, \
	)

/mob/living/simple_animal/hostile/tree/palm

	name = "Palm tree"
	icon = 'icons/obj/flora/jungletreesmall.dmi'
	icon_state = "palm"
	icon_living = "palm"
	icon_dead = "palm"
	icon_gib = "palm"
	aggro_vision_range = 3
	damage_coeff = list(BRUTE = 1, FIRE = 0.5, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	obj_damage = 0

/mob/living/simple_animal/hostile/tree/jungle
	name = "Tree"
	icon = 'icons/obj/flora/jungletreesmall.dmi'
	icon_state = "tree2"
	icon_living = "tree2"
	icon_dead = "tree2"
	icon_gib = "tree2"
	aggro_vision_range = 3
	damage_coeff = list(BRUTE = 0.3, FIRE = 2, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	obj_damage = 0

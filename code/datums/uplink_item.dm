#define UPLINK_DISCOUNTS 4

/**
 * Proc that generates a list of items, available for certain uplink.
 *
 * Arguments:
 * * target_uplink - uplink we are checking.
 * * only_main_operations - skips sales and discounts, used for surplus crates generation.
 */
/proc/get_uplink_items(obj/item/uplink/target_uplink, generate_discounts = FALSE)
	. = list()
	var/list/sales_items = generate_discounts ? list() : null

	for(var/datum/uplink_item/uplink_item as anything in GLOB.uplink_items)
		if(length(uplink_item.uplinktypes) && !(target_uplink.uplink_type in uplink_item.uplinktypes) && target_uplink.uplink_type != UPLINK_TYPE_ADMIN)
			continue

		if(length(uplink_item.excludefrom) && (target_uplink.uplink_type in uplink_item.excludefrom) && target_uplink.uplink_type != UPLINK_TYPE_ADMIN)
			continue

		if(uplink_item.limited_stock != -1 || (uplink_item.can_discount && uplink_item.refundable))
			uplink_item = new uplink_item.type //If item has limited stock or can be discounted and refundable at same time make a copy
		. += uplink_item

		if(generate_discounts && uplink_item.limited_stock < 0 && uplink_item.can_discount && uplink_item.cost > 5)
			sales_items += uplink_item

	if(generate_discounts)
		for(var/i in 1 to UPLINK_DISCOUNTS)
			var/datum/uplink_item/discount_origin = pick_n_take(sales_items)

			var/datum/uplink_item/discount_item = new discount_origin.type
			var/discount = 0.5
			var/init_cost = initial(discount_item.cost)
			discount_item.limited_stock = 1
			if(discount_item.cost >= 100)
				discount *= 0.5 // If the item costs 100TC or more, it's only 25% off.
			discount_item.cost = max(round(discount_item.cost * (1 - discount)), 1)
			discount_item.category = "Снаряжение со скидкой"
			discount_item.name += " ([round(((init_cost - discount_item.cost) / init_cost) * 100)]% скидка!)"
			discount_item.job = null // If you get a job specific item selected, actually lets you buy it in the discount section
			discount_item.desc += "Ограничение в размере [discount_item.limited_stock] на аплинк. Обычно это стоит [init_cost] ТК."
			discount_item.surplus = 0 // stops the surplus crate potentially giving out a bit too much

			. += discount_item

	return .


/datum/uplink_item
	/// Uplink name.
	var/name = "item name"
	/// Uplink category.
	var/category = "item category"
	/// Uplink description.
	var/desc = "item description"
	/// Item object, must be defined in every datum entry and must be /obj path.
	var/item
	/// Item cost in TC.
	var/cost = 0
	/// Empty list means it is in all the uplink types. Otherwise place the uplink type here.
	var/list/uplinktypes
	/// Empty list does nothing. Place the name of uplink type you don't want this item to be available in here.
	var/list/excludefrom
	/// Empty list means it is available for every job assignment.
	var/list/job
	/// Empty list means it is available for every in game species.
	var/list/race
	/// Chance of being included in the surplus crate (when pick() selects it).
	var/surplus = 100
	/// Whether item can be on sales category.
	var/can_discount = TRUE
	/// Can you only buy so many? -1 allows for infinite purchases.
	var/limited_stock = -1
	/// Can this item be purchased only with hijack objective?
	var/hijack_only = FALSE
	/// Is this item refundable?
	var/refundable = FALSE
	/// Alternative path for refunds, in case the item purchased isn't what is actually refunded (ie: holoparasites).
	var/refund_path
	/// Associative list UID - refund cost
	var/static/list/item_to_refund_cost


/datum/uplink_item/Destroy(force)
	if(force)
		return ..()
	else
		// if you're deleting an uplink item something has gone wrong
		return QDEL_HINT_LETMELIVE


/**
 * Spawns object item contained as path in datum item variable if possible.
 *
 * Arguments:
 * * buyer - mob who performs the transaction.
 * * target_uplink - uplink we are buying from.
 */
/datum/uplink_item/proc/spawn_item(mob/buyer, obj/item/uplink/target_uplink)
	. = null
	//nukies get items that regular traitors only get with hijack. If a hijack-only item is not for nukies, then exclude it via the gamemode list.
	if(hijack_only && !(buyer.mind.special_role == SPECIAL_ROLE_NUKEOPS) && !(locate(/datum/objective/hijack) in buyer.mind.get_all_objectives()) && target_uplink.uplink_type != UPLINK_TYPE_ADMIN)
		to_chat(buyer, span_warning("Синдикат готов предоставить этот чрезвычайно опасный предмет только тем агентам, целью которых является угон эвакуационного шаттла."))
		return .

	if(!item)
		return .

	target_uplink.uses -= max(cost, 0)
	target_uplink.used_TC += cost
	SSblackbox.record_feedback("nested tally", "traitor_uplink_items_bought", 1, list("[initial(name)]", "[cost]"))
	return new item(get_turf(buyer))


/**
 * Actulizes datum description.
 */
/datum/uplink_item/proc/description()
	if(!desc)
		// Fallback description
		var/obj/temp = item
		desc = replacetext(initial(temp.desc), "\n", "<br>")
	return desc


/**
 * Handles buying an item, and logging.
 *
 * Arguments:
 * * target_uplink - uplink we are buying from.
 * * buyer - mob who performs the transaction.
 */
/datum/uplink_item/proc/buy(obj/item/uplink/hidden/target_uplink, mob/living/carbon/human/buyer, put_in_hands = TRUE)

	if(!istype(target_uplink))
		return FALSE

	if(buyer.stat || HAS_TRAIT(buyer, TRAIT_HANDS_BLOCKED))
		return FALSE

	if(!ishuman(buyer))
		return FALSE

	// If the uplink's holder is in the user's contents
	if(!(target_uplink.loc in buyer.contents) && !(in_range(target_uplink.loc, buyer) && isturf(target_uplink.loc.loc)))
		return FALSE

	if(cost > target_uplink.uses)
		return FALSE

	. = TRUE

	buyer.set_machine(target_uplink)

	var/obj/spawned = spawn_item(buyer, target_uplink)

	if(!spawned)
		return .

	if(category == "Снаряжение со скидкой" && refundable)
		var/obj/item/refund_item
		if(istype(spawned, refund_path))
			refund_item = spawned
		else
			refund_item = locate(refund_path) in spawned

		if(!item_to_refund_cost)
			item_to_refund_cost = list()

		if(refund_item)
			item_to_refund_cost[refund_item.UID()] = cost
		else
			stack_trace("Can not find [refund_path] in [src]")

	if(limited_stock > 0)
		limited_stock--
		add_game_logs("purchased [name]. [name] was discounted to [cost].", buyer)
		if(!buyer.mind.special_role)
			message_admins("[key_name_admin(buyer)] purchased [name] (discounted to [cost]), as a non antagonist.")
	else
		add_game_logs("purchased [name].", buyer)
		if(!buyer.mind.special_role)
			message_admins("[key_name_admin(buyer)] purchased [name], as a non antagonist.")

	if(put_in_hands)
		buyer.put_in_any_hand_if_possible(spawned)

	if(istype(spawned, /obj/item/storage/box) && length(spawned.contents))
		for(var/atom/box_item in spawned)
			target_uplink.purchase_log += "<BIG>[bicon(box_item)]</BIG>"
	else
		target_uplink.purchase_log += "<BIG>[bicon(spawned)]</BIG>"

	return spawned

/*
//
//	UPLINK ITEMS
//
*/
//Work in Progress, job specific antag tools

//Discounts (dynamically filled above)

/datum/uplink_item/discounts
	category = "Снаряжение со скидкой"

//Job specific gear

/datum/uplink_item/jobspecific
	category = "Профессиональные предметы"
	can_discount = FALSE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST) // Stops the job specific category appearing for nukies

//Clown

/datum/uplink_item/jobspecific/clowngrenade
	name = "Банановая граната"
	desc = "Граната, которая взрывается с оглушительным ХОНКОМ! \
			Внутри неё находятся фирменные банановые кожурки, которые были генетически модифицированы. \
			Это делает их особенно скользкими и способными выделять едкую кислоту при контакте."
	item = /obj/item/grenade/clown_grenade
	cost = 8
	job = list(JOB_TITLE_CLOWN)

/datum/uplink_item/jobspecific/cmag
	name = "Шутографический считыватель"
	desc = "Представляет собой карту, также известную как КМАГ, способную изменять порядок доступа к любой двери, к которой её подключили. \
			Превосходный выбор для ограничения доступа сотрудников за пределы их собственных отделов. Хонк!"
	item = /obj/item/card/cmag
	cost = 20
	surplus = 50
	job = list(JOB_TITLE_CLOWN)

/datum/uplink_item/jobspecific/clownmagboots
	name = "Клоунские магнитные башмаки"
	desc = "Пара модернизированных клоунских ботинок, которые оснащены передовой системой магнитного сцепления. \
			Если не приглядываться, они выглядят и звучат как обычные клоунские башмаки."
	item = /obj/item/clothing/shoes/magboots/clown
	cost = 12
	job = list(JOB_TITLE_CLOWN)

/datum/uplink_item/jobspecific/acrobatic_shoes
	name = "Клоунские башмаки акробата"
	desc = "Пара модернизированных клоунских башмаки, оснащённых инновационным прыгающим механизмом, работающим на основе технологии \"хонк-спейс\". \
			Этот механизм открывает безграничные возможности для выполнения захватывающих акробатических трюков, позволяя стать настоящим мастером в мире развлечений!"
	item = /obj/item/clothing/shoes/bhop/clown
	cost = 12
	job = list(JOB_TITLE_CLOWN)

/datum/uplink_item/jobspecific/trick_revolver
	name = "Револьвер для розыгрышей"
	desc = "Револьвер, который стреляет в обратном направлении, убивая любого, кто попытается им воспользоваться. \
			Идеально подходит для назойливых мстителей или просто для того, чтобы посмеяться."
	item = /obj/item/storage/box/syndie_kit/fake_revolver
	cost = 5
	job = list(JOB_TITLE_CLOWN)

/datum/uplink_item/jobspecific/bipki
	name = "Чемодан с бипками"
	desc = "Хочешь знать, что там внутри? Отсосёшь - скажу."
	item = /obj/item/case_with_bipki
	cost = 30
	job = list(JOB_TITLE_CLOWN)

//Mime

/datum/uplink_item/jobspecific/caneshotgun
	name = "Дробовик-трость и патроны для убийства"
	desc = "Однозарядный дробовик, оснащённый устройством, которое имитирует трость. В комплект входят шесть специальных шрапнельных патронов, \
			заставляющих жертву замолчать, а также один патрон, уже заряженный в патронник. Кроме того, этот дробовик может использовать и обычные патроны."
	item = /obj/item/storage/box/syndie_kit/caneshotgun
	cost = 25
	job = list(JOB_TITLE_MIME)

/datum/uplink_item/jobspecific/mimery
	name = "Руководство по продвинутым пантомимам"
	desc = "В этом сборнике вы найдёте два руководства, которые помогут вам освоить искусство пантомимы на продвинутом уровне. \
			Вы научитесь стрелять оглушающими пулями прямо из пальцев и создавать большие стены, способные перекрыть целый коридор!"
	item = /obj/item/storage/box/syndie_kit/mimery
	cost = 30
	job = list(JOB_TITLE_MIME)

/datum/uplink_item/jobspecific/mimejutsu
	name = "Руководство по Мимдзютсу"
	desc = "Старое пособие по боевому искусству мимов."
	item = /obj/item/mimejutsu_scroll
	cost = 40
	job = list(JOB_TITLE_MIME)

/datum/uplink_item/jobspecific/combat_baking
	name = "Набор боевого пекаря"
	desc = "Набор секретного оружия, изготовленного из выпечки! В наборе вы найдёте багет, который опытный мим мог бы использовать в качестве меча, \
			пару круассанов для метания и рецепт, по которому можно приготовить ещё. Когда работа будет выполнена, не забудьте съесть улики."
	item = /obj/item/storage/box/syndie_kit/combat_baking
	cost = 25
	job = list(JOB_TITLE_MIME, JOB_TITLE_CHEF)

//Miner

/datum/uplink_item/jobspecific/pressure_mod
	name = "Модкит \"Давление\" для кинетического акселератора"
	desc = "Набор для модификации КА, который значительно увеличивает его урон в герметичной среде. Занимает 35% ёмкости мода. \
			Для полной компенсации штрафа необходимо использовать 2 таких модуля."
	item = /obj/item/borg/upgrade/modkit/indoors
	cost = 18 //you need two for full damage, so total of 8 for maximum damage
	job = list(JOB_TITLE_MINER, JOB_TITLE_QUARTERMASTER)

/datum/uplink_item/jobspecific/mining_charge_hacker
	name = "Взломщик подрывных зарядов"
	desc = "Выглядит и функционирует как продвинутый шахтёрский сканер, но позволяет размещать заряды в любом месте и разрушать не только камни. \
			Используйте его на шахтёрском заряде, чтобы отменить его предустановки безопасности. \
			Уменьшает взрывную силу зарядов за счет модификации их внутренних компонентов."
	item = /obj/item/t_scanner/adv_mining_scanner/syndicate
	cost = 20
	job = list(JOB_TITLE_MINER, JOB_TITLE_QUARTERMASTER)

//Chef

/datum/uplink_item/jobspecific/specialsauce
	name = "Элитарный соус шефа"
	desc = "Фирменный соус, приготовленный из мухоморов. Токсический эффект будет зависеть от того, как долго он остаётся в организме, \
			чем больше доза, тем больше времени потребуется для её усвоения."
	item = /obj/item/reagent_containers/food/condiment/syndisauce
	cost = 1
	job = list(JOB_TITLE_CHEF)

/datum/uplink_item/jobspecific/meatcleaver
	name = "Тесак для мяса"
	desc = "Устрашающий на вид нож для разделки мяса способен нанести урон, сравнимый с энергетическим мечом. \
			Но его главное преимущество — он может разрубать жертву на куски после её гибели."
	item = /obj/item/kitchen/knife/butcher/meatcleaver
	cost = 20
	job = list(JOB_TITLE_CHEF)

/datum/uplink_item/jobspecific/syndidonk
	name = "Донк-покеты Синдиката"
	desc = "Коробка с уникальными Донк-покетами, содержащими сильнодействующие регенерирующие и стимулирующие химические вещества. \
			Из-за высокой концентрации этих веществ не рекомендуется употреблять более одного покета за раз. В коробке предусмотрен механизм подогрева."
	item = /obj/item/storage/box/syndidonkpockets
	cost = 10
	job = list(JOB_TITLE_CHEF)

/datum/uplink_item/jobspecific/CQC_upgrade
	name = "Имплант улучшения CQC"
	desc = "Специальный имплант для шеф-поваров, который позволяет им нарушать правила безопасности и использовать CQC за пределами кухни. \
			Убедитесь, есть ли у вас имплант CQC, который даёт вам возможность использовать это боевое искусство."
	item = /obj/item/CQC_manual/chef
	cost = 30
	job = list(JOB_TITLE_CHEF)
	surplus = 0 //because it's useless for all non-chefs

/datum/uplink_item/jobspecific/dangertray
	name = "Набор особо острых подносов"
	desc = "В набор входят 3 острых металлических подноса, которые можно использовать для отрезания конечностей."
	item = /obj/item/storage/box/syndie_kit/dangertray
	cost = 15
	job = list(JOB_TITLE_CHEF)

//Chaplain
//Translation of uplink items into Russian continues from here

/datum/uplink_item/jobspecific/voodoo
	name = "Кукла Вуду"
	desc = "Кукла, созданная колдунами Синдиката, состоит из различных ингредиентов: ниток, частей головы, тела, а также секретных трав вуду и глутамата натрия."
	item = /obj/item/voodoo
	cost = 11
	job = list(JOB_TITLE_CHAPLAIN)

/datum/uplink_item/jobspecific/missionary_kit
	name = "Стартовый набор миссионера"
	desc = "В комплект входят миссионерский посох, миссионерская одежда и Библия. \
			С помощью посоха и одежды вы сможете убедить ваших жертв следовать вашим указаниям на короткое время. ВОЛОЛО!"
	item = /obj/item/storage/box/syndie_kit/missionary_set
	cost = 72
	job = list(JOB_TITLE_CHAPLAIN)

/datum/uplink_item/jobspecific/artistic_toolbox
	name = "Артистический ящик для инструментов"
	desc = "Проклятый ящик для инструментов, который наделяет своих последователей невероятной силой, требуя взамен постоянных жертв. \
			Если эти жертвы не будут принесены, он может напасть на своего обладателя."
	item = /obj/item/storage/toolbox/green/memetic
	cost = 100
	job = list(JOB_TITLE_CHAPLAIN, JOB_TITLE_CIVILIAN)
	surplus = 0 //No lucky chances from the crate; if you get this, this is ALL you're getting
	hijack_only = TRUE //This is a murderbone weapon, as such, it should only be available in those scenarios.

/datum/uplink_item/jobspecific/book_of_babel
	name = "Вавилонская книга"
	desc = "Древнейший фолиант, написанный на бесчисленном множестве языков. \
			Тем не менее, вы без труда сможете прочитать эту книгу и освоить все существующие языки. Не задавайте лишних вопросов."
	item = /obj/item/book_of_babel
	cost = 1
	job = list(JOB_TITLE_CHAPLAIN, JOB_TITLE_LIBRARIAN)
	surplus = 0
	can_discount = FALSE

//Janitor

/datum/uplink_item/jobspecific/cautionsign
	name = "Бесконтактная мина"
	desc = "Противопехотная мина, искусно замаскированная под знак \"Осторожно! Мокрый пол!\", срабатывает, когда кто-то пробегает мимо неё. \
			При активации запускается таймер, отсчитывающий 15 секунд, после чего мина приходит в боевую готовность. \
			Чтобы обезвредить её, необходимо активировать устройство повторно."
	item = /obj/item/caution/proximity_sign
	cost = 11
	job = list(JOB_TITLE_JANITOR)
	surplus = 0

/datum/uplink_item/jobspecific/holomine
	name = "Проектор голографических мин"
	desc = "Проектор, позволяющий устанавливать до пяти оглушающих мин, обладающих дополнительным ЭМИ эффектом. \
			Устройство является многоразовым, как и обычный голопроектор."
	item = /obj/item/holosign_creator/janitor/syndie
	cost = 40
	job = list(JOB_TITLE_JANITOR)
	surplus = 0

//Medical

/datum/uplink_item/jobspecific/rad_laser
	name = "Радиационный излучатель"
	desc = "Устройство с радиационным лазером, закрепленным снаружи анализатора здоровья. \
			Имеет регулируемое управление, позволяющее выставить необходимые параметры. Не функционирует как обычный анализатор, а лишь имитирует его работу. \
			Важно отметить, что он может некорректно работать на гуманоидах, устойчивых к радиации!"
	item = /obj/item/rad_laser
	cost = 23
	job = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_GENETICIST, JOB_TITLE_PSYCHIATRIST, \
			JOB_TITLE_CHEMIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_CORONER, JOB_TITLE_VIROLOGIST)

/datum/uplink_item/jobspecific/batterer
	name = "Подавитель разума"
	desc = "Устройство, которое способно на длительное время дезориентировать окружающих и замедлить их движение. \
			Никак не влияет на пользователя. Зарядка занимает 3 минуты."
	item = /obj/item/batterer
	cost = 50
	job = list(JOB_TITLE_CMO, JOB_TITLE_PSYCHIATRIST)

/datum/uplink_item/jobspecific/dna_upgrader
	name = "Инъектор генетического превосходства"
	desc = "Экспериментальный ДНК-инъектор, который позволит вам выбрать один из продвинутых генов и повысит вашу генетическую стабильность."
	item = /obj/item/dna_upgrader
	cost = 55
	job = list(JOB_TITLE_CMO, JOB_TITLE_GENETICIST)
	surplus = 0

/datum/uplink_item/jobspecific/laser_eyes_injector
	name = "Инъектор лазерных глаз"
	desc = "Экспериментальный ДНК-инъектор, который даст вам способность стрелять лазерами из глаз."
	item = /obj/item/laser_eyes_injector
	cost = 37
	job = list(JOB_TITLE_GENETICIST)
	surplus = 0

//Virology

/datum/uplink_item/jobspecific/viral_injector
	name = "Вирусный инъектор"
	desc = "Модифицированный гипоспрей, замаскированный под пипетку. При использовании на ком-то, пипетка может заразить жертву вирусами."
	item = /obj/item/reagent_containers/dropper/precision/viral_injector
	cost = 15
	job = list(JOB_TITLE_VIROLOGIST)

/datum/uplink_item/jobspecific/cat_grenade
	name = "Граната доставки диких кошек"
	desc = "Представляет собой устройство, в котором находятся 5 дегидратированных кошек аналогично дегидратированным обезьянам, \
			которые после взрыва будут регидратированы небольшим резервуаром воды, содержащимся внутри гранаты. \
			Затем эти кошки будут нападать на всё, что попадется им на глаза."
	item = /obj/item/grenade/spawnergrenade/feral_cats
	cost = 3
	job = list(JOB_TITLE_PSYCHIATRIST)//why? Becuase its funny that a person in charge of your mental wellbeing has a cat granade..

/datum/uplink_item/jobspecific/gbs
	name = "Бутылка с вирусом ГБС"
	desc = "Содержит чрезвычайно смертельный вирус ГБС, в начальной фазе имитирующий симптомы гриппа, но со временем разрывает тело носителя."
	item = /obj/item/reagent_containers/glass/bottle/gbs
	cost = 60
	job = list(JOB_TITLE_VIROLOGIST)
	surplus = 0
	hijack_only = TRUE

/datum/uplink_item/jobspecific/lockermech
	name = "Синди-Шкафомех"
	desc = "Массивный и невероятно смертоносный экзоскетлет Синдиката (на самом деле нет)."
	item = /obj/mecha/combat/lockersyndie/loaded
	cost = 25
	job = list(JOB_TITLE_CIVILIAN, JOB_TITLE_ROBOTICIST)
	surplus = 0

/datum/uplink_item/jobspecific/combat_drone
	name = "Руководство по эксплуатации боевого дрона"
	desc = "Руководство, которое позволит вам сконструировать боевые дроны и панель управления для них."
	item = /obj/item/drone_manual
	cost = 45
	job = list(JOB_TITLE_ROBOTICIST)

/datum/uplink_item/jobspecific/stungloves
	name = "Оглушающие перчатки"
	desc = "Пара изоляционных перчаток, которые предотвращают поражение электрическим током и позволяет наносить оглушающие удары током. \
			В комплект входит аккумулятор, который можно заменить с помощью кусачек."
	item = /obj/item/storage/box/syndie_kit/stungloves
	cost = 7
	job = list(JOB_TITLE_CIVILIAN, JOB_TITLE_MECHANIC, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_CHIEF)

//Bartender

/datum/uplink_item/jobspecific/drunkbullets
	name = "Опьяняющие ружейные патроны"
	desc = "Патронаш с 16 патронами для ружья, которые вызывают сильное алкогольное опьянение. \
			Эффективность воздействия возрастает с каждым видом алкоголя, содержащимся в крови жертвы на момент выстрела."
	item = /obj/item/storage/belt/bandolier/booze
	cost = 15
	job = list(JOB_TITLE_BARTENDER)

//Botanist

/datum/uplink_item/jobspecific/bee_briefcase
	name = "Полный чемодан пчёл"
	desc = "На первый взгляд, это безобидный чемоданчик. Однако внутри него скрываются опасные пчелы, выведенные Синдикатом. \
			Чтобы пчелы не обращали внимания на хозяина или хозяев, в чемодан необходимо добавить кровь. \
			А чтобы увеличить количество пчёл, нужно залить внутрь стабильный мутаген. \
			Когда чемодан открывается, он подключается к интеркому на станции по беспроводной связи и передаёт устрашающее сообщение."
	item = /obj/item/bee_briefcase
	cost = 22
	job = list(JOB_TITLE_BOTANIST)

/datum/uplink_item/jobspecific/gatfruit
	name = "Семена Гатфрукта"
	desc = "Пачка семян Гатфрукта, съев плоды которого можно получить револьвер .36 калибра! \
			Кроме того, растение содержит химические элементы: 10% серы, 10% углерода, 7% азота и 5% калия."
	item = /obj/item/seeds/gatfruit
	cost = 22
	job = list(JOB_TITLE_BOTANIST)

//Engineer

/datum/uplink_item/jobspecific/powergloves
	name = "Силовые перчатки"
	desc = "Изолированные перчатки, которые могут преобразовывать энергию на станции в короткую электрическую дугу, поражая выбранную цель. \
			Для активации устройства необходимо встать на кабель с питанием."
	item = /obj/item/clothing/gloves/color/yellow/power
	cost = 33
	job = list(JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_CHIEF)

/datum/uplink_item/jobspecific/supertoolbox
	name = "Набор экспериментальных инструментов"
	desc = "Ящик, выполненный в зловещих чёрно-красных тонах, содержащий набор экспериментальных инструментов, боевые перчатки и стильные солнцезащитные очки."
	item = /obj/item/storage/toolbox/syndisuper
	cost = 8
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	job = list(JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_CHIEF, \
			JOB_TITLE_MECHANIC, JOB_TITLE_ROBOTICIST, JOB_TITLE_PARAMEDIC)

//RD

/datum/uplink_item/jobspecific/telegun
	name = "Телепушка"
	desc = "Чрезвычайно высокотехнологичное оружие, которое использует блюспейс технологию для телепортации живых целей. \
			Вам необходимо выбрать целевой маяк на телепушке, и тогда её снаряды будут отправлять цели к этому маяку."
	item = /obj/item/gun/energy/telegun
	cost = 66
	job = list(JOB_TITLE_RD)

//Roboticist

/datum/uplink_item/jobspecific/syndiemmi
	name = "НКИ Синдиката"
	desc = "Разработанный синдикатом Нейронный Компьютерный Интерфейс, который навязывает законы Синдиката любому мозгу, помещённому в него."
	item = /obj/item/mmi/syndie
	cost = 15
	job = list(JOB_TITLE_ROBOTICIST)
	surplus = 0

/datum/uplink_item/jobspecific/missilemedium
	name = "Пусковая ракетная установка SRM-8"
	desc = "Эта ракетная установка используются на высококлассных экзоскелетах, таких как \"Mauler\" и \"Marauder\". \
			Она обладает гораздо большей мощностью, чем ракетные установки, которые можно создать в фабрикаторе экзоскелетов. \
			Поставляется без кейса!"
	item = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/medium
	cost = 50
	job = list(JOB_TITLE_ROBOTICIST)
	surplus = 0
	can_discount = FALSE
	hijack_only = TRUE

//Librarian

/datum/uplink_item/jobspecific/etwenty
	name = "Двадцатигранник"
	desc = "На первый взгляд это обычный кубик, но он обладает поистине взрывным эффектом! Кубик оснащён четырёхсекундным таймером."
	item = /obj/item/dice/d20/e20
	cost = 8
	job = list(JOB_TITLE_LIBRARIAN)
	surplus = 0
	hijack_only = TRUE

/datum/uplink_item/jobspecific/random_spell_book
	name = "Случайная книга заклинаний"
	desc = "Случайная книга заклинаний, которую мы позаимствовали у Федерации Космических Волшебников."
	item = /obj/item/spellbook/oneuse/random
	cost = 25
	job = list(JOB_TITLE_LIBRARIAN)
	can_discount = FALSE

/datum/uplink_item/jobspecific/dice_of_fate
	name = "Кости судьбы"
	desc = "Мой девиз — всё или ничего."
	item = /obj/item/dice/d20/fate/one_use
	cost = 100
	job = list(JOB_TITLE_LIBRARIAN)
	surplus = 0
	can_discount = FALSE

//Botanist

/datum/uplink_item/jobspecific/ambrosiacruciatus
	name = "Семена Амброзии Круциатус"
	desc = "Этот вид, принадлежащий к печально известному семейству амброзиевых, практически неотличим от Амброзии Вульгарис, однако его ветви содержат смертельный токсин."
	item = /obj/item/seeds/ambrosia/cruciatus
	cost = 4
	job = list(JOB_TITLE_BOTANIST)

//Atmos Tech

/datum/uplink_item/jobspecific/contortionist
	name = "Комбинезон акробата"
	desc = "Этот комбинезон обладает высокой гибкостью, что позволяет с лёгкостью перемещаться в вентиляционных трубах станции. \
			Он оснащён карманами и прорезью для ID-карты. Однако для его использования необходимо снять большую часть снаряжения, включая рюкзак, ремень, ИКС и головной убор. \
			Кроме того, для передвижения внутри вентиляции вам потребуются свободные руки."
	item = /obj/item/clothing/under/contortionist
	cost = 50
	job = list(JOB_TITLE_ATMOSTECH, JOB_TITLE_CHIEF)

/datum/uplink_item/jobspecific/energizedfireaxe
	name = "Энергетический пожарный топор"
	desc = "Пожарный топор, обладающий мощным энергетическим зарядом. Способен отбросить цель назад и на некоторое время оглушить. \
			Однако для повторного заряда требуется определённое время. Кроме того, этот топор значительно острее обычного и может пробивать лёгкую броню."
	item = /obj/item/twohanded/fireaxe/energized
	cost = 18
	job = list(JOB_TITLE_ATMOSTECH, JOB_TITLE_CHIEF)

/datum/uplink_item/jobspecific/combat_rcd
	name = "УБС Синдиката"
	desc = "Способно разрушать укреплённые стены. Имеет 500 единиц материи вместо стандартных 100."
	item = /obj/item/rcd/combat
	cost = 25
	job = list(JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_MECHANIC, JOB_TITLE_ATMOSTECH, JOB_TITLE_CHIEF)
	surplus = 0

/datum/uplink_item/jobspecific/poisonbottle
	name = "Бутылка с ядом"
	desc = "Синдикат отправит вам флакон с 40 единицами случайно выбранного яда. Этот яд может быть как совершенно неэффективным, так и крайне смертельным."
	item = /obj/item/reagent_containers/glass/bottle/traitor
	cost = 10
	job = list(JOB_TITLE_RD, JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_PSYCHIATRIST, \
			JOB_TITLE_CHEMIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_VIROLOGIST, JOB_TITLE_BARTENDER, JOB_TITLE_CHEF)

/datum/uplink_item/jobspecific/poison_pen
	name = "Ручка с ядом"
	desc = "Новейшая разработка в области смертоносных письменных принадлежностей. \
			Она способна пропитать любой лист бумаги медленно действующим ядом."
	item = /obj/item/pen/poison
	cost = 5
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	job = list(JOB_TITLE_HOP, JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH, JOB_TITLE_LIBRARIAN)

// Racial

/datum/uplink_item/racial
	category = "Расовые предметы"
	can_discount = FALSE
	surplus = 0
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

//IPC

/datum/uplink_item/racial/ipc_combat_upgrade
	name = "Боевое обновление КПБ"
	desc = "Усовершенствованное хранилище данных, разработанное для обеспечения совместимости с позитронными системами. \
			Оно оснащено алгоритмами ближнего боя и имеет обновленные протоколы безопасности для работы с микробатареями."
	item = /obj/item/ipc_combat_upgrade
	cost = 11
	race = list(SPECIES_MACNINEPERSON)

/datum/uplink_item/racial/supercharge
	name = "Имплант cуперзаряда"
	desc = "Имплант, который можно вживить в организм и активировать по желанию. Можно активировать до 3 раза. \
			Он выпускает специальный химический коктейль, который снимает и значительно сокращает эффект оглушения, а также повышает скорость передвижения."
	item = /obj/item/implanter/supercharge
	cost = 40
	race = list(SPECIES_MACNINEPERSON)

//Slime People

/datum/uplink_item/racial/anomaly_extract
	name = "Аномальный экстракт"
	desc = "Результат научных экспериментов по смешиванию экспериментального стабильного мутагена с ядром огненной аномалии. \
			Позволяет пользователю трансформироваться в слизня и разогреться до очень высокой температуры."
	item = /obj/item/anomaly_extract
	cost = 40
	race = list(SPECIES_SLIMEPERSON)

//Plasmaman

/datum/uplink_item/racial/plasma_chameleon
	name = "Набор одежды \"Хамелеон\" для плазмолюдов"
	desc = "Комплект одежды, оснащённый технологией \"Хамелеон\", которая позволяет изменять её внешний вид. \
			Однако из-за несовершенства этой технологии обувь не обеспечивает защиту от скольжения. \
			В набор также входит дополнительный печать \"Хамелеон\". Предназначен только для плазмолюдов."
	item = /obj/item/storage/box/syndie_kit/plasma_chameleon
	cost = 20
	race = list(SPECIES_PLASMAMAN)

//Nucleation

/datum/uplink_item/racial/second_chance
	name = "Имплант второго шанса"
	desc = "Имплант, активируемый по желанию, позволяет имитировать смерть, вызывая взрыв. \
			После активации он полностью залечивает все раны пользователя и телепортирует его в безопасное место."
	item = /obj/item/implanter/second_chance
	cost = 40
	race = list(SPECIES_NUCLEATION)

//Human

/datum/uplink_item/racial/holo_cigar
	name = "Голографическая сигара"
	desc = "Привезена из Солнечной системы. Помимо брутального внешнего вида, пользователи отмечают, что она повышает точность при стрельбе обеими руками одновременно."
	item = /obj/item/clothing/mask/holo_cigar
	cost = 10
	race = list(SPECIES_HUMAN)

/datum/uplink_item/racial/ghostface_kit
	name = "Набор \"Гоустфейс\""
	desc = "Всё, что нужно, дабы повторить всем известное призрачное лицо! \
			Включает в себя бронированный чёрный балахон, бронированную маску с функцией сокрытия голоса и сверх-острый аутентичный нож."
	item = /obj/item/storage/box/syndie_kit/ghostface_kit
	cost = 50
	race = list(SPECIES_HUMAN)

/datum/uplink_item/racial/devilghostface_kit
	name = "Набор \"Дьявольский Гоустфейс\""
	desc = "Всё, что нужно, дабы повторить всем известное призрачное лицо! \
			Включает в себя бронированный чёрный балахон, бронированную маску с функцией сокрытия голоса и сверх-острый аутентичный нож."
	item = /obj/item/storage/box/syndie_kit/devil_ghostface_kit
	cost = 50
	race = list(SPECIES_HUMAN)

//Grey

/datum/uplink_item/racial/agent_belt
	name = "Пояс абдуктора"
	desc = "Пояс с инструментами, используемый абдукторами. Он включает в себя полный набор инопланетных инструментов."
	item = /obj/item/storage/belt/military/abductor/full
	cost = 16
	race = list(SPECIES_GREY)

/datum/uplink_item/racial/silencer
	name = "Глушитель абдуктора"
	desc = "Компактное устройство, предназначенное для выключения коммуникационного оборудования."
	item = /obj/item/abductor/silencer
	cost = 12
	race = list(SPECIES_GREY)

// DANGEROUS WEAPONS

/datum/uplink_item/dangerous
	category = "Очень заметное и опасное оружие"

/datum/uplink_item/dangerous/minotaur
	name = "Дробовик AS-12 \"Минотавр\""
	desc = "Современный дробовик с магнитным механизмом питания, способный стрелять очередями. В зависимости от типа барабана, он может вмещать от 12 до 24 патронов, \
			что делает его идеальным для ближнего боя. \
			Обладает большим разнообразием боеприпасов, выбор которых во многом определяет эффективность дробовика и стиль ведения боя."
	item = /obj/item/gun/projectile/automatic/shotgun/minotaur
	cost = 80
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/dangerous/pistol
	name = "Пистолет FK-69 \"Стечкин\""
	desc = "Полностью заряженный пистолет, оснащённый магазином на 8 патронов калибра 10 мм. Обладает большим разнообразием боеприпасов. \
			Крайне компактный пистолет, который легко помещается в карман. Совместим с глушителем."
	item = /obj/item/gun/projectile/automatic/pistol
	cost = 20

/datum/uplink_item/dangerous/revolver
	name = "Револьвер Синдиката .357"
	desc = "Полностью заряженный револьвер, оснащённый барабаном на 7 патронов \"Магнум\" .357 калибра."
	item = /obj/item/gun/projectile/revolver
	cost = 50
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 50

/datum/uplink_item/dangerous/deagle
	name = "Пистолет Desert Eagle"
	desc = "Легендарный пистолет огромной мощности с магазином на 7 патронов калибра .50AE."
	item = /obj/item/gun/projectile/automatic/pistol/deagle
	cost = 50
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/dangerous/uzi
	name = "Пистолет-пулемёт Uzi"
	desc = "Полностью заряженный лёгкий пистолет-пулемёт, оснащённый магазином на 32 патрона калибра 9 мм. \
			Имеет два режима стрельбы: полуавтоматический и с отсечкой по 4 патрона. Совместим с глушителем."
	item = /obj/item/gun/projectile/automatic/mini_uzi
	cost = 60
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/dangerous/smg
	name = "Пистолет-пулемёт C-20r"
	desc = "Полностью заряженный пистолет-пулемёт, оснащённый магазином на 20 патронов .45 калибра. \
			Имеет два режима стрельбы: полуавтоматический и с отсечкой по 2 патрона. Совместим с глушителем."
	item = /obj/item/gun/projectile/automatic/c20r
	cost = 70
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 40

/datum/uplink_item/dangerous/carbine
	name = "Карабин М-90gl"
	desc = "Полностью заряженный карабин, оснащённый магазином калибра 5.56 мм на 30 патронов. \
			Cовместим с глушителем. Имеет подстольный гранатомет под снаряды калибра 40 мм."
	item = /obj/item/gun/projectile/automatic/m90
	cost = 80
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 50

/datum/uplink_item/dangerous/machinegun
	name = "Ручной пулемёт L6 SAW"
	desc = "Полностью заряженный ручной пулемёт с ленточным питанием, оснащённый магазином на 50 патронов калибра 5.56x45 мм. \
			Прекрасно подойдёт для уничтожения живой силы или поддержки пехоты. Требует использования обоих рук для стрельбы."
	item = /obj/item/gun/projectile/automatic/l6_saw
	cost = 175
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/dangerous/rapid
	name = "Перчатки \"Полярная Звезда\""
	desc = "Позволяют владельцу наносить удары руками с невероятной скоростью."
	item = /obj/item/clothing/gloves/fingerless/rapid
	cost = 16

/datum/uplink_item/dangerous/sniper
	name = "Снайперская винтовка Bubz FX1000"
	desc = "Полностью заряженная винтовка со снайперским прицелом, оснащённая магазином на 5 патронов .50 калибра. Совместима с глушителем. \
			Требует использования обоих рук для стрельбы. Обладает огромной убойной силой и бронепробитием в зависимости от типа патрона. \
			Будьте уверены, она не оставит вас равнодушными, а ваши ТК будут потрачены с пользой! Невероятная мощь Синдиката!"
	item = /obj/item/gun/projectile/automatic/sniper_rifle/syndicate
	cost = 100
	surplus = 25
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/dangerous/sniper_compact //For when you really really hate that one guy.
	name = "Компактная снайперская винтовка Bubz Mini"
	desc = "Полностью заряженная компактная версия оперативной снайперской винтовки без прицела, оснащённая магазином на 4 патрона .50 калибра. \
			У неё большая убойная сила, но количество патронов ограничено."
	item = /obj/item/gun/projectile/automatic/sniper_rifle/compact
	cost = 40
	surplus = 0
	can_discount = FALSE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/dangerous/crossbow
	name = "Энергетический арбалет"
	desc = "Он настолько компактный, что легко помещается в карман. Стрелы арбалета содержат токсин, который на короткое время ослабляет цель и наносит ей повреждения. \
			Перезарядка происходит автоматически."
	item = /obj/item/gun/energy/kinetic_accelerator/crossbow
	cost = 48
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 50

/datum/uplink_item/dangerous/flamethrower
	name = "Огнемёт"
	desc = "Оснащён канистрой плазмы, украденной с одной из станций Nanotrasen. \
			Идеальное для борьбы с живой силой в узких пространствах. Используйте с осторожностью!"
	item = /obj/item/flamethrower/full/tank
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 40

/datum/uplink_item/dangerous/sword
	name = "Энергетический меч"
	desc = "Оружие с лезвием, сотканным из чистой энергии. Достаточно компактен, чтобы его можно было носить в кармане в сложенном виде. \
			При активации издаёт громкий характерный звук."
	item = /obj/item/melee/energy/sword/saber
	cost = 40

/datum/uplink_item/dangerous/powerfist
	name = "Силовой кулак"
	desc = "Представляет собой металлическую перчатку со встроенным поршнем, который приводится в действие с помощью баллона с газом. \
			При ударе по цели поршень выдвигается вперед, нанося мощный урон. С помощью гаечного ключа на поршневом клапане вы можете регулировать количество газа, \
			используемого для удара. Это позволит наносить дополнительный урон и поражать цели на более дальних расстояниях. \
			Отвертка используется для извлечения прикреплённых баллонов."
	item = /obj/item/melee/powerfist
	cost = 18

/datum/uplink_item/dangerous/chainsaw
	name = "Бензопила"
	desc = "Великолепный инструмент, который с лёгкостью распиливает деревья... \
			Оснащена невероятно удобной рукоятью, которая обеспечивает надёжное удержание и исключает риск случайного выронить её во время работы."
	item = /obj/item/twohanded/chainsaw
	cost = 60

/datum/uplink_item/dangerous/rapier
	name = "Рапира Синдиката"
	desc = "Изящная рапира из пластитана с алмазным наконечником, покрытым особым нокаутирующим ядом. \
			Поставляется в ножнах и способна пробить практически любую защиту. \
			Однако из-за внушительных размеров клинка и ножен, это оружие сразу выделяется как исключительно опасное."
	item = /obj/item/storage/belt/rapier/syndie
	cost = 40

/datum/uplink_item/dangerous/commando_kit
	name = "Набор для ножевого боя"
	desc = "Коробка, наполненная ароматами пороха, напалма и дешёвого виски, хранит в себе всё необходимое для выживания в суровых условиях."
	item = /obj/item/storage/box/syndie_kit/commando_kit
	cost = 33
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/dangerous/foamsmg
	name = "Игрушечный пистолет-пулемёт \"Донксофт\" C-20r"
	desc = "Полностью заряженный игрушечный пистолет-пулемёт, оснащённый магазином на 20 усиленных пенных патронов. \
			Предназначен для выведения из строя цели, не причиняя ей вреда. \
			Имеет два режима стрельбы: полуавтоматический и с отсечкой по 2 патрона."
	item = /obj/item/gun/projectile/automatic/c20r/toy
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/dangerous/foammachinegun
	name = "Игрушечный ручной пулемёт \"Донксофт\" L6 SAW"
	desc = "Полностью заряженный игрушечный пулемёт с ленточным питанием, оснащённый магазином на 50 усиленных пенных патронов. \
			Предназначен для выведения из строя цели, не причиняя ей вреда. \
			Способен ненадолго вывести цель из строя всего одним залпом. Требует использования обоих рук для стрельбы."
	item = /obj/item/gun/projectile/automatic/l6_saw/toy
	cost = 50
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/dangerous/guardian
	name = "Голопаразиты"
	desc = "При введении вызывает паразитическую сущность-наномашину, известную, как голопаразит. Хотя голопаразиты и обладают удивительной способностью выполнять почти \
			сверхъестественные действия, используя светочувствительные голограммы и наномашины, они не могут существовать без органического хозяина, \
			который служит им домом и источником энергии. Голопаразиты не способны к синергии с генокрадами и вампирами."
	item = /obj/item/storage/box/syndie_kit/guardian
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	cost = 69
	refund_path = /obj/item/guardiancreator/tech/choose
	refundable = TRUE
	can_discount = TRUE

// SUPPORT AND MECHAS

/datum/uplink_item/support
	category = "Поддержка и механизированные экзоскелеты"
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/support/gygax
	name = "Экзоскелет \"Gygax\""
	desc = "Модернизированный экзоскелет \"Gygax\", созданный для нужд Синдиката, оснащён следующими модулями: \
			LBX AC 11 \"Ram\", броня для ближнего и дальнего боя, дроид-ремонтник, маневровые двигатели, аккумулятор ёмкостью 40кВт."
	item = /obj/mecha/combat/gygax/dark/loaded
	cost = 400

/datum/uplink_item/support/rover
	name = "Экзоскелет \"Rover\""
	desc = "Модернизированный экзоскелет \"Durand\", созданный для нужд Синдиката, оснащён следующими модулями: \
			AC 2 \"Special\", G.M. Ion Shotgun, броня для дальнего боя, дроид-ремонтник, маневровые двигатели, аккумулятор ёмкостью 40кВт. \
			Обладает способностью создавать энергетические барьеры, преодолеть которые могут лишь члены Синдиката."
	item = /obj/mecha/combat/durand/rover/loaded
	cost = 500

/datum/uplink_item/support/mauler
	name = "Экзоскелет \"Маулер\""
	desc = "Модернизированный экзоскелет \"Mauler\", созданный для нужд Синдиката, оснащён следующими модулями: \
			AC 2 \"Special\", LBX AC 10 \"Scattershot\", Пусковая ракетная установка SRM-8, броня для дальнего боя, \
			дроид-ремонтник, маневровые двигатели, аккумулятор с бесконечной ёмкостью. Оснащён системой прицеливания и дымогенератором."
	item = /obj/mecha/combat/marauder/mauler/loaded
	cost = 700

/datum/uplink_item/support/reinforcement
	name = "Подкрепление Синдиката"
	desc = "Пригласите ещё одного члена команды. У него не будет с собой никакого снаряжения, поэтому вам нужно сохранить несколько телекристаллов, чтобы вооружить его."
	item = /obj/item/antag_spawner/nuke_ops
	refund_path = /obj/item/antag_spawner/nuke_ops
	cost = 100
	refundable = TRUE
	can_discount = FALSE

/datum/uplink_item/support/reinforcement/assault_borg
	name = "Штурмовой робот Синдиката"
	desc = "Создан и запрограммирован на уничтожение всех, кто не имеет отношения к Синдикату. \
			Его арсенал включает самозарядный пулемёт LMG, работающий только в полуавтоматическом режиме стрельбы, \
			гранатомет на 6 зарядов и энергетический меч. Дополнительное снаряжение включает в себя EMAG, пинпоинтер, флешер, огнетушитель и лом."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/assault
	refund_path = /obj/item/antag_spawner/nuke_ops/borg_tele/assault
	cost = 325

/datum/uplink_item/support/reinforcement/medical_borg
	name = "Медицинский робот Синдиката"
	desc = "Обладает ограниченным наступательным потенциалом, но с лихвой компенсирует его возможностями поддержки. \
			Его арсенал включает нанитовый гипоспрей, медицинскую лучевую пушку, боевой дефибриллятор и полный хирургический набор, \
			а также сумку для хранения органов, благодаря которой он способен проводить операции не хуже гуманоида. \
			Дополнительное снаряжение включает в себя EMAG, пинпоинтер, флешер, огнетушитель и лом."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/medical
	refund_path = /obj/item/antag_spawner/nuke_ops/borg_tele/medical
	cost = 175

/datum/uplink_item/support/reinforcement/saboteur_borg
	name = "Саботажный робот Синдиката"
	desc = "Усовершенствованный инженерный робот, оснащённый модулем скрытности. Благодаря маскировочному проектору \"Хамелеон\" он способен принимать облик \
			обычного инженерного робота со станции. Его арсенал включает энергетический меч и инженерное оборудование. \
			Дополнительное снаряжение включает в себя EMAG, пинпоинтер, флешер и огнетушитель, а также модуль тепловизионного зрения."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	refund_path = /obj/item/antag_spawner/nuke_ops/borg_tele/saboteur

// Ammunition

/datum/uplink_item/ammo
	category = "Боеприпасы"
	surplus = 40

/datum/uplink_item/ammo/pistol
	name = "\"Стечкин\" — 2 магазина 10 мм"
	desc = "Два магазина на 8 стандартных патронов калибра 10 мм. Эти патроны примерно в два раза менее эффективны, чем патроны .357 калибра."
	item = /obj/item/storage/box/syndie_kit/pistol_ammo
	cost = 5

/datum/uplink_item/ammo/pistolap
	name = "\"Стечкин\" — магазин 10 мм (Бронебойные)"
	desc = "Магазин на 8 бронебойных патронов калибра 10 мм. Эти патроны наносят немного меньше повреждений, чем стандартные, но обладают высокой пробивной силой."
	item = /obj/item/ammo_box/magazine/m10mm/ap
	cost = 5

/datum/uplink_item/ammo/pistolfire
	name = "\"Стечкин\" — магазин 10 мм (Зажигательные)"
	desc = "Магазин на 8 зажигательных патронов калибра 10 мм. Эти патроны поджигают цель при попадании."
	item = /obj/item/ammo_box/magazine/m10mm/fire
	cost = 5

/datum/uplink_item/ammo/pistolhp
	name = "\"Стечкин\" — магазин 10 мм (Экспансивные)"
	desc = "Магазин на 8 экспансивных патронов калибра 10 мм. Эти патроны наносят намного больше повреждений, чем стандартные, но они совершенно бесполезны против брони."
	item = /obj/item/ammo_box/magazine/m10mm/hp
	cost = 5

/datum/uplink_item/ammo/bullbuck
	name = "Барабан 12g — \"Картечь\""
	desc = "Барабан на 12 патронов картечи калибра 12g. Отлично подходит для ближней дистанции."
	item = /obj/item/ammo_box/magazine/m12g
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bulldragon
	name = "Барабан 12g — \"Дыхание дракона\""
	desc = "Барабан на 12 патронов \"Дыхание дракона\" калибра 12g. Каждый снаряд содержит 4 поражающих элемента, которые при попадании поджигают цель."
	item = /obj/item/ammo_box/magazine/m12g/dragon
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bullflechette
	name = "Барабан 12g — \"Флешетта\""
	desc = "Барабан на 12 патронов \"Флешетта\" калибра 12g. В отличие от картечи, у этих дробинок более узкая траектория полёта. Они обладают бронебойным действием."
	item = /obj/item/ammo_box/magazine/m12g/flechette
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bullterror
	name = "Барабан 12g — \"Биотеррор\""
	desc = "Барабан на 12 патронов \"Биотеррор\" калибра 12g. Эти снаряды наносят повреждения за счёт токсинов и радиации."
	item = /obj/item/ammo_box/magazine/m12g/bioterror
	cost = 15
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bullmeteor
	name = "Барабан 12g — \"Метеорит\""
	desc = "Барабан на 12 патронов \"Метеорит\" калибра 12g. Каждый выстрел отбрасывает цель на три тайла и на некоторое время оглушает её. \
			С их помощью можно выбить даже шлюз."
	item = /obj/item/ammo_box/magazine/m12g/breach
	cost = 25
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bull_XLbuck
	name = "Расширенный барабан 12g — \"Картечь\""
	desc = "Расширенный барабан на 24 патронов картечи калибра 12g. Отлично подходит для ближней дистанции."
	item = /obj/item/ammo_box/magazine/m12g/XtrLrg
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bull_XLflechette
	name = "Расширенный барабан 12g — \"Флешетта\""
	desc = "Расширенный барабан на 24 патронов \"Флешетта\" калибра 12g. \
			В отличие от картечи, у этих дробинок более узкая траектория полёта. Они обладают бронебойным действием."
	item = /obj/item/ammo_box/magazine/m12g/XtrLrg/flechette
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bull_XLdragon
	name = "Расширенный барабан 12g — \"Дыхание дракона\""
	desc = "Расширенный барабан на 24 патронов \"Дыхание дракона\" калибра 12g. Каждый снаряд содержит 4 поражающих элемента, которые при попадании поджигают цель."
	item = /obj/item/ammo_box/magazine/m12g/XtrLrg/dragon
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bulldog_ammobag
	name = "Барабан 12g — сумка"
	desc = "Сумка, содержащая 8 барабанов на 12 патронов калибра 12g \"Картечь\" и 1 барабан \"Дыхание дракона\"."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/shotgun
	cost = 60 // normally 90
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bulldog_XLmagsbag
	name = "Расширенный барабан 12g — сумка"
	desc = "Сумка, содержащая 3 расширенных барабана на 24 патронов калибра 12g: \"Картечь\", \"Дыхание дракона\", \"Флешетта\"."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/shotgunXLmags
	cost = 45 // normally 90
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/uzi
	name = "Пистолет-пулемёт Uzi — магазин 9 мм"
	desc = "Магазин на 30 патронов калибра 9 мм."
	item = /obj/item/ammo_box/magazine/uzim9mm
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/uzi_ammobag
	name = "Пистолет-пулемёт Uzi — сумка с магазинами 9 мм"
	desc = "Сумка, содержащая 10 магазинов на 30 патронов калибра 9 мм. Для тех, кто идёт на серьёзное дело."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/uzi
	cost = 70 // normally 100
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/smg
	name = "Пистолет-пулемёт C-20r — магазин .45"
	desc = "Магазин на 20 патронов .45 калибра. \
			Эти патроны обладают сильным останавливающим действием, способным сбить с ног большинство целей, однако они не наносят серьёзных повреждений."
	item = /obj/item/ammo_box/magazine/smgm45
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/smg_ammobag
	name = "Пистолет-пулемёт C-20r — сумка с магазинами .45"
	desc = "Сумка, содержащая 10 магазинов на 20 патронов .45 калибра."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/smg
	cost = 70 // normally 100
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/carbine
	name = "Карабин М-90gl — магазин 5.56 мм"
	desc = "Магазин на 30 патронов калибра 5.56 мм. \
			Эти патроны не обладают достаточной ударной силой, чтобы сбить с ног, но наносят серьёзные повреждения."
	item = /obj/item/ammo_box/magazine/m556
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/a40mm
	name = "Карабин М-90gl — коробка гранат 40 мм"
	desc = "Коробка на 4 осколочно-фугасные гранаты калибра 40 мм, предназначенными для подствольного гранатомёта."
	item = /obj/item/ammo_box/a40mm
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/carbine_ammobag
	name = "Карабин М-90gl — сумка с магазинами 5.56 мм"
	desc = "Сумка, содержащая 9 магазинов на 30 патронов калибра 5.56 мм и 1 коробку на 4 осколочно-фугасных гранат калибра 40 мм."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/carbine
	cost = 90 // normally 120
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/machinegun
	name = "Ручной пулемёт L6 SAW — магазин 5.56x45 мм"
	desc = "Магазин на 50 патронов калибра 5.56x45 мм."
	item = /obj/item/ammo_box/magazine/mm556x45
	cost = 50
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/ammo/LMG_ammobag
	name = "Ручной пулемёт L6 SAW — сумка с магазинами 5.56x45 мм"
	desc = "Сумка, содержащая 5 магазинов на 50 патронов калибра 5.56x45 мм. И помните, ни слова на общесолнечном."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/lmg
	cost = 200 // normally 250
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/sniper
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/sniper/basic
	name = "Снайперская винтовка Bubz FX1000 — магазин .50 \"Стандартный\""
	desc = "Магазин на 5 стандартных патронов .50 калибра. Эти патроны способны с лёгкостью оторвать голову или конечность."
	item = /obj/item/ammo_box/magazine/sniper_rounds
	cost = 20

/datum/uplink_item/ammo/sniper/soporific
	name = "Снайперская винтовка Bubz FX1000 — магазин .50 \"Снотворный\""
	desc = "Магазин на 5 усыпляющих патронов .50 калибра. Снотворное действует мгновенно, и его нельзя обнаружить с помощью сканирующих устройств. \
			\"Иди поспи, реально. Иди приляг и поспи.\""
	item = /obj/item/ammo_box/magazine/sniper_rounds/soporific
	cost = 15

/datum/uplink_item/ammo/sniper/explosive
	name = "Снайперская винтовка Bubz FX1000 — магазин .50 \"Разрывной\""
	desc = "Магазин на 5 разрывных патронов .50 калибра. При попадании в цель пуля взрывается, нанося серьёзный урон."
	item = /obj/item/ammo_box/magazine/sniper_rounds/explosive
	cost = 30

/datum/uplink_item/ammo/sniper/penetrator
	name = "Снайперская винтовка Bubz FX1000 — магазин .50 \"Бронебойный\""
	desc = "Магазин на 5 бронебойных патронов .50 калибра. В отличие от стандартных патронов, эти наносят чуть меньше урона и не способны отрывать конечности. \
			Однако их высокая пробивная сила позволяет им легко проходить сквозь препятствия и броню."
	item = /obj/item/ammo_box/magazine/sniper_rounds/penetrator
	cost = 25

/datum/uplink_item/ammo/bioterror
	name = "Набор шприцов \"Биотеррор\""
	desc = "Коробка, содержащая семь шприцов, каждый из которых содержит смесь химических веществ: нейротоксин, капулеттий плюс и тиопентал натрия. \
			Для эффективного использования рекомендуется применять шприцемёт."
	item = /obj/item/storage/box/syndie_kit/bioterror
	cost = 25
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/toydarts
	name = "Коробка усиленных пенных патронов"
	desc = "Коробка, содержащая 40 усиленных пенных патронов, предназначенных для перезарядки игрушечного оружия от компании \"Донксофт\". \
			Эти патроны предназначены для того, чтобы вывести из строя цель, не причиняя ей вреда."
	item = /obj/item/ammo_box/foambox/riot
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/ammo/compact
	name = "Компактная снайперская винтовка Bubz Mini — магазин .50 \"Стандартный\""
	desc = "Магазин на 4 стандартных патронов .50 калибра."
	item = /obj/item/ammo_box/magazine/sniper_rounds/compact
	cost = 5
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/revolver
	name = "Револьвер Синдиката .357 — 2 сменных барабана"
	desc = "Коробка, содержащая 2 сменных барабана, каждый из которых вмещает 7 патронов \"Магнум\" .357 калибра."
	item = /obj/item/storage/box/syndie_kit/revolver_ammo
	cost = 5
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/deagle
	name = "Пистолет Desert Eagle — магазин .50AE"
	desc = "Магазин на 7 патронов .50AE калибра. Убей их всех."
	item = /obj/item/ammo_box/magazine/m50
	cost = 5
	surplus = 0

/datum/uplink_item/ammo/rocketHE
	name = "Реактивный гранатомёт — ракета 84 мм (HE)"
	desc = "Осколочно-фугасная ракета для реактивного гранатомёта PML-9. Этот снаряд может вызвать мощный взрыв, \
			который способен причинить значительный ущерб живой силе и конструкциям. \
			Гарантированно поразит вашу цель или мы вернёт вам деньги!"
	item = /obj/item/ammo_casing/caseless/rocket
	cost = 40
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/rocketHEDP
	name = "Реактивный гранатомёт — ракета 84 мм (HEDP)"
	desc = "Осколочно-фугасная ракета двойного назначения ракета для реактивного гранатомёта PML-9. Она обладает высокой проникающей способностью, \
			что делает её идеальным оружием для борьбы с экзоскелетами и роботами на станции. Ракета способна уничтожить цель с одного выстрела. \
			Гарантированно поразит вашу цель или мы вернёт вам деньги!"
	item = /obj/item/ammo_casing/caseless/rocket/hedp
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/knives_kit
	name = "Набор метательных ножей"
	desc = "Коробка, содержащая 7 метательных ножей. Ощутите себя в роли Рэмбо!"
	item = /obj/item/storage/box/syndie_kit/knives_kit
	cost = 4
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Незаметное и тихое оружие"

/datum/uplink_item/stealthy_weapons/garrote
	name = "Гаррота"
	desc = "Отрезок скрученной проволоки, зажатый между двумя деревянными рукоятками, идеальное оружие для осторожного убийцы. \
			При использовании сзади оно мгновенно захватывает шею жертвы, лишая её возможности говорить, и приводит к быстрой асфиксии. \
			Очевидно, что невозможно задушить того, кому не нужно дышать."
	item = /obj/item/twohanded/garrote
	cost = 20

/datum/uplink_item/stealthy_weapons/martialarts
	name = "Свиток боевого искусства \"Путь Спящего Карпа\""
	desc = "Этот свиток хранит в себе тайны древнейшего боевого искусства, известного как \"Путь Спящего Карпа\". \
			Овладев его секретами, вы научитесь мастерски отражать снаряды, выпущенные из любого оружия дальнего боя, используя только рукопашные техники. \
			Однако, чтобы освоить этот путь, вам придётся полностью отказаться от применения любого оружия дальнего боя. Обратите внимание, что техники этого \
			искусства не будут эффективны, если вы зависимы от каких-либо препаратов. Недоступно для изучения генокрадам и вампирам."
	item = /obj/item/sleeping_carp_scroll
	cost = 80
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

	refundable = TRUE
	can_discount = FALSE

/datum/uplink_item/stealthy_weapons/cqc
	name = "Руководство по \"Технике ближнего боя\" (CQC)"
	desc = "Это одноразовое руководство по тактике ближнего боя, также известное как CQC. \
			Оно предназначено для того, чтобы быстро и эффективно нейтрализовать противников с помощью захватов и сокрушительных ударов. \
			Оно не накладывает ограничений на использование оружия, однако не может быть использовано вместе с перчатками \"Полярная Звезда\"."
	item = /obj/item/CQC_manual
	cost = 50
	can_discount = FALSE

/datum/uplink_item/stealthy_weapons/mr_chang
	name = "Техника агрессивного маркетинга Мистера Чанга"
	desc = "Этот набор был любезно предоставлен нам корпорацией Мистера Чанга и является абсолютно законным. \
			В набор входит одноразовый журнал, обучающий пользователя агрессивным приемам маркетинга, а также стильная одежда. \
			Освоив описанные в журнале приёмы, вы научитесь без труда воровать кошельки, использовать деньги как оружие и по-новому ощутить вкус еды Мистера Чанга."
	item = /obj/item/storage/box/syndie_kit/mr_chang_technique
	cost = 18

/datum/uplink_item/stealthy_weapons/cameraflash
	name = "Фотокамера-флешер"
	desc = "Флешер, который выглядит как фотоаппарат, обладает всеми функциями обычного флешера, но при этом имеет несколько преимуществ. \
			Он оснащён самозарядным аккумулятором, что исключает возможность полного разряда. Устройство рассчитано на 5 зарядов."
	item = /obj/item/flash/cameraflash
	cost = 6

/datum/uplink_item/stealthy_weapons/throwingweapons
	name = "Набор метательного оружия"
	desc = "В коробке находятся 5 сюрикенов и 2 усиленные болы, которые были созданы в рамках древних боевых искусств, практикуемых на Земле. \
			Эти метательные орудия крайне эффективны. Болы способны сбивать с ног, а сюрикены могут с лёгкостью вонзаться в конечности, \
			нанося серьёзные ранения."
	item = /obj/item/storage/box/syndie_kit/throwing_weapons
	cost = 3

/datum/uplink_item/stealthy_weapons/edagger
	name = "Энергетический кинжал"
	desc = "Энергетический кинжал, который в неактивном состоянии выглядит и функционирует как обычная ручка."
	item = /obj/item/pen/edagger
	cost = 7

/datum/uplink_item/stealthy_weapons/sleepy_pen
	name = "Усыпляющая ручка"
	desc = "Гипоспрей, замаскированный под обычную ручку, содержит 100 единиц кетамина. \
			При использовании на цели он незаметно вводит 50 единиц препарата. Может быть повторно заправлен любыми веществами."
	item = /obj/item/pen/sleepy
	cost = 36
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_weapons/foampistol
	name = "Игрушечный пистолет \"Донксофт\" FK-69 \"Стечкин\""
	desc = "Полностью заряженный игрушечный пистолет компании \"Донксофт\", оснащённый магазином на 8 усиленных пенных патронов. \
			Как и его огнестрельный аналог, этот пистолет очень компактный и легко помещается в карман. \
			Предназначен для выведения из строя цели, не причиняя ей вреда."
	item = /obj/item/gun/projectile/automatic/toy/pistol/riot
	cost = 12
	surplus = 10

/datum/uplink_item/stealthy_weapons/false_briefcase
	name = "Портфель с фальшивым дном"
	desc = "Модифицированный портфель, позволяющий спрятать оружие внутри, что даёт возможность стрелять, не вынимая его. \
			Для того чтобы использовать портфель в качестве тайника, необходимо открутить двойное дно с помощью отвёртки, поместить оружие внутрь и снова закрутить дно. \
			При ближайшем рассмотрении его можно отличить по утолщённому дну."
	item = /obj/item/storage/briefcase/false_bottomed
	cost = 1

/datum/uplink_item/stealthy_weapons/soap
	name = "Мыло Синдиката"
	desc = "Устрашающе красный кусок специального мыла, созданного Синдикатом, предназначен для быстрого удаления пятен крови и других улик, чтобы скрыть убийства. \
			Его можно использовать и как оружие, например, бросить кому-то под ноги, чтобы он поскользнулся."
	item = /obj/item/soap/syndie
	cost = 1
	surplus = 50

/datum/uplink_item/stealthy_weapons/tape
	name = "Плотная изолента Синдиката"
	desc = "Чрезвычайно прочная клейкая лента. Она позволяет быстро заклеить рот жертве, при этом моментально сбивая маску. \
			Увеличенный размер ленты позволяет использовать её до 40 раз."
	item = /obj/item/stack/tape_roll/thick
	cost = 7
	surplus = 50

/datum/uplink_item/stealthy_weapons/dart_pistol
	name = "Набор дротикового пистолета"
	desc = "Это миниатюрная версия обычного шприцемёта. Он не издаёт громких звуков при выстреле и легко помещается в кармане. \
			В комплекте с ним идут три шприца, содержащие: Капулеттий+, Зарин и Панкуроний."
	item = /obj/item/storage/box/syndie_kit/dart_gun
	cost = 18
	surplus = 50
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_weapons/RSG
	name = "Барабанный шприцемёт"
	desc = "В барабане можно разместить шесть шприцов, что позволяет быстро и эффективно поражать цели. \
			Прекрасно подходит для использования со шприцами \"Биотеррор\"."
	item = /obj/item/gun/syringe/rapidsyringe
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_weapons/silencer
	name = "Универсальный глушитель"
	desc = "Обеспечивает повышенную скрытность, заглушая звуки выстрелов."
	item = /obj/item/suppressor
	cost = 4
	surplus = 10

/datum/uplink_item/stealthy_weapons/dehy_carp
	name = "Дегидрированный Космический карп"
	desc = "Просто добавьте воды, чтобы обзавестись ручным карпом, который будет настроен агрессивно по отношению ко всем, кроме вас. \
			Он замаскирован под игрушечного карпа. Не забудьте обнять карпа перед тем, как налить воду, иначе он не признает вас своим хозяином."
	item = /obj/item/toy/carpplushie/dehy_carp
	cost = 7

// GRENADES AND EXPLOSIVES

/datum/uplink_item/explosives
	category = "Гранаты и взрывчатка"

/datum/uplink_item/explosives/plastic_explosives
	name = "Пластичная взрывчатка C-4"
	desc = "Это пластичная взрывчатка малой мощности, которую можно прикрепить к любому объекту или поверхности. \
			Она оснащена настраиваемым таймером, с минимальным временем задержки в 10 секунд."
	item = /obj/item/grenade/plastic/c4
	cost = 2

/datum/uplink_item/explosives/plastic_explosives_pack
	name = "Набор пластичной взрывчатки C-4"
	desc = "Коробка, содержащая 5 единиц пластичной взрывчатки C-4 по сниженной цене."
	item = /obj/item/storage/box/syndie_kit/c4
	cost = 8

/datum/uplink_item/explosives/c4bag
	name = "Сумка пластичной взрывчатки C-4"
	desc = "Сумка, содержащая 10 единиц пластичной взрывчатки C-4 по сниженной цене."
	item = /obj/item/storage/backpack/duffel/syndie/c4
	cost = 40 //20% discount!
	can_discount = FALSE
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/breaching_charge
	name = "Пластичная взрывчатка X-4"
	desc = "Это пластичная взрывчатка высокой мощности, которую можно прикрепить к любому объекту или поверхности. \
			При установке на шлюз или стену взрыв будет направлен в противоположную сторону от места установки. \
			Взрыв обязательно приведёт к разгерметизации. Она оснащена настраиваемым таймером, с минимальным временем задержки в 10 секунд."
	item = /obj/item/grenade/plastic/x4
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/x4bag
	name = "Сумка пластичной взрывчатки X-4"
	desc = "Сумка, содержащая 3 единицы пластичной взрывчатки X-4 по сниженной цене."
	item = /obj/item/storage/backpack/duffel/syndie/x4
	cost = 20
	can_discount = FALSE
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/t4
	name = "Термитная взрывчатка T-4"
	desc = "Взрывчатка повышенной мощности с направленным действием. Эффективно разрушает даже укреплённые стены, но не шлюзы и двери."
	item = /obj/item/grenade/plastic/x4/thermite
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/t4_pack
	name = "Набор термитной взрывчатки T-4"
	desc = "Коробка, содержащая 3 единицы пластичной взрывчатки T-4 по сниженной цене."
	item = /obj/item/storage/box/syndie_kit/t4P
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/syndicate_bomb
	name = "Бомба Синдиката"
	desc = "Бомба Синдиката, оснащенная настраиваемым таймером, с минимальным временем задержки в 90 секунд. При заказе бомбы вы получите небольшой маячок, \
			который телепортирует бомбу к вам при активации. Бомбу можно прикрутить к полу гаечным ключом. После того как таймер будет запущен, \
			она начнёт издавать громкий звук, который будет усиливаться по мере приближения взрыва. Если бомбу обнаружат вовремя, её можно будет обезвредить. \
			Взрыв нанесёт серьёзный ущерб окружению."
	item = /obj/item/radio/beacon/syndicate/bomb
	cost = 40
	surplus = 0
	can_discount = FALSE
	hijack_only = TRUE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/syndicate_bomb/nuke
	item = /obj/item/radio/beacon/syndicate/bomb
	cost = 55
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	hijack_only = FALSE

/datum/uplink_item/explosives/emp_bomb
	name = "ЭМИ-бомба"
	desc = "ЭМИ-бомба, оснащенная настраиваемым таймером, с минимальным временем задержки в 90 секунд. При заказе бомбы вы получите небольшой маячок, \
			который телепортирует бомбу к вам при активации. Бомбу можно прикрутить к полу гаечным ключом. После того как таймер будет запущен, \
			она начнёт издавать громкий звук, который будет усиливаться по мере приближения взрыва. Если бомбу обнаружат вовремя, её можно будет обезвредить. \
			На 2-3 минуты все электронные устройства в радиусе 36 тайлов будут полностью отключены."
	item = /obj/item/radio/beacon/syndicate/bomb/emp
	cost = 40
	surplus = 0
	can_discount = FALSE
	hijack_only = TRUE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/emp_bomb/nuke
	item = /obj/item/radio/beacon/syndicate/bomb/emp
	cost = 50
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	hijack_only = FALSE

/datum/uplink_item/explosives/syndicate_minibomb
	name = "Мини-бомба Синдиката"
	desc = "Довольно мощная граната с задержкой в 5 секунд."
	item = /obj/item/grenade/syndieminibomb
	cost = 30

/datum/uplink_item/explosives/rocketlauncher
	name = "Реактивный гранатомёт PML-9"
	desc = "Многоразовый реактивный гранатомёт, предварительно заряженный осколочно-фугасной ракетой калибра 84 мм (HE). \
			Характеристики могут различаться в зависимости от типа используемой ракеты (HE и HEDP). \
			На стволе можно увидеть надпись \"НТ в той стороне\" и стрелку, указывающую направление выстрела."
	item = /obj/item/gun/projectile/revolver/rocketlauncher
	cost = 50
	surplus = 0 // no way
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/rocketbelt
	name = "Пояс с ракетами калибра 84 мм"
	desc = "Пояс, заполненный ракетами для реактивного гранатомёта. \
			В комплект входят три 3 осколочно-фугасные ракеты и 3 осколочно-фугасные ракеты двойного назначения калибра 84 мм."
	item = /obj/item/storage/belt/rocketman
	cost = 175
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/detomatix
	name = "Подрывной картридж КПК"
	desc = "Картридж для вашего КПК. После установки вы сможете использовать его, чтобы попытаться отправить вирус на КПК других членов экипажа, чтобы их взорвать. \
			Однако есть риск, что вирус не сработает или взорвёт ваш собственный КПК. Попытки атаковать КПК других агентов не приведут к их детонации, \
			а вместо этого заряд вернётся к вам. Взрыв будет достаточно слабым, но он оглушит и может оторвать конечности."
	item = /obj/item/cartridge/syndicate
	cost = 30

/datum/uplink_item/explosives/pizza_bomb
	name = "Пицца-бомба"
	desc = "Коробка из-под пиццы, внутри которой приклеена бомба. \
			Откройте коробку и установите таймер, чтобы задать время, через которое бомба взорвётся при следующем открытии. Повторное открытие запустит таймер."
	item = /obj/item/pizza_bomb
	cost = 15
	surplus = 80

/datum/uplink_item/explosives/fraggrenade
	name = "Пояс боевых осколочных гранат"
	desc = "Пояс, содержащий 4 мощные боевые осколочные гранаты."
	item = /obj/item/storage/belt/grenade/frag
	cost = 10

/datum/uplink_item/explosives/grenadier
	name = "Пояс гренадера"
	desc = "Пояс, наполненный 26 разнообразными гранатами, включает в себя: 4 дымовых шашки, 2 ЭМИ гранаты, 4 глюонные гранаты, 1 кислотную гранату, \
			1 зариновую гранату, 2 плазменные гранаты, 10 боевых осколочных гранат и 2 мини-бомбы Синдиката."
	item = /obj/item/storage/belt/grenade/full
	cost = 125
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/manhacks
	name = "Граната доставки Потрошителей"
	desc = "Представляет собой устройство, в котором находятся 5 дегидратированных Потрошителей аналогично дегидратированным обезьянам, \
			которые после взрыва будут регидратированы небольшим резервуаром воды, содержащимся внутри гранаты. \
			Затем эти Потрошители будут нападать на всех, кто не является оперативником Синдиката."
	item = /obj/item/grenade/spawnergrenade/manhacks
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 35

/datum/uplink_item/explosives/atmosn2ogrenades
	name = "Усыпляющая газовая кластерная граната"
	desc = "Коробка, содержащая 2 кластерные гранаты наполненные газом N2O. \
			После активации газ быстро заполнит помещение и усыпит всех, кто не будет использовать маску с кислородным баллоном."
	item = /obj/item/storage/box/syndie_kit/atmosn2ogrenades
	cost = 18

/datum/uplink_item/explosives/atmosfiregrenades
	name = "Плазменная газовая кластерная граната"
	desc = "Коробка, содержащая 2 кластерные гранаты наполненные газообразной плазмой. \
			При активации высвобождает плазму, которая, воспламеняясь, уничтожает всё на своём пути."
	item = /obj/item/storage/box/syndie_kit/atmosfiregrenades
	hijack_only = TRUE
	cost = 50
	surplus = 0
	can_discount = FALSE

/datum/uplink_item/explosives/emp
	name = "Набор ЭМИ-гранат и ЭМИ-импланта"
	desc = "Коробка, содержащая две ЭМИ-гранаты и имплантер с ЭМИ-имплантом, имеющим два заряда."
	item = /obj/item/storage/box/syndie_kit/emp
	cost = 10

// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools
	category = "Предметы для маскировки и незаметной работы"

/datum/uplink_item/stealthy_tools/syndie_kit/counterfeiter_bundle
	name = "Набор для подделывания документов"
	desc = "Набор, оснащённый технологией \"Хамелеон\", предназначеный для подделки документов. В него входят штамп, \
			который может имитировать любые печати, и ручка, способная подделывать подписи. \
			С помощью этого набора можно легко подделать практически любой документ."
	cost = 2
	surplus = 35
	item = /obj/item/storage/box/syndie_kit/counterfeiter_bundle

/datum/uplink_item/stealthy_tools/chameleonflag
	name = "Флаг \"Хамелеон\""
	desc = "Флаг, оснащённый технологией \"Хамелеон\". Она позволяет изменять внешний вид флага. \
			В шесте имеется скрытый отсек, позволяющий разместить внутри гранату. После поджога флага граната взорвётся через некоторое время."
	item = /obj/item/flag/chameleon
	cost = 1
	surplus = 35

/datum/uplink_item/stealthy_tools/chamsechud
	name = "ИЛС СБ \"Хамелеон\""
	desc = "Украденный ИЛС сотрудников СБ, оснащённый технологией \"Хамелеон\". Она позволяет изменять внешний вид устройства, не нарушая его функциональность."
	item = /obj/item/clothing/glasses/hud/security/chameleon
	cost = 8

/datum/uplink_item/stealthy_tools/thermal
	name = "Тепловизионные очки \"Хамелеон\""
	desc = "Тепловизионные очки, оснащённые технологией \"Хамелеон\". Она позволяет изменять внешний вид устройства, не нарушая его функциональность. \
			Тепловизионные очки позволяют видеть источники тепла сквозь стены. Однако они создают повышенную чувствительность к вспышкам."
	item = /obj/item/clothing/glasses/chameleon/thermal
	cost = 20

/datum/uplink_item/stealthy_tools/traitor_belt
	name = "Пояс агента Синдиката"
	desc = "Пояс, который выглядит как обычный пояс для инструментов, но с увеличенными карманами. В них можно хранить любые маленькие предметы."
	item = /obj/item/storage/belt/military/traitor
	cost = 2
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/frame
	name = "Картридж П.О.Д.С.Т.А.В.А."
	desc = "Картридж для КПК, содержащий 5 вирусов, которые можно отправить на другие КПК. \
			После заражения, вирус создаст и откроет аплинк на КПК, отправляя вам код от него. В картридж можно зарядить ТК, которые будут отправлены вместе с вирусом. \
			Если на заражённом устройстве уже имеется аплинк, то код останется неизменным. Этот картридж представляет собой идеальный инструмент для проведения различных подстав."
	item = /obj/item/cartridge/frame
	cost = 16
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/agent_card
	name = "ID-карта агента Синдиката"
	desc = "Специальная ID-карта, которая позволяет в любой момент изменить её имя, профессию и внешний вид. \
			При использовании этой карты на другой, она копирует доступ, не удаляя старый. Чем больше различных карт вы просканируете, тем шире будет ваш доступ. \
			Кроме того позволяет запретить ИИ отслежить вас."
	item = /obj/item/card/id/syndicate
	cost = 10

/datum/uplink_item/stealthy_tools/chameleon
	name = "Набор одежды \"Хамелеон\""
	desc = "Комплект одежды, оснащённый технологией \"Хамелеон\", которая позволяет изменять её внешний вид. \
			Однако из-за несовершенства этой технологии обувь не обеспечивает защиту от скольжения. \
			В набор также входит дополнительный штамп \"Хамелеон\"."
	item = /obj/item/storage/box/syndie_kit/chameleon
	cost = 20

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Маскировочный \"Хамелеон\"-проектор"
	desc = "Проецирует изображение на пользователя, позволяя ему стать замаскированным под сканируемый объект. \
			Эффект сохраняется до тех пор, пока вы не выпустите проектор из рук. Однако в режиме маскировки вы не сможете свободно \
			передвигаться и взаимодействовать с окружающими предметами."
	item = /obj/item/chameleon
	cost = 26

/datum/uplink_item/stealthy_tools/camera_bug
	name = "Переносной монитор"
	desc = "Мобильное устройство, которое позволяет просматривать изображения с камер наблюдения, установленных на станции. \
			При переключении между камерами издаётся характерный звук."
	item = /obj/item/camera_bug
	cost = 3
	surplus = 90

/datum/uplink_item/stealthy_tools/dnascrambler
	name = "Шифратор ДНК"
	desc = "Одноразовый инъектор, позволяющий полностью изменить внешность. Это менее эффективная альтернатива карточке агента и набору одежды \"Хамелеон\"."
	item = /obj/item/dnascrambler
	cost = 10

/datum/uplink_item/stealthy_tools/smugglersatchel
	name = "Сумка контрабандиста"
	desc = "Сумка изготовлена особым образом, что позволяет ей помещаться между обшивкой станции и напольной плиткой. \
			Она прекрасно подходит для хранения украденных вещей. В комплект входят лом и плитка."
	item = /obj/item/storage/backpack/satchel_flat
	cost = 6
	surplus = 30

/datum/uplink_item/stealthy_tools/emplight
	name = "ЭМИ-фонарик"
	desc = "Небольшое ЭМИ устройство, замаскированное под фонарик. Можно использовать для выведения из строя гарнитур, камер и роботов. \
			Имеет 4 заряда, которые со временем восстанавливаются."
	item = /obj/item/flashlight/emp
	cost = 19
	surplus = 30

/datum/uplink_item/stealthy_tools/syndigaloshes
	name = "Ботинки с защитой от скольжения \"Хамелеон\""
	desc = "Ботинки, оснащённые технологией \"Хамелеон\", которая позволяет изменять их внешний вид. \
			Подошва покрыта специальным составом, который обеспечивает защиту от скольжения."
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 8
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/syndigaloshes/nuke
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 20
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/cutouts
	name = "Адаптивные картонные фигуры"
	desc = "Эти фигурки из картона покрыты тонким слоем материала, который предотвращает выцветание и делает изображения на них более реалистичными. \
			В коробке 3 фигурки, а также баллончик с краской для изменения их внешнего вида."
	item = /obj/item/storage/box/syndie_kit/cutouts
	cost = 1
	surplus = 20

/datum/uplink_item/stealthy_tools/clownkit
	name = "Набор внедрения \"ХОНК\""
	desc = "Комплект одежды, оснащённый технологией \"ХОНК\", для усиления комичности. \
			В набор входит стандартная одежда клоуна, клоунские магбутсы, противогаз \"Хамелеон\" и инъектор с геном комичности."
	item = /obj/item/storage/backpack/clown/syndie
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/stealthy_tools/chameleon_counter
	name = "Фальсификатор \"Хамелеон\""
	desc = "Коробка, содержащая 3 фальсификатора \"Хамелеон\". Эти устройства способны маскироваться под любой сканируемый объект. \
			Однако, они не отличаются стабильностью, и маскировка отключается примерно через 30 минут."
	item = /obj/item/storage/box/syndie_kit/chameleon_counter
	cost = 6

// Devices and Tools

/datum/uplink_item/device_tools
	category = "Девайсы и инструменты"

/datum/uplink_item/device_tools/emag
	name = "Криптографический считыватель"
	desc = "Представляет собой модифицированную ID-карту, также известную как ЕМАГ, которая способна активировать скрытые функции в электронных устройствах, \
			изменять их назначение и обходить механизмы безопасности."
	item = /obj/item/card/emag
	cost = 30 // Brainrot allowed

/datum/uplink_item/device_tools/access_tuner
	name = "Тюнер доступа"
	desc = "Небольшое устройство, предназначенное для удаленного управления шлюзами. \
			Подключение занимает несколько секунд, после чего позволяет открывать/закрывать шлюзы, настраивать их скорость, переключать аварийный доступ."
	item = /obj/item/door_remote/omni/access_tuner
	cost = 15

/datum/uplink_item/device_tools/toolbox
	name = "Набор инструментов"
	desc = "Ящик, выполненный в зловещих чёрно-красных тонах, содержащий набор стандартных инструментов, изолированные перчатки и мультитул."
	item = /obj/item/storage/toolbox/syndicate
	cost = 3

/datum/uplink_item/device_tools/supertoolbox
	name = "Набор экспериментальных инструментов"
	desc = "Ящик, выполненный в зловещих чёрно-красных тонах, содержащий набор экспериментальных инструментов, боевые перчатки и стильные солнцезащитные очки."
	item = /obj/item/storage/toolbox/syndisuper
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/holster
	name = "Кобура"
	desc = "Надежно крепится к комбинезону, обеспечивая быстрый доступ к оружию нормального размера."
	item = /obj/item/clothing/accessory/holster
	cost = 2

/datum/uplink_item/device_tools/holster/knives
	name = "Кобура для ножей"
	desc = "Надежно крепится к комбинезону, позволяя носить с собой до 7 ножей."
	item = /obj/item/clothing/accessory/holster/knives
	cost = 2
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/webbing
	name = "Боевая разгрузка"
	desc = "Прочная разгрузка, созданная из ремней и пряжек, выполненных из синтетического хлопка. \
			Она оснащёна множеством карманов, куда можно сложить всё необходимое. Позволяет переносить дополнительно до 5 мелких предметов."
	item = /obj/item/clothing/accessory/storage/webbing
	cost = 2

/datum/uplink_item/device_tools/black_vest
	name = "Боевая разгрузка — чёрный жилет"
	desc = "Прочный чёрный жилет из синтетического хлопка, оснащённый множеством карманов, куда можно сложить всё необходимое. \
			Позволяет переносить дополнительно до 5 мелких предметов."
	item = /obj/item/clothing/accessory/storage/black_vest
	cost = 2

/datum/uplink_item/device_tools/brown_vest
	name = "Боевая разгрузка — коричневый жилет"
	desc = "Прочный коричневый жилет из синтетического хлопка, оснащённый множеством карманов, куда можно сложить всё необходимое. \
			Позволяет переносить дополнительно до 5 мелких предметов."
	item = /obj/item/clothing/accessory/storage/brown_vest
	cost = 2

/datum/uplink_item/device_tools/blackops_kit
	name = "Набор для секретных операций"
	desc = "Коробка с одеждой, предназначенной для проведения опасных секретных операций. В комплект входят: комбинезон, боевые перчатки и ботинки, боевая разгрузка, \
			бронежилет, штурмовой пояс, балаклава и очки ночного видения."
	item = /obj/item/storage/box/syndie_kit/blackops_kit
	cost = 8

/datum/uplink_item/device_tools/surgerybag
	name = "Сумка с хирургическими инструментами"
	desc = "Сумка Синдиката, содержащая полный набор хирургических инструментов, а также смирительную рубашку и намордник. \
			В отличие от обычных сумок, она отличается большей вместительностью и легкостью."
	item = /obj/item/storage/backpack/duffel/syndie/surgery
	cost = 7

/datum/uplink_item/device_tools/bonerepair
	name = "Экспериментальный инъектор с нанокальцием"
	desc = "Коробка, содержащая 1 инъектор и руководство по применению. \
			Препарат способствует заживлению любых внутренних повреждений, однако имеет побочные эффекты, такие как слабость, дезориентация и потеря сознания. \
			Не рекомендуется применять вместе со стимуляторами и наркотиками."
	item = /obj/item/storage/box/syndie_kit/bonerepair
	cost = 6

/datum/uplink_item/device_tools/syndicate_teleporter
	name = "Экспериментальный телепортер Синдиката"
	desc = "Портативное устройство, способное телепортировать пользователя на расстояние от 4 до 8 тайлов вперёд. \
			Будьте осторожны: если телепортироваться в стену, активируются защитные системы, которые попытаются переместить вас параллельно направлению телепортации. \
			Однако, если это не удастся, вы можете быть разорваны на мелкие кусочки. \
			Устройство имеет 4 заряда, которые со временем восполняются. Подвержно воздействию ЭМИ."
	item = /obj/item/storage/box/syndie_kit/teleporter
	cost = 44

/datum/uplink_item/device_tools/spai
	name = "Синдикатский Персональный ИИ (СПИИ)"
	desc = "Усовершенствованная версия обычного ПИИ. Он отличается большим объёмом памяти и наличием специальных программ, \
			позволяющих, например, удалённо управлять шлюзами, вводить лечебные препараты в организм, видеть сквозь стены и так далее."
	item = /obj/item/storage/box/syndie_kit/pai
	cost = 37
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	refundable = TRUE
	refund_path = /obj/item/paicard_upgrade/unused
	can_discount = FALSE

/datum/uplink_item/device_tools/thermal_drill
	name = "Дрель с усиленным сверлом"
	desc = "Устройство для взлома сейфов, оснащенное нанитовой системой обнаружения. \
			В случае обнаружения сотрудников службы безопасности рядом с местом взлома, активируются протоколы помощи взломщику, \
			восстанавливая его повреждения и выносливость. Время, необходимое для взлома, составляет 5 минут."
	item = /obj/item/thermal_drill/syndicate
	cost = 2
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/dthermal_drill
	name = "Дрель с усиленным алмазным сверлом"
	desc = "Устройство для взлома сейфов, оснащенное нанитовой системой обнаружения. \
			В случае обнаружения сотрудников службы безопасности рядом с местом взлома, активируются протоколы помощи взломщику, \
			восстанавливая его повреждения и выносливость. Время, необходимое для взлома, составляет 2 с половиной минуты."
	item = /obj/item/thermal_drill/diamond_drill/syndicate
	cost = 5
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/jackhammer
	name = "Отбойный молоток"
	desc = "Инструмент, используемый шахтёрами для дробления скал с помощью звукового удара. \
			Он может применяться для разрушения стен, даже укреплённых, и даже черепов."
	item = /obj/item/pickaxe/drill/jackhammer
	cost = 15

/datum/uplink_item/device_tools/pickpocketgloves
	name = "Перчатки карманника"
	desc = "Пара удобных перчаток, созданных специально для карманных краж. \
			С их помощью вы сможете легко и незаметно достать всё, до чего сможете дотянуться."
	item = /obj/item/clothing/gloves/color/black/thief
	cost = 30

/datum/uplink_item/device_tools/medkit
	name = "Боевая аптечка Синдиката"
	desc = "Аптечка, выполненная в зловещих чёрно-красных тонах. В её состав входит продвинутый анализатор здоровья, \
			медицинский ИЛС с ночным зрением, автомендер с 200 единицами синтплоти и боевой гипоспрей, в состав которого входят \
			эпинефрин, разбавленный омнизин и физиологический раствор."
	item = /obj/item/storage/firstaid/syndie
	cost = 35
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/vtec
	name = "Модуль ускорения робота VTEC"
	desc = "Повышает скорость передвижения робота."
	item = /obj/item/borg/upgrade/vtec
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/cyborg_magboots
	name = "Магнитный модуль робота (F-Magnet)"
	desc = "Позволяет роботу примагничиваться к полу или ближайшим объектам, что обеспечивает ему эффективное передвижение в условиях невесомости."
	item = /obj/item/borg/upgrade/magboots
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/autoimplanter
	name = "Автоимплантер"
	desc = "Устройство, позволяющее устанавливать 3 кибернетических импланта в полевых условиях без необходимости хирургического вмешательства."
	item = /obj/item/autoimplanter/traitor
	cost = 28
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/binary
	name = "Ключ бинарного перевода"
	desc = "Ключ для гарнитуры, который позволяет подключаться к двоичному каналу связи синтетиков."
	item = /obj/item/encryptionkey/binary
	cost = 21
	surplus = 75

/datum/uplink_item/device_tools/bowman_kit
	name = "Набор гарнитуры с ключом-шифратором Синдиката"
	desc = "В комплект входит гарнитура, оснащённая технологией \"Хамелеон\", которая обеспечивает защиту от громких звуков, а также ключ-шифратор Синдиката. \
			Этот ключ открывает доступ к зашифрованному каналу Синдиката и позволяет прослушивать все каналы связи на станции."
	item = /obj/item/storage/box/syndie_kit/bowman_conversion_kit
	cost = 2
	surplus = 75

/datum/uplink_item/device_tools/hacked_module
	name = "Модуль для взлома ИИ"
	desc = "Модуль, позволяющий установить закон, который будет выше всех остальных законов ИИ. Для его использования вам также потребуется консоль загрузки. \
			Будьте внимательны при формулировании этих закона, чтобы не допустить возникновения лазеек для ИИ."
	item = /obj/item/ai_module/syndicate
	cost = 38

/datum/uplink_item/device_tools/magboots
	name = "Кроваво-красные магнитные ботинки"
	desc = "Пара магнитных ботинок, выполненных в зловещих чёрно-красных тонах. Обеспечивают надежное сцепление с поверхностью и \
			позволяют двигаться в невесомости. От стандартных магнитных ботинок их отличает только дополнительное бронирование."
	item = /obj/item/clothing/shoes/magboots/syndie
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/magboots/advance
	name = "Улучшенные кроваво-красные магнитные ботинки"
	desc = "Пара магнитных ботинок, выполненных в зловещих чёрно-красных тонах. Обеспечивают превосходное сцепление с поверхностью и \
			позволяют двигаться в невесомости, не замедляя движения. Кроме того, они обладают дополнительным бронированием."
	item = /obj/item/clothing/shoes/magboots/syndie/advance
	cost = 40
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/powersink
	name = "Поглотитель энергии"
	desc = "Устройство, предназначенное для отключения питания станции, потребляет огромное количество энергии — 2 мегаватта в секунду! \
			Чтобы его подключить, необходимо установить его на узел и закрепить с помощью отвёртки, а затем включить. \
			Если количество энергии, потреблённой поглотителем, превысит 10 мегаватт, произойдёт мощный взрыв."
	item = /obj/item/powersink
	cost = 40

/datum/uplink_item/device_tools/singularity_beacon
	name = "Силовой маяк"
	desc = "Устройство, притягивающее к себе сингулярность и тесла-шар после того, как они покинут зону содержания. \
			Чтобы его подключить, необходимо установить его на узел и закрепить с помощью отвёртки, а затем включить."
	item = /obj/item/radio/beacon/syndicate
	cost = 30
	surplus = 0
	hijack_only = TRUE //This is an item only useful for a hijack traitor, as such, it should only be available in those scenarios.
	can_discount = FALSE

/datum/uplink_item/device_tools/ion_caller
	name = "Пульт управления ионной пушкой на низкой орбите"
	desc = "Портативное устройство, позволяющее активировать ионную пушку, которая перезаряжается каждые 15 минут. \
			Оно может изменять законы станционного ИИ, что приведет к обнаружению вас системой безопасности НаноТрейзен, или же вызывать перебои в телекоммуникациях."
	item = /obj/item/ion_caller
	limited_stock = 1	// Might be too annoying if someone had multiple.
	cost = 30
	surplus = 10
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)


/datum/uplink_item/device_tools/syndicate_detonator
	name = "Детонатор Синдиката"
	desc = "При активации детонатора все установленные бомбы Синдиката будут приведены в боевую готовность, и таймер начнет отсчитывать 5 секунд до взрыва. \
			Убедитесь, что вы находитесь в безопасном месте, прежде чем активировать детонатор."
	item = /obj/item/syndicatedetonator
	cost = 15
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/advpinpointer
	name = "Продвинутый целеуказатель"
	desc = "Устройство, предназначенное для поиска целей, имеет три режима работы. Оно способно указывать направление до введенных координат \
			до ядерного диска и других ценных предметов, а также до определённого гуманоида, если ввести его ДНК-код, который можно найти в медицинских записях. \
			Цвет стрелки на экране устройства показывает расстояние до цели: красный — далеко, синий — среднее, зелёный — близко."
	item = /obj/item/pinpointer/advpinpointer
	cost = 19

/datum/uplink_item/device_tools/ai_detector
	name = "Детектор ИИ"
	desc = "Устройство, замаскированное под мультитул, которое оповещает владельца световым индикатором о том, что за ним следит искусственный интеллект. \
			Расстояние до фокуса ИИ определяется цветом индикатора: жёлтый означает, что до него 20 тайлов, а красный — 8 тайлов."
	item = /obj/item/multitool/ai_detect
	cost = 2

/datum/uplink_item/device_tools/jammer
	name = "Источник радиопомех"
	desc = "Устройство, блокирующее радиосигнал на небольшом расстоянии — 12 тайлов. Несмотря на то что сообщения будут искажаться, они всё равно будут передаваться."
	item = /obj/item/jammer
	cost = 6

/datum/uplink_item/device_tools/teleporter
	name = "Плата консоли телепорта"
	desc = "Плата, необходимая для завершения сборки телепорта на корабле. \
			Если возникли проблемы с его работой, рекомендуется полностью разобрать и заново собрать все компоненты."
	item = /obj/item/circuitboard/teleporter
	cost = 100
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/device_tools/assault_pod
	name = "Целеуказатель для штурмовой капсулы"
	desc = "Устройство, позволяющее выбрать место для приземления вашей штурмовой капсулы."
	item = /obj/item/assault_pod
	cost = 125
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/device_tools/shield
	name = "Энергетический щит"
	desc = "Отражает любые энергетические снаряды, но абсолютно неэффективен против баллистического оружия."
	item = /obj/item/shield/energy/syndie
	cost = 60
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 20

/datum/uplink_item/device_tools/medgun
	name = "Медицинская лучевая пушка"
	desc = "Высокотехнологичное медицинское устройство, способное лечить как механические, так и термические повреждения, а также сращивать кости. \
			При пересечении с другими медицинскими лучами или при наведении двух лучей на одну цель может произойти взрыв."
	item = /obj/item/gun/medbeam
	cost = 75
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/stims
	name = "Стимуляторы"
	desc = "Инъектор с запрещённым стимулятором. После его применения гуманоид становится невосприимчивым к оглушению и значительно повышает свои способности к восстановлению."
	item = /obj/item/reagent_containers/hypospray/autoinjector/stimulants
	cost = 28
	excludefrom = list(UPLINK_TYPE_NUCLEAR)

//Space Suits and Hardsuits

/datum/uplink_item/suits
	category = "Скафандры и ИКСы"
	surplus = 40

/datum/uplink_item/suits/space_suit
	name = "Скафандр Синдиката"
	desc = "Скафандр, выполненный в зловещих чёрно-красных тонах, отличается компактными размерами по сравнению с ВКД НаноТрейзнен, \
			легко помещается в сумку и оснащён карманами для хранения оружия. В комплект также входит оборудование для поддержания жизнедеятельности. \
			Скафандр обеспечивает хорошую защиту, но при этом замедляет передвижение. Шлем защищает от вспышек."
	item = /obj/item/storage/box/syndie_kit/space
	cost = 18

/datum/uplink_item/suits/hardsuit
	name = "ИКС Синдиката"
	desc = "Знаменитый ИКС, выполненный в зловещих чёрно-красных тонах, отличается компактными размерами по сравнению с ИКСами НаноТрейзнен и \
			легко помещается в сумку. В комплект также входит оборудование для поддержания жизнедеятельности. ИКС оснащён встроенным джетпаком и \
			обеспечивает отличную защиту. Он имеет два режима работы: ВКД — для внекорабельной деятельности и боевой — для использования на станции."
	item = /obj/item/storage/box/syndie_kit/hardsuit
	cost = 33
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/suits/chameleon_hardsuit
	name = "ИКС-\"Хамелеон\""
	desc = "Скафандр, оснащённый технологией \"Хамелеон\". В комплект также входит оборудование для поддержания жизнедеятельности. \
			Изначально он выглядит как инженерный ИКС, но его можно замаскировать под любой другой из числа следующих: \
			инженерный, медицинский, шахтёрский, службы безопасности, а также под стандартный ВКД. \
			Скафандр обеспечивает хорошую защиту, но при этом замедляет передвижение. Шлем защищает от вспышек."
	cost = 46 //reskinned blood-red hardsuit with chameleon
	item = /obj/item/storage/box/syndie_kit/chameleon_hardsuit

/datum/uplink_item/suits/hardsuit/elite
	name = "Элитный ИКС Синдиката"
	desc = "Усовершенствованная версия знаменитого ИКСа Синдиката, выполненная в мрачном чёрном цвете. Обладает компактными размерами и легко помещается в сумку. \
			В комплект также входит оборудование для поддержания жизнедеятельности. ИКС оснащён встроенным джетпаком и обеспечивает отличную защиту. \
			В отличие от своего предшественника, он обладает полной защитой от термического воздействия и обладает превосходной броней. \
			Он имеет два режима работы: ВКД — для внекорабельной деятельности и боевой — для использования на станции."
	item = /obj/item/clothing/suit/space/hardsuit/syndi/elite
	cost = 50
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/suits/hardsuit/shielded
	name = "ИКС Синдиката с энергетическим щитом"
	desc = "Знаменитый ИКС, выполненный в зловещих чёрно-красных тонах, отличается компактными размерами по сравнению с ИКСами НаноТрейзнен и \
			легко помещается в сумку. В комплект также входит оборудование для поддержания жизнедеятельности. ИКС оснащён встроенным джетпаком и обеспечивает отличную защиту. \
			В отличие от обычного ИКСа Синдиката, этот обладает энергетическим щитом, который способен блокировать любые атаки, как в ближнем, так и в дальнем бою. \
			Щит имеет три заряда и восстанавливается в течение 20 секунд, если его не использовать. \
			Он имеет два режима работы: ВКД — для внекорабельной деятельности и боевой — для использования на станции."
	item = /obj/item/clothing/suit/space/hardsuit/syndi/shielded
	cost = 150
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

// IMPLANTS

/datum/uplink_item/implants
	category = "Импланты"

/datum/uplink_item/implants/freedom
	name = "Имплант свободы"
	desc = "Имплант, который можно вживить в организм и активировать по желанию. Может быть активирован 4 раза. \
			Предназначен для мгновенного освобождения от наручников, стяжек и болы. Можно вколоть 2 штуки одновременно."
	item = /obj/item/implanter/freedom
	cost = 18

/datum/uplink_item/implants/freedom/prototype
	name = "Прототип импланта свободы"
	desc = "Имплант, который можно вживить в организм и активировать по желанию. Может быть активирован 1 раз. \
			Предназначен для мгновенного освобождения от наручников, стяжек и болы. Можно вколоть 2 штуки одновременно."
	item = /obj/item/implanter/freedom/prototype
	cost = 6

/datum/uplink_item/implants/uplink
	name = "Имплант аплинка"
	desc = "Имплант, который можно вживить в организм и активировать по желанию. Может быть активирован многократно. \
			Предоставляет возможность использовать аплинк без необходимости иметь под рукой КПК или радиогарнитуру. \
			В начале он содержит 50 ТК, и с каждым последующим уколом их количество будет увеличиваться на 50 ТК. \
			Также можно вводить ТК отдельно."
	item = /obj/item/implanter/uplink
	cost = 60
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	can_discount = FALSE

/datum/uplink_item/implants/storage
	name = "Имплант хранилища"
	desc = "Имплант, который можно вживить в организм и активировать по желанию. \
			Создаёт небольшой подпространственный карман, в который можно поместить 2 предмета нормального размера. \
			После каждой новой имплантации объем хранилища будет увеличиваться."
	item = /obj/item/implanter/storage
	cost = 27

/datum/uplink_item/implants/mindslave
	name = "Имплант для порабощения разума"
	desc = "Имплант, который вживляют гуманоидам, чтобы контролировать их сознание. Не действует, если у жертвы уже есть аналогичный имплант. \
			Имплант активен, пока находится в теле, но не может воздействовать на тех, у кого установлен имплант щита разума."
	item = /obj/item/implanter/traitor
	cost = 25

/datum/uplink_item/implants/adrenal
	name = "Адреналиновый имплант"
	desc = "Имплант, который можно вживить в организм и активировать по желанию. Может быть активирован 3 раза. Избавляет от оглушения и замедления, восстанавливает выносливость. \
			Кроме того, вы получаете коктейль из стимуляторов, которые лечат вас, ускоряют и делают менее уязвимыми к оглушению."
	item = /obj/item/implanter/adrenalin
	cost = 44
	can_discount = FALSE
	surplus = 0

/datum/uplink_item/implants/adrenal/prototype
	name = "Прототип адреналинового импланта"
	desc = "Имплант, который можно вживить в организм и активировать по желанию. Может быть активирован 1 раз. Избавляет от оглушения и замедления, восстанавливает выносливость. \
			Кроме того, вы получаете коктейль из стимуляторов, которые лечат вас, ускоряют и делают менее уязвимыми к оглушению."
	item = /obj/item/implanter/adrenalin/prototype
	cost = 16

/datum/uplink_item/implants/microbomb
	name = "Имплант микробомбы"
	desc = "Имплант, который можно вживить в организм, активируется по желанию или автоматически в момент смерти. \
			При активации он вызывает взрыв, и чем больше таких устройств находится в теле, тем сильнее будет взрыв."
	item = /obj/item/implanter/explosive
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/implants/stealthbox
	name = "Имплант маскировки"
	desc = "Имплант, который можно вживить в организм и активировать по желанию. Может быть активирован многократно.\
			Позволяет развернуть коробку, которая полностью скрывает вас от посторонних глаз."
	item = /obj/item/implanter/stealth
	cost = 40

/datum/uplink_item/implants/macrobomb
	name = "Имплант макробомбы"
	desc = "Имплант, который можно вживить в организм, активируется по желанию или же срабатывает автоматически в момент смерти. \
			При активации он вызывает разрушительный взрыв. Перед детонацией происходит небольшая задержка, сопровождаемая тиканьем таймера бомбы. \
			Не рекомендуется использовать его в непосредственной близости от других оперативников."
	item = /obj/item/implanter/explosive_macro
	cost = 100
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

// Cybernetic Implants

/datum/uplink_item/cyber_implants
	category = "Кибернетические импланты"
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/cyber_implants/thermals
	name = "Имплант тепловизионного зрения"
	desc = "Кибернетические глаза, обеспечивающие тепловизионное зрение. Поставляются в комплекте с автоимплантером."
	item = /obj/item/storage/box/cyber_implants/thermals
	cost = 40

/datum/uplink_item/cyber_implants/xray
	name = "Имплант рентгеновского зрения"
	desc = "Кибернетические глаза, обеспечивающие рентгеновское зрение. Поставляются в комплекте с автоимплантером."
	item = /obj/item/storage/box/cyber_implants/xray
	cost = 50

/datum/uplink_item/cyber_implants/antistun
	name = "Укреплённый имплант перезагрузки ЦНС"
	desc = "Этот имплант предназначен для того, чтобы сокращать время вашего оглушения. Устойчив к ЭМИ. Поставляется в комплекте с автоимплантером."
	item = /obj/item/storage/box/cyber_implants/anti_stun_hardened
	cost = 60

/datum/uplink_item/cyber_implants/antisleep
	name = "Укреплённый имплант нейростимуляции"
	desc = "Этот имплант предназначен для того, чтобы помочь вам прийти в сознание, но на это потребуется некоторое время. \
			Устойчив к ЭМИ. Не совместим с имплантом перезагрузки ЦНС. В комплекте идёт автоматический инструмент для установки. Поставляется в комплекте с автоимплантером."
	item = /obj/item/storage/box/cyber_implants/anti_sleep_hardened
	cost = 75

/datum/uplink_item/cyber_implants/reviver
	name = "Укреплённый реанимирующий имплант"
	desc = "Этот имплант предназначен для того, чтобы попытаться вернуть вас к жизни, если вы потеряете сознание. \
			Устойчив к ЭМИ. Поставляется в комплекте с автоимплантером."
	item = /obj/item/storage/box/cyber_implants/reviver_hardened
	cost = 40

/datum/uplink_item/cyber_implants/mantisblade
	name = "Клинки богомола"
	desc = "Коробка, содержащая 2 клинка богомола. Поставляются в комплекте с саморазрушающимися автоимплантерами."
	item = /obj/item/storage/box/syndie_kit/mantisblade
	cost = 57
	surplus = 90
	uplinktypes = list()

/datum/uplink_item/cyber_implants/razorblade
	name = "Имплант хвостового лезвия"
	desc = "Лезвие, которое можно установить в хвост. Поставляется в комплекте с саморазрушающимися автоимплантерами. \
			С его помощью вы сможете продемонстрировать противнику, насколько опасным может быть ваш хвост."
	item = /obj/item/autoimplanter/oneuse/razorblade
	cost = 42
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_TRAITOR)

/datum/uplink_item/cyber_implants/laserblade
	name = "Имплант хвостового лазера"
	desc = "Лазерное лезвие, которое можно установить в хвост. Поставляется в комплекте с саморазрушающимися автоимплантерами. \
			С его помощью вы сможете продемонстрировать противнику, насколько опасным может быть ваш хвост."
	item = /obj/item/autoimplanter/oneuse/laserblade
	cost = 38
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_TRAITOR)

// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "Безделушки"
	surplus = 0

/datum/uplink_item/badass/desert_eagle
	name = "Пистолет Desert Eagle"
	desc = "Легендарный мощный пистолет с магазином на 7 патронов калибра .50AE. Полностью покрыт ЗОЛОТОМ, убивайте стильно!"
	item = /obj/item/gun/projectile/automatic/pistol/deagle/gold
	cost = 50

/datum/uplink_item/badass/syndiecigs
	name = "Сигареты Синдиката"
	desc = "Насыщенный аромат, плотный дым и вкус синдизина. Обычные сигареты."
	item = /obj/item/storage/fancy/cigarettes/cigpack_syndicate
	cost = 2

/datum/uplink_item/badass/syndiecards
	name = "Игральные карты Синдиката"
	desc = "У них очень острые края, поэтому во время игры можно легко пораниться. Обычные игральные карты."
	item = /obj/item/deck/cards/syndicate
	cost = 2
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 40

/datum/uplink_item/badass/syndiecash
	name = "Портфель с наличкой"
	desc = "Чемодан, оснащённый кодовым замком, содержит 5000 космических кредитов. Он может быть полезен для подкупа экипажа или оплаты товаров и услуг. \
			Ощущается немного тяжелее в руке, что делает его более эффектным в тех случаях, когда нужно убедить клиента."
	item = /obj/item/storage/secure/briefcase/syndie
	cost = 5

/datum/uplink_item/badass/plasticbag
	name = "Полиэтиленовый пакет"
	desc = "Обычный полиэтиленовый пакет. Хранить в недоступном для маленьких детей месте, не надевать на голову."
	item = /obj/item/storage/bag/plasticbag
	cost = 1
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/badass/balloon
	name = "Фирменный воздушный шар \"Синдикат\""
	desc = "Изящный красный воздушный шар с эмблемой Синдиката."
	item = /obj/item/toy/syndicateballoon
	cost = 100
	can_discount = FALSE

/datum/uplink_item/badass/unocard
	name = "Реверсивная карта Синдиката"
	desc = "Устройство, замаскированное под игральную карту, способно телепортировать оружие вашего противника прямо к вам в руку, когда он пытается выстрелить в вас."
	item = /obj/item/syndicate_reverse_card
	cost = 10

// Bundles and Telecrystals

/datum/uplink_item/bundles_TC
	category = "Наборы и телекристаллы"
	surplus = 0
	can_discount = FALSE

/datum/uplink_item/bundles_TC/bulldog
	name = "Набор — Дробовик \"Бульдог\""
	desc = "Сумка, в которой находятся: дробовик \"Бульдог\", 3 барабана по 12 патронов калибра 12g \"Картечь\" и тепловизионные очки."
	item = /obj/item/storage/backpack/duffel/syndie/bulldogbundle
	cost = 45 // normally 60
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/c20r
	name = "Набор — Пистолет-пулемёт C-20r"
	desc = "Сумка, в которой находятся: пистолет-пулемёт C-20r, 4 магазина по 20 патронов .45 калибра и универсальный глушитель."
	item = /obj/item/storage/backpack/duffel/syndie/c20rbundle
	cost = 90 // normally 105
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/cyber_implants
	name = "Набор — Кибернетические импланты"
	desc = "Сумка, в которой находятся: 5 случайных импланта из категории \"Кибернетические импланты\"."
	item = /obj/item/storage/box/cyber_implants/bundle
	cost = 200
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/medical
	name = "Медицинский набор"
	desc = "Сумка, в которой находятся: боевая аптечка Синдиката, автомендор с синтплотью, боевой гипоспрей, боевой компактный дефибриллятор, боевой ручной дефибриллятор, \
			имплант медицинской лучевой пушки, имплант хирургических инструментов, отвертка, автоимплантер, элитный медицинский ИКС Синдиката, портативный анализатор тела, \
			медицинская шина, инъектор с нанокальцием."
	item = /obj/item/storage/backpack/duffel/syndie/med/medicalbundle
	cost = 175 // normally 200
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/sniper
	name = "Набор — Снайперская винтовка Bubz FX1000"
	desc = "Портфель, в которой находятся: снайперская винтовка Bubz FX1000, красный галстук, тактический комбинезон и 2 магазина .50 \"Снотворный\"."
	item = /obj/item/storage/briefcase/sniperbundle
	cost = 110 // normally 135
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/cyborg_maint
	name = "Набор для починки роботов"
	desc = "Коробка, содержащая всё необходимое для ремонта робота, а также подробную инструкцию по эксплуатации."
	item = /obj/item/storage/box/syndie_kit/cyborg_maint
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/badass
	name = "Набор Синдиката"
	desc = "Предлагает вам выбрать один из трёх наборов или получить случайный набор. Общая стоимость предметов в наборах превышает 100 телекристаллов."
	item = /obj/item/radio/beacon/syndicate/bundle
	cost = 100
	refundable = TRUE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/surplus_crate
	name = "Ящик снабжения Синдиката"
	desc = "Ящик с различным снаряжением, стоимость которого составляет 250 телекристаллов."
	cost = 100
	item = /obj/item/storage/box/syndicate
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	var/crate_value = 250

/datum/uplink_item/bundles_TC/surplus_crate/super
	name = "Большой ящик снабжения Синдиката"
	desc = "Ящик с различным снаряжением, стоимость которого составляет 625 телекристаллов. Из-за высокой цены этот набор не доступен для покупки в одиночку."
	cost = 200
	crate_value = 625

/datum/uplink_item/bundles_TC/surplus_crate/spawn_item(mob/buyer, obj/item/uplink/target_uplink)
	var/obj/structure/closet/crate/crate = new(get_turf(buyer))
	var/list/buyable_items = get_uplink_items(target_uplink, generate_discounts = FALSE)
	var/remaining_TC = crate_value
	var/list/bought_items = list()
	var/list/itemlog = list()
	target_uplink.uses -= cost
	target_uplink.used_TC = cost


	while(remaining_TC && buyable_items.len)
		var/datum/uplink_item/chosen_item = pick(buyable_items)
		if(!chosen_item.surplus || prob(100 - chosen_item.surplus))
			continue
		if(chosen_item.cost > remaining_TC)
			continue
		if((chosen_item.item in bought_items) && prob(33)) //To prevent people from being flooded with the same thing over and over again.
			continue
		bought_items += chosen_item.item
		remaining_TC -= chosen_item.cost
		itemlog += chosen_item.name // To make the name more readable for the log compared to just i.item

	target_uplink.purchase_log += "<BIG>[bicon(crate)]</BIG>"
	for(var/bought_item in bought_items)
		var/obj/purchased = new bought_item(crate)
		target_uplink.purchase_log += "<BIG>[bicon(purchased)]</BIG>"
	add_game_logs("purchased a surplus crate with [jointext(itemlog, ", ")]", buyer)

/datum/uplink_item/bundles_TC/telecrystal
	name = "Телекристалл"
	desc = "Телекристалл в его естественном и первозданном виде. Предназначен для использования в аплинке. Форма, удобная для передачи."
	item = /obj/item/stack/telecrystal
	cost = 1

/datum/uplink_item/bundles_TC/telecrystal/twenty_five
	name = "25 Телекристаллов"
	desc = "25 телекристаллов в их естественном и первозданном виде. Предназначены для использования в аплинке. Форма, удобная для передачи."
	item = /obj/item/stack/telecrystal/twenty_five
	cost = 25

/datum/uplink_item/bundles_TC/telecrystal/hundred
	name = "100 Телекристаллов"
	desc = "100 телекристаллов в их естественном и первозданном виде. Предназначены для использования в аплинке. Форма, удобная для передачи."
	item = /obj/item/stack/telecrystal/hundred
	cost = 100

/datum/uplink_item/bundles_TC/telecrystal/twohundred_fifty
	name = "250 Телекристаллов"
	desc = "250 телекристаллов в их естественном и первозданном виде. Предназначены для использования в аплинке. Форма, удобная для передачи."
	item = /obj/item/stack/telecrystal/twohundred_fifty
	cost = 250
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

// Contractor

/datum/uplink_item/contractor
	category = "Контрактник"
	uplinktypes = list(UPLINK_TYPE_ADMIN)
	surplus = 0
	can_discount = FALSE

/datum/uplink_item/contractor/balloon
	name = "Воздушный шарик Контрактника"
	desc = "Изящный воздушный шар, выполненный в черно-золотых тонах и украшенный символикой контрактников. \
			Чтобы приобрести этот предмет, необходимо успешно завершить все предоставленные контракты в самой сложной локации."
	item = /obj/item/toy/syndicateballoon/contractor
	cost = 240

/datum/uplink_item/contractor/baton
	name = "Дубинка Контрактника"
	desc = "Компактная специализированная дубинка, которую выдают контрактникам Синдиката. \
			Это оружие применяется для поражения цели слабым электрическим током, что позволяет быстро обездвижить её."
	item = /obj/item/melee/baton/telescopic/contractor
	cost = 40

/datum/uplink_item/contractor/baton_cuffup
	name = "Улучшение для дубинки — \"Стяжки\""
	desc = "Позволяет заряжать стяжки, которые будут автоматически надеваться на цель во время оглушения."
	item = /obj/item/baton_upgrade/cuff
	cost = 40

/datum/uplink_item/contractor/baton_muteup
	name = "Улучшение для дубинки — \"Безмолвие\""
	desc = "Удар на 5 секунд лишает цель возможности говорить."
	item = /obj/item/baton_upgrade/mute
	cost = 40

/datum/uplink_item/contractor/baton_focusup
	name = "Улучшение для дубинки — \"Фокусировка\""
	desc = "Теперь, когда вы используете дубинку на цели, указанной в вашем контракте, она станет еще более эффективной."
	item = /obj/item/baton_upgrade/focus
	cost = 40

/datum/uplink_item/contractor/baton_antidropup
	name = "Улучшение для дубинки — \"Защита от выпадения\""
	desc = "Экспериментальная технология, представляющая собой систему шипов. \
			Когда вы держите дубинку, шипы впиваются в вашу кожу, обеспечивая надёжную фиксацию и предотвращая её выпадение."
	item = /obj/item/baton_upgrade/antidrop
	cost = 40

/datum/uplink_item/contractor/fulton
	name = "Набор для эвакуации \"Фултон\""
	desc = "Устройство, похожее на шахтёрский набор, но предназначенное для работы на космической станции. Он используется для транспортировки целей в труднодоступные места."
	item = /obj/item/storage/box/contractor/fulton_kit
	cost = 20

/datum/uplink_item/contractor/contractor_hardsuit
	name = "ИКС Контрактника"
	desc = "ИКС, оснащённый технологией \"Хамелеон\". В комплект также входит оборудование для поддержания жизнедеятельности. \
			ИКС выполнен в чёрно-золотых тонах и отличается компактностью, что позволяет легко носить его в сумке. \
			Он обеспечивает надежную защиту от внешних угроз, а шлем защищает от вспышек."
	item = /obj/item/storage/box/contractor/hardsuit
	cost = 80

/datum/uplink_item/contractor/pinpointer
	name = "Целеуказатель Контрактника"
	desc = "Высокоточное устройство, способное отслеживать любого человека в секторе, не используя датчики костюма. \
			Доступ к этому устройству предоставляется только тому, кто первым его активирует."
	item = /obj/item/pinpointer/crew/contractor
	cost = 20

/datum/uplink_item/contractor/contractor_partner
	name = "Вызов напарника"
	desc = "Устройство, позволяющее связаться с ближайшими отделениями Синдиката в вашем регионе. \
			Если в вашем районе есть свободный агент, его незамедлительно отправят к вам на помощь. \
			В случае отсутствия свободных агентов, сердства будут возвращены."
	item = /obj/item/antag_spawner/contractor_partner
	cost = 40
	refundable = TRUE

/datum/uplink_item/contractor/spai_kit
	name = "Набор СПИИ"
	desc = "Усовершенствованная версия обычного ПИИ. Он отличается большим объёмом памяти и наличием специальных программ, \
			позволяющих, например, удалённо управлять шлюзами, вводить лечебные препараты в организм, видеть сквозь стены и так далее."
	item = /obj/item/storage/box/contractor/spai_kit
	cost = 40
	refundable = TRUE
	refund_path = /obj/item/paicard_upgrade/unused

/datum/uplink_item/contractor/zippo
	name = "Зажигалка Контрактника"
	desc = "Изящная зажигалка, оформленная в черно-золотых тонах и украшенная символикой контрактников. \
			Чтобы приобрести этот предмет, необходимо сначала выполнить все свои контракты."
	item = /obj/item/lighter/zippo/contractor
	cost = 1

/datum/uplink_item/contractor/loadout_box
	name = "Стандартный набор Контрактника"
	desc = "Коробка с экипировкой, предназначенной только для контрактников."
	item = /obj/item/storage/box/syndie_kit/contractor_loadout
	cost = 40

#undef UPLINK_DISCOUNTS

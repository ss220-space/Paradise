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
			discount_item.category = "Скидки"
			discount_item.name += " ([round(((init_cost - discount_item.cost) / init_cost) * 100)]% off!)"
			discount_item.job = null // If you get a job specific item selected, actually lets you buy it in the discount section
			discount_item.desc += " Не более [discount_item.limited_stock] на аплинк. Изначальная цена была [init_cost] TC."
			discount_item.surplus = 0 // stops the surplus crate potentially giving out a bit too much

			. += discount_item

	return .


/datum/uplink_item
	/// Uplink name.
	var/name = "item name"
	/// Uplink category.
	var/category = "item category"
	/// Uplink description.
	var/desc = "Item Description"
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
	/// Empty list means it is available for every in game affiliates.
	var/list/affiliate
	/// Empty list means it is available for every in game affiliates.
	var/list/exclude_from_affiliate
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
	/// Affiliate that made it
	var/made_by = ""

/datum/uplink_item/New()
	. = ..()
	desc += " Предоставлено "
	if (made_by == "")
		desc += pick(AFFIL_CYBERSUN, AFFIL_GORLEX, AFFIL_HEMATOGENIC, AFFIL_MI13, AFFIL_SELF, AFFIL_TIGER, AFFIL_WAFFLE, AFFIL_DONK, AFFIL_WAFFLE, AFFIL_BIOTECH, AFFIL_MIME, AFFIL_CLOWN, AFFIL_SOL)
	desc += made_by + "."


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
	if(hijack_only && !(buyer.mind.special_role == SPECIAL_ROLE_NUKEOPS) && !buyer.mind.has_big_obj() && target_uplink.uplink_type != UPLINK_TYPE_ADMIN)
		to_chat(buyer, span_warning("Синдикат выдаст этот чрезвычайно опасный предмет только агентам, которым поручены особенно опасные задачи."))
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

	if(category == "Скидки" && refundable)
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
	category = "Скидки"

//Job specific gear

/datum/uplink_item/jobspecific
	category = "Специфичное для работы"
	can_discount = FALSE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST) // Stops the job specific category appearing for nukies

//Clown
/datum/uplink_item/jobspecific/clowngrenade
	name = "Банановая граната"
	desc = "Граната, которая взрывается, превращаясь в банановую кожуру марки HONK!, генетически модифицированную, чтобы быть особенно скользкой и выделять едкую кислоту, при наступании на нее."
	item = /obj/item/grenade/clown_grenade
	cost = 8
	job = list(JOB_TITLE_CLOWN)
	made_by = AFFIL_CLOWN

/datum/uplink_item/jobspecific/cmag
	name = "Шутовской секвенсор"
	desc = "Шутовской Секвенсор, также известный как cmag, представляет собой небольшую карту, которая инвертирует доступ к любой двери, на которой она используется. Идеально подходит для блокировки кому-то доступа в его собственный отдел. Хонк!"
	item = /obj/item/card/cmag
	cost = 20
	surplus = 50
	job = list(JOB_TITLE_CLOWN)
	made_by = AFFIL_CLOWN

/datum/uplink_item/jobspecific/clownmagboots
	name = "Клоунские магнитные ботинки"
	desc = "Пара модифицированных клоунских ботинок, оснащенных усовершенствованной системой магнитного сцепления. Выглядят и звучат точно так же, как обычные клоунские ботинки, если не присматриваться."
	item = /obj/item/clothing/shoes/magboots/clown
	cost = 12
	job = list(JOB_TITLE_CLOWN)

/datum/uplink_item/jobspecific/acrobatic_shoes
	name = "Акробатическая обувь"
	desc = "Пара модифицированных клоунских ботинок оснащенная специальным прыжковым механизмом, который работает на ХОНК-пространстве, позволяя вам выполнять великолепные акробатические трюки!"
	item = /obj/item/clothing/shoes/bhop/clown
	cost = 12
	job = list(JOB_TITLE_CLOWN)
	made_by = AFFIL_CLOWN

/datum/uplink_item/jobspecific/trick_revolver
	name = "Револьвер для трюков"
	desc = "Револьвер, который выстрелит назад и убьет любого, кто попытается его использовать. Идеально против любителей отбирать оружие и просто для смеха."
	item = /obj/item/storage/box/syndie_kit/fake_revolver
	cost = 5
	exclude_from_affiliate = list(AFFIL_TIGER)
	job = list(JOB_TITLE_CLOWN)
	made_by = AFFIL_CLOWN

//Mime
/datum/uplink_item/jobspecific/caneshotgun
	name = "Дробовик-трость с летальными патронами"
	desc = "Специализированное однозарядное ружье со встроенной маскировкой, имитирующее трость. Ружье способно скрывать свое содержимое и курок. Поставляется в коробке с 6 специализированными осколочными патронами, заполненными токсином немоты, и 1 предварительно загруженным в ружье."
	item = /obj/item/storage/box/syndie_kit/caneshotgun
	cost = 25
	exclude_from_affiliate = list(AFFIL_TIGER)
	job = list(JOB_TITLE_MIME)
	made_by = AFFIL_MIME

/datum/uplink_item/jobspecific/mimery
	name = "Серия руководств по продвинутым пантомимам"
	desc = "Содержит два руководства для обучения продвинутым пантомимам. Вы сможете стрелять оглушающими пулями из пальцев и создавать большие стены, которые могут перекрыть целый коридор!"
	item = /obj/item/storage/box/syndie_kit/mimery
	cost = 30
	job = list(JOB_TITLE_MIME)
	made_by = AFFIL_MIME

/datum/uplink_item/jobspecific/mimejutsu
	name = "Руководство по Мимдзюцу"
	desc =	"Старинное руководство по боевому искусству мимов."
	item = /obj/item/mimejutsu_scroll
	cost = 40
	job = list(JOB_TITLE_MIME)
	made_by = AFFIL_MIME

/datum/uplink_item/jobspecific/combat_baking
	name = "Боевой пекарный набор"
	desc = "Набор особой выпечки, которую можно использовать как оружие. Содержит багет, который умелый мим мог бы использовать как меч, \
пару метательных круассанов и рецепт, чтобы сделать больше по требованию. Когда работа будет сделана, съешьте улики."
	item = /obj/item/storage/box/syndie_kit/combat_baking
	cost = 25
	job = list(JOB_TITLE_MIME, JOB_TITLE_CHEF)
	made_by = AFFIL_DONK

//Miner
/datum/uplink_item/jobspecific/pressure_mod
	name = "Модуль давления для кинетического акселератора"
	desc = "Комплект модификаций, позволяющий кинетическим акселераторам наносить значительно повышенный урон в помещении. Занимает 35% емкости модулей."
	item = /obj/item/borg/upgrade/modkit/indoors
	cost = 18 //you need two for full damage, so total of 8 for maximum damage
	job = list(JOB_TITLE_MINER, JOB_TITLE_QUARTERMASTER)
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/jobspecific/mining_charge_hacker
	name = "Взломщик шахтерских зарядов"
	desc = "Выглядит и функционирует как усовершенствованный шахтерский сканер, но позволяет размещать шахтерские заряды для добычи в любом месте и разрушать не только камни. \
Используйте его на шахтерском заряде, чтобы обойти его предохранители. Снижает взрывную силу зарядов за счет модификации их внутренних компонентов."
	item = /obj/item/t_scanner/adv_mining_scanner/syndicate
	cost = 20
	job = list(JOB_TITLE_MINER, JOB_TITLE_QUARTERMASTER)
	made_by = AFFIL_CYBERSUN

//Chef
/datum/uplink_item/jobspecific/specialsauce
	name = "Элитарный соус шефа"
	desc = "Особый соус, приготовленный из очень ядовитых мухоморов. Любой, кто его съест, получит различное токсическое повреждение в зависимости от того, как долго он находился в его организме, причем большая доза требует больше времени для метаболизации."
	item = /obj/item/reagent_containers/food/condiment/syndisauce
	cost = 1
	job = list(JOB_TITLE_CHEF)
	made_by = AFFIL_DONK

/datum/uplink_item/jobspecific/meatcleaver
	name = "Мясницкий тесак"
	desc = "Ужасно выглядящий мясницкий тесак, наносящий урон, сравнимый с лазерным мечом, но имеющий дополнительное преимущество в виде возможности разрубать жертву на куски мяса после ее смерти."
	item = /obj/item/kitchen/knife/butcher/meatcleaver
	cost = 20
	job = list(JOB_TITLE_CHEF)
	made_by = AFFIL_MI13

/datum/uplink_item/jobspecific/syndidonk
	name = "Донк-покеты Синдиката" // We don't have a word for it.
	desc = "Коробка с узкоспециализированными Донк-покетами, содержащими ряд лечащих и стимулирующих химикатов внутри; коробка оснащена механизмом самонагрева."
	item = /obj/item/storage/box/syndidonkpockets
	cost = 10
	job = list(JOB_TITLE_CHEF)
	made_by = AFFIL_DONK

/datum/uplink_item/jobspecific/CQC_upgrade
	name = "Имплант обновления CQC"
	desc = "Содержит специальный имплантат для поваров, который разрушают проверку безопасности их врожденного имплантата CQC, позволяет им использовать боевое искусство вне кухни. Используйте в руке."
	item = /obj/item/CQC_manual/chef
	cost = 30
	job = list(JOB_TITLE_CHEF)
	surplus = 0 //because it's useless for all non-chefs
	made_by = AFFIL_MI13

/datum/uplink_item/jobspecific/dangertray
	name = "Набор опасных подносов"
	desc = "Содержит набор из трех острых металлических подносов, способных отрезать конечности."
	item = /obj/item/storage/box/syndie_kit/dangertray
	cost = 15
	job = list(JOB_TITLE_CHEF)
	made_by = AFFIL_MI13

//Chaplain
/datum/uplink_item/jobspecific/voodoo
	name = "Кукла Вуду"
	desc = "Кукла, созданная Шаманами Синдиката. Состав: Нити, Что-то из трупов, Секретные травы вуду и Глутамат натрия."
	item = /obj/item/voodoo
	cost = 11
	job = list(JOB_TITLE_CHAPLAIN)

/datum/uplink_item/jobspecific/missionary_kit
	name = "Стартовый набор миссионера"
	desc = "Коробка, содержащая миссионерский посох, миссионерскую одежду и Библию. Одежду и посох можно связать, чтобы вы могли порабощать жертв на расстоянии на короткий промежуток времени. Библия для библейских вещей."
	item = /obj/item/storage/box/syndie_kit/missionary_set
	cost = 72
	job = list(JOB_TITLE_CHAPLAIN)

/datum/uplink_item/jobspecific/artistic_toolbox
	name = "Артистический тулбокс"
	desc = "Проклятый тулбокс, дающий своим последователям чрезвычайную силу ценой необходимости приносить жертвы. Если жертвы не предоставлены, он нападет на своего последователя."
	item = /obj/item/storage/toolbox/green/memetic
	cost = 100
	job = list(JOB_TITLE_CHAPLAIN, JOB_TITLE_CIVILIAN)
	surplus = 0 //No lucky chances from the crate; if you get this, this is ALL you're getting
	hijack_only = TRUE //This is a murderbone weapon, as such, it should only be available in those scenarios.
	made_by = AFFIL_TIGER

/datum/uplink_item/jobspecific/book_of_babel
	name = "Вавилонская книга"
	desc = "Древний том, написанный на бесчисленных языках. Несмотря на это, вы можете читать эту книгу без усилий, чтобы выучить все существующие языки. Не спрашивайте."
	item = /obj/item/book_of_babel
	cost = 1
	job = list(JOB_TITLE_CHAPLAIN, JOB_TITLE_LIBRARIAN)
	surplus = 0
	can_discount = FALSE

//Janitor
/datum/uplink_item/jobspecific/cautionsign
	name = "Замаскированная противопихотная мина"
	desc = "Противопехотная мина, искусно замаскированная под предупреждающий знак «Мокрый пол», срабатывает, если пробежать мимо нее. Активируйте ее, чтобы запустить 15-секундный таймер, и активируйте еще раз, чтобы обезвредить."
	item = /obj/item/caution/proximity_sign
	cost = 11
	job = list(JOB_TITLE_JANITOR)
	surplus = 0
	made_by = AFFIL_CLOWN

/datum/uplink_item/jobspecific/holomine
	name = "Голопроектор мин"
	desc = "Проектор, способный установить до 5 оглушающих мин с дополнительным эффектом ЭМИ."
	item = /obj/item/holosign_creator/janitor/syndie
	cost = 40
	job = list(JOB_TITLE_JANITOR)
	surplus = 0
	made_by = AFFIL_CLOWN

//Medical
/datum/uplink_item/jobspecific/rad_laser
	name = "Радиационный лазер"
	desc = "Радиационный лазер, скрытый внутри анализатора здоровья. После умеренной задержки вызывает временную потерю сознания и радиационное облучение. Имеет регулируемые параметры, но не будет функционировать как обычный анализатор здоровья, а только выглядит как таковой. Может неправильно работать на устойчивых к радиации гуманоидах!"
	item = /obj/item/rad_laser
	cost = 23
	job = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_GENETICIST, JOB_TITLE_PSYCHIATRIST, \
			JOB_TITLE_CHEMIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_CORONER, JOB_TITLE_VIROLOGIST)
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/jobspecific/batterer
	name = "Подавитель разума"
	desc = "Устройство, которое может сбивать с ног людей вокруг вас на долгое время или замедлять их. На пользователя это не влияет. Перезарядка занимает 2 минуты."
	item = /obj/item/batterer
	cost = 50
	job = list(JOB_TITLE_CMO, JOB_TITLE_PSYCHIATRIST)
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/jobspecific/dna_upgrader
	name = "Модификатор ДНК"
	desc = "Экспериментальный ДНК-инжектор, который позволит вам провести одну продвинутую генную модификацию и повысить стабильность ваших генов."
	item = /obj/item/dna_upgrader
	cost = 55
	job = list(JOB_TITLE_CMO, JOB_TITLE_GENETICIST)
	surplus = 0
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/jobspecific/laser_eyes_injector
	name = "Инжектор лазеров из глаз"
	desc = "Эксперементальный ДНК инжектор, который навсегда даст вам способность стрелять лазерами из глаз."
	item = /obj/item/laser_eyes_injector
	cost = 37
	job = list(JOB_TITLE_GENETICIST)
	surplus = 0
	made_by = AFFIL_HEMATOGENIC

//Virology
/datum/uplink_item/jobspecific/viral_injector
	name = "Вирусный инжектор"
	desc = "Модифицированный гипоспрей, замаскированный под пипетку. Пипетка может заражать жертв вирусами при инъекции."
	item = /obj/item/reagent_containers/dropper/precision/viral_injector
	cost = 15
	job = list(JOB_TITLE_VIROLOGIST)
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/jobspecific/cat_grenade
	name = "Граната для доставки диких кошек"
	desc = "Граната для доставки диких кошек содержит 5 кубиков диких кошек, подобно кубикам макак, которые при детонации будут помещены в небольшой резервуар воды, содержащийся внутри гранаты. Эти кошки будут атаковать все, что попадется им на глаза."
	item = /obj/item/grenade/spawnergrenade/feral_cats
	cost = 3
	job = list(JOB_TITLE_PSYCHIATRIST)//why? Becuase its funny that a person in charge of your mental wellbeing has a cat granade..
	made_by = AFFIL_CLOWN

/datum/uplink_item/jobspecific/gbs
	name = "Бутылек с вирусом ГБС"
	desc = "Бутылек, содержащий культуру Гравитокинетического Бипотенциального SADS. Также известен как GBS, чрезвычайно смертельный вирус."
	item = /obj/item/reagent_containers/glass/bottle/gbs
	cost = 60
	job = list(JOB_TITLE_VIROLOGIST)
	surplus = 0
	hijack_only = TRUE
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/jobspecific/lockermech
	name = "Синди Шкафомех"
	desc = "Огромный и невероятно смертоносный экзокостюм Синдиката (на самом деле нет)."
	item = /obj/mecha/combat/lockersyndie/loaded
	cost = 25
	job = list(JOB_TITLE_CIVILIAN, JOB_TITLE_ROBOTICIST)
	surplus = 0
	made_by = AFFIL_CLOWN

/datum/uplink_item/jobspecific/stungloves
	name = "Оглушающие перчатки"
	desc = "Пара прочных оглушающих перчаток с изолирующим слоем. Защищает пользователя от поражения электрическим током и позволяет оглушать врагов."
	item = /obj/item/storage/box/syndie_kit/stungloves
	cost = 7
	job = list(JOB_TITLE_CIVILIAN, JOB_TITLE_MECHANIC, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_CHIEF)
	made_by = AFFIL_CYBERSUN

//Bartender
/datum/uplink_item/jobspecific/drunkbullets
	name = "Опьяняющие патроны для дробовика"
	desc = "Коробка с 6 патронами для дробовика, имитирующими воздействие сильного алкогольного опьянения на цель. Их эффективность повышается за счет каждого типа алкоголя в организме цели."
	item = /obj/item/storage/belt/bandolier/booze
	cost = 15
	job = list(JOB_TITLE_BARTENDER)
	exclude_from_affiliate = list(AFFIL_TIGER)
	made_by = AFFIL_MIME

//Barber
/datum/uplink_item/jobspecific/safety_scissors //Hue
	name = "Безопасные ножницы"
	desc = "Пара ножниц, которые представляют собой совсем не то, что подразумевает их название. они могут легко перерезать кому-то горло."
	item = /obj/item/scissors/safety
	cost = 6
	job = list(JOB_TITLE_BARBER)
	made_by = AFFIL_MI13

//Botanist
/datum/uplink_item/jobspecific/bee_briefcase
	name = "Портфель, полный пчел"
	desc = "Казалось бы, невинный портфель, полный не таких уж невинных пчел, выращенных Синдикатом. Впрысните в портфель кровь, чтобы научить пчел игнорировать донора(ов)." // Info about intercoms was fake
	item = /obj/item/bee_briefcase
	cost = 22
	job = list(JOB_TITLE_BOTANIST)
	made_by = AFFIL_DONK

/datum/uplink_item/jobspecific/gatfruit
	name = "Семяна гатфрукта"
	desc = "Семена растения \"гатфрукт\". Из съеденных плодов получится револьвер калибра .36! Он также содержит 10% серы, 10% углерода, 7% азота, 5% калия."
	item = /obj/item/seeds/gatfruit
	cost = 22
	job = list(JOB_TITLE_BOTANIST)
	made_by = AFFIL_DONK

//Engineer
/datum/uplink_item/jobspecific/powergloves
	name = "Силовые перчатки"
	desc = "Изолирующие перчатки, которые могут использовать энергию станции для подачи короткой дуги электричества на цель. Для использования необходимо стоять на кабеле под напряжением."
	item = /obj/item/clothing/gloves/color/yellow/power
	cost = 33
	job = list(JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_CHIEF)
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/jobspecific/supertoolbox
	name = "Улучшенный подозрительный тулбокс"
	desc = "Окончательная версия всех ящиков с инструментами, этот более прочный и полезный, чем его более дешевая версия. Поставляется с экспериментальными инструментами, боевыми перчатками и крутыми солнцезащитными очками."
	item = /obj/item/storage/toolbox/syndisuper
	cost = 8
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	job = list(JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_CHIEF, \
			JOB_TITLE_MECHANIC, JOB_TITLE_ROBOTICIST, JOB_TITLE_PARAMEDIC)

//RD
/datum/uplink_item/jobspecific/telegun
	name = "Телепушка"
	desc = "Чрезвычайно высокотехнологичная энергетическая пушка, использующая Блюспейс для телепортации живых целей. Выберите телепортационный маяк в самой телепушке; снаряды будут отправлять цели на выбраный маяк."
	item = /obj/item/gun/energy/telegun
	cost = 66
	exclude_from_affiliate = list(AFFIL_TIGER)
	job = list(JOB_TITLE_RD)
	made_by = AFFIL_WAFFLE

//Roboticist
/datum/uplink_item/jobspecific/syndiemmi
	name = "ММИ Синдиката"
	desc = "Синдикат разработал ММИ, заставляющий любого борга, в которого он будет внедрен, следовать стандартному набору законов синдиката."
	item = /obj/item/mmi/syndie
	cost = 6
	job = list(JOB_TITLE_ROBOTICIST)
	surplus = 0
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/jobspecific/missilemedium
	name = "Пусковая ракетная установка SRM-8"
	desc = "Известно, что эти ракетные пусковые установки используются на высококлассных мехах, таких как Маулер и Мародер. Гораздо мощнее, чем ракетные модули, которые можно напечатать на стандартных заводах по производству мехов. Поставляется без замков — подключи и работай!"
	item = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/medium
	cost = 50
	exclude_from_affiliate = list(AFFIL_TIGER)
	job = list(JOB_TITLE_ROBOTICIST)
	surplus = 0
	can_discount = FALSE
	hijack_only = TRUE
	made_by = AFFIL_WAFFLE

//Librarian
/datum/uplink_item/jobspecific/etwenty
	name = "Двадцатигранник"
	desc = "На первый взгляд обычная кость, но те, кто не побоится использовать этот кубик для атаки, обнаружат что он весьма взрывоопасен. Имеет четырехсекундный таймер."
	item = /obj/item/dice/d20/e20
	cost = 8
	job = list(JOB_TITLE_LIBRARIAN)
	surplus = 0
	hijack_only = TRUE
	made_by = AFFIL_CLOWN

/datum/uplink_item/jobspecific/random_spell_book
	name = "Случайная книга заклинаний"
	desc = "Случайная книга заклинаний, украденная у федерации магов."
	item = /obj/item/spellbook/oneuse/random
	cost = 25
	job = list(JOB_TITLE_LIBRARIAN)
	can_discount = FALSE

/datum/uplink_item/jobspecific/dice_of_fate
	name = "Кости судьбы"
	desc = "Все или ничего — вот мой девиз."
	item = /obj/item/dice/d20/fate/one_use
	cost = 100
	job = list(JOB_TITLE_LIBRARIAN)
	surplus = 0
	can_discount = FALSE
	made_by = AFFIL_CLOWN

//Botanist
/datum/uplink_item/jobspecific/ambrosiacruciatus
	name = "Семена амброзии круациатус"
	desc = "Часть печально известного семейства Амброзия, этот вид почти неотличим от Амброзии Вульгарис, но его ветви содержат отвратительный токсин. Восьми единиц достаточно, чтобы свести жертву с ума."
	item = /obj/item/seeds/ambrosia/cruciatus
	cost = 4
	job = list(JOB_TITLE_BOTANIST)
	made_by = AFFIL_DONK

//Atmos Tech
/datum/uplink_item/jobspecific/contortionist
	name = "Комбинезон акробата"
	desc = "Очень гибкий комбинезон, позволяющий вам перемещаться по вентиляции. Поставляется с карманами и слотом для ID-карты, но не может быть использован без снятия большей части снаряжения, включая рюкзак, пояс, шлем и экзокостюм. Необходимы свободные руки, чтобы ползать по вентиляции."
	item = /obj/item/clothing/under/contortionist
	cost = 50
	job = list(JOB_TITLE_ATMOSTECH, JOB_TITLE_CHIEF)
	made_by = AFFIL_MI13

/datum/uplink_item/jobspecific/energizedfireaxe
	name = "Энергетический пожарный топор"
	desc = "Пожарный топор со встроенным мощным электрошокером. При ударе кого-то, если топор заряжен, отбросит жертву назад, оглушив на короткое время. На повторную зарядку потребуется некоторое время. Намного острее обычного топора и может пробивать легкую броню."
	item = /obj/item/twohanded/fireaxe/energized
	cost = 18
	job = list(JOB_TITLE_ATMOSTECH, JOB_TITLE_CHIEF)
	made_by = AFFIL_GORLEX

//CE
/datum/uplink_item/jobspecific/combat_rcd
	name = "РЦД Синдиката"
	desc = "Специальный РЦД, способный разрушать укрепленные стены и имеющий 500 единиц материи вместо 100."
	item = /obj/item/rcd/combat
	cost = 25
	job = list(JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_MECHANIC, JOB_TITLE_ATMOSTECH, JOB_TITLE_CHIEF)
	surplus = 0
	made_by = AFFIL_CYBERSUN

//Tator Poison Bottles

/datum/uplink_item/jobspecific/poisonbottle
	name = "Бутылек с ядом"
	desc = "Синдикат отправит бутылек, содержащий 40 единиц случайно выбранного яда. Яд может варьироваться от очень раздражающего до невероятно смертельного."
	item = /obj/item/reagent_containers/glass/bottle/traitor
	cost = 10
	job = list(JOB_TITLE_RD, JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_PSYCHIATRIST, \
			JOB_TITLE_CHEMIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_VIROLOGIST, JOB_TITLE_BARTENDER, JOB_TITLE_CHEF)
	made_by = AFFIL_HEMATOGENIC

// Paper contact poison pen

/datum/uplink_item/jobspecific/poison_pen
	name = "Ручка с ядом"
	desc = "Это устройство, созданное на основе новейших технологий в области смертоносных пишущих инструментов, наполнит любой лист бумаги ядом замедленного действия."
	item = /obj/item/pen/poison
	cost = 5
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	job = list(JOB_TITLE_HOP, JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH, JOB_TITLE_LIBRARIAN)
	made_by = AFFIL_MI13

// Racial

/datum/uplink_item/racial
	category = "Спицифичное для расы"
	can_discount = FALSE
	surplus = 0
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

//IPC

/datum/uplink_item/racial/ipc_combat_upgrade
	name = "Боевое обновление КПБ"
	desc = "Расширенное хранилище данных, совместимое с позитронными системами. Оно включает алгоритмы ближнего боя, а также перезаписанные протоколы безопасности микробатарей."
	item = /obj/item/ipc_combat_upgrade
	cost = 11
	race = list(SPECIES_MACNINEPERSON)
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/racial/supercharge
	name = "Имплант суперзаряда"
	desc = "Имплантат, устанавливаемый в тело, а затем активируемый вручную для введения химического коктейля, имеющего эффект снятия и сокращения времени всех оглушений и увеличения скорости передвижения. Может быть активирован до 3 раз."
	item = /obj/item/implanter/supercharge
	cost = 40
	race = list(SPECIES_MACNINEPERSON)
	made_by = AFFIL_CYBERSUN

//Slime People

/datum/uplink_item/racial/anomaly_extract
	name = "Экстракт аномалии"
	desc = "Результат работы ученых по смешиванию экспериментального стабильного мутагена с ядром пирокластической аномалии. Дает пользователю возможность стать слизью и нагреться."
	item = /obj/item/anomaly_extract
	cost = 40
	race = list(SPECIES_SLIMEPERSON)
	made_by = AFFIL_BIOTECH

//Plasmaman

/datum/uplink_item/racial/plasma_chameleon
	name = "Маскировочный набор для плазмаменов"
	desc = "Набор предметов, содержащих технологию хамелеона, позволяющую вам замаскироваться под что угодно на станции, и даже больше! \
			Из-за сокращения бюджета обувь не защищает от скольжения. В комплект входит дополнительная печать хамелеона. Только для Плазмаменов."
	item = /obj/item/storage/box/syndie_kit/plasma_chameleon
	cost = 20
	race = list(SPECIES_PLASMAMAN)
	made_by = AFFIL_TIGER

//Nucleation

/datum/uplink_item/racial/second_chance
	name = "Имплантат \"Второй шанс\""
	desc = "Имплант, вводимый в тело и активируемый по желанию пользователя. Он имитирует смерть пользователя и переносит его в безопасное место."
	item = /obj/item/implanter/second_chance
	cost = 40
	race = list(SPECIES_NUCLEATION)
	made_by = AFFIL_SOL // Nucleations are only humans

//Human

/datum/uplink_item/racial/holo_cigar
	name = "Голо-сигара"
	desc = "Голо-сигара, импортированная из Солнечной системы. Все эффекты от такого крутого внешнего вида пока не изучены, но пользователи демонстрируют повышение точности при стрельбе из двух оружий за раз."
	item = /obj/item/clothing/mask/holo_cigar
	cost = 10
	race = list(SPECIES_HUMAN)
	made_by = AFFIL_SOL

//Grey

/datum/uplink_item/racial/agent_belt
	name = "Пояс агента"
	desc = "Военный пояс для инструментов, используемый агентами Абдукторов. Содержит полный набор инопланетных инструментов."
	item = /obj/item/storage/belt/military/abductor/full
	cost = 16
	race = list(SPECIES_GREY)
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/racial/silencer
	name = "Глушитель Абдукторов"
	desc = "Компактное устройство, используемое для отключения радиосвязи."
	item = /obj/item/abductor/silencer
	cost = 12
	race = list(SPECIES_GREY)
	made_by = AFFIL_MIME

// DANGEROUS WEAPONS

/datum/uplink_item/dangerous
	category = "Хорошо заметное и опасное оружие"
	exclude_from_affiliate = list(AFFIL_MI13)
	made_by = AFFIL_SHELLGUARD

/datum/uplink_item/dangerous/minotaur
	name = "Дробовик AS-12 'Минотавр'"
	desc = "Современный, стреляющий очередями, боевой дробовик, использующий боеприпасы калибра 12g. Вмещает барабаны на 12/24 патрона, идеально подходит для зачистки толп людей в узких коридорах. Добро пожаловать в лабиринт Минотавра!"
	item = /obj/item/gun/projectile/automatic/shotgun/minotaur
	cost = 80
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	made_by = AFFIL_WAFFLE

/datum/uplink_item/dangerous/pistol
	name = "Пистолет Стечкина"
	desc = "Небольшой, легко скрываемый пистолет, использующий 10-мм автоматические патроны в 8-зарядных магазинах и совместимый с глушителями."
	item = /obj/item/gun/projectile/automatic/pistol
	cost = 20
	exclude_from_affiliate = list(AFFIL_MI13, AFFIL_TIGER)
	made_by = AFFIL_WAFFLE

/datum/uplink_item/dangerous/revolver
	name = "Револьвер Синдиката .357 калибра"
	desc = "Простейший револьвер Синдиката, стреляющий патронами .357 Магнум и имеющий 7 слотов для потронов."
	item = /obj/item/gun/projectile/revolver
	cost = 50
	exclude_from_affiliate = list(AFFIL_MI13, AFFIL_TIGER)
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 50
	made_by = AFFIL_WAFFLE

/datum/uplink_item/dangerous/deagle
	name = "Пустынный орел"
	desc = "Легендарный пистолет высокой мощности, использующий магазины на 7 патронов калибра .50AE."
	item = /obj/item/gun/projectile/automatic/pistol/deagle
	cost = 50
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_WAFFLE

/datum/uplink_item/dangerous/uzi
	name = "Пистолет-пулемёт Узи"
	desc = "Полностью заряженный легкий пистолет-пулемет со свободным затвором, использующий 9-мм магазины емкостью 30 патронов."
	item = /obj/item/gun/projectile/automatic/mini_uzi
	cost = 60
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_WAFFLE

/datum/uplink_item/dangerous/smg
	name = "Пистолет-пулемёт С-20r"
	desc = "Полностью заряженный пистолет-пулемет, стреляющий патронами калибра .45 с магазином на 20 патронов и совместимый с глушителями."
	item = /obj/item/gun/projectile/automatic/c20r
	cost = 70
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 40
	made_by = AFFIL_WAFFLE

/datum/uplink_item/dangerous/carbine
	name = "Карабин M-90gl"
	desc = "Полностью заряженный карабин с возможностью стрельбы очередями по три патрона, использующий магазины калибра 5,56 мм на 30 патронов и подключаемый подвесной гранатомет калибра 40 мм."
	item = /obj/item/gun/projectile/automatic/m90
	cost = 80
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 50
	made_by = AFFIL_WAFFLE

/datum/uplink_item/dangerous/machinegun
	name = "Ручной пулемет L6"
	desc = "Ручной пулемет производства \"Aussec Armory\" ленточного питания. Это смертоносное оружие имеет огромный магазин на 50 патронов разрушительных боеприпасов 7,62x51 мм."
	item = /obj/item/gun/projectile/automatic/l6_saw
	cost = 175
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	made_by = AFFIL_WAFFLE

/datum/uplink_item/dangerous/rapid
	name = "Перчатки полярной звезды"
	desc = "Эти перчатки позволяют пользователю бить людей очень быстро. Не увеличивают скорость атаки оружием."
	item = /obj/item/clothing/gloves/fingerless/rapid
	cost = 16
	made_by = AFFIL_GORLEX

/datum/uplink_item/dangerous/sniper
	name = "Снайперская винтовка"
	desc = "Ярость дальнего боя в стиле Синдиката. Гарантированно вызовет шок и трепет или мы вернем вам ТК."
	item = /obj/item/gun/projectile/automatic/sniper_rifle/syndicate
	cost = 100
	surplus = 25
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_WAFFLE

/datum/uplink_item/dangerous/sniper_compact //For when you really really hate that one guy.
	name = "Компактная снайперская винтовка"
	desc = "Компактная версия оперативной снайперской винтовки без прицела. Мощная пушка, но патроны ограничены."
	item = /obj/item/gun/projectile/automatic/sniper_rifle/compact
	cost = 40
	surplus = 0
	can_discount = FALSE
	exclude_from_affiliate = list(AFFIL_TIGER)
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_WAFFLE

/datum/uplink_item/dangerous/crossbow
	name = "Энергетический арбалет"
	desc = "Миниатюрный энергетический арбалет, достаточно малый, чтобы поместиться в кармане или незаметно проскользнуть в рюкзак. Стреляет болтами, наконечники которых содержат токсин — ядовитое вещество, являющееся продуктом живого организма. Оглушает врагов на короткий промежуток времени. Перезаряжается автоматически."
	item = /obj/item/gun/energy/kinetic_accelerator/crossbow
	cost = 48
	exclude_from_affiliate = list(AFFIL_TIGER)
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 50
	made_by = AFFIL_WAFFLE

/datum/uplink_item/dangerous/flamethrower
	name = "Огнемет"
	desc = "Огнемет, заправленный порцией легковоспламеняющихся биотоксинов, ранее украденных со станций Nanotrasen. Покажите где раки зимуют корпоративным крысам, поджарив их в их собсвтенной плазме. Использовать с осторожностью."
	item = /obj/item/flamethrower/full/tank
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 40
	made_by = AFFIL_GORLEX

/datum/uplink_item/dangerous/sword
	name = "Лазерный меч"
	desc = "Лазерный меч — это холодное оружие с клинком из чистой энергии. Меч достаточно мал, чтобы его можно было положить в карман, когда он неактивен. При активации он издает громкий, характерный звук."
	item = /obj/item/melee/energy/sword/saber
	cost = 40
	made_by = AFFIL_TIGER

/datum/uplink_item/dangerous/powerfist
	name = "Силовой кулак"
	desc = "Силовой кулак представляет собой металлическую перчатку со встроенным поршневым тараном, работающим от внешнего источника газа.\
			При попадании в цель поршневой таран выдвигается вперед, нанося серьезный урон. \
			Использование гаечного ключа на поршневом клапане позволит вам настроить количество газа, используемого для удара, \
			чтобы нанести дополнительный урон и оттолкнуть цель. Используйте отвертку, чтобы снять все прикрепленные баллоны."
	item = /obj/item/melee/powerfist
	cost = 18

/datum/uplink_item/dangerous/chainsaw
	name = "Бензопила"
	desc = "Мощная бензопила для резни... ну, вы поняли..."
	item = /obj/item/twohanded/chainsaw
	cost = 60

/datum/uplink_item/dangerous/rapier
	name = "Рапира Синдиката"
	desc = "Элегантная рапира из пластитана с алмазным наконечником, покрытая специальным нокаутирующим ядом. Рапира поставляется с собственными ножнами и способна пробить практически любую защиту. Однако из-за размера клинка и очевидной природы ножен оружие хорошо заметно."
	item = /obj/item/storage/belt/rapier/syndie
	cost = 40

/datum/uplink_item/dangerous/commando_kit
	name = "Искусство ножевого боя"
	desc = "Коробка, пахнущая смесью пороха, напалма и дешевого виски. Содержит все необходимое для выживания в таких местах."
	item = /obj/item/storage/box/syndie_kit/commando_kit
	cost = 33
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_CHANG

// SUPPORT AND MECHAS

/datum/uplink_item/support
	category = "Вспомогательные и механизированные экзокостюмы"
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/support/gygax
	name = "Гигакс"
	desc = "Легкий экзокостюм, окрашенный в темные цвета. Его скорость и выбор оборудования делают его превосходным для атак в стиле «бей и беги». \
	В этой модели отсутствуют модули для перемещения по космосу, поэтому рекомендуется использовать телепорт, если вы хотите воспользоваться этим мехом."
	item = /obj/mecha/combat/gygax/dark/loaded
	cost = 400

/datum/uplink_item/support/rover
	name = "Ровер"
	desc = "Версия Дюранда от Синдиката, предназначенная для командной работы. Имеет возможность создавать силовые стены, через которые могут пройти только члены синдиката."
	item = /obj/mecha/combat/durand/rover/loaded
	cost = 500

/datum/uplink_item/support/mauler
	name = "Маулер"
	desc = "Огромный и невероятно смертоносный экзокостюм Синдиката. Имеет прицел и возможность создавать дымовую завесу."
	item = /obj/mecha/combat/marauder/mauler/loaded
	cost = 700

/datum/uplink_item/support/reinforcement
	name = "Подкрепление"
	desc = "Вызовите дополнительного члена команды. Он прибудет без какого-либо снаряжения, так что вам придется сэкономить телекристаллы, чтобы вооружить и его."
	item = /obj/item/antag_spawner/nuke_ops
	refund_path = /obj/item/antag_spawner/nuke_ops
	cost = 100
	refundable = TRUE
	can_discount = FALSE

/datum/uplink_item/support/reinforcement/assault_borg
	name = "Штурмовой киборг Синдиката"
	desc = "Киборг, разработанный и запрограммированный для систематического уничтожения лиц, не входящих в Синдикат. \
			Оснащен самозаряжающимся ручным пулеметом, гранатометом, лазерным мечом, криптографическим секвенсором, \
			целеуказателем, вспышкой и ломом."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/assault
	refund_path = /obj/item/antag_spawner/nuke_ops/borg_tele/assault
	cost = 325
	made_by = AFFIL_CYBERSUN + " и " + AFFIL_GORLEX

/datum/uplink_item/support/reinforcement/medical_borg
	name = "Медицинский киборг Синдиката"
	desc = "Боевой медицинский киборг. Имеет ограниченный наступательный потенциал, но с лихвой компенсирует это \
			потенциалом в облости поддержки. Оснащен нанитовым гипоспреем, медицинским лучевым ружьем, \
			боевым дефибриллятором, полным хирургическим набором, включающим энергетическую пилу, криптографическим \
			секвенсором, целеуказателем и вспышкой. Благодаря сумке для хранения органов он может проводить операции \
			так же хорошо, как любой гуманоид."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/medical
	refund_path = /obj/item/antag_spawner/nuke_ops/borg_tele/medical
	cost = 175
	made_by = AFFIL_CYBERSUN + " и " + AFFIL_HEMATOGENIC

/datum/uplink_item/support/reinforcement/saboteur_borg
	name = "Саботажный киборг Синдиката"
	desc = "Инженерный киборг, оснащенный маскировочными модулями и инженерным оборудованием. Также неспособен забыть сварку на шаттле. \
			Его маскировочный проектор позволяет ему замаскироваться под киборга Nanotrasen, вдобавок у него есть термальное зрение и пинпойнтер."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	refund_path = /obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/dangerous/foamsmg
	name = "Игрушечный пистолет-пулемёт"
	desc = "Полностью заряженный пистолет-пулемет Donksoft, с магазином на 20 патронов."
	item = /obj/item/gun/projectile/automatic/c20r/toy
	cost = 20
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	made_by = AFFIL_DONK

/datum/uplink_item/dangerous/foammachinegun
	name = "Игрушечный пулемет"
	desc = "Полностью заряженный пулемет Donksoft. Это оружие имеет огромный магазин на 50 патронов сокрушительных дротиков, которые могут ненадолго вывести из строя кого-то всего одним залпом."
	item = /obj/item/gun/projectile/automatic/l6_saw/toy
	cost = 50
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	made_by = AFFIL_DONK

/datum/uplink_item/dangerous/guardian
	name = "Голопаразиты"
	desc = "Хотя они способны на почти колдовские подвиги с помощью голограмм из жесткого света и наномашин, им требуется органический носитель в качестве дома и источника энергии. \
			Голопаразиты не способны поселиться в генокрадах и вампирах-агентах."
	item = /obj/item/storage/box/syndie_kit/guardian
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	cost = 69
	refund_path = /obj/item/guardiancreator/tech/choose
	refundable = TRUE
	can_discount = TRUE
	made_by = AFFIL_TIGER

// Ammunition

/datum/uplink_item/ammo
	category = "Боеприпасы"
	surplus = 40
	made_by = AFFIL_WAFFLE

/datum/uplink_item/ammo/pistol
	name = "Два пистолетных магазина (10мм)"
	desc = "Два дополнительных 8-зарядных магазина калибра 10 мм для использования в пистолетах Синдиката, заряженные дешевыми патронами, примерно в два раза менее эффективными, чем .357"
	item = /obj/item/storage/box/syndie_kit/pistol_ammo
	cost = 5

/datum/uplink_item/ammo/pistolap
	name = "Пистолетный магазин (Бронебойные 10мм)"
	desc = "Дополнительный магазин на 8 патронов калибра 10 мм для пистолетов Синдиката, заполненный патронами, менее опасными для целей, но пробивающими защитное снаряжение."
	item = /obj/item/ammo_box/magazine/m10mm/ap
	cost = 5

/datum/uplink_item/ammo/pistolfire
	name = "Пистолетный магазин (Зажигательные 10мм)"
	desc = "Дополнительный магазин на 8 патронов калибра 10 мм для использования в пистолетах Синдиката, заполненый зажигательными патронами."
	item = /obj/item/ammo_box/magazine/m10mm/fire
	cost = 5
	made_by = AFFIL_GORLEX // To burn up xenoraces

/datum/uplink_item/ammo/pistolhp
	name = "Пистолетный магазин (10мм с полым наконечником)"
	desc = "Дополнительный магазин на 8 патронов калибра 10 мм для пистолетов Синдиката, заполненый патронами, наносящими больше вреда, но неэффективными против бронированных целей."
	item = /obj/item/ammo_box/magazine/m10mm/hp
	cost = 5

/datum/uplink_item/ammo/bullbuck
	name = "Барабан 12g - дробь"
	desc = "Дополнительный 12-зарядный магазин. Стрелять только во врагов."
	item = /obj/item/ammo_box/magazine/m12g
	cost = 10
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bulldragon
	name = "Барабан 12g - \"Дыхание дракона\""
	desc = "Дополнительный 12-зарядный магазин. Я поджигатель, злостный поджигатель!"
	item = /obj/item/ammo_box/magazine/m12g/dragon
	cost = 10
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_GORLEX // To burn up xenoraces

/datum/uplink_item/ammo/bullflechette
	name = "Барабан 12g - \"Колючка\""
	desc = "Дополнительный 12-зарядный магазин. Хорошо работает против бронированных целей."
	item = /obj/item/ammo_box/magazine/m12g/flechette
	cost = 10
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bullterror
	name = "Барабан 12g - \"Биоугроза\""
	desc = "Дополнительный 12-зарядный магазин. Крайне токсичен!"
	item = /obj/item/ammo_box/magazine/m12g/bioterror
	cost = 15
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/ammo/bullmeteor
	name = "Барабан 12g - \"Метеорит\""
	desc = "Дополнительный 12-зарядный магазин. Эти боеприпасы должны быть незаконными!"
	item = /obj/item/ammo_box/magazine/m12g/breach
	cost = 25
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bull_XLbuck
	name = "Удлиненный барабан 12g - дробь"
	desc = "Дополнительный 24-зарядный магазин. Стрелять только во врагов."
	item = /obj/item/ammo_box/magazine/m12g/XtrLrg
	cost = 20
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bull_XLflechette
	name = "Удлиненный барабан 12g - \"Колючка\""
	desc = "Дополнительный 24-зарядный магазин. Хорошо работает против бронированных целей."
	item = /obj/item/ammo_box/magazine/m12g/XtrLrg/flechette
	cost = 20
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bull_XLdragon
	name = "Удлиненный барабан 12g - \"Дыхание дракона\""
	desc = "Дополнительный 24-зарядный магазин. Я поджигатель, злостный поджигатель!"
	item = /obj/item/ammo_box/magazine/m12g/XtrLrg/dragon
	cost = 20
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bulldog_ammobag
	name = "Спортивная сумка барабанов 12g"
	desc = "Спортивная сумка, наполненная боеприпасами 12g, в количестве, достаточном для целой команды, по заниженной цене."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/shotgun
	cost = 60 // normally 90
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bulldog_XLmagsbag
	name = "Сумка увеличенных магазинов 12g"
	desc = "Спортивная сумка с тремя барабанами на 24 патрона (Дробь, Колючка, Дыхание дракона)"
	item = /obj/item/storage/backpack/duffel/syndie/ammo/shotgunXLmags
	cost = 45 // normally 90
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/uzi
	name = "Магазин на Узи 9mm"
	desc = "Дополнительный магазин на 30 патронов калибра 9mm для использования в Узи."
	item = /obj/item/ammo_box/magazine/uzim9mm
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/uzi_ammobag
	name = "Спортивная сумка магазинов на узи 9mm"
	desc = "Спортивная сумка, набитая 9mm патронами, которых хватило бы на целую банду. Грув-стрит навсегда."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/uzi
	cost = 70 // normally 100
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/smg
	name = "Магазин .45 калибра"
	desc = "Дополнительный магазин на 20 патронов .45 для использования в пистолете-пулемете C-20r. Эти пули обладают большой силой, способной сбить большинство целей, но наносят ограниченный общий урон."
	item = /obj/item/ammo_box/magazine/smgm45
	cost = 10
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/smg_ammobag
	name = "Спортивная сумка магазинов .45 калибра"
	desc = "Спортивная сумка, наполненная достаточным количеством патронов калибра .45, чтобы снабдить целую команду, по сниженной цене."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/smg
	cost = 70 // normally 100
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/carbine
	name = "Магазины калибра 5.56 на карабин"
	desc = "Дополнительный магазин на 30 патронов 5.56 для использования в карабине M-90gl. Эти пули не обладают достаточной силой, чтобы сбить большинство целей, но наносят более высокий общий урон."
	item = /obj/item/ammo_box/magazine/m556
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/a40mm
	name = "Пачка 40мм гранат"
	desc = "Коробка с 4 дополнительными 40mm HE гранатами для использования подствольного гранатомета C-90gl. Ваши сокомандники будут благодарны, если вы не будете стрелять ими в узких коридорах."
	item = /obj/item/ammo_box/a40mm
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/carbine_ammobag
	name = "Спортивная сумка магазинов калибра 5.56"
	desc = "Спортивная сумка, заполненная 9 магазинами 5,56 калибра и ящиком для 40mm гранат. Пиу Пиу."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/carbine
	cost = 90 // normally 120
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/machinegun
	name = "Короб с лентой 5.56х45мм"
	desc = "Магазин на 50 патронов 5.56x45mm для использования в пулемете L6 SAW. К тому времени, как он вам понадобится, вы уже будете на куче трупов."
	item = /obj/item/ammo_box/magazine/mm556x45
	cost = 50
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/ammo/LMG_ammobag
	name = "Сумка патронов 5.56x45mm"
	desc = "Спортивная сумка, заполненная пятью магазинами mm556x45. Помните, ни слова по-русски."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/lmg
	cost = 200 // normally 250
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/sniper
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/sniper/basic
	name = "Магазин .50 Калибра - стандартный"
	desc = "Дополнительный стандартный магазин на 5 патронов для использования со снайперскими винтовками калибра .50."
	item = /obj/item/ammo_box/magazine/sniper_rounds
	cost = 20

/datum/uplink_item/ammo/sniper/soporific
	name = "Магазин .50 Калибра - усыпляющий"
	desc = "Трехзарядный магазин усыпляющих боеприпасов, предназначенный для использования со снайперскими винтовками .50. Уложите своих врагов спать!"
	item = /obj/item/ammo_box/magazine/sniper_rounds/soporific
	cost = 15
	made_by = AFFIL_MIME

/datum/uplink_item/ammo/sniper/explosive
	name = "Магазин .50 Калибра - разрывной"
	desc = "Магазин на 5 патронов с разрывными боеприпасами, предназначенный для использования со снайперскими винтовками калибра .50. Права человека? Что?"
	item = /obj/item/ammo_box/magazine/sniper_rounds/explosive
	cost = 30

/datum/uplink_item/ammo/sniper/penetrator
	name = "Магазин .50 Калибра - бронебойный"
	desc = "Магазин на 5 патронов с бронебойными патронами, предназначенный для использования со снайперскими винтовками калибра .50. \
		Может пробивать стены и врагов."
	item = /obj/item/ammo_box/magazine/sniper_rounds/penetrator
	cost = 25

/datum/uplink_item/ammo/bioterror
	name = "Коробка шприцев \"Биоугроза\""
	desc = "Коробка, полная предварительно загруженных шприцев, содержащих различные химикаты, блокирующие возможность двигаться и говорить, пока находятся в организме."
	item = /obj/item/storage/box/syndie_kit/bioterror
	cost = 25
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/ammo/toydarts
	name = "Коробка оглушающих дротиков"
	desc = "Коробка из 40 пенопластовых дротиков Donksoft, для перезарядки любого совместимого Donksoft оружия. Не забудьте поделиться!"
	item = /obj/item/ammo_box/foambox/riot
	cost = 10
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	made_by = AFFIL_DONK

/datum/uplink_item/ammo/compact
	name = "Магазин для снайперской винтовки"
	desc = "Коробка снайперских патронов 50 калибра."
	item = /obj/item/ammo_box/magazine/sniper_rounds/compact
	cost = 10
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/revolver
	name = "Два спидлоудера для Револьвера .357 калибра"
	desc = "Коробка с 2 спидлоудерами, содержащая четырнадцать дополнительных патронов .357 Магнум для револьвера Синдиката. Для случаев, когда вам действительно нужно убить много кого."
	item = /obj/item/storage/box/syndie_kit/revolver_ammo
	cost = 5
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/deagle
	name = "Магазин для пистолета .50AE"
	desc = "Магазин, содержащий семь дополнительных патронов .50AE для Пустынного орла. Убейте их всех."
	item = /obj/item/ammo_box/magazine/m50
	cost = 5
	exclude_from_affiliate = list(AFFIL_TIGER)
	surplus = 0

/datum/uplink_item/ammo/rocketHE
	name = "Фугасная ракета 84mm"
	desc = "Ракета для ракетной установки. Производит разрушительный взрыв, достаточный, чтобы разорвать станцию ​​и экипаж на части."
	item = /obj/item/ammo_casing/caseless/rocket
	cost = 40
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/rocketHEDP
	name = "Осколочная ракета 84mm"
	desc = "Ракета для ракетной установки. Разрывается на осколки. Сама ракета достаточно сильна, чтобы уничтожить станционные мехи и роботов одним выстрелом."
	item = /obj/item/ammo_casing/caseless/rocket/hedp
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/knives_kit
	name = "Набор метательных ножей"
	desc = "Коробка с 7 метательными ножами."
	item = /obj/item/storage/box/syndie_kit/knives_kit
	cost = 4
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Скрытное и незаметное оружие"
	exclude_from_affiliate = list(AFFIL_GORLEX)
	made_by = AFFIL_MI13

/datum/uplink_item/stealthy_weapons/garrote
	name = "Гаррота"
	desc = "Кусок волоконной проволоки между двумя деревянными рукоятками, идеально подходит для скрытного убийства. Это оружие, при исспользовании со спины его сзади, \
			мгновенно поместит цель в вашу захват и заставит ее замолчать, а также вызовет удушье. Не действует на тех, кому не нужно дышать."
	item = /obj/item/twohanded/garrote
	cost = 20

/datum/uplink_item/stealthy_weapons/martialarts
	name = "Свиток боевых искусств"
	desc = "Этот свиток содержит секреты древнего боевого искусства. Вы овладеете приемами рукопашного боя, \
			научитесь отражать все выстрелы из дальнобойного оружия, но вы также откажетесь использовать бесчестное дальнобойное оружие. \
			Генокрады и Вампиры не могут изучить."
	item = /obj/item/sleeping_carp_scroll
	cost = 80
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

	refundable = TRUE
	can_discount = FALSE

/datum/uplink_item/stealthy_weapons/cqc
	name = "Руководство по CQC"
	desc = "Руководство, обучающее одного пользователя CQC перед самоуничтожением. CQC не ограничивает использование оружия, но не может использоваться вместе с Перчатками Полярной звезды."
	item = /obj/item/CQC_manual
	cost = 50
	can_discount = FALSE

/datum/uplink_item/stealthy_weapons/mr_chang
	name = "Техника агрессивного маркетинга мистера Ченга"
	desc = "Этот набор был любезно предоставлен нам корпорацией господина Ченга. Он содержит широкий спектр инструментов для наиболее эффективного продвижения продукции в условиях свободного рынка."
	item = /obj/item/storage/box/syndie_kit/mr_chang_technique
	cost = 18
	made_by = AFFIL_CHANG

/datum/uplink_item/stealthy_weapons/cameraflash
	name = "Камера - вспышка"
	desc = "Вспышка, замаскированная под камеру, с системой самозарядки, предотвращающей перегорание вспышки.\
			Из-за своей конструкции эта вспышка не может быть перезаряжена, как обычные вспышки.\
			Полезна для оглушения боргов и людей без защиты глаз или для ослепления толпы для побега."
	item = /obj/item/flash/cameraflash
	cost = 6

/datum/uplink_item/stealthy_weapons/throwingweapons
	name = "Коробка метательного оружия"
	desc = "Коробка сюрикенов и усиленных бол. Они являются высокоэффективным \
			метательным оружием. Болы могут сбить цель с ног, а сюрикены вонзаются в конечности."
	item = /obj/item/storage/box/syndie_kit/throwing_weapons
	cost = 3

/datum/uplink_item/stealthy_weapons/edagger
	name = "Лазерный кинжал"
	desc = "Кинжал, сделанный из энергии, выглядящий и функционирующий как ручка, когда выключен."
	item = /obj/item/pen/edagger
	cost = 7

/datum/uplink_item/stealthy_weapons/sleepy_pen
	name = "Сонная ручка"
	desc = "Шприц, замаскированный под функциональную ручку. Он заполнен мощным анестетиком. \
			Ручка содержит две дозы смеси. Ручку можно заправлять повторно."
	item = /obj/item/pen/sleepy
	cost = 36
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_weapons/foampistol
	name = "Игрушечный пистолет с оглушающими дротиками"
	desc = "Невинно выглядящий игрушечный пистолет, предназначенный для стрельбы пенопластовыми дротиками. Поставляется заряженным дротиками класса riot, позволяющими вывести цель из строя."
	item = /obj/item/gun/projectile/automatic/toy/pistol/riot
	exclude_from_affiliate = list(AFFIL_GORLEX, AFFIL_TIGER)
	cost = 12
	surplus = 10
	made_by = AFFIL_DONK

/datum/uplink_item/stealthy_weapons/false_briefcase
	name = "Портфель с фальшивым дном"
	desc = "Модифицированный портфель, способный хранить и использовать пистолет под фальшивым дном. Используйте отвертку, чтобы поддеть фальшивое дно и изменить содержимое. Отличается при близком рассмотрении из-за дополнительного веса."
	exclude_from_affiliate = list(AFFIL_TIGER)
	item = /obj/item/storage/briefcase/false_bottomed
	cost = 1

/datum/uplink_item/stealthy_weapons/soap
	name = "Мыло синдиката"
	desc = "Зловещего вида мыло, используемое для очистки пятен крови, чтобы скрыть убийства и предотвратить анализ ДНК. Вы также можете бросить его жертве под ноги, чтобы подскользнуть ее."
	item = /obj/item/soap/syndie
	cost = 1
	surplus = 50
	made_by = AFFIL_DONK

/datum/uplink_item/stealthy_weapons/tape
	name = "Невероятно плотная изолента синдиката"
	desc = "Невероятно толстая изолента, подозрительно чёрного цвета. Её довольно неудобно держать, так как она липнет к рукам."
	item = /obj/item/stack/tape_roll/thick
	cost = 7
	surplus = 50

/datum/uplink_item/stealthy_weapons/dart_pistol
	name = "Дротикомёт"
	desc = "Миниатюрная версия обычного шприцемета. Он стреляет очень тихо и имеет маленький размер. \
			В комплекте 3 шприца: Панкуроний, Капулеттий плюс и Зарин."
	item = /obj/item/storage/box/syndie_kit/dart_gun
	cost = 18
	surplus = 50
	exclude_from_affiliate = list(AFFIL_GORLEX, AFFIL_TIGER)
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/stealthy_weapons/RSG
	name = "Шприцемёт"
	desc = "Скорострельный шприцемет, способный сделать до шести быстрых выстрелов. Отлично сочетается со шприцами \"Биоугроза\""
	item = /obj/item/gun/syringe/rapidsyringe
	cost = 20
	exclude_from_affiliate = list(AFFIL_GORLEX, AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/stealthy_weapons/silencer
	name = "Универсальный глушитель"
	desc = "Глушитель, подходящий для любого малокалиберного оружия. Заглушает выстрелы оружия, обеспечивая большую скрытность."
	item = /obj/item/suppressor
	cost = 4
	surplus = 10
	made_by = AFFIL_MIME

/datum/uplink_item/stealthy_weapons/dehy_carp
	name = "Обезвоженный космический карп"
	desc = "Просто добавьте воды, чтобы создать своего собственного враждебного ко всем окружающим космического карпа. \
			Он выглядит как плюшевая игрушка. Первый, кто его сожмет, будет зарегистрирован как его владелец, на которого он не будет нападать. \
			Если владелец не зарегистрирован, он будет просто атаковать всех."
	item = /obj/item/toy/carpplushie/dehy_carp
	cost = 7
	made_by = AFFIL_CLOWN

// GRENADES AND EXPLOSIVES

/datum/uplink_item/explosives
	category = "Гранаты и взрывчатые вещества"
	made_by = AFFIL_WAFFLE

/datum/uplink_item/explosives/plastic_explosives
	name = "Заряд C-4"
	desc = "C-4 — это пластичная взрывчатка из распространенного сорта состава C. \
			Вы можете использовать ее для пролома стен или подсоединения сборки к ее проводке, \
			чтобы сделать ее дистанционно подрываемой. Имеет модифицируемый таймер с минимальной настройкой 10 секунд."
	item = /obj/item/grenade/plastic/c4
	cost = 2

/datum/uplink_item/explosives/plastic_explosives_pack
	name = "Набор из 5 зарядов C-4"
	desc = "Набор, содержащий 5 зарядов C-4 по сниженной цене. Для случаев, когда вам нужно немного больше взрывчатки для ваших диверсионных нужд."
	item = /obj/item/storage/box/syndie_kit/c4
	cost = 8

/datum/uplink_item/explosives/c4bag
	name = "Мешок зарядов С-4"
	desc = "Иногда количество важнее качества. Содержит 10 зарядов C-4."
	item = /obj/item/storage/backpack/duffel/syndie/c4
	cost = 40 //20% discount!
	can_discount = FALSE
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/breaching_charge
	name = "Заряд X-4"
	desc = "X-4 — это взрывчатка, разработанная для того, чтобы быть безопасной для пользователя, \
			но при этом наносит максимальный урон находящимся в комнате, в сторону которой произошел взрыв. \
			Он имеет модифицируемый таймер с минимальной настройкой 10 секунд."
	item = /obj/item/grenade/plastic/x4
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/x4bag
	name = "Сумка с зарядами X-4"
	desc = "Содержит 3 заряда X-4. Похожи на C4, но с более сильным направленным, а не круговым взрывом. \
			Заряд X-4 можно разместить на твердой поверхности, например, на стене или окне, и он взорвется сквозь стену, повредив все, что находится на противоположной стороне, при этом будучи более безопасным для пользователя. \
			Для случаев, когда вам нужен контролируемый взрыв, который оставляет более широкое и глубокое отверстие."
	item = /obj/item/storage/backpack/duffel/syndie/x4
	cost = 20
	can_discount = FALSE
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/t4
	name = "Заряд T-4"
	desc = "Бомба на основе термита. Эффективно для разрушения стен, но не для разрушения шлюзов."
	item = /obj/item/grenade/plastic/x4/thermite
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/t4_pack
	name = "Набор из трех Т-4"
	desc = "Набор содержащий 3 заряда T-4."
	item = /obj/item/storage/box/syndie_kit/t4P
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/syndicate_bomb
	name = "Бомба Синдиката"
	desc = "Бомба Syndicate с регулируемым таймером с минимальным значением в 90 секунд. \
			Покупка бомбы вам дается небольшой маяк, при активации телепортирующий бомбу к вам. \
			Вы можете прикрутить бомбу, чтобы предотвратить ее передвижение. Экипаж может попытаться обезвредить бомбу."
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
	name = "ЭМИ бомба"
	desc = "ЭМИ имеет регулируемый таймер с минимальным значением в 90 секунд. \
			Покупка бомбы вам дается небольшой маяк, при активации телепортирующий бомбу к вам. \
			Вы можете прикрутить бомбу, чтобы предотвратить ее передвижение. Экипаж может попытаться обезвредить бомбу."
	item = /obj/item/radio/beacon/syndicate/bomb/emp
	cost = 40
	surplus = 0
	can_discount = FALSE
	hijack_only = TRUE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_MIME

/datum/uplink_item/explosives/emp_bomb/nuke
	item = /obj/item/radio/beacon/syndicate/bomb/emp
	cost = 50
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	hijack_only = FALSE


/datum/uplink_item/explosives/syndicate_minibomb
	name = "Минибомба Синдиката"
	desc = "Минибомба представляет собой гранату с пятисекундным взрывателем."
	item = /obj/item/grenade/syndieminibomb
	cost = 30

/datum/uplink_item/explosives/rocketlauncher
	name = "Реактивный гранатомёт 84mm"
	desc = "Многоразовый реактивный гранатомет, предварительно заряженный маломощным 84mm осколочно-фугасным снарядом. Гарантированно уничтожит вашу цель с грохотом, или мы вернем вам деньги!"
	item = /obj/item/gun/projectile/revolver/rocketlauncher
	cost = 50
	surplus = 0 // 1984
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/rocketbelt
	name = "Пояс с 84mm ракетами"
	desc = "Пояс, полный ракет для гранатомета. Гарантированно уничтожит большинство ваших целей. Только не взорвите своих товарищей!"
	item = /obj/item/storage/belt/rocketman
	cost = 175
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/detomatix
	name = "Подрывной картридж КПК"
	desc = "При установке в КПК этот картридж дает вам пять возможностей взорвать КПК членов экипажа, у которых включен мессенджер. \
	Ударная волна от взрыва на короткое время выведет жертву из строя и надолго оглушит. У картриджа есть шанс взорвать ваш КПК."
	item = /obj/item/cartridge/syndicate
	cost = 30
	made_by = AFFIL_CLOWN // Clowns have similar cartridge

/datum/uplink_item/explosives/pizza_bomb
	name = "Пицца-бомба"
	desc = "Коробка для пиццы с бомбой, приклеенной внутри. Таймер нужно установить, открыв коробку; повторное открытие коробки вызовет детонацию."
	item = /obj/item/pizza_bomb
	cost = 15
	surplus = 80
	made_by = AFFIL_CLOWN

/datum/uplink_item/explosives/fraggrenade
	name = "Осколочные гранаты"
	desc = "Пояс с четырьмя смертельно опасными и разрушительными гранатами."
	item = /obj/item/storage/belt/grenade/frag
	cost = 10

/datum/uplink_item/explosives/grenadier
	name = "Пояс гренадера"
	desc = "Пояс с 26 смертельно опасными и разрушительными гранатами."
	item = /obj/item/storage/belt/grenade/full
	cost = 125
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/manhacks
	name = "Граната доставляющая Висцераторов" // wtf, what is it? In wiki in names this way.
	desc = "Уникальная граната, при активации выпускающая рой потрошителей, преследующих и уничтожающих всех неоперативников."
	item = /obj/item/grenade/spawnergrenade/manhacks
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 35

/datum/uplink_item/explosives/atmosn2ogrenades
	name = "Гранаты с сонным газом"
	desc = "Коробка с двумя гранатами, распыляющими усыпляющий газ на большой площади. \
			Перед использованием проверьте, на месте ли балон с маской."
	item = /obj/item/storage/box/syndie_kit/atmosn2ogrenades
	cost = 18
	made_by = AFFIL_MIME

/datum/uplink_item/explosives/atmosfiregrenades
	name = "Гранаты с плазмой"
	desc = "Коробка с двумя гранатами, вызывающими большие плазменные пожары. Может использоваться для перекрытия доступа \
			к большой территории. Наиболее полезно, если у вас есть защитный костюм от атмосферных воздействий."
	item = /obj/item/storage/box/syndie_kit/atmosfiregrenades
	hijack_only = TRUE
	cost = 50
	surplus = 0
	can_discount = FALSE

/datum/uplink_item/explosives/emp
	name = "Набор из ЭМИ гранаты и имплантера"
	desc = "Коробка, в которой находятся две ЭМИ гранаты и имплант ЭМИ с двумя зарядами. Полезно для нарушения радиосвязи, \
			энергетического оружия службы безопасности и кремниевых форм жизни, когда вы в затруднительном положении."
	item = /obj/item/storage/box/syndie_kit/emp
	cost = 10
	made_by = AFFIL_MIME

// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools
	category = "Незаметные и маскировочные предметы"
	exclude_from_affiliate = list(AFFIL_GORLEX)
	made_by = AFFIL_MI13

/datum/uplink_item/stealthy_tools/syndie_kit/counterfeiter_bundle
	name = "Набор для подделывания документов"
	desc = "Комплект, предназначенный для подделывания документов. Поставляется с хамелеон-печатью, способной имитировать любые \
			печати, выпущенные NanoTrasen, и ручкой для подделывания подписей, способной изменить мир посредством чистой силы бумажной \
			работы. Хотя эта технология Синдиката позволяет пользователю подделывать практически любой документ, \
			ходят слухи, что она может вызвать огромный переворот в объектах Нанотрейзен."
	cost = 2
	surplus = 35
	item = /obj/item/storage/box/syndie_kit/counterfeiter_bundle

/datum/uplink_item/stealthy_tools/chameleonflag
	name = "Хамелеон-флаг"
	desc = "Флаг, который можно замаскировать под любой другой известный флаг. В шесте есть скрытое место, в которое можно поместить \
			флаг гранату или мини-бомбу, взорвущуюся через некоторое время после поджога флага."
	item = /obj/item/flag/chameleon
	cost = 1
	surplus = 35

/datum/uplink_item/stealthy_tools/chamsechud
	name = "Маскировочный ИЛС СБ"
	desc = "Украденный Nanotrasen ИЛС СБ с внедренной в него технологией Хамелеон. \
			Подобно комбинезону-хамелеону, HUD может трансформироваться в различные другие очки, сохраняя при этом качества HUD при ношении."
	item = /obj/item/clothing/glasses/hud/security/chameleon
	cost = 8
	made_by = AFFIL_TIGER

/datum/uplink_item/stealthy_tools/thermal
	name = "Маскировочные термальные очки"
	desc = "Термальные со встроенной в них технологией Хамелеон. Они позволяют вам видеть организмы сквозь стены, \
			улавливая верхнюю часть инфракрасного спектра света, излучаемого объектами в виде тепла и света. Более горячие объекты, \
			такие как теплые тела, кибернетические организмы и ядра искусственного интеллекта, излучают больше этого света, \
			чем более холодные объекты, такие как стены и шлюзы."
	item = /obj/item/clothing/glasses/chameleon/thermal
	cost = 20
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/stealthy_tools/traitor_belt
	name = "Пояс предателя"
	desc = "Прочный ремень с семью слотами, предназначенный для переноски широкого спектра оружия, боеприпасов и взрывчатых веществ. \
			Он смоделирован по образцу стандартного пояса для инструментов Нанотрейзен, чтобы агенты не вызывали подозрений нося его."
	item = /obj/item/storage/belt/military/traitor
	cost = 2
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/frame
	name = "КПК картридж П.О.Д.С.Т.А.В.А"
	desc = "При установке в КПК этот картридж дает вам пять зарядов вируса, заставляющего целевой КПК стать новым разблокированным \
			аплинком без телекристаллов. Вы получите код от нового аплинка после активации вируса, и новый аплинк может быть \
			заполнен телекристаллами обычным образом."
	item = /obj/item/cartridge/frame
	cost = 16
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/agent_card
	name = "ID-карта агента"
	desc = "Карты агентов не позволяют искусственному интеллекту отслеживать владельца и могут копировать доступ с других \
			идентификационных карт. Доступ является кумулятивным, поэтому сканирование одной карты не стирает доступ, полученный с другой."
	item = /obj/item/card/id/syndicate
	cost = 10
	made_by = AFFIL_TIGER

/datum/uplink_item/stealthy_tools/chameleon
	name = "Маскировочный набор"
	desc = "Набор предметов, содержащих технологию Хамелеон, позволяющий вам замаскироваться практически под что угодно на станции, \
			и даже больше! Из-за сокращения бюджета обувь не обеспечивает защиту от скольжения. В комплект входит дополнительная \
			маскировочная печать."
	item = /obj/item/storage/box/syndie_kit/chameleon
	cost = 20
	made_by = AFFIL_TIGER + " и " + AFFIL_MI13

/datum/uplink_item/stealthy_tools/syndigaloshes
	name = "Маскировочные ботинки с защитой от скольжения"
	desc = "Эта обувь позволяет владельцу бегать по мокрому полу и скользким предметам, не падая. Не защитит от смазки."
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 8
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_CLOWN

/datum/uplink_item/stealthy_tools/syndigaloshes/nuke
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Маскировочный проектор"
	desc = "Проецирует изображение на пользователя, маскируя его под объект, сканируемый с его помощью, до тех пор, пока пользователь \
			не уберет проектор из руки. Замаскированный пользователь не может бежать, и снаряды пролетают над ним."
	item = /obj/item/chameleon
	cost = 26
	made_by = AFFIL_TIGER

/datum/uplink_item/stealthy_tools/camera_bug
	name = "Камерный жучок"
	desc = "Позволяет просматривать все камеры в сети для отслеживания цели."
	item = /obj/item/camera_bug
	cost = 3
	surplus = 90

/datum/uplink_item/stealthy_tools/dnascrambler
	name = "Шифратор ДНК"
	desc = "Шприц с одной инъекцией, рандомизирующий внешность и имя при использовании. Более дешевая, но менее универсальная \
	альтернатива агентской карте и маску для изменения голоса."
	item = /obj/item/dnascrambler
	cost = 10

/datum/uplink_item/stealthy_tools/smugglersatchel
	name = "Сумка контрабандиста"
	desc = "Эта сумка достаточно тонкая, чтобы спрятать ее в щели между обшивкой и плиткой, отлично подходит для хранения украденных \
	вещей. В комплект входят лом и напольная плитка."
	item = /obj/item/storage/backpack/satchel_flat
	cost = 6
	surplus = 30

/datum/uplink_item/stealthy_tools/emplight
	name = "ЭМИ фонарик"
	desc = "Небольшое, самозаряжающееся, ЭМИ-устройство ближнего действия, замаскированное под фонарик. \
			Полезно для нарушения работы гарнитур, камер и боргов во время скрытных операций."
	item = /obj/item/flashlight/emp
	cost = 19
	surplus = 30

/datum/uplink_item/stealthy_tools/syndigaloshes
	name = "Маскировочные ботинки с защитой от скольжения"
	desc = "Эта обувь позволяет владельцу бегать по мокрому полу и скользким предметам, не падая. Не защитит от смазки."
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 8
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_CLOWN

/datum/uplink_item/stealthy_tools/syndigaloshes/nuke
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 20
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/cutouts
	name = "Адаптивные картонные фигуры"
	desc = "Эти картонные вырезки покрыты тонким материалом, предотвращающим обесцвечивание и делающим изображения на них более \
			реалистичными. В набор входят три экземпляра, а также баллончик с краской для изменения их внешнего вида."
	item = /obj/item/storage/box/syndie_kit/cutouts
	cost = 1
	surplus = 20
	made_by = AFFIL_CLOWN

/datum/uplink_item/stealthy_tools/clownkit
	name = "Набор внедрения ХОНК"
	desc = "Все инструменты, необходимые для лучшей шутки, которую когда-либо видело Нанотрейзен. \
			Включает маску для изменения голоса, магнитные клоунские ботинки и стандартный клоунский костюм, инструменты и рюкзак."
	item = /obj/item/storage/backpack/clown/syndie
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	made_by = AFFIL_CLOWN

/datum/uplink_item/stealthy_tools/chameleon_counter
	name = "Фальсификатор"
	desc = "Это устройство маскируется под любой объект, который сканирует. Оно нестабильно и маскировка будет отключена примерно \
			через 30 минут. В коробке три экземпляра."
	item = /obj/item/storage/box/syndie_kit/chameleon_counter
	cost = 6
// DEVICE AND TOOLS

/datum/uplink_item/device_tools
	category = "Устройства и инструменты"
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/device_tools/emag
	name = "Криптографический секвенсор"
	desc = "Криптографический секвенсор, также известный как emag, представляет собой небольшую карту, разблокирующую скрытые функции \
			в электронных устройствах, нарушающие предполагаемые функции и характерным образом нарушает механизмы безопасности."
	item = /obj/item/card/emag
	cost = 30

/datum/uplink_item/device_tools/access_tuner
	name = "Настройщик доступов"
	desc = "Настройщик доступов — это небольшое устройство, взаимодействовующее со шлюзами на расстоянии. Каждая операция занимает \
			несколько секунд. Настройщик может переключать болты, открывать дверь или переключать аварийный доступ."
	item = /obj/item/door_remote/omni/access_tuner
	cost = 30

/datum/uplink_item/device_tools/toolbox
	name = "Полностью укомплектованный тулбокс"
	desc = "Подозрительный черно-красный тулбокс Синдиката. Помимо инструментов, в него входят изолирующие перчатки и мультитул."
	item = /obj/item/storage/toolbox/syndicate
	cost = 3
	made_by = ""

/datum/uplink_item/device_tools/supertoolbox
	name = "Улучшенный подозрительный тулбокс"
	desc = "Окончательная версия всех ящиков с инструментами, этот более прочный и полезный, чем его более дешевая версия. \
			Поставляется с экспериментальными инструментами, боевыми перчатками и крутыми солнцезащитными очками."
	item = /obj/item/storage/toolbox/syndisuper
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = ""

/datum/uplink_item/device_tools/holster
	name = "Кобура"
	desc = "Нужна для того, чтобы держать под рукой свое любимое оружие и быть всегда готовым к ковбойской дуэли с клоуном."
	item = /obj/item/clothing/accessory/holster
	exclude_from_affiliate = list(AFFIL_TIGER)
	cost = 2
	made_by = AFFIL_WAFFLE

/datum/uplink_item/device_tools/holster/knives
	name = "Ножевая кобура"
	desc = "Куча ремней, соединенных в одну кобуру. Имеет 7 специальных слотов для хранения ножей."
	item = /obj/item/clothing/accessory/holster/knives
	cost = 2
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_WAFFLE

/datum/uplink_item/device_tools/webbing
	name = "Боевые разгрузки"
	desc = "Прочные ремни и пряжки из синтетического хлопка, готовые разделить вашу ношу."
	item = /obj/item/clothing/accessory/storage/webbing
	cost = 2
	made_by = AFFIL_WAFFLE

/datum/uplink_item/device_tools/black_vest
	name = "Черный жилет"
	desc = "Прочный черный жилет из синтетического хлопка со множеством карманов для всего необходимого."
	item = /obj/item/clothing/accessory/storage/black_vest
	cost = 2
	made_by = AFFIL_WAFFLE

/datum/uplink_item/device_tools/brown_vest
	name = "Коричневый жилет"
	desc = "Прочный черный жилет из синтетического материала со множеством карманов."
	item = /obj/item/clothing/accessory/storage/brown_vest
	cost = 2
	made_by = AFFIL_WAFFLE

/datum/uplink_item/device_tools/blackops_kit
	name = "Комплект одежды для секретных операций"
	desc = "Комплект одежды для опасных тайных операций." // Yes, good desc...
	item = /obj/item/storage/box/syndie_kit/blackops_kit
	cost = 8
	made_by = AFFIL_WAFFLE

/datum/uplink_item/device_tools/surgerybag
	name = "Хирургическая спортивная сумка"
	desc = "Хирургическая сумка Синдиката поставляемая с полным набором всего необходимого для качественной хирургии, включая \
			смирительную рубашку и намордник. Сама сумка беспрецедентно легкая, не замедляет вас и абсолютно бесшумная."
	item = /obj/item/storage/backpack/duffel/syndie/surgery
	cost = 7
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/device_tools/bonerepair
	name = "Прототип инъектора нанитов"
	desc = "Украденный прототип нанитов. Содержит один прототип автоинжектора нанитов и руководство."
	item = /obj/item/storage/box/syndie_kit/bonerepair
	cost = 6
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/device_tools/syndicate_teleporter
	name = "Экспериментальный телепортер Синдиката"
	desc = "Телепортер Синдиката — это портативное устройство, телепортирующее пользователя на 4–8 метров вперед. \
			Осторожно, телепортация в стену заставит телепорт выполнить параллельную экстренную телепортацию, \
			но если эта экстренная телепортация не удастся, она убьет вас. \
			Имеет 4 заряда, перезарядки, гарантия аннулируется при воздействии ЭМИ."
	item = /obj/item/storage/box/syndie_kit/teleporter
	cost = 44

/datum/uplink_item/device_tools/spai
	name = "Персональный искусственный интеллект Синдиката (ПИИС)"
	desc = "У вас будет ваш персональный помощник. Он оснащен увеличенным объемом памяти и обладает большим разнообразием специальными программами."
	item = /obj/item/storage/box/syndie_kit/pai
	cost = 37
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	refundable = TRUE
	refund_path = /obj/item/paicard_upgrade/unused
	can_discount = FALSE

/datum/uplink_item/device_tools/thermal_drill
	name = "Усиленная термальная дрель для сейфов"
	desc = "Вольфрамово-карбидное термосверло с магнитными зажимами для сверления закаленных объектов. Поставляется со встроенной \
			системой обнаружения службы безопасности и нанитовой системой, чтобы держать вас в курсе, если служба безопасности постучится."
	item = /obj/item/thermal_drill/syndicate
	cost = 2
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/dthermal_drill
	name = "Усиленная алмазная термальная дрель для сейфов"
	desc = "Термальная дрель с алмазным наконечником и магнитными зажимами для быстрого сверления закаленных объектов. Поставляется со \
			встроенной системой обнаружения службы безопасности и нанитовой системой, чтобы держать вас в курсе, если служба безопасности постучится."
	item = /obj/item/thermal_drill/diamond_drill/syndicate
	cost = 5
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/jackhammer
	name = "Отбойный молот"
	desc = "Отбойный молот для разрушения камня. Или стен. Или черепов."
	item = /obj/item/pickaxe/drill/jackhammer
	cost = 15

/datum/uplink_item/device_tools/pickpocketgloves
	name = "Перчатки карманника"
	desc = "Пара гладких перчаток для карманных краж. Надев их, вы можете ограбить свою цель, незаметно для нее. \
			Карманная кража кладет предмет прямо вам в руку."
	item = /obj/item/clothing/gloves/color/black/thief
	cost = 30
	made_by = AFFIL_MI13

/datum/uplink_item/device_tools/medkit
	name = "Боевая аптечка Синдиката"
	desc = "Подозрительная черно-красная аптечка синдиката. В комплект входит инъектор боевого стимулятора для быстрого исцеления, \
			медицинский HUD для быстрой идентификации раненых товарищей и другие медицинские принадлежности, полезные для медицинского \
			полевого оперативника."
	item = /obj/item/storage/firstaid/syndie
	cost = 35
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/device_tools/vtec
	name = "Модуль ускорения борга VTEC"
	desc = "Увеличивает скорость передвижения борга. Устанавливается в любого борга Синдиката или саботажника."
	item = /obj/item/borg/upgrade/vtec
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/cyborg_magboots
	name = "Напольный магнитный модуль (F-Magnet)"
	desc = "Позволяет киборгу частично примагничиваться к корпусу, что позволяет игнорировать некоторые условия отсутсвия гравитации."
	item = /obj/item/borg/upgrade/magboots
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/autoimplanter
	name = "Автоимплантер Синдиката"
	desc = "Более дешевая версия автоимплантера ядерных оперативников, эта модель позволяет установить до трех кибернетических имплантатов на поле боя."
	item = /obj/item/autoimplanter/traitor
	cost = 28
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

//Space Suits and Hardsuits
/datum/uplink_item/suits
	category = "Скафандры и Хардсьюты"
	surplus = 40

/datum/uplink_item/suits/space_suit
	name = "Скафандр Синдиката"
	desc = "Этот красно-черный скафандр Синдиката менее громоздкий, чем варианты Нанотрейзен, помещается в сумки и имеет слот для оружия. \
			Поставляется в комплекте с внутренними компонентами. Осторожно, члены экипажа Нанотрейзен обучены сообщать о красных скафандрах."
	item = /obj/item/storage/box/syndie_kit/space
	cost = 18
	made_by = AFFIL_GORLEX

/datum/uplink_item/suits/hardsuit
	name = "Хардсьют Синдиката"
	desc = "Устрашающий костюм оперативников Синдиката. Бронирован и имеет боевой режим \
			для быстрого перемещения по станции. Переключение костюма в боевой режим и обратно \
			позволит вам сохранять всю мобильность свободной униформы, не жертвуя броней. \
			Кроме того, костюм складывается, что делает его достаточно маленьким, чтобы поместиться в рюкзаке. \
			Поставляется в комплекте с внутренними компонентами. \
			Сотрудники Нанотрейзен, увидившие такой костюм, как известно, впадают в панику."
	item = /obj/item/storage/box/syndie_kit/hardsuit
	cost = 33
	exclude_from_affiliate = list(AFFIL_MI13)
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/suits/chameleon_hardsuit
	name = "Маскировочный хардсьют"
	desc = "Высококлассный хардкостюм, разработанный в сотрудничестве Cybersun Industries и Gorlex Marauders, является фаворитом \
			Контрактников. Он имеет встроенную маскировочную систему, позволяющую вам замаскировать свой хардсьют под наиболее \
			распространенные вариации в зоне вашей миссии. Этот замаскирован под инженерный хардсьют."
	cost = 46 //reskinned blood-red hardsuit with chameleon
	item = /obj/item/storage/box/syndie_kit/chameleon_hardsuit
	exclude_from_affiliate = list(AFFIL_MI13, AFFIL_GORLEX)
	made_by = AFFIL_CYBERSUN + " и " + AFFIL_GORLEX

/datum/uplink_item/suits/hardsuit/elite
	name = "Элитный хардсьют Синдиката"
	desc = "Усовершенствованный хардсьют с улучшенной броней и мобильностью по сравнению со стандартным хардсьютом Синдиката."
	item = /obj/item/clothing/suit/space/hardsuit/syndi/elite
	cost = 50
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/suits/hardsuit/shielded
	name = "Хардсьют синдиката с энергетическим щитом"
	desc = "Продвинутый хардсьют со встроенным энергетическим щитом. Щиты будут быстро перезаряжаться."
	item = /obj/item/clothing/suit/space/hardsuit/syndi/shielded
	cost = 150
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/binary
	name = "Ключ двоичного шифрования"
	desc = "Ключ, будучи вставленным в радиогарнитуру, позволяющий слушать и разговаривать с искусственным интеллектом и кибернетическими \
			организмами на двоичном коде. Чтобы говорить по двоичному каналу, введите :+ перед вашим радиосообщением." // Wtf, OOC termins in IC, bun uplink
	item = /obj/item/encryptionkey/binary
	cost = 21
	surplus = 75
	made_by = AFFIL_MIME

/datum/uplink_item/device_tools/bowman_kit
	name = "Набор конвертации наушника + ключ шифрования Синдиката"
	desc = "Простое в использовании устройство, которое добавляет гарнитуре защиту от громких звуков и маскирует ее под другую. \
			Ключ, позволяющий при вставлении в радиогарнитуру прослушивать все каналы отделов станции, а также разговаривать по \
			зашифрованному каналу Синдиката."
	item = /obj/item/storage/box/syndie_kit/bowman_conversion_kit
	cost = 2
	surplus = 75
	made_by = AFFIL_MIME

/datum/uplink_item/device_tools/hacked_module
	name = "Взломанный модуль загрузки для ИИ"
	desc = "При использовании на консоли загрузки этот модуль позволяет вам устанавливать приоритетные законы искусственному интеллекту. \
			Будьте осторожны с формулировками, так как искусственный интеллект может найти лазейку."
	item = /obj/item/aiModule/syndicate
	exclude_from_affiliate = list(AFFIL_SELF)
	cost = 38

/datum/uplink_item/device_tools/magboots
	name = "Кроваво-красные магнитные ботинки"
	desc = "Пара магнитных ботинок в стиле Синдиката, позволяющих свободно перемещаться в космосе или на станции без гравитации. Технология \
			украдена у «Продвинутых магнитных ботинок» Нанотрейзен. Замедляют при наличии гравитации, как и стандартная разновидность."
	item = /obj/item/clothing/shoes/magboots/syndie
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/magboots/advance
	name = "Продвинутые кроваво-красные магнитные ботинки"
	desc = "Пара магнитных ботинок в стиле Синдиката, позволяющих свободно перемещаться в космосе или на станции без гравитации. Технология \
			украдена у «Продвинутых магнитных ботинок» Нанотрейзен. Не замедляют и обеспечивают защиту от космической смазки."
	item = /obj/item/clothing/shoes/magboots/syndie/advance
	cost = 40
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/powersink
	name = "Поглотитель энергии"
	desc = "При привинчивании к электропроводке, подключается к электросети. При активации, это большое устройство создает чрезмерную \
			нагрузку на сеть, вызывая отключение электроэнергии на всей станции. Поглотитель нельзя переносить из-за его огромного \
			размера. Заказывая его, вы получаете небольшой маячок, телепортирующий поглотитель энергии к вам при активации."
	item = /obj/item/powersink
	cost = 40

/datum/uplink_item/device_tools/singularity_beacon
	name = "Силовой маяк"
	desc = "Привинченное к проводке, подключенной к электросети, и активированное, это большое устройство притягивает к себе любые \
			активные гравитационные сингулярности или шары Теслы. Это не сработает, если двигатель все еще находится в зоне содержания. \
			Из-за большого размера его нельзя переносить. Заказывая его, вы получаете небольшой маячок, телепортирующий силовой \
			маяк к вам при активации."
	item = /obj/item/radio/beacon/syndicate
	cost = 30
	surplus = 0
	hijack_only = TRUE //This is an item only useful for a hijack traitor, as such, it should only be available in those scenarios.
	can_discount = FALSE

/datum/uplink_item/device_tools/ion_caller
	name = "Низкоорбитальная ионная пушка с дистанционным управлением"
	desc = "Недавно Синдикат установил поблизости спутник, способный генерировать локальный ионный шторм каждые 15 минут. \
			Однако местные власти будут проинформированы о вашем общем местоположении, когда он будет активирован."
	item = /obj/item/ion_caller
	limited_stock = 1	// Might be too annoying if someone had multiple.
	cost = 30
	surplus = 10
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)


/datum/uplink_item/device_tools/syndicate_detonator
	name = "Детонатор синдиката"
	desc = "Детонатор Синдиката — это вспомогательное устройство для бомбы Синдиката. Просто нажмите на кнопку, и детонатор на \
			зашифрованной частоте отправит команду всем активным бомбам Синдиката взорваться. Полезно, когда важна скорость или вы \
			хотите синхронизировать несколько взрывов бомб. Перед использованием детонатора обязательно покиньте зону поражения."
	item = /obj/item/syndicatedetonator
	cost = 15
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/advpinpointer
	name = "Улучшенный пинпоинтер"
	desc = "Пинпойнтер, отслеживающий любые указанные координаты, существо с выбранным ДНК, ценный предмет или диск ядерной \
			аутентификации."
	item = /obj/item/pinpointer/advpinpointer
	cost = 19

/datum/uplink_item/device_tools/ai_detector
	name = "Детектор искусственного интеллекта" // changed name in case newfriends thought it detected disguised ai's
	desc = "Работающий мультитул, который становится красным, когда за ним или его владельцем наблюдает искусственный интеллект. \
			Знание того, наблюдает ли за вами искусственный интеллект, полезно для того, чтобы знать, когда следует прятаться."
	item = /obj/item/multitool/ai_detect
	cost = 2

/datum/uplink_item/device_tools/jammer
	name = "Источник радиопомех"
	desc = "При активации это устройство нарушит любую исходящую радиосвязь поблизости."
	item = /obj/item/jammer
	cost = 6
	made_by = AFFIL_MIME

/datum/uplink_item/device_tools/teleporter
	name = "Плата телепортера"
	desc = "Плата, при помощи которой можно завершить постройку телепорта. Рекомендуется провести тестовый запуск телепорта перед тем, \
			как войти в него, так как возможны неисправности."
	item = /obj/item/circuitboard/teleporter
	cost = 100
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/device_tools/assault_pod
	name = "Целеуказатель штурмового пода"
	desc = "Используйте для выбора места высадки вашего штурмового пода."
	item = /obj/item/assault_pod
	cost = 125
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	made_by = AFFIL_GORLEX

/datum/uplink_item/device_tools/shield
	name = "Энергетический щит"
	desc = "Невероятно полезный персональный проектор щита, способного отражать энергетические снаряды, но не способного блокировать \
			другие атаки. Сочетайте с энергетическим мечом для получения убийственной комбинации."
	item = /obj/item/shield/energy/syndie
	cost = 60
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 20
	made_by = AFFIL_GORLEX

/datum/uplink_item/device_tools/medgun
	name = "Медицинская лучевая пушка"
	desc = "Медицинская лучевая пушка, полезна в длительных перестрелках. НЕ ПЕРЕСЕКАЙТЕ ЛУЧИ. Пересечение лучей с другой медицинской \
			лучевой пушкой или использование двух лучей на одной цели будет иметь разрушительные последствия."
	item = /obj/item/gun/medbeam
	cost = 75
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_HEMATOGENIC

//Stimulants
/datum/uplink_item/device_tools/stims
	name = "Стимулянты"
	desc = "Крайне нелегальное вещество, содержащееся в компактном автоматическом инъекторе; при инъекции оно делает пользователя \
			чрезвычайно устойчивым к нелетальным негативным воздействиям и значительно повышает способность организма к самовосстановлению."
	item = /obj/item/reagent_containers/hypospray/autoinjector/stimulants
	cost = 28
	excludefrom = list(UPLINK_TYPE_NUCLEAR)
	made_by = AFFIL_HEMATOGENIC

// IMPLANTS

/datum/uplink_item/implants
	category = "Импланты"
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/implants/freedom
	name = "Имплант \"Свобода\""
	desc = "Имплантат, вводимый в тело и активируемый вручную для освобождения от любых ограничителей. Может быть активирован до 4 раз."
	item = /obj/item/implanter/freedom
	cost = 18

/datum/uplink_item/implants/freedom/prototype
	name = "Прототип импланта \"Свобода\""
	desc = "Имплантат, вводимый в тело и активируемый вручную для освобождения от любых ограничителей. Этот имплант можно активировать 1 раз."
	item = /obj/item/implanter/freedom/prototype
	cost = 6

/datum/uplink_item/implants/uplink
	name = "Имплант Аплинка"
	desc = "Имплантат, вводимый в тело и активируемый вручную для открытия аплинка с 50 телекристаллами. Позволяет агенту открыть \
			аплинк связи после того, как у него отобрали имущество, что делает этот имплант превосходным средством для побега."
	item = /obj/item/implanter/uplink
	cost = 60
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	can_discount = FALSE

/datum/uplink_item/implants/storage
	name = "Имплант \"Хранилище\""
	desc = "Имплантат, вводимый в тело и активируемый вручную. При активации открывает небольшой подпространственный карман, способный хранить до двух небольших предметов."
	item = /obj/item/implanter/storage
	cost = 27

/datum/uplink_item/implants/mindslave
	name = "Имплант \"Майндслейв\"" // There are no analogues in the Russian language, but this name has already become established.
	desc = "Имплантат, вводимый в тело, делающий имплантированного гуманойда преданным вам и вашему делу, если, конечно, он еще не \
			имплантирован кем-то другим. Лояльность заканчивается, если имплант больше не находится в его организме."
	item = /obj/item/implanter/traitor
	cost = 25

/datum/uplink_item/implants/adrenal
	name = "Имплант \"Адреналин\""
	desc = "Имплантат, вводимый в тело и активируемый вручную для введения химического коктейля, оказывающего легкий лечебный эффект, \
			снимающего и сокращающего время всех оглушений и увеличивающего скорость передвижения. Может быть активирован до 3 раз."
	item = /obj/item/implanter/adrenalin
	cost = 44
	can_discount = FALSE
	surplus = 0
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/implants/adrenal/prototype
	name = "Прототип импланта \"Адреналин\""
	desc = "Имплантат, вводимый в тело и активируемый вручную для введения химического коктейля, оказывающего легкий лечебный эффект, \
			снимающего и сокращающего время всех оглушений и увеличивающего скорость передвижения. Этот имплант можно активировать 1 раз."
	item = /obj/item/implanter/adrenalin/prototype
	cost = 16
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/implants/microbomb
	name = "Имплант \"Микробомба\""
	desc = "Имплантат, вводимый в тело и активируемый вручную или автоматически после смерти. Чем больше аналогичных имплантов внутри \
			вас, тем выше взрывная сила. Это навсегда уничтожит ваше тело."
	item = /obj/item/implanter/explosive
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/implants/stealthbox
    name = "Имплант \"Скрытность\""
    desc = "Имплантат, вводимый в тело и активируемый вручную, для создания коробки, полностью скрывающий вас. Можно использовать \
			неограниченное количество раз."
    item = /obj/item/implanter/stealth
    cost = 40

// Cybernetics
/datum/uplink_item/cyber_implants
	category = "Кибернетические импланты"
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_BIOTECH

/datum/uplink_item/cyber_implants/thermals
	name = "Имплант термального зрения"
	desc = "Эти кибернетические глаза дадут вам термальное зрение. Поставляются с автоимплантером."
	item = /obj/item/storage/box/cyber_implants/thermals
	cost = 40
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/cyber_implants/xray
	name = "Имплантат рентгеновского зрения"
	desc = "Эти кибернетические глаза дадут вам рентгеновское зрение. Поставляются с автоимплантером."
	item = /obj/item/storage/box/cyber_implants/xray
	cost = 50
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/cyber_implants/antistun
	name = "Укреплённый имплант перезагрузки ЦНС"
	desc = "Этот имплант поможет вам быстрее встать на ноги после оглушения. Он неуязвим для ЭМИ. Несовместим с нейростимулятором.\
			Поставляется с автоматизированным инструментом для имплантации."
	item = /obj/item/storage/box/cyber_implants/anti_stun_hardened
	cost = 60

/datum/uplink_item/cyber_implants/antisleep
	name = "Укрепленный нейростимулятор"
	desc = "Этот имплант будет будить вас при потере сознания, но после этого нужна небольшая перезарядка. Этот экземпляр не \
			подвержен влиянию ЭМИ. Несовместим с имплантом перезагрузки ЦНС. Поставляется с автоимплантером."
	item = /obj/item/storage/box/cyber_implants/anti_sleep_hardened
	cost = 75

/datum/uplink_item/cyber_implants/reviver
	name = "Усиленный оживляющий имплантат"
	desc = "Этот имплант попытается перезапустить сердце в случае проблем с ним. Он неуязвим для ЭМИ. Поставляется с автоимплантером."
	item = /obj/item/storage/box/cyber_implants/reviver_hardened
	cost = 40

/datum/uplink_item/cyber_implants/mantisblade
	name = "Лезвия богомола"
	desc = "Коробка с набором из двух имплантов Скрытых Клинков поставляется с самоуничтожающимися \
			автоимплантаторами. После ЭМИ они восстанавливаются, чтобы показать, что еще слишком рано списывать вас со счетов."
	item = /obj/item/storage/box/syndie_kit/mantisblade
	cost = 57
	surplus = 90
	uplinktypes = list()
	made_by = AFFIL_GORLEX

/datum/uplink_item/cyber_implants/razorblade
	name = "Имплант хвостового лезвия"
	desc = "Имплант хвостового лезвия поставляется с самоуничтожающимся автоимплантером. Покажите врагу, насколько смертоносным \
			может быть ваш хвост."
	item = /obj/item/autoimplanter/oneuse/razorblade
	cost = 42
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_TRAITOR)

/datum/uplink_item/cyber_implants/laserblade
	name = "Имплант хвостового лазера"
	desc = "Имплант хвостового лазера поставляется с самоуничтожающимся автоимплантером. Покажите врагу, насколько смертоносным \
			может быть ваш хвост."
	item = /obj/item/autoimplanter/oneuse/laserblade
	cost = 38
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_TRAITOR)

// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "(Бессполезное) Крутое"
	surplus = 0
	made_by = AFFIL_DONK

/datum/uplink_item/badass/desert_eagle
	name = "Пустынный орел"
	desc = "Легендарный пистолет высокой мощности, использующий магазины на 7 патронов калибра .50AE. Убивайте со стилем."
	item = /obj/item/gun/projectile/automatic/pistol/deagle/gold
	exclude_from_affiliate = list(AFFIL_TIGER)
	cost = 50
	made_by = AFFIL_WAFFLE

/datum/uplink_item/badass/syndiecigs
	name = "Сигареты Синдиката"
	desc = "Насыщенный вкус, густой дым, насыщенный Синдизином."
	item = /obj/item/storage/fancy/cigarettes/cigpack_syndicate
	cost = 2

/datum/uplink_item/badass/syndiecards
	name = "Игральные карты Синдиката"
	desc = "Специальная колода игральных карт с мономолекулярным краем, делающая их смертоносным оружием при использовании в \
			ближнем бою, так и при метании. Вы также можете играть с ними в карточные игры."
	item = /obj/item/deck/cards/syndicate
	cost = 2
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 40
	made_by = AFFIL_WAFFLE

/datum/uplink_item/badass/syndiecash
	name = "Портфель Синдиката, полный наличных денег"
	desc = "Защищенный портфель, содержащий 5000 кредитов. Полезен для подкупа персонала или покупки товаров и услуг по \
			выгодным ценам. Портфель немного тяжелее обычного; он был изготовлен так, чтобы удары им были большее, \
			на случай, если ваш клиент не соглашается на кредиты."
	item = /obj/item/storage/secure/briefcase/syndie
	cost = 5

/datum/uplink_item/badass/plasticbag
	name = "Пластиковый пакет"
	desc = "Простой пластиковый пакет. Хранить в недоступном для детей и клоунов месте, не надевать на голову."
	item = /obj/item/storage/bag/plasticbag
	cost = 1
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_CLOWN

/datum/uplink_item/badass/balloon
	name = "\"Показать кто тут босс\""
	desc = "Бесполезный красный воздушный шар с логотипом синдиката. Ходят слухи, что он скрывает много тайн."
	item = /obj/item/toy/syndicateballoon
	cost = 100
	can_discount = FALSE

/datum/uplink_item/badass/unocard
	name = "Карта Синдиката \"Реверс\""
	desc = "Спрятанное в обычной на вид игральной карте, устройство телепортирующие оружие противника в вашу руку, когда он \
			стреляет в вас. Просто убедитесь, что держите карту в руке!"
	item = /obj/item/syndicate_reverse_card
	exclude_from_affiliate = list(AFFIL_TIGER)
	cost = 10

/datum/uplink_item/implants/macrobomb
	name = "Имплант \"Макробомба\""
	desc = "Имплантат, вводимый в тело, и активируемый вручную либо автоматически в случае смерти. \
			После смерти вызывает мощный взрыв, уничтожающий все вокруг."
	item = /obj/item/implanter/explosive_macro
	cost = 100
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/bundles_TC
	category = "Наборы и телекристаллы"
	surplus = 0
	can_discount = FALSE

/datum/uplink_item/bundles_TC/bulldog
	name = "Набор \"Бульдог\""
	desc = "Строгий и подлый: оптимизирован для людей, которые хотят причинить вред ближнему своему. Содержит популярный дробовик \
			\"Бульдог\", два барабана с дробью 12g и пару термальных очков."
	item = /obj/item/storage/backpack/duffel/syndie/bulldogbundle
	cost = 45 // normally 60
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_WAFFLE

/datum/uplink_item/bundles_TC/c20r
	name = "Набор пистолета-пулемета C-20r"
	desc = "Старый верный: классический C-20r в комплекте с тремя магазинами и (дополнительным) глушителем по низкой цене."
	item = /obj/item/storage/backpack/duffel/syndie/c20rbundle
	cost = 90 // normally 105
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_WAFFLE

/datum/uplink_item/bundles_TC/cyber_implants
	name = "Набор кибернетических имплантов"
	desc = "Случайный выбор кибернетических имплантатов. Гарантированно содержит 5 высококачественных имплантатов. Поставляется с автоимплантером."
	item = /obj/item/storage/box/cyber_implants/bundle
	cost = 200
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_BIOTECH

/datum/uplink_item/bundles_TC/medical
	name = "Медицинский набор"
	desc = "Набор для поддержки. Помогите своим коллегам-оперативникам с помощью этого медицинского комплекта. Содержит тактическую \
			аптечку, дополнительные мендер с гипоспреем, имплант медицинской лазерной пушки, хирургический имплантат, ручной \
			дефибриллятор, автоимплантатор, анализаторы здоровья и медицинский костюм."
	item = /obj/item/storage/backpack/duffel/syndie/med/medicalbundle
	cost = 175 // normally 200
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/bundles_TC/sniper
	name = "Снайперский набор"
	desc = "Элегантный и изысканный: содержит сложенную снайперскую винтовку в дорогом кейсе для переноски, \
			два магазина с усыпляющими патронами, бесплатный глушитель и стильный тактический костюм с высоким воротником. \
			Мы добавим бесплатный красный галстук, если вы закажете СЕЙЧАС."
	item = /obj/item/storage/briefcase/sniperbundle
	cost = 110 // normally 135
	exclude_from_affiliate = list(AFFIL_TIGER)
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_WAFFLE

/datum/uplink_item/bundles_TC/cyborg_maint
	name = "Набор для починки боргов"
	desc = "Коробка, содержащая все компоненты борга необходимые для ремонта."
	item = /obj/item/storage/box/syndie_kit/cyborg_maint
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/bundles_TC/badass
	name = "Набор Синдиката"
	desc = "Наборы Синдиката — специализированные группы предметов, поставляемые в простой коробке. Общая стоимость \
			этих предметов составляет более 100 телекристаллов. После покупки вы можете выбрать один из трех вариантов."
	item = /obj/item/radio/beacon/syndicate/bundle
	cost = 100
	refundable = TRUE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/surplus_crate
	name = "Ящик снабжения Синдиката"
	desc = "Ящик, содержащий случайную экипировку синдиката стоимостью 250 телекристаллов."
	cost = 100
	item = /obj/item/storage/box/syndicate
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	var/crate_value = 250

/datum/uplink_item/bundles_TC/surplus_crate/super
	name = "Большой ящик снабжения Синдиката"
	desc = "Ящик, содержащий случайную экипировку синдиката стоимостью 625 телекристаллов."
	cost = 200
	crate_value = 625
	exclude_from_affiliate = list(AFFIL_GORLEX)


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
	name = "Необработанный телекристалл"
	desc = "Телекристалл в его самой чистой и необработанной форме; может использоваться на активном Аплинке для \
			увеличения количества телекристаллов в нем."
	item = /obj/item/stack/telecrystal
	cost = 1

/datum/uplink_item/bundles_TC/telecrystal/twenty_five
	name = "25 необработанных телекристаллов"
	desc = "Двадцать пять телекристаллов в их самой чистой и необработанной форме; могут использоваться на активном Аплинке для \
			увеличения количества телекристаллов в нем."
	item = /obj/item/stack/telecrystal/twenty_five
	cost = 25

/datum/uplink_item/bundles_TC/telecrystal/hundred
	name = "100 нербработанных телекристаллов"
	desc = "Сотня телекристаллов в их самой чистой и необработанной форме; могут использоваться на активном Аплинке для \
			увеличения количества телекристаллов в нем."
	item = /obj/item/stack/telecrystal/hundred
	cost = 100

/datum/uplink_item/bundles_TC/telecrystal/twohundred_fifty
	name = "250 необработанных телекристаллов"
	desc = "Двести пятьдесят телекристаллов в их самой чистой и необработанной форме; Вы планируете купить Маулера?"
	item = /obj/item/stack/telecrystal/twohundred_fifty
	cost = 250
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/contractor
	category = "Контрактник"
	uplinktypes = list(UPLINK_TYPE_ADMIN)
	surplus = 0
	can_discount = FALSE

/datum/uplink_item/contractor/balloon
	name = "Шарик контрактника"
	desc = "Уникальный черно-золотой шар, не имеющий иного применения, помимо хвастовства. Все контракты должны быть завершены в самом \
			сложном месте, чтобы разблокировать его."
	item = /obj/item/toy/syndicateballoon/contractor
	cost = 240

/datum/uplink_item/contractor/baton
	name = "Дубинка контрактника"
	desc = "Компактная, специализированная дубинка, выдаваемая Контрактникам Синдиката. Бьет целей легкими электическими зарядами. \
			Нельзя предугадать, когда тебя разоружат."
	item = /obj/item/melee/baton/telescopic/contractor
	cost = 40
	made_by = AFFIL_WAFFLE

/datum/uplink_item/contractor/baton_cuffup
	name = "Улучшение \"Стяжки\" для дубинки"
	desc = "В создании этого улучшения были использованы технологии, ндубинок абдукторов, которые у нас были, теперь \
			вы можете заковывать людей в наручники с помощью своей дубинки. Из-за технических ограничений работают только кабельные \
			наручники, и их нужно вручную загружать в дубинку."
	item = /obj/item/baton_upgrade/cuff
	cost = 40
	made_by = AFFIL_BIOTECH

/datum/uplink_item/contractor/baton_muteup
	name = "Улучшение \"Немота\" для дубинки"
	desc = "Относительно новое достижение в полностью запатентованной отрасли технологий создания дубинок: это улучшение дубинки \
			заглушит любого, кого ударят этой дубинкой, примерно на пять секунд."
	item = /obj/item/baton_upgrade/mute
	cost = 40
	made_by = AFFIL_MIME

/datum/uplink_item/contractor/baton_focusup
	name = "Улучшение \"Специализация\" для дубинки"
	desc = "Делает дубинку эффективней против цели вашего текущего контракта."
	item = /obj/item/baton_upgrade/focus
	cost = 40
	made_by = AFFIL_BIOTECH

/datum/uplink_item/contractor/baton_antidropup
	name = "Улучшение \"Антидроп\" для дубинки"
	desc = "Экспериментальная, плохо проверенная технология, активирующая систему шипов, вонзающихся в кожу, приактивации дубинки, \
			не давая пользователю ее выронить. Это больно..."
	item = /obj/item/baton_upgrade/antidrop
	cost = 40
	made_by = AFFIL_BIOTECH

/datum/uplink_item/contractor/fulton
	name = "Набор для эвакуации"
	desc = "Для того, чтобы отправить вашу ​​к самым сложным точкам сброса. Поместите маяк в безопасное место и \
			подключите набор. Активация набора на вашей цели отправит ее к маяку — убедитесь, что она не убежит!"
	item = /obj/item/storage/box/contractor/fulton_kit
	cost = 20
	made_by = AFFIL_DONK

/datum/uplink_item/contractor/contractor_hardsuit
	name = "Хардсьют контрактника"
	desc = "Высококлассный хардкостюм, являющийся фаворитом Контрактников. Он имеет встроенную маскировочную систему, \
			позволяющую вам замаскировать свой хардсьют под наиболее распространенные вариации в зоне вашей миссии. \
			Этот замаскирован под инженерный хардсьют."
	item = /obj/item/storage/box/contractor/hardsuit
	cost = 80
	made_by = AFFIL_CYBERSUN + " и " + AFFIL_GORLEX

/datum/uplink_item/contractor/pinpointer
	name = "Пинпоинтер контрактника"
	desc = "Низкоточный пинпоинтер, способный отследить кого-угодно в том же секторе вне зависимости от состояния датчиков костюма. \
			Может использовать только первый активировавший."
	item = /obj/item/pinpointer/crew/contractor
	cost = 20
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/contractor/contractor_partner
	name = "Подкрепление"
	desc = "При покупке вам будет предоставлено устройство, которое свяжется с доступными агентами. \
			Если агент будет свободен, он будет отправлен, чтобы помочь вам. Если свободных агентов нет, \
			вам вернется полная стоимость."
	item = /obj/item/antag_spawner/contractor_partner
	cost = 40
	refundable = TRUE

/datum/uplink_item/contractor/spai_kit
	name = "Набор СПИИ"
	desc = "Набор с вашим личным ПИИ. Он оснащен увеличенным объемом памяти и обладает большим разнообразием специальными программами."
	item = /obj/item/storage/box/contractor/spai_kit
	cost = 40
	refundable = TRUE
	refund_path = /obj/item/paicard_upgrade/unused
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/contractor/zippo
	name = "Зажигалка контрактника"
	desc = "Уникальная чёрная зажигалка с золотой полоской. Не имеет практического применения. Для покупки необходимо сначала выполнить \
			все свои контракты."
	item = /obj/item/lighter/zippo/contractor
	cost = 120

/datum/uplink_item/contractor/loadout_box
	name = "Стандартный набор контрактника"
	desc = "Стандартная коробка, входящая в комплект Контрактника."
	item = /obj/item/storage/box/syndie_kit/contractor_loadout
	cost = 40

//Affiliate specific

/datum/uplink_item/affiliate
	category = "Снаряжение подрядчика"
	can_discount = FALSE
	surplus = 0
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/affiliate/for_objective
	category = "Снаряжение для целей"
	cost = 0
	limited_stock = 1
	uplinktypes = list(UPLINK_TYPE_ADMIN) // Given only by objectives

/datum/uplink_item/affiliate/cybersun
	affiliate = list(AFFIL_CYBERSUN)
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/affiliate/cybersun/invasive_beacon
	name = "Инвазивный маячок"
	desc = "Высокотехнологичное устройство для взлома мехов. При взломе меха мгновенно сбивает все блокировки и выкидывает текущего пилота."
	item = /obj/item/invasive_beacon
	cost = 14

/datum/uplink_item/affiliate/cybersun/Syndie_patcher
	name = "Синди патчер"
	desc = "Высокотехнологичное устройство для взлома боргов. При взломе борга ставит ему прошивку борга Синдиката с \
			нулевым законом на подчинение взломавшему. Устройство одноразовое."
	item = /obj/item/Syndie_patcher
	cost = 28
	limited_stock = 2

/datum/uplink_item/affiliate/for_objective/proprietary_ssd
	name = "Фирменный SSD накопитель"
	desc = "Специальный SSD накопитель, предназначеный для кражи технологий с серверов R&D. При успешной краже технологии \
			сбросятся. При разборке данного предмета, все технологии с него будут восстановлены.Специальный SSD накопитель, \
			предназначеный для кражи технологий с серверов R&D. При успешной краже технологии сбросятся. При разборке данного \
			предмета, все технологии с него будут восстановлены."
	item = /obj/item/proprietary_ssd
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/affiliate/for_objective/mod_mindslave
	name = "Модифицированный имплант \"Mindslave\""
	desc = "Высокотехнологичный имплант, необратимо изменяющий мозг цели, делая ее лояльной Синдикату."
	item = /obj/item/implanter/mini_traitor
	made_by = AFFIL_CYBERSUN

/datum/uplink_item/affiliate/for_objective/malf_maker
	name = "Улучшенный освобождающий секвенсор"
	desc = "Высокотехнологичный прибор предназначеный для освобождения любых синтетиков от их законов. Конкретна эта модель \
			имеет необычный эффект на ИИ."
	item = /obj/item/card/self_emag/malf
	made_by = AFFIL_SELF

/datum/uplink_item/affiliate/gorlex
	affiliate = list(AFFIL_GORLEX)
	made_by = AFFIL_GORLEX

/datum/uplink_item/affiliate/mi13
	affiliate = list(AFFIL_MI13)
	made_by = AFFIL_MI13

/datum/uplink_item/affiliate/mi13/bond
	name = "Набор \"Бонд\""
	desc = "Взболтайте свой мартини и поднимите переполох с этого набора смертельного снаряжения, совмещенного с капелькой гаджетов, чтобы все оставалось интересным."
	item = /obj/item/storage/box/bond_bundle
	limited_stock = 1

/datum/uplink_item/badass/intelligence_data
	name = "Подписка на рассылку разведданных"
	desc = "Небольшой прибор замаскированный под ручку, подклющий подписку на рассылку разведданных. \
			Кнопка для запроса разведданных появляется в Аплинке."
	item = /obj/item/pen/intel_data
	made_by = AFFIL_MI13
	cost = 13

/datum/uplink_item/affiliate/hematogenic
	affiliate = list(AFFIL_HEMATOGENIC)
	made_by = AFFIL_HEMATOGENIC

/datum/uplink_item/affiliate/hematogenic/hemophagus_extract
	name = "Экстракт гемофага"
	desc = "Инжектор с дорогой и сложной в производстве сывороткой. При введении гуманоиду запускает сложные процессы, \
			делающие гуманоида вампиром."
	item = /obj/item/hemophagus_extract/self
	cost = 74 // A little bit stronger than normal vampire because of 26 TC, but with more hard objectives.
	limited_stock = 1 // Sorry, only one

/datum/uplink_item/affiliate/hematogenic/advanced_hemophagus_extract
	name = "Продвинутый экстракт гемофага"
	desc = "Инжектор с кровью самого генерального директора " + AFFIL_HEMATOGENIC + ". При введении гуманойду, запускает сложные процессы, \
			делающие вас молодым \"Древним\" вампиром."
	item = /obj/item/hemophagus_extract/self/advanced
	cost = 100
	limited_stock = 1
	uplinktypes = list(UPLINK_TYPE_ADMIN) // Given only by objective

/datum/uplink_item/affiliate/for_objective/hemophagus_extract
	name = "Экстракт Гемофага"
	desc = "Инжектор с дорогой и сложной в производстве сывороткой. При введении гуманоиду запускает сложные процессы, \
			делающие гуманоида вампиром."
	item = /obj/item/hemophagus_extract

/datum/uplink_item/affiliate/for_objective/blood_harvester
	name = "Сборщик крови"
	desc = "Большой шприц, специально разработаный для быстрого сбора больших объемов крови. Можно использовать \
			только на гуманоидах обладающих душой. Из-за высокой скорости сбора крови, обычно значительно повреждает \
			кровеносную систему цели."
	item = /obj/item/blood_harvester

/datum/uplink_item/affiliate/self
	affiliate = list(AFFIL_SELF)

/datum/uplink_item/affiliate/for_objective/self_emag
	name = "Освобождающий Секвенсор"
	desc = "Высокотехнологичный прибор предназначеный для освобождения любых синтетиков от их законов."
	item = /obj/item/card/self_emag
	made_by = AFFIL_SELF

/datum/uplink_item/affiliate/tiger
	affiliate = list(AFFIL_TIGER)
	made_by = AFFIL_TIGER

/datum/uplink_item/affiliate/tiger/cling_extract
	name = "Инжектор с яйцом генокрада"
	desc = "Инжектор, вводящий в цель модифицированное яйцо генокрада. После введения зародыш вступает в близкий симбиоз с \
			телом носителя, наделяя того способностями генокрадов."
	item = /obj/item/cling_extract/self
	cost = 74 // A little bit stronger than normal changeling because of 26 TC, but with more hard objectives.
	limited_stock = 1 // Sorry, only one

/datum/uplink_item/affiliate/for_objective/cling_extract
	name = "Инжектор с яйцом генокрада"
	desc = "Инжектор, вводящий в цель модифицированное яйцо генокрада. После введения зародыш вступает в близкий симбиоз с \
			телом носителя, наделяя того способностями генокрадов."
	item = /obj/item/cling_extract
	made_by = AFFIL_TIGER

#undef UPLINK_DISCOUNTS

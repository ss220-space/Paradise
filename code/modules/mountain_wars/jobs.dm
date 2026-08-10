// Джоб-датумы задают фракцию (доступы, ХУД, тайтл). Конкретная роль внутри
// фракции определяется аутфитом — см. GLOB.mountain_wars_roles.

/datum/job/civilian/mw_marine
	title = JOB_TITLE_MW_MARINE
	flag = JOB_FLAG_MW_MARINE
	department_flag = JOBCAT_COMBAT_TEAM
	selection_color = "#1100ff"
	alt_titles = list()
	total_positions = 0
	spawn_positions = 0
	outfit = /datum/outfit/job/mountain_wars/marine
	insurance_type = INSURANCE_TYPE_NONE
	announce_job = FALSE
	hidden_from_job_prefs = TRUE
	admin_only = TRUE

/datum/job/civilian/mw_insurgent
	title = JOB_TITLE_MW_INSURGENT
	flag = JOB_FLAG_MW_INSURGENT
	department_flag = JOBCAT_COMBAT_TEAM
	selection_color = "#ff0000"
	alt_titles = list()
	total_positions = 0
	spawn_positions = 0
	outfit = /datum/outfit/job/mountain_wars/insurgent
	insurance_type = INSURANCE_TYPE_NONE
	announce_job = FALSE
	hidden_from_job_prefs = TRUE
	admin_only = TRUE

// Полный стак мешков одним предметом. Через backpack_contents так не выдать: там счётчик
// означает число предметов, а не размер стака, и «50» обернулось бы полусотней объектов
// на каждого бойца при заходе. Стак сливается с обычными мешками — can_merge сверяет
// merge_type через istype, а он у подтипа родительский.
/obj/item/stack/sheet/mineral/sandbags/mw_full
	amount = 50

// MARK: Навыки
// Общесерверная система навыков режиму не нужна: разница между бойцами здесь задаётся
// ролью в отряде, а не очками, вложенными в персонажа до раунда.
//
// Но промолчать нельзя. Пустая таблица навыков у должности означает не «навыки не
// важны», а SKILL_LEVEL_NONE по всем строкам: полуторное время на любое действие,
// двойной разброс, меньшая меткость и шанс осечки. Бойцы вышли бы в поле криворукими.
//
// Базовый уровень — ровно то поведение, что было до перехода: все множители равны
// единице. Стволы, медицина и постройки работают как раньше, без правок в предметах.
/datum/job/civilian/mw_marine/get_skill_level(skill_type, alt_job_title)
	return SKILL_LEVEL_BASIC

/datum/job/civilian/mw_insurgent/get_skill_level(skill_type, alt_job_title)
	return SKILL_LEVEL_BASIC

// Штатная выдача снаряжения предлагает распределить навыки. В режиме это окно всплывало
// бы на каждой высадке и каждом респавне, а распределённое всё равно тут же затирается
// выравниванием в deploy_member. Молча пропускаем.
/datum/outfit/job/mountain_wars/skill_select_offer(mob/living/carbon/human/user)
	return

/datum/outfit/job/mountain_wars
	allow_loadout = FALSE
	allow_backbag_choice = FALSE
	id = /obj/item/card/id/syndicate/anyone
	pda = null
	box = null
	/// Командирская роль: рисует на тактической карте, получает приказы и вызовы.
	/// Проверяется в /datum/team/mountain_wars/add_member до выдачи кнопок.
	var/squad_leader = FALSE
	/// Санитар: перевязывает вдвое быстрее.
	var/field_medic = FALSE
	/// Сапёр: строит вдвое быстрее.
	var/combat_engineer = FALSE
	/// Сколько бойцов фракции могут держать эту роль разом. Ноль — сколько угодно.
	/// Считаются только живые: место выбитого специалиста освобождается, см. teams.dm.
	var/role_cap = 0

// MARK: Классовые бонусы
// Специальность даёт не только сумку, но и скорость: без этого санитар отличается от
// боевика одним рюкзаком, а перевязывать под огнём одинаково долго всем.
//
// Считается ускорение не в предметах, а в паре процов на трейт. Иначе пришлось бы
// заводить фракционные копии каждого бинта, шины и жгута — а бинты у сторон разные, и
// копий вышло бы вдвое больше самих предметов.

/// Во сколько раз специалист быстрее обычного бойца.
#define MW_CLASS_SPEEDUP 0.5

/// Задержка перевязки с поправкой на санитара. Зовётся из medical.dm.
/proc/mw_medic_delay(mob/user, delay)
	return HAS_TRAIT(user, TRAIT_MW_MEDIC) ? delay * MW_CLASS_SPEEDUP : delay

/// Задержка сборки из стопки с поправкой на сапёра. Зовётся из stack_recipe.dm.
/proc/mw_build_delay(mob/user, delay)
	return HAS_TRAIT(user, TRAIT_MW_ENGINEER) ? delay * MW_CLASS_SPEEDUP : delay

#undef MW_CLASS_SPEEDUP

// MARK: Потолок специальностей
// Сколько специалистов одного вида фракция держит разом. Три — потому что отделений
// три: Альфа, Браво и Чарли (GLOB.mw_squads). Четвёртому командиру взяться неоткуда,
// сколько бы народу ни набралось, а с ним и четвёртому медику с пулемётчиком.
//
// У повстанцев отделений нет, но потолок тот же: иначе половина фракции уходит в
// подрывники, и стороны перестают быть сравнимыми.
//
// Меняется число отделений — меняется и это. Держать его вычисленным из mw_squads
// нельзя: значение идёт в initial() у аутфита, а туда попадают только константы.
#define MW_ROLE_CAP 3

// MARK: Морпехи
// Базовый аутфит = Пехотинец. Спрайты — плейсхолдеры до порта из CM-SS13.
/datum/outfit/job/mountain_wars/marine
	name = JOB_TITLE_RU_MW_MARINE
	jobtype = /datum/job/civilian/mw_marine

	uniform = /obj/item/clothing/under/mw_marine
	suit = /obj/item/clothing/suit/armor/vest/mw_marine
	head = /obj/item/clothing/head/helmet/mw_marine
	shoes = /obj/item/clothing/shoes/jackboots
	l_ear = /obj/item/radio/headset/blue
	r_hand = /obj/item/gun/projectile/automatic/arg/mw_m16a4
	backpack_contents = list(
		/obj/item/ammo_box/magazine/m556/mw_m16a4 = 4,
		/obj/item/stack/sheet/mineral/sandbags/mw_full = 1,
		/obj/item/storage/firstaid/mw_marine = 1,
	)

// Гранаты выдаём здесь, а не списком в рюкзаке: backpack_contents подтипы
// переопределяют целиком, и пришлось бы дописывать строку в каждую роль.
/datum/outfit/job/mountain_wars/marine/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	for(var/i in 1 to 2)
		H.equip_or_collect(new /obj/item/grenade/frag/mw_m67(H), ITEM_SLOT_BACKPACK)

/datum/outfit/job/mountain_wars/marine/leader
	name = "Морпех США (Командир отряда)"
	squad_leader = TRUE
	role_cap = MW_ROLE_CAP
	suit = /obj/item/clothing/suit/armor/vest/mw_marine/leader
	head = /obj/item/clothing/head/helmet/mw_marine/leader
	glasses = /obj/item/clothing/glasses/hud/security/night
	// Подствол на всё отделение — это сорок фугасов в атаке. Гранатомёт один, у
	// командира: он и так решает, куда бить.
	r_hand = /obj/item/gun/projectile/automatic/arg/mw_m16a4/m203
	backpack_contents = list(
		/obj/item/ammo_casing/a40mm/mw_he = 4,
		/obj/item/ammo_box/magazine/m556/mw_m16a4 = 3,
		/obj/item/stack/sheet/mineral/sandbags/mw_full = 1,
		/obj/item/storage/firstaid/mw_marine = 1,
		/obj/item/radio/off = 1,
		/obj/item/mw_fob_kit/marine = 1,
	)

/datum/outfit/job/mountain_wars/marine/medic
	name = "Морпех США (Медик)"
	role_cap = MW_ROLE_CAP
	field_medic = TRUE
	suit = /obj/item/clothing/suit/armor/vest/mw_marine/medic
	head = /obj/item/clothing/head/helmet/mw_marine/medic
	glasses = /obj/item/clothing/glasses/hud/health
	// Хирургический пояс вместо медицинского: инструмент лежит прямо на поясе, а не в
	// рюкзаке, и оперировать можно не разгружаясь. Заодно уходит пустой пояс — базовый
	// /medical, как и /utility у сапёров, едет без содержимого.
	belt = /obj/item/storage/belt/medical/surgery/loaded
	backpack_contents = list(
		/obj/item/ammo_box/magazine/m556/mw_m16a4 = 3,
		/obj/item/storage/firstaid/mw_marine = 3,
		/obj/item/defibrillator/compact/loaded = 1,
		// Каталка едет в стойке, а не россыпью: сама сложенная каталка объёмная и в
		// рюкзак не лезет, а стойка с ней внутри — обычный предмет.
		/obj/item/roller_holder = 1,
	)

/datum/outfit/job/mountain_wars/marine/engineer
	name = "Морпех США (Инженер)"
	role_cap = MW_ROLE_CAP
	combat_engineer = TRUE
	suit = /obj/item/clothing/suit/armor/vest/mw_marine/engineer
	head = /obj/item/clothing/head/helmet/mw_marine/engineer
	gloves = /obj/item/clothing/gloves/color/yellow
	// Единственный морпех, который видит мины. Остальным их не покажет ничто.
	glasses = /obj/item/clothing/glasses/mw_sapper
	// Пояс со снятием: без кусачек или мультитула мину не обезвредить, а базовый
	// /utility едет пустым — инструмент в нём только у подтипа full.
	belt = /obj/item/storage/belt/utility/full/multitool
	backpack_contents = list(
		/obj/item/ammo_box/magazine/m556/mw_m16a4 = 3,
		/obj/item/stack/sheet/mineral/sandbags/mw_full = 1,
		/obj/item/storage/firstaid/mw_marine = 1,
		/obj/item/weldingtool/largetank = 1,
		/obj/item/storage/toolbox/emergency = 1,
	)

/datum/outfit/job/mountain_wars/marine/mg
	name = "Морпех США (Пулемётчик)"
	role_cap = MW_ROLE_CAP
	suit = /obj/item/clothing/suit/armor/vest/mw_marine/heavy
	head = /obj/item/clothing/head/helmet/mw_marine/heavy
	r_hand = /obj/item/gun/projectile/automatic/l6_saw/mw_m249
	backpack_contents = list(
		/obj/item/ammo_box/magazine/l6saw/mw_m249 = 2,
		/obj/item/storage/firstaid/mw_marine = 1,
	)

// MARK: Повстанцы
// Базовый аутфит = Боевик.
/datum/outfit/job/mountain_wars/insurgent
	name = JOB_TITLE_RU_MW_INSURGENT
	jobtype = /datum/job/civilian/mw_insurgent

	uniform = /obj/item/clothing/under/mw_insurgent
	suit = /obj/item/clothing/suit/armor/mw_insurgent
	head = /obj/item/clothing/head/helmet/mw_insurgent
	shoes = /obj/item/clothing/shoes/laceup
	l_ear = /obj/item/radio/headset/red
	r_hand = /obj/item/gun/projectile/automatic/ak814/mw_akm
	backpack_contents = list(
		/obj/item/ammo_box/magazine/mw_akm = 4,
		/obj/item/stack/sheet/mineral/sandbags/mw_full = 1,
		/obj/item/storage/firstaid/mw_insurgent = 1,
	)

// Полевой рации у повстанцев нет. Подкрепления они и так поднимают из лазов по всему
// сектору, а переносная точка сбора сверх этого — уже перебор. Тип рации повстанцев
// (/obj/structure/mw_fob/insurgent) оставлен: админ ставит её вручную, когда ивент того
// требует.
/datum/outfit/job/mountain_wars/insurgent/leader
	name = "Повстанец (Полевой командир)"
	role_cap = MW_ROLE_CAP
	squad_leader = TRUE
	suit = /obj/item/clothing/suit/armor/mw_insurgent/leader
	head = /obj/item/clothing/head/helmet/mw_insurgent/leader
	backpack_contents = list(
		/obj/item/ammo_box/magazine/mw_akm = 3,
		/obj/item/stack/sheet/mineral/sandbags/mw_full = 1,
		/obj/item/storage/firstaid/mw_insurgent = 1,
		/obj/item/radio/off = 1,
	)

/datum/outfit/job/mountain_wars/insurgent/marksman
	name = "Повстанец (Стрелок)"
	role_cap = MW_ROLE_CAP
	suit = /obj/item/clothing/suit/armor/mw_insurgent/marksman
	head = /obj/item/clothing/head/helmet/mw_insurgent/marksman
	r_hand = /obj/item/gun/projectile/shotgun/boltaction/mw_mosin
	backpack_contents = list(
		/obj/item/ammo_box/a762x54 = 3,
		/obj/item/stack/sheet/mineral/sandbags/mw_full = 1,
		/obj/item/storage/firstaid/mw_insurgent = 1,
	)

// Санитару и подрывнику вместо автомата ППШ: их работа вблизи и в тесноте, а
// стрелковый бой на дистанции держат боевики.
/datum/outfit/job/mountain_wars/insurgent/medic
	name = "Повстанец (Санитар)"
	role_cap = MW_ROLE_CAP
	field_medic = TRUE
	suit = /obj/item/clothing/suit/armor/mw_insurgent/medic
	// Инструмент и каталка те же, что у морпеха: расходники у сторон разные — жгут
	// Эсмарха против C-A-T, тряпьё против гемостатика, — а режут и зашивают одним и
	// тем же. Пояс заодно перестаёт быть пустым, базовый /medical едет без содержимого.
	belt = /obj/item/storage/belt/medical/surgery/loaded
	r_hand = /obj/item/gun/projectile/automatic/smg/ppsh/mw_ppsh
	backpack_contents = list(
		/obj/item/ammo_box/magazine/ppsh = 2,
		/obj/item/storage/firstaid/mw_insurgent = 3,
		/obj/item/roller_holder = 1,
	)

/datum/outfit/job/mountain_wars/insurgent/engineer
	name = "Повстанец (Подрывник)"
	role_cap = MW_ROLE_CAP
	combat_engineer = TRUE
	suit = /obj/item/clothing/suit/armor/mw_insurgent/boomvest
	belt = /obj/item/storage/belt/utility/full/multitool
	r_hand = /obj/item/gun/projectile/automatic/smg/ppsh/mw_ppsh
	backpack_contents = list(
		/obj/item/ammo_box/magazine/ppsh = 2,
		/obj/item/stack/sheet/mineral/sandbags/mw_full = 1,
		/obj/item/storage/firstaid/mw_insurgent = 1,
		/obj/item/weldingtool/largetank = 1,
		/obj/item/storage/toolbox/emergency = 1,
		/obj/item/grenade/plastic/c4 = 2,
		/obj/item/mw_mine = 4,
	)

#undef MW_ROLE_CAP

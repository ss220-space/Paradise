// channel numbers for power
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
#define TOTAL 4 //for total power used only
#define CHANNEL_STATIC_EQUIP 5
#define CHANNEL_STATIC_LIGHT 6
#define CHANNEL_STATIC_ENVIRON 7

//Power use
#define NO_POWER_USE 0
#define IDLE_POWER_USE 1
#define ACTIVE_POWER_USE 2

//APC charging
/// APC is not receiving power
#define APC_NOT_CHARGING 0
/// APC is currently receiving power and storing it
#define APC_IS_CHARGING 1
/// APC battery is at 100%
#define APC_FULLY_CHARGED 2

// Definitions for power restoration types
/// Charging without repair
#define POWER_RESTORE_ONLY 0
/// Repair without charging
#define APC_REPAIR_ONLY 1
/// Repair and charging
#define APC_REPAIR_AND_CHARGE 2

//computer3 error codes, move lower in the file when it passes dev -Sayu
#define PROG_CRASH (1<<0) // Generic crash
#define MISSING_PERIPHERAL (1<<1) // Missing hardware
#define BUSTED_ASS_COMPUTER (1<<2) // Self-perpetuating error.  BAC will continue to crash forever.
#define MISSING_PROGRAM (1<<3) // Some files try to automatically launch a program.  This is that failing.
#define FILE_DRM (1<<4) // Some files want to not be copied/moved.  This is them complaining that you tried.
#define NETWORK_FAILURE (1<<5)

#define IMPRINTER (1<<0) //For circuits. Uses glass/chemicals.
#define PROTOLATHE (1<<1) //New stuff. Uses glass/metal/chemicals
#define AUTOLATHE (1<<2) //Uses glass/metal only.
#define CRAFTLATHE (1<<3) //Uses fuck if I know. For use eventually.
#define MECHFAB (1<<4) //Remember, objects utilising this flag should have construction_time and construction_cost vars.
#define PODFAB (1<<5) //Used by the spacepod part fabricator. Same idea as the mechfab
#define BIOGENERATOR (1<<6) //Uses biomass
#define SMELTER (1<<7) //uses various minerals
//Note: More then one of these can be added to a design but imprinter and lathe designs are incompatable.

#define HYDRO_SPEED_MULTIPLIER 1

// Demotion Console (card/minor/*) departments
#define TARGET_DEPT_GENERIC 1
#define TARGET_DEPT_SEC 2
#define TARGET_DEPT_MED 3
#define TARGET_DEPT_SCI 4
#define TARGET_DEPT_ENG 5
#define TARGET_DEPT_SUP 6

// Status display maptext stuff
#define DISPLAY_CHARS_PER_LINE 5
#define DISPLAY_FONT_SIZE "5pt"
#define DISPLAY_FONT_COLOR "#09f"
#define DISPLAY_WARNING_FONT_COLOR "#f90"
#define DISPLAY_FONT_STYLE "Small Fonts"
#define DISPLAY_SCROLL_SPEED 2

// AI display mode types
#define AI_DISPLAY_MODE_BLANK 0
#define AI_DISPLAY_MODE_EMOTE 1
#define AI_DISPLAY_MODE_BSOD 2

// Status display mode types
#define STATUS_DISPLAY_BLANK 0
#define STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME 1
#define STATUS_DISPLAY_MESSAGE 2
#define STATUS_DISPLAY_ALERT 3
#define STATUS_DISPLAY_TIME 4
#define STATUS_DISPLAY_CUSTOM 5

// Firelock states
#define FD_OPEN 1
#define FD_CLOSED 2

// Door operations
#define DOOR_OPENING 1
#define DOOR_CLOSING 2
#define DOOR_MALF 3

// Computer login types
#define LOGIN_TYPE_NORMAL 1
#define LOGIN_TYPE_AI 2
#define LOGIN_TYPE_ROBOT 3
#define LOGIN_TYPE_ADMIN 4

#define NUKE_STATUS_INTACT 0
#define NUKE_CORE_MISSING 1
#define NUKE_MISSING 2

// Bitflags for a machine's preferences on when it should start processing. For use with machinery's `processing_flags` var.
/// Indicates the machine will automatically start processing right after it's `Initialize()` is ran.
#define START_PROCESSING_ON_INIT (1<<0)
/// Machines with this flag will not start processing when it's spawned. Use this if you want to manually control when a machine starts processing.
#define START_PROCESSING_MANUALLY (1<<1)

#define MACHINE_FLICKER_CHANCE 0.05 // roughly 1/2000 chance of a machine flickering on any given tick. That means in a two hour round each machine will flicker on average a little less than two times.

#define ORE_REDEMPTION "Плавильная печь"

// Research tree names
#define RESEARCH_TREE_MATERIALS_NAME "Материаловедение"
#define RESEARCH_TREE_ENGINEERING_NAME "Инженерные технологии"
#define RESEARCH_TREE_PLASMA_NAME "Плазмотехнологии"
#define RESEARCH_TREE_POWERSTORAGE_NAME "Энергетические системы"
#define RESEARCH_TREE_BLUESPACE_NAME "Блюспейс-исследования"
#define RESEARCH_TREE_BIOTECH_NAME "Биотехнологии"
#define RESEARCH_TREE_COMBAT_NAME "Боевые системы"
#define RESEARCH_TREE_MAGNETS_NAME "Электромагнитные технологии"
#define RESEARCH_TREE_PROGRAMMING_NAME "Теория данных"
#define RESEARCH_TREE_TOXINS_NAME "Токсинология"
#define RESEARCH_TREE_ILLEGAL_NAME "Запрещённые технологии"
#define RESEARCH_TREE_ALIEN_NAME "Инопланетные технологии"

// Research tree ids
#define RESEARCH_TREE_MATERIALS "materials"
#define RESEARCH_TREE_ENGINEERING "engineering"
#define RESEARCH_TREE_PLASMA "plasmatech"
#define RESEARCH_TREE_POWERSTORAGE "powerstorage"
#define RESEARCH_TREE_BLUESPACE "bluespace"
#define RESEARCH_TREE_BIOTECH "biotech"
#define RESEARCH_TREE_COMBAT "combat"
#define RESEARCH_TREE_MAGNETS "magnets"
#define RESEARCH_TREE_PROGRAMMING "programming"
#define RESEARCH_TREE_TOXINS "toxins"
#define RESEARCH_TREE_ILLEGAL "syndicate"
#define RESEARCH_TREE_ALIEN "abductor"

// Categories, used in different types of printers
#define PRINTER_CATEGORY_INITIAL "initial"
#define PRINTER_CATEGORY_HACKED "hacked"

// Autolathe categories
#define AUTOLATHE_CATEGORY_TOOLS "Инструменты"
#define AUTOLATHE_CATEGORY_ELECTRONICS "Электроника"
#define AUTOLATHE_CATEGORY_CONSTRUCTION "Конструирование"
#define AUTOLATHE_CATEGORY_COMMUNICATION "Радиосвязь"
#define AUTOLATHE_CATEGORY_SECURITY "Безопасность"
#define AUTOLATHE_CATEGORY_MACHINERY "Машинерия"
#define AUTOLATHE_CATEGORY_MEDICAL "Медицина"
#define AUTOLATHE_CATEGORY_MISC "Разное"
#define AUTOLATHE_CATEGORY_DINNERWARE "Посуда и утварь"
#define AUTOLATHE_CATEGORY_IMPORTED "Импортированное"

// Protolathe categories
#define PROTOLATHE_CATEGORY_BLUESPACE "Блюспейс"
#define PROTOLATHE_CATEGORY_EQUIPMENT "Снаряжение"
#define PROTOLATHE_CATEGORY_JANITORIAL "Уборка"
#define PROTOLATHE_CATEGORY_MINING "Шахтёрское дело"
#define PROTOLATHE_CATEGORY_WEAPON "Вооружение"
#define PROTOLATHE_CATEGORY_STOCK_PARTS "Компоненты машинерии"
#define PROTOLATHE_CATEGORY_MEDICAL "Медицина"
#define PROTOLATHE_CATEGORY_POWER "Электроэнергия"
#define PROTOLATHE_CATEGORY_MISC "Разное"
#define PROTOLATHE_CATEGORY_ILLEGAL "Контрабанда"
#define PROTOLATHE_CATEGORY_CIRCUITRY "Интегральные схемы"

// Circuit Imprinter categories
#define CIRCUIT_IMPRINTER_CATEGORY_AI "Станционный ИИ"
#define CIRCUIT_IMPRINTER_CATEGORY_COMPUTER "Компьютеры и консоли"
#define CIRCUIT_IMPRINTER_CATEGORY_ENGINEERING "Инженерные модули"
#define CIRCUIT_IMPRINTER_CATEGORY_EXOSUIT "Экзоскелеты"
#define CIRCUIT_IMPRINTER_CATEGORY_HYDROPONICS "Гидропоника"
#define CIRCUIT_IMPRINTER_CATEGORY_MEDICAL "Медицина"
#define CIRCUIT_IMPRINTER_CATEGORY_POWER "Электроэнергия"
#define CIRCUIT_IMPRINTER_CATEGORY_MISC "Разное"
#define CIRCUIT_IMPRINTER_CATEGORY_RESEARCH "Наука и исследование"
#define CIRCUIT_IMPRINTER_CATEGORY_TELECOMS "Телекоммуникация"
#define CIRCUIT_IMPRINTER_CATEGORY_TELEPORTATION "Телепортация"
#define CIRCUIT_IMPRINTER_CATEGORY_CIRCUIT "Компоненты схем"

// Mech fabricator categories
#define MECH_FAB_CATEGORY_CYBORG "Части роботов"
#define MECH_FAB_CATEGORY_CYBORG_REPAIR "Компоненты роботов"
#define MECH_FAB_CATEGORY_CYBORG_EQUIPMENT "Оборудование роботов"
#define MECH_FAB_CATEGORY_IPC "КПБ"
#define MECH_FAB_CATEGORY_MODSUIT_CONSTRUCTION "Сборка МЭК"
#define MECH_FAB_CATEGORY_MODSUIT_MODULES "Модули МЭК"
#define MECH_FAB_CATEGORY_EXOSUIT_EQUIPMENT "Оборудование экзоскелетов"
#define MECH_FAB_CATEGORY_EXOSUIT_PAINTKITS "Наборы кастомизации экзоскелетов"
#define MECH_FAB_CATEGORY_RIPLEY "Рипли"
#define MECH_FAB_CATEGORY_FIREFIGHTER "Огнеборец"
#define MECH_FAB_CATEGORY_CLARKE "Кларк"
#define MECH_FAB_CATEGORY_ODYSSEUS "Одиссей"
#define MECH_FAB_CATEGORY_GYGAX "Гигакс"
#define MECH_FAB_CATEGORY_DURAND "Дюран"
#define MECH_FAB_CATEGORY_HONKER "Х.О.Н.К."
#define MECH_FAB_CATEGORY_RETICENCE "Молчун"
#define MECH_FAB_CATEGORY_PHAZON "Фазон"
#define MECH_FAB_CATEGORY_MISC "Разное"
#define MECH_FAB_CATEGORY_ROVER "Странник"
#define MECH_FAB_CATEGORY_DARK_GYGAX "Тёмный Гигакс"
#define MECH_FAB_CATEGORY_SYNDICATE "Синдикат"

// Engine types
#define ENGTYPE_SING "Сингулярность"
#define ENGTYPE_TESLA "Тесла"

#define AALARM_MODE_FILTERING 1
/// Makes draught
#define AALARM_MODE_DRAUGHT 2
/// Like siphon, but stronger (enables widenet)
#define AALARM_MODE_PANIC 3
/// Sucks off all air, then refill and swithes to scrubbing
#define AALARM_MODE_CYCLE 4
/// Scrubbers suck air
#define AALARM_MODE_SIPHON 5
/// Turns on all filtering and widenet scrubbing.
#define AALARM_MODE_CONTAMINATED 6
/// Just like normal, but disables low pressure check until normalized, then switches to normal
#define AALARM_MODE_REFILL 7
#define AALARM_MODE_OFF 8
/// Emagged mode; turns off scrubbers and pressure checks on vents
#define AALARM_MODE_FLOOD 9
#define AALARM_MODE_CUSTOM 10

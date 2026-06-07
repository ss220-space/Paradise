#define HUD_BLANK "Пусто"

#define HUD_ONE "Один"
#define HUD_TWO "Два"
#define HUD_THREE "Три"
#define HUD_FOUR "Четыре"
#define HUD_FIVE "Пять"

#define HUD_BLOOD "Кровь"
#define HUD_BOMB "Бомба"
#define HUD_BRAIN "Мозг"
#define HUD_BRAIN_DAMAGE "Повреждение мозга"
#define HUD_CROSS "Крест"
#define HUD_ELECTRICITY "Электричество"
#define HUD_EXCLAMATION "Восклицание"
#define HUD_HEART "Сердце"
#define HUD_ID "ID"
#define HUD_INFO "Инфо"
#define HUD_INJECTION "Инъекция"
#define HUD_MAGNETISM "Магнетизм"
#define HUD_MINUS "Минус"
#define HUD_NETWORK "Сеть"
#define HUD_PLUS "Плюс"
#define HUD_POWER "Энергия"
#define HUD_QUESTION "Вопрос"
#define HUD_RADIOACTIVE "Радиоактивность"
#define HUD_REACTION "Реакция"
#define HUD_REPAIR "Ремонт"
#define HUD_SAY "Сказать"
#define HUD_SCAN "Сканирование"
#define HUD_SHIELD "Щит"
#define HUD_SKILL "Череп"
#define HUD_SLEEP "Сон"
#define HUD_WIRELESS "Беспроводная связь"

/obj/item/circuit_component/equipment_action
	display_name = "Действие оборудования"
	desc = "Представляет действие, которое пользователь может выполнить при использовании поддерживаемых оболочек."
	required_shells = list(/obj/item/organ/internal/cyberimp/brain/bci, /obj/item/mod/module/circuit)

	/// The icon of the button
	var/datum/port/input/option/icon_options

	/// The name to use for the button
	var/datum/port/input/button_name

	/// The mob who activated their granted action
	var/datum/port/output/user

	/// Called when the user presses the button
	var/datum/port/output/signal

	/// An assoc list of datum UID()s, linked to the actions granted.
	var/list/granted_to = list()

	/// An assoc list of available action icons
	var/list/options_map

/obj/item/circuit_component/equipment_action/Initialize(mapload, default_icon)
	. = ..()

	if(!isnull(default_icon))
		icon_options.set_input(default_icon)

	button_name = add_input_port("Название", PORT_TYPE_STRING)

	user = add_output_port("Пользователь", PORT_TYPE_USER)
	signal = add_output_port("Вызвано", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/equipment_action/Destroy()
	QDEL_LIST_ASSOC_VAL(granted_to)
	icon_options = null
	button_name = null
	user = null
	signal = null
	options_map = null
	return ..()

/obj/item/circuit_component/equipment_action/populate_options()
	var/static/action_options = list(
	HUD_BLANK = "bci_blank",

	HUD_ONE = "bci_one",
	HUD_TWO = "bci_two",
	HUD_THREE = "bci_three",
	HUD_FOUR = "bci_four",
	HUD_FIVE = "bci_five",

	HUD_BLOOD = "bci_blood",
	HUD_BOMB = "bci_bomb",
	HUD_BRAIN = "bci_brain",
	HUD_BRAIN_DAMAGE = "bci_brain_damage",
	HUD_CROSS = "bci_cross",
	HUD_ELECTRICITY = "bci_electricity",
	HUD_EXCLAMATION = "bci_exclamation",
	HUD_HEART = "bci_heart",
	HUD_ID = "bci_id",
	HUD_INFO = "bci_info",
	HUD_INJECTION = "bci_injection",
	HUD_MAGNETISM = "bci_magnetism",
	HUD_MINUS = "bci_minus",
	HUD_NETWORK = "bci_network",
	HUD_PLUS = "bci_plus",
	HUD_POWER = "bci_power",
	HUD_QUESTION = "bci_question",
	HUD_RADIOACTIVE = "bci_radioactive",
	HUD_REACTION = "bci_reaction",
	HUD_REPAIR = "bci_repair",
	HUD_SAY = "bci_say",
	HUD_SCAN = "bci_scan",
	HUD_SHIELD = "bci_shield",
	HUD_SKILL = "bci_skull",
	HUD_SLEEP = "bci_sleep",
	HUD_WIRELESS = "bci_wireless",
	)

	icon_options = add_option_port("Icon", action_options)
	options_map = action_options

/obj/item/circuit_component/equipment_action/register_shell(atom/movable/shell)
	. = ..()
	SEND_SIGNAL(shell, COMSIG_CIRCUIT_ACTION_COMPONENT_REGISTERED, src)

/obj/item/circuit_component/equipment_action/unregister_shell(atom/movable/shell)
	. = ..()
	SEND_SIGNAL(shell, COMSIG_CIRCUIT_ACTION_COMPONENT_UNREGISTERED, src)

/obj/item/circuit_component/equipment_action/input_received(datum/port/input/port)
	if(length(granted_to))
		update_actions()

/obj/item/circuit_component/equipment_action/proc/update_actions()
	for(var/uid in granted_to)
		var/datum/action/granted_action = granted_to[uid]
		granted_action.name = button_name.value || "Действие"
		granted_action.button_icon_state = LAZYACCESS(options_map, icon_options.value)
		granted_action.build_all_button_icons(ALL)


#undef HUD_BLANK

#undef HUD_ONE
#undef HUD_TWO
#undef HUD_THREE
#undef HUD_FOUR
#undef HUD_FIVE

#undef HUD_BLOOD
#undef HUD_BOMB
#undef HUD_BRAIN
#undef HUD_BRAIN_DAMAGE
#undef HUD_CROSS
#undef HUD_ELECTRICITY
#undef HUD_EXCLAMATION
#undef HUD_HEART
#undef HUD_ID
#undef HUD_INFO
#undef HUD_INJECTION
#undef HUD_MAGNETISM
#undef HUD_MINUS
#undef HUD_NETWORK
#undef HUD_PLUS
#undef HUD_POWER
#undef HUD_QUESTION
#undef HUD_RADIOACTIVE
#undef HUD_REACTION
#undef HUD_REPAIR
#undef HUD_SAY
#undef HUD_SCAN
#undef HUD_SHIELD
#undef HUD_SKILL
#undef HUD_SLEEP
#undef HUD_WIRELESS

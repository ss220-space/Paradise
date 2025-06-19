GLOBAL_LIST_EMPTY(keybindings)
GLOBAL_LIST_EMPTY(keybindings_by_name)
GLOBAL_LIST_EMPTY(default_hotkeys)


GLOBAL_LIST_INIT(keybindings_groups, list(
	"Передвижение" = KB_CATEGORY_MOVEMENT,
	"Коммуникация" = KB_CATEGORY_COMMUNICATION,
	"Существа" = KB_CATEGORY_LIVING,
	"Основное" = KB_CATEGORY_MOB,
	"Эмоции – Основное" = KB_CATEGORY_EMOTE_GENERIC,
	"Гуманоиды" = KB_CATEGORY_HUMAN,
	"Эмоции – Гуманоиды" = KB_CATEGORY_EMOTE_HUMAN,
	"Органики" = KB_CATEGORY_CARBON,
	"Эмоции – Органики" = KB_CATEGORY_EMOTE_CARBON,
	"Роботы" = KB_CATEGORY_ROBOT,
	"Синтетики" = KB_CATEGORY_SILICON,
	"Эмоции – Синтетики" = KB_CATEGORY_EMOTE_SILICON,
	"Эмоции – Животные" = KB_CATEGORY_EMOTE_ANIMAL,
	"Эмоции – Мозги (НКИ)" = KB_CATEGORY_EMOTE_BRAIN,
	"Эмоции – Ксеноморфы" = KB_CATEGORY_EMOTE_ALIEN,
	"Администрация" = KB_CATEGORY_ADMIN,
	"Другое" = KB_CATEGORY_UNSORTED,
	"Пользовательские эмоции (Привязано к слоту персонажа)" = KB_CATEGORY_EMOTE_CUSTOM,
))


/// Creates and sorts all the keybinding datums
/proc/init_keybindings()
	for(var/datum/keybinding/keybinding_path as anything in subtypesof(/datum/keybinding))
		if(!initial(keybinding_path.name))
			continue
		add_keybinding(new keybinding_path)


/// Adds an instanced keybinding to the global tracker
/proc/add_keybinding(datum/keybinding/instance)
	GLOB.keybindings += instance
	GLOB.keybindings_by_name[instance.name] = instance

	// Hotkey
	if(!LAZYLEN(instance.keys))
		return

	for(var/bound_key in instance.keys)
		if(bound_key == "Unbound")
			LAZYADD(GLOB.default_hotkeys[instance.name], list())
		else
			LAZYADD(GLOB.default_hotkeys[instance.name], list(bound_key))


GLOBAL_LIST_EMPTY(keybindings)
GLOBAL_LIST_EMPTY(keybindings_by_name)
GLOBAL_LIST_EMPTY(default_hotkeys)


GLOBAL_LIST_INIT(keybindings_groups, list(
	"Movement" = KB_CATEGORY_MOVEMENT,
	"Communication" = KB_CATEGORY_COMMUNICATION,
	"Living" = KB_CATEGORY_LIVING,
	"General" = KB_CATEGORY_MOB,
	"General Emote" = KB_CATEGORY_EMOTE_GENERIC,
	"Human" = KB_CATEGORY_HUMAN,
	"Human Emotes" = KB_CATEGORY_EMOTE_HUMAN,
	"Carbon" = KB_CATEGORY_CARBON,
	"Carbon Emote" = KB_CATEGORY_EMOTE_CARBON,
	"Robot" = KB_CATEGORY_ROBOT,
	"Silicon" = KB_CATEGORY_SILICON,
	"Silicon/IPC Emote" = KB_CATEGORY_EMOTE_SILICON,
	"Animal Emote" = KB_CATEGORY_EMOTE_ANIMAL,
	"Brain Emote" = KB_CATEGORY_EMOTE_BRAIN,
	"Alien Emote" = KB_CATEGORY_EMOTE_ALIEN,
	"Admin" = KB_CATEGORY_ADMIN,
	"Other" = KB_CATEGORY_UNSORTED,
	"Custom Emotes (Character-based)" = KB_CATEGORY_EMOTE_CUSTOM,
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


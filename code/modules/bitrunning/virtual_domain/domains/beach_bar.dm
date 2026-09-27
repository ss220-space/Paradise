/datum/lazy_template/virtual_domain/beach_bar
	name = "Пляжный бар"
	announce_to_ghosts = TRUE
	desc = "Солнечный берег, где дружелюбные скелеты разливают напитки. Кстати, а как вы все умерли?"
	completion_loot = list(/obj/item/beach_ball = 1)
	help_text = "Заведение держится на скелетной команде, и подробностями делиться она не спешит. Может, пара стаканов развяжет языки. Как говорится, не можешь победить — присоединяйся."
	key = LAZY_TEMPLATE_KEY_BITRUNNING_BEACH_BAR
	map_name = "beach_bar"
	domain_flags = DOMAIN_NO_NOHIT_BONUS

/datum/lazy_template/virtual_domain/beach_bar/setup_domain(list/created_atoms)
	. = ..()
	for(var/turf/tile as anything in created_atoms)
		for(var/atom/thing as anything in tile.get_all_contents())
			if(iscup(thing))
				RegisterSignal(thing, COMSIG_GLASS_DRANK, PROC_REF(on_drink_drank))
				continue

			if(istype(thing, /obj/machinery/vending))
				RegisterSignal(thing, COMSIG_VENDING_DISPENSED, PROC_REF(on_item_vended))

/datum/lazy_template/virtual_domain/beach_bar/proc/on_item_vended(datum/source, obj/item/vended_item)
	SIGNAL_HANDLER

	if(!iscup(vended_item))
		return

	RegisterSignal(vended_item, COMSIG_GLASS_DRANK, PROC_REF(on_drink_drank))

/datum/lazy_template/virtual_domain/beach_bar/proc/on_drink_drank(datum/source)
	SIGNAL_HANDLER

	add_points(0.5)

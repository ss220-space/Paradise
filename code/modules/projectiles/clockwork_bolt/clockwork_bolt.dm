/obj/item/clockwork_bolt
	name = "clockwork bolt"
	desc = "Древний механизм из часового металла, пульсирующий тусклым оранжевым светом. При установке на оружие позволяет использовать его только слугам Ратвара."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_bolt"
	w_class = WEIGHT_CLASS_TINY

	var/datum/clockwork_bolt_module/module

/obj/item/clockwork_bolt/Initialize(mapload)
	. = ..()
	module = new(src)

/obj/item/clockwork_bolt/get_ru_names()
	return list(
		NOMINATIVE = "часовой затвор",
		GENITIVE = "часового затвора",
		DATIVE = "часовому затвору",
		ACCUSATIVE = "часовой затвор",
		INSTRUMENTAL = "часовым затвором",
		PREPOSITIONAL = "часовом затворе"
	)

/obj/item/clockwork_bolt/deplete_spell()
	. = ..()
	module.deplete_spell()

/obj/item/clockwork_bolt/proc/install(obj/item/gun/W, mob/user = null)
	return module.install(W, user)

/obj/item/clockwork_bolt/proc/uninstall(obj/item/gun/W, mob/user = null)
	return module.uninstall(W, user)

/obj/item/clockwork_bolt/proc/bible_removal(mob/living/user)
	module.bible_removal(user)

/obj/item/clockwork_bolt/attackby(obj/item/I, mob/user, params)
	. = ..()
	return module.handle_attackby(I, user, params)

/obj/item/clockwork_bolt/screwdriver_act(mob/living/user, obj/item/I)
	return module.handle_screwdriver(user, I)

/obj/item/clockwork_bolt/welder_act(mob/living/user, obj/item/I)
	return module.handle_welder(user, I)

/obj/item/clockwork_bolt/crowbar_act(mob/living/user, obj/item/I)
	return module.handle_crowbar(user, I)

/obj/item/clockwork_bolt/Destroy()
	QDEL_NULL(module)
	return ..()

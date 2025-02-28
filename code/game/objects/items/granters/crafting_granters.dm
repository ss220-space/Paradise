/obj/item/book/granter/crafting_recipe
	/// A list of all recipe types we grant on learn
	var/list/crafting_recipe_types = list()

/obj/item/book/granter/crafting_recipe/on_reading_finished(mob/user)
	..()
	if(!user.mind)
		return
	for(var/datum/crafting_recipe/crafting_recipe_type as anything in crafting_recipe_types)
		user.mind.teach_crafting_recipe(crafting_recipe_type)
		to_chat(user, span_notice("Вы узнаёте новый рецепт -  \"[initial(crafting_recipe_type.name)]\"."))

/obj/item/book/granter/crafting_recipe/dusting
	icon_state = "book1"

/obj/item/book/granter/crafting_recipe/dusting/recoil(mob/living/user)
	to_chat(user, span_warning("Книга рассыпается в прах у вас в руках!"))
	qdel(src)

// actual crafting ganters

////Combat baking kit////

/obj/item/book/granter/crafting_recipe/combat_baking
	name = "the anarchist's cookbook"
	desc = "Знаменитая книга рецептов, которая поможет вам научиться печь такие круассаны, за которые можно и умереть."
	ru_names = list(
		NOMINATIVE = "поваренная книга анархиста",
		GENITIVE = "поваренной книги анархиста",
		DATIVE = "поваренной книге анархиста",
		ACCUSATIVE = "поваренную книгу анархиста",
		INSTRUMENTAL = "поваренной книгой анархиста",
		PREPOSITIONAL = "поваренной книге анархиста"
	)
	crafting_recipe_types = list(
		/datum/crafting_recipe/throwing_croissant
	)
	icon_state = "cooking_learing_illegal"
	remarks = list(
		"\"Австриец? Не по-французски?\"",
		"\"Нужно правильно распределить масло...\"",
		"\"Это лучшее, что может быть после нарезанного хлеба!\"",
		"\"Я не оставлю ни следа, кроме крошек!\"",
		"\"Кто бы мог подумать, что хлеб может причинить такую сильную боль?\""
	)

/obj/item/book/granter/crafting_recipe/combat_baking/recoil(mob/living/user)
	to_chat(user, span_warning("Книга превращается в подгоревшую муку!"))
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

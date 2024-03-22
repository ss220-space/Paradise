/obj/item/book/granter/crafting_recipe
	/// A list of all recipe types we grant on learn
	var/list/crafting_recipe_types = list()

/obj/item/book/granter/crafting_recipe/on_reading_finished(mob/user)
	..()
	if(!user.mind)
		return
	for(var/datum/crafting_recipe/crafting_recipe_type as anything in crafting_recipe_types)
		user.mind.teach_crafting_recipe(crafting_recipe_type)
		to_chat(user, "<span class='notice'>You learned how to make [initial(crafting_recipe_type.name)].</span>")

/obj/item/book/granter/crafting_recipe/dusting
	icon_state = "book1"

/obj/item/book/granter/crafting_recipe/dusting/recoil(mob/living/user)
	to_chat(user, "<span class='notice'>The book turns to dust in your hands.</span>")
	qdel(src)

// actual crafting ganters

////Combat baking kit////

/obj/item/book/granter/crafting_recipe/combat_baking
	name = "the anarchist's cookbook"
	desc = "A widely illegal recipe book which will teach you how to bake croissants to die for."
	crafting_recipe_types = list(
		/datum/crafting_recipe/throwing_croissant
	)
	icon_state = "cooking_learing_illegal"
	remarks = list(
		"\"Austrian? Not French?\"",
		"\"Got to get the butter ratio right...\"",
		"\"This is the greatest thing since sliced bread!\"",
		"\"I'll leave no trace except crumbs!\"",
		"\"Who knew that bread could hurt a man so badly?\""
	)

/obj/item/book/granter/crafting_recipe/combat_baking/recoil(mob/living/user)
	to_chat(user, "<span class='warning'>The book dissolves into burnt flour!</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

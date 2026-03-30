/obj/item/ammo_box/magazine/internal
	desc = "Oh god, this shouldn't be here!"
	can_fast_load = TRUE

//internals magazines are accessible, so replace spent ammo if full when trying to put a live one in
/obj/item/ammo_box/magazine/internal/give_round(obj/item/ammo_casing/new_casing, replace_spent = TRUE, count_chambered = FALSE, mob/user)
	. = ..()

/obj/item/reagent_containers/food/pill/patch
	name = "chemical patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bandaid"
	item_state = "bandaid"
	possible_transfer_amounts = null
	volume = 20
	container_type = 0 //nooo my insta-kill patch!!!
	apply_type = REAGENT_TOUCH
	apply_method = "apply"
	transfer_efficiency = 0.5 //patches aren't as effective at getting chemicals into the bloodstream.
	temperature_min = 270
	temperature_max = 350
	var/needs_to_apply_reagents = TRUE


/obj/item/reagent_containers/food/pill/patch/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(!iscarbon(target))
		return .
	if(!user.can_unEquip(src))
		return .
	bitesize = 0
	if(!target.eat(src, user) || !user.can_unEquip(src))
		return .
	user.drop_transfer_item_to_loc(src, target)
	LAZYADD(target.processing_patches, src)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/item/reagent_containers/food/pill/patch/afterattack(obj/target, mob/user, proximity, params)
	return // thanks inheritance again

/obj/item/reagent_containers/food/pill/patch/styptic
	name = "healing patch"
	desc = "Helps with brute injuries."
	icon_state = "bandaid2"
	instant_application = 1
	list_reagents = list("styptic_powder" = 20)

/obj/item/reagent_containers/food/pill/patch/styptic/small
	name = "healing mini-patch"
	icon_state = "bandaid1"
	list_reagents = list("styptic_powder" = 10)

/obj/item/reagent_containers/food/pill/patch/silver_sulf
	name = "burn patch"
	desc = "Helps with burn injuries."
	icon_state = "bandaid4"
	instant_application = 1
	list_reagents = list("silver_sulfadiazine" = 20)

/obj/item/reagent_containers/food/pill/patch/silver_sulf/small
	name = "burn mini-patch"
	icon_state = "bandaid3"
	list_reagents = list("silver_sulfadiazine" = 10)

/obj/item/reagent_containers/food/pill/patch/synthflesh
	name = "synthflesh patch"
	desc = "Helps with brute and burn injuries."
	icon_state = "bandaid8"
	instant_application = 1
	list_reagents = list("synthflesh" = 10)

/obj/item/reagent_containers/food/pill/patch/nicotine
	name = "nicotine patch"
	desc = "Helps temporarily curb the cravings of nicotine dependency."
	list_reagents = list("nicotine" = 10)

/obj/item/reagent_containers/food/pill/patch/jestosterone
	name = "jestosterone patch"
	desc = "Helps with brute injuries if the affected person is a clown, otherwise inflicts various annoying effects."
	icon_state = "bandaid20"
	list_reagents = list("jestosterone" = 20)

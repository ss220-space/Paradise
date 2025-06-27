/obj/item/reagent_containers/food/pill/patch
	name = "chemical patch"
	desc = "Химический пластырь, предназначенный для медленного ввода веществ в кровоток пациента через контакт с кожей."
	ru_names = list(
        NOMINATIVE = "пластырь",
        GENITIVE = "пластыря",
        DATIVE = "пластырю",
        ACCUSATIVE = "пластырь",
        INSTRUMENTAL = "пластырем",
        PREPOSITIONAL = "пластыре"
	)
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bandaid"
	item_state = "bandaid"
	possible_transfer_amounts = null
	volume = 20
	container_type = 0 //nooo my insta-kill patch!!!
	apply_type = REAGENT_TOUCH
	apply_method = "налепи"
	transfer_efficiency = 0.5 //patches aren't as effective at getting chemicals into the bloodstream.
	temperature_min = 270
	temperature_max = 350
	var/needs_to_apply_reagents = TRUE
	var/application_zone = null
	var/protection_on_apply = 1


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
	var/mob/living/carbon/human/H = target
	if(istype(H))
		protection_on_apply = H.get_permeability_protection_organ(target.get_organ(def_zone))
	application_zone = def_zone
	LAZYADD(target.processing_patches, src)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/item/reagent_containers/food/pill/patch/afterattack(obj/target, mob/user, proximity, params)
	return // thanks inheritance again

/obj/item/reagent_containers/food/pill/patch/styptic
	name = "healing patch"
	desc = "Помогает при порезах и ушибах."
	ru_names = list(
        NOMINATIVE = "пластырь (Мех. Повреждения)",
        GENITIVE = "пластыря (Мех. Повреждения)",
        DATIVE = "пластырю (Мех. Повреждения)",
        ACCUSATIVE = "пластырь (Мех. Повреждения)",
        INSTRUMENTAL = "пластырем (Мех. Повреждения)",
        PREPOSITIONAL = "пластыре (Мех. Повреждения)"
	)
	icon_state = "bandaid2"
	instant_application = 1
	list_reagents = list("styptic_powder" = 20)

/obj/item/reagent_containers/food/pill/patch/styptic/small
	name = "healing mini-patch"
	ru_names = list(
        NOMINATIVE = "мини-пластырь (Мех. Повреждения)",
        GENITIVE = "мини-пластыря (Мех. Повреждения)",
        DATIVE = "мини-пластырю (Мех. Повреждения)",
        ACCUSATIVE = "мини-пластырь (Мех. Повреждения)",
        INSTRUMENTAL = "мини-пластырем (Мех. Повреждения)",
        PREPOSITIONAL = "мини-пластыре (Мех. Повреждения)"
	)
	icon_state = "bandaid1"
	list_reagents = list("styptic_powder" = 10)

/obj/item/reagent_containers/food/pill/patch/silver_sulf
	name = "burn patch"
	desc = "Помогает при ожогах."
	ru_names = list(
        NOMINATIVE = "пластырь (Терм. Повреждения)",
        GENITIVE = "пластыря (Терм. Повреждения)",
        DATIVE = "пластырю (Терм. Повреждения)",
        ACCUSATIVE = "пластырь (Терм. Повреждения)",
        INSTRUMENTAL = "пластырем (Терм. Повреждения)",
        PREPOSITIONAL = "пластыре (Терм. Повреждения)"
	)
	icon_state = "bandaid4"
	instant_application = 1
	list_reagents = list("silver_sulfadiazine" = 20)

/obj/item/reagent_containers/food/pill/patch/silver_sulf/small
	name = "burn mini-patch"
	ru_names = list(
        NOMINATIVE = "мини-пластырь (Терм. Повреждения)",
        GENITIVE = "мини-пластыря (Терм. Повреждения)",
        DATIVE = "мини-пластырю (Терм. Повреждения)",
        ACCUSATIVE = "мини-пластырь (Терм. Повреждения)",
        INSTRUMENTAL = "мини-пластырем (Терм. Повреждения)",
        PREPOSITIONAL = "мини-пластыре (Терм. Повреждения)"
	)
	icon_state = "bandaid3"
	list_reagents = list("silver_sulfadiazine" = 10)

/obj/item/reagent_containers/food/pill/patch/synthflesh
	name = "synthflesh patch"
	desc = "Помогает лечить как механические, так и термические повреждения."
	ru_names = list(
        NOMINATIVE = "пластырь (Синт-плоть)",
        GENITIVE = "пластыря (Синт-плоть)",
        DATIVE = "пластырю (Синт-плоть)",
        ACCUSATIVE = "пластырь (Синт-плоть)",
        INSTRUMENTAL = "пластырем (Синт-плоть)",
        PREPOSITIONAL = "пластыре (Синт-плоть)"
	)
	icon_state = "bandaid8"
	instant_application = 1
	list_reagents = list("synthflesh" = 10)

/obj/item/reagent_containers/food/pill/patch/nicotine
	name = "nicotine patch"
	desc = "Помогает облегчить никотиновую зависимость."
	ru_names = list(
        NOMINATIVE = "пластырь (Никотин)",
        GENITIVE = "пластыря (Никотин)",
        DATIVE = "пластырю (Никотин)",
        ACCUSATIVE = "пластырь (Никотин)",
        INSTRUMENTAL = "пластырем (Никотин)",
        PREPOSITIONAL = "пластыре (Никотин)"
	)
	list_reagents = list("nicotine" = 10)

/obj/item/reagent_containers/food/pill/patch/jestosterone
	name = "jestosterone patch"
	desc = "Вводит необходимую дозу хи-хи и ха-ха прямо в кровь."
	ru_names = list(
        NOMINATIVE = "пластырь (Шутостерон)",
        GENITIVE = "пластыря (Шутостерон)",
        DATIVE = "пластырю (Шутостерон)",
        ACCUSATIVE = "пластырь (Шутостерон)",
        INSTRUMENTAL = "пластырем (Шутостерон)",
        PREPOSITIONAL = "пластыре (Шутостерон)"
	)
	icon_state = "bandaid20"
	list_reagents = list("jestosterone" = 20)

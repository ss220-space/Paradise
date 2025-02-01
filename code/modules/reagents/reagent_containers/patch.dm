/obj/item/reagent_containers/food/pill/patch
	name = "chemical patch"
	desc = "Химический патч, предназначенный для медленного ввода веществ в кровоток пациента через контакт с кожей."
	ru_names = list(
        NOMINATIVE = "патч",
        GENITIVE = "патча",
        DATIVE = "патчу",
        ACCUSATIVE = "патч",
        INSTRUMENTAL = "патчем",
        PREPOSITIONAL = "патче"
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
        NOMINATIVE = "патч (Мех. Повреждения)",
        GENITIVE = "патча (Мех. Повреждения)",
        DATIVE = "патчу (Мех. Повреждения)",
        ACCUSATIVE = "патч (Мех. Повреждения)",
        INSTRUMENTAL = "патчем (Мех. Повреждения)",
        PREPOSITIONAL = "патче (Мех. Повреждения)"
	)
	icon_state = "bandaid2"
	instant_application = 1
	list_reagents = list("styptic_powder" = 20)

/obj/item/reagent_containers/food/pill/patch/styptic/small
	name = "healing mini-patch"
	ru_names = list(
        NOMINATIVE = "мини-патч (Мех. Повреждения)",
        GENITIVE = "мини-патча (Мех. Повреждения)",
        DATIVE = "мини-патчу (Мех. Повреждения)",
        ACCUSATIVE = "мини-патч (Мех. Повреждения)",
        INSTRUMENTAL = "мини-патчем (Мех. Повреждения)",
        PREPOSITIONAL = "мини-патче (Мех. Повреждения)"
	)
	icon_state = "bandaid1"
	list_reagents = list("styptic_powder" = 10)

/obj/item/reagent_containers/food/pill/patch/silver_sulf
	name = "burn patch"
	desc = "Помогает при ожогах."
	ru_names = list(
        NOMINATIVE = "патч (Терм. Повреждения)",
        GENITIVE = "патча (Терм. Повреждения)",
        DATIVE = "патчу (Терм. Повреждения)",
        ACCUSATIVE = "патч (Терм. Повреждения)",
        INSTRUMENTAL = "патчем (Терм. Повреждения)",
        PREPOSITIONAL = "патче (Терм. Повреждения)"
	)
	icon_state = "bandaid4"
	instant_application = 1
	list_reagents = list("silver_sulfadiazine" = 20)

/obj/item/reagent_containers/food/pill/patch/silver_sulf/small
	name = "burn mini-patch"
	ru_names = list(
        NOMINATIVE = "мини-патч (Терм. Повреждения)",
        GENITIVE = "мини-патча (Терм. Повреждения)",
        DATIVE = "мини-патчу (Терм. Повреждения)",
        ACCUSATIVE = "мини-патч (Терм. Повреждения)",
        INSTRUMENTAL = "мини-патчем (Терм. Повреждения)",
        PREPOSITIONAL = "мини-патче (Терм. Повреждения)"
	)
	icon_state = "bandaid3"
	list_reagents = list("silver_sulfadiazine" = 10)

/obj/item/reagent_containers/food/pill/patch/synthflesh
	name = "synthflesh patch"
	desc = "Помогает лечить как механические, так и термические повреждения."
	ru_names = list(
        NOMINATIVE = "патч (Синт-плоть)",
        GENITIVE = "патча (Синт-плоть)",
        DATIVE = "патчу (Синт-плоть)",
        ACCUSATIVE = "патч (Синт-плоть)",
        INSTRUMENTAL = "патчем (Синт-плоть)",
        PREPOSITIONAL = "патче (Синт-плоть)"
	)
	icon_state = "bandaid8"
	instant_application = 1
	list_reagents = list("synthflesh" = 10)

/obj/item/reagent_containers/food/pill/patch/nicotine
	name = "nicotine patch"
	desc = "Помогает облегчить никотиновой зависимости."
	ru_names = list(
        NOMINATIVE = "патч (Никотин)",
        GENITIVE = "патча (Никотин)",
        DATIVE = "патчу (Никотин)",
        ACCUSATIVE = "патч (Никотин)",
        INSTRUMENTAL = "патчем (Никотин)",
        PREPOSITIONAL = "патче (Никотин)"
	)
	list_reagents = list("nicotine" = 10)

/obj/item/reagent_containers/food/pill/patch/jestosterone
	name = "jestosterone patch"
	desc = "Вводит необходимую дозу хи-хи и ха-ха прямо в кровь."
	ru_names = list(
        NOMINATIVE = "патч (Шутостерон)",
        GENITIVE = "патча (Шутостерон)",
        DATIVE = "патчу (Шутостерон)",
        ACCUSATIVE = "патч (Шутостерон)",
        INSTRUMENTAL = "патчем (Шутостерон)",
        PREPOSITIONAL = "патче (Шутостерон)"
	)
	icon_state = "bandaid20"
	list_reagents = list("jestosterone" = 20)

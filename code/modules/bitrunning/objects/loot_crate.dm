#define ORE_MULTIPLIER_IRON 3
#define ORE_MULTIPLIER_GLASS 2
#define ORE_MULTIPLIER_PLASMA 1
#define ORE_MULTIPLIER_SILVER 0.7
#define ORE_MULTIPLIER_GOLD 0.6
#define ORE_MULTIPLIER_TITANIUM 0.5
#define ORE_MULTIPLIER_URANIUM 0.4
#define ORE_MULTIPLIER_DIAMOND 0.3
#define ORE_MULTIPLIER_BLUESPACE_CRYSTAL 0.2

/obj/structure/closet/crate/secure/bitrunning
	name = "bitrunning cache"
	desc = "Контейнер, собранный из чистых данных."

/obj/structure/closet/crate/secure/bitrunning/get_ru_names()
	return alist(
		NOMINATIVE = "контейнер битраннера",
		GENITIVE = "контейнера битраннера",
		DATIVE = "контейнеру битраннера",
		ACCUSATIVE = "контейнер битраннера",
		INSTRUMENTAL = "контейнером битраннера",
		PREPOSITIONAL = "контейнере битраннера",
	)

/obj/structure/closet/crate/secure/bitrunning/encrypted
	name = "encrypted cache"
	desc = "Зашифрован. Чтобы вскрыть его, нужно дотащить контейнер до площадки выдачи."
	can_be_emaged = FALSE
	damage_deflection = 30
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/closet/crate/secure/bitrunning/encrypted/get_ru_names()
	return alist(
		NOMINATIVE = "зашифрованный контейнер",
		GENITIVE = "зашифрованного контейнера",
		DATIVE = "зашифрованному контейнеру",
		ACCUSATIVE = "зашифрованный контейнер",
		INSTRUMENTAL = "зашифрованным контейнером",
		PREPOSITIONAL = "зашифрованном контейнере",
	)

/obj/structure/closet/crate/secure/bitrunning/encrypted/togglelock(mob/living/user)
	balloon_alert(user, "шифрование не поддаётся!")
	return FALSE

/obj/structure/closet/crate/secure/bitrunning/decrypted
	name = "decrypted cache"
	desc = "Скомпилирован из виртуального домена. Награда удачливого битраннера."
	locked = FALSE

/obj/structure/closet/crate/secure/bitrunning/decrypted/get_ru_names()
	return alist(
		NOMINATIVE = "расшифрованный контейнер",
		GENITIVE = "расшифрованного контейнера",
		DATIVE = "расшифрованному контейнеру",
		ACCUSATIVE = "расшифрованный контейнер",
		INSTRUMENTAL = "расшифрованным контейнером",
		PREPOSITIONAL = "расшифрованном контейнере",
	)

/obj/item/storage/lockbox/bitrunning
	name = "curiosity"
	desc = "Запертый ящик, собранный из чистых данных."
	icon_state = "lockbox"
	req_access = list(ACCESS_BITRUNNING)

/obj/item/storage/lockbox/bitrunning/get_ru_names()
	return alist(
		NOMINATIVE = "диковина",
		GENITIVE = "диковины",
		DATIVE = "диковине",
		ACCUSATIVE = "диковину",
		INSTRUMENTAL = "диковиной",
		PREPOSITIONAL = "диковине",
	)

/obj/item/storage/lockbox/bitrunning/encrypted
	name = "encrypted curiosity"
	desc = "Зашифрована. Положите её на площадку выдачи в убежище, как и основной груз."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/storage/lockbox/bitrunning/encrypted/get_ru_names()
	return alist(
		NOMINATIVE = "зашифрованная диковина",
		GENITIVE = "зашифрованной диковины",
		DATIVE = "зашифрованной диковине",
		ACCUSATIVE = "зашифрованную диковину",
		INSTRUMENTAL = "зашифрованной диковиной",
		PREPOSITIONAL = "зашифрованной диковине",
	)

/obj/item/storage/lockbox/bitrunning/decrypted
	name = "decrypted curiosity"
	desc = "Скомпилирована из виртуального домена. Побочная добыча битраннера."
	locked = FALSE
	var/datum/lazy_template/virtual_domain/source_domain

/obj/item/storage/lockbox/bitrunning/decrypted/get_ru_names()
	return alist(
		NOMINATIVE = "расшифрованная диковина",
		GENITIVE = "расшифрованной диковины",
		DATIVE = "расшифрованной диковине",
		ACCUSATIVE = "расшифрованную диковину",
		INSTRUMENTAL = "расшифрованной диковиной",
		PREPOSITIONAL = "расшифрованной диковине",
	)

/obj/item/storage/lockbox/bitrunning/decrypted/Initialize(mapload, datum/lazy_template/virtual_domain/completed_domain)
	source_domain = completed_domain
	. = ..()
	playsound(src, 'sound/effects/phasein.ogg', 50, TRUE)

/obj/item/storage/lockbox/bitrunning/decrypted/populate_contents()
	var/path = source_domain?.take_secondary_loot()
	if(isnull(path))
		return

	new path(src)

/obj/structure/closet/crate/secure/bitrunning/decrypted/Initialize(mapload, datum/lazy_template/virtual_domain/completed_domain, rewards_multiplier = 1)
	. = ..()
	playsound(src, 'sound/effects/phasein.ogg', 50, TRUE)

	if(isnull(completed_domain))
		return

	fill_with_rewards(completed_domain, rewards_multiplier)

/obj/structure/closet/crate/secure/bitrunning/decrypted/proc/fill_with_rewards(datum/lazy_template/virtual_domain/completed_domain, rewards_multiplier)
	var/reward_points = completed_domain.reward_points

	for(var/path in completed_domain.completion_loot)
		for(var/count in 1 to completed_domain.completion_loot[path])
			new path(src)

	new /obj/item/stack/ore/iron(src, calculate_ore_amount(reward_points, rewards_multiplier, ORE_MULTIPLIER_IRON))
	new /obj/item/stack/ore/glass(src, calculate_ore_amount(reward_points, rewards_multiplier, ORE_MULTIPLIER_GLASS))

	if(reward_points > 1)
		new /obj/item/stack/ore/silver(src, calculate_ore_amount(reward_points, rewards_multiplier, ORE_MULTIPLIER_SILVER))
		new /obj/item/stack/ore/titanium(src, calculate_ore_amount(reward_points, rewards_multiplier, ORE_MULTIPLIER_TITANIUM))

	if(reward_points > 2)
		new /obj/item/stack/ore/plasma(src, calculate_ore_amount(reward_points, rewards_multiplier, ORE_MULTIPLIER_PLASMA))
		new /obj/item/stack/ore/gold(src, calculate_ore_amount(reward_points, rewards_multiplier, ORE_MULTIPLIER_GOLD))
		new /obj/item/stack/ore/uranium(src, calculate_ore_amount(reward_points, rewards_multiplier, ORE_MULTIPLIER_URANIUM))

	if(reward_points > 3)
		new /obj/item/stack/ore/diamond(src, calculate_ore_amount(reward_points, rewards_multiplier, ORE_MULTIPLIER_DIAMOND))
		new /obj/item/stack/ore/bluespace_crystal(src, calculate_ore_amount(reward_points, rewards_multiplier, ORE_MULTIPLIER_BLUESPACE_CRYSTAL))

/obj/structure/closet/crate/secure/bitrunning/decrypted/proc/calculate_ore_amount(reward_points, rewards_multiplier, ore_multiplier)
	var/base = rewards_multiplier + reward_points
	var/random_sum = (rand() + 0.5) * base
	return max(ROUND_UP(random_sum * ore_multiplier), 1)

#undef ORE_MULTIPLIER_IRON
#undef ORE_MULTIPLIER_GLASS
#undef ORE_MULTIPLIER_PLASMA
#undef ORE_MULTIPLIER_SILVER
#undef ORE_MULTIPLIER_GOLD
#undef ORE_MULTIPLIER_TITANIUM
#undef ORE_MULTIPLIER_URANIUM
#undef ORE_MULTIPLIER_DIAMOND
#undef ORE_MULTIPLIER_BLUESPACE_CRYSTAL

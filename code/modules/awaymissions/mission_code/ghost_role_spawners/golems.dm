//Golem shells: Spawns in Free Golem ships in lavaland, or through xenobiology adamantine extract.
//Xenobiology golems are slaved to their creator.

/obj/item/golem_shell
	name = "incomplete free golem shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "Незавершённое тело голема. Добавьте десять листов любого минерала, чтобы завершить его."
	ru_names = list(
		NOMINATIVE = "незавершённая оболочка свободного голема",
		GENITIVE = "незавершённой оболочки свободного голема",
		DATIVE = "незавершённой оболочке свободного голема",
		ACCUSATIVE = "незавершённую оболочку свободного голема",
		INSTRUMENTAL = "незавершённой оболочкой свободного голема",
		PREPOSITIONAL = "незавершённой оболочке свободного голема"
	)
	var/shell_type = /obj/effect/mob_spawn/human/golem
	w_class = WEIGHT_CLASS_BULKY

/obj/item/golem_shell/servant
	name = "incomplete servant golem shell"
	ru_names = list(
		NOMINATIVE = "незавершённая оболочка голема-слуги",
		GENITIVE = "незавершённой оболочки голема-слуги",
		DATIVE = "незавершённой оболочке голема-слуги",
		ACCUSATIVE = "незавершённую оболочку голема-слуги",
		INSTRUMENTAL = "незавершённой оболочкой голема-слуги",
		PREPOSITIONAL = "незавершённой оболочке голема-слуги"
	)
	shell_type = /obj/effect/mob_spawn/human/golem/servant


/obj/item/golem_shell/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !isstack(I))
		return .

	add_fingerprint(user)
	if(!isturf(loc))
		to_chat(user, span_warning("Вы должны разместить оболочку на землю, чтобы завершить голема."))
		return .

	var/static/list/golem_shell_species_types = list(
		/obj/item/stack/sheet/metal					= /datum/species/golem,
		/obj/item/stack/sheet/glass					= /datum/species/golem/glass,
		/obj/item/stack/sheet/plasteel				= /datum/species/golem/plasteel,
		/obj/item/stack/ore/glass					= /datum/species/golem/sand,
		/obj/item/stack/sheet/mineral/sandstone		= /datum/species/golem/sand,
		/obj/item/stack/sheet/mineral/plasma		= /datum/species/golem/plasma,
		/obj/item/stack/sheet/mineral/diamond		= /datum/species/golem/diamond,
		/obj/item/stack/sheet/mineral/gold			= /datum/species/golem/gold,
		/obj/item/stack/sheet/mineral/silver		= /datum/species/golem/silver,
		/obj/item/stack/sheet/mineral/uranium		= /datum/species/golem/uranium,
		/obj/item/stack/sheet/mineral/bananium		= /datum/species/golem/bananium,
		/obj/item/stack/sheet/mineral/tranquillite	= /datum/species/golem/tranquillite,
		/obj/item/stack/sheet/mineral/titanium		= /datum/species/golem/titanium,
		/obj/item/stack/sheet/mineral/plastitanium	= /datum/species/golem/plastitanium,
		/obj/item/stack/sheet/mineral/abductor		= /datum/species/golem/alloy,
		/obj/item/stack/sheet/wood					= /datum/species/golem/wood,
		/obj/item/stack/sheet/bluespace_crystal		= /datum/species/golem/bluespace,
		/obj/item/stack/sheet/mineral/adamantine	= /datum/species/golem/adamantine,
		/obj/item/stack/sheet/plastic				= /datum/species/golem/plastic,
		/obj/item/stack/sheet/brass					= /datum/species/golem/clockwork,
	)

	var/obj/item/stack/stack = I
	var/species = golem_shell_species_types[stack.merge_type]
	if(!species)
		to_chat(user, span_warning("Вы не можете построить голема из этого материала."))
		return .
	if(!stack.use(10))
		to_chat(user, span_warning("Вам нужно как минимум десять листов [stack], чтобы завершить голема."))
		return .
	to_chat(user, span_notice("Вы завершили оболочку голема, используя десять листов [stack]."))
	new shell_type(loc, species, user)
	qdel(src)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/effect/mob_spawn/human/golem
	name = "inert free golem shell"
	desc = "Гуманоидная форма, пустая, безжизненная, но полная потенциала."
	ru_names = list(
		NOMINATIVE = "инертная оболочка свободного голема",
		GENITIVE = "инертной оболочки свободного голема",
		DATIVE = "инертной оболочке свободного голема",
		ACCUSATIVE = "инертную оболочку свободного голема",
		INSTRUMENTAL = "инертной оболочкой свободного голема",
		PREPOSITIONAL = "инертной оболочке свободного голема"
	)
	mob_name = "a free golem"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	mob_species = /datum/species/golem
	roundstart = FALSE
	death = FALSE
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	var/has_owner = FALSE
	var/can_transfer = TRUE //if golems can switch bodies to this new shell
	var/mob/living/owner = null //golem's owner if it has one
	important_info = "Вы не антагонист. Не вмешивайтесь в дела станции, и не создавайте ИИ."
	description = "Как свободный голем на Лавленде, вы не можете использовать большинство оружия, но можете добывать ресурсы, проводить исследования и создавать себе подобных. Заработайте достаточно очков добычи руды, и вы сможете даже улететь на своём шаттле."
	flavour_text = "Вы – свободный голем. Ваш клан поклоняется Освободителю.\nВ своей бесконечной и божественной мудрости он освободил ваш клан, чтобы вы могли путешествовать по звёздам, сказав: \"Да делайте что хотите\".\nХотя вы связаны с тем, кто вас создал, в вашем обществе принято повторять эти же слова новорождённым големам, чтобы ни один голем больше не был вынужден служить."

/obj/effect/mob_spawn/human/golem/Initialize(mapload, datum/species/golem/species = null, mob/creator = null)
	if(species) //spawners list uses object name to register so this goes before ..()
		name += " ([initial(species.prefix)]ая)"
		mob_species = species
	. = ..()
	var/area/A = get_area(src)
	if(!mapload && A)
		var/golem_type_text = initial(species.prefix) != null ? initial(species.prefix) + "ая " : initial(species.prefix)
		notify_ghosts("Собрана [golem_type_text]оболочка голема на [A.name].", source = src) //здесь пробел перед не нужен, это не ошибка!
	if(has_owner && creator)
		important_info = "Служите своему создателю, даже если он антагонист."
		flavour_text = "Вы – голем, созданный для служения своему создателю."
		description = "Вы – голем. Вы двигаетесь медленно, но достаточно устойчивы к жаре, холоду и травмам. Вы не можете носить одежду, но можете использовать большинство инструментов. Служите [creator] и помогайте ему в достижении его целей любой ценой."
		owner = creator

/obj/effect/mob_spawn/human/golem/special(mob/living/new_spawn, name)
	var/datum/species/golem/X = mob_species
	to_chat(new_spawn, "[initial(X.info_text)]")
	if(!owner)
		to_chat(new_spawn, span_notice("В обществах свободных големов принято уважать адамантиновых големов как старейшин, однако вы не обязаны подчиняться им. Адамантиновые големы – единственные, кто может резонировать со всеми големами."))
		to_chat(new_spawn, "Создавайте оболочки големов в автолате и добавляйте обработанные минеральные листы в оболочки, чтобы оживить их! Вы – мирная группа, если вас не провоцировать.")
		to_chat(new_spawn, span_warning("Вы не антагонист и не член экипажа. Вы можете взаимодействовать или торговать с экипажем, а также защищать себя и свой корабль, но избегайте активного вмешательства в дела станции, если у вас нет веской ролевой причины, например, приглашения от членов экипажа."))
	else
		new_spawn.mind.store_memory("<b>Служите [owner.real_name], своему создателю.</b>")
		add_game_logs("[key_name(new_spawn)] possessed a golem shell enslaved to [key_name(owner)].")
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		if(has_owner)
			var/datum/species/golem/G = H.dna.species
			G.owner = owner
		if(!name || name == "Unknown")
			H.rename_character(null, H.dna.species.get_random_name())
		else
			H.rename_character(null, name)
		if(is_species(H, /datum/species/golem/tranquillite) && H.mind)
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/conjure/build/mime_wall(null))
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/mime/speak(null))
			H.mind.miming = TRUE

	if(has_owner)
		new_spawn.mind.assigned_role = "Servant Golem"
	else
		new_spawn.mind.assigned_role = "Free Golem"

/obj/effect/mob_spawn/human/golem/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(isgolem(user) && can_transfer)
		var/transfer_choice = tgui_alert(user, "Перенести вашу душу в [declent_ru(ACCUSATIVE)]? (Внимание, ваше старое тело умрёт!)", "Перенести", list("Да","Нет"))
		if(transfer_choice != "Да")
			return
		if(QDELETED(src) || uses <= 0)
			return
		add_game_logs("golem-swapped into [src]", user)
		user.visible_message(span_notice("Слабый свет покидает [user], перемещаясь в [declent_ru(ACCUSATIVE)] и оживляя его!"), span_notice("Вы покидаете своё старое тело и переноситесь в [declent_ru(ACCUSATIVE)]!)"))
		create(plr = user, name = user.real_name)
		user.death()
		return

/obj/effect/mob_spawn/human/golem/servant
	has_owner = TRUE
	name = "inert servant golem shell"
	ru_names = list(
		NOMINATIVE = "инертная оболочка голема-слуги",
		GENITIVE = "инертной оболочки голема-слуги",
		DATIVE = "инертной оболочке голема-слуги",
		ACCUSATIVE = "инертную оболочку голема-слуги",
		INSTRUMENTAL = "инертной оболочкой голема-слуги",
		PREPOSITIONAL = "инертной оболочке голема-слуги"
	)
	mob_name = "a servant golem"

/obj/effect/mob_spawn/human/golem/adamantine
	name = "dust-caked free golem shell"
	desc = "Гуманоидная форма, пустая, безжизненная, но полная потенциала."
	ru_names = list(
		NOMINATIVE = "покрытая пылью оболочка свободного голема",
		GENITIVE = "покрытой пылью оболочки свободного голема",
		DATIVE = "покрытой пылью оболочке свободного голема",
		ACCUSATIVE = "покрытую пылью оболочку свободного голема",
		INSTRUMENTAL = "покрытой пылью оболочкой свободного голема",
		PREPOSITIONAL = "покрытой пылью оболочке свободного голема"
	)
	mob_name = "a free golem"
	can_transfer = FALSE
	mob_species = /datum/species/golem/adamantine

/obj/effect/mob_spawn/human/golem/clockwork
	name = "fleshed golem shell"
	desc = "Это тело когда-то было сделано из плоти, но теперь... это просто оболочка, отлитая в латуни."
	ru_names = list(
		NOMINATIVE = "оболочка голема из плоти",
		GENITIVE = "оболочки голема из плоти",
		DATIVE = "оболочке голема из плоти",
		ACCUSATIVE = "оболочку голема из плоти",
		INSTRUMENTAL = "оболочкой голема из плоти",
		PREPOSITIONAL = "оболочке голема из плоти"
	)
	mob_name = "a clockwork golem"
	can_transfer = FALSE
	mob_species = /datum/species/golem/clockwork
	banType = ROLE_CLOCKER
	offstation_role = FALSE
	random = TRUE
	important_info =  "Вы – антагонист, но вы должны служить другим слугам, чтобы призвать Ратвара!"
	description = "Вы – голем. Вы двигаетесь медленно. Вы не можете носить одежду, но можете использовать большинство инструментов. Служите Ратвару и завершите ритуал любой ценой."
	flavour_text = "Вы – часовой голем, созданный для служения Ратвару."

/obj/effect/mob_spawn/human/golem/clockwork/special(mob/living/new_spawn, name)
	var/datum/species/golem/X = mob_species
	to_chat(new_spawn, "[initial(X.info_text)]")
	new_spawn.rename_character(null, new_spawn.dna.species.get_random_name())
	SSticker.mode.add_clocker(new_spawn)

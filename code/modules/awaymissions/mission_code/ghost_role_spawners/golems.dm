//Golem shells: Spawns in Free Golem ships in lavaland, or through xenobiology adamantine extract.
//Xenobiology golems are slaved to their creator.

/obj/item/golem_shell
	name = "незавершенная оболочка свободного голема"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "Незавершенное тело голема. Добавьте десять листов любого минерала для завершения сборки."
	var/shell_type = /obj/effect/mob_spawn/human/golem
	w_class = WEIGHT_CLASS_BULKY

/obj/item/golem_shell/servant
	name = "незавершенная оболочка голема-прислужника"
	shell_type = /obj/effect/mob_spawn/human/golem/servant

/obj/item/golem_shell/attackby(obj/item/I, mob/user, params)
	..()
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
		/obj/item/stack/sheet/plastic				= /datum/species/golem/plastic)

	if(istype(I, /obj/item/stack))
		var/obj/item/stack/O = I
		var/species = golem_shell_species_types[O.merge_type]
		if(species)
			if(O.use(10))
				to_chat(user, "Вы собрали оболочку голема десятью листами [O.name].")
				new shell_type(get_turf(src), species, user)
				qdel(src)
			else
				to_chat(user, "Вам нужно как минимум десять листов, чтобы собрать голема.")
		else
			to_chat(user, "Вы не можете собрать голема из такого металла.")

/obj/effect/mob_spawn/human/golem
	name = "инертная оболочка свободного голема"
	desc = "Гуманоидная форма, пуста, безжизненна и полна потенциала."
	mob_name = "свободный голем"
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
	important_info = "Вы не антагонист. Не впутывайтесь в дела станции и не создавайте ИИ."
	description = "Будучи свободным големом лаваленда, вы не можете использовать большую часть оружия, но вы можете добывать, исследовать и создавать больше себе подобных. Заработав достаточно очков, вы даже сможете улететь на шаттле."
	flavour_text = "Вы свободный голем. Ваша семья поклоняется Освободителю. В своей безграничной и божественной мудрости он освободил ваш клан, \
	чтобы вы могли путешествовать по звездам, с единственным заявлением: \"Да делайте что хотите.\" Хоть вы и связаны с тем, кто вас создал, в вашем обществе принято повторять \
	эти слова новорожденным големам, чтобы ни один голем больше никогда не был вынужден служить."

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
		important_info = "Служите вашему создателю, даже если он антагонист."
		flavour_text = "Вы голем, созданный для службы своему хозяину."
		description = "Вы Голем. Вы медленно двигаетесь, но вы устойчивы к жаре и холоду, а также к тупым травмам. \
		Вы не можете носить одежду, кроме плащей, но можете пользоваться большинством инструментов. \
		Служите [creator], и помогайте [genderize_ru(creator.gender,"ему","ей","этому","им")] в достижении [genderize_ru(creator.gender,"его","её","этого","их")] целей."
		owner = creator

/obj/effect/mob_spawn/human/golem/special(mob/living/new_spawn, name)
	var/datum/species/golem/X = mob_species
	to_chat(new_spawn, "[initial(X.info_text)]")
	if(!owner)
		to_chat(new_spawn, "<span class='notice'>В обществах свободных големов принято уважать адамантовых големов как старейшин, однако вы не обязаны им подчиняться. \
		Адамантиновые големы — единственные големы, которые могут резонировать со всеми големами.</span>")
		to_chat(new_spawn, "Создавайте оболочки големов в автолате и загружайте в них минеральные листы, чтобы оживить их! Вы довольно миролюбивая община, пока вас не провоцируют.")
		to_chat(new_spawn, "<span class='warning'>Вы не антагонист. А также не член экипажа. \
		Вы можете взаимодействовать или торговать с экипажем, с которым вы сталкиваетесь, а также защищать себя и свой корабль, \
		но избегайте активных вмешательств в работу станции, если у вас нет для этого веской ролевой причины, такой как приглашение членов экипажа.</span>")
	else
		new_spawn.mind.store_memory("<b>Служите [owner.real_name], вашему создателю.</b>")
		log_game("[key_name(new_spawn)] possessed a golem shell enslaved to [key_name(owner)].")
		log_admin("[key_name(new_spawn)] possessed a golem shell enslaved to [key_name(owner)].")
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		if(has_owner)
			var/datum/species/golem/G = H.dna.species
			G.owner = owner
		if(!name || name == "" || name == "Unknown") //Существует баг который заставляет всех големов бегать без имени. Я так и не нашел почему он вызывается и как, поэтому пускай будет хоть какая-то проверка при создании големов.
			H.rename_character(null, H.dna.species.get_random_name())
		else
			H.rename_character(null, name)
		if(is_species(H, /datum/species/golem/tranquillite) && H.mind)
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall(null))
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak(null))
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
		var/transfer_choice = alert("Перенести свою душу в [src.name]? (Осторожно, ваше старое тело умрет!)",,"Да","Нет")
		if(transfer_choice != "Yes")
			return
		if(QDELETED(src) || uses <= 0)
			return
		log_game("[key_name(user)] golem-swapped into [src]")
		user.visible_message("<span class='notice'>Тусклый свет покинул [user.name], перелетев к [src.name] и оживив его!</span>","<span class='notice'>Вы покинули старое тело и переместились в [src.name]!</span>")
		create(ckey = user.ckey, name = user.real_name)
		user.death()
		return

/obj/effect/mob_spawn/human/golem/servant
	has_owner = TRUE
	name = "инертная оболочка голема-прислужника"
	mob_name = "голем-прислужник"

/obj/effect/mob_spawn/human/golem/adamantine
	name = "пыльная оболочка свободного голема"
	desc = "Гуманоидная форма, пуста, безжизненна и полна потенциала."
	mob_name = "свободный голем"
	can_transfer = FALSE
	mob_species = /datum/species/golem/adamantine

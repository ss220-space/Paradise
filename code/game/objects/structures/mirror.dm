//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	anchored = TRUE
	max_integrity = 200
	integrity_failure = 100
	flags_ricochet = RICOCHET_SHINY | RICOCHET_HARD
	var/list/ui_users = list()

/obj/structure/mirror/Initialize(mapload, newdir = SOUTH, building = FALSE)
	. = ..()
	if(building)
		switch(newdir)
			if(NORTH)
				pixel_y = -32
			if(SOUTH)
				pixel_y = 32
			if(EAST)
				pixel_x = -32
			if(WEST)
				pixel_x = 32
	GLOB.mirrors += src

/obj/structure/mirror/Destroy()
	QDEL_LIST_ASSOC_VAL(ui_users)
	GLOB.mirrors -= src
	return ..()

/obj/structure/mirror/attack_hand(mob/user)
	if(broken)
		return

	if(ishuman(user))
		var/datum/ui_module/appearance_changer/AC = ui_users[user]
		if(!AC)
			AC = new(src, user)
			AC.name = "SalonPro Nano-Mirror"
			AC.flags = APPEARANCE_ALL_BODY
			if(iswryn(user))
				AC.flags -= APPEARANCE_HAIR
			ui_users[user] = AC
		add_fingerprint(user)
		AC.ui_interact(user)

/obj/structure/mirror/obj_break(damage_flag, mapload)
	if(!broken && !(obj_flags & NODECONSTRUCT))
		icon_state = "mirror_broke"
		if(!mapload)
			playsound(src, SFX_SHATTER, 70, TRUE)
		if(desc == initial(desc))
			desc = "Oh no, seven years of bad luck!"
		broken = TRUE
		GLOB.mirrors -= src
		for(var/user in ui_users)
			SStgui.close_uis(ui_users[user])

/obj/structure/mirror/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message(span_notice("[user] begins to unfasten [src]."), span_notice("You begin to unfasten [src]."))
	if(!I.use_tool(src, user, 30, volume = I.tool_volume))
		return
	if(broken)
		user.visible_message(span_notice("[user] drops the broken shards to the floor."), span_notice("You drop the broken shards on the floor."))
		new /obj/item/shard(get_turf(user))
	else
		user.visible_message(span_notice("[user] carefully places [src] on the floor."), span_notice("You carefully place [src] on the floor."))
		new /obj/item/mounted/mirror(get_turf(user))
	qdel(src)

/obj/structure/mirror/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		if(!disassembled)
			new /obj/item/shard( src.loc )
	qdel(src)

/obj/structure/mirror/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
		if(BURN)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)

/obj/structure/mirror/handle_ricochet(obj/projectile/P)
	if(!anchored)
		return FALSE

	if(broken)
		if(prob(90))
			return FALSE
	else if(prob(70))
		return FALSE

	return ..()

/obj/item/mounted/mirror
	name = "mirror"
	desc = "Some reflective glass ready to be hung on a wall. Don't break it!"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"

/obj/item/mounted/mirror/do_build(turf/on_wall, mob/user)
	var/obj/structure/mirror/M = new /obj/structure/mirror(get_turf(user), get_dir(on_wall, user), 1)
	transfer_fingerprints_to(M)
	qdel(src)

#define MIRROR_CHANGE_HAIR "Волосы"
#define MIRROR_CHANGE_RACE "Раса"
#define MIRROR_CHANGE_SEX "Пол"
#define MIRROR_CHANGE_EYES "Глаза"

/obj/structure/mirror/heretic
	name = "miraculous mirror"
	desc = "Глядя на своё отражение, вы чувствуете, что могли бы стать лучше."
	icon_state = "magic_mirror"

/obj/structure/mirror/heretic/get_ru_names()
	return alist(
		NOMINATIVE = "чудотворное зеркало",
		GENITIVE = "чудотворного зеркала",
		DATIVE = "чудотворному зеркалу",
		ACCUSATIVE = "чудотворное зеркало",
		INSTRUMENTAL = "чудотворным зеркалом",
		PREPOSITIONAL = "чудотворном зеркале",
	)

/obj/structure/mirror/heretic/attack_hand(mob/user)
	if(broken || !ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	add_fingerprint(human_user)

	if(IS_HERETIC(human_user))
		var/datum/ui_module/appearance_changer/heretic_mirror/changer = ui_users[human_user]
		if(!changer)
			var/list/race_list = list(SPECIES_HUMAN)
			race_list += CONFIG_GET(str_list/playable_species)
			changer = new(src, human_user)
			changer.name = "Miraculous Mirror"
			changer.flags = APPEARANCE_ALL
			changer.whitelist = race_list
			changer.wizard_mirror = TRUE
			ui_users[human_user] = changer
		changer.ui_interact(human_user)
		return

	var/picked = tgui_input_list(human_user, "Что изменить?", "Чудотворное зеркало", list(MIRROR_CHANGE_HAIR, MIRROR_CHANGE_RACE, MIRROR_CHANGE_SEX, MIRROR_CHANGE_EYES))
	if(!picked || broken || !Adjacent(human_user))
		return

	to_chat(human_user, span_hypnophrase("Вы ловите себя на том, что не можете оторвать взгляд от [declent_ru(GENITIVE)]..."))
	human_user.Immobilize(5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(change_something), human_user, picked), 5 SECONDS)

/obj/structure/mirror/heretic/proc/change_something(mob/living/carbon/human/user, picked)
	if(QDELETED(src) || QDELETED(user))
		return

	if(!Adjacent(user))
		to_chat(user, span_warning("Вас оттащили от [declent_ru(GENITIVE)], и вы выходите из транса."))
		return
	if(broken)
		to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] разбивается, и вы выходите из транса."))
		return

	switch(picked)
		if(MIRROR_CHANGE_HAIR)
			to_chat(user, span_hypnophrase("Волосы — да, волосы никуда не годятся — [pick("их можно улучшить", "их нужно изменить", "они должны быть другими")]..."))
			var/list/hairstyles = user.generate_valid_hairstyles()
			if(length(hairstyles))
				user.change_hair(pick(hairstyles))
			var/list/facial_hairstyles = user.generate_valid_facial_hairstyles()
			if(length(facial_hairstyles))
				user.change_facial_hair(pick(facial_hairstyles))
		if(MIRROR_CHANGE_RACE)
			to_chat(user, span_hypnophrase("Тело — нет, тело совершенно не то — [pick("я должен родиться заново", "мне нужно стать другим", "я хочу быть чем-то иным")]..."))
			var/list/options = list(SPECIES_HUMAN) + CONFIG_GET(str_list/playable_species) - user.dna.species.name
			var/datum/species/newrace = GLOB.all_species[pick(options)]
			on_species_change(user, newrace)
			user.set_species(newrace.type)
		if(MIRROR_CHANGE_SEX)
			to_chat(user, span_hypnophrase("Моя форма — да, форма совсем не та — её нужно изменить..."))
			var/list/options = list(MALE, FEMALE, PLURAL, NEUTER) - user.gender
			user.change_gender(pick(options))
		if(MIRROR_CHANGE_EYES)
			to_chat(user, span_hypnophrase("Мои глаза — я не вижу ясно — [pick("они просто не те", "их нужно заменить", "они оба никуда не годятся")]..."))
			user.change_eye_color(ready_random_color())

/obj/structure/mirror/heretic/proc/on_species_change(mob/living/carbon/human/race_changer, datum/species/newrace)
	if(race_changer.dna?.species?.type == newrace.type)
		return
	obj_break()

/obj/structure/mirror/heretic/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message(span_notice("[user] начина[PLUR_ET_YUT(user)] снимать [declent_ru(ACCUSATIVE)]."), span_notice("Вы начинаете снимать [declent_ru(ACCUSATIVE)]."))
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
		return
	user.visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] рассыпается на осколки."), span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] рассыпается на осколки у вас в руках."))
	new /obj/item/shard(get_turf(user))
	qdel(src)

/obj/structure/mirror/heretic/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/shard(loc)
	qdel(src)

/datum/ui_module/appearance_changer/heretic_mirror

/datum/ui_module/appearance_changer/heretic_mirror/ui_act(action, list/params)
	var/old_species_type = owner?.dna?.species?.type
	. = ..()
	if(action != "race" || QDELETED(owner))
		return
	if(owner.dna?.species?.type == old_species_type)
		return
	var/obj/structure/mirror/heretic/mirror = host
	if(!QDELETED(mirror) && !mirror.broken)
		mirror.obj_break()

/obj/item/mounted/mirror/heretic
	name = "miraculous mirror"
	desc = "Глядя на своё отражение, вы чувствуете, что могли бы стать лучше. Осталось повесить его на стену."
	icon_state = "magic_mirror"

/obj/item/mounted/mirror/heretic/get_ru_names()
	return alist(
		NOMINATIVE = "чудотворное зеркало",
		GENITIVE = "чудотворного зеркала",
		DATIVE = "чудотворному зеркалу",
		ACCUSATIVE = "чудотворное зеркало",
		INSTRUMENTAL = "чудотворным зеркалом",
		PREPOSITIONAL = "чудотворном зеркале",
	)

/obj/item/mounted/mirror/heretic/do_build(turf/on_wall, mob/user)
	var/obj/structure/mirror/heretic/mirror = new(get_turf(user), get_dir(on_wall, user), TRUE)
	transfer_fingerprints_to(mirror)
	qdel(src)

#undef MIRROR_CHANGE_HAIR
#undef MIRROR_CHANGE_RACE
#undef MIRROR_CHANGE_SEX
#undef MIRROR_CHANGE_EYES

/obj/structure/mirror/magic
	name = "magic mirror"
	icon_state = "magic_mirror"

/obj/structure/mirror/magic/attack_hand(mob/user)
	if(!ishuman(user) || broken)
		return

	var/mob/living/carbon/human/H = user
	var/choice = tgui_input_list(user, "Something to change?", "Magical Grooming", list("Name", "Body", "Voice"))

	add_fingerprint(user)

	switch(choice)
		if("Name")
			var/newname = tgui_input_text(H, "Who are we again?", "Name change", H.name, max_length = MAX_NAME_LEN)

			if(!newname)
				return
			H.real_name = newname
			H.name = newname
			if(H.dna)
				H.dna.real_name = newname
			if(H.mind)
				H.mind.name = newname

			if(newname)
				curse(user)

		if("Body")
			var/list/race_list = list(SPECIES_HUMAN)
			race_list += CONFIG_GET(str_list/playable_species)

			var/datum/ui_module/appearance_changer/AC = ui_users[user]
			if(!AC)
				AC = new(src, user)
				AC.name = "Magic Mirror"
				AC.flags = APPEARANCE_ALL
				AC.whitelist = race_list
				AC.wizard_mirror = TRUE
				ui_users[user] = AC
			AC.ui_interact(user)

		if("Voice")
			var/voice_choice = tgui_input_list(user, "Perhaps...", "Voice effects", list("Comic Sans", "Wingdings", "Swedish", "Староимперский", "Mute"))
			var/voice_mutation
			switch(voice_choice)
				if("Comic Sans")
					voice_mutation = GLOB.comicblock
				if("Wingdings")
					voice_mutation = GLOB.wingdingsblock
				if("Swedish")
					voice_mutation = GLOB.swedeblock
				if("Староимперский")
					voice_mutation = GLOB.auld_imperial_block
				if("Mute")
					if(HAS_TRAIT_FROM(user, TRAIT_MUTE, "mirror"))
						REMOVE_TRAIT(user, TRAIT_MUTE, "mirror")
					else
						ADD_TRAIT(user, TRAIT_MUTE, "mirror")
			if(voice_mutation)
				H.force_gene_block(voice_mutation, !H.dna.GetSEState(voice_mutation))

			if(voice_choice)
				curse(user)

/obj/structure/mirror/magic/ui_close(mob/user)
	curse(user)

/obj/structure/mirror/magic/attackby(obj/item/I, mob/living/user, params)
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/structure/mirror/magic/proc/curse(mob/living/user)
	return

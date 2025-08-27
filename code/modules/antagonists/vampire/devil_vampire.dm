/datum/antagonist/vampire/devil_vampire
	name = "Devil-Vampire"
	nullification = OLD_NULLIFICATION
	is_garlic_affected = TRUE
	dust_in_space = TRUE
	antag_datum_blacklist = list(/datum/antagonist/vampire)
	antag_menu_name = "Вампир дьявола"
	upgrade_tiers = list(/obj/effect/proc_holder/spell/vampire/self/rejuvenate = 0,
								/obj/effect/proc_holder/spell/vampire/glare = 0,
								/obj/effect/proc_holder/spell/vampire/goon/self/shapeshift = 100,
								/obj/effect/proc_holder/spell/vampire/goon/self/cloak = 150,
								/obj/effect/proc_holder/spell/vampire/shadow_snare = 150,
								/obj/effect/proc_holder/spell/vampire/vamp_extinguish = 200,
								/obj/effect/proc_holder/spell/vampire/goon/self/screech = 200,
								/datum/vampire_passive/regen = 200,
								/obj/effect/proc_holder/spell/vampire/goon/shadowstep = 250,
								/obj/effect/proc_holder/spell/vampire/goon/self/jaunt = 300,
								/datum/vampire_passive/xray = 500,
								/datum/vampire_passive/full = 500)

/datum/antagonist/vampire/devil_vampire/add_owner_to_gamemode()
	SSticker.mode.vampires += owner


/datum/antagonist/vampire/devil_vampire/remove_owner_from_gamemode()
	SSticker.mode.vampires -= owner

/datum/antagonist/vampire/devil_vampire/greet()
	var/list/messages = list()
	SEND_SOUND(owner.current, sound('sound/ambience/antag/vampalert.ogg'))
	messages.Add(span_danger("Вы — вампир!<br>"))
	messages.Add(span_danger("Вы продали свою душу в обмен на вечную молодость. Однако у всего есть цена. Теперь вы вынуждены пить кровь, чтобы жить."))
	messages.Add(span_danger("Вы не являетесь полноценным антагонистом и не должны убивать, за исключением случаев самообороны<br>"))
	messages.Add("Чтобы укусить кого-то, нацельтесь на голову, выберите намерение <b>вреда (4)</b> и ударьте пустой рукой. Пейте кровь, чтобы получать новые силы. \
		Вы уязвимы перед святостью, огнём и звёздным светом. Не выходите в космос, избегайте священника, церкви и, особенно, святой воды.")
	return messages

/datum/antagonist/vampire/devil_vampire/give_objectives()
	add_objective(/datum/objective/blood)
	add_objective(/datum/objective/survive)

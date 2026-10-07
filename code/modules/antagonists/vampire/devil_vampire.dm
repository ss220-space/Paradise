/datum/antagonist/vampire/devil_vampire
	name = "Devil-Vampire"
	nullification = OLD_NULLIFICATION
	is_garlic_affected = TRUE
	dust_in_space = TRUE
	antag_datum_blacklist = list(/datum/antagonist/vampire)
	antag_menu_name = "Вампир дьявола"
	upgrade_tiers = list(
		/datum/action/cooldown/spell/vamp_rejuvenate = 0,
		/datum/action/cooldown/spell/aoe/glare = 0,
		/datum/action/cooldown/spell/vamp_shapeshift = 100,
		/datum/action/cooldown/spell/goon_vamp_cloak = 150,
		/datum/action/cooldown/spell/pointed/shadow_snare = 150,
		/datum/action/cooldown/spell/aoe/vamp_extinguish = 200,
		/datum/action/cooldown/spell/aoe/goon_vamp_screech = 200,
		/datum/vampire_passive/regen = 200,
		/datum/action/cooldown/spell/teleport/radius_turf/goon_vamp_blink = 250,
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/goon_vamp_jaunt = 300,
		/datum/vampire_passive/xray = 500,
		/datum/vampire_passive/full = 500,
	)

/datum/antagonist/vampire/devil_vampire/add_owner_to_gamemode()
	SSticker.mode.vampires += owner

/datum/antagonist/vampire/devil_vampire/remove_owner_from_gamemode()
	SSticker.mode.vampires -= owner

/datum/antagonist/vampire/devil_vampire/greet()
	SEND_SOUND(owner.current, sound('sound/ambience/antag/vampalert.ogg'))

	var/list/messages = list()
	messages.Add(span_danger("Вы — вампир!<br>"))
	messages.Add(span_danger("Вы продали свою душу в обмен на вечную молодость. Однако у всего есть цена. Теперь вы вынуждены пить кровь, чтобы жить."))
	messages.Add(span_danger("Вы не являетесь полноценным антагонистом и не должны убивать, за исключением случаев самообороны<br>"))
	messages.Add("Чтобы укусить кого-то, нацельтесь на голову, выберите намерение <b>вреда (4)</b> и ударьте пустой рукой. Пейте кровь, чтобы получать новые силы. \
		Вы уязвимы перед святостью, огнём и звёздным светом. Не выходите в космос, избегайте священника, церкви и, особенно, святой воды.")
	return messages

/datum/antagonist/vampire/devil_vampire/give_objectives()
	add_objective(/datum/objective/blood)
	add_objective(/datum/objective/survive)

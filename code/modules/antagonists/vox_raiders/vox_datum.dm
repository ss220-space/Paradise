/datum/antagonist/vox_raider
	name = "Vox Raider"
	roundend_category = "vox raiders"
	job_rank = ROLE_VOX_RAIDER
	special_role = SPECIAL_ROLE_VOX_RAIDER
	antag_hud_name = "hudvoxraider"
	antag_hud_type = ANTAG_HUD_VOX_RAIDER
	wiki_page_name = "vox_raiders"
	russian_wiki_name = "Вокс-Рейдер"
	antag_memory = "<b> Я Вокс-Рейдер, основа моя: беречь стаю, тащить ценности. </b>."
	var/datum/team/vox_raiders/raiders_team = null

/datum/antagonist/vox_raider/greet()
	. = ..()
	SEND_SOUND(owner.current, sound('sound/ambience/antag/vox_raiders_intro.ogg'))

	. += {"Вы Вокс Рейдер, вы и ваша стая нашли станцию Нанотрейзен имеющую ценности.
		Раздобудьте эти ценности любым доступным способом: торговлей, кражей, договорами.
		Главное помните, не допустите своей гибели или гибели членов стаи. Ценные блестяшки не стоят мертвого собрата.
		\nВы можете заказывать товары и снаряжение в Киконсоле Закиказов.
		\nСдавайте ценности в Расчичетчикик.
		\nКовчег выделил вам товары которые могут потенциально заинтересовать экипаж станции.
		Разумеется не за бесплатно, выберите что вам действительно нужно и закажите это."}

	var/raider_names = get_raider_names_text()
	if(raider_names)
		. += "Оберегай собратьев и помогай стае: <b>[raider_names]</b>. Только стая важна!"
		antag_memory += "<b>Ваша стая:</b>: [raider_names]<br>"

	. += "Нужно больше ценностей!"

/datum/antagonist/vox_raider/create_team(datum/team/vox_raiders/team)
	if(!istype(team))
		error("Wrong team type passed to [type].")
		return

	raiders_team = team
	return raiders_team

/datum/antagonist/vox_raider/get_team()
	return raiders_team

/datum/antagonist/vox_raider/proc/get_raider_names_text()
	PRIVATE_PROC(TRUE)
	var/datum/team/vox_raiders/team = get_team()
	if(!istype(team))
		return ""

	return team.get_raider_names_text(owner)

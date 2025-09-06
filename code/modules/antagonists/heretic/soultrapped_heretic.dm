///a heretic that got soultrapped by cultists. does nothing, other than signify they suck
/datum/antagonist/soultrapped_heretic
	name = "Запертая Душа Еретика"
	roundend_category = "Heretics"
	special_role = SPECIAL_ROLE_SOULTRAPPED_HERETIC
	job_rank = ROLE_HERETIC
	antag_hud_name = "heretic"


// always failure obj
/datum/objective/heretic_trapped
	name = "неудачно захваченная душа"
	explanation_text = "Помогите культу. Уничтожьте культ. Помогите экипажу. Перебейте экипаж. Помогите своему владельцу. Убейте своего владельца. Убейте всех. Грохочите своими цепями. Разбейте свои оковы."


/datum/antagonist/soultrapped_heretic/on_gain()
	..()
	if(owner)
		to_chat(owner, span_ghostalert("Вы — запертая душа еретика, которым вы когда-то были. Вы можете попытаться убедить своих владельцев освободить вас, \
									предоставив вам некоторую степень свободы, а им — доступ к некоторым вашим силам. Вы были порабощены культом, но не \
									являетесь его членом и сохранили то, что осталось от вашей свободы воли. Помимо этого, мало что можно сделать, \
									кроме как комментировать. Постарайтесь не попасть в ловушку со шкафом."))
		log_game("[key_name_log(owner)]был принесен в жертву Нар'си как еретик и запечатан внутри меча.")

	var/datum/objective/epic_fail = new /datum/objective/heretic_trapped()
	epic_fail.completed = FALSE
	objectives += epic_fail

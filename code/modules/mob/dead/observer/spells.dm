GLOBAL_LIST_INIT(boo_phrases, list(
	"По вашей спине пробегает холодок.",
	"Вам кажется, что вы видите что-то боковым зрением.",
	"Что это было?",
	"Волосы на вашей шее встают дыбом.",
	"Вас охватывает глубокая печаль.",
	"Что-то здесь не так...",
	"Вы чувствуете присутствие в комнате.",
	"Такое ощущение, что кто-то стоит у вас за спиной.",
	"Внезапно вам становится очень одиноко.",
	"Вы замечаете движение в темном углу, но там ничего нет.",
	"Тени вокруг будто стали гуще...",
	"Вам кажется, что за вами наблюдают.",
))

/datum/action/cooldown/spell/pointed/Boo
	name = "Буу!"
	desc = "К черту живых."
	deactive_msg = span_shadowling_alt("Ваше присутствие останется незамеченным. Пока что.")
	active_msg = span_shadowling_alt("Вы готовы протянуть руку сквозь завесу.")
	check_flags = NONE
	spell_requirements = NONE
	button_icon_state = "boo"
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 2 MINUTES
	allow_observer_click = TRUE

/datum/action/cooldown/spell/pointed/Boo/cast(atom/cast_on)
	. = ..()
	ASSERT(istype(cast_on))
	cooldown_time = initial(cooldown_time)
	if(cast_on.get_spooked())
		var/area/spook_zone = get_area(cast_on)
		if(spook_zone.is_haunted == TRUE)
			to_chat(usr, span_shadowling("Завеса слаба в [spook_zone], потребовалось меньше усилий, чтобы воздействовать на [cast_on]."))
			cooldown_time = initial(cooldown_time) / 2
		return

	cooldown_time = initial(cooldown_time) * 0.1

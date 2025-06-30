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

/obj/effect/proc_holder/spell/boo
	name = "Буу!"
	desc = "К черту живых."
	selection_deactivated_message	= span_shadowling("Ваше присутствие останется незамеченным. Пока что.")
	selection_activated_message		= span_shadowling("Вы готовы протянуть руку сквозь завесу. <b>ЛКМ по цели для воздействия!</b>")

	ghost = TRUE

	action_icon_state = "boo"
	school = "transmutation"
	base_cooldown = 2 MINUTES
	starts_charged = FALSE
	clothes_req = FALSE
	human_req = FALSE
	stat_allowed = UNCONSCIOUS
	invocation = ""
	invocation_type = "none"
	need_active_overlay = TRUE
	// no need to spam admins regarding boo casts
	create_attack_logs = FALSE



/obj/effect/proc_holder/spell/boo/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /atom
	T.try_auto_target = FALSE
	return T


/obj/effect/proc_holder/spell/boo/cast(list/targets, mob/user = usr)
	var/atom/target = targets[1]
	ASSERT(istype(target))

	if(target.get_spooked())
		var/area/spook_zone = get_area(target)
		if (spook_zone.is_haunted == TRUE)
			to_chat(usr, span_shadowling("Завеса слаба в [spook_zone], потребовалось меньше усилий, чтобы воздействовать на [target]."))
			cooldown_handler.start_recharge(cooldown_handler.recharge_duration / 2)
		return

	cooldown_handler.start_recharge(cooldown_handler.recharge_duration * 0.1)

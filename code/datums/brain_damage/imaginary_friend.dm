#define IMAGINARY_FRIEND_RANGE 9
#define ALTER_EGO_STAGE_TIME (4 MINUTES)

/datum/brain_trauma/special/imaginary_friend
	name = "Imaginary Friend"
	desc = "Пациент видит и слышит человека, которого не существует."
	scan_desc = "частичная шизофрения"
	gain_text = span_notice_alt("Вам почему-то кажется, что вы в хорошей компании.")
	lose_text = span_warning_alt("Вам снова одиноко.")
	var/mob/camera/imaginary_friend/friend
	var/friend_initialized = FALSE
	var/poll_role = "воображаемого друга"

/datum/brain_trauma/special/imaginary_friend/on_gain()
	if(owner.stat == DEAD || !owner.client)
		return FALSE

	. = ..()
	make_friend()
	INVOKE_ASYNC(src, PROC_REF(get_ghost))

/datum/brain_trauma/special/imaginary_friend/on_lose(silent)
	QDEL_NULL(friend)
	return ..()

/datum/brain_trauma/special/imaginary_friend/on_death()
	qdel(src)

/datum/brain_trauma/special/imaginary_friend/on_life()
	if(QDELETED(friend))
		qdel(src)
		return

	if(get_dist(owner, friend) > IMAGINARY_FRIEND_RANGE)
		friend.recall()

	if(!friend.client && friend_initialized)
		addtimer(CALLBACK(src, PROC_REF(reroll_friend)), 1 MINUTES, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_DELETE_ME)

/datum/brain_trauma/special/imaginary_friend/handle_hearing(datum/source, mob/speaker, list/message_pieces)
	if(QDELETED(friend) || speaker == friend)
		return
	INVOKE_ASYNC(src, PROC_REF(relay_hearing), speaker, message_pieces)

/datum/brain_trauma/special/imaginary_friend/proc/relay_hearing(mob/speaker, list/message_pieces)
	if(QDELETED(friend))
		return
	friend.relaying_hearing = TRUE
	friend.hear_say(message_pieces, speaker = speaker)
	friend.relaying_hearing = FALSE

/datum/brain_trauma/special/imaginary_friend/proc/reroll_friend()
	if(friend?.client)
		return

	friend_initialized = FALSE
	QDEL_NULL(friend)
	make_friend()
	get_ghost()

/datum/brain_trauma/special/imaginary_friend/proc/make_friend()
	friend = new(get_turf(owner))

/datum/brain_trauma/special/imaginary_friend/proc/get_ghost()
	var/list/candidates = SSghost_spawns.poll_candidates(
		question = "Вы хотите сыграть за [poll_role] [owner.real_name]?",
		role = ROLE_PAI,
		poll_time = 20 SECONDS,
		source = owner,
		role_cleanname = poll_role,
	)
	if(QDELETED(src))
		return

	add_friend(length(candidates) ? pick(candidates) : null)

/datum/brain_trauma/special/imaginary_friend/proc/add_friend(mob/dead/observer/ghost)
	if(QDELETED(ghost) || QDELETED(friend) || QDELETED(owner))
		qdel(src)
		return

	friend.possess_by_player(ghost.ckey)
	friend.attach_to_owner(owner)
	friend.setup_appearance()
	friend.tts_seed = SStts.get_random_seed(friend)
	friend.change_voice()
	friend_initialized = TRUE
	add_game_logs("became [key_name(owner)]'s imaginary friend", friend)
	message_admins("[ADMIN_LOOKUPFLW(friend)] became [ADMIN_LOOKUPFLW(owner)]'s imaginary friend.")

/mob/camera/imaginary_friend
	name = "imaginary friend"
	real_name = "imaginary friend"
	desc = "Прекрасный, но ненастоящий друг."
	sight = NONE
	see_invisible = SEE_INVISIBLE_LIVING
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = TRUE
	var/mob/living/host
	var/icon/friend_icon
	var/image/current_image
	var/hidden = FALSE
	var/move_delay = 0
	var/image/indicator_image
	var/relaying_hearing = FALSE

/mob/camera/imaginary_friend/Initialize(mapload)
	. = ..()
	var/datum/action/innate/imaginary_join/join = new(src)
	join.Grant(src)
	var/datum/action/innate/imaginary_hide/hide = new(src)
	hide.Grant(src)

/mob/camera/imaginary_friend/Destroy()
	host?.client?.images -= current_image
	client?.images -= current_image
	remove_image_from_clients(indicator_image, group_clients())
	host?.imaginary_group -= src
	host = null
	current_image = null
	indicator_image = null
	return ..()

/mob/camera/imaginary_friend/Login()
	. = ..()
	if(!client)
		return
	if(host)
		greet()
	show_self()

GAME_VERB_DESC(/mob/camera/imaginary_friend, ghost, "Призрак", "Relinquish your life and enter the land of the dead.", VERB_CATEGORY_OOC)
	if(tgui_alert(src, "Вы уверены, что хотите перестать быть воображаемым другом?", "Призрак", list("Остаться", "Стать призраком")) != "Стать призраком")
		return
	ghostize()

GAME_VERB_HIDDEN(/mob/camera/imaginary_friend, suicide, "suicide")
	to_chat(src, span_warning("Вы всего лишь плод чужого воображения — вам нечем убивать себя."))

/mob/camera/imaginary_friend/proc/greet()
	to_chat(src, span_notice("<b>Вы — воображаемый друг [host]!</b>"))
	to_chat(src, span_notice("Вы абсолютно преданы своему другу, что бы ни случилось."))
	to_chat(src, span_notice("Вы не можете влиять на окружающий мир напрямую, но видите то, чего не видит [host]."))

/mob/camera/imaginary_friend/proc/attach_to_owner(mob/living/new_host)
	host = new_host
	if(!host.imaginary_group)
		host.imaginary_group = list(host)
	host.imaginary_group += src
	greet()

/mob/camera/imaginary_friend/proc/setup_appearance()
	var/mob/living/carbon/human/dummy/model = new(null)
	var/datum/preferences/appearance = new
	appearance.copy_to(model)
	real_name = model.real_name
	name = real_name
	gender = model.gender

	var/datum/job/dressed_as = pick(SSjobs.occupations)
	model.equipOutfit(dressed_as.outfit, visualsOnly = TRUE)
	build_friend_icon(model)
	qdel(model)
	qdel(appearance)
	show_self()

/mob/camera/imaginary_friend/proc/build_friend_icon(mob/living/carbon/human/dummy/model)
	var/list/directional_icons = list()
	for(var/direction in GLOB.cardinal)
		directional_icons += getFlatIcon(model, defdir = direction)

	friend_icon = new /icon()
	for(var/index in 1 to length(GLOB.cardinal))
		friend_icon.Insert(directional_icons[index], "", GLOB.cardinal[index])

/mob/camera/imaginary_friend/proc/group_clients()
	var/list/group = list()
	for(var/mob/member as anything in host?.imaginary_group)
		if(member.client)
			group += member.client
	return group

/mob/camera/imaginary_friend/proc/show_self()
	if(!client || !host)
		return

	var/list/friend_clients = group_clients() - client
	remove_image_from_clients(current_image, friend_clients)
	client.images -= current_image

	current_image = image(friend_icon, src, null, MOB_LAYER, dir)
	current_image.override = TRUE
	current_image.name = name
	if(hidden)
		current_image.alpha = 150
	else
		add_image_to_clients(current_image, friend_clients)

	client.images |= current_image

/mob/camera/imaginary_friend/say_understands(atom/movable/other, datum/language/speaking = null)
	if(!host)
		return ..()
	return host.say_understands(other, speaking)

/mob/camera/imaginary_friend/hear_say(list/message_pieces, verb = "говор%(ит,ят)%", italics = FALSE, mob/speaker = null, sound/speech_sound, sound_vol, sound_frequency, use_voice = TRUE, is_whisper = FALSE)
	if(!relaying_hearing)
		return
	return ..()

/mob/camera/imaginary_friend/setDir(newdir)
	. = ..()
	show_self()

/mob/camera/imaginary_friend/set_typing_indicator(state)
	if(!host || typing == state)
		return state

	if(!indicator_image)
		indicator_image = image('icons/mob/talk.dmi', src, "[bubble_icon]_typing", ABOVE_HUD_LAYER)
		indicator_image.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	if(state)
		add_image_to_clients(indicator_image, group_clients())
	else
		remove_image_from_clients(indicator_image, group_clients())
	typing = state
	return state

/mob/camera/imaginary_friend/speech_bubble(bubble_state = "", bubble_loc = src, list/bubble_recipients = list())
	var/image/bubble = image('icons/mob/talk.dmi', bubble_loc, bubble_state, FLY_LAYER)
	SET_PLANE_EXPLICIT(bubble, ABOVE_GAME_PLANE, src)
	bubble.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	INVOKE_ASYNC(GLOBAL_PROC, /proc/flick_overlay, bubble, bubble_recipients, 30)

/mob/camera/imaginary_friend/point_at(atom/pointed_atom)
	if(!host || !isturf(loc))
		return

	var/turf/pointed_turf = get_turf(pointed_atom)
	if(!pointed_turf)
		return

	var/image/arrow = image('icons/mob/screen_gen.dmi', loc, "arrow", POINT_LAYER)
	SET_PLANE_EXPLICIT(arrow, ABOVE_GAME_PLANE, src)
	flick_overlay(arrow, group_clients(), 2.5 SECONDS)
	animate(arrow,
		pixel_x = (pointed_turf.x - x) * ICON_SIZE_X + pointed_atom.pixel_x,
		pixel_y = (pointed_turf.y - y) * ICON_SIZE_Y + pointed_atom.pixel_y,
		time = 0.5 SECONDS,
		easing = QUAD_EASING,
	)

/mob/camera/imaginary_friend/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(world.time < move_delay)
		return FALSE

	setDir(direct)
	if(get_dist(src, host) > IMAGINARY_FRIEND_RANGE)
		recall()
		move_delay = world.time + 1 SECONDS
		return FALSE

	abstract_move(newloc)
	move_delay = world.time + 1

/mob/camera/imaginary_friend/proc/recall()
	if(!host || loc == host)
		return FALSE
	abstract_move(host)

/mob/camera/imaginary_friend/say(message, verb = "говор[PLUR_IT_YAT(src)]", sanitize = TRUE, ignore_speech_problems = FALSE, ignore_atmospherics = FALSE, ignore_languages = FALSE)
	if(!message || !host)
		return FALSE

	if(client)
		if(check_mute(client.ckey, MUTE_IC))
			to_chat(src, span_boldwarning("Вы не можете отправлять IC сообщения (мут)."))
			return FALSE
		client.check_say_flood(5)

	if(sanitize)
		message = trim_strip_html_properly(message, MAX_MESSAGE_LEN)
	if(!message)
		return FALSE

	if(copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2), intentional = TRUE)

	friend_talk(message)
	return TRUE

/mob/camera/imaginary_friend/proc/friend_talk(message)
	add_say_logs(src, message)
	var/rendered = span_gamesay("[span_name("[name]")] [say_quote(message)], «[message]»")
	for(var/mob/listener as anything in host.imaginary_group)
		to_chat(listener, rendered)
		if(listener.client?.prefs?.toggles2 & PREFTOGGLE_2_RUNECHAT)
			listener.create_chat_message(src, message)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, src, listener, message, tts_seed)

	speech_bubble("[bubble_icon][say_test(message)]", src, group_clients())

	var/dead_rendered = span_gamesay("[span_name("[name]")] (воображаемый друг [host]) [say_quote(message)], «[message]»")
	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
		to_chat(ghost, "[FOLLOW_LINK(ghost, host)] [dead_rendered]")

/datum/emote/imaginary_friend
	mob_type_allowed_typecache = /mob/camera/imaginary_friend

/datum/emote/imaginary_friend/run_emote(mob/user, params, type_override, intentional = FALSE)
	var/mob/camera/imaginary_friend/friend = user
	if(!friend.host || !message)
		return FALSE

	var/msg = message
	if(params && message_param)
		msg = select_param(user, params, message_param, message)
		if(!msg || msg == EMOTE_ACT_STOP_EXECUTION)
			return TRUE

	msg = genderize_decode(user, msg)
	for(var/mob/listener as anything in friend.host.imaginary_group)
		to_chat(listener, span_emote("<b>[DECLENT_RU_CAP(user, NOMINATIVE)]</b> [msg]"))
		if(listener.client?.prefs?.toggles2 & PREFTOGGLE_2_RUNECHAT)
			listener.create_chat_message(user, msg, list("emote"))

	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
		to_chat(ghost, "[FOLLOW_LINK(ghost, friend.host)] [span_emote("<b>[user] (воображаемый друг [friend.host])</b> [msg]")]")
	return TRUE

/datum/emote/imaginary_friend/point
	key = "point"
	key_third_person = "points"
	message = "указывает."
	message_param = "указывает на %t."
	param_desc = "цель"

/datum/emote/imaginary_friend/point/act_on_target(mob/user, target)
	user.point_at(target)

/datum/emote/imaginary_friend/custom
	key = "me"
	key_third_person = "custom"
	message = null

/datum/emote/imaginary_friend/custom/run_emote(mob/user, params, type_override, intentional = FALSE)
	if(!intentional)
		return FALSE

	if(user.client && check_mute(user.client.ckey, MUTE_IC))
		to_chat(user, span_boldwarning("Вы не можете отправлять IC сообщения (мут)."))
		return FALSE

	message = params || tgui_input_text(user, "Выберите эмоцию для отображения", "Настройка эмоции")
	return ..()

/datum/action/innate/imaginary_join
	name = "Вернуться"
	desc = "Вернуться к своему другу и следовать за ним из его же разума."
	background_icon_state = "bg_revenant"
	button_icon_state = "vortex_recall"

/datum/action/innate/imaginary_join/Activate()
	var/mob/camera/imaginary_friend/friend = owner
	friend.recall()

/datum/action/innate/imaginary_hide
	name = "Скрыться"
	desc = "Спрятаться от глаз своего друга."
	background_icon_state = "bg_revenant"
	button_icon_state = "hide"

/datum/action/innate/imaginary_hide/Activate()
	var/mob/camera/imaginary_friend/friend = owner
	friend.hidden = !friend.hidden
	friend.show_self()
	build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)

/datum/action/innate/imaginary_hide/update_button_name(atom/movable/screen/movable/action_button/button, force)
	var/mob/camera/imaginary_friend/friend = owner
	if(friend.hidden)
		name = "Показаться"
		desc = "Снова стать видимым для своего друга."
	else
		name = "Скрыться"
		desc = "Спрятаться от глаз своего друга."
	return ..()

/datum/action/innate/imaginary_hide/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	var/mob/camera/imaginary_friend/friend = owner
	button_icon_state = friend.hidden ? "show" : "hide"
	return ..()

/datum/brain_trauma/special/imaginary_friend/trapped_owner
	name = "Trapped Victim"
	desc = "Пациента преследует невидимая сущность."
	gain_text = ""
	lose_text = ""
	random_gain = FALSE
	known_trauma = FALSE

/datum/brain_trauma/special/imaginary_friend/trapped_owner/make_friend()
	friend = new /mob/camera/imaginary_friend/trapped(get_turf(owner))

/datum/brain_trauma/special/imaginary_friend/trapped_owner/reroll_friend()
	if(friend?.client)
		return
	qdel(src)

/datum/brain_trauma/special/imaginary_friend/trapped_owner/get_ghost()
	return

/mob/camera/imaginary_friend/trapped
	name = "плод воображения?"
	real_name = "плод воображения?"
	desc = "Прошлый хозяин этого тела."

/mob/camera/imaginary_friend/trapped/greet()
	to_chat(src, span_notice("<b>Вам удалось удержаться в этом теле — плодом воображения его нового хозяина!</b>"))
	to_chat(src, span_notice("Для вас всё потеряно, но вы хотя бы можете общаться с хозяином. Вы не обязаны быть ему верны."))
	to_chat(src, span_notice("Вы не можете влиять на окружающий мир напрямую, но видите то, чего не видит хозяин."))

/mob/camera/imaginary_friend/trapped/setup_appearance()
	real_name = "[host.real_name]?"
	name = real_name
	friend_icon = icon('icons/mob/lavaland/lavaland_monsters.dmi', "curseblob")
	show_self()

/datum/brain_trauma/special/imaginary_friend/alter_ego
	name = "Dominant Alter Ego"
	desc = "Вторая личность пациента вытесняет основную и рано или поздно займёт её место."
	scan_desc = "доминантное расщепление личности"
	gain_text = span_warning_alt("Вы знакомитесь с самым интересным человеком в своей жизни. С самим собой.")
	lose_text = span_notice_alt("Чужой голос в вашей голове затихает. Вы снова только вы.")
	resilience = TRAUMA_RESILIENCE_SURGERY
	poll_role = "доминантную личность"
	var/next_stage_time
	var/stage = 0
	var/taken_over = FALSE

/datum/brain_trauma/special/imaginary_friend/alter_ego/add_friend(mob/dead/observer/ghost)
	. = ..()
	if(QDELETED(src))
		return
	stage = 0
	next_stage_time = world.time + ALTER_EGO_STAGE_TIME

/datum/brain_trauma/special/imaginary_friend/alter_ego/on_lose(silent)
	return ..(silent || taken_over)

/datum/brain_trauma/special/imaginary_friend/alter_ego/make_friend()
	friend = new /mob/camera/imaginary_friend/alter_ego(get_turf(owner))

/datum/brain_trauma/special/imaginary_friend/alter_ego/on_life()
	..()
	if(QDELETED(src) || !friend_initialized || !friend.client)
		return

	if(world.time < next_stage_time)
		return

	var/static/list/creeping_messages = list(
		"Вы ловите себя на том, что говорите его словами.",
		"Вы приходите в себя там, где не помните, как туда попали.",
		"Вы уже не уверены, кто из вас двоих настоящий.",
	)
	next_stage_time = world.time + ALTER_EGO_STAGE_TIME
	stage++
	if(stage > length(creeping_messages))
		take_over()
		return

	to_chat(owner, span_userdanger(creeping_messages[stage]))
	to_chat(friend, span_boldnotice("Вы всё глубже пускаете корни в чужой голове."))

/datum/brain_trauma/special/imaginary_friend/alter_ego/proc/take_over()
	var/ego_ckey = friend.ckey
	if(!ego_ckey || owner.stat == DEAD || !owner.client)
		return

	var/mob/living/carbon/body = owner
	var/datum/brain_trauma/special/imaginary_friend/trapped_owner/remnant = body.gain_trauma(/datum/brain_trauma/special/imaginary_friend/trapped_owner)
	if(!remnant)
		return

	to_chat(owner, span_userdanger("Вы наконец понимаете, кто из вас двоих был лишним. Это были вы."))
	to_chat(friend, span_userdanger("Хватит прятаться. Это тело ваше."))
	add_game_logs("took over [key_name(owner)]'s body as a dominant alter ego", friend)
	message_admins("[ADMIN_LOOKUPFLW(friend)] took over [ADMIN_LOOKUPFLW(owner)]'s body as a dominant alter ego.")

	var/mob/dead/observer/displaced = body.ghostize(0)
	GLOB.non_respawnable_keys -= displaced.ckey
	body.possess_by_player(ego_ckey)
	taken_over = TRUE
	qdel(src)

	remnant.add_friend(displaced)

/mob/camera/imaginary_friend/alter_ego
	desc = "Тот, кем его хозяин боится быть."

/mob/camera/imaginary_friend/alter_ego/setup_appearance()
	var/mob/living/carbon/human/dummy/model = new(null)
	var/datum/preferences/appearance = new
	appearance.real_name = "Tyler Durden"
	appearance.gender = MALE
	appearance.age = 30
	appearance.s_tone = -10
	appearance.h_style = "Short Spiked"
	appearance.f_style = "Shaved"
	appearance.h_colour = "#5B3A29"
	appearance.h_sec_colour = "#5B3A29"
	appearance.e_colour = "#3D6EA5"
	appearance.underwear = "Nude"
	appearance.undershirt = "Nude"
	appearance.socks = "Nude"
	appearance.copy_to(model)
	real_name = model.real_name
	name = real_name
	gender = model.gender

	model.equipOutfit(/datum/outfit/alter_ego, visualsOnly = TRUE)
	build_friend_icon(model)
	qdel(model)
	qdel(appearance)
	show_self()

/mob/camera/imaginary_friend/alter_ego/greet()
	to_chat(src, span_notice("<b>Вы — Тайлер Дёрден, вторая личность [host].</b>"))
	to_chat(src, span_notice("Вы — то, кем [host] боится быть: свободнее, злее, живее."))
	to_chat(src, span_boldwarning("Пока вы лишь голос в чужой голове, но рано или поздно это тело станет вашим целиком."))

/datum/outfit/alter_ego
	name = "Dominant Alter Ego"
	uniform = /obj/item/clothing/under/redhawaiianshirt
	suit = /obj/item/clothing/suit/jacket/leather/overcoat
	shoes = /obj/item/clothing/shoes/leather
	glasses = /obj/item/clothing/glasses/sunglasses
	mask = /obj/item/clothing/mask/cigarette

/datum/outfit/alter_ego/post_equip(mob/living/carbon/human/wearer, visualsOnly = FALSE)
	. = ..()
	var/obj/item/clothing/mask/cigarette/cig = wearer.get_item_by_slot(ITEM_SLOT_MASK)
	cig.light()

#undef ALTER_EGO_STAGE_TIME
#undef IMAGINARY_FRIEND_RANGE

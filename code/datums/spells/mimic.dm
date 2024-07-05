/obj/effect/proc_holder/spell/mimic
	name = "Mimic"
	desc =  "Изучите новую форму для мимикрии или станьте одной из известных вам форм."
	clothes_req = FALSE
	human_req = FALSE
	base_cooldown = 3 SECONDS
	action_icon_state = "genetic_morph"
	selection_activated_message = span_sinister("Нажмите на цель, чтобы запомнить её форму. Нажмите на себя, чтобы изменить форму.")
	create_attack_logs = FALSE
	action_icon_state = "morph_mimic"
	need_active_overlay = TRUE
	/// Which form is currently selected
	var/datum/mimic_form/selected_form
	/// Which forms the user can become
	var/list/available_forms = list()
	/// How many forms the user can remember
	var/max_forms = 5
	/// Which index will be overriden next when the user wants to remember another form
	var/next_override_index = 1
	/// If a message is shown when somebody examines the user from close range
	var/perfect_disguise = FALSE

	var/static/list/black_listed_form_types = list(
		/atom/movable/screen,
		/obj/singularity,
		/obj/effect,
		/mob/living/simple_animal/hostile/megafauna,
		/obj/machinery/dna_vault,
		/obj/machinery/power/bluespace_tap,
		/obj/structure/sign/barsign,
		/obj/machinery/atmospherics/unary/cryo_cell,
		/obj/machinery/gravity_generator
	)


/obj/effect/proc_holder/spell/mimic/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.include_user = TRUE // To change forms
	T.allowed_type = /atom/movable
	T.try_auto_target = FALSE
	T.click_radius = -1
	return T


/obj/effect/proc_holder/spell/mimic/valid_target(atom/target, user)
	if(is_type_in_list(target, black_listed_form_types))
		return FALSE
	if(istype(target, /atom/movable))
		var/atom/movable/AM = target
		if(AM.bound_height > world.icon_size || AM.bound_width > world.icon_size)
			return FALSE // No multitile structures
	if(user != target && ismorph(target))
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/mimic/cast(list/targets, mob/user)
	var/atom/movable/A = targets[1]
	if(A == user)
		INVOKE_ASYNC(src, PROC_REF(pick_form), user)
		return

	INVOKE_ASYNC(src, PROC_REF(remember_form), A, user)


/obj/effect/proc_holder/spell/mimic/proc/remember_form(atom/movable/A, mob/user)
	if(A.name in available_forms)
		to_chat(user, span_warning("[A] уже является доступной формой."))
		revert_cast(user)
		return

	if(length(available_forms) >= max_forms)
		to_chat(user, span_warning("Вы начинаете забывать форму [available_forms[next_override_index]] чтобы запомнить новую."))

	to_chat(user, span_sinister("Вы начинаете запоминать форму [A]."))
	if(!do_after(user, 2 SECONDS, user, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
		to_chat(user, span_warning("You lose focus."))
		return

	// Forget the old form if needed
	if(length(available_forms) >= max_forms)
		qdel(available_forms[available_forms[next_override_index]]) // Delete the value using the key
		available_forms[next_override_index++] = A.name
		// Reset if needed
		if(next_override_index > max_forms)
			next_override_index = 1

	available_forms[A.name] = new /datum/mimic_form(A, user)
	to_chat(user, span_sinister("Вы запомнили форму [A]."))


/obj/effect/proc_holder/spell/mimic/proc/pick_form(mob/user)
	if(!length(available_forms) && !selected_form)
		to_chat(user, span_warning("Доступных форм нет. Изучите больше форм, применив это заклинание к другим существам."))
		revert_cast(user)
		return

	var/list/forms = list()
	if(selected_form)
		forms += "Original Form"

	forms += available_forms.Copy()
	var/what = tgui_input_list(user, "Какую форму вы хотите принять?", "Мимик", forms)
	if(!what)
		to_chat(user, span_notice("Вы отказываетесь от изменения формы."))
		revert_cast(user)
		return

	if(what == "Original Form")
		restore_form(user)
		return
	to_chat(user, span_sinister("Вы начинаете превращаться в [what]."))
	if(!do_after(user, 2 SECONDS, user, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
		to_chat(user, span_warning("Вы теряете концентрацию."))
		return
	take_form(available_forms[what], user)


/obj/effect/proc_holder/spell/mimic/proc/take_form(datum/mimic_form/form, mob/user)
	var/old_name = "[user]"
	if(ishuman(user))
		// Not fully finished yet
		var/mob/living/carbon/human/H = user
		H.name_override = form.name
	else
		user.appearance = form.appearance
		user.transform = initial(user.transform)
		user.pixel_y = initial(user.pixel_y)
		user.pixel_x = initial(user.pixel_x)
		user.layer = MOB_LAYER // Avoids weirdness when mimicing something below the vent layer

	playsound(user, "bonebreak", 75, TRUE)
	show_change_form_message(user, old_name, "[user]")
	user.create_log(MISC_LOG, "Mimicked into [user]")

	if(!selected_form)
		RegisterSignal(user, COMSIG_PARENT_EXAMINE, PROC_REF(examine_override))
		RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(on_death))

	selected_form = form


/obj/effect/proc_holder/spell/mimic/proc/show_change_form_message(mob/user, old_name, new_name)
	user.visible_message(span_warning("[old_name] искажается и медленно превращается в [new_name]!"), \
						span_sinister("Вы приняли форму [new_name]."), \
						span_italics("Вы слышите громкий треск!"))


/obj/effect/proc_holder/spell/mimic/proc/restore_form(mob/user, show_message = TRUE)
	selected_form = null
	var/old_name = "[user]"

	user.cut_overlays()
	user.icon = initial(user.icon)
	user.icon_state = initial(user.icon_state)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.name_override = null
		H.regenerate_icons()
	else
		user.name = initial(user.name)
		user.desc = initial(user.desc)
		user.color = initial(user.color)

	playsound(user, "bonebreak", 150, TRUE)
	if(show_message)
		show_restore_form_message(user, old_name, "[user]")

	UnregisterSignal(user, list(COMSIG_PARENT_EXAMINE, COMSIG_MOB_DEATH))


/obj/effect/proc_holder/spell/mimic/proc/show_restore_form_message(mob/user, old_name, new_name)
	user.visible_message(span_warning("[old_name] трясётся, корчится и превращается в [new_name]!"), \
						span_sinister("Вы возвращаетесь к своей обычной форме."), \
						span_italics("Вы слышите громкий треск!"))


/obj/effect/proc_holder/spell/mimic/proc/examine_override(datum/source, mob/user, list/examine_list)
	examine_list.Cut()
	examine_list += selected_form.examine_text
	if(!perfect_disguise && get_dist(user, source) <= 3)
		examine_list += span_warning("Что-то не так...")


/obj/effect/proc_holder/spell/mimic/proc/on_death(mob/user, gibbed)
	if(!gibbed)
		restore_form(user, FALSE)
		show_death_message(user)


/obj/effect/proc_holder/spell/mimic/proc/show_death_message(mob/user)
	user.visible_message(span_warning("[user] трясётся и корчится, в то время как [user.p_they()] умирает, принимая истинную форму!"), \
						span_deadsay("Ваша маскировка спадает по мере угасания ваших жизненных сил."), \
						span_italics("Вы слышите громкий треск, за которым следует глухой удар!"))


/datum/mimic_form
	/// What the visible species of the form is (Only for human forms)?
	var/examine_species = "Unknown"
	/// What the visible gender of the form is (Only for human forms)?
	var/examine_gender
	/// What is the examine text paired with this form?
	var/examine_text
	/// What is the examine time paired with this form?
	var/examine_time
	/// How does the form look like?
	var/appearance
	/// What the name of the form is?
	var/name


/datum/mimic_form/New(atom/movable/form, mob/user)
	examine_gender = form.get_visible_gender()
	examine_text = form.examine(user)
	examine_time = form.get_examine_time()
	appearance = form.appearance
	name = form.name
	if(isliving(form))
		var/mob/living/form_living = form
		examine_species = form_living.get_visible_species()


/obj/effect/proc_holder/spell/mimic/morph
	action_background_icon_state = "bg_morph"


/obj/effect/proc_holder/spell/mimic/morph/create_new_handler()
	var/datum/spell_handler/morph/H = new
	return H


/obj/effect/proc_holder/spell/mimic/morph/valid_target(atom/target, user)
	if(target != user && ismorph(target))
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/mimic/morph/take_form(datum/mimic_form/form, mob/living/simple_animal/hostile/morph/user)
	..()
	user.assume()

/obj/effect/proc_holder/spell/mimic/morph/restore_form(mob/living/simple_animal/hostile/morph/user, show_message = TRUE)
	..()
	user.restore()


/obj/effect/proc_holder/spell/mimic/morph/show_change_form_message(mob/user, old_name, new_name)
	user.visible_message(span_warning("[old_name] внезапно искажается и меняет форму, становясь копией [new_name]!"), \
						span_notice("Вы искажаете своё тело и принимаете форму [new_name]."))


/obj/effect/proc_holder/spell/mimic/morph/show_restore_form_message(mob/user, old_name, new_name)
	user.visible_message(span_warning("[old_name] внезапно сворачивается сам в себя, превращаясь в груду зеленой плоти!"), \
						span_notice("Ты принимаешь свою обычную форму."))


/obj/effect/proc_holder/spell/mimic/morph/show_death_message(mob/user)
	user.visible_message(span_warning("[user] сворачивается и превращается в груду зеленой плоти!"), \
						span_userdanger("Твоя кожа лопается! Твоя плоть распадается на части! Никакая маскировка не спасет тебя от смер--"))


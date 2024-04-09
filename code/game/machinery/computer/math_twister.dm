/obj/machinery/computer/retro/math_twister    ////////object_sampo.dmm
	icon = 'icons/obj/machines/computer5.dmi'
	icon_state = "computer-retro"
	icon_screen = "command_generic"
	icon_keyboard = "id_key"
	name = "security management console"
	flags = NODECONSTRUCT
	var/onceused = FALSE
	var/blast_id
	var/list/task
	var/timer


/obj/machinery/computer/retro/math_twister/attack_hand(mob/living/user)
	if(..())
		return

	if(isobserver(user) && !is_admin(user))
		return

	if(!user.has_vision())
		to_chat(user, "<span class='danger'>Вы не можете видеть, что происходит на экране!</span>")
		return

	if(SStgui.update_uis(src))
		to_chat(user,"<span class='notice'>Кто-то уже использует консоль.</span>")
		return
	else
		ui_interact(user)

/obj/machinery/computer/retro/math_twister/ui_interact(mob/living/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		generate_task()
		ui = new(user, src, ui_key, "Math", name, 360, 330)
		ui.open()
		ui.autoupdate = FALSE

/obj/machinery/computer/retro/math_twister/proc/generate_task()
	if(timer)
		deltimer(timer)
		timer = null
	timer = addtimer(CALLBACK(src, PROC_REF(generate_task)), 30 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)
	task = list()
	for(var/i in 0 to 9)
		var/op1  = rand(1, 9)
		var/op2  = rand(1, 9)
		var/answer
		var/sign
		if(prob(50))
			answer = abs((op1 + op2) % 10)
			sign = "+"
		else
			answer = abs((op1 - op2) % 10)
			sign = "-"
		task["[i]"] = list("answer" = answer, "op1" = op1, "op2" = op2, "sign" = sign, "choosen" = 0)
	SStgui.update_uis(src)

/obj/machinery/computer/retro/math_twister/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	add_fingerprint(ui.user)

	switch(action)
		if("checkAnswer")
			var/task_id = params["taskID"]
			var/answer_id = text2num(params["answerID"])
			onceused = TRUE
			task[task_id]["choosen"] = answer_id
			SStgui.update_uis(src)

		if("open")
			var/done = 0
			for(var/check in task)
				if(task[check]["answer"] == task[check]["choosen"])
					done += 1
			if(done == 10)
				win(ui.user)
			else
				wrong_answer(ui.user, 10-done)


/obj/machinery/computer/retro/math_twister/ui_data(mob/living/user)
	var/list/data = list("tasks" = task)
	return data

/obj/machinery/computer/retro/math_twister/proc/wrong_answer(mob/living/user, var/mistake)
	if(!onceused)
		user.visible_message("<span class='notice'>[user] бездумно жмёт по клавиатуре, но ничего не происходит!}</span>", \
		"<span class='notice'>Вы бездумно нажали по клавиатуре, но ничего не происходит!</span>", \
		"<span class='notice'>Кажется кто-то бездумно нажал по клавиатуре!</span>")
	else
		to_chat(user, "<span class='danger'>Ох! Моя пустая голова так болит!</span>")
		user.adjustBrainLoss(5 * mistake)
		generate_task()

/obj/machinery/computer/retro/math_twister/proc/win(mob/living/user)
	to_chat(user, "Протокол безопасности отключен!")
	UnBlockBlastDoors()
	new /obj/effect/particle_effect/sparks(get_turf(src))
	new /obj/effect/particle_effect/chem_smoke/small(get_turf(src))
	new /obj/item/shard(get_turf(src))
	set_broken()
	playsound(src, 'sound/effects/empulse.ogg', 80)

/obj/machinery/computer/retro/math_twister/proc/UnBlockBlastDoors()
	for(var/obj/machinery/door/poddoor/impassable/P in GLOB.airlocks)
		if(P.id_tag == blast_id && P.z == z)
			INVOKE_ASYNC(P, TYPE_PROC_REF(/obj/machinery/door, open))

/obj/machinery/computer/retro/math_twister/on_deconstruction()
	playsound(src, 'sound/effects/glassbr3.ogg', 30, FALSE)
	new /obj/effect/decal/cleanable/glass(get_turf(src))
	new /obj/item/shard(get_turf(src))
	new /obj/item/stack/sheet/metal(get_turf(src), 5)
	new /obj/item/stack/cable_coil(get_turf(src), 5)

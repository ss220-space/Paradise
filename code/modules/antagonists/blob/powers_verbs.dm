/** Toggles requiring nodes */
/mob/camera/blob/verb/toggle_node_req()
	set category = "Blob"
	set name = "Переключить требование узла"
	set desc = "Переключить требование узла для размещения ресурсной плитки и фабрики."

	nodes_required = !nodes_required
	if(nodes_required)
		to_chat(src, span_warning("Теперь вам необходимо иметь узел или ядро рядом ​​для размещения фабрики и ресурсной плитки."))
	else
		to_chat(src, span_warning("Теперь вам не нужно иметь узел или ядро рядом ​​для размещения фабрики и ресурсной плитки."))


/mob/camera/blob/verb/blob_broadcast()
	set category = "Blob"
	set name = "Ретрянсляция блоба"
	set desc = "Говорите, используя споры и блобернаутов в качестве рупоров. Это действие бесплатно."

	var/speak_text = tgui_input_text(usr, "Что вы хотите сказать от лица ваших созданий?", "Ретрянсляция блоба", null)

	if(!speak_text)
		return
	else
		to_chat(usr, "Вы говорите от лица ваших созданий, <b>[speak_text]</b>")
	for(var/mob/living/simple_animal/hostile/blob_minion in blob_mobs)
		if(blob_minion.stat == CONSCIOUS)
			add_say_logs(usr, speak_text, language = "BLOB Broadcast")
			blob_minion.atom_say(speak_text)
	return

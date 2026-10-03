/** Toggles requiring nodes */
GAME_VERB_DESC(/mob/camera/blob, toggle_node_req, "Требование узла", "Переключить требование узла для размещения ресурсной плитки и фабрики.", VERB_CATEGORY_BLOB)
	nodes_required = !nodes_required
	if(nodes_required)
		to_chat(src, span_warning("Теперь вам необходимо иметь узел или ядро рядом ​​для размещения фабрики и ресурсной плитки."))
	else
		to_chat(src, span_warning("Теперь вам не нужно иметь узел или ядро рядом ​​для размещения фабрики и ресурсной плитки."))

GAME_VERB_DESC(/mob/camera/blob, blob_broadcast, "Ретрянсляция блоба", "Говорите, используя споры и блобернаутов в качестве рупоров. Это действие бесплатно.", VERB_CATEGORY_BLOB)
	VERB_ARG(speak_text, VERB_ARG_TYPE_TEXT, VERB_ARG_SOURCE_INPUT)
	if(!speak_text)
		return
	else
		to_chat(usr, "Вы говорите от лица ваших созданий, <b>[speak_text]</b>")
	for(var/mob/living/simple_animal/hostile/blob_minion in blob_mobs)
		if(blob_minion.stat == CONSCIOUS)
			add_say_logs(usr, speak_text, language = "BLOB Broadcast")
			blob_minion.atom_say(speak_text)

/datum/hallucination/message
	random_hallucination_weight = 60
	hallucination_tier = HALLUCINATION_TIER_COMMON

/datum/hallucination/message/start()
	if(hallucinator.incapacitated())
		return FALSE

	var/list/nearby_humans = list()
	var/adjacent_to_us = FALSE
	var/mob/living/carbon/human/suspicious_personnel
	for(var/mob/living/carbon/human/nearby_human in oview(7, hallucinator))
		if(get_dist(nearby_human, hallucinator) <= 1)
			suspicious_personnel = nearby_human
			adjacent_to_us = TRUE
			break
		nearby_humans += nearby_human

	if(!suspicious_personnel && length(nearby_humans))
		suspicious_personnel = pick(nearby_humans)

	var/list/message_pool = list()
	if(suspicious_personnel)
		if(adjacent_to_us)
			message_pool[span_warning("Вы чувствуете лёгкий укол!")] = 5

		message_pool["<b>[suspicious_personnel]</b> [pick("чихает", "кашляет")]."] = 1

	message_pool[span_notice("Вы слышите, как что-то пробирается по вентиляции...")] = 1

	message_pool[span_warning("Ваша [pick("рука", "нога", "спина", "голова")] чешется.")] = 1
	message_pool[span_warning("Вы чувствуете себя [pick("дурно", "слабо")].")] = 1
	message_pool[span_warning("Вам [pick("холодно", "жарко")].")] = 1
	message_pool[span_warning("Ваш желудок урчит.")] = 1
	message_pool[span_warning("У вас болит голова.")] = 1
	message_pool[span_warning("Вы слышите слабый гул в голове.")] = 1

	if(prob(10))
		message_pool[span_warning("Позади тебя.")] = 1
		message_pool[span_warning("Вы слышите слабый смех.")] = 1
		message_pool[span_warning("Вы слышите шорох на потолке.")] = 1
		message_pool[span_warning("Вы видите неестественно высокий силуэт вдалеке.")] = 2

	if(prob(30))
		message_pool[pick("Кто-то следит за тобой.", "Ты слышал это?", "Что ты натворил?", "Почему?", "Отдай!", "Уйди!")] = 4

	var/chosen = pickweight(message_pool)
	feedback_details += "Message: [chosen]"
	to_chat(hallucinator, chosen)
	qdel(src)
	return TRUE

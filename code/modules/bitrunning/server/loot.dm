#define GRADE_D "D"
#define GRADE_C "C"
#define GRADE_B "B"
#define GRADE_A "A"
#define GRADE_S "S"

/obj/machinery/quantum_server/proc/calculate_rewards()
	var/rewards_base = 0.8

	if(domain_randomized)
		rewards_base += 0.2

	rewards_base += servo_bonus
	rewards_base += length(spawned_threat_refs) * 2
	rewards_base += get_multiplayer_bonus()
	rewards_base += get_nohit_bonus()

	return rewards_base

/obj/machinery/quantum_server/proc/get_multiplayer_bonus()
	var/total = 0
	var/counted_first = FALSE

	for(var/datum/weakref/connection_ref as anything in avatar_connection_refs)
		var/datum/component/avatar_connection/connection = connection_ref.resolve()
		if(isnull(connection))
			continue
		if(counted_first)
			total += multiplayer_bonus
		counted_first = TRUE

	return total

/obj/machinery/quantum_server/proc/get_nohit_bonus()
	if(generated_domain.domain_flags & DOMAIN_NO_NOHIT_BONUS)
		return 0

	var/total = 0
	for(var/datum/weakref/connection_ref as anything in avatar_connection_refs)
		var/datum/component/avatar_connection/connection = connection_ref.resolve()
		if(connection?.nohit)
			total += nohit_bonus

	return total

/obj/machinery/quantum_server/proc/generate_loot(obj/cache, obj/machinery/byteforge/chosen_forge)
	for(var/mob/living/person in cache.contents)
		SEND_SIGNAL(person, COMSIG_BITRUNNER_CACHE_SEVER)

	spark_at_location(cache)
	qdel(cache)

	SEND_SIGNAL(src, COMSIG_BITRUNNER_DOMAIN_COMPLETE, chosen_forge, generated_domain.reward_points)

	points += generated_domain.reward_points
	playsound(src, 'sound/machines/terminal_success.ogg', 30, TRUE)

	var/bonus = calculate_rewards()
	var/completion_time = world.time - generated_domain.start_time
	var/grade = grade_completion(completion_time)

	var/obj/structure/closet/crate/secure/bitrunning/decrypted/reward_cache = new(src, generated_domain, bonus)

	var/obj/item/paper/certificate = new(reward_cache)
	certificate.name = "сертификат о прохождении домена"
	certificate.info = get_completion_certificate(completion_time, grade, bonus)

	if(can_generate_tech_disk(grade))
		generated_domain.disk_reward_spawned = TRUE
		var/disk_path = pick(subtypesof(/obj/item/disk/tech_disk/loaded))
		new disk_path(reward_cache)

	chosen_forge.start_to_spawn(reward_cache)

	domain_complete = TRUE

/obj/machinery/quantum_server/proc/generate_secondary_loot(obj/curiosity, obj/machinery/byteforge/chosen_forge)
	spark_at_location(curiosity)
	qdel(curiosity)

	chosen_forge.start_to_spawn(new /obj/item/storage/lockbox/bitrunning/decrypted(src, generated_domain))

/obj/machinery/quantum_server/proc/can_generate_tech_disk(grade)
	if(generated_domain.disk_reward_spawned)
		return FALSE

	if(generated_domain.difficulty < BITRUNNER_DIFFICULTY_MEDIUM)
		return FALSE

	return grade == GRADE_A || grade == GRADE_S

/obj/machinery/quantum_server/proc/get_completion_certificate(completion_time, grade, bonus)
	var/text = "<center><b>Сертификат о прохождении домена</b></center><hr>"
	text += "<b>Домен:</b> [generated_domain.name][domain_randomized ? " (случайный выбор)" : ""]<br>"
	text += "<b>Сложность:</b> [generated_domain.difficulty]<br>"
	text += "<b>Базовая награда:</b> [generated_domain.reward_points]<br>"
	text += "<b>Множитель:</b> [bonus]x<br>"
	text += "<b>Время прохождения:</b> [DisplayTimeText(completion_time)]<br><hr>"

	var/mp_bonus = get_multiplayer_bonus()
	if(mp_bonus)
		text += "Совместное прохождение: +[mp_bonus]<br>"

	var/untouched_bonus = get_nohit_bonus()
	if(untouched_bonus)
		text += "Без единого ранения: +[untouched_bonus]<br>"

	if(servo_bonus)
		text += "Манипуляторы сервера: +[servo_bonus]<br>"
	if(length(spawned_threat_refs))
		text += "Угрозы: [length(spawned_threat_refs)], бонус +[length(spawned_threat_refs) * 2]<br>"

	text += "<center><b>Оценка: [grade]</b></center>"

	return text

/obj/machinery/quantum_server/proc/grade_completion(completion_time)
	var/score = generated_domain.reward_points + length(spawned_threat_refs) * 5
	var/base = generated_domain.difficulty + 1
	var/time_score = 1

	if(completion_time <= 1 MINUTES)
		time_score = 10
	else if(completion_time <= 2 MINUTES)
		time_score = 5
	else if(completion_time <= 5 MINUTES)
		time_score = 3
	else if(completion_time <= 10 MINUTES)
		time_score = 2

	score += time_score * base
	threat += score

	switch(score)
		if(1 to 4)
			return GRADE_D
		if(5 to 7)
			return GRADE_C
		if(8 to 10)
			return GRADE_B
		if(11 to 13)
			return GRADE_A
		else
			return GRADE_S

#undef GRADE_D
#undef GRADE_C
#undef GRADE_B
#undef GRADE_A
#undef GRADE_S

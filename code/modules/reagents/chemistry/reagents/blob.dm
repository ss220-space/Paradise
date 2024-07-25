// These can only be applied by blobs. They are what blobs are made out of.
// The 4 damage
/datum/reagent/blob
	description = ""
	var/complementary_color = "#000000"
	var/message = "Блоб наносит вам удар" //message sent to any mob hit by the blob
	var/message_living = null //extension to first mob sent to only living mobs i.e. silicons have no skin to be burnt
	can_synth = FALSE

/datum/reagent/blob/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume, show_message, touch_protection)
	return round(volume * min(1.5 - touch_protection, 1), 0.1) //full touch protection means 50% volume, any prot below 0.5 means 100% volume.

/datum/reagent/blob/proc/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag) //when the blob takes damage, do this
	return damage

/datum/reagent/blob/ripping_tendrils //does brute and a little stamina damage
	name = "Разрывающие щупальца"
	description = "Наносит высокий урон <span class='red'>травмами</span>, а также урон <span style='color:#0000FF'>выносливости</span>."
	id = "ripping_tendrils"
	color = "#7F0000"
	complementary_color = "#a15656"
	message_living = ", и вы чувствуете, как ваша кожа рвется и слезает."

/datum/reagent/blob/ripping_tendrils/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.6*volume, BRUTE)
		M.adjustStaminaLoss(volume)
		if(iscarbon(M))
			M.emote("scream")

/datum/reagent/blob/boiling_oil //sets you on fire, does burn damage
	name = "Кипящее масло"
	description = "Наносит высокий урон <span style='color:#B68D00'>ожогами</span> и <span style='color:#FF4500'>поджигает</span> жертву."
	id = "boiling_oil"
	color = "#B68D00"
	complementary_color = "#c0a856"
	message = "Блоб обдает вас горящим маслом"
	message_living = ", и вы чувствуете, как ваша кожа обугливается и плавится"

/datum/reagent/blob/boiling_oil/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		M.adjust_fire_stacks(round(volume/10))
		volume = ..()
		M.apply_damage(0.6*volume, BURN)
		M.IgniteMob()
		M.emote("scream")

/datum/reagent/blob/envenomed_filaments //toxin, hallucination, and some bonus spore toxin
	name = "Ядовитые нити"
	description = "Наносит высокий урон <span style='color:#9ACD32'>токсинами</span>, вызывает галлюцинации и вводит споры в кровоток."
	id = "envenomed_filaments"
	color = "#9ACD32"
	complementary_color = "#b0cd73"
	message_living = ", и вы чувствуете себя плохо. Вас тошнит"

/datum/reagent/blob/envenomed_filaments/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.6 * volume, TOX)
		M.AdjustHallucinate(1.2 SECONDS * volume)
		if(M.reagents)
			M.reagents.add_reagent("spore", 0.4*volume)

/datum/reagent/blob/lexorin_jelly //does tons of oxygen damage and a little brute
	name = "Лексориновое желе"
	description = "Наносит средний урон <span class='red'>травмами</span>, но огромный урон <span style='color:#00FFFF'>гипоксией</span>."
	id = "lexorin_jelly"
	color = "#00FFC5"
	complementary_color = "#56ebc9"
	message_living = ", и ваши легкие кажутся тяжелыми и слабыми"

/datum/reagent/blob/lexorin_jelly/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.4*volume, BRUTE)
		M.apply_damage(1*volume, OXY)
		M.AdjustLoseBreath(round(0.6 SECONDS * volume))


/datum/reagent/blob/kinetic //does semi-random brute damage
	name = "Кинетический желатин"
	description = "Наносит случайный урон <span class='red'>травмами</span>, в 0,33–2,33 раза превышающий стандартное количество."
	id = "kinetic"
	color = "#FFA500"
	complementary_color = "#ebb756"
	message = "Блоб избивает вас"

/datum/reagent/blob/kinetic/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		var/damage = rand(5, 35)/25
		M.apply_damage(damage*volume, BRUTE)

/datum/reagent/blob/cryogenic_liquid //does low burn damage and stamina damage and cools targets down
	name = "Криогенная жидкость"
	description = "Наносит средний урон <span class='red'>травмами</span>, урон <span style='color:#0000FF'>выносливости</span> и вводит в жертв <span style='color:#8BA6E9'>ледяное масло</span>, замораживая их до смерти."
	id = "cryogenic_liquid"
	color = "#8BA6E9"
	complementary_color = "#a8b7df"
	message = "Блоб обливает вас ледяной жидкостью"
	message_living = ", и вы чувствуете себя холодным и усталым"

/datum/reagent/blob/cryogenic_liquid/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.4*volume, BURN)
		M.adjustStaminaLoss(volume)
		if(M.reagents)
			M.reagents.add_reagent("frostoil", 0.4*volume)

/datum/reagent/blob/b_sorium
	name = "Сорий"
	description = "Наносит высокий урон <span class='red'>травмами</span> и <span style='color:#808000'>отбрасывает</span> людей в стороны."
	id = "b_sorium"
	color = "#808000"
	complementary_color = "#a2a256"
	message = "Блоб врезается в вас и отбрасывает в сторону."

/datum/reagent/blob/b_sorium/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		reagent_vortex(M, 1, volume)
		volume = ..()
		M.apply_damage(0.6*volume, BRUTE)

/datum/reagent/blob/proc/reagent_vortex(mob/living/M, setting_type, volume)
	var/turf/pull = get_turf(M)
	var/range_power = clamp(round(volume/5, 1), 1, 5)
	for(var/atom/movable/X in range(range_power,pull))
		if(iseffect(X))
			continue
		if(X.move_resist <= MOVE_FORCE_DEFAULT && !X.anchored)
			var/distance = get_dist(X, pull)
			var/moving_power = max(range_power - distance, 1)
			spawn(0)
				if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
					if(setting_type)
						var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, pull)))
						var/throw_range = 5 - distance
						X.throw_at(throw_target, throw_range, 1)
					else
						X.throw_at(pull, distance, 1)
				else
					if(setting_type)
						for(var/i = 0, i < moving_power, i++)
							sleep(2)
							if(!step_away(X, pull))
								break
					else
						for(var/i = 0, i < moving_power, i++)
							sleep(2)
							if(!step_towards(X, pull))
								break

/datum/reagent/blob/radioactive_gel
	name = "Радиоактивный гель"
	description = "Наносит средний урон <span style='color:#9ACD32'>токсинами</span> и небольшой урон <span class='red'>травмами</span>, но <span style='color:#4B0082'>облучает</span> тех, кого задевает."
	id = "radioactive_gel"
	color = "#2476f0"
	complementary_color = "#24f0f0"
	message_living = ", и вы чувствуете странное тепло изнутри"

/datum/reagent/blob/radioactive_gel/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.3 * volume, TOX)
		M.apply_damage(0.2 * volume, BRUTE) // lets not have IPC / plasmaman only take 7.5 damage from this
		if(M.reagents)
			M.reagents.add_reagent("uranium", 0.3 * volume)

/datum/reagent/blob/teslium_paste
	name = "Теслиевая паста"
	description = "Наносит средний урон <span style='color:#B68D00'>ожогами</span> и вызывает <span style='color:#FFFFE0'>удары током</span> у тех, кого задевает, со временем."
	id = "teslium_paste"
	color = "#20324D"
	complementary_color = "#412968"
	message_living = ", и вы чувствуете удар статическим электричеством"

/datum/reagent/blob/teslium_paste/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.4 * volume, BURN)
		if(M.reagents)
			if(M.reagents.has_reagent("teslium") && prob(0.6 * volume))
				M.electrocute_act((0.5 * volume), "разряда блоба", flags = SHOCK_NOGLOVES)
				M.reagents.del_reagent("teslium")
				return //don't add more teslium after you shock it out of someone.
			M.reagents.add_reagent("teslium", 0.125 * volume)  // a little goes a long way

/datum/reagent/blob/proc/send_message(mob/living/M)
	var/totalmessage = message
	if(message_living && !issilicon(M))
		totalmessage += message_living
	totalmessage += "!"
	to_chat(M, "<span class='userdanger'>[totalmessage]</span>")

// These can only be applied by blobs. They are what blobs are made out of.
// The 4 damage
/datum/reagent/blob
	description = ""
	var/complementary_color = "#000000"
	var/message = "Блоб ударяет вас" //message sent to any mob hit by the blob
	var/message_living = null //extension to first mob sent to only living mobs i.e. silicons have no skin to be burnt
	can_synth = FALSE

/datum/reagent/blob/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume, show_message, touch_protection)
	return round(volume * min(1.5 - touch_protection, 1), 0.1) //full touch protection means 50% volume, any prot below 0.5 means 100% volume.

/datum/reagent/blob/proc/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag) //when the blob takes damage, do this
	return damage

/datum/reagent/blob/ripping_tendrils //does brute and a little stamina damage
	name = "Разрывающие усики" // Ripping Tendrils
	description = "Наносит много урона травмами и урона выносливости."
	id = "ripping_tendrils"
	color = "#7F0000"
	complementary_color = "#a15656"
	message_living = ", терзая и обдирая кожу"

/datum/reagent/blob/ripping_tendrils/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.6*volume, BRUTE)
		M.adjustStaminaLoss(volume)
		if(iscarbon(M))
			M.emote("scream")

/datum/reagent/blob/boiling_oil //sets you on fire, does burn damage
	name = "Кипящее масло" // Boiling Oil
	description = "Наносит много урона ожогами; поджигает жертву."
	id = "boiling_oil"
	color = "#B68D00"
	complementary_color = "#c0a856"
	message = "Блоб обливает вас раскалённым маслом"
	message_living = ", обугливая и плавя кожу"

/datum/reagent/blob/boiling_oil/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		M.adjust_fire_stacks(round(volume/10))
		volume = ..()
		M.apply_damage(0.6*volume, BURN)
		M.IgniteMob()
		M.emote("scream")

/datum/reagent/blob/envenomed_filaments //toxin, hallucination, and some bonus spore toxin
	name = "Ядовитые нити" // Envenomed Filaments
	description = "Deals High Toxin damage, causes Hallucinations, and injects Spores into the bloodstream."
	id = "envenomed_filaments"
	color = "#9ACD32"
	complementary_color = "#b0cd73"
	message_living = ", вызывая тошноту и слабость"

/datum/reagent/blob/envenomed_filaments/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.6*volume, TOX)
		M.hallucination += 0.6*volume
		if(M.reagents)
			M.reagents.add_reagent("spore", 0.4*volume)

/datum/reagent/blob/lexorin_jelly //does tons of oxygen damage and a little brute
	name = "Лексориновое желе" // Lexorin Jelly
	description = "Наносит средний урон травмами, но огромное количество урона от удушья."
	id = "lexorin_jelly"
	color = "#00FFC5"
	complementary_color = "#56ebc9"
	message_living = ", ваши легкие слабеют, а дыхание тяжелеет"

/datum/reagent/blob/lexorin_jelly/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.4*volume, BRUTE)
		M.apply_damage(1*volume, OXY)
		M.AdjustLoseBreath(round(0.3*volume))


/datum/reagent/blob/kinetic //does semi-random brute damage
	name = "Кинетический желатин" // Kinetic Gelatin
	description = "Наносит от одной до семи третьих обычного урона."
	id = "kinetic"
	color = "#FFA500"
	complementary_color = "#ebb756"
	message = "Блоб вас отталкивает"

/datum/reagent/blob/kinetic/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		var/damage = rand(5, 35)/25
		M.apply_damage(damage*volume, BRUTE)

/datum/reagent/blob/cryogenic_liquid //does low burn damage and stamina damage and cools targets down
	name = "Криогенная жидкость" // Cryogenic Liquid
	description = "Наносит средний урон от травм, урон выносливости; делает жертвам инъекции ледяного масла, замораживающего их насмерть."
	id = "cryogenic_liquid"
	color = "#8BA6E9"
	complementary_color = "#a8b7df"
	message = "Блоб обливает вас ледяной жидкостью"
	message_living = ", забирая силы и промораживая до самых костей"

/datum/reagent/blob/cryogenic_liquid/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.4*volume, BURN)
		M.adjustStaminaLoss(volume)
		if(M.reagents)
			M.reagents.add_reagent("frostoil", 0.4*volume)

/datum/reagent/blob/b_sorium
	name = "Сорий" // Sorium
	description = "Наносит много урона от травм и раскидывает людей в стороны."
	id = "b_sorium"
	color = "#808000"
	complementary_color = "#a2a256"
	message = "Блоб бьёт вас, отбрасывая ударом"

/datum/reagent/blob/b_sorium/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		reagent_vortex(M, 1, volume)
		volume = ..()
		M.apply_damage(0.6*volume, BRUTE)

/datum/reagent/blob/proc/reagent_vortex(mob/living/M, setting_type, volume)
	var/turf/pull = get_turf(M)
	var/range_power = clamp(round(volume/5, 1), 1, 5)
	for(var/atom/movable/X in range(range_power,pull))
		if(istype(X, /obj/effect))
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
	name = "Радиоактивный гель" // Radioactive gel
	description = "Наносит средний урон токсинами и небольшой урон от травм, но облучает поражённых."
	id = "radioactive_gel"
	color = "#2476f0"
	complementary_color = "#24f0f0"
	message_living = ", и внутри появляется странное ощущение тепла"

/datum/reagent/blob/radioactive_gel/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.3 * volume, TOX)
		M.apply_damage(0.2 * volume, BRUTE) // lets not have IPC / plasmaman only take 7.5 damage from this
		if(M.reagents)
			M.reagents.add_reagent("uranium", 0.3 * volume)

/datum/reagent/blob/teslium_paste
	name = "Теслиевая паста" // Teslium paste
	description = "Наносит средний урон от ожогов и периодические удары током."
	id = "teslium_paste"
	color = "#20324D"
	complementary_color = "#412968"
	message_living = ", и добавляет удар электрошоком"

/datum/reagent/blob/teslium_paste/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		volume = ..()
		M.apply_damage(0.4 * volume, BURN)
		if(M.reagents)
			if(M.reagents.has_reagent("teslium") && prob(0.6 * volume))
				M.electrocute_act((0.5 * volume), "электроразрядом блоба", 1, TRUE)
				M.reagents.del_reagent("teslium")
				return //don't add more teslium after you shock it out of someone.
			M.reagents.add_reagent("teslium", 0.125 * volume)  // a little goes a long way

/datum/reagent/blob/proc/send_message(mob/living/M)
	var/totalmessage = message
	if(message_living && !issilicon(M))
		totalmessage += message_living
	totalmessage += "!"
	to_chat(M, "<span class='userdanger'>[totalmessage]</span>")

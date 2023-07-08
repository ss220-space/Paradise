//Техника агрессивного маркетинга мистера Ченга
/datum/martial_art/mr_chang
	name = "Mr. Chang's Aggressive Marketing"
	combos = list(/datum/martial_combo/mr_chang/steal_card)
	var/stun_on_cooldown = FALSE

/datum/martial_art/mr_chang/attack_reaction(var/mob/living/carbon/human/defender, var/mob/living/carbon/human/attacker, var/obj/item/I)
	//Stunning discounts!
	if(can_use(defender) && defender.in_throw_mode && !defender.incapacitated(FALSE, TRUE) && defender.a_intent == INTENT_DISARM && !stun_on_cooldown)
		defender.visible_message("<span class='warning'>[defender] intercept attack of [attacker]!</span>")
		attacker.forceMove(defender.loc)
		attacker.adjustStaminaLoss(200)
		stun_on_cooldown = TRUE
		defender.SpinAnimation(10,1)
		attacker.SpinAnimation(10,1)
		add_attack_logs(defender, attacker, "Intercepted attack with [src]: Stunning discounts!")

		var/msg = pick("Сногсшибательные скидки!", "От скидок кругом голова!", "Предложение — хоть стой, хоть падай!", \
					"Пол тоже продаётся!", "С вас 350000 кредитов!", "Вы за это заплатите!")
		defender.say(msg)

		spawn(40)
			stun_on_cooldown = FALSE
		return TRUE



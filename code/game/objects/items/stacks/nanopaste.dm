/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite swarm"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	icon = 'icons/obj/nanopaste.dmi'
	icon_state = "tube"
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=2;engineering=3"
	amount = 6
	max_amount = 6
	toolspeed = 1

/obj/item/stack/nanopaste/cyborg
	is_cyborg = 1

/obj/item/stack/nanopaste/cyborg/attack(mob/living/M, mob/user)
	if(!get_amount())
		to_chat(user, "<span class='danger'>Not enough nanopaste!</span>")
		return
	else
		. = ..()

/obj/item/stack/nanopaste/attack(mob/living/M, mob/user)
	if(!istype(M) || !istype(user))
		return 0
	if(istype(M,/mob/living/silicon/robot))	//Repairing cyborgs
		var/mob/living/silicon/robot/R = M
		if(R.getBruteLoss() || R.getFireLoss() || LAZYLEN(R.diseases))
			R.heal_overall_damage(15, 15)
			R.CureAllDiseases(FALSE)
			use(1)
			user.visible_message("<span class='notice'>\The [user] applied some [src] at [R]'s damaged areas.</span>",\
				"<span class='notice'>You apply some [src] at [R]'s damaged areas.</span>")
		else
			to_chat(user, "<span class='notice'>All [R]'s systems are nominal.</span>")

	if(ishuman(M)) //Repairing robotic limbs and IPCs
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/S = H.get_organ(user.zone_selected)

		if(S && S.is_robotic())
			if(ismachineperson(M) && M.diseases?.len)
				use(1)
				M.CureAllDiseases()
				user.visible_message("<span class='notice'>\The [user] applies some nanite paste at \the [M] to fix problems.</span>")
				return
			if(S.get_damage())
				use(1)
				var/remheal = 15
				var/nremheal = 0
				var/childlist
				if(LAZYLEN(S.children))
					childlist = S.children.Copy()
				var/parenthealed = FALSE
				var/should_update_health = FALSE
				var/update_damage_icon = NONE
				while(remheal > 0)
					var/obj/item/organ/external/E
					if(S.get_damage())
						E = S
					else if(LAZYLEN(childlist))
						E = pick_n_take(childlist)
						if(!E.get_damage() || !E.is_robotic())
							continue
					else if(S.parent && !parenthealed)
						E = S.parent
						parenthealed = TRUE
						if(!E.get_damage() || !E.is_robotic())
							break
					else
						break
					nremheal = max(remheal - E.get_damage(), 0)
					var/brute_was = E.brute_dam
					var/burn_was = E.burn_dam
					update_damage_icon |= E.heal_damage(remheal, remheal, FALSE, TRUE, FALSE)
					if(E.brute_dam != brute_was || E.burn_dam != burn_was)
						should_update_health = TRUE
					remheal = nremheal
					user.visible_message("<span class='notice'>\The [user] applies some nanite paste at \the [M]'s [E.name] with \the [src].</span>")
				if(should_update_health)
					H.updatehealth("nanopaste repair")
				if(update_damage_icon)
					H.UpdateDamageIcon()
				if(H.bleed_rate && ismachineperson(H))
					H.bleed_rate = 0
			else
				to_chat(user, "<span class='notice'>Nothing to fix here.</span>")
		else
			to_chat(user, "<span class='notice'>[src] won't work on that.</span>")

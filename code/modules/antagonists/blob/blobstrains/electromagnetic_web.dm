//does burn damage and EMPs, slightly fragile
/datum/blobstrain/reagent/electromagnetic_web
	name = "Электромагнитная паутина"
	color = "#83ECEC"
	complementary_color = "#EC8383"
	description = "наносит большой урон от ожогов и излучает ЭМИ."
	effectdesc = "также получает значительно увеличенный урон и выпускает ЭМИ после разрушения."
	analyzerdescdamage = "Наносит большой урон от ожогов и излучает ЭМИ."
	analyzerdesceffect = "Хрупок ко всем типам урона и получает огромный урон от травм. Кроме того, при разрушении выпускает небольшой ЭМИ."
	reagent = /datum/reagent/blob/electromagnetic_web

/datum/blobstrain/reagent/electromagnetic_web/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(damage_type == BRUTE) // take full brute, divide by the multiplier to get full value
		return damage / B.brute_resist
	return damage * 1.25 //a laser will do 25 damage, which will kill any normal blob

/datum/blobstrain/reagent/electromagnetic_web/attack_mech(obj/mecha/mech)
	if(prob(50))
		empulse(mech.loc, 0, 1)

/datum/blobstrain/reagent/electromagnetic_web/death_reaction(obj/structure/blob/B, damage_flag)
	if(damage_flag == MELEE || damage_flag == BULLET || damage_flag == LASER)
		empulse(B.loc, 1, 3) //less than screen range, so you can stand out of range to avoid it

/datum/reagent/blob/electromagnetic_web
	name = "Электромагнитная паутина"
	id = "blob_electromagnetic_web"
	taste_description = "поп-рока"
	color = "#83ECEC"

/datum/reagent/blob/electromagnetic_web/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	if(prob(reac_volume*2))
		exposed_mob.emp_act(EMP_LIGHT)
	if(exposed_mob)
		exposed_mob.apply_damage(reac_volume, BURN, forced=TRUE)

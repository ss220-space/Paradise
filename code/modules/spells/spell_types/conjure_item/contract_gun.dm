/datum/action/cooldown/spell/conjure_item/contract_gun
	name = "Призвать верное оружие"
	desc = "Призвать оружие, полученное в обмен на душу."

	invocation_type = INVOCATION_WHISPER
	invocation = "Amicus meus, suus ' vicis"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	button_icon_state = "bolt_action_old"
	background_icon_state = "bg_demon"

/datum/action/cooldown/spell/conjure_item/contract_gun/Grant(mob/grant_to)
	. = ..()
	item_type = safepick(GLOB.devil_guns)

/datum/action/cooldown/spell/conjure_item/contract_gun/post_created(atom/cast_on, atom/created)
	. = ..()
	var/obj/item/gun/projectile/automatic/weapon = created
	weapon.origin_tech = list()
	weapon.materials = list()
	ADD_TRAIT(weapon, TRAIT_NODROP, INNATE_TRAIT)
	ADD_TRAIT(weapon, TRAIT_NOT_TURRET_GUN, INNATE_TRAIT)

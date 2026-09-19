/datum/action/cooldown/spell/pointed/projectile/shadow_grapple
	name = "Теневой захват"
	desc = "Выстрелите одной из своих рук. Если она попадёт в человека, вы притянете его к себе. Если же она попадёт в структуру, то вы сами притянетесь к ней."
	background_icon_state = "shadow_demon_bg"
	button_icon_state = "shadow_grapple"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = null
	sound = null
	active_msg = span_notice_alt("Вы поднимаете руку, наполненную демонической энергией! <b>ЛКМ, чтобы применить к цели!</b>")
	deactive_msg = span_notice_alt("Вы поглощаете энергию обратно... пока что.")
	cooldown_time = 10 SECONDS
	projectile_type = /obj/projectile/magic/shadow_hand

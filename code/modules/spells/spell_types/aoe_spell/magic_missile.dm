/datum/action/cooldown/spell/aoe/magic_missile
	name = "Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."
	button_icon_state = "magicm"
	sound = 'sound/magic/magic_missile.ogg'
	school = SCHOOL_EVOCATION
	cooldown_time = 20 SECONDS
	cooldown_reduction_per_rank = 3.5 SECONDS
	invocation = "FORTI GY AMA!"
	invocation_type = INVOCATION_SHOUT
	targeting_type = /datum/aoe_targeting/living
	/// The projectile type fired at all people around us
	var/obj/projectile/projectile_type = /obj/projectile/magic/aoe/magic_missile

/datum/action/cooldown/spell/aoe/magic_missile/cast_on_thing_in_aoe(mob/living/victim, atom/caster)
	fire_projectile(victim, caster)

/datum/action/cooldown/spell/aoe/magic_missile/proc/fire_projectile(atom/victim, mob/caster)
	var/obj/projectile/to_fire = new projectile_type()
	to_fire.firer = caster
	to_fire.current = get_turf(caster)
	to_fire.original = victim
	to_fire.preparePixelProjectile(victim, caster)
	SEND_SIGNAL(caster, COMSIG_MOB_SPELL_PROJECTILE, src, victim, to_fire)
	to_fire.fire()

/datum/action/cooldown/spell/aoe/magic_missile/lesser
	name = "Lesser Magic Missile"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	cooldown_time = 40 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	max_targets = 6
	shuffle_targets_list = TRUE
	projectile_type = /obj/projectile/magic/aoe/magic_missile/lesser

/datum/action/cooldown/spell/aoe/magic_missile/honk_missile
	name = "Honk Missile"
	desc = "This spell fires several, slow moving, magic bikehorns at nearby targets."
	projectile_type = /obj/projectile/magic/aoe/magic_missile/honk
	cooldown_reduction_per_rank = 2.5 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "HONK GY AMA"
	sound = 'sound/items/bikehorn.ogg'

/datum/action/cooldown/spell/pointed/mindswap
	name = "Mind Transfer"
	desc = "This spell allows the user to switch bodies with a target."

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 60 SECONDS
	cooldown_reduction_per_rank = 10 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "GIN'YU CAPAN"
	invocation_type = INVOCATION_WHISPER
	active_msg = span_notice_alt("You prepare to transfer your mind.")
	deactive_msg = span_notice_alt("You decide that your current form is good enough.")
	var/list/protected_roles = list("Wizard","Changeling","Cultist") //which roles are immune to the spell
	var/paralysis_amount_caster = 40 SECONDS //how much the caster is paralysed for after the spell
	var/paralysis_amount_victim = 40 SECONDS //how much the victim is paralysed for after the spell
	button_icon_state = "mindswap"
	cast_range = 1

/datum/action/cooldown/spell/pointed/mindswap/is_valid_target(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return FALSE
	var/mob/living/target = cast_on
	return target.stat != DEAD && target.key && target.mind && !HAS_TRAIT(target, TRAIT_MIND_TEMPORARILY_GONE)

/*
Urist: I don't feel like figuring out how you store object spells so I'm leaving this for you to do.
Make sure spells that are removed from spell_list are actually removed and deleted when mind transfering.
Also, you never added distance checking after target is selected. I've went ahead and did that.
*/
/datum/action/cooldown/spell/pointed/mindswap/cast(atom/cast_on)
	. = ..()
	var/mob/living/target = cast_on

	if(owner.suiciding)
		to_chat(owner, span_warning("You're killing yourself! You can't concentrate enough to do this!"))
		return

	if(target.mind.special_role in protected_roles)
		to_chat(owner, "Their mind is resisting your spell.")
		return

	if(issilicon(target))
		to_chat(owner, "You feel this enslaved being is just as dead as its cold, hard exoskeleton.")
		return

	var/mob/living/victim = target//The target of the spell whos body will be transferred to.
	var/mob/living/caster = owner//The wizard/whomever doing the body transferring.

	//MIND TRANSFER BEGIN

	var/mob/dead/observer/ghost = victim.ghostize(0)
	caster.mind.transfer_to(victim)

	ghost.mind.transfer_to(caster)
	if(ghost.key)
		GLOB.non_respawnable_keys -= ghost.ckey //ghostizing with an argument of 0 will make them unable to respawn forever, which is bad
		caster.possess_by_player(ghost.ckey)	//have to transfer the key since the mind was not active
	qdel(ghost)
	//MIND TRANSFER END

	//Here we paralyze both mobs and knock them out for a time.
	caster.Paralyse(paralysis_amount_caster)
	victim.Paralyse(paralysis_amount_victim)


/obj/item/implant/sad_trombone
	name = "sad trombone bio-chip"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	trigger_emotes = list("deathgasp")
	// If something forces the clown to fake death, it's pretty funny to still see the sad trombone played
	trigger_causes = BIOCHIP_EMOTE_TRIGGER_UNINTENTIONAL|BIOCHIP_TRIGGER_DEATH_ANY
	implant_data = /datum/implant_fluff/sad_trombone
	implant_state = "implant-honk"


/obj/item/implant/sad_trombone/emote_trigger(emote, mob/source, intentional)
	activate()


/obj/item/implant/sad_trombone/death_trigger(mob/user, gibbed)
	activate()


/obj/item/implant/sad_trombone/activate(cause)
	playsound(loc, 'sound/misc/sadtrombone.ogg', 50, FALSE)


/obj/item/implanter/sad_trombone
	name = "bio-chip implanter (sad trombone)"
	imp = /obj/item/implant/sad_trombone


/obj/item/implantcase/sad_trombone
	name = "bio-chip case - 'Sad Trombone'"
	desc = "A glass case containing a sad trombone bio-chip."
	imp = /obj/item/implant/sad_trombone


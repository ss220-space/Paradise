/obj/item/organ/internal/tongue
	name = "tongue"
	desc = "A fleshy muscle mostly used for lying."
	icon_state = "tonguenormal"
	parent_organ = "head"
	slot = "tongue"
	attack_verb = list("licked", "slobbered", "slapped", "frenched", "tongued")
	var/list/languages_possible
	var/taste_sensitivity = 15 // lower is more sensitive.
	var/modifies_speech = FALSE
	var/speech_verb = "says"
	var/ask_verb = "asks"
	var/exclaim_verb = "exclaims"
	var/list/languages_possible_base = list(
		/datum/language/common,
		/datum/language/com_srus,
		/datum/language/gutter,
		/datum/language/gothic,
		/datum/language/human,
		/datum/language/monkey,
		/datum/language/kidan,
		/datum/language/slime,
		/datum/language/skrell,
		/datum/language/tajaran,
		/datum/language/unathi,
		)

/obj/item/organ/internal/tongue/lizard
	name = "forked tongue"
	desc = "A thin and long muscle typically found in reptilian races, apparently moonlights as a nose."
	icon_state = "tonguelizard"
	speech_verb = "hisses"

/obj/item/organ/internal/tongue/tajaran
	name = "cat tongue"
	desc = "A long and rough feline tongue, covered with growths."
	speech_verb = "meows"

/obj/item/organ/internal/tongue/vulpkanin
	name = "canine tongue"
	desc = "A long and wet canine tongue."
	speech_verb = "barks"

/obj/item/organ/internal/tongue/kidan
	name = "kidan proboscis"
	desc = "A freakish looking meat tube that apparently can take in liquids."
	icon_state = "tonguefly"
	slot = "proboscis"
	speech_verb = list("clicks","clacks","chitters")

/obj/item/organ/internal/tongue/wryn
	name = "wryn proboscis"
	desc = "A freakish looking meat tube that apparently can take in liquids."
	slot = "proboscis"

/obj/item/organ/internal/tongue/grey
	name = "psilingual matrix"
	desc = "A mysterious structure that allows for instant psionic communication between users. Pretty impressive until you need to eat something."
	icon_state = "tongueayylmao"
	slot = "psilingual matrix"

/obj/item/organ/internal/tongue/alien
	name = "alien tongue"
	desc = "According to leading xenobiologists the evolutionary benefit of having a second mouth in your mouth is \"that it looks badass\"."
	icon_state = "tonguexeno"
	var/static/list/languages_possible_alien = typecacheof(list(
		/datum/language/xenocommon,
		/datum/language/common,
		/datum/language/unathi
		))

/obj/item/organ/internal/tongue/monkey
	name = "monkey tongue"
	languages_possible_base = list(/datum/language/monkey)

/obj/item/organ/internal/tongue/stok
	name = "forked tongue"
	desc = "A thin and long muscle typically found in reptilian races, apparently moonlights as a nose."
	icon_state = "tonguelizard"
	languages_possible_base = list(/datum/language/monkey)
	speech_verb = "hisses"

/obj/item/organ/internal/tongue/wolpin
	name = "wulpin tongue"
	desc = "A long and wet canine tongue."
	languages_possible_base = list(/datum/language/monkey)

/obj/item/organ/internal/tongue/farwa
	name = "farwa tongue"
	desc = "A long and rough feline tongue, covered with growths."
	languages_possible_base = list(/datum/language/monkey)

/obj/item/organ/internal/tongue/neara
	name = "neara tongue"
	desc = "A long and slippery skrell tongue, covered with watery slime."
	icon_state = "tongueslime"
	languages_possible_base = list(/datum/language/monkey)
	speech_verb = "blorbles"

/obj/item/organ/internal/tongue/bone
	name = "lingual bone"
	desc = "Apparently skeletons alter the sounds they produce through oscillation of their teeth, hence their characteristic rattling."
	icon_state = "tonguebone"
	attack_verb = list("bitten", "chattered", "chomped", "enamelled", "boned")
	slot = "lingual bone"

/obj/item/organ/internal/tongue/bone/plasmaman
	name = "lingual plasma-infused bone"
	desc = "Like animated skeletons, Plasmamen vibrate their teeth in order to produce speech."
	icon_state = "tongueplasma"
	modifies_speech = FALSE
	slot = "lingual bone"

/obj/item/organ/internal/tongue/robot
	name = "vox-grate"
	desc = "A voice synthesizer that can interface with humans, vulpkanines, tajarans, slimepeople, skrells, unathi and voxes." // Yes, rename was inspired by 40K.
	icon_state = "tongue_robot"
	attack_verb = list("beeped", "booped")
	speech_verb = "states"
	ask_verb = "queries"
	exclaim_verb = list("announces","declares")
	var/list/languages_possible_alien = list(
		/datum/language/binary,
		/datum/language/nucleation
		)
/obj/item/organ/internal/tongue/robot/mechanicus
	name = "noosphere transmitter"
	desc = "An advanced voice synthesizer that can interface with humans, vulpkanines, tajarans, slimepeople, skrells, unathi and voxes, also connected to encoded data network of MIT, by the name of Noosphere." // Yes, robotic hivemind.
	icon_state = "tongue_robot"
	speech_verb = "states"
	ask_verb = "queries"
	exclaim_verb = list("announces","declares")
	attack_verb = list("beeped", "booped")
	languages_possible_alien = list(
			/datum/language/linguatechnis,
			/datum/language/binary,
			/datum/language/nucleation
			)

/obj/item/organ/internal/tongue/robot/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base += typecacheof(/datum/language/binary) + typecacheof(/datum/language/trinary)

/obj/item/organ/internal/tongue/robot/emp_act(severity)
	owner.emote("buzz")
	to_chat(owner, "<span class='warning'>Alert: Vox-grate malfunction.</span>")

/obj/item/organ/internal/tongue/snail
	name = "snailtongue"
	modifies_speech = TRUE

/obj/item/organ/internal/tongue/nucleation
	name = "gamma-electric resonator"
	desc = "A sophisticated nucleation organ, capable of synthesising speech via electrical and radiation discharge of supermatter crystals."
	icon_state = "electrotongue"
	speech_verb = list("cracks","crackles")
	attack_verb = list("shocked", "jolted", "zapped")
	slot = "gamma-electric resonator"

/obj/item/organ/internal/tongue/nucleation/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base += typecacheof(/datum/language/nucleation)

/obj/item/organ/internal/tongue/drask
	name = "resonant crystal"
	desc = "A sophisticated drask organ, capable of synthesising speech via light friction of Drask's lithoidic mouth crystals."
	icon_state = "drask-crystal"
	speech_verb = list("cracks","crackles")
	slot = "resonant crystal"

/obj/item/organ/internal/tongue/drask/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base += typecacheof(/datum/language/drask)

/obj/item/organ/internal/tongue/diona
	name = "cortical communicator"
	desc = "A sophisticated dionea organ, capable of synthesising speech via cortex frictions."
	speech_verb = "chirps"
	icon_state = "tonguewood"

/obj/item/organ/internal/tongue/diona/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base += typecacheof(/datum/language/diona)

/obj/item/organ/internal/tongue/vox
	name = "bird tongue"
	desc = "A long and narrow vox tongue, typical for birds."
	speech_verb = "chirps"
	icon_state = "tonguenormal"

/obj/item/organ/internal/tongue/skrell
	name = "skrell tongue"
	desc = "A long and slippery skrell tongue, covered with watery slime."
	speech_verb = list("blorbles","blobs")
	icon_state = "tongueslime"

/obj/item/organ/internal/tongue/slime
	name = "slime tongue"
	speech_verb = list("blorbles","blobs","plops")
	ask_verb = "bubbles"
	desc = "A slimy tongue, made of green slime."
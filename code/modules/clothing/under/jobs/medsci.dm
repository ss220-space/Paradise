/*
 * Science
 */
/obj/item/clothing/under/rank/research_director
	name = "research director's jumpsuit"
	desc = "It's a jumpsuit worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	icon_state = "director"
	item_state = "g_suit"
	item_color = "director"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 10, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 35)

/obj/item/clothing/under/rank/scientist
	name = "scientist's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has markings that denote the wearer as a scientist."
	icon_state = "toxins"
	item_state = "w_suit"
	item_color = "toxinswhite"
	permeability_coefficient = 0.50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/under/rank/scientist/skirt
	name = "scientist's jumpskirt"
	icon_state = "sciencewhitef"
	item_color = "sciencewhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/scientist/student
	name = "scientist student jumpsuit"
	icon_state = "student_s"
	item_color = "student"

/obj/item/clothing/under/rank/scientist/student/skirt
	name = "scientist student jumpskirt"
	icon_state = "studentf_s"
	item_color = "studentf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/scientist/student/assistant
	name = "scientist assistant jumpsuit"
	icon_state = "sci_ass_s"
	item_color = "sci_ass"

/obj/item/clothing/under/rank/scientist/student/assistant/skirt
	name = "scientist assistant jumpskirt"
	icon_state = "sci_ass_f_s"
	item_color = "sci_ass_f"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/chemist
	name = "chemist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a chemist rank stripe on it."
	icon_state = "chemistry"
	item_state = "w_suit"
	item_color = "chemistrywhite"
	permeability_coefficient = 0.50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 50, "acid" = 65)

/obj/item/clothing/under/rank/chemist/skirt
	name = "chemist's jumpskirt"
	icon_state = "chemistrywhitef"
	item_color = "chemistrywhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/*
 * Medical
 */
/obj/item/clothing/under/rank/chief_medical_officer
	name = "chief medical officer's jumpsuit"
	desc = "It's a jumpsuit worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmo"
	item_state = "w_suit"
	item_color = "cmo"
	permeability_coefficient = 0.50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/under/rank/chief_medical_officer/skirt
	name = "chief medical officer's jumpskirt"
	desc = "It's a jumpskirt worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmof"
	item_color = "cmof"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/geneticist
	name = "geneticist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a genetics rank stripe on it."
	icon_state = "genetics"
	item_state = "w_suit"
	item_color = "geneticswhite"
	permeability_coefficient = 0.50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/under/rank/geneticist/skirt
	name = "geneticist's jumpskirt"
	icon_state = "geneticswhitef"
	item_color = "geneticswhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/virologist
	name = "virologist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a virologist rank stripe on it."
	icon_state = "virology"
	item_state = "w_suit"
	item_color = "virologywhite"
	permeability_coefficient = 0.50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/under/rank/virologist/skirt
	name = "virologist's jumpskirt"
	icon_state = "virologywhitef"
	item_color = "virologywhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/nursesuit
	name = "nurse's suit"
	desc = "It's a jumpsuit commonly worn by nursing staff in the medical department."
	icon_state = "nursesuit"
	item_state = "nursesuit"
	item_color = "nursesuit"
	permeability_coefficient = 0.50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/under/rank/nurse
	name = "nurse's dress"
	desc = "A dress commonly worn by the nursing staff in the medical department."
	icon_state = "nurse"
	item_state = "nurse"
	item_color = "nurse"
	permeability_coefficient = 0.50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/under/rank/orderly
	name = "orderly's uniform"
	desc = "A white suit to be worn by orderly people who love orderly things."
	icon_state = "orderly"
	item_state = "orderly"
	item_color = "orderly"
	permeability_coefficient = 0.50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/under/rank/medical
	name = "medical doctor's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel."
	icon_state = "medical"
	item_state = "w_suit"
	item_color = "medical"
	permeability_coefficient = 0.50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/under/rank/medical/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/medical/intern
	name = "intern jumpsuit"
	icon_state = "intern_s"
	item_color = "intern"

/obj/item/clothing/under/rank/medical/intern/skirt
	name = "intern jumpskirt"
	icon_state = "internf_s"
	item_color = "internf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/intern/assistant
	name = "medical assistant jumpsuit"
	icon_state = "med_ass_s"
	item_color = "med_ass"

/obj/item/clothing/under/rank/medical/intern/assistant/skirt
	name = "medical assistant jumpskirt"
	icon_state = "med_ass_f_s"
	item_color = "med_ass_f"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/skirt
	name = "medical doctor's jumpskirt"
	icon_state = "medicalf"
	item_color = "medicalf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/blue
	name = "medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in baby blue."
	icon_state = "scrubsblue"
	item_color = "scrubsblue"

/obj/item/clothing/under/rank/medical/green
	name = "medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in dark green."
	icon_state = "scrubsdarkgreen"
	item_color = "scrubsdarkgreen"

/obj/item/clothing/under/rank/medical/lightgreen
	name = "medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in green."
	icon_state = "scrubsgreen"
	item_color = "scrubsgreen"

/obj/item/clothing/under/rank/medical/purple
	name = "medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in deep purple."
	icon_state = "scrubspurple"
	item_color = "scrubspurple"

/obj/item/clothing/under/rank/medical/mortician
	name = "coroner's scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is as dark as an emo's poetry."
	icon_state = "scrubsblack"
	item_color = "scrubsblack"

//paramedic
/obj/item/clothing/under/rank/medical/paramedic
	name = "paramedic's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against biohazards and radiation. It has a cross on the chest denoting that the wearer is trained medical personnel."
	icon_state = "paramedic"
	item_state = "paramedic"
	item_color = "paramedic"
	permeability_coefficient = 0.50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 10, "fire" = 0, "acid" = 0)

/obj/item/clothing/under/rank/medical/paramedic/skirt
	name = "paramedic's jumpskirt"
	desc = "It's made of a special fiber that provides minor protection against biohazards and radiation blue jumpskirt. It has a cross on the chest denoting that the wearer is trained medical personnel."
	icon_state = "paramedicf"
	item_state = "paramedicf"
	item_color = "paramedicf"

/obj/item/clothing/under/rank/psych
	name = "psychiatrist's jumpsuit"
	desc = "A basic white jumpsuit. It has turqouise markings that denote the wearer as a psychiatrist."
	icon_state = "psych"
	item_state = "w_suit"
	item_color = "psych"

/obj/item/clothing/under/rank/psych/skirt
	name = "psychiatrist's jumpskirt"
	desc = "A basic white jumpskirt. It has turqouise markings that denote the wearer as a psychiatrist."
	icon_state = "psychf"
	item_state = "w_suit"
	item_color = "psychf"

/obj/item/clothing/under/rank/psych/turtleneck
	name = "psychologist's turtleneck"
	desc = "A turqouise turtleneck and a pair of dark blue slacks, belonging to a psychologist."
	icon_state = "psychturtle"
	item_state = "b_suit"
	item_color = "psychturtle"


/*
 * Medsci, unused (i think) stuff
 */
/obj/item/clothing/under/rank/geneticist_new
	name = "geneticist's jumpsuit"
	desc = "It's made of a special fiber which provides minor protection against biohazards."
	icon_state = "genetics_new"
	item_state = "w_suit"
	item_color = "genetics_new"
	permeability_coefficient = 0.50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/under/rank/chemist_new
	name = "chemist's jumpsuit"
	desc = "It's made of a special fiber which provides minor protection against biohazards."
	icon_state = "chemist_new"
	item_state = "w_suit"
	item_color = "chemist_new"
	permeability_coefficient = 0.50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 50, "acid" = 65)

/obj/item/clothing/under/rank/scientist_new
	name = "scientist's jumpsuit"
	desc = "Made of a special fiber that gives special protection against biohazards and small explosions."
	icon_state = "scientist_new"
	item_state = "w_suit"
	item_color = "scientist_new"
	permeability_coefficient = 0.50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/under/rank/virologist_new
	name = "virologist's jumpsuit"
	desc = "Made of a special fiber that gives increased protection against biohazards."
	icon_state = "virologist_new"
	item_state = "w_suit"
	item_color = "virologist_new"
	permeability_coefficient = 0.50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

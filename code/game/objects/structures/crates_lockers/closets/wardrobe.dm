/obj/structure/closet/wardrobe
	name = "wardrobe"
	desc = "Это устройство для хранения стандартной одежды Нанотрейзен."

/obj/structure/closet/wardrobe/get_ru_names()
    return list(
        NOMINATIVE = "гардероб",
        GENITIVE = "гардероба",
        DATIVE = "гардеробу",
        ACCUSATIVE = "гардероб",
        INSTRUMENTAL = "гардеробом",
        PREPOSITIONAL = "гардеробе",
    )

/obj/structure/closet/wardrobe/generic
	// Identical to the base wardrobe, aside from containing some stuff.

/obj/structure/closet/wardrobe/generic/populate_contents()
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/mask/bandana/blue(src)
	new /obj/item/clothing/mask/bandana/blue(src)
	new /obj/item/clothing/mask/bandana/blue(src)
	new /obj/item/clothing/shoes/color/brown(src)
	new /obj/item/clothing/shoes/color/brown(src)
	new /obj/item/clothing/shoes/color/brown(src)

/obj/structure/closet/wardrobe/red
	name = "security wardrobe"
	icon_state = "secward"

/obj/structure/closet/wardrobe/red/get_ru_names()
    return list(
        NOMINATIVE = "гардероб службы безопасности",
        GENITIVE = "гардероба службы безопасности",
        DATIVE = "гардеробу службы безопасности",
        ACCUSATIVE = "гардероб службы безопасности",
        INSTRUMENTAL = "гардероб службы безопасности",
        PREPOSITIONAL = "гардеробе службы безопасности",
    )

/obj/structure/closet/wardrobe/red/populate_contents()
	new /obj/item/storage/backpack/duffel/security(src)
	new /obj/item/storage/backpack/duffel/security(src)
	new /obj/item/clothing/mask/bandana/red(src)
	new /obj/item/clothing/mask/bandana/red(src)
	new /obj/item/clothing/mask/bandana/red(src)
	new /obj/item/clothing/under/rank/security(src)
	new /obj/item/clothing/under/rank/security(src)
	new /obj/item/clothing/under/rank/security/formal(src)
	new /obj/item/clothing/under/rank/security/formal(src)
	new /obj/item/clothing/under/rank/security/formal(src)
	new /obj/item/clothing/under/rank/security/skirt(src)
	new /obj/item/clothing/under/rank/security/skirt(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/shoes/jackboots/jacksandals(src)
	new /obj/item/clothing/shoes/jackboots/jacksandals(src)
	new /obj/item/clothing/shoes/jackboots/jacksandals(src)
	new /obj/item/clothing/head/soft/sec(src)
	new /obj/item/clothing/head/soft/sec(src)
	new /obj/item/clothing/head/soft/sec(src)
	new /obj/item/clothing/head/beret/sec(src)
	new /obj/item/clothing/head/beret/sec(src)
	new /obj/item/clothing/head/beret/sec(src)
	new /obj/item/clothing/head/officer(src)
	new /obj/item/clothing/head/officer(src)
	new /obj/item/clothing/head/officer(src)

/obj/structure/closet/redcorp
	name = "corporate security wardrobe"
	custom_door_overlay = "red"

/obj/structure/closet/redcorp/get_ru_names()
    return list(
        NOMINATIVE = "корпоративный гардероб службы безопасности",
        GENITIVE = "корпоративного гардероба службы безопасности",
        DATIVE = "корпоративному гардеробу службы безопасности",
        ACCUSATIVE = "корпоративный гардероб службы безопасности",
        INSTRUMENTAL = "корпоративным гардеробом службы безопасности",
        PREPOSITIONAL = "корпоративном гардеробе службы безопасности",
    )

/obj/structure/closet/redcorp/populate_contents()
	new /obj/item/clothing/under/rank/security/corp(src)
	new /obj/item/clothing/under/rank/security/corp(src)
	new /obj/item/clothing/under/rank/security/corp(src)
	new /obj/item/clothing/head/soft/sec/corp(src)
	new /obj/item/clothing/head/soft/sec/corp(src)
	new /obj/item/clothing/head/soft/sec/corp(src)
	new /obj/item/clothing/head/beret/sec/black(src)
	new /obj/item/clothing/head/beret/sec/black(src)
	new /obj/item/clothing/head/beret/sec/black(src)

/obj/structure/closet/wardrobe/pink
	name = "pink wardrobe"
	custom_door_overlay = "pink"

/obj/structure/closet/wardrobe/pink/get_ru_names()
    return list(
        NOMINATIVE = "розовый гардероб",
        GENITIVE = "розового гардероба",
        DATIVE = "розовому гардеробу",
        ACCUSATIVE = "розовый гардероб",
        INSTRUMENTAL = "розовым гардеробом",
        PREPOSITIONAL = "розовом гардеробе",
    )

/obj/structure/closet/wardrobe/pink/populate_contents()
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/shoes/color/brown(src)
	new /obj/item/clothing/shoes/color/brown(src)
	new /obj/item/clothing/shoes/color/brown(src)

/obj/structure/closet/wardrobe/black
	name = "black wardrobe"
	custom_door_overlay = "black"

/obj/structure/closet/wardrobe/black/get_ru_names()
    return list(
        NOMINATIVE = "чёрный гардероб",
        GENITIVE = "чёрного гардероба",
        DATIVE = "чёрному гардеробу",
        ACCUSATIVE = "чёрный гардероб",
        INSTRUMENTAL = "чёрным гардеробом",
        PREPOSITIONAL = "чёрном гардеробе",
    )

/obj/structure/closet/wardrobe/black/populate_contents()
	new /obj/item/clothing/under/color/black(src)
	new /obj/item/clothing/under/color/black(src)
	new /obj/item/clothing/under/color/black(src)
	if(prob(25))
		new /obj/item/clothing/suit/jacket/leather(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/head/soft/black(src)

/obj/structure/closet/wardrobe/green
	name = "green wardrobe"
	custom_door_overlay = "green"

/obj/structure/closet/wardrobe/green/get_ru_names()
    return list(
        NOMINATIVE = "зелёный гардероб",
        GENITIVE = "зелёного гардероба",
        DATIVE = "зелёному гардеробу",
        ACCUSATIVE = "зелёный гардероб",
        INSTRUMENTAL = "зелёным гардеробом",
        PREPOSITIONAL = "зелёном гардеробе",
    )

/obj/structure/closet/wardrobe/green/populate_contents()
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/clothing/shoes/color/black(src)

/obj/structure/closet/wardrobe/xenos
	name = "xenos wardrobe"
	custom_door_overlay = "green"

/obj/structure/closet/wardrobe/xenos/get_ru_names()
    return list(
        NOMINATIVE = "гардероб ксеносов",
        GENITIVE = "гардероба ксеносов",
        DATIVE = "гардеробу ксеносов",
        ACCUSATIVE = "гардероб ксеносов",
        INSTRUMENTAL = "гардеробом ксеносов",
        PREPOSITIONAL = "гардеробе ксеносов",
    )

/obj/structure/closet/wardrobe/xenos/populate_contents()
	new /obj/item/clothing/neck/mantle/unathi(src)
	new /obj/item/clothing/suit/unathi/robe(src)
	new /obj/item/clothing/shoes/sandal(src)
	new /obj/item/clothing/shoes/sandal(src)
	new /obj/item/clothing/shoes/sandal(src)
	new /obj/item/clothing/shoes/footwraps(src)
	new /obj/item/clothing/shoes/footwraps(src)
	new /obj/item/clothing/shoes/footwraps(src)

/obj/structure/closet/wardrobe/orange
	name = "prison wardrobe"
	desc = "Это устройство для хранения стандартной формы заключённых Нанотрейзен."
	custom_door_overlay = "orange"

/obj/structure/closet/wardrobe/orange/get_ru_names()
    return list(
        NOMINATIVE = "гардероб заключённого",
        GENITIVE = "гардероба заключённого",
        DATIVE = "гардеробу заключённого",
        ACCUSATIVE = "гардероб заключённого",
        INSTRUMENTAL = "гардеробом заключённого",
        PREPOSITIONAL = "гардеробе заключённого",
    )

/obj/structure/closet/wardrobe/orange/populate_contents()
	new /obj/item/clothing/under/color/orange/prison(src)
	new /obj/item/clothing/under/color/orange/prison(src)
	new /obj/item/clothing/under/color/orange/prison(src)
	new /obj/item/clothing/shoes/color/orange/prison(src)
	new /obj/item/clothing/shoes/color/orange/prison(src)
	new /obj/item/clothing/shoes/color/orange/prison(src)

/obj/structure/closet/wardrobe/yellow
	name = "yellow wardrobe"
	custom_door_overlay = "yellow"

/obj/structure/closet/wardrobe/yellow/get_ru_names()
    return list(
        NOMINATIVE = "жёлтый гардероб",
        GENITIVE = "жёлтого гардероба",
        DATIVE = "жёлтому гардеробу",
        ACCUSATIVE = "жёлтый гардероб",
        INSTRUMENTAL = "жёлтым гардеробом",
        PREPOSITIONAL = "жёлтом гардеробе",
    )

/obj/structure/closet/wardrobe/yellow/populate_contents()
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/shoes/color/orange(src)
	new /obj/item/clothing/shoes/color/orange(src)
	new /obj/item/clothing/shoes/color/orange(src)

/obj/structure/closet/wardrobe/atmospherics_yellow
	name = "atmospherics wardrobe"
	custom_door_overlay = "atmostech"

/obj/structure/closet/wardrobe/atmospherics_yellow/get_ru_names()
    return list(
        NOMINATIVE = "гардероб атмосферного техника",
        GENITIVE = "гардероба атмосферного техника",
        DATIVE = "гардеробу атмосферного техника",
        ACCUSATIVE = "гардероб атмосферного техника",
        INSTRUMENTAL = "гардеробом атмосферного техника",
        PREPOSITIONAL = "гардеробе атмосферного техника",
    )

/obj/structure/closet/wardrobe/atmospherics_yellow/populate_contents()
	new /obj/item/clothing/under/rank/atmospheric_technician(src)
	new /obj/item/clothing/under/rank/atmospheric_technician(src)
	new /obj/item/clothing/under/rank/atmospheric_technician(src)
	new /obj/item/clothing/under/rank/atmospheric_technician/skirt(src)
	new /obj/item/clothing/under/rank/atmospheric_technician/skirt(src)
	new /obj/item/clothing/under/rank/atmospheric_technician/skirt(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/head/hardhat/red(src)
	new /obj/item/clothing/head/hardhat/red(src)
	new /obj/item/clothing/head/hardhat/red(src)
	new /obj/item/clothing/head/beret/atmos(src)
	new /obj/item/clothing/head/beret/atmos(src)
	new /obj/item/clothing/head/beret/atmos(src)

/obj/structure/closet/wardrobe/engineering_yellow
	name = "engineering wardrobe"
	custom_door_overlay = "engineer"

/obj/structure/closet/wardrobe/engineering_yellow/get_ru_names()
    return list(
        NOMINATIVE = "гардероб инженера",
        GENITIVE = "гардероба инженера",
        DATIVE = "гардеробу инженера",
        ACCUSATIVE = "гардероб инженера",
        INSTRUMENTAL = "гардеробом инженера",
        PREPOSITIONAL = "гардеробе инженера",
    )

/obj/structure/closet/wardrobe/engineering_yellow/populate_contents()
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/under/rank/engineer/skirt(src)
	new /obj/item/clothing/under/rank/engineer/skirt(src)
	new /obj/item/clothing/under/rank/engineer/skirt(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/head/hardhat(src)
	new /obj/item/clothing/head/hardhat(src)
	new /obj/item/clothing/head/hardhat(src)
	new /obj/item/clothing/head/beret/eng(src)
	new /obj/item/clothing/head/beret/eng(src)
	new /obj/item/clothing/head/beret/eng(src)

/obj/structure/closet/wardrobe/trainee_yellow
	name = "trainee wardrobe"
	custom_door_overlay = "engineer"

/obj/structure/closet/wardrobe/trainee_yellow/get_ru_names()
    return list(
        NOMINATIVE = "гардероб стажёра",
        GENITIVE = "гардероба стажёра",
        DATIVE = "гардеробу стажёра",
        ACCUSATIVE = "гардероб стажёра",
        INSTRUMENTAL = "гардеробом стажёра",
        PREPOSITIONAL = "гардеробе стажёра",
    )

/obj/structure/closet/wardrobe/trainee_yellow/populate_contents()
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/under/rank/engineer/skirt(src)
	new /obj/item/clothing/under/rank/engineer/skirt(src)
	new /obj/item/clothing/under/rank/engineer/trainee/assistant(src)
	new /obj/item/clothing/under/rank/engineer/trainee/assistant(src)
	new /obj/item/clothing/under/rank/engineer/trainee/assistant/skirt(src)
	new /obj/item/clothing/under/rank/engineer/trainee/assistant/skirt(src)
	new /obj/item/clothing/suit/storage/hazardvest(src)
	new /obj/item/clothing/suit/storage/hazardvest(src)
	new /obj/item/clothing/suit/storage/hazardvest(src)
	new /obj/item/clothing/suit/storage/hazardvest(src)
	new /obj/item/clothing/head/hardhat/orange(src)
	new /obj/item/clothing/head/hardhat/orange(src)
	new /obj/item/clothing/head/hardhat/orange(src)
	new /obj/item/clothing/head/hardhat/orange(src)
	new /obj/item/storage/backpack/satchel_eng(src)
	new /obj/item/storage/backpack/satchel_eng(src)
	new /obj/item/storage/backpack/satchel_eng(src)
	new /obj/item/storage/backpack/satchel_eng(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)

/obj/structure/closet/wardrobe/white
	name = "white wardrobe"
	custom_door_overlay = "white"

/obj/structure/closet/wardrobe/white/get_ru_names()
    return list(
        NOMINATIVE = "белый гардероб",
        GENITIVE = "белого гардероба",
        DATIVE = "белому гардеробу",
        ACCUSATIVE = "белый гардероб",
        INSTRUMENTAL = "белым гардеробом",
        PREPOSITIONAL = "белом гардеробе",
    )

/obj/structure/closet/wardrobe/white/populate_contents()
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)

/obj/structure/closet/wardrobe/medical_white
	name = "medical doctor's wardrobe"
	custom_door_overlay = "white"

/obj/structure/closet/wardrobe/medical_white/get_ru_names()
    return list(
        NOMINATIVE = "гардероб врача",
        GENITIVE = "гардероба врача",
        DATIVE = "гардеробу врача",
        ACCUSATIVE = "гардероб врача",
        INSTRUMENTAL = "гардеробом врача",
        PREPOSITIONAL = "гардеробе врача",
    )

/obj/structure/closet/wardrobe/medical_white/populate_contents()
	new /obj/item/clothing/under/rank/nursesuit (src)
	new /obj/item/clothing/head/nursehat (src)
	new /obj/item/clothing/under/rank/nurse(src)
	new /obj/item/clothing/under/rank/orderly(src)
	new /obj/item/clothing/suit/storage/fr_jacket(src)
	new /obj/item/clothing/suit/storage/fr_jacket(src)
	new /obj/item/clothing/suit/storage/fr_jacket(src)
	new /obj/item/clothing/under/rank/medical/blue(src)
	new /obj/item/clothing/head/surgery/blue(src)
	new /obj/item/clothing/under/rank/medical/green(src)
	new /obj/item/clothing/head/surgery/green(src)
	new /obj/item/clothing/under/rank/medical/purple(src)
	new /obj/item/clothing/under/rank/medical/skirt(src)
	new /obj/item/clothing/under/rank/medical/skirt(src)
	new /obj/item/clothing/head/surgery/purple(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/clothing/under/rank/medical/intern(src)
	new /obj/item/clothing/under/rank/medical/intern(src)
	new /obj/item/clothing/under/rank/medical/intern/skirt(src)
	new /obj/item/clothing/under/rank/medical/intern/skirt(src)

/obj/structure/closet/wardrobe/pjs
	name = "Pajama wardrobe"
	custom_door_overlay = "white"

/obj/structure/closet/wardrobe/pjs/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для пижамы",
        GENITIVE = "шкафчика для пижамы",
        DATIVE = "шкафчику для пижамы",
        ACCUSATIVE = "шкафчик для пижамы",
        INSTRUMENTAL = "шкафчиком для пижамы",
        PREPOSITIONAL = "шкафчике для пижамы",
    )

/obj/structure/closet/wardrobe/pjs/populate_contents()
	new /obj/item/clothing/under/pj/red(src)
	new /obj/item/clothing/under/pj/red(src)
	new /obj/item/clothing/under/pj/blue(src)
	new /obj/item/clothing/under/pj/blue(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/slippers(src)
	new /obj/item/clothing/shoes/slippers(src)

/obj/structure/closet/wardrobe/toxins_white
	name = "toxins wardrobe"
	custom_door_overlay = "white"

/obj/structure/closet/wardrobe/toxins_white/get_ru_names()
    return list(
        NOMINATIVE = "гардероб учёного",
        GENITIVE = "гардероба учёного",
        DATIVE = "гардеробу учёного",
        ACCUSATIVE = "гардероб учёного",
        INSTRUMENTAL = "гардеробом учёного",
        PREPOSITIONAL = "гардеробе учёного",
    )

/obj/structure/closet/wardrobe/toxins_white/populate_contents()
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/under/rank/scientist/skirt(src)
	new /obj/item/clothing/under/rank/scientist/skirt(src)
	new /obj/item/clothing/under/rank/scientist/skirt(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/slippers
	new /obj/item/clothing/shoes/slippers
	new /obj/item/clothing/shoes/slippers

/obj/structure/closet/wardrobe/student
	name = "students wardrobe"
	custom_door_overlay = "pink"

/obj/structure/closet/wardrobe/student/get_ru_names()
    return list(
        NOMINATIVE = "гардероб студента",
        GENITIVE = "гардероба студента",
        DATIVE = "гардеробу студента",
        ACCUSATIVE = "гардероб студента",
        INSTRUMENTAL = "гардеробом студента",
        PREPOSITIONAL = "гардеробе студента",
    )

/obj/structure/closet/wardrobe/student/populate_contents()
	new /obj/item/clothing/under/rank/scientist/student(src)
	new /obj/item/clothing/under/rank/scientist/student(src)
	new /obj/item/clothing/under/rank/scientist/student/skirt(src)
	new /obj/item/clothing/under/rank/scientist/student/skirt(src)
	new /obj/item/clothing/under/rank/scientist/student/assistant(src)
	new /obj/item/clothing/under/rank/scientist/student/assistant(src)
	new /obj/item/clothing/under/rank/scientist/student/assistant/skirt(src)
	new /obj/item/clothing/under/rank/scientist/student/assistant/skirt(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/storage/backpack/satchel_tox(src)
	new /obj/item/storage/backpack/satchel_tox(src)
	new /obj/item/storage/backpack/satchel_tox(src)
	new /obj/item/storage/backpack/satchel_tox(src)

/obj/structure/closet/wardrobe/robotics_black
	name = "robotics wardrobe"
	icon_state = "robo"

/obj/structure/closet/wardrobe/robotics_black/get_ru_names()
    return list(
        NOMINATIVE = "гардероб роботехника",
        GENITIVE = "гардероба роботехника",
        DATIVE = "гардеробу роботехника",
        ACCUSATIVE = "гардероб роботехника",
        INSTRUMENTAL = "гардеробом роботехника",
        PREPOSITIONAL = "гардеробе роботехника",
    )

/obj/structure/closet/wardrobe/robotics_black/populate_contents()
	new /obj/item/clothing/under/rank/roboticist(src)
	new /obj/item/clothing/under/rank/roboticist(src)
	new /obj/item/clothing/under/rank/roboticist/skirt(src)
	new /obj/item/clothing/under/rank/roboticist/skirt(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/head/soft/black(src)

/obj/structure/closet/wardrobe/chemistry_white
	name = "chemistry wardrobe"
	icon_state = "chem"

/obj/structure/closet/wardrobe/chemistry_white/get_ru_names()
    return list(
        NOMINATIVE = "гардероб химика",
        GENITIVE = "гардероба химика",
        DATIVE = "гардеробу химика",
        ACCUSATIVE = "гардероб химика",
        INSTRUMENTAL = "гардеробом химика",
        PREPOSITIONAL = "гардеробе химика",
    )

/obj/structure/closet/wardrobe/chemistry_white/populate_contents()
	new /obj/item/clothing/under/rank/chemist(src)
	new /obj/item/clothing/under/rank/chemist(src)
	new /obj/item/clothing/under/rank/chemist/skirt(src)
	new /obj/item/clothing/under/rank/chemist/skirt(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/suit/storage/labcoat/chemist(src)
	new /obj/item/clothing/suit/storage/labcoat/chemist(src)
	new /obj/item/storage/backpack/chemistry(src)
	new /obj/item/storage/backpack/chemistry(src)
	new /obj/item/storage/backpack/satchel_chem(src)
	new /obj/item/storage/backpack/satchel_chem(src)
	new /obj/item/storage/bag/chemistry(src)
	new /obj/item/storage/bag/chemistry(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/mask/gas(src)

/obj/structure/closet/wardrobe/genetics_white
	name = "genetics wardrobe"
	custom_door_overlay = "white"

/obj/structure/closet/wardrobe/genetics_white/get_ru_names()
    return list(
        NOMINATIVE = "гардероб генетика",
        GENITIVE = "гардероба генетика",
        DATIVE = "гардеробу генетика",
        ACCUSATIVE = "гардероб генетика",
        INSTRUMENTAL = "гардеробом генетика",
        PREPOSITIONAL = "гардеробе генетика",
    )

/obj/structure/closet/wardrobe/genetics_white/populate_contents()
	new /obj/item/clothing/under/rank/geneticist(src)
	new /obj/item/clothing/under/rank/geneticist(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/suit/storage/labcoat/genetics(src)
	new /obj/item/clothing/suit/storage/labcoat/genetics(src)
	new /obj/item/storage/backpack/genetics(src)
	new /obj/item/storage/backpack/genetics(src)
	new /obj/item/storage/backpack/satchel_gen(src)
	new /obj/item/storage/backpack/satchel_gen(src)

/obj/structure/closet/wardrobe/virology_white
	name = "virology wardrobe"
	icon_state = "vir"

/obj/structure/closet/wardrobe/virology_white/get_ru_names()
    return list(
        NOMINATIVE = "гардероб вирусолога",
        GENITIVE = "гардероба вирусолога",
        DATIVE = "гардеробу вирусолога",
        ACCUSATIVE = "гардероб вирусолога",
        INSTRUMENTAL = "гардеробом вирусолога",
        PREPOSITIONAL = "гардеробе вирусолога",
    )

/obj/structure/closet/wardrobe/virology_white/populate_contents()
	new /obj/item/clothing/under/rank/virologist(src)
	new /obj/item/clothing/under/rank/virologist(src)
	new /obj/item/clothing/under/rank/virologist/skirt(src)
	new /obj/item/clothing/under/rank/virologist/skirt(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/suit/storage/labcoat/virologist(src)
	new /obj/item/clothing/suit/storage/labcoat/virologist(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/storage/backpack/virology(src)
	new /obj/item/storage/backpack/virology(src)
	new /obj/item/storage/backpack/satchel_vir(src)
	new /obj/item/storage/backpack/satchel_vir(src)

/obj/structure/closet/wardrobe/medic_white
	name = "medical wardrobe"
	custom_door_overlay = "white"

/obj/structure/closet/wardrobe/medic_white/get_ru_names()
    return list(
        NOMINATIVE = "медицинский гардероб",
        GENITIVE = "медицинского гардероба",
        DATIVE = "медицинскому гардеробу",
        ACCUSATIVE = "медицинский гардероб",
        INSTRUMENTAL = "медицинским гардеробом",
        PREPOSITIONAL = "медицинском гардеробе",
    )

/obj/structure/closet/wardrobe/medic_white/populate_contents()
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/under/rank/medical/skirt(src)
	new /obj/item/clothing/under/rank/medical/skirt(src)
	new /obj/item/clothing/under/rank/medical/blue(src)
	new /obj/item/clothing/under/rank/medical/green(src)
	new /obj/item/clothing/under/rank/medical/purple(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/under/medigown(src)
	new /obj/item/clothing/head/headmirror(src)
	new /obj/item/clothing/head/headmirror(src)

/obj/structure/closet/wardrobe/intern_white
	name = "intern wardrobe"
	custom_door_overlay = "white"

/obj/structure/closet/wardrobe/intern_white/get_ru_names()
    return list(
        NOMINATIVE = "гардероб интерна",
        GENITIVE = "гардероба интерна",
        DATIVE = "гардеробу интерна",
        ACCUSATIVE = "гардероб интерна",
        INSTRUMENTAL = "гардеробом интерна",
        PREPOSITIONAL = "гардеробе интерна",
    )

/obj/structure/closet/wardrobe/intern_white/populate_contents()
	new /obj/item/clothing/under/rank/medical/intern(src)
	new /obj/item/clothing/under/rank/medical/intern(src)
	new /obj/item/clothing/under/rank/medical/intern/skirt(src)
	new /obj/item/clothing/under/rank/medical/intern/skirt(src)
	new /obj/item/clothing/under/rank/medical/intern/assistant(src)
	new /obj/item/clothing/under/rank/medical/intern/assistant(src)
	new /obj/item/clothing/under/rank/medical/intern/assistant/skirt(src)
	new /obj/item/clothing/under/rank/medical/intern/assistant/skirt(src)
	new /obj/item/clothing/under/rank/medical/lightgreen
	new /obj/item/clothing/under/rank/medical/lightgreen
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/storage/backpack/satchel_med(src)

/obj/structure/closet/wardrobe/grey
	name = "grey wardrobe"
	custom_door_overlay = "grey"

/obj/structure/closet/wardrobe/grey/get_ru_names()
    return list(
        NOMINATIVE = "серый гардероб",
        GENITIVE = "серого гардероба",
        DATIVE = "серому гардеробу",
        ACCUSATIVE = "серый гардероб",
        INSTRUMENTAL = "серым гардеробом",
        PREPOSITIONAL = "сером гардеробе",
    )


/obj/structure/closet/wardrobe/grey/populate_contents()
	new /obj/item/clothing/under/color/grey(src)
	new /obj/item/clothing/under/color/grey(src)
	new /obj/item/clothing/under/color/grey(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/clothing/head/soft/grey(src)
	new /obj/item/clothing/head/soft/grey(src)
	new /obj/item/clothing/head/soft/grey(src)
	if(prob(50))
		new /obj/item/storage/backpack/duffel(src)
	if(prob(40))
		new /obj/item/clothing/under/assistantformal(src)
	if(prob(40))
		new /obj/item/clothing/under/assistantformal(src)

/obj/structure/closet/wardrobe/mixed
	name = "mixed wardrobe"
	custom_door_overlay = "mixed"

/obj/structure/closet/wardrobe/mixed/get_ru_names()
    return list(
        NOMINATIVE = "смешанный гардероб",
        GENITIVE = "смешанного гардероба",
        DATIVE = "смешанному гардеробу",
        ACCUSATIVE = "смешанный гардероб",
        INSTRUMENTAL = "смешанным гардеробом",
        PREPOSITIONAL = "смешанном гардеробе",
    )

/obj/structure/closet/wardrobe/mixed/populate_contents()
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/under/color/orange(src)
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/under/dress/plaid_blue(src)
	new /obj/item/clothing/under/dress/plaid_red(src)
	new /obj/item/clothing/under/dress/plaid_purple(src)
	new /obj/item/clothing/shoes/color/blue(src)
	new /obj/item/clothing/shoes/color/yellow(src)
	new /obj/item/clothing/shoes/color/green(src)
	new /obj/item/clothing/shoes/color/orange(src)
	new /obj/item/clothing/shoes/color/purple(src)
	new /obj/item/clothing/shoes/leather(src)

/obj/structure/closet/wardrobe/coroner
	name = "coroner wardrobe"
	icon_state = "coroner"

/obj/structure/closet/wardrobe/coroner/get_ru_names()
    return list(
        NOMINATIVE = "гардероб патологоанатома",
        GENITIVE = "гардероба патологоанатома",
        DATIVE = "гардеробу патологоанатома",
        ACCUSATIVE = "гардероб патологоанатома",
        INSTRUMENTAL = "гардеробом патологоанатома",
        PREPOSITIONAL = "гардеробе патологоанатома",
    )

/obj/structure/closet/wardrobe/coroner/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/storage/backpack/duffel/medical(src)
	new /obj/item/clothing/suit/storage/labcoat/mortician(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/under/rank/medical/mortician(src)
	new /obj/item/clothing/head/surgery/black(src)

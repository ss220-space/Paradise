/obj/item/clothing/under/rank/cargo
	icon = 'icons/clothing/uniforms/cargo.dmi'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/uniform.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/vulpkanin/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi',
	)

/obj/item/clothing/under/rank/qm
	name = "quartermaster's jumpsuit"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"
	item_state = "lb_suit"
	item_color = "qm"

/obj/item/clothing/under/rank/cargo/qm/alt
	name = "quartermaster's dress"
	desc = "Dress for conducting bureaucracy and working with supplies, convenience and rigor in a single whole."
	icon_state = "qm_new"
	item_state = "clb_suit"
	item_color = "qm_new"

/obj/item/clothing/under/rank/cargo/qm/skirt
	name = "quartermaster's jumpskirt"
	desc = "It's a jumpskirt worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qmf"
	item_color = "qmf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/cargo/qm/official
	name = "quartermaster uniform"
	desc = "Pretty stylish for common NT supply workers uniform who are ready to check your request."
	icon_state = "qmu"
	item_state = "qmu"
	item_color = "qmu"

/obj/item/clothing/under/rank/cargo/cargotech
	name = "cargo technician's jumpsuit"
	desc = "Shooooorts! They're comfy and easy to wear!"
	icon_state = "cargo"
	item_state = "lb_suit"

/obj/item/clothing/under/rank/cargo/cargotech/skirt
	name = "cargo technician's jumpskirt"
	desc = "Skirrrrrts! They're comfy and easy to wear!"
	icon_state = "cargof"
	item_color = "cargof"

/obj/item/clothing/under/rank/cargo/cargotech/alt
	name = "cargo technician's dress"
	desc = "Pretty good and convenient to work dress for cargo technicians."
	icon_state = "cargotech_new"
	item_state = "clb_suit"
	item_color = "cargotech_new"

/obj/item/clothing/under/rank/cargo/miner
	name = "shaft miner's jumpsuit"
	desc = "Стильный комбинезон с прочными подкладками. Покрыты тонким слоем грязи и пепла, \
			который, видимо, уже никогда не смоется."
	icon_state = "miner"
	item_state = "miner"
	item_color = "miner"

/obj/item/clothing/under/rank/cargo/miner/get_ru_names()
	return alist(
		NOMINATIVE = "шахтёрский комбинезон",
		GENITIVE = "шахтёрского комбинезона",
		DATIVE = "шахтёрскому комбинезону",
		ACCUSATIVE = "шахтёрский комбинезон",
		INSTRUMENTAL = "шахтёрским комбинезоном",
		PREPOSITIONAL = "шахтёрском комбинезоне"
	)

/obj/item/clothing/under/rank/cargo/miner/alt
	name = "shaft miner's sweater"
	desc = "Уютный рабочий свитер в старомодном стиле."
	icon_state = "miner_alt"
	item_state = "miner_alt"
	item_color = "miner_alt"

/obj/item/clothing/under/rank/cargo/miner/alt/get_ru_names()
	return alist(
		NOMINATIVE = "шахтёрский свитер",
		GENITIVE = "шахтёрского свитера",
		DATIVE = "шахтёрскому свитеру",
		ACCUSATIVE = "шахтёрский свитер",
		INSTRUMENTAL = "шахтёрским свитером",
		PREPOSITIONAL = "шахтёрском свитере"
	)

/obj/item/clothing/under/rank/cargo/miner/lavaland
	desc = "Зелёная униформа, созданная для работы в опасных условиях."
	icon_state = "explorer"
	item_state = "explorer"
	item_color = "explorer"
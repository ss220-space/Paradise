/obj/effect/spawner/lootdrop/seed_vault
	name = "seed vault seeds"
	lootcount = 1

	loot = list(/obj/item/reagent_containers/food/snacks/grown/mushroom/glowshroom/glowcap = 10,
				/obj/item/seeds/cherry/bomb = 10,
				/obj/item/seeds/berry/glow = 10,
				/obj/item/seeds/sunflower/moonflower = 8
				)

/obj/effect/mob_spawn/human/seed_vault
	name = "Сохранившийся террариум"
	desc = "Древняя машина, которая, кажется, использовалась для хранения растительных материалов. Стекла закрыты ковром из лозы."
	ru_names = list(
		NOMINATIVE = "сохранившийся террариум",
		GENITIVE = "сохранившегося террариума",
		DATIVE = "сохранившемуся террариуму",
		ACCUSATIVE = "сохранившийся террариум",
		INSTRUMENTAL = "сохранившимся террариумом",
		PREPOSITIONAL = "сохранившемся террариуме"
	)
	mob_name = "a lifebringer"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "terrarium"
	density = TRUE
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/diona/pod
	important_info = "Распространение Лозы \"Кудзу\" на территории Лаваленда запрещено правилами."
	description = "Вы - диона на Лаваленде с доступом к полному набору для ботаники. Идеально, чтобы спокойно экспериментировать с растениями."
	flavour_text = "Вы - разумная экосистема, пример мастерства над жизнью, которым обладали ваши создатели. Ваши мастера, столь же доброжелательные, сколь и могущественные, создали бесчисленные \
	хранилища семян и распространили их по всей вселенной на каждую планету, которую смогли нанести на карту. Вы находитесь в одном из таких хранилищ. Ваша цель — культивировать и распространять жизнь везде, где это возможно, \
	ожидая контакта от ваших создателей. Предполагаемое время последнего контакта: 5x10^3 тысячелетий назад."
	assignedrole = "Lifebringer"

/obj/effect/mob_spawn/human/seed_vault/special(mob/living/new_spawn)
	var/plant_name = pick("Tomato", "Potato", "Broccoli", "Carrot", "Ambrosia", "Pumpkin", "Ivy", "Kudzu", "Banana", "Moss", "Flower", "Bloom", "Root", "Bark", "Glowshroom", "Petal", "Leaf", \
	"Venus", "Sprout","Cocoa", "Strawberry", "Citrus", "Oak", "Cactus", "Pepper", "Juniper")
	new_spawn.rename_character(null, plant_name)

/obj/effect/mob_spawn/human/seed_vault/Destroy()
	new/obj/structure/fluff/empty_terrarium(get_turf(src))
	return ..()

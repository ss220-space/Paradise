//Contains wizard loadouts and associated unique spells

//Standard loadouts, which are meant to be suggestions for beginners. Should always be worth exactly 10 spell points, and only contain standard wizard spells/items.
/datum/spellbook_entry/loadout/mutant
	name = "Offense Focus : Mutant"
	desc = "Набор заклинаний, сфокусированный на заклинании Mutate как основном источнике урона, который обеспечивает защиту от оглушения, лазерные глаза и сильные удары. <br> \
 			Ethereal Jaunt и Blink обеспечивают  мобильность, в то время как Magic Missile и Disintegrate могут использоваться вместе для поражения опасных или ключевых целей. <br> \
 			Поскольку в этом наборе отсутствует какие-либо средства исцеления или воскрешения, вам следует быть осторожным, чтобы не пораниться. <br><br> \
 			</i> Даёт Mutate, Ethereal Jaunt, Blink, Magic Missile и Disintegrate.<i>"
	spells_path = list(/obj/effect/proc_holder/spell/genetic/mutate,
						/obj/effect/proc_holder/spell/ethereal_jaunt,
						/obj/effect/proc_holder/spell/turf_teleport/blink,
						/obj/effect/proc_holder/spell/projectile/magic_missile,
						/obj/effect/proc_holder/spell/touch/disintegrate
					)

/datum/spellbook_entry/loadout/lich
	name = "Defense Focus : Lich"
	desc = "Набор заклинаний, сфокусированный на заклинании Bind Soul, чтобы защитить вашу жизнь как лича и позволить использование более опасных атакующих заклинаний. <br> \
 			Ethereal Jaunt позволяет сбежать, Fireball и Rod Form - ваши атакующие заклинания, а Disable Tech и Greater Force Wall помогают выводить из строя оружие СБ или преграждать им путь. <br> \
 			Следует очень кропотливо относиться к предмету, который вы выбрали в качестве своей филактерии после использования Bind Soul, так как вы не сможете возродиться, если он будет уничтожен или вы отойдёте слишком далеко! <br><br> \
 			</i> Даёт Bind Soul, Ethereal Jaunt, Fireball, Rod Form, Disable Tech и Greater Force Wall.<i>"
	spells_path = list(/obj/effect/proc_holder/spell/lichdom,
						/obj/effect/proc_holder/spell/ethereal_jaunt,
						/obj/effect/proc_holder/spell/fireball,
						/obj/effect/proc_holder/spell/rod_form,
						/obj/effect/proc_holder/spell/emplosion/disable_tech,
						/obj/effect/proc_holder/spell/forcewall/greater
					)
	is_ragin_restricted = TRUE

/datum/spellbook_entry/loadout/wands
	name = "Utility Focus : Wands"
	desc = "В этот набор входит пояс с атакующими, защитными и прочими волшебными палочками. Количество зарядов палочек ограничено, но их можно частично перезарядить с помощью прилагаемого заклинания Charge. <br> \
 			Ethereal Jaunt и Blink обеспечивают мобильность, в то время как Disintegrate и Repulse могут быть использованы для уничтожения или отталкивания любого, кто приблизится к вам слишком близко. <br> \
 			Не отдавайте свои волшебные палочки экипажу станции, так как они чрезвычайно опасны. Помните, что палочку оживления можно использовать на себе для полного исцеления! <br><br> \
			</i> Даёт пояс с волшебными палочками, Charge, Ethereal Jaunt, Blink, Repulse и Disintegrate.<i>"
	items_path = list(/obj/item/storage/belt/wands/full)
	spells_path = list(/obj/effect/proc_holder/spell/charge,
						/obj/effect/proc_holder/spell/ethereal_jaunt,
						/obj/effect/proc_holder/spell/turf_teleport/blink,
						/obj/effect/proc_holder/spell/aoe/repulse,
						/obj/effect/proc_holder/spell/touch/disintegrate
					)

//Unique loadouts, which are more gimmicky. Should contain some unique spell or item that separates it from just buying standard wiz spells, and be balanced around a 10 spell point cost.
/datum/spellbook_entry/loadout/mimewiz
	name = "Silencio"
	desc = "...<br><br> \
		</i>В комплект входят Finger Gun, Invisible Greater Wall, Ethereal Jaunt, Blink, Teleport, Mime Malaise, Knock и Stop Time, а также мантия мима и трость.<i>"
	items_path = list(/obj/item/spellbook/oneuse/mime/fingergun,
					/obj/item/spellbook/oneuse/mime/greaterwall,
					/obj/item/clothing/suit/wizrobe/mime,
					/obj/item/clothing/head/wizard/mime,
					/obj/item/clothing/mask/gas/mime/wizard,
					/obj/item/clothing/shoes/sandal/marisa,
					/obj/item/cane,
					/obj/item/stack/tape_roll
				)
	spells_path = list(/obj/effect/proc_holder/spell/ethereal_jaunt,
					/obj/effect/proc_holder/spell/turf_teleport/blink,
					/obj/effect/proc_holder/spell/area_teleport/teleport,
					/obj/effect/proc_holder/spell/touch/mime_malaise,
					/obj/effect/proc_holder/spell/aoe/knock,
					/obj/effect/proc_holder/spell/aoe/conjure/timestop
				)
	category = "Уникальные"
	destroy_spellbook = TRUE

/datum/spellbook_entry/loadout/mimewiz/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(user.mind)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/mime/speak(null))
		user.mind.miming = TRUE
	..()

/datum/spellbook_entry/loadout/gunreaper
	name = "Gunslinging Reaper"
	desc = "Клонируемые снова и снова души на борту этой станции жаждут заслуженного отдыха.<br> \
 			Отправляйте их на встречу со своим божеством, раз за разом вдавливая спусковой крючок. <br> \
 			Вам, скорее всего, придётся добирать патроны из запасов станции. <br><br>\
 			</i> Даёт револьвер 357-го калибра, 4 спидлоадера, Ethereal Jaunt, Blink, Summon Item, No Clothes и Bind Soul, а также уникальный наряд.</i>"
	items_path = list(/obj/item/gun/projectile/revolver,
					/obj/item/ammo_box/speedloader/a357,
					/obj/item/ammo_box/speedloader/a357,
					/obj/item/ammo_box/speedloader/a357,
					/obj/item/ammo_box/speedloader/a357,
					/obj/item/clothing/under/syndicate
				)
	spells_path = list(/obj/effect/proc_holder/spell/ethereal_jaunt,
					/obj/effect/proc_holder/spell/turf_teleport/blink,
					/obj/effect/proc_holder/spell/summonitem,
					/obj/effect/proc_holder/spell/noclothes,
					/obj/effect/proc_holder/spell/lichdom/gunslinger
				)
	category = "Уникальные"
	destroy_spellbook = TRUE
	is_ragin_restricted = TRUE

/obj/effect/proc_holder/spell/lichdom/gunslinger/equip_lich(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/det_suit(H), ITEM_SLOT_CLOTH_OUTER)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), ITEM_SLOT_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(H), ITEM_SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(H), ITEM_SLOT_CLOTH_INNER)

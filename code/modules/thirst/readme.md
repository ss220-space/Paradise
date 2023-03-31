## Title: Thirst meter

### Description:

Add the thirst for mobs and requirements to drink water. Stay hydrated!

### Modified files:

code/__DEFINES/genetics.dm - added defines for thirst
code/__DEFINES/mobs.dm - added define for default thirst factor
code/game/gamemodes/changeling/powers/absorb.dm - added ability to gain water when changeling absorbs
code/game/gamemodes/spaceninja/ninja/suit/ninja_equipment_actions/ninja_status_read.dm - added additional hydration info for ninja HUD
code/game/gamemodes/wizard/spellbook.dm - smoke spell also decreases hydration
code/modules/flufftext/Hallucination.dm - additional hallucination option for being dehydrated
code/modules/mob/living/carbon/human/examine.dm - added additional examine text for dehydrated mobs
code/modules/mob/living/carbon/human/life.dm - removed hunger alerts when mobs aren't hungry
code/modules/mob/living/carbon/human/species/_species.dm - added slowdown modifier while dehydrated
code/modules/reagents/reagent_containers/glass_containers.dm - transferring dirty water between containers
code/modules/reagents/reagent_containers.dm - water from sinks is dirty


No Thirst species:
code/modules/mob/living/carbon/human/species/abductor.dm
code/modules/mob/living/carbon/human/species/golem.dm
code/modules/mob/living/carbon/human/species/machine.dm
code/modules/mob/living/carbon/human/species/plasmaman.dm
code/modules/mob/living/carbon/human/species/shadowling.dm
code/modules/mob/living/carbon/human/species/skeleton.dm
code/modules/mob/living/carbon/human/species/grey.dm
code/modules/mob/living/carbon/human/species/vox.dm

### Credits:

Larentoun - Owner

## Title: Pixel shifting for RP positioning

MODULE ID: PIXEL_SHIFT

### Description:

Adds the ability for living mobs to shift their sprite to fit an RP situation better (standing against a wall for example). Not appended to proc due to it being a busy proc

### Modified files:

code/game/objects/buckling.dm - unpixel_shift() on buckling
code/modules/mob/living/carbon/update_icons.dm - updated transform when pixel_x is different from 0
code/modules/mob/living/living.dm - unpixel_shift() on movement
code/modules/mob/mob_grab.dm - unpixel_shift() when grabbed
code/modules/mob/mob_movement.dm - pixel_shift()
code/controllers/configuration.dm - config

### Credits:

Azarak - Porting to Skyrat
Gandalf2k15 - Refactoring

Larentoun - Porting to SS220

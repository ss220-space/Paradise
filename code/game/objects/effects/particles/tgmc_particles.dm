/**
 * MARK: TGMC
 * Particles ported from TGMC.
 * They are used in case of explosions and hits on objects from firearms (except for disabler and taser).
 */

/**
 * MARK: Explosion smoke
 */
/particles/explosion_smoke
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke3"
	width = 1000
	height = 1000
	count = 45
	spawning = 45
	gradient = list("#FA9632", "#C3630C", "#333333", "#808080", "#FFFFFF")
	lifespan = 2 SECONDS
	fade = 4 SECONDS
	color = generator(GEN_NUM, 0, 0.25)
	color_change = generator(GEN_NUM, 0.04, 0.05)
	velocity = generator(GEN_CIRCLE, 15, 15)
	drift = generator(GEN_CIRCLE, 0, 1, NORMAL_RAND)
	spin = generator(GEN_NUM, -20, 20)
	friction = generator(GEN_NUM, 0.1, 0.5)
	gravity = list(1, 2)
	scale = 0.25
	grow = 0.05

/particles/explosion_smoke/deva
	lifespan = 3 SECONDS
	fade = 6 SECONDS
	scale = 0.5
	velocity = generator(GEN_CIRCLE, 23, 23)

/particles/explosion_smoke/small
	lifespan = 1 SECONDS
	fade = 2 SECONDS
	count = 15
	spawning = 15
	scale = 0.15
	velocity = generator(GEN_CIRCLE, 10, 10)

/particles/smoke_wave
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke3"
	width = 750
	height = 750
	count = 75
	spawning = 75
	lifespan = 1 SECONDS
	fade = 4 SECONDS
	gradient = list("#BA9F6D", "#808080", "#FFFFFF")
	color = generator(GEN_NUM, 0, 0.25)
	color_change = generator(GEN_NUM, 0.08, 0.07)
	velocity = generator(GEN_CIRCLE, 15, 15)
	rotation = generator(GEN_NUM, -45, 45)
	scale = 0.10
	grow = 0.05
	friction = 0.1

/particles/smoke_wave/small
	count = 45
	spawning = 45
	scale = 0.05
	lifespan = 0.5 SECONDS
	fade = 3 SECONDS

/particles/sparks_outwards
	icon = 'icons/effects/64x64.dmi'
	icon_state = "flare"
	width = 750
	height = 750
	count = 40
	spawning = 20
	lifespan = 2 SECONDS
	fade = 4 SECONDS
	position = generator(GEN_SPHERE, 8, 8)
	velocity = generator(GEN_CIRCLE, 30, 30)
	scale = 0.1
	friction = 0.1

/**
 * MARK: Impact debris
 */
/particles/debris
	icon = 'icons/effects/particles/generic_particles.dmi'
	width = 500
	height = 500
	count = 10
	spawning = 10
	lifespan = 0.7 SECONDS
	fade = 0.4 SECONDS
	position = generator(GEN_CIRCLE, 3, 3)
	scale = 1
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.3, 0.6)
	rotation = generator(GEN_NUM, -20, 20)
	spin = generator(GEN_NUM, -20, 20)
	drift = generator(GEN_CIRCLE, 0, 9, SQUARE_RAND)

/particles/impact_smoke
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke5"
	width = 500
	height = 500
	count = 5
	spawning = 15
	lifespan = 0.7 SECONDS
	fade = 3.3 SECONDS
	grow = 0.065
	drift = generator(GEN_CIRCLE, 8, 8)
	scale = 0.1
	spin = generator(GEN_NUM, -20, 20)
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.3, 0.6)

/**
 * MARK: Bloodsplatter
 */
/particles/splatter
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke5"
	width = 500
	height = 500
	count = 10
	spawning = 10
	lifespan = 0.5 SECONDS
	fade = 0.2 SECONDS
	drift = generator(GEN_CIRCLE, 3, 3)
	scale = 0.25
	spin = generator(GEN_NUM, -20, 20)
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.3, 0.6)
	position = generator(GEN_CIRCLE, 4, 4)


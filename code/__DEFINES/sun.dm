#define GET_SUN_ANGLE                   RUSTLIB_CALL(get_sun_angle)

#define TICK_SOLAR_CONTROL(solar)       RUSTLIB_CALL(add_solar, solar, solar.get_num_uid())
#define UNTICK_SOLAR_CONTROL(solar)     RUSTLIB_CALL(remove_solar, solar.get_num_uid())

#define ATTACHED_SOLAR_CONTROLS_LEN     RUSTLIB_CALL(get_solars_length)

#define GET_SUN_DY                      RUSTLIB_CALL(get_sun_dy)
#define GET_SUN_DX                      RUSTLIB_CALL(get_sun_dx)

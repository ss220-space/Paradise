#define EYE_BLUR_SCALE_STEP 5
#define EYE_BLUR_SCALE_MAX_DURATION 40
#define EYE_BROKEN_THRESHOLD 45

/// Yellow-Blue colorblindness. Tajarans/Farwas have this.
#define TRITANOPIA_COLOR_REPLACE list( \
	"red" = "rebeccapurple", \
	"blue" = "darkslateblue", \
	"green" = "darkolivegreen", \
	"orange" = "darkkhaki", \
	"yellow" = "darkkhaki", \
	"brown" = "rebeccapurple", \
	"gold" = "darkkhaki", \
	"cyan" = "darkseagreen", \
	"magenta" = "darkslateblue", \
	"purple" = "darkslateblue", \
	"pink" = "lightgrey" \
)

#define MATRIX_TAJ_CBLIND list(\
	0.95, 0.07, 0,\
	0, 0.44, 0.52,\
	0.05, 0.49, 0.48)

/// Red colorblindness. Vulpkanins/Wolpins have this.
#define PROTANOPIA_COLOR_REPLACE list( \
	"red" = "darkolivegreen", \
	"green" = "darkslategrey", \
	"orange" = "goldenrod", \
	"yellow" = "goldenrod", \
	"brown" = "darkolivegreen", \
	"gold" = "goldenrod", \
	"cyan" = "steelblue", \
	"magenta" = "blue", \
	"purple" = "darkslategrey", \
	"pink" = "beige" \
)

#define MATRIX_VULP_CBLIND list(\
	0.51, 0.4, 0.12,\
	0.49, 0.41, 0.12,\
	0, 0.2, 0.76)

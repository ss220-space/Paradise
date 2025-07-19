
// art quality defines, used in datums/components/art.dm, elsewhere
#define BAD_ART 12.5
#define OK_ART 20
#define GOOD_ART 25
#define GREAT_ART 50

///tgui tab portrait categories- they're the same across all portrait tguis.
#define TAB_LIBRARY 1
#define TAB_SECURE 2
#define TAB_PRIVATE 3

///cost defines for drawing graffiti: how many charges of a crayon or spraycan are used.
#define CRAYON_COST_SMALL 0.5
#define CRAYON_COST_DEFAULT 1
#define CRAYON_COST_LARGE 5

/**
 * Patronage thresholds for paintings.
 * Different cosmetic frames become available as more credits are spent on the patronage.
 * These also influence the artistic value (read: positive moodlets) of a painting.
 */
#define PATRONAGE_OK_FRAME (150)
#define PATRONAGE_NICE_FRAME (PATRONAGE_OK_FRAME * 2.5)
#define PATRONAGE_GREAT_FRAME (PATRONAGE_NICE_FRAME * 2)
#define PATRONAGE_EXCELLENT_FRAME (PATRONAGE_GREAT_FRAME * 2)
#define PATRONAGE_AMAZING_FRAME (PATRONAGE_EXCELLENT_FRAME * 2)
#define PATRONAGE_SUPERB_FRAME (PATRONAGE_AMAZING_FRAME * 2)
#define PATRONAGE_LEGENDARY_FRAME (PATRONAGE_SUPERB_FRAME * 2)

/// Only returns paintings with 23x23 or 24x24 sizes fitting AI display icon.
#define PAINTINGS_FILTER_AI_PORTRAIT (1<<0)
/// Search mode for the title of the painting
#define PAINTINGS_FILTER_SEARCH_TITLE (1<<1)
/// Ditto but for the creator's name
#define PAINTINGS_FILTER_SEARCH_CREATOR (1<<2)

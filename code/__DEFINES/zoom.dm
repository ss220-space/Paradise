/// How the scope component is toggled. This one is done by right-clicking.
#define ZOOM_METHOD_RIGHT_CLICK 1
/// Wielding the object with both hands toggles the zoom. Requires the two-handed component to work.
#define ZOOM_METHOD_WIELD 2
/// Activated by clicking an item action button specified by the `item_action_type` var.
#define ZOOM_METHOD_ITEM_ACTION 3
/// Toggled by the parent gun's own zoom action (see COMSIG_GUN_ZOOM_TOGGLE).
#define ZOOM_METHOD_GUN_ZOOM 4

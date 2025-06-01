#define chat_box_regular(str) ("<div class='boxed_message thick_border'>" + str + "</div>")
#define chat_box_examine(str) ("<div class='boxed_message left_align_text thick_border'>" + str + "</div>")
#define chat_box_red(str) ("<div class='boxed_message red_border thick_border'>" + str + "</div>")
#define chat_box_purple(str) ("<div class='boxed_message purple_border thick_border'>" + str + "</div>")
#define chat_box_purple_tips(str) ("<div class='boxed_message purple_border left_align_text'>" + str + "</div>")
#define chat_box_yellow(str) ("<div class='boxed_message yellow_border thick_border'>" + str + "</div>")
#define chat_box_green(str) ("<div class='boxed_message green_border thick_border'>" + str + "</div>")
#define chat_box_notice(str) ("<div class='boxed_message notice_border thick_border'>" + str + "</div>")
#define chat_box_notice_thick(str) ("<div class='boxed_message notice_border thick_border'>" + str + "</div>")

/* Need TGUI v6 (please!)
// Adds a box around whatever message you're sending in chat. Can apply color and/or additional classes. Available colors: red, green, blue, purple. Use it like red_box
#define custom_boxed_message(classes, str) ("<div class='boxed_message " + classes + "'>" + str + "</div>")
// Makes a fieldset with a neaty styled name. Can apply additional classes.
#define fieldset_block(title, content, classes) ("<fieldset class='fieldset " + classes + "'><legend class='fieldset_legend'>" + title + "</legend>" + content + "</fieldset>")
*/

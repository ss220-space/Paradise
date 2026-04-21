// Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 4096
#define MAX_PAPER_FIELDS 50
#define MAX_BOOK_MESSAGE_LEN 9216
#define MAX_NAME_LEN 50 // diona names can get loooooooong

// A link given to ghost alice to follow bob
#define FOLLOW_LINK(alice, bob) "<a href=byond://?src=[alice.UID()];follow=[bob.UID()]>(F)</a>"
#define FOLLOW_LINK_WITH_DISPLAY(alice, bob, display) "<a href=byond://?src=[alice.UID()];follow=[bob.UID()]>[display]</a>"
#define TURF_LINK(alice, turfy) "<a href=byond://?src=[alice.UID()];x=[turfy.x];y=[turfy.y];z=[turfy.z]>(T)</a>"
#define FOLLOW_OR_TURF_LINK(alice, bob, turfy) "<a href=byond://?src=[alice.UID()];follow=[bob.UID()];x=[turfy.x];y=[turfy.y];z=[turfy.z]>(F)</a>"

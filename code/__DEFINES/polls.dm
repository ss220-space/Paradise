
//unmagic-strings for types of polls, used by SQL don't change these
#define POLLTYPE_OPTION "Single Option"
#define POLLTYPE_TEXT "Text Reply"
#define POLLTYPE_RATING "Rating"
#define POLLTYPE_MULTI "Multiple Choice"

#define POLL_SECOND "SECOND"
#define POLL_MINUTE "MINUTE"
#define POLL_HOUR "HOUR"
#define POLL_DAY "DAY"
#define POLL_WEEK "WEEK"
#define POLL_MONTH "MONTH"
#define POLL_YEAR "YEAR"

///The message sent when you sign up to a poll.
#define POLL_RESPONSE_SIGNUP "signup"
///The message sent when you've already signed up for a poll and are trying to sign up again.
#define POLL_RESPONSE_ALREADY_SIGNED "already_signed"
///The message sent when you are not signed up for a poll.
#define POLL_RESPONSE_NOT_SIGNED "not_signed"
///The message sent when you are too late to unregister from a poll.
#define POLL_RESPONSE_TOO_LATE_TO_UNREGISTER "failed_unregister"
///The message sent when you successfully unregister from a poll.
#define POLL_RESPONSE_UNREGISTERED "unregistered"

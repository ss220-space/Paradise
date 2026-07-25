#define SUBSCRIPTION_NOTI_NO_REPLY FALSE
// cancel source
#define CANCEL_USER 1
#define CANCEL_SYSTEM 2
#define SUBSCRIPTION_PARAM_MODIFIER "modifier"
// Max unpaid cycles before removing inactive subscription.
#define SUBSCRIPTION_MAX_DEAD_CYCLES 2

// DEFINES FOR SUBSCRIPTION TYPES
#define SALARY_MODIFIER 95
#define SALARY_MODIFIER_INTERVAL (5 MINUTES)

// DEFINES FOR SUBSYSTEM
// Base subsystem tick. Subscription intervals should use multiples of this.
#define BASE_FREQUENCY_SUBSYSTEM (5 MINUTES)
// Bucket count. 12 buckets = 1 hour at 5-minute ticks.
// Increase for intervals > 1 hour.
#define BUCKET_COUNT 12

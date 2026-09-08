#define SUBSCRIPTION_NOTI_NO_REPLY FALSE

#define SUBSCRIPTION_PARAM_MODIFIER "modifier"

// DEFINES FOR SUBSCRIPTION TYPES
#define SALARY_INTERVAL (5 MINUTES)

// DEFINES FOR SUBSYSTEM
// Base subsystem tick. Subscription intervals should use multiples of this.
#define BASE_FREQUENCY_SUBSYSTEM (1 MINUTES)
// Bucket count. 60 buckets = 1 hour at 1-minute ticks.
// Increase for intervals > 1 hour.
#define BUCKET_COUNT 60

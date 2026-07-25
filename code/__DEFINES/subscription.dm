#define SUBSCRIPTION_NOTI_NO_REPLY FALSE
// for cancel desc
#define CANCEL_USER 1
#define CANCEL_SYSTEM 2
#define SUBSCRIPTION_PARAM_MODIFIER "modifier"
// Number of consecutive subscriptions_subsystem cycles an inactive ("dead") subscription
// is allowed to sit unpaid before it gets permanently deleted (qdel'd).
#define SUBSCRIPTION_MAX_DEAD_CYCLES 2

// DEFINES FOR SUBSCRIPTION TYPES
// ===============================
// SALARY_MODIFIER
#define SALARY_MODIFIER 95
#define SALARY_MODIFIER_INTERVAL (5 MINUTES)


// DEFINES FOR SUBSYSTEM
// ===============================
// The base tick rate of this subsystem. All subscription intervals should ideally be
// multiples of this value for precise scheduling.
#define BASE_FREQUENCY_SUBSYSTEM (5 MINUTES)
// Number of time buckets. With a 5-minute wait, 12 buckets cover 1 hour of scheduling.
// Increase this value if you plan to have subscriptions with intervals > 1 hour.
#define BUCKET_COUNT 12

#define RAINDROP_STATUS_OPEN "open"
#define RAINDROP_STATUS_TAKEN "taken"
#define RAINDROP_STATUS_SUBMITTED "submitted"
#define RAINDROP_STATUS_COMPLETED "completed"
#define RAINDROP_STATUS_CANCELLED "cancelled"
#define RAINDROP_STATUS_DISPUTED "disputed"

/// share of the frozen reward paid out to the executor on successful completion (platform keeps the rest as commission)
#define RAINDROP_EXECUTOR_CUT 0.8
/// share of the frozen reward that gets refunded to the client if they withdraw an offer nobody has taken yet
#define RAINDROP_CANCEL_REFUND_CUT 1
/// dispute split: fraction of the frozen reward returned to the client
#define RAINDROP_DISPUTE_CLIENT_CUT 0.4
/// dispute split: fraction of the frozen reward paid to the executor as compensation for work already done
#define RAINDROP_DISPUTE_WORKER_CUT 0.2

#define RAINDROP_TITLE_MAX_LEN 60
#define RAINDROP_DESC_MAX_LEN 300

#define RAINDROP_MIN_REWARD 10
#define RAINDROP_MAX_REWARD 100000

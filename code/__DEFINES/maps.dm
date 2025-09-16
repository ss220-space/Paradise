//clusterCheckFlags defines
//All based on clusterMin and clusterMax as guides

//Individual defines
#define CLUSTER_CHECK_NONE 0 //!No checks are done, cluster as much as possible
#define CLUSTER_CHECK_DIFFERENT_TURFS (1<<1) //!Don't let turfs of DIFFERENT types cluster
#define CLUSTER_CHECK_DIFFERENT_ATOMS (1<<2) //!Don't let atoms of DIFFERENT types cluster
#define CLUSTER_CHECK_SAME_TURFS (1<<3) //!Don't let turfs of the SAME type cluster
#define CLUSTER_CHECK_SAME_ATOMS (1<<4) //!Don't let atoms of the SAME type cluster

//Combined defines
#define CLUSTER_CHECK_SAMES 24 //!Don't let any of the same type cluster
#define CLUSTER_CHECK_DIFFERENTS 6 //!Don't let any of different types cluster
#define CLUSTER_CHECK_ALL_TURFS 10 //!Don't let ANY turfs cluster same and different types
#define CLUSTER_CHECK_ALL_ATOMS 20 //!Don't let ANY atoms cluster same and different types

//All
#define CLUSTER_CHECK_ALL 30 //!Don't let anything cluster, like, at all

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

// Maploader bounds indices
/// The maploader index for the maps minimum x
#define MAP_MINX 1
/// The maploader index for the maps minimum y
#define MAP_MINY 2
/// The maploader index for the maps minimum z
#define MAP_MINZ 3
/// The maploader index for the maps maximum x
#define MAP_MAXX 4
/// The maploader index for the maps maximum y
#define MAP_MAXY 5
/// The maploader index for the maps maximum z
#define MAP_MAXZ 6

// Bluespace shelter deploy checks for survival capsules
/// Shelter spot is allowed
#define SHELTER_DEPLOY_ALLOWED "allowed"
/// Shelter spot has turfs that restrict deployment
#define SHELTER_DEPLOY_BAD_TURFS "bad turfs"
/// Shelter spot has areas that restrict deployment
#define SHELTER_DEPLOY_BAD_AREA "bad area"
/// Shelter spot has anchored objects that restrict deployment
#define SHELTER_DEPLOY_ANCHORED_OBJECTS "anchored objects"

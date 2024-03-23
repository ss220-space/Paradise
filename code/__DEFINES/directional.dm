//Directions (already defined on BYOND natively, purely here for reference)
//#define NORTH		1
//#define SOUTH		2
//#define EAST		4
//#define WEST		8
//#define NORTHEAST	5
//#define SOUTHEAST 6
//#define NORTHWEST 9
//#define SOUTHWEST 10

// Multi-z directions
//#define UP 16
//#define DOWN 32

/// North direction as a string "[1]"
#define TEXT_NORTH "[NORTH]"
/// South direction as a string "[2]"
#define TEXT_SOUTH "[SOUTH]"
/// East direction as a string "[4]"
#define TEXT_EAST "[EAST]"
/// West direction as a string "[8]"
#define TEXT_WEST "[WEST]"

/// for directions, each cardinal direction only has 1 TRUE bit, so `1000` or `0100` for example, so when you subtract 1
/// from a cardinal direction it results in that directions initial TRUE bit always switching to FALSE, so if you & check it
/// against its initial self, it will return false, indicating that the direction is straight and not diagonal

///True if the dir is diagonal, false otherwise
#define ISDIAGONALDIR(d) (d & (d-1))
///True if direction is cardinal and false if not
#define ISCARDINALDIR(d) (!ISDIAGONALDIR(d))
///True if the dir is north or south, false therwise
#define NSCOMPONENT(d) (d & (NORTH|SOUTH))
///True if the dir is east/west, false otherwise
#define EWCOMPONENT(d) (d & (EAST|WEST))


/// Using the ^ operator or XOR, we can compared TRUE East and West bits against our direction,
/// since XOR will only return TRUE if one bit is False and the other is True, if East is 0, that bit will return TRUE
/// and if West is 1, then that bit will return 0
/// hence  EAST (0010) XOR EAST|WEST (0011) --> WEST (0001)

///Inverse direction, taking into account UP|DOWN if necessary.
#define REVERSE_DIR(dir) (((dir & 85) << 1)|((dir & 170) >> 1))
///Flips the dir for north/south directions
#define NSDIRFLIP(d) (d ^ (NORTH|SOUTH))
///Flips the dir for east/west directions
#define EWDIRFLIP(d) (d ^ (EAST|WEST))

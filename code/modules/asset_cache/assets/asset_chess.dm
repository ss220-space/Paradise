/datum/asset/simple/namespaced/chess
	legacy = TRUE
	assets = list(
		"bishop_black.png"			= 'icons/misc/chess_pieces/bishop_black.png',
		"bishop_white.png"			= 'icons/misc/chess_pieces/bishop_white.png',
		"king_black.png"			= 'icons/misc/chess_pieces/king_black.png',
		"king_white.png"			= 'icons/misc/chess_pieces/king_white.png',
		"knight_black.png"			= 'icons/misc/chess_pieces/knight_black.png',
		"knight_white.png"			= 'icons/misc/chess_pieces/knight_white.png',
		"pawn_black.png"			= 'icons/misc/chess_pieces/pawn_black.png',
		"pawn_white.png"			= 'icons/misc/chess_pieces/pawn_white.png',
		"queen_black.png"			= 'icons/misc/chess_pieces/queen_black.png',
		"queen_white.png"			= 'icons/misc/chess_pieces/queen_white.png',
		"rook_black.png"			= 'icons/misc/chess_pieces/rook_black.png',
		"rook_white.png"			= 'icons/misc/chess_pieces/rook_white.png',
		"sprites.png"			    = 'icons/misc/chess_pieces/sprites.png',
		"blank.gif"                 = 'icons/misc/chess_pieces/blank.gif',
	)
	parents = list(
		"garbochess.js"             = 'html/browser/garbochess.js',
		"boardui.js"                = 'html/browser/boardui.js'
	)

/datum/asset/group/chess
	children = list(
		/datum/asset/simple/namespaced/chess,
		/datum/asset/simple/jquery
	)

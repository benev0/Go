extends Object
class_name WeiQiGameState

var board: Array
var size: int
var visitation: Array
var visit_number: int
# todo: ko
var ko: Vector2i

signal intesection_captured(position: Vector2i)

enum Intersection {EMPTY, BALCK, WHITE}

func _init(game_size: int) -> void:
	size = game_size
	visit_number = 0

	board = []
	visitation = []

	board.resize(size)
	visitation.resize(size)
	for row in size:
		board[row] = []
		board[row].resize(size)
		visitation[row] = []
		visitation[row].resize(size)
		for col in size:
			board[row][col] = Intersection.EMPTY
			visitation[row][col] = -1

func place_stone(position: Vector2i, is_black: bool) -> bool:
	if off_board(position):
		return false
	if board[position.y][position.x] != Intersection.EMPTY:
		return false
	return check_place(position, is_black)

	 
func check_place(position: Vector2i, is_black: bool) -> bool:
	board[position.y][position.x] = Intersection.BALCK if is_black else Intersection.WHITE
	if try_capture(position):
		return true
	if has_liberty(position):
		return true
	board[position.y][position.x] = Intersection.EMPTY
	return false

func try_capture(position: Vector2i) -> int:
	var type: Intersection = get_intersection(position)
	if type == Intersection.EMPTY:
		return false
	var captured = 0
	captured += try_capture_internal(position + Vector2i( 1, 0 ), type)
	captured += try_capture_internal(position + Vector2i( 0, 1 ), type) 
	captured += try_capture_internal(position + Vector2i(-1, 0 ), type) 
	captured += try_capture_internal(position + Vector2i( 0,-1 ), type)
	if captured == 1:
		ko = position
	return  captured

func try_capture_internal(position: Vector2i, captor: Intersection) -> int:
	var target: Intersection = get_intersection(position)
	if target == captor || target == Intersection.EMPTY:
		return 0
	if !has_liberty(position):
		return confirm_capture()
	return 0

func confirm_capture() -> int:
	var captured: int = 0
	for row in size:
		for col in size:
			if visitation[row][col] == visit_number:
				board[row][col] = Intersection.EMPTY
				intesection_captured.emit(Vector2i(col, row))
				captured += 1
	return captured

func has_liberty(position: Vector2i) -> bool:
	if off_board(position):
		return false
	var type: Intersection = get_intersection(position)
	if type == Intersection.EMPTY:
		return true
	visit_number += 1
	return has_liberty_internal(position, type)

func has_liberty_internal(position: Vector2i, group: Intersection)  -> bool:
	if has_visited(position):
		return false
	var check_intersection: Intersection = get_intersection(position)
	if check_intersection == Intersection.EMPTY:
		return true
	if check_intersection != group:
		return false
	visit(position)
	return has_liberty_internal(position + Vector2i(1, 0), group) || has_liberty_internal(position + Vector2i(0, 1), group) || has_liberty_internal(position + Vector2i(-1, 0), group) || has_liberty_internal(position + Vector2i(0, -1), group)
	
func off_board(position: Vector2i) -> bool:
	return position.x < 0 || position.y < 0 || position.x >= size || position.y >= size

func get_intersection(position: Vector2i) -> Intersection:
	if off_board(position):
		return Intersection.EMPTY
	return board[position.y][position.x]
	
func has_visited(position: Vector2i) -> bool:
	return off_board(position) || visitation[position.y][position.x] == visit_number

func visit(position: Vector2i):
	if off_board(position):
		return
	visitation[position.y][position.x] = visit_number

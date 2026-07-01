extends Area2D

const WeiQiGameState = preload("res://weiqi_game_state.gd")

@export var stone: PackedScene
# pixel height/width
@export var size: int
# the logial size of the board
@export var dim: int
@export var board_color: Color
@export var line_color: Color
@export var stone_space_ratio: float
@export var stone_alpha: float

var mouse_present: bool
var black_turn: bool
var stride: int
var line_len: int
var stone_size: float
var ghost_stone: AnimatedSprite2D
var stones: Array
var game: WeiQiGameState
var score_update: bool
var black_capture: int
var white_capture: int
var last_move_pass: bool

signal new_score(black: int, white: int)

func draw_h_line(image: Image, start: Vector2i, lenght: int) -> void:
	for i in lenght + 1:
		image.set_pixel(start.x + i, start.y, line_color)
	
func draw_v_line(image: Image, start: Vector2i, length: int) -> void:
	for i in length + 1:
		image.set_pixel(start.x, start.y + i, line_color)

func create_new_stone() -> Node:
	var new_stone: Node = stone.instantiate()
	new_stone.scale_stone(stone_size / 128.0)
	add_child(new_stone)
	return new_stone

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_present = false
	black_turn = true
	stride = size / (dim + 1)
	line_len = size - 2 * stride
	stone_size = stride * stone_space_ratio
	ghost_stone = create_new_stone()
	ghost_stone.modulate.a = stone_alpha
	game = WeiQiGameState.new(dim)
	game.intesection_captured.connect(_on_stone_captured)
	score_update = true
	black_capture = 0
	white_capture = 0
	last_move_pass = false
	
	stones = []
	stones.resize(dim)
	for i in dim:
		stones[i] = []
		stones[i].resize(dim)
	
	$CollisionShape2D.shape.size = Vector2(size - stride, size - stride)

	var image: Image = Image.create(size, size, false, Image.FORMAT_RGB8)

	image.fill(board_color)
	for i in dim: 
		var progress: int = (i + 1) * stride 
		draw_h_line(image, Vector2i(stride, progress), line_len)
		draw_v_line(image, Vector2i(progress, stride), line_len)

	var texture: ImageTexture = ImageTexture.create_from_image(image)
	$Sprite2D.texture = texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if score_update:
		new_score.emit(black_capture, white_capture)
	
	if !mouse_present:
		return

	var relitive_mouse: Vector2 = get_local_mouse_position() + Vector2(size / 2.0, size / 2.0);
	var square: Vector2i = Vector2i(relitive_mouse / stride - Vector2(0.5, 0.5))
	
	if square.x < 0 || square.y < 0 || square.x >= dim || square.y >= dim:
		ghost_stone.hide_stone()
		return
	
	if stones[square.y][square.x] != null:
		ghost_stone.hide_stone()
		return
	
	var center_offset: int = stride - size / 2
	
	if Input.is_action_just_pressed("Click") && game.check_place(square, black_turn):
		var new_stone: Node = create_new_stone()
		if !black_turn:
			new_stone.white()
		new_stone.place(square * stride + Vector2i(center_offset, center_offset))
		stones[square.y][square.x] = new_stone
		next_turn()
		ghost_stone.hide_stone()
		return
	
	ghost_stone.place(square * stride + Vector2i(center_offset, center_offset))

func pass_turn() -> void:
	if last_move_pass:
		# todo: end the game
		return
	next_turn(true)

func next_turn(passed: bool = false) -> void:
	black_turn = !black_turn
	ghost_stone.change_color()
	last_move_pass = passed

func _on_stone_captured(where: Vector2i, is_black: bool) -> void:
	stones[where.y][where.x].queue_free()
	stones[where.y][where.x] = null
	if is_black:
		black_capture += 1
	else:
		white_capture += 1
	score_update = true

func _on_mouse_entered() -> void:
	mouse_present = true

func _on_mouse_exited() -> void:
	mouse_present = false

extends Area2D

@export var stone: PackedScene
# pixel height/width
@export var size: int
# the logial size of the board
@export var dim: int
@export var board_color: Color
@export var line_color: Color
@export var stone_space_ratio: float

var mouse_present: bool
var black_turn: bool
var stride: int
var line_len: int
var stone_size: float
var ghost_stone: Node

func draw_h_line(image: Image, start: Vector2i, lenght: int) -> void:
	for i in lenght + 1:
		image.set_pixel(start.x + i, start.y, line_color)
	
func draw_v_line(image: Image, start: Vector2i, length: int) -> void:
	for i in length + 1:
		image.set_pixel(start.x, start.y + i, line_color)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_present = false
	black_turn = true
	stride = size / (dim + 1)
	line_len = size - 2 * stride
	stone_size = stride * stone_space_ratio
	ghost_stone = stone.instantiate()
	add_child(ghost_stone)
	
	ghost_stone.scale_stone(stone_size / 128.0)
	ghost_stone.place(Vector2(0.0, 0.0))
	
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
	if !mouse_present:
		return

	var relitive_mouse: Vector2 = get_local_mouse_position() + Vector2(size / 2.0, size / 2.0);
	var square: Vector2i = Vector2i(relitive_mouse / stride - Vector2(0.5, 0.5))
	
	if square.x < 0 || square.y < 0 || square.x >= dim || square.y >= dim:
		ghost_stone.hide_stone()
		return
	
	var center_offset: int = stride - size / 2
	ghost_stone.place(square * stride + Vector2i(center_offset, center_offset))
	
	if Input.is_action_just_pressed("Click"):
		print(square) #try to place piece
		print(relitive_mouse)
	

func _on_mouse_entered() -> void:
	mouse_present = true

func _on_mouse_exited() -> void:
	mouse_present = false

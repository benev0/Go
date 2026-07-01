extends AnimatedSprite2D

var is_black: bool

func _ready() -> void:
	is_black = true
	hide()

func _process(_delta: float) -> void:
	pass

func place(pos: Vector2) -> void:
	transform.origin = pos
	show()

func scale_stone(stone_scale: float) -> void:
	scale = Vector2(stone_scale, stone_scale)

func hide_stone() -> void:
	hide()
	
func black() -> void:
	is_black = true
	animation = "Black"
	
func white() -> void:
	is_black = false
	animation = "White"
	
func change_color() -> void:
	is_black = !is_black
	if is_black:
		animation = "Black"
	else:
		animation = "White"

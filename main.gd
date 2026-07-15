extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$Board.transform.origin = get_viewport().get_visible_rect().size / 2.0
	$UI/Pass.pressed.connect(_pass_pressed)
	$Control/Board.new_score.connect(_scores_updated)
	$Control/Board.size = get_viewport().get_visible_rect().size.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _pass_pressed() -> void:
	$Control/Board.pass_turn()

func _scores_updated(black_captures: int, white_captures: int) -> void:
	$UI/Captures.text = "Black: %d White: %d" % [white_captures, black_captures]

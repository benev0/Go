extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Board.transform.origin = get_viewport().get_visible_rect().size / 2.0
	$UI/Pass.pressed.connect(_pass_pressed)
	$Board.new_score.connect(_scores_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _pass_pressed() -> void:
	$Board.pass_turn()

func _scores_updated(black: int, white: int) -> void:
	$UI/Captues.text = "Black: %d White %d" % [black, white]

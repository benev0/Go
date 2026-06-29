extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Board.transform.origin = get_viewport().get_visible_rect().size / 2.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

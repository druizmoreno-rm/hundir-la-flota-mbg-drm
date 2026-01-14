extends Button
class_name Cell

var x:int
var y:int
var game_manager:Node

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if game_manager:
		game_manager.on_cell_pressed(self)

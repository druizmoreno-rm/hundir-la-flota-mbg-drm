extends TextureButton
class_name Cell

var x:int
var y:int
var board_owner:int
var has_ship:bool = false
var is_revealed:bool = false
var game_manager:Node = null

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if game_manager == null:
		return
	game_manager.on_cell_clicked(self)

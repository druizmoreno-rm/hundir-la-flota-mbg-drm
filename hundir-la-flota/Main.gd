extends Control

const BOARD_SIZE:int = 8
const SHIPS_PER_PLAYER:int = 5

@onready var CellScene:PackedScene = preload("res://Cell.tscn")

@export var water_texture:Texture2D
@export var ship_sunk_texture:Texture2D
@export var splash_texture:Texture2D

@onready var player1_grid:GridContainer = %Player1Grid
@onready var player2_grid:GridContainer = %Player2Grid

@onready var status_label:Label = %StatusLabel
@onready var current_player_avatar:TextureRect = %CurrentPlayerAvatar
@onready var restart_button:TextureButton = %RestartButton

@onready var player1_score_label:Label = %Player1ScoreLabel
@onready var player2_score_label:Label = %Player2ScoreLabel

@onready var player1_avatar:TextureRect = %Player1Avatar
@onready var player2_avatar:TextureRect = %Player2Avatar

var boards:Array = []
var revealed:Array = []
var ships_remaining:Array[int] = [SHIPS_PER_PLAYER, SHIPS_PER_PLAYER]
var current_player:int = 0
var game_over:bool = false
var wins:Array[int] = [0, 0]

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	_create_logical_boards()
	_create_visual_boards()
	_place_ships_randomly()
	_update_ui_turn()

func _create_logical_boards() -> void:
	boards.clear()
	revealed.clear()
	for player in range(2):
		var board:Array = []
		var rev:Array = []
		for x in range(BOARD_SIZE):
			board.append([])
			rev.append([])
			for y in range(BOARD_SIZE):
				board[x].append(false)
				rev[x].append(false)
		boards.append(board)
		revealed.append(rev)
	ships_remaining = [SHIPS_PER_PLAYER, SHIPS_PER_PLAYER]
	game_over = false

func _create_visual_boards() -> void:
	for child in player1_grid.get_children():
		child.queue_free()
	for child in player2_grid.get_children():
		child.queue_free()

	player1_grid.columns = BOARD_SIZE
	player2_grid.columns = BOARD_SIZE

	for x in range(BOARD_SIZE):
		for y in range(BOARD_SIZE):
			var cell1:Cell = CellScene.instantiate()
			cell1.x = x
			cell1.y = y
			cell1.board_owner = 0
			cell1.game_manager = self
			cell1.texture_normal = water_texture
			player1_grid.add_child(cell1)

			var cell2:Cell = CellScene.instantiate()
			cell2.x = x
			cell2.y = y
			cell2.board_owner = 1
			cell2.game_manager = self
			cell2.texture_normal = water_texture
			player2_grid.add_child(cell2)

func _place_ships_randomly() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for player in range(2):
		var placed:int = 0
		while placed < SHIPS_PER_PLAYER:
			var x:int = rng.randi_range(0, BOARD_SIZE - 1)
			var y:int = rng.randi_range(0, BOARD_SIZE - 1)
			if boards[player][x][y] == false:
				boards[player][x][y] = true
				placed += 1

func _update_ui_turn() -> void:
	if game_over:
		return
	status_label.text = "Turno del Jugador %d" % (current_player + 1)
	current_player_avatar.texture = player1_avatar.texture if current_player == 0 else player2_avatar.texture

func on_cell_clicked(cell:Cell) -> void:
	if game_over:
		return
	if cell.board_owner == current_player:
		return

	var x:int = cell.x
	var y:int = cell.y
	var target_player:int = cell.board_owner

	if revealed[target_player][x][y]:
		return

	revealed[target_player][x][y] = true

	if boards[target_player][x][y]:
		boards[target_player][x][y] = false
		ships_remaining[target_player] -= 1
		cell.texture_normal = ship_sunk_texture
		status_label.text = "¡Impacto al Jugador %d!" % (target_player + 1)
		if ships_remaining[target_player] <= 0:
			_on_player_defeated(target_player)
			return
	else:
		cell.texture_normal = splash_texture
		status_label.text = "Agua..."

	_change_turn()

func _change_turn() -> void:
	if game_over:
		return
	current_player = 1 - current_player
	_update_ui_turn()

func _on_player_defeated(player:int) -> void:
	game_over = true
	var winner:int = 1 - player
	status_label.text = "¡Gana el Jugador %d!" % (winner + 1)
	wins[winner] += 1
	_update_score_labels()

func _update_score_labels() -> void:
	player1_score_label.text = "Victorias J1: %d" % wins[0]
	player2_score_label.text = "Victorias J2: %d" % wins[1]

func _on_restart_pressed() -> void:
	_create_logical_boards()
	_create_visual_boards()
	_place_ships_randomly()
	current_player = 0
	_update_ui_turn()
	status_label.text = "Nueva partida"

extends Control

const SIZE:int = 4

@onready var status_label:Label = %StatusLabel
@onready var score_label:Label = %ScoreLabel
@onready var grid:GridContainer = %Grid
@onready var restart_button:Button = %RestartButton

@onready var CellScene:PackedScene = preload("res://Cell.tscn")

# --- LÓGICA DEL JUEGO ---
var special_x:int
var special_y:int

var rounds_to_win:int = 3
var rounds_won:Array[int] = [0, 0]
var current_round:int = 1

var current_player:int = 0
var game_over:bool = false

# Matriz para bloquear celdas ya usadas
var board:Array = []


func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	_start_round()


# ============================================================
#   INICIO DE RONDA
# ============================================================
func _start_round() -> void:
	game_over = false
	current_player = 0

	status_label.text = "Ronda %d - Turno: Jugador %d" % [current_round, current_player + 1]
	_update_score_label()

	# Crear matriz vacía (-1 = libre)
	board.clear()
	for x in range(SIZE):
		board.append([])
		for y in range(SIZE):
			board[x].append(-1)

	# Elegir celda especial aleatoria
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	special_x = rng.randi_range(0, SIZE - 1)
	special_y = rng.randi_range(0, SIZE - 1)

	# Limpiar tablero visual
	for child in grid.get_children():
		child.queue_free()

	# Crear celdas nuevas
	for x in range(SIZE):
		for y in range(SIZE):
			var cell:Cell = CellScene.instantiate()
			cell.x = x
			cell.y = y
			cell.game_manager = self
			cell.text = ""
			cell.modulate = Color.WHITE
			grid.add_child(cell)


# ============================================================
#   CUANDO SE PULSA UNA CELDA
# ============================================================
func on_cell_pressed(cell:Cell) -> void:
	if game_over:
		return

	var x:int = cell.x
	var y:int = cell.y

	# Si la celda ya fue usada, no permitir pulsarla
	if board[x][y] != -1:
		return

	# Marcar celda como usada por el jugador actual
	board[x][y] = current_player

	# Comprobar si la celda es especial
	if x == special_x and y == special_y:
		cell.modulate = Color(0.0, 0.96, 0.83) # Verde-azulado neón
		_on_player_found_special(current_player)
		return

	# Si no es la especial, marcar celda normal
	if current_player == 0:
		cell.modulate = Color(0.18, 0.36, 1.0)
	else:
		cell.modulate = Color(1.0, 0.54, 0.0)

	# Cambiar turno
	current_player = 1 - current_player
	status_label.text = "Ronda %d - Turno: Jugador %d" % [current_round, current_player + 1]


# ============================================================
#   CUANDO UN JUGADOR ENCUENTRA LA CELDA ESPECIAL
# ============================================================
func _on_player_found_special(player:int) -> void:
	game_over = true
	rounds_won[player] += 1

	status_label.text = "Jugador %d encuentra la celda especial!" % (player + 1)
	_update_score_label()

	# ¿Ha ganado la partida?
	if rounds_won[player] >= rounds_to_win:
		status_label.text = "Jugador %d gana la partida!" % (player + 1)
		return

	# Si no, iniciar siguiente ronda tras un pequeño retraso
	current_round += 1
	await get_tree().create_timer(1.5).timeout
	_start_round()


# ============================================================
#   ACTUALIZAR MARCADOR
# ============================================================
func _update_score_label() -> void:
	score_label.text = "Rondas:  J1 %d  |  J2 %d" % [rounds_won[0], rounds_won[1]]


# ============================================================
#   BOTÓN DE REINICIO
# ============================================================
func _on_restart_pressed() -> void:
	rounds_won = [0, 0]
	current_round = 1
	current_player = 0
	_update_score_label()
	_start_round()

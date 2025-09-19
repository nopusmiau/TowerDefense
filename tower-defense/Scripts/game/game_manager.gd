# game_manager.gd
extends Node2D

# Recursos del jugador
var current_gold: int = 100
var current_lives: int = 10
var current_score: int = 0
@export var waves: Array = []
var current_wave_index: int = -1
var enemies_left_to_spawn: int = 0
var is_wave_active: bool = false
var level_path: Path2D
var is_in_build_mode: bool = false
var current_ghost = null
var current_tower_type: String = ""
var current_tower_cost: int = 0
var enemies_alive: int = 0

@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var path_layer: TileMapLayer = get_parent().get_node("TileMap/PathLayer")
@onready var ground_layer: TileMapLayer = get_parent().get_node("TileMap/GroundLayer")

func _ready():
	# Conectarse a las señales que le importan al manager
	print("GameManager listo. Conectando señales...")
	GameEvents.enemy_died.connect(_on_enemy_died)
	print("GameManager conectado a enemy_died()")
	_initialize_waves()
	level_path = get_parent().get_node("Path2D")
	print("Path2D encontrado: ", level_path != null)
	print("Oleadas inicializadas: ", waves)
	GameEvents.request_wave_start.connect(_on_request_wave_start)
	GameEvents.enemy_reached_end.connect(_on_enemy_reached_end)
	GameEvents.request_build_mode.connect(_on_tower_button_pressed)
	GameEvents.request_restart.connect(_restart_level)

# --- FUNCIONES PARA MODIFICAR RECURSOS ---
func add_gold(amount: int):
	print("add_gold llamado con cantidad: ", amount)
	current_gold += amount
	GameEvents.gold_changed.emit(current_gold) # ¡Notifica a todo el juego!
	print("Oro nuevo: ", current_gold)

func spend_gold(amount: int) -> bool:
	if current_gold >= amount:
		current_gold -= amount
		GameEvents.gold_changed.emit(current_gold)
		return true # Compra exitosa
	return false # No hay suficiente oro

func lose_life(amount: int):
	if current_lives <= 0:
		return
	
	current_lives -= amount
	if current_lives < 0:
		current_lives = 0
	
	GameEvents.lives_changed.emit(current_lives)
	
	if current_lives == 0:
		is_wave_active = false
		enemy_spawn_timer.stop()
		print("Game Over!")
		GameEvents.game_over.emit(false) # Derrota
	

# --- MANEJADOR DE SEÑALES ---
func _on_enemy_died(enemy_instance: Node2D, reward: int):
	print("GameManager capturo la señal enemy_died! Recompensa: ", reward)
	add_gold(reward)
	current_score += reward
	GameEvents.score_changed.emit(current_score)
	
	enemies_alive -= 1
	
	if current_lives > 0 and is_wave_active and enemies_left_to_spawn <= 0 and enemies_alive <= 0:
		wave_cleared()

func _initialize_waves():
	waves = [
		# Oleada 1: 5 enemigos normales, con 1 segundo entre cada spawn
		{"enemy_type": "normal", "enemy_count": 5, "spawn_delay": 1.0},
		# Oleada 2: 3 enemigos tanques, con 2 segundos entre cada spawn
		{"enemy_type": "tank", "enemy_count": 3, "spawn_delay": 2.0},
		# Oleada 3: 10 enemigos normales, spawn rápido (0.5 sec)
		{"enemy_type": "normal", "enemy_count": 10, "spawn_delay": 0.5}
	]

func start_next_wave():
	if is_wave_active:
		print("¡Ya hay una oleada activa!")
		return
	
	current_wave_index += 1
	
	if current_lives == 0:
		print("¡Sin vidas, has perdido!")
		is_wave_active = false
		GameEvents.game_over.emit(false)
		return
		
	elif current_wave_index >= waves.size():
		print("¡Todas las oleadas completadas! VICTORIA")
		is_wave_active = false
		GameEvents.victory.emit()
		return
	
	var current_wave_data = waves[current_wave_index]
	enemies_left_to_spawn = current_wave_data["enemy_count"]
	is_wave_active = true
	
	enemy_spawn_timer.wait_time = current_wave_data["spawn_delay"]
	enemy_spawn_timer.start()
	
	print("Comenzando oleada %d" % [current_wave_index + 1])
	GameEvents.wave_started.emit(current_wave_index + 1)
	
func _on_enemy_spawn_timer_timeout():
	if enemies_left_to_spawn > 0:
		spawn_enemy()
		enemies_left_to_spawn -= 1
		enemy_spawn_timer.start()
	else:
		enemy_spawn_timer.stop()

func spawn_enemy():
	var enemy_scene = load("res://Scenes/game/enemies/test_enemy.tscn")
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.add_to_group("enemies")
	enemies_alive += 1
	
	if level_path and enemy_instance.has_method("set_path"):
		enemy_instance.set_path(level_path)
	
	get_parent().add_child(enemy_instance)
	print("Enemigo spawned! Quedan por spawnear: ", enemies_left_to_spawn - 1)
	GameEvents.enemy_spawned.emit(enemy_instance)

func wave_cleared():
	is_wave_active = false
	print("¡Oleada %d completada!" % [current_wave_index + 1])
	GameEvents.wave_cleared.emit(current_wave_index + 1)

func _on_request_wave_start():
	start_next_wave()

func _on_enemy_reached_end():
	lose_life(1)
	enemies_alive -= 1
	
	if current_lives > 0 and is_wave_active and enemies_left_to_spawn <= 0 and enemies_alive <= 0:
		wave_cleared()

func _on_tower_button_pressed(tower_type: String, tower_cost: int):
	if is_in_build_mode:
		cancel_build_mode()
	
	if spend_gold(tower_cost):
		start_build_mode(tower_type, tower_cost)
	else:
		print("No hay suficiente oro para construir!")

func start_build_mode(tower_type: String, tower_cost: int):
	is_in_build_mode = true
	current_tower_type = tower_type
	current_tower_cost = tower_cost
	
	var ghost_scene = load("res://Scenes/game/towers/test_ghost_tower.tscn")
	current_ghost = ghost_scene.instantiate()
	get_parent().add_child(current_ghost)
	print("Modo construcción activado. Click izquierdo para colocar, click derecho para cancelar")

func cancel_build_mode():
	is_in_build_mode = false
	if current_ghost:
		current_ghost.queue_free()
		current_ghost = null
	print("Modo construcción cancelado.")

func _input(event):
	if not is_in_build_mode:
		return
	
	if event is InputEventMouseMotion and current_ghost:
		current_ghost.global_position = get_global_mouse_position()
		
		var is_valid_position = check_position_validity(current_ghost.global_position)
		current_ghost.update_validity(is_valid_position)
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			attempt_place_tower()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			add_gold(current_tower_cost)
			cancel_build_mode()

func attempt_place_tower():
	if not current_ghost:
		return
	
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = current_ghost.global_position
	parameters.collision_mask = 1
	
	var results = space_state.intersect_point(parameters)
	
	if results.is_empty():
		place_tower()
	else:
		print("Posición no válida para construir")

func place_tower():
	var tower_scene = load("res://Scenes/game/towers/test_tower.tscn")
	var tower_instance = tower_scene.instantiate()
	
	tower_instance.global_position = current_ghost.global_position
	get_parent().add_child(tower_instance)
	
	print("Torre colocada!")
	cancel_build_mode()

func check_position_validity(position: Vector2) -> bool:
	var cell = path_layer.local_to_map(path_layer.to_local(position))
	
	if path_layer.get_cell_source_id(cell) != -1:
		return false
	
	if ground_layer.get_cell_source_id(cell) == -1:
		return false
	
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = position
	parameters.collision_mask = 1
	
	return space_state.intersect_point(parameters).is_empty()

func _restart_level():
	get_tree().reload_current_scene()

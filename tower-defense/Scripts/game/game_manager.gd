# game_manager.gd
extends Node2D

# Recursos del jugador
var current_gold: int = 100
var current_lives: int = 10
var current_score: int = 0

func _ready():
	# Conectarse a las señales que le importan al manager
	print("GameManager listo. Conectando señales...")
	GameEvents.enemy_died.connect(_on_enemy_died)
	print("GameManager conectado a enemy_died()")

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
	current_lives -= amount
	GameEvents.lives_changed.emit(current_lives)
	if current_lives <= 0:
		GameEvents.game_over.emit(false) # Derrota

# --- MANEJADOR DE SEÑALES ---
func _on_enemy_died(enemy_instance: Node2D, reward: int):
	print("GameManager capturo la señal enemy_died! Recompensa: ", reward)
	add_gold(reward)
	current_score += reward
	GameEvents.score_changed.emit(current_score)

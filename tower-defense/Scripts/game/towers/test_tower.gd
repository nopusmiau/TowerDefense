# basic_tower.gd
extends Area2D

# --- Configuración de la Torre ---
@export var attack_damage: int = 30
@export var attack_speed: float = 1.0  # Ataques por segundo
@export var attack_range: float = 150.0 # Radio del área de detección

# --- Variables Internas ---
var current_target: Node2D = null
var enemies_in_range: Array[Node2D] = [] # Lista de enemigos dentro del rango

@onready var attack_timer: Timer = $AttackTimer

func _ready():
	# Configurar el timer con la velocidad de ataque
	attack_timer.wait_time = 1.0 / attack_speed
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	
	# Conectar las señales del Area2D para saber cuándo entran/salen enemigos
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

# --- Señales del Area2D ---
func _on_body_entered(body: Node2D):
	# Verificar si el cuerpo que entró es un enemigo
	if body.is_in_group("enemies"):
		print("Enemigo entró en el rango!")
		enemies_in_range.append(body)
		# Si no tenemos objetivo, elegir uno
		if current_target == null:
			_acquire_target()

func _on_body_exited(body: Node2D):
	if body in enemies_in_range:
		print("Enemigo salió del rango!")
		enemies_in_range.erase(body)
		# Si el que se fue era nuestro objetivo, buscar uno nuevo
		if body == current_target:
			_acquire_target()

# --- Lógica de Targeting ---
func _acquire_target():
	# Elegir el primer enemigo en la lista como objetivo (lógica simple)
	if enemies_in_range.size() > 0:
		current_target = enemies_in_range[0]
		print("Objetivo adquirido: ", current_target)
		attack_timer.start()
		# Empezar a disparar si el timer no está activo
	else:
		current_target = null
		attack_timer.stop() # Si no hay enemigos, dejar de disparar

# --- Lógica de Ataque ---
func _on_attack_timer_timeout():
	if current_target != null and is_instance_valid(current_target):
		# ¡Disparar!
		_fire_at_target(current_target)
	else:
		# El objetivo ya no es válido (murió o salió), buscar otro
		_acquire_target()

func _fire_at_target(target: Node2D):
	print("Disparando a objetivo por ", attack_damage, " de daño")
	# Aquí irá la lógica de crear un proyectil visualmente
	# Por ahora, aplicamos el daño directamente al objetivo
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)

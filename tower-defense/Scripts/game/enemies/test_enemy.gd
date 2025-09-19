# test_enemy.gd
extends CharacterBody2D

# Variable para definir cuánto oro da este enemigo al morir
@export var reward: int = 10
@export var speed: float = 100.0

var path_to_follow: Path2D = null
var path_follow: PathFollow2D = null
var is_moving: bool = false
var health: int = 30

func _ready():
	print("¡El enemigo ha sido creado! ") # <- DEBUG

func set_path(path: Path2D):
	path_to_follow = path
	path_follow = PathFollow2D.new()
	path_follow.loop = false
	path_to_follow.add_child(path_follow)
	is_moving = true
	print("Camino asignado. Enemigo comenzando a moverse.")

func _physics_process(delta):
	if not is_moving or not path_follow:
		return
	path_follow.progress += speed * delta
	
	global_position = path_follow.global_position
	
	# (Opcional) Rota el sprite para que mire en la dirección del movimiento
	# var target_angle = path_follow.rotation + PI/2 # Ajusta el ángulo si es necesario
	# $Sprite2D.rotation = lerp($Sprite2D.rotation, target_angle, 0.1)
	
	if path_follow.progress_ratio >= 0.99:
		_reached_end()

func _reached_end():
	print("Enemigo llego al final del camino!")
	is_moving = false
	GameEvents.enemy_reached_end.emit()
	queue_free()

func take_damage(damage_amount: int):
	health -= damage_amount
	print("Enemigo recibio ", damage_amount, " de daño. Vida restante: ", health)
	if health <= 0:
		die()

func die():
	print("Enemigo Eliminado!") # <- DEBUG
	is_moving = false
	# ¡Aquí está la magia! Al morir, emite la señal global.
	GameEvents.enemy_died.emit(self, reward)
	if path_follow and is_instance_valid(path_follow):
		path_follow.queue_free()
	queue_free() # Se destruye a sí mismo
	print("Esta línea no debería verse") # <- DEBUG (queue_free() es inmediato)

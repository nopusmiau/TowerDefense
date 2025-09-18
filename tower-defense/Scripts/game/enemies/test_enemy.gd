# test_enemy.gd
extends Node2D

# Variable para definir cuánto oro da este enemigo al morir
@export var reward: int = 10

func _ready():
	print("¡El enemigo ha sido creado! Esperando 2 segundos...") # <- DEBUG
	# Simula que el enemigo muere después de 2 segundos
	await get_tree().create_timer(2.0).timeout
	print("¡Timer completado! Llamando a die()") # <- DEBUG
	die()

func die():
	print("Ejecutando die()") # <- DEBUG
	# ¡Aquí está la magia! Al morir, emite la señal global.
	GameEvents.enemy_died.emit(self, reward)
	print("Señal enemy_died emitida. Ahora llamando a queue_free()") # <- DEBUG
	queue_free() # Se destruye a sí mismo
	print("Esta línea no debería verse") # <- DEBUG (queue_free() es inmediato)

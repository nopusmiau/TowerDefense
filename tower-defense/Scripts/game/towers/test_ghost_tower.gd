# tower_ghost.gd
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

func update_validity(is_valid: bool):
	if is_valid:
		sprite.modulate = Color(0, 1, 0, 0.5) # Verde semitransparente
	else:
		sprite.modulate = Color(1, 0, 0, 0.5) # Rojo semitransparente

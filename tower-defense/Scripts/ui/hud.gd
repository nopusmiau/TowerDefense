# hud.gd
extends CanvasLayer

@onready var gold_label: Label = $GoldLabel

func _ready():
	# Nos conectamos a la señal global de oro cambiado
	GameEvents.gold_changed.connect(_on_gold_changed)

func _on_gold_changed(new_gold: int):
	# Esta función se ejecuta cada vez que el GameManager emite "gold_changed"
	gold_label.text = "Oro: " + str(new_gold)
	print("HUD actualizado. Oro: ", new_gold) # Debug opcional

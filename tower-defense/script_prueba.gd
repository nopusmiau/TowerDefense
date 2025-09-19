extends Node
func _ready():
	GameEvents.gold_changed.connect(_on_gold_changed)
	GameEvents.gold_changed.emit(100) # Simula que ganaste 100 de oro

func _on_gold_changed(amount: int):
	print("¡El oro cambió! Ahora es: ", amount)

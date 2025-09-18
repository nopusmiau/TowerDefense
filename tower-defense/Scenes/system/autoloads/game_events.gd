extends Node
# Señales del Core Gameplay
signal game_started()
signal game_over(victory: bool)
signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)

# Señales de Economía y Progreso
signal gold_changed(new_amount: int) # Se emite cuando el oro cambia
signal lives_changed(new_amount: int) # Se emite cuando la vida del jugador cambia
signal score_changed(new_amount: int)

# Señales de Entidades del Juego
signal enemy_spawned(enemy_instance: Node2D)
signal enemy_died(enemy_instance: Node2D, reward: int) # Lleva la instancia y la recompensa
signal tower_placed(tower_instance: Node2D)
signal tower_sold(tower_instance: Node2D)
signal tower_selected(tower_instance: Node2D) # Para mostrar stats en UI
signal tower_deselected()

# Señales de UI
signal request_build_ui(tower_data) # El GameManager pide a la UI que muestre el menú de construcción
signal request_wave_start() # El botón de la UI pide iniciar una oleada

# Función de debug opcional, pero muy útil
func emit_debug_signal(signal_name: String, value):
	print("[GameEvents] Emitting: %s with value: %s" % [signal_name, str(value)])

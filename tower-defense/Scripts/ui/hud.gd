# hud.gd
extends CanvasLayer

@onready var gold_label: Label = $GoldLabel
@onready var live_label: Label = $HealthLabel
@onready var wave_button: Button = $WaveButton
@onready var tower_button: Button = $TowerButton


var test_tower_cost: int = 100

func _ready():
	# Nos conectamos a la señal global de oro cambiado
	GameEvents.gold_changed.connect(_on_gold_changed)
	GameEvents.lives_changed.connect(_on_lives_changed)
	wave_button.pressed.connect(_on_wave_button_pressed)
	tower_button.pressed.connect(_on_tower_button_pressed)
	tower_button.text = "Torre #1 ($%d)" % test_tower_cost

func _on_tower_button_pressed():
	GameEvents.request_build_mode.emit("test_tower", test_tower_cost)

func update_tower_button_availability(current_gold: int):
	if current_gold >= test_tower_cost:
		tower_button.disabled = false
	else:
		tower_button.disabled = true

func _on_wave_button_pressed():
	GameEvents.request_wave_start.emit()

func _on_gold_changed(new_gold: int):
	# Esta función se ejecuta cada vez que el GameManager emite "gold_changed"
	gold_label.text = "Oro: " + str(new_gold)
	print("HUD actualizado. Oro: ", new_gold) # Debug opcional

func _on_lives_changed(new_lives: int):
	live_label.text = "Vida: " + str(new_lives)
	print("HUD actualizado. Vida: ", new_lives)

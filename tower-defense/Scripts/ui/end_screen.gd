# end_screen.gd
extends CanvasLayer

@onready var label: Label = $CenterContainer/Panel/Label
@onready var retry_button: Button = $CenterContainer/Panel/VBoxContainer/RetryButton
@onready var exit_to_menu_button: Button = $CenterContainer/Panel/VBoxContainer/ExitToMenuButton

func _ready():
	hide() # Que inicie oculto
	retry_button.pressed.connect(_on_retry_pressed)
	exit_to_menu_button.pressed.connect(_on_exit_pressed)
	
	GameEvents.game_over.connect(_on_game_over)
	GameEvents.victory.connect(_on_victory)

func show_screen(victory: bool):
	show()
	if victory:
		label.text = "Victory!"
		retry_button.text = "Retry?"
		exit_to_menu_button.text = "Exit"
	else:
		label.text = "Game Over..."
		retry_button.text = "Retry?"
		exit_to_menu_button.text = "Exit"

func _on_retry_pressed():
	# Llamar al GameManager para reiniciar o cargar siguiente nivel
	GameEvents.request_restart.emit() # o request_next_level si es victory
	hide()

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://Scenes/ui/menus/main_menu.tscn")

func _on_game_over(victory: bool):
	show_screen(victory)

func _on_victory():
	show_screen(true)

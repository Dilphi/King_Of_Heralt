extends Node
@onready var pause_menu = $"../CanvasLayer/PauseMenu"
@onready var player: CharacterBody2D = $"../Player/Player"
@onready var level: Node2D = $".."

var save_pach = "user://savegame.save" 

var game_paused : bool = false

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		game_paused = !game_paused
	
	if game_paused == true:
		get_tree().paused = true
		pause_menu.show()
	else:
		get_tree().paused = false
		pause_menu.hide()

func _on_resume_pressed() -> void:
	game_paused = !game_paused


func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")

func save_game():
	var file = FileAccess.open(save_pach, FileAccess.WRITE)
	if file:
		file.store_var(Global.gold)  # Сохраняем количество монет
		file.store_var(player.position)  # Сохраняем позицию игрока как Vector2
		Db.update_coin_state(Global.gold)
		file.store_var(Global.health)  # Сохраняем количество монет
		
		# Сохраняем текущее время дня и номер дня
		file.store_var(level.day_count)  # Сохраняем номер дня
		file.store_var(level.state)      # Сохраняем состояние дня (MORNING, DAY, etc.)
		
		print("Игра сохранена.")
	else:
		print("Ошибка: невозможно открыть файл для сохранения.")

func load_game():
	if FileAccess.file_exists(save_pach):
		var file = FileAccess.open(save_pach, FileAccess.READ)
		if file:
			# Загружаем глобальные данные
			Global.gold = file.get_var()
			player.position = file.get_var()
			Global.health = file.get_var()
			
			# Загружаем текущее время дня и номер дня
			
			level.day_count = file.get_var()  # Восстанавливаем номер дня
			level.state = file.get_var()      # Восстанавливаем состояние дня
			
			# Обновляем интерфейс
			level.set_day_text()
			
			print("Игра загружена.")
		else:
			print("Ошибка: невозможно открыть файл для загрузки.")
	else:
		print("Файл сохранения не найден.")


func _on_save_pressed() -> void:
	save_game()
	game_paused = !game_paused
	
	
func _on_load_pressed() -> void:
	load_game()
	game_paused = !game_paused

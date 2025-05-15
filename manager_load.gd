extends Node
@onready var pause_menu = $"../CanvasLayer/PauseMenu"

@onready var level: Node2D = $"."

var save_pach = "user://savegame.save"

func load_game():
	if FileAccess.file_exists(save_pach):
		var file = FileAccess.open(save_pach, FileAccess.READ)
		if file:
			# Загружаем глобальные данные
			Global.gold = file.get_var()
			Global.player_pos = file.get_var()
			
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

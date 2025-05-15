extends Node2D

# Выход из игры
func _on_quit_pressed():
	get_tree().quit()

# Начало игры
func _on_play_pressed():
	get_tree().change_scene_to_file("res://level.tscn")
	Db.create_tables()

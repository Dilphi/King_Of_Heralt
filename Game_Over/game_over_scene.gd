extends Control
@onready var manager: Node = $Manager
@onready var player: CharacterBody2D = $Player/Player
@onready var level = $"."
var save_pach = "user://savegame.save" 
@onready var empty_coult: Label = $empty_coult
@onready var coin_coult: Label = $coin_coult

func _ready() -> void:
	# Получаем данные о смертях мобов и монетах
	var stats = Db.on_game_over()
	
	# Обновляем текст для label
	empty_coult.text = "Пало врагов от ваших рук: %s" % str(stats["mob_deaths"])
	coin_coult.text = "За всю игру собрано монет: " + str(stats["coins"])


func _on_quit_nemu_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")

func _on_load_pressed() -> void:
	get_tree().change_scene_to_file("res://level.tscn")  # Заменяем текущую сцену на новую

extends Control

@onready var manager: Node = $Manager
@onready var player: CharacterBody2D = $Player/Player
@onready var level = $"."
var save_pach = "user://savegame.save"
@onready var empty_coult: Label = $empty_coult
@onready var coin_coult: Label = $coin_coult

# Сюда сохраняем старт времени — получено, например, из Global при старте
var start_time := 0  # Установи это значение в момент запуска игры

# Также желательно передать текущий день из Global или через сигнал
var total_days := 0
var gold_collected := 0

func _ready() -> void:
	Global.day_count = Global.day_count if Global.day_count != null else 1
	Global.gold = Global.gold if Global.gold != null else 0
	Global.start_time = Global.start_time if Global.start_time != null else Time.get_ticks_msec() / 1000

	var now = Time.get_ticks_msec() / 1000
	var duration = now - Global.start_time

	var stats = Db.on_game_over(duration, Global.day_count, Global.gold)

	empty_coult.text = "Пало врагов от ваших рук: %s" % str(stats["mob_deaths"])
	coin_coult.text = "За всю игру собрано монет: " + str(stats["coins"])


func _on_quit_nemu_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")

func _on_load_pressed() -> void:
	get_tree().change_scene_to_file("res://level.tscn")

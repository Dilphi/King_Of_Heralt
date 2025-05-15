extends Node2D
@onready var play: Button = $Play
@onready var quit: Button = $Quit
@onready var stat: Control = $Stat
@onready var dead: Label = $Stat/VBoxContainer/Dead
@onready var kill: Label = $Stat/VBoxContainer/Kill
@onready var coins: Label = $Stat/VBoxContainer/Coins
@onready var rock: Label = $Stat/VBoxContainer/Rock
@onready var statistics: Button = $Statistics

# Выход из игры
func _on_quit_pressed():
	get_tree().quit()

# Начало игры
func _on_play_pressed():
	get_tree().change_scene_to_file("res://level.tscn")
	Db.create_tables()


func _on_statistics_pressed() -> void:
	play.visible = false 
	quit.visible = false
	stat.visible = true
	statistics.visible = false

	# Получаем статистику игрока
	var player_stats = Db.get_player_stats()
	var mob_stats = Db.get_mob_stats()

	var total_kills := 0
	for mob in mob_stats:
		total_kills += int(mob.get("deaths_by_player", 0))

	# Обновляем текст на метках
	var rocks = int(player_stats.get("collected_rocks", 0))
	rock.text = "Собрано камней: %d" % rocks
	dead.text = "Смертей игрока: %d" % player_stats.get("player_deaths", 0)
	kill.text = "Убито мобов: %d" % total_kills
	coins.text = "Собрано монет: %d" % player_stats.get("collected_gold", 0)


func _on_back_button_up() -> void:
	play.visible = true 
	quit.visible = true
	statistics.visible = true
	stat.visible = false

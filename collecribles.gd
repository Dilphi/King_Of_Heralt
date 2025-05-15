extends Node2D

var coin_preload = preload("res://coins/coin.tscn")
var rock_preload = preload("res://Collecribles/roock.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.connect("enemy_died", Callable(self, "_on_enemy_died"))
	Signals.connect("enemy_died_skelet", Callable(self, "_on_enemy_died_skelet"))

func _on_enemy_died(enemy_position):
	for i in randf_range(1,5):
		coin_spawn(enemy_position)
		await get_tree().create_timer(0.05).timeout

func coin_spawn(pos):
	var coin = coin_preload.instantiate()
	coin.position = pos
	call_deferred("add_child", coin)
	
func _on_enemy_died_skelet(position):
	for i in randf_range(1,5):
		rock_spawn(position)
		await get_tree().create_timer(0.05).timeout

func rock_spawn(pos):
	var rock = rock_preload.instantiate()
	rock.position = pos
	call_deferred("add_child", rock)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

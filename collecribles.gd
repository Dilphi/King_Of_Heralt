extends Node2D

var coin_preload = preload("res://coins/coin.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.connect("enemy_died", Callable(self, "_on_enemy_died"))

func _on_enemy_died(enemy_position):
	for i in randf_range(1,5):
		coin_spawn(enemy_position)
		await get_tree().create_timer(0.05).timeout

func coin_spawn(pos):
	var coin = coin_preload.instantiate()
	coin.position = pos
	call_deferred("add_child", coin)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node2D
@onready var mobs: Node2D = $".."
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var mushrrom_preload = preload("res://Mobs/mushroom.tscn")
var spawn_count = 0

func _ready() -> void:
	Signals.connect("day_time", Callable(self, "_on_time_changed"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_time_changed(state,day_count):
	spawn_count = 0
	var rng = randi_range(0,2)
	if state == 1:
		for i in (day_count + rng):
			animation_player.play("spawn")
			await animation_player.animation_finished
			spawn_count += 1
	if spawn_count == day_count + rng:
		animation_player.play("idle")
		

func mushrrom_spawn():
	var  mushrrom = mushrrom_preload.instantiate()
	mushrrom.position = Vector2(self.position.x,980)
	mobs.add_child(mushrrom)

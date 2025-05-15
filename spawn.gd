extends Node2D

@onready var mobs: Node2D = $".."
@onready var animation_player = $AnimationPlayer
var mushroom_preload: PackedScene = preload("res://Mobs/mushroom.tscn")
var skelet_preload: PackedScene = preload("res://skelets.tscn")

const MAX_SPAWN := 3

var spawned_day := false
var spawned_night := false

# Состояния времени суток из уровня
const MORNING = 0
const DAY     = 1
const EVENING = 2
const NIGHT   = 3

func _ready() -> void:
	Signals.connect("day_time", Callable(self, "_on_day_time_changed"))


func _on_day_time_changed(state: int, count: int) -> void:
	if state in [MORNING, DAY]:
		if spawned_day:
			return
		spawned_day = true
		spawned_night = false  # сбрасываем ночь

		var rng: int = randi_range(0, 2)
		var amount: int = min(MAX_SPAWN, count + rng)
		var spawned: int = 0

		while spawned < amount:
			animation_player.play("spawn")
			await animation_player.animation_finished
			spawn_mushroom()
			spawned += 1

		animation_player.play("idle")

	elif state == NIGHT:  # ✅ только в фазе NIGHT
		if spawned_night:
			return
		spawned_night = true
		spawned_day = false  # сбрасываем день

		var rng: int = randi_range(0, 2)
		var amount: int = min(MAX_SPAWN, count + rng)
		var spawned: int = 0

		while spawned < amount:
			animation_player.play("spawn_skelet")
			await animation_player.animation_finished
			spawn_skelet()
			spawned += 1

		animation_player.play("idle")


# ---------------------------------------------------------
# ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
# ---------------------------------------------------------
func spawn_mushroom() -> void:
	var mob := mushroom_preload.instantiate()
	mob.position = Vector2(position.x, 980)
	mobs.add_child(mob)


func spawn_skelet() -> void:
	var mob := skelet_preload.instantiate()
	mob.position = Vector2(position.x, 980)
	mobs.add_child(mob)

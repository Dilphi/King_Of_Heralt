extends Node2D

@onready var mobs: Node2D = $".."
@onready var animation_player = $AnimationPlayer
var mushroom_preload: PackedScene = preload("res://Mobs/mushroom.tscn")
var skelet_preload: PackedScene = preload("res://skelets.tscn")

const MAX_SPAWN := 3

var spawned_day := false
var spawned_night := false
var alive_skelets := 0  # 🔥 Счётчик живых скелетов

# Состояния времени суток из уровня
const MORNING = 0
const DAY     = 1
const EVENING = 2
const NIGHT   = 3

func _ready() -> void:
	Signals.connect("day_time", Callable(self, "_on_day_time_changed"))

func _on_day_time_changed(state: int, count: int) -> void:
	match state:
		MORNING, DAY:
			if spawned_day:
				return
			spawned_day = true
			spawned_night = false

			var rng: int = randi_range(0, 2)
			var amount: int = min(MAX_SPAWN, count + rng)
			var spawned: int = 0

			while spawned < amount:
				animation_player.play("spawn")
				await animation_player.animation_finished
				spawn_mushroom()
				spawned += 1

			animation_player.play("idle")

		NIGHT:
			if spawned_night or alive_skelets > 0:
				return
			spawned_night = true
			spawned_day = false

			var amount: int = 1
			var spawned: int = 0

			while spawned < amount:
				animation_player.play("spawn_skelet")
				await animation_player.animation_finished
				spawn_skelet()
				spawned += 1
				return
			animation_player.play("idle")
			

		EVENING:
			# Вечером ничего не делаем
			pass

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
	alive_skelets += 1

	# Подписываемся на сигнал mob_died
	if mob.has_signal("mob_died"):
		mob.connect("mob_died", Callable(self, "_on_skelet_died"))

func _on_skelet_died() -> void:
	alive_skelets -= 1
	if alive_skelets <= 0:
		# Можно снова спавнить скелетов в следующую ночь
		spawned_night = false

extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var health_text = $"../hp_text"
@onready var hp_anim = $"../HpAnim"

var base_health := 100
var max_health := base_health
var old_hp := max_health
var _health := max_health

# Свойство для здоровья
var health:
	get: return _health
	set(value):
		_health = clamp(value, 0, max_health)
		health_bar.value = _health
		var difference = _health - old_hp
		health_text.text = str(difference)
		old_hp = _health
		if difference < 0:
			hp_anim.play("damage_received")
		elif difference > 0:
			hp_anim.play("regen")

func _ready():
	health_text.modulate.a = 0  # Скрываем текст
	
	# Усиливаем здоровье: за каждые 10 монет +100% здоровья
	var health_multiplier = 1 + (Global.rock / 10.0)
	max_health = int(base_health * health_multiplier)
	health = max_health

	# Установка значений на полоске здоровья
	health_bar.max_value = max_health
	health_bar.value = health

# Метод для обработки восстановления здоровья
func _on_regen_timeout() -> void:
	# Базовое восстановление
	var regen := 10

	# Усиливаем восстановление за каждые 10 монет: +10 единиц
	var regen_bonus := int(Global.gold / 10) * 10
	regen += regen_bonus

	health += regen
	Global.health = health

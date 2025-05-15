extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var health_text = $"../hp_text"
@onready var hp_anim = $"../HpAnim"

var max_health = 100
var old_hp = max_health
var _health = max_health

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
	health = max_health          # Устанавливаем максимальное здоровье
	health_bar.max_value = max_health
	health_bar.value = health

# Метод для обработки восстановления здоровья
func _on_regen_timeout() -> void:
	health += 10
	Global.health = health
	

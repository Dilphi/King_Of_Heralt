extends CharacterBody2D

enum 
{
	IDLE,
	ATTACK,
	CHASE,
	DAMAGE,
	DEATH,
	RECOVER
}
#SetGet универсальная переменая
var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			DAMAGE:
				damage_state()
			DEATH:
				death_state()
			RECOVER:
				recover_state()
				
# Подключение скрипта базы данных
@onready var database = preload("res://db.gd").new()

@onready var animPlayer = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player = Vector2.ZERO
var direction = Vector2.ZERO
var damage = 30
var speed = 100

func _ready() -> void:
	state = CHASE

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	if state == CHASE:
		chase_state()
		
	move_and_slide()

	player = Global.player_pos

func _on_attack_range_body_entered(body):
	state = ATTACK

func idle_state():
	velocity.x = 0
	animPlayer.play("Idle")
	state = CHASE
	
func attack_state():
	velocity.x = 0
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	state = RECOVER

func chase_state():
	animPlayer.play("Run")
	direction = (player - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		$AttackDirection.rotation_degrees = 180
	else:
		sprite.flip_h = false
		$AttackDirection.rotation_degrees = 0
	
	velocity.x = direction.x * speed

func damage_state():
	velocity.x = 0
	damage_anim()
	animPlayer.play("Damage")
	await animPlayer.animation_finished
	state = IDLE

func death_state():
	velocity.x = 0
	Signals.emit_signal("enemy_died", position)
	animPlayer.play("Death")	
	await animPlayer.animation_finished
	database.add_mob_death("mushroom")  # Обновление счётчика смертей в базе данных
	queue_free()

func recover_state():
	velocity.x = 0
	animPlayer.play("Recover")
	await animPlayer.animation_finished
	state = IDLE
	
func _on_hit_box_area_entered(area):
	Signals.emit_signal("enemy_attack", damage)

func _on_mob_hp_no_healths():
	state = DEATH

func _on_mob_hp_damage_received():
	state = IDLE
	state = DAMAGE
	
func damage_anim():
	direction = (player - self.position).normalized()
	velocity.x = 0
	if direction.x < 0:
		velocity.x += 200
	elif direction.x > 0:
		velocity.x -= 200
	var tween= get_tree().create_tween()
	tween.tween_property(self, "velocity", Vector2.ZERO, 0.2)

func _on_run_timeout() -> void:
	speed = move_toward(speed, randi_range(120,160), 50)

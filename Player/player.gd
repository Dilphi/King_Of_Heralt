extends CharacterBody2D

enum 
{
	IDLE,
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	DAMAGE,
	DEATH
}
#Скорость передвежения и прыжка
const SPEED = 150.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
#Гравитация для 2д проекта
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#Чтобы постоянно не вызывать ветку анимации, @onready подхватывает нод при загрузке
@onready var database = preload("res://db.gd").new()
@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer
@onready var stats = $stats


var state = MOVE
var run_speed = 1
var combo = false
var attack_cooldown = false
var damage_basic = 10
var damage_multiplier = 1
var damage_current

func _ready():
	Signals.connect("enemy_attack", Callable(self, "_on_damage_received"))

#Если персонаж находится в прыжке или подении то на него действует гравитация
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if velocity.y > 0:
		animPlayer.play("Fall")

	# Усиливаем урон за каждое 10 золота: +100%
	damage_multiplier = 1 + (Global.gold / 10.0)
	Global.player_damage = damage_basic * damage_multiplier
	
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
		ATTACK3:
			attack3_state()
		BLOCK:
			block_state()
		DEATH:
			death_state()
		DAMAGE:
			damage_state()

	move_and_slide()
	Global.player_pos = self.position

	
	
func move_state():
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * run_speed
		if velocity.y == 0:
			if run_speed == 1:
				animPlayer.play("Walk")
			else:
				animPlayer.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animPlayer.play("Idle")
		#При движении влево
	if direction  == -1:
		$AttackDirection.rotation_degrees = 180
		anim.flip_h = true
	#При движении вправо
	elif direction == 1:
		anim.flip_h = false
		$AttackDirection.rotation_degrees = 0
	if Input.is_action_pressed("run"):
		run_speed = 2
	else:
		run_speed = 1
		
	if Input.is_action_pressed("block"):
		if velocity.x == 0:
			state = BLOCK
	if Input.is_action_just_pressed("attack") and attack_cooldown == false:
		state = ATTACK

func block_state():
	velocity.x = 0
	animPlayer.play("Block")
	if Input.is_action_just_released("block"):
		state = MOVE



func death_state():
	velocity.x = 0
	anim.play("Death")
	await get_tree().create_timer(0.5).timeout
	database.add_player_death()
	if get_tree() != null:
		get_tree().change_scene_to_file("res://Game_Over/game_over_scene.tscn")

func attack_state():
	damage_multiplier = 1
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK2
	velocity.x = 0
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	attack_freeze()
	state = MOVE

func attack2_state():
	damage_multiplier = 1.5
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK3
	animPlayer.play("Attack2")
	await animPlayer.animation_finished
	state = MOVE
	
func attack3_state():
	damage_multiplier = 2
	animPlayer.play("Attack3")
	await animPlayer.animation_finished
	state = MOVE

func combo1():
	combo = true
	await animPlayer.animation_finished
	combo = false
	
func attack_freeze():
	attack_cooldown = true
	await get_tree().create_timer(0.5).timeout
	attack_cooldown = false
	
func damage_state():
	animPlayer.play("Damage")
	await animPlayer.animation_finished
	state = MOVE

func _on_damage_received(enemy_damage):
	if state == BLOCK:
		enemy_damage /= 2
	else:
		state = DAMAGE
		damage_anim()
		
	stats.health -= enemy_damage
	if stats.health <= 0:
		stats.health = 0
		state = DEATH

func _on_hit_box_area_entered(area):
	Signals.emit_signal("player_attack", damage_current)

func damage_anim():
	velocity.x = 0
	self.modulate = Color(1,0,0,1)
	if $AnimatedSprite2D.flip_h == true:
		velocity.x += 200
	else:
		velocity.x -= 200
	var tween= get_tree().create_tween()
	tween.parallel().tween_property(self, "velocity", Vector2.ZERO, 0.2)
	tween.parallel().tween_property(self, "modulate", Color(1,1,1,1), 0.1)

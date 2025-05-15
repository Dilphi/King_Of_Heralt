extends CanvasLayer
@onready var gold_text: Label = $Control/PanelConteiner/HBoxContainer/gold_text
@onready var rock_text: Label = $Control/PanelConteiner/HBoxContainer/rock_text


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	gold_text.text = str(Global.gold)
	rock_text.text = str(Global.rock)

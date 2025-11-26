extends Control

@onready var base = $Base
@onready var knob = $Base/Knob 

@export var max_distance: float = 30.0 
@export var sensitivity: float = 10.0  

var is_active: bool = true
var default_center_pos: Vector2 = Vector2.ZERO

func _ready():
	default_center_pos = (base.size / 2) - (knob.size / 2)	
	knob.position = default_center_pos

func _process(delta):
	if not is_active:
		return
	var accelerometer = Input.get_accelerometer()
	var direction = Vector2(accelerometer.x, -accelerometer.y)
	
	if direction.length() < 0.1:
		direction = Vector2.ZERO
	var target_vector = direction * sensitivity
	
	if target_vector.length() > max_distance:
		target_vector = target_vector.normalized() * max_distance
	
	knob.position = default_center_pos + target_vector

func stop():
	is_active = false
	var tween = get_tree().create_tween()
	tween.tween_property(knob, "position", default_center_pos, 0.2)

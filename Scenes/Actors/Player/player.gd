extends CharacterBody2D
class_name  Player

# Export Vars

@export var SpeedParam : float;
@export_range(0, 1) var AccelerationParam : float;

# Object Vars

var up : bool = false;
var down : bool = false;
var left : bool = false;
var right : bool = false;

var movement_dir : Vector2 = Vector2.ZERO;


# Processes

func _physics_process(_delta: float) -> void:
	
	#region Check inputs
	up = Input.is_action_pressed("ui_up");
	down = Input.is_action_pressed("ui_down");
	left = Input.is_action_pressed("ui_left");
	right = Input.is_action_pressed("ui_right");
	#endregion
	#region Set movement direction
	movement_dir = Vector2.ZERO;
	if(up):
		movement_dir.y -= 1;
	if(down):
		movement_dir.y += 1;
	if(left):
		movement_dir.x -= 1;
	if(right):
		movement_dir.x += 1;
	movement_dir = movement_dir.normalized();
	#endregion
	
	velocity = lerp(velocity, movement_dir * SpeedParam, AccelerationParam);
	move_and_slide();


# Functions

func initialize(spawn_position : Vector2, color : Color = Color.WHITE) -> void:
	global_position = spawn_position;
	modulate = color;

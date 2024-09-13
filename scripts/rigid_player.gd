extends RigidBody3D

var mouse_sense := 0.001
var twist := 0.0
var pitch := 0.0
var current_jump = 0
@export var max_jumps = 2
@export var jump_height = 7000
@onready var floor_checker = $RayCast3D as RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready():
	self.continuous_cd = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_jump = max_jumps


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	jump()
	$visual.rotation.y = $TwistPivot.rotation.y
	var input := Vector3.ZERO
	input.x = Input.get_axis("left","right")
	input.z = Input.get_axis("forward","backward")
	apply_central_force($TwistPivot.basis * input * 20000.0 * delta)
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	$TwistPivot.rotate_y(twist)
	$TwistPivot/PitchPivot.rotate_x(pitch)
	$TwistPivot/PitchPivot.rotation.x = clamp($TwistPivot/PitchPivot.rotation.x, deg_to_rad(-30),deg_to_rad(30))
	twist = 0.0
	pitch = 0.0
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist = - event.relative.x * mouse_sense
			pitch = - event.relative.y * mouse_sense
func jump():
	if Input.is_action_just_pressed("ui_accept") and current_jump > 0:
		apply_central_force(Vector3.UP * jump_height)
		current_jump -= 1
	if floor_checker.is_colliding():
		current_jump = max_jumps

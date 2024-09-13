extends CharacterBody3D

@export var run_speed := 15
@export var walk_speed := 5
var SPEED = 0
const JUMP_VELOCITY = 10
var jumping := false
@export var cam_sensitivity := 0.05
@onready var pivot = $CamOrigin
@onready var animations = $AnimationTree

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CamOrigin/SpringArm3D.add_excluded_object(self)
	SPEED = walk_speed
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * cam_sensitivity))
		pivot.rotate_x(deg_to_rad(-event.relative.y * cam_sensitivity))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-45), deg_to_rad(45))
func _physics_process(delta: float) -> void:
	var playback = animations.get("parameters/playback")
	var current_animation = playback.get_current_node()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	print("JUMP STATUS: " ,jumping)
	# Handle jump.
	if current_animation == "FallingToLanding":
		velocity = Vector3.ZERO
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !jumping:
		jumping = true
		print("JUMP!")
		$AnimationTree["parameters/conditions/is_jumping"] = true
	
	if !jumping:
		$AnimationTree["parameters/conditions/is_jumping"] = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if current_animation != "FallingToLanding":
		var input_dir := Input.get_vector("right", "left", "backward", "forward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	if Input.is_action_pressed("run") && is_on_floor() && current_animation !="FallingToLanding":
		SPEED = run_speed
	else:
		SPEED = walk_speed
	
	print("Current animation/state: ", current_animation)
	animate()
	move_and_slide()
func animate():
	
	print("Velocity: ", velocity.length())
	$AnimationTree["parameters/conditions/is_idle"] = velocity.length() <= 0
	#Change the speeds to walk and run speed
	$AnimationTree["parameters/conditions/is_walking"] = velocity.length() >= 5 && velocity.length() < run_speed -1 && !fall_checker()
	$AnimationTree["parameters/conditions/is_running"] = velocity.length() >= run_speed - 1 && !fall_checker()
	$AnimationTree["parameters/conditions/is_falling"] = fall_checker()
	$AnimationTree["parameters/conditions/is_landing"] = !fall_checker()
func fall_checker() -> bool:
	if !is_on_floor() and !jumping:
		#print("Falling")
		return true
	else:
		return false

func jump():
	print("Jump Status: " , jumping)
	velocity.y = JUMP_VELOCITY
	jumping = false

	

extends AnimatableBody3D
var spawn := Vector3()
var end := Vector3()
enum Mode{
	Diagonal,
	Vertical,
	X_Move,
	Z_Move
}
enum Movement_Mode{
	Smooth,
	Standard
}
var lerp_worker := 0.0
var moving_to_end := true
@export var mode: Mode 
@export var movemet_mode: Movement_Mode = Movement_Mode.Smooth
@export var x_variation := float()
@export var y_variation := float()
@export var z_variation := float()
@export var speed := 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn = self.global_position
	match mode:
		Mode.Diagonal:
			end = Vector3(x_variation,spawn.y,z_variation)
		Mode.Vertical:
			end = Vector3(spawn.x,y_variation,spawn.z)
		Mode.X_Move:
			end = Vector3(x_variation,spawn.y,spawn.z)
		Mode.Z_Move:
			end = Vector3(spawn.x,spawn.y,z_variation)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match movemet_mode:
		Movement_Mode.Smooth:
			if moving_to_end:
				lerp_worker += speed * delta
			else:
				lerp_worker -= speed * delta
			global_position = lerp(spawn,end,clamp(lerp_worker,0.0,1.0))
			if lerp_worker >= 1.0:
				moving_to_end = false
			elif lerp_worker <= 0.0:
				moving_to_end = true
		Movement_Mode.Standard:
			pass

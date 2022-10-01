extends KinematicBody

export var speed := 14
export var jump_strength := 20
export var gravity := 50
export var damage := 25

export(NodePath) var animationTree

onready var _anim_tree = get_node(animationTree) 

var velocity := Vector3.ZERO
var snap_vector := Vector3.DOWN

onready var spring_arm: SpringArm = $SpringArm
onready var model: Spatial = $AstronautSkin
onready var aimcast: RayCast = $SpringArm/Camera/RayCast

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm.rotation.y).normalized()
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	velocity.y -= gravity * delta
	
	var just_landed := is_on_floor() and snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	if is_jumping:
		velocity.y = jump_strength
		snap_vector = Vector3.ZERO
	elif just_landed:
		snap_vector = Vector3.DOWN
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)
	
	if velocity.length() > 0.2:
		var look_direction = Vector2(velocity.z, velocity.x)
		model.rotation.y = look_direction.angle()
		
	if Input.is_action_just_pressed("fire"):
		if aimcast.is_colliding():
			var target = aimcast.get_collider()
			if target.is_in_group("Enemy"):
				print("shot enemy");
				target.health -= damage
		
	if Input.is_action_pressed("forward") or Input.is_action_pressed("back") or Input.is_action_pressed("right") or Input.is_action_pressed("left"):
		_anim_tree["parameters/playback"].travel("move")
		print("moving")
	elif Input.is_action_pressed("jump"):
		_anim_tree["parameters/playback"].travel("jump")
		print("jumping")
	else:
		_anim_tree["parameters/playback"].travel("idle")
		print("idle")
	
func _process(_delta: float) -> void:
	spring_arm.translation = translation
	


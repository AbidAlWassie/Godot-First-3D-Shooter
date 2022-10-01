extends KinematicBody

var health = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if health <= 0:
		queue_free()

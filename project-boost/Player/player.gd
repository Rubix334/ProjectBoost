extends RigidBody3D
class_name Player

@export_range(750,2500) var force := 1000.0
@export var TorqueThrust := 100

var transitioning := false

func _process(delta: float) -> void:
	if not transitioning:
		if Input.is_action_pressed("boost"):
			apply_central_force(basis.y * delta * force)
		if Input.is_action_pressed("rotateL"):
			apply_torque(Vector3(0.0,0.0,delta*TorqueThrust))
		if Input.is_action_pressed("rotateR"):
			apply_torque(Vector3(0,0,-delta*TorqueThrust))

func crash_sequence() -> void:
	transitioning = true
	print("KABOOM")
	await get_tree().create_timer(2.5).timeout
	get_tree().reload_current_scene.call_deferred()

func complete_level(next_level_file) -> void:
	transitioning = true
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file.call_deferred(next_level_file)

func _on_body_entered(body: Node) -> void:
	## Detects if the rockets hits any object in these groups and prints accordingly
	if "Goal" in body.get_groups():
		print("You Win!")
		if body.file_path:
			complete_level(body.file_path)
		else:
			print("No next level found!")
	if "Hazard" in body.get_groups():
		crash_sequence()

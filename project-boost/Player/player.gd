extends RigidBody3D
class_name Player

@export_range(750,2500) var force := 1000.0
@export var TorqueThrust := 100
@export var starting_fuel := 100

var transitioning := false
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var success_audio: AudioStreamPlayer3D = $SuccessAudio
@onready var explosion_audio: AudioStreamPlayer3D = $ExplosionAudio
@onready var main_booster: GPUParticles3D = $MainBooster
@onready var right_booster: GPUParticles3D = $RightBooster
@onready var left_booster: GPUParticles3D = $LeftBooster
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

var ui : CanvasLayer 

var fuel : int:
	set(new_fuel):
		fuel = new_fuel
		ui.update_fuel(new_fuel)

func _ready() -> void:
	ui = get_tree().get_first_node_in_group("UI")
	fuel = starting_fuel

func _process(delta: float) -> void:
	if not transitioning:
		if Input.is_action_pressed("boost") and fuel > 0:
			fuel -= 0.5
			apply_central_force(basis.y * delta * force)
			main_booster.emitting = true
			if not rocket_audio.is_playing():
				rocket_audio.play()
		else:
			main_booster.emitting = false
			rocket_audio.stop()
		if Input.is_action_pressed("rotateL"):
			apply_torque(Vector3(0.0,0.0,delta*TorqueThrust))
			right_booster.emitting = true
		else:
			right_booster.emitting = false
		if Input.is_action_pressed("rotateR"):
			apply_torque(Vector3(0,0,-delta*TorqueThrust))
			left_booster.emitting = true
		else:
			left_booster.emitting = false

func crash_sequence() -> void:
	transitioning = true
	explosion_particles.emitting = true
	explosion_audio.play()
	rocket_audio.stop()
	main_booster.emitting = false
	right_booster.emitting = false
	left_booster.emitting = false
	print("KABOOM")
	await get_tree().create_timer(2.5).timeout
	get_tree().reload_current_scene.call_deferred()

func complete_level(next_level_file) -> void:
	transitioning = true
	success_particles.emitting = true
	success_audio.play()
	rocket_audio.stop()
	main_booster.emitting = false
	right_booster.emitting = false
	left_booster.emitting = false
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file.call_deferred(next_level_file)

func _on_body_entered(body: Node) -> void:
	## Detects if the rockets hits any object in these groups and prints accordingly
	if not transitioning:
		if "Goal" in body.get_groups():
			print("You Win!")
			if body.file_path:
				complete_level(body.file_path)
			else:
				print("No next level found!")
		if "Hazard" in body.get_groups():
			crash_sequence()

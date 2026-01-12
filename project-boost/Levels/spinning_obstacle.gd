extends CSGBox3D

@export_range(0.01,0.05) var SpinSpeed := 0.02

func _process(delta: float) -> void:
	rotate_z(SpinSpeed)

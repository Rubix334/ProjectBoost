extends CanvasLayer
@onready var label: Label = $MarginContainer/CenterContainer/Label

func update_fuel(amt):
	label.text = "FUEL: " + str(amt)

extends Node2D

var IsOnButton = false
@onready var Field = $"../Field"


func _input(event):
	if self.visible:
		if event is InputEventMouseButton and event.is_pressed():
			if IsOnButton:
				Field.call("Borders")
				


func _on_label_mouse_entered():
	IsOnButton = true


func _on_label_mouse_exited():
	IsOnButton = false

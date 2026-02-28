extends Node2D

var IsOnButton = false
@onready var Field = $"../Field"


func _input(event):
	if self.visible:
		if event is InputEventMouseButton and event.is_pressed():
			if IsOnButton:
				Field.call("BorderMode")


func _on_button_sb_mouse_exited():
	IsOnButton = false


func _on_button_sb_mouse_entered():
	IsOnButton = true

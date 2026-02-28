extends Node2D

var Continue = false
var Restart = false
var Main = false
@onready var Field = $"../Field"
@onready var StartButton = $"../Buttons"
# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false

func OpenMenu(Yes : bool):
	if Yes:
		self.visible = true
	else:
		self.visible = false


func _input(event):
	if self.visible:
		if event is InputEventMouseButton and event.is_pressed():
			
			if Continue:
				doAction()
				Field.call("Pauze")
			elif Restart:
				Field.call("Kill")
				doAction()
				StartButton.call("OnStart")
			elif Main:
				doAction()
				Field.call("Kill")


func doAction():
	self.visible = false
	await get_tree().create_timer(0.5).timeout


func ContinueEnter():
	Continue = true


func RestartEnter():
	Restart = true


func MainEntered():
	Main = true


func ContinueExit():
	Continue = false


func RestartExit():
	Restart = false


func MainExit():
	Main = false


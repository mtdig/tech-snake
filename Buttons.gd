extends Node2D

var IsOnButtonStart = false
var IsOnResetButton = false
@onready var Field = $"../Field"
@onready var Score = $"../Score"
@onready var LabelsToHide = [
	$"../BorderSelection", 
	$"../ShowBGGrid", 
	$"../SpawnMoreBorders", 
	$"../Teleportation", 
]
func _ready():
	self.visible = true
	Show(true)

func _input(event):
	if self.visible:
		if event is InputEventMouseButton and event.is_pressed():
			if IsOnButtonStart:
				OnStart()
			if IsOnResetButton:
				get_tree().reload_current_scene()


func OnStart():
	self.visible = false
	Show(false)
	await get_tree().create_timer(0.5).timeout
	Field.call("OnStart")


func _on_label_mouse_entered():
	IsOnButtonStart = true


func _on_label_mouse_exited():
	IsOnButtonStart = false


func ShowMenu():
	self.visible = true
	Show(true)


func Show(what : bool):
	for entity in LabelsToHide:
		entity.visible = what


func _on_reset_game_mouse_entered():
	IsOnResetButton = true


func _on_reset_game_mouse_exited():
	IsOnResetButton = false

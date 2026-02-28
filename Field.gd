extends TileMap

#settings
@export var fieldsize = Vector2i(46, 25)
@export var Delay = 0.1

#in-game setting
var BordersOn = false
var GridShow = true
var SummonBorders = false
var Teleportation = false


@onready var Score = $"../Score/Label"
var ScoreInt = 0
@onready var Balls = [$"../BALL", $"../BALL2"]
@onready var TotalChildren = Balls[0].get_child_count() - 1
@onready var FoodSkin = randi_range(0, TotalChildren-1)
@onready var PauzeScreen = $"../PauzeMenu"

var ExtraWalls = [] 

#0: BG
#1: Head
#2-11: Tail
#12: Food
#13: Extra borders
var Grid := []

const SNAKEHEAD = Vector2i(0, 0)
const SNAKEBODY = [
	Vector2i(2, 0), Vector2i(2, 1), 
	Vector2i(2, 2), Vector2i(2, 3), Vector2i(2, 4), Vector2i(2, 5),
	Vector2i(2, 6), Vector2i(2, 7), Vector2i(2, 8), Vector2i(2, 9)
]
const BORDER = Vector2i(1, 1)
var BG = Vector2i(1, 2)

var PosList = []
var Snek = []
var IsAlive := false
var pauze = false
var FoodPos = []

# 0 is up, 1 is right, 2 is down and 3 is left
var Orientations = []


func FieldClearance(End : bool):
	for i in range(fieldsize.x):
		for j in range(fieldsize.y):
			Grid[i][j] = 0
			if End:
				set_cell(0, Vector2i(i+1, j+1), 0, BORDER)
			else:
				set_cell(0, Vector2i(i+1, j+1), 0, BG)


func OnStart():
	ScoreInt = 0
	IsAlive = true
	Orientations = [0]
	PosList = [Vector2i(fieldsize.x/2, fieldsize.y/2)]
	Snek = [SNAKEHEAD]
	
	for x in range(fieldsize.x):
		var YList = []
		for y in range(fieldsize.y):
			YList.append(0)
		Grid.append(YList)
	
	GenTailPiece()
	GenTailPiece()
	FieldClearance(false)
	
	for i in range(len(PosList)):
		set_cell(0, PosList[i], 0, Snek[i])
		Grid[PosList[i].x][PosList[i].y] = 1
	
	GenFood()
	Move()
	
	while IsAlive:
		await get_tree().create_timer(Delay).timeout
		if !pauze and IsAlive:
			Move()


func GenFood():
	if len(FoodPos) == 0:
		FoodPos.append(Vector2i(0, 0))
		
	if Teleportation and len(FoodPos) == 1:
		FoodPos.append(Vector2i(0, 0))
	Score.text = str(ScoreInt)
	
	
	for i in range(len(FoodPos)):
		if SummonBorders:
			var tempFood = Vector2i(randi_range(0, fieldsize.x-1),randi_range(0, fieldsize.y-1))
			if len(ExtraWalls) == 0:
				FoodPos[i] = tempFood
			else:
				var CanGo = true
				for j in range(len(ExtraWalls)):
					if tempFood == ExtraWalls[j]:
						i-=1
						CanGo = false
						continue
				if CanGo:
					FoodPos[i] = tempFood
		else:
			FoodPos[i] = Vector2i(randi_range(0, fieldsize.x-1),randi_range(0, fieldsize.y-1))
					
					
	Balls[0].position.x = (FoodPos[0].x+1.5)*16
	Balls[0].position.y = (FoodPos[0].y+1.5)*16
	
	Balls[0].get_child(FoodSkin).set("visible", false)
	if Teleportation: Balls[1].get_child(FoodSkin).set("visible", false)
	FoodSkin = randi_range(0, TotalChildren-1)
	
	if Teleportation:
		Balls[1].position.x = (FoodPos[1].x+1.5)*16
		Balls[1].position.y = (FoodPos[1].y+1.5)*16
		Balls[1].get_child(FoodSkin).set("visible", true)
	
	
	Balls[0].get_child(FoodSkin).set("visible", true)
	if SummonBorders:
		if ScoreInt != 0 and ScoreInt%2 == 1:
			for i in range(1):
				var canContinue = true
				var tempWall = Vector2i(randi_range(0, fieldsize.x-1),randi_range(0, fieldsize.y-1))
				for j in range(len(ExtraWalls)):
					if tempWall == ExtraWalls[j]:
						i-=1
						canContinue = false
						continue
				for j in range(len(FoodPos)):
					if !canContinue or FoodPos[j] == tempWall:
						i-=1
						continue
				if canContinue:
					ExtraWalls.append(tempWall)


func GenTailPiece():
	Orientations.append(Orientations[len(Orientations)-1])
	var Tempx = 0
	var Tempy = 0
	
	match Orientations[len(Orientations)-1]:
		0:
			Tempy = 1
			Snek.append(SNAKEBODY[2])
		1:
			Tempx = -1
			Snek.append(SNAKEBODY[4])
		2:
			Tempy = -1
			Snek.append(SNAKEBODY[3])
		3:
			Tempx = 1
			Snek.append(SNAKEBODY[5])
	
	PosList.append(Vector2i(PosList[len(PosList)-1].x+Tempx, PosList[len(PosList)-1].y+Tempy))


func _process(_delta):
	if IsAlive:
		if !pauze:
			if Input.is_action_just_pressed("ui_left"):
				if Orientations[0] != 1 and Orientations[1] != 1:
					Orientations[0] = 3
			elif Input.is_action_just_pressed("ui_right"):
				if Orientations[0] != 3 and Orientations[1] != 3:
					Orientations[0] = 1
			elif Input.is_action_just_pressed("ui_up"):
				if Orientations[0] != 2 and Orientations[1] != 2:
					Orientations[0] = 0
			elif Input.is_action_just_pressed("ui_down"):
				if Orientations[0] != 0 and Orientations[1] != 0:
					Orientations[0] = 2
		if Input.is_action_just_pressed("space"):
			Pauze()


func Move():
	FieldClearance(false)
	
	for i in range(len(FoodPos)):
		Grid[FoodPos[i].x][FoodPos[i].y] = 12
	
	var Temp = PosList[0]
	
	match Orientations[0]:
		0:
			Temp.y -= 1
		1:
			Temp.x += 1
		2:
			Temp.y += 1
		3:
			Temp.x -= 1
			
	for i in range(len(PosList)-1, 0, -1):
		PosList[i] = PosList[i-1]
		Orientations[i] = Orientations[i-1]
		
		var tempR : int
		
		if Orientations[i-1] == 0 and i == len(Orientations)-1:
			tempR = 4
		elif Orientations[i-1] == 1 and i == len(Orientations)-1:
			tempR = 6
		elif Orientations[i-1] == 2 and i == len(Orientations)-1:
			tempR = 5
		elif Orientations[i-1] == 3 and i == len(Orientations)-1:
			tempR = 7
		
		elif Orientations[i-1] == 0 and Orientations[i+1] == 0 or Orientations[i-1] == 2 and Orientations[i+1] == 2:
			tempR = 2
		elif Orientations[i-1] == 1 and Orientations[i+1] == 1 or Orientations[i-1] == 3 and Orientations[i+1] == 3:
			tempR = 3
		
		elif Orientations[i-1] == 0 and Orientations[i+1] == 1 or Orientations[i-1] == 3 and Orientations[i+1] == 2:
			tempR = 11
		elif Orientations[i-1] == 1 and Orientations[i+1] == 2 or Orientations[i-1] == 0 and Orientations[i+1] == 3:
			tempR = 8
		elif Orientations[i-1] == 3 and Orientations[i+1] == 0 or Orientations[i-1] == 2 and Orientations[i+1] == 1:
			tempR = 10
		elif Orientations[i-1] == 1 and Orientations[i+1] == 0 or Orientations[i-1] == 2 and Orientations[i+1] == 3:
			tempR = 9
		Grid[PosList[i].x][PosList[i].y] = tempR
	
	
	
	PosList[0] = Temp
	
	if SummonBorders and len(ExtraWalls) > 0:
		for wall in ExtraWalls:
			Grid[wall.x][wall.y] = 13
	
	
	if PosList[0].x > fieldsize.x-1 or PosList[0].x < 0 or PosList[0].y > fieldsize.y-1 or PosList[0].y < 0:
		if BordersOn:
			print("Death by border")
			Kill()
			return
		else:
			if PosList[0].x > fieldsize.x-1:
				PosList[0].x = 0
			elif PosList[0].x < 0:
				PosList[0].x = fieldsize.x-1
			elif PosList[0].y > fieldsize.y-1:
				PosList[0].y = 0
			elif PosList[0].y < 0:
				PosList[0].y = fieldsize.y-1
	
	
	if Grid[PosList[0].x][PosList[0].y] == 13 and SummonBorders:
		print("Death by some extra walls")
		Kill()
		return
	for i in range(1, len(PosList)):
		if PosList[0] == PosList[i]:
			print("Death by tail")
			Kill()
			return

	if Grid[PosList[0].x][PosList[0].y] == 12:
		if Teleportation:
			if PosList[0] == FoodPos[0]:
				Grid[FoodPos[1].x][FoodPos[1].y] = 0
				PosList[0] = FoodPos[1]
			else:
				Grid[FoodPos[0].x][FoodPos[0].y] = 0
				PosList[0] = FoodPos[0]
		ScoreInt+=1
		GenFood()
		GenTailPiece()
	
	
	Grid[PosList[0].x][PosList[0].y] = 1
	
	for i in range(fieldsize.x):
		for j in range(fieldsize.y):
			var UsedTile = BG
			
			match Grid[i][j]:
				1:
					UsedTile = Vector2i(SNAKEHEAD.x, SNAKEHEAD.y+Orientations[0])
				2:
					UsedTile = SNAKEBODY[0]
				3:
					UsedTile = SNAKEBODY[1]
				4:
					UsedTile = SNAKEBODY[2]
				5:
					UsedTile = SNAKEBODY[3]
				6:
					UsedTile = SNAKEBODY[4]
				7:
					UsedTile = SNAKEBODY[5]
				8:
					UsedTile = SNAKEBODY[6]
				9:
					UsedTile = SNAKEBODY[7]
				10:
					UsedTile = SNAKEBODY[8]
				11:
					UsedTile = SNAKEBODY[9]
				12:
					UsedTile = BG
				13:
					UsedTile = BORDER
			set_cell(0, Vector2i(i+1, j+1), 0, UsedTile)


func Kill():
	IsAlive = false
	pauze = false
	Balls[0].position = Vector2i(1000, 1000)
	if Teleportation:
		Balls[1].position = Vector2i(1000, 1000)
	Orientations = [0]
	PosList = [Vector2i(fieldsize.x/2, fieldsize.y/2)]
	Snek = [SNAKEHEAD]
	$"../Buttons".call("ShowMenu")
	FieldClearance(true)
	ExtraWalls.clear()
	
	for i in range(2):
		Borders()
		ShowGrid()
		BorderMode()
		TeleportationF()


func Borders():
	BordersOn = !BordersOn
	
	if BordersOn:
		set_cell(0, Vector2i(35, 4), 0, Vector2i(0, 5))
		set_cell(0, Vector2i(36, 4), 0, Vector2i(1, 5))
	else:
		set_cell(0, Vector2i(35, 4), 0, Vector2i(0, 6))
		set_cell(0, Vector2i(36, 4), 0, Vector2i(1, 6))


func ShowGrid():
	GridShow = !GridShow
	if GridShow:
		set_cell(0, Vector2i(35, 8), 0, Vector2i(0, 5))
		set_cell(0, Vector2i(36, 8), 0, Vector2i(1, 5))
		BG = Vector2i(1, 2)
	else:
		set_cell(0, Vector2i(35, 8), 0, Vector2i(0, 6))
		set_cell(0, Vector2i(36, 8), 0, Vector2i(1, 6))
		BG = Vector2i(1, 0)


func BorderMode():
	SummonBorders = !SummonBorders
	
	if SummonBorders:
		set_cell(0, Vector2i(35, 12), 0, Vector2i(0, 5))
		set_cell(0, Vector2i(36, 12), 0, Vector2i(1, 5))
	else:
		set_cell(0, Vector2i(35, 12), 0, Vector2i(0, 6))
		set_cell(0, Vector2i(36, 12), 0, Vector2i(1, 6))


func TeleportationF():
	Teleportation = !Teleportation
	
	if Teleportation:
		set_cell(0, Vector2i(35, 16), 0, Vector2i(0, 5))
		set_cell(0, Vector2i(36, 16), 0, Vector2i(1, 5))
	else:
		set_cell(0, Vector2i(35, 16), 0, Vector2i(0, 6))
		set_cell(0, Vector2i(36, 16), 0, Vector2i(1, 6))


func Pauze():
	pauze = !pauze
	if pauze:
		PauzeScreen.call("OpenMenu", true)
	else:
		PauzeScreen.call("OpenMenu", false)

extends Node3D

@export var enemyRoot: Node3D
@export var enemyTypes: Array[PackedScene]

@export var enabled = true
@export var spawnTime = 1.0
var spawnTimer = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if enemyRoot == null:
		enemyRoot = get_tree().current_scene


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !enabled:return
	
	spawnTimer+= delta
	if spawnTimer > spawnTime:
		spawnTimer=0
		spawnEnemy()
	pass

func spawnEnemy():
	print(Globals.max_mobs)
	if enemyTypes.is_empty():return
	if Globals.mob_count > Globals.max_mobs :return
	var selectedMob = enemyTypes.pick_random()
	var mob = selectedMob.instantiate()
	add_child(mob)

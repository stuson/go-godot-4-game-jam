extends Node
class_name Spawn

export(PackedScene) var Enemy
export(int) var num_enemies = 1
export var spawn_interval: float = 0.1
var time_since_spawn: float
var remaining_enemies: int

func _ready():
	remaining_enemies = num_enemies

func get_spawn_count(delta: float) -> int:
	time_since_spawn += delta
	var spawn_count = 0
	while time_since_spawn > spawn_interval and remaining_enemies > 0:
		spawn_count += 1
		remaining_enemies -= 1
		time_since_spawn -= spawn_interval
	return spawn_count

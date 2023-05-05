extends Node

onready var waves = $Waves.get_children()
onready var spawn_timer = $SpawnTimer

var current_wave_idx = -1
var current_wave: Wave
var enemies_to_spawn_remaining
var enemies_killed = 0

func _ready() -> void:
    spawn_next_wave()

func spawn_next_wave():
    enemies_killed = 0
    current_wave_idx += 1
    if current_wave_idx < waves.size():
        current_wave = waves[current_wave_idx]
        enemies_to_spawn_remaining = current_wave.num_enemies
        spawn_timer.wait_time = current_wave.spawn_interval
        spawn_timer.start()

func _on_SpawnTimer_timeout() -> void:
    if enemies_to_spawn_remaining <= 0:
        spawn_timer.stop()
    else:
        var enemy: Node2D = current_wave.Enemy.instance()
        enemy.global_translate(get_spawn_pos())
        enemy.get_node("HpManager").connect("die", self, "_on_Enemy_die")
        get_tree().current_scene.add_child(enemy)
        enemies_to_spawn_remaining -= 1

func get_spawn_pos() -> Vector2:
    randomize()
    var spawn_quadrant = randi() % 4
    var view = get_viewport()
    
    match spawn_quadrant:
        0:
            return Vector2(-5, rand_range(-5, view.size.y + 5))
        1:
            return Vector2(view.size.x + 5, rand_range(-5, view.size.y + 5))
        2:
            return Vector2(rand_range(-5, view.size.x + 5), -5)
        3:
            return Vector2(rand_range(-5, view.size.x + 5), view.size.y + 5)
        _:
            return Vector2(-5, -5)
    
func _on_Enemy_die() -> void:
    print("he deed")
    enemies_killed += 1
    
    if enemies_killed >= current_wave.num_enemies:
        spawn_next_wave()

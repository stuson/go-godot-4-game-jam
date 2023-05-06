extends Node

onready var waves = $Waves.get_children()
onready var spawn_timer = $SpawnTimer
onready var wave_delay_timer = $WaveDelayTimer

var current_wave_idx = -1
var current_wave: Wave
var enemies_to_spawn_remaining
var enemies_killed = 0

signal new_wave_spawned
signal enemies_to_kill_updated
signal wave_cleared

func _ready() -> void:
    trigger_next_wave()

func trigger_next_wave() -> void:
    wave_delay_timer.start()

func spawn_next_wave():
    enemies_killed = 0
    current_wave_idx += 1
    if current_wave_idx < waves.size():
        current_wave = waves[current_wave_idx]
        enemies_to_spawn_remaining = current_wave.num_enemies
        spawn_timer.wait_time = current_wave.spawn_interval
        spawn_timer.start()
        emit_signal("new_wave_spawned", current_wave_idx, current_wave.num_enemies)

func _on_SpawnTimer_timeout() -> void:
    if enemies_to_spawn_remaining <= 0:
        spawn_timer.stop()
    else:
        var enemy: Node2D = current_wave.Enemy.instance()
        var stats = enemy.get_node("Stats")
        stats.connect("die", self, "_on_Enemy_die")
        get_tree().current_scene.add_child(enemy)
        enemy.global_translate(get_spawn_pos())
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
    enemies_killed += 1
    emit_signal("enemies_to_kill_updated", current_wave.num_enemies - enemies_killed)
    
    if enemies_killed >= current_wave.num_enemies:
        emit_signal("wave_cleared")


func _on_WaveDelayTimer_timeout() -> void:
    spawn_next_wave()


func _on_UpgradesMenu_upgrade_selected() -> void:
    trigger_next_wave()

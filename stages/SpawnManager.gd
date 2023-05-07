extends Node

onready var waves = $Waves.get_children()
onready var spawn_timer = $SpawnTimer
onready var wave_delay_timer = $WaveDelayTimer

var current_wave_idx = -1
var current_wave: Wave
var spawn_groups: Array
var current_group_idx = -1
var current_group: SpawnGroup
var spawns: Array
var enemies_in_wave = 0
var enemies_in_group_to_spawn = 0
var enemies_spawned = 0
var enemies_killed = 0
var cum_delta

signal new_wave_spawned
signal enemies_to_kill_updated
signal wave_cleared

func _ready() -> void:
    trigger_next_wave()

func trigger_next_wave() -> void:
    wave_delay_timer.start()

func spawn_next_wave():
    enemies_killed = 0
    enemies_spawned = 0
    current_wave_idx += 1
    spawn_timer.stop()
    if current_wave_idx < waves.size():
        current_wave = waves[current_wave_idx]
        spawn_groups = current_wave.get_children()
        
        enemies_in_wave = 0
        for group in spawn_groups:
            spawns = group.get_children()
            for spawn in spawns:
                enemies_in_wave += spawn.num_enemies
        
        current_group_idx = -1
        get_next_spawn_group()
        
        emit_signal("new_wave_spawned", current_wave_idx, enemies_in_wave)

func _process(delta: float) -> void:
    if current_wave:
        enemies_in_group_to_spawn = 0
        for spawn in spawns:
            var spawn_count = spawn.get_spawn_count(delta)
            enemies_in_group_to_spawn += spawn.remaining_enemies
            for idx in range(0, spawn_count):
                var enemy: Node2D = spawn.Enemy.instance()
                var stats = enemy.get_node("Stats")
                stats.connect("die", self, "_on_Enemy_die")
                get_tree().current_scene.add_child(enemy)
                enemy.global_translate(get_spawn_pos())
                enemies_spawned += 1
        if enemies_in_group_to_spawn <= 0 and spawn_timer.is_stopped():
            spawn_timer.wait_time = current_group.spawn_duration
            spawn_timer.start()
        

func _on_SpawnTimer_timeout() -> void:
    spawn_timer.stop()
    get_next_spawn_group()

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

func get_next_spawn_group():
    current_group_idx += 1
    if current_group_idx < spawn_groups.size():
        current_group = spawn_groups[current_group_idx]
        spawns = current_group.get_children()

func _on_Enemy_die() -> void:
    enemies_killed += 1
    emit_signal("enemies_to_kill_updated", enemies_in_wave - enemies_killed)
    
    if enemies_killed >= enemies_spawned and not spawn_timer.is_stopped():
        spawn_timer.wait_time = min(spawn_timer.time_left, 1)
    if enemies_killed >= enemies_in_wave:
        emit_signal("wave_cleared")


func _on_WaveDelayTimer_timeout() -> void:
    spawn_next_wave()


func _on_UpgradesMenu_upgrade_selected() -> void:
    trigger_next_wave()

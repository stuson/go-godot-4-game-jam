extends Node

onready var waves = $Waves.get_children()
onready var spawn_timer = $SpawnTimer
onready var wave_delay_timer = $WaveDelayTimer
onready var camera: Camera2D = get_tree().get_nodes_in_group("MainCamera")[0]
onready var nav_poly: NavigationPolygonInstance = get_tree().get_nodes_in_group("NavMap")[0]

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
signal game_won

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
    else:
        emit_signal("game_won")

func _process(delta: float) -> void:
    if current_wave:
        enemies_in_group_to_spawn = 0
        for spawn in spawns:
            var spawn_count = spawn.get_spawn_count(delta)
            enemies_in_group_to_spawn += spawn.remaining_enemies
            for _idx in range(0, spawn_count):
                var enemy: Enemy = spawn.Enemy.instance()
                enemy.max_hp *= 1 + 0.2 * floor(current_wave_idx / 5)
                var stats = enemy.get_node("Stats")
                stats.connect("die", self, "_on_Enemy_die")
                enemy.connect("duplicated", self, "_on_Enemy_duplicated")
                get_tree().current_scene.add_child(enemy)
                enemy.global_translate(get_spawn_pos(enemy))
                enemies_spawned += 1
        if enemies_in_group_to_spawn <= 0 and spawn_timer.is_stopped():
            spawn_timer.wait_time = current_group.spawn_duration
            spawn_timer.start()
        

func _on_SpawnTimer_timeout() -> void:
    spawn_timer.stop()
    get_next_spawn_group()

func get_spawn_pos(enemy: Enemy, retry_count = 0) -> Vector2:
    if retry_count > 10:
        return Vector2(0, 0)
        
    randomize()
    var spawn_quadrant = randi() % 4
    
    var view = get_viewport()
    var camera_pos = camera.global_position
    var enemy_sprite: AnimatedSprite = enemy.get_node("AnimatedSprite")
    var w_off = view.size.x/2
    var h_off = view.size.y/2
    var sprite_size = enemy_sprite.get_sprite_frames().get_frame("default", 0).get_size()
    var w = sprite_size.x * enemy_sprite.scale.x
    var h = sprite_size.y * enemy_sprite.scale.y
    
    var min_x = camera_pos.x - w_off - w
    var max_x = camera_pos.x + w_off + w
    var min_y = camera_pos.y - h_off - h
    var max_y = camera_pos.y + h_off + h
    
    var end_pos: Vector2
    
    match spawn_quadrant:
        0:
            end_pos = Vector2(min_x, rand_range(min_y, max_y))
        1:
            end_pos =  Vector2(max_x, rand_range(min_y, max_y))
        2:
            end_pos =  Vector2(rand_range(min_x, max_x), min_y)
        3:
            end_pos = Vector2(rand_range(min_x, max_x), max_y)
        _:
            end_pos = Vector2(min_x, min_y)
    
    var map = enemy.nav_agent.get_navigation_map()
    end_pos = Navigation2DServer.map_get_closest_point(map, end_pos)
    
    if not (end_pos.x > max_x or end_pos.x < min_x or end_pos.y < min_y or end_pos.y > max_y):
        return get_spawn_pos(enemy, retry_count+1)
    
    return end_pos

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

func _on_Enemy_duplicated(dupe) -> void:
    var dupe_stats = dupe.get_node("Stats")
    dupe_stats.connect("die", self, "_on_Enemy_die")
    dupe.connect("duplicated", self, "_on_Enemy_duplicated")
    enemies_in_wave += 1
    enemies_spawned += 1
    emit_signal("enemies_to_kill_updated", enemies_in_wave - enemies_killed)


func _on_WaveDelayTimer_timeout() -> void:
    spawn_next_wave()


func _on_UpgradesMenu_upgrade_menu_finished() -> void:
    trigger_next_wave()

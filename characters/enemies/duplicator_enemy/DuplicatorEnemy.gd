extends Enemy

func _ready() -> void:
    duplicatable = false

func death_explosion_effect(body: KinematicBody2D) -> void:
    if body.duplicatable:
        var dupe = body.clone()
        get_tree().current_scene.call_deferred("add_child", dupe)
        randomize()
        dupe.global_position = body.global_position + Vector2(randi()%41-20, randi()%41-20)

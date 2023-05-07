extends CanvasLayer


func _unhandled_key_input(event: InputEventKey) -> void:
    if visible and event.is_action_pressed("restart"):
        get_tree().paused = false
        get_tree().reload_current_scene()


func _on_Player_player_died() -> void:
    visible = true

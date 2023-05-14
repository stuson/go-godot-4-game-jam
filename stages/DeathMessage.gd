extends CanvasLayer


func _unhandled_key_input(event: InputEventKey) -> void:
    if visible:
        if event.is_action_pressed("restart"):
            get_tree().paused = false
            get_tree().reload_current_scene()
        elif event.is_action_pressed("ui_cancel"):
            MainMenuMusic.play()
            get_tree().change_scene("res://ui/MainMenu.tscn")


func _on_Player_player_died() -> void:
    visible = true

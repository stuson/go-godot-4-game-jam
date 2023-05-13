extends Button


func _on_StartGame_pressed() -> void:
    get_tree().change_scene("res://stages/Level.tscn")
    

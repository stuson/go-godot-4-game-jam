extends HSlider


export var audio_bus_name = "Master"

onready var bus = AudioServer.get_bus_index(audio_bus_name)

func _ready() -> void:
    value = db2linear(AudioServer.get_bus_volume_db(bus)) * 100

func _on_value_changed(value: float) -> void:
    if has_focus():
        AudioServer.set_bus_volume_db(bus, linear2db(value / 100))

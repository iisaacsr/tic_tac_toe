extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Connection.is_connected_to_server():
		print("stream is connected")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _disconnect_from_host() -> void:
	Connection.disconnect_from_host();

func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_disconnect_from_host()

func _on_button_pressed() -> void:
	print("button is pressed")

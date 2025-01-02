extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Connection.is_connected_to_server():
		Connection.stream.put_data(("details/" + Connection.stream.).to_ascii_buffer())

func _process(delta):
	if Connection.is_connected_to_server():
		if Connection.stream.get_available_bytes() > 0:
			var data = Connection.stream.get_string(Connection.stream.get_available_bytes()).split("#")
			for req in data:
				match req.split("/")[0]:
					"message":
						print(req.split("/")[1])
					"gameId":
						print("gameId")

func _disconnect_from_host() -> void:
	Connection.disconnect_from_host();

func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_disconnect_from_host()
		get_tree().quit()

func _on_button_pressed() -> void:
	print("button is pressed")

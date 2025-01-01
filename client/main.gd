extends Node2D

const DEV = true

var url : String = "server-address"
const PORT = 48646

var _status: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DEV == true:
		url = "127.0.0.1"

func _connect_to_host() -> void:
	print("connection to %s:%d" % [url, PORT])
	Connection.connect_to_host()
		
func _disconnect_from_host() -> void:
	Connection.disconnect_from_host();
	
func _start_matchmaking() -> void:
	_connect_to_host()
	print("starting matchmaking")	
	Connection.stream.poll()
	if !Connection.is_connected_to_server():
		print("not connected")
		return
	var username : TextEdit = get_node("Username")
	Connection.stream.put_data(("matchmake/" + username.text).to_ascii_buffer())
	
		
func _on_button_pressed() -> void:
	var button : Button = get_node("Button")
	_start_matchmaking()
		
func _process(delta):
	if Connection.is_connected_to_server():
		if Connection.stream.get_available_bytes() > 0:
			var data = Connection.stream.get_string(Connection.stream.get_available_bytes()).split("/")
			match data[0]:
				"message":
					print(data[1])
					get_tree().change_scene_to_file("res://tictactoe.tscn")
	
func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_disconnect_from_host()

extends Node2D

const DEV = true

signal connected
signal data
signal disconnected
signal error

var multiplayer_peer = ENetMultiplayerPeer.new();
var url : String = "server-address"
const PORT = 48646

var _status: int = 0
var _stream : StreamPeerTCP = StreamPeerTCP.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DEV == true:
		url = "127.0.0.1"

		_connect_to_host();

func _connect_to_host() -> void:
	print("connection to %s:%d" % [url, PORT])
	_stream.connect_to_host(url, PORT)
		
func _disconnect_from_host() -> void:
	_stream.disconnect_from_host();
	
func _send_data() -> void:
	print("sending data")	
	_stream.poll()
	if _stream.get_status() != _stream.STATUS_CONNECTED:
		print("not connected")
		return
	_stream.put_data("yo".to_ascii_buffer())
	
		
func _on_button_pressed() -> void:
	_send_data()
	
func _process(delta):
	if _stream.get_status() == _stream.STATUS_CONNECTED:
		if _stream.get_available_bytes() > 0:
			var data = _stream.get_string(_stream.get_available_bytes())
			print("received from server : ", data)
	
func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_disconnect_from_host()

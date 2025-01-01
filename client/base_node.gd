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
	
func _notification(noti) -> void:
	if(noti) == NOTIFICATION_WM_CLOSE_REQUEST:
		_disconnect_from_host()
		get_tree().quit()
		

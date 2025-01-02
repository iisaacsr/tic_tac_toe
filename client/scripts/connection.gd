extends Node

const DEV = true

var url : String = "server-address"
const PORT = 48646

var _status: int = 0
var stream : StreamPeerTCP = StreamPeerTCP.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DEV == true:
		url = "127.0.0.1"

func connect_to_host() -> void:
	print("connection to %s:%d" % [url, PORT])
	stream.connect_to_host(url, PORT)
		
func disconnect_from_host() -> void:
	stream.disconnect_from_host();

func is_connected_to_server() -> bool:
	return stream.get_status() == stream.STATUS_CONNECTED

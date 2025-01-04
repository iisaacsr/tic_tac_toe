extends Node2D
 
@onready var username_text_edit : TextEdit = get_node("Username")
@onready var matchmaking_button : Button = get_node("Button")
@onready var special_chars_label : Label = get_node("special_chars")
@onready var special_chars_underline_rect : ColorRect = get_node("special_chars_underline")
@onready var progress_bar : ProgressBar = get_node("progress_bar")
@onready var find_button : Button = get_node("find_button")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("starting app...")

func _connect_to_host() -> void:
	#artificial wait to ensure connection
	Connection.connect_to_host()
	await get_tree().create_timer(1).timeout
	Connection.stream.poll()

func _disconnect_from_host() -> void:
	Connection.disconnect_from_host();
	Connection.stream.poll()

func _start_matchmaking() -> void:
	var username : String = username_text_edit.text
	GameState.set_username(username)
	#regex to avoid code injection (no special chars)
	var regex = RegEx.new()
	regex.compile("[^A-Za-z0-9]")
	var result = regex.search(username)
	if !result:
		await _connect_to_host()
		print("starting matchmaking")	
		if !Connection.is_connected_to_server():
			print("not connected")
			return
		Connection.stream.put_data(("matchmake/" + username).to_ascii_buffer())
	else:
		print("no special characters allowed :3")

func _on_button_pressed() -> void:
	progress_bar.visible = true
	find_button.disabled = true
	_start_matchmaking()

func _on_username_text_changed() -> void:
	var username : String = username_text_edit.text
	#regex to avoid code injection (no special chars)
	var regex = RegEx.new()
	regex.compile("[^A-Za-z0-9]")
	var result = regex.search(username)
	if result:
		special_chars_label.visible = true
		special_chars_underline_rect.visible = true 
		matchmaking_button.disabled = true
	else:
		special_chars_label.visible = false
		special_chars_underline_rect.visible = false 

func _process(delta):
	if Connection.is_connected_to_server():
		if Connection.stream.get_available_bytes() > 0:
			var data = Connection.stream.get_string(Connection.stream.get_available_bytes()).split("#")
			for req in data:
				match req.split("/")[0]:
					"message":
						print(req.split("/")[1])
					"game_id":
						GameState.set_game_id(int(req.split("/")[1]))
					"player_id":
						GameState.set_player_id(int(req.split("/")[1]))
					"change_scene":
						progress_bar.visible = false
						find_button.disabled = false
						get_tree().change_scene_to_file("res://scenes/tictactoe.tscn")	

func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_disconnect_from_host()
		get_tree().quit()

extends Node2D

#player 1 (0) is circle
const CIRCLE_ICON : int = 1
#player 2 (1) is x
const X_ICON : int = 2

@onready var game_id = GameState.get_game_id()
@onready var own_player_id = GameState.get_player_id()
@onready var tictactoe : TicTacToe = TicTacToe.new()
@onready var user1name : Label = get_node("username1")
@onready var user2name : Label = get_node("username2")
var current_player_turn : int

signal tictactoe_state(new_ttt : TicTacToe)

func _ready() -> void:
	_get_game_details(game_id)
	for button : Button in get_tree().get_nodes_in_group("buttons"):
		button.pressed.connect(_on_button_pressed.bind(button))

func _process(delta):
	if Connection.is_connected_to_server():
		if Connection.stream.get_available_bytes() > 0:
			var data = Connection.stream.get_string(Connection.stream.get_available_bytes()).split("#")
			for req in data:
				match req.split("/")[0]:
					"message":
						print(req.split("/")[1])
					"details":
						print("got match details")
						var new_tictactoe = _parse_details_json_data(req.split("/")[1])
						# change the game state (see on state change function below)
						tictactoe_state.emit("details", new_tictactoe)
					"move":
						print("handling move")
						var new_tictactoe = _parse_details_json_data(req.split("/")[1])
						tictactoe_state.emit("move", new_tictactoe)
						

func _get_game_details(game_id) -> void:
	if Connection.is_connected_to_server():
		Connection.stream.put_data(("details/" + str(game_id)).to_ascii_buffer())

func _parse_details_json_data(item : String) -> TicTacToe:
	var json = JSON.new()
	var error = json.parse(item)
	if error == OK:
		var data = json.data
		if typeof(data) == TYPE_DICTIONARY:
			var ttt : TicTacToe = _tictactoe_from_json(data)
			return ttt
		else: 
			print("parsed tictactoe json data is wrong")
			return null 
	else: return null 
	

func _tictactoe_from_json(data : Dictionary) -> TicTacToe:
	var tictactoe : TicTacToe = TicTacToe.new()
	tictactoe.id = int(data.get("id"))
	tictactoe.board = data.get("board")
	tictactoe.users = data.get("users")
	tictactoe.winner = data.get("winner") || null
	tictactoe.current_player = int(data.get("current_player"))
	tictactoe.game_over = data.get("game_over")
	return tictactoe

func _disconnect_from_host() -> void:
	Connection.disconnect_from_host();

func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_disconnect_from_host()
		get_tree().quit()

func _on_button_pressed(button : Button) -> void:
	var coords : String = button.name.split("b")[0]
	Connection.stream.put_data(("move/" + str(coords) + "/" + str(game_id) + "/" + str(own_player_id)).to_ascii_buffer())

func _on_tictactoe_state_changed(code : String, new_tictactoe : TicTacToe) -> void:
	tictactoe = new_tictactoe
	match code:
		"details":
			user1name.text = tictactoe.users[0]
			user2name.text = tictactoe.users[1]
			current_player_turn = tictactoe.current_player
		"move":
			current_player_turn = tictactoe.current_player
			_handle_tictactoe_buttons(current_player_turn)
			
func _handle_tictactoe_buttons(player_turn : int) -> void:
	if player_turn == GameState.get_player_id():
		
					
func _change_tictactoe_icons(icon : int)
	for row in tictactoe.board:
		for column in row:
			if player_turn == 0:
					
	

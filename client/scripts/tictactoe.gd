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
@onready var user0turn : Label = get_node("u0turn")
@onready var user1turn : Label = get_node("u1turn")

var current_player_turn : int

signal tictactoe_state(new_ttt : TicTacToe)

func _ready() -> void:
	_get_game_details(game_id)
	for button : Button in get_tree().get_nodes_in_group("buttons"):
		button.pressed.connect(_on_button_pressed.bind(button))
	_handle_tictactoe_tiles(current_player_turn)

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
					"draw":
						_handle_draw()
					"winner":
						var winner : Array = req.split("/")
						_handle_win(int(winner[1]), winner[2])

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

func _on_tictactoe_state_changed(code : String, new_tictactoe : TicTacToe) -> void:
	tictactoe = new_tictactoe
	match code:
		"details":
			user1name.text = tictactoe.users[0]
			user2name.text = tictactoe.users[1]
			current_player_turn = tictactoe.current_player
			_handle_tictactoe_tiles(current_player_turn)
		"move":
			current_player_turn = tictactoe.current_player
			_handle_tictactoe_tiles(current_player_turn)
			
func _handle_tictactoe_tiles(player_turn : int) -> void:
		if player_turn == own_player_id:
			_toggle_tictactoe_buttons(false)
		else:
			_toggle_tictactoe_buttons(true)	
		_change_tictactoe_icons(CIRCLE_ICON) 
		_change_tictactoe_icons(X_ICON)	
		_change_player_turn(player_turn)

func _change_player_turn(player_turn : int) -> void:
	if own_player_id == 0:
		if current_player_turn == own_player_id:
			user0turn.text = "Your turn..."
			user1turn.text = ""
		else : 
			user0turn.text = ""
			user1turn.text = "Their turn..."
	else:
		if current_player_turn == own_player_id:
			user1turn.text = "Your turn..."
			user0turn.text = ""
		else : 
			user1turn.text = ""
			user0turn.text = "Their turn..."

func _toggle_tictactoe_buttons(toggle : bool):
	for button : Button in get_tree().get_nodes_in_group("buttons"):
		button.disabled = toggle

func _change_tictactoe_icons(icon : int):
	var name : String = "circle" if (icon == 1) else "x"
	var row_i : int = 0
	for row in tictactoe.board:
		var column_i = 0
		for column in row:
			if column == icon:
				var sprite : Sprite2D = get_node(str(row_i)+str(column_i)+name)
				var button : Button = get_node(str(row_i)+str(column_i)+"button")
				button.disabled = true
				sprite.visible = true
			column_i += 1
		row_i += 1

func _disable_board():
	_disconnect_from_host()
	_toggle_tictactoe_buttons(true)
	user0turn.visible = false
	user1turn.visible = false
	get_node("homebutton").visible = true

func _handle_draw():
	_disable_board()
	get_node("u0draw").visible = true
	get_node("u1draw").visible = true

func _handle_win(winning_player_id : int,  winning_player_username : String):
	_disable_board()
	var winning_text : Label = get_node("u" + str(winning_player_id) + "won")
	winning_text.visible = true

func _on_button_pressed(button : Button) -> void:
	var coords : String = button.name.split("b")[0]
	Connection.stream.put_data(("move/" + str(coords) + "/" + str(game_id) + "/" + str(own_player_id)).to_ascii_buffer())

func _on_home_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")	

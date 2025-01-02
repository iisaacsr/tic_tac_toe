extends Node2D

@onready var game_id = GameState.get_game_id()
@onready var tictactoe : TicTacToe = TicTacToe.new()

func _ready() -> void:
	get_game_details(game_id)

func _process(delta):
	if Connection.is_connected_to_server():
		if Connection.stream.get_available_bytes() > 0:
			var data = Connection.stream.get_string(Connection.stream.get_available_bytes()).split("#")
			for req in data:
				match req.split("/")[0]:
					"message":
						print(req.split("/")[1])
					"details":
						tictactoe = parse_details_json_data(req.split("/")[1])
						print(tictactoe.board)

func get_game_details(game_id) -> void:
	if Connection.is_connected_to_server():
		Connection.stream.put_data(("details/" + str(game_id)).to_ascii_buffer())

func parse_details_json_data(item : String) -> TicTacToe:
	var json = JSON.new()
	var error = json.parse(item)
	if error == OK:
		var data = json.data
		if typeof(data) == TYPE_DICTIONARY:
			var ttt : TicTacToe = tictactoe_from_json(data)
			return ttt
		else: 
			print("parsed tictactoe json data is wrong")
			return null 
	else: return null 
	

func tictactoe_from_json(data : Dictionary) -> TicTacToe:
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

func _on_button_pressed() -> void:
	print(game_id)
	print("button is pressed")

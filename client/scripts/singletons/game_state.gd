extends Node

var owned_username : String
var owned_player_id : int
var game_id : int
	
func set_username(new_username: String) -> void:
	owned_username = new_username	

func get_username() -> String:
	return owned_username

func set_player_id(new_player_id: int) -> void:
	owned_player_id = new_player_id

func get_player_id() -> int:
	return owned_player_id
	
func set_game_id(new_game_id: int) -> void:
	game_id = new_game_id	

func get_game_id() -> int:
	return game_id

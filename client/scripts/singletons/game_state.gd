extends Node

var game_id : int

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	pass
	
func set_game_id(new_game_id: int) -> void:
	game_id = new_game_id	

func get_game_id() -> int:
	return game_id

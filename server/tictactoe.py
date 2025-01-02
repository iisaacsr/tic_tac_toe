import json
from models.user import User

class TicTacToe:
    board : list[list[int]]
    users : list[User]
    winner : int
    current_player : int
    game_over : bool

    def __init__(self, id : int, user1 : User, user2 : User):
        self.id = id
        self.board = [[0 for _ in range(3)] for _ in range(3)]
        self.users = [user1, user2]
        self.winner = None
        self.current_player = 1
        self.game_over = False

    def to_json(self):
        return json.dumps({
            "id": self.id,
            "board": self.board,
            "users": [user.username for user in self.users],
            "winner": self.winner,
            "current_player": self.current_player,
            "game_over": self.game_over
        })


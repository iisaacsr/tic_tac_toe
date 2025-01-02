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

    def make_move(self, move : str, player_turn : int):
        if self.current_player != player_turn:
            print("not player turn")
            return self.to_json()
        
        x = int(move[0])
        y = int(move[1])

        if self.board[x][y] != 0:
            print("cell already taken")
            return self.to_json()

        self.board[x][y] = player_turn + 1

        # opposite player turn
        self.current_player = 1 if self.current_player == 0 else 0

        return self.to_json()


    def to_json(self):
        return json.dumps({
            "id": self.id,
            "board": self.board,
            "users": [user.username for user in self.users],
            "winner": self.winner,
            "current_player": self.current_player,
            "game_over": self.game_over
        })


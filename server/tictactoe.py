from models.user import User

class TicTacToe:
    board : list[list[int]]
    users : list[User]
    winner : int
    current_player : int
    game_over : bool

    def __init__(self, user1 : User, user2 : User):
        self.board = [[0 for _ in range(3)] for _ in range(3)]
        self.users = [user1, user2]
        self.winner = None
        self.game_over = False
        self.current_player = 1



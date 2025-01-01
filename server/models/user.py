import socket

class User:
    username : str
    user_address : tuple
    connection : socket

    def __init__(self, username : str, user_address : tuple, connection : socket):
        self.username = username
        self.user_address = user_address
        self.connection = connection

    def send_message(self, message : str):
        self.connection.sendall(message.encode())

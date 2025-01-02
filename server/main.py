import socket
import select
from models.user import User
from tictactoe import TicTacToe

HOST = "127.0.0.1"
PORT = 48646

users_in_queue : list[User] = []
current_games : list[TicTacToe] = []
active_connections : list[socket.socket] = []

def start_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_address = (HOST, PORT)
    
    print(f"starting up on {server_address[0]} port {server_address[1]}")
    server_socket.bind(server_address)
    server_socket.listen(10)
    
    active_connections.append(server_socket)

    while True:
        readable, _, exceptional = select.select(active_connections, [], active_connections)
        for sock in readable:
            if sock is server_socket:
                connection, client_address = sock.accept()
                active_connections.append(connection)
                print(f"new connection from {client_address}")
            else:
                try:
                    data = sock.recv(1024).decode()
                    if data:
                        print(f"received data: {data}")
                        handle_request(data, sock.getpeername(), sock)
                    else:
                        print(f"closing connection {sock.getpeername()}")
                        active_connections.remove(sock)
                        sock.close()
                except Exception as e:
                    print(f"error handling client: {e}")
                    active_connections.remove(sock)
                    sock.close()

        for sock in exceptional:
            print(f"handling exceptional condition for {sock.getpeername()}")
            active_connections.remove(sock)
            sock.close()

def handle_request(data : str, client_address : tuple, connection : socket):
    print(f"handling request {data} from {client_address}")
    req : str = data.split("/")[0]
    match(req):
        case "matchmake":
            username = data.split("/")[1]
            users_in_queue.append(User(username, client_address, connection))
            if len(users_in_queue) % 2 == 0 and len(users_in_queue) > 0:
                start_matchmaking(users_in_queue[0], users_in_queue[1])
        case "details":
            gameId = int(data.split("/")[1])
            connection.sendall(f"details/{current_games[0]}".encode())


def start_matchmaking(user1 : User, user2 : User):
    from tictactoe import TicTacToe
    print(f"starting matchmaking for {user1.username} and {user2.username}")

    tictactoe = TicTacToe(len(current_games), user1, user2)
    current_games.append(tictactoe)

    user1.send_message(f"message/Game started against {user2.username}#")
    user2.send_message(f"message/Game started against {user1.username}#")
    send_shared_message("change_scene/#", user1, user2)
    send_shared_message(f"gameId/{tictactoe.id}#", user1, user2)

def send_shared_message(message : str, user1 : User, user2 : User):
    user1.send_message(message)
    user2.send_message(message)

if __name__ == "__main__":
    start_server()
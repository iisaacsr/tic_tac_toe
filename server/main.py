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
    
    if server_socket not in active_connections:
        active_connections.append(server_socket)

    while True:
        try:
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
                            cleanup_client(sock)
                    except (ConnectionResetError, ConnectionAbortedError) as e:
                        print(f"connection error: {e}")
                        cleanup_client(sock)
                    except Exception as e:
                        print(f"error handling client data: {e}")

            for sock in exceptional:
                cleanup_client(sock)

        except select.error as e:
            print(f"select error occurred: {e}")
            continue

def cleanup_client(sock):
    try:        
        for game in current_games[:]:  
                for user in game.users:
                    if user.connection != sock:
                        try:
                            user.send_message(f"message/{user.username} disconnected#")
                            print(f"{user.username} disconnected from game {game.id}")
                        except:
                            pass 
                current_games.remove(game)

        if sock in active_connections:
            active_connections.remove(sock)
        sock.close()
        
    except Exception as e:
        print(f"error during cleanup: {e}")

def handle_request(data : str, client_address : tuple, connection : socket):
    print(f"handling request {data} from {client_address}")
    req : str = data.split("/")[0]
    match(req):
        case "matchmake":
            username = data.split("/")[1]
            users_in_queue.append(User(username, client_address, connection))
            if len(users_in_queue) % 2 == 0 and len(users_in_queue) > 0:
                start_matchmaking(users_in_queue[0], users_in_queue[1])
                users_in_queue.remove(users_in_queue[0])
                users_in_queue.remove(users_in_queue[0])
        case "details":
            game_id = int(data.split("/")[1])
            send_game_details(game_id, connection)
        case "move":
            req = data.split("/")
            move = req[1]
            game_id = int(req[2])
            player_id = int(req[3])
            handle_move(connection, game_id, move, player_id)



def start_matchmaking(user1 : User, user2 : User):
    from tictactoe import TicTacToe
    print(f"starting matchmaking for {user1.username} and {user2.username}")

    tictactoe = TicTacToe(len(current_games), user1, user2)
    current_games.append(tictactoe)
    
    user1Id = 0
    user2Id = 1

    user1.send_message(f"message/Game started against {user2.username}#")
    user2.send_message(f"message/Game started against {user1.username}#")
    user1.send_message(f"player_id/{user1Id}#")
    user2.send_message(f"player_id/{user2Id}#")
    send_shared_message(f"game_id/{tictactoe.id}#", user1, user2)
    send_shared_message("change_scene/#", user1, user2)


def send_game_details(game_id : int, connection : socket):
    try:
        tictactoe : TicTacToe = current_games[game_id]
        connection.sendall(f"details/{tictactoe.to_json()}#".encode())
    except IndexError:
        connection.sendall(f"error/game_not_found#".encode())

def handle_move(connection : socket, game_id : int, move : str, player_id : int):
    try:
        tictactoe : TicTacToe = current_games[game_id]
        send_shared_message(f"move/{tictactoe.make_move(move, player_id)}#", tictactoe.users[0], tictactoe.users[1])
        match tictactoe.check_winner():
            case "Draw":
                send_shared_message("draw/#", tictactoe.users[0], tictactoe.users[1])
            case "0":
                send_shared_message(f"winner/0/{tictactoe.users[0].username}#", tictactoe.users[0], tictactoe.users[1])
            case "1":
                send_shared_message(f"winner/1/{tictactoe.users[1].username}#", tictactoe.users[0], tictactoe.users[1])
        
    except IndexError:
        connection.sendall(f"error/game_not_found#".encode())

def send_shared_message(message : str, user1 : User, user2 : User):
    user1.send_message(message)
    user2.send_message(message)

if __name__ == "__main__":
    start_server()
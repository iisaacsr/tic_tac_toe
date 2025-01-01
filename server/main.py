import socket
from models.user import User

HOST = "127.0.0.1"
PORT = 48646
users_in_queue : list[User] = []


# Start the server
def start_server():
    server_address = (HOST, PORT)
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    print(f"starting up on {server_address[0]} port {server_address[1]}")

    sock.bind(server_address)
    sock.listen(1)

    while True:
        print(f"waiting for a connection")
        connection, client_address = sock.accept()
        try:
            print(f"connection from {client_address}")
            while True:
                # if there are at least one pair of users in the queue, start matchmaking
                if len(users_in_queue) % 2 == 0 and len(users_in_queue) > 0:
                    start_matchmaking(users_in_queue[0], users_in_queue[1])
                    users_in_queue.clear()
                data = connection.recv(1024).decode()
                if not data or data == "":
                    break
                print(f"received data from {client_address}: {data}")
                handle_request(data, client_address)
                connection.sendall(f"Hello, you said: {data}".encode())
        except Exception as e:
            print(f"server error: {e}")
            break
        finally:
            print(f"client {client_address} closed connection")
            connection.close()


def handle_request(data : str, client_address : tuple):
    req : str = data.split("/")[0]
    username : str = data.split("/")[1]
    match(req):
        case "matchmake":
            users_in_queue.append(User(username, client_address))

def start_matchmaking(user1 : User, user2 : User):
    print(f"starting matchmaking for {user1.username} and {user2.username}")


if __name__ == "__main__":
    start_server()
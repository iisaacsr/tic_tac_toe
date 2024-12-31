import socket
import sys 

HOST = "127.0.0.1"
PORT = 48646

# Create a socket (connect two computers)
def create_socket():
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
                data = connection.recv(1024)
                print(f'received {data}')
                if not data:
                    break
                connection.sendall(data)
        finally:
            connection.close()

if __name__ == "__main__":
    create_socket()
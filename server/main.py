import socket
import websockets

HOST = "127.0.0.1"
PORT = 48646

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
                data = connection.recv(1024).decode()
                if not data or data == "":
                    break
                print(f"received data from {client_address}: {data}")
                connection.sendall(f"Hello, you said: {data}".encode('utf-8'))
        except Exception as e:
            print(f"server error: {e}")
            break
        finally:
            print(f"client {client_address} closed connection")
            connection.close()

if __name__ == "__main__":
    start_server()
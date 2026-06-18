import socket

def probe_port(port):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(5)
        s.connect(('213.210.37.129', port))
        banner = s.recv(1024)
        s.close()
        return f"Port {port} Success: {banner.decode('utf-8', errors='ignore').strip()}"
    except Exception as e:
        return f"Port {port} Failed: {e}"

print(probe_port(22))
print(probe_port(2222))

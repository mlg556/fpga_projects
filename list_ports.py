import serial.tools.list_ports

ports = serial.tools.list_ports.comports()

print("-" * 64)

for port, desc, _ in sorted(ports):
    print(f"{port}: {desc}")

print("-" * 64)

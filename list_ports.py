import serial.tools.list_ports as ls

print([p.device for p in ls.comports()])

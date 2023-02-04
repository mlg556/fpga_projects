import serial

with serial.Serial(port="COM20", baudrate=115_200) as ser:
    while True:
        if ser.in_waiting:
            data = ser.read(ser.in_waiting)
            print("-" * 64)
            print(f"ASCII:\t{data.decode('ascii')}")
            print(f"HEX:\t{data.hex()}")
            print(f"BIN:\t{' '.join([bin(byte)[2:] for byte in data])}")
            print("-" * 64)

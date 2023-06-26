# code ported from js to python: https://learn.lushaylabs.com/tang-nano-9k-graphics/

# import imageio.v3 as iio
# im = iio.imread("sprite.png")

width, height = 128, 64

with open("sprite.bmp", "rb") as im:
    f = im.read()
    data = bytearray(f)

bytes = []

for y in range(0, height, 8):
    for x in range(0, width, 1):
        byt = 0
        for j in range(7, -1, -1):
            idx = (width * (y + j) + x) * 3  # or 4?
            if data[idx + 3] < 128:
                byte = (byte << 1) + 1
            else:
                byte = (byte << 1) + 0

        bytes.append(byt)


hex_data = [f"{b:#04x}".replace("0x", "") for b in bytes]

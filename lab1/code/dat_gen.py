with open("code.bin", "rb") as f:
  while True:
    data = f.read(4)
    if len(data) == 4:
      print(f"{int.from_bytes(data, byteorder='little'):08x}",end='\n')
    else:
      break
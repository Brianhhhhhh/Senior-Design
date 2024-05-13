import serial
import time
import math
import sys

if (len(sys.argv)>2):
  uart_port = sys.argv[2]
else:
  uart_port = 'COM5'
  print('Defaulting to COM5')
  
def mem_write(data):
    
  for i in range(4):
    write_data = bytes.fromhex(data[2*(i):(i)*2+2]) # 6:7, 4:5, 2:3, 0:1
    ser.write(write_data)
    #print('Write Data :',write_data)

# Start by trying to open the specified UART port
try:
  ser = serial.Serial(port=uart_port, baudrate=115200)
except:  
  uart_port_is_open = False
  print(uart_port + ' is not available')
else:
  print(uart_port + ' is available')
  uart_port_is_open = True
  ser.baudrate = 115200
  ser.bytesize = serial.EIGHTBITS
  
  ser.stopbits = serial.STOPBITS_ONE

  # select PARITY_NONE, PARITY_EVEN or PARITY_ODD
  ser.parity = serial.PARITY_NONE

  ser.xonxoff = 0
  ser.rtscts = 0
  # IF you don't set the timeout for reads the code will hang
  ser.timeout = 2
  

  with open(sys.argv[1], 'rb') as fp:
    hex_list = fp.readlines()
  num_lines = len(hex_list)
  num_bytes = num_lines*4
  print('num_bytes = ',num_bytes)
  # null = 0x00
  # ser.write(null.to_bytes(1,'little'))           # this is instr mem so 0x00 is first byte
  num_bytes_high = (num_bytes>>8) & 0xFF
  num_bytes_high = num_bytes_high.to_bytes(1,'little')
  ser.write(num_bytes_high)
  num_bytes_low = num_bytes & 0xFF
  num_bytes_low = num_bytes_low.to_bytes(1,'little')
  ser.write(num_bytes_low)
  
  for elem in hex_list:
    line = str(elem)
    line = line[2:10]                           #cut off strange b' that python adds
    print(line)
    mem_write(line)                             #write MSB byte as 0x55 for write
  print('Done Booting')
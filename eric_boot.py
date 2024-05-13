import serial
import time
import math
import sys

if (len(sys.argv)>2):
  uart_port = sys.argv[2]
else:
  uart_port = 'COM10'
  print('Defaulting to COM10')
  
def mem_write(data):
    
  for i in range(4):
    write_data = bytes.fromhex(data[2*(3-i):(3-i)*2+2])
    ser.write(write_data)
    #print('Write Data :',write_data)
  
    
def mem_read(address):
  for i in range(4):
    addr_byte= (address >> (8*i)) & 0xff
    addr_byte = addr_byte.to_bytes(1,'little')
    ser.write(addr_byte)
    #print('Read addr_byte', addr_byte)
  read_data = ser.read(4)
  #print('read data end', read_data)
  read_data = int.from_bytes(read_data,'little')
  #print('Read Data : ',hex(read_data))

  return read_data


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
  null = 0x00
  ser.write(null.to_bytes(1,'little'))           # this is instr mem so 0x00 is first byte
  num_bytes_high = (num_bytes>>8) & 0xFF
  num_bytes_high = num_bytes_high.to_bytes(1,'little')
  ser.write(num_bytes_high)
  num_bytes_low = num_bytes & 0xFF
  num_bytes_low = num_bytes_low.to_bytes(1,'little')
  ser.write(num_bytes_low)
  
  counter = 0x000000                            # assumed starting address
  for elem in hex_list:
    line = str(elem)
    line = line[2:10]                           #cut off strange b' that python adds
    print(line)
    mem_write(line)                             #write MSB byte as 0x55 for write
    #read_address = (counter ^ 0xff000000)
    #print('read_address :', hex(read_address))
    #read_data = mem_read(read_address) #write MSB byte as 0xaa for read
    #print('read_data : ',hex(read_data))

  print('Done Booting')
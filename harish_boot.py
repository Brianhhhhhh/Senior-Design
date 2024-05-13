import serial
import time
import math
import sys

uart_port = 'COM7'
def mem_write(address, data):
  #addr_byte = address.to_bytes(4, 'little')
  #for i in range(4):
  #  print(addr_byte[i])
  for i in range(4):
    addr_byte= (address >> (8*i)) & 0xff
    addr_byte = addr_byte.to_bytes(1,'little')
    #print('Write Addr Byte :', addr_byte)
    ser.write(addr_byte)
    
  for i in range(4):
    write_data = bytes.fromhex(data[2*(3-i):(3-i)*2+2])
    print('Write Data :',write_data)
    ser.write(write_data)
    #print('Write Data :',write_data)
  
    
    #ser.write(addr_byte0)
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
  ser = serial.Serial(port=uart_port)
except:  
  uart_port_is_open = False
  print(uart_port + ' is not available')
else:
  print(uart_port + ' is available')
  uart_port_is_open = True
  ser.baudrate = 9600
  # select FIVEBITS, SIXBITS, SEVENBITS or EIGHTBITS of data
  #ser.bytesize = serial.FIVEBITS
  #ser.bytesize = serial.SIXBITS
  #ser.bytesize = serial.SEVENBITS
  ser.bytesize = serial.EIGHTBITS
  
  # select STOPBITS_ONE, STOPBIT_TWO or STOPBITS_ONE_POINT_FIVE
  ser.stopbits = serial.STOPBITS_ONE
  #ser.stopbits = serial.STOPBIT_TWO
  #ser.stopbits = serial.STOPBITS_ONE_POINT_FIVE
  
  # select PARITY_NONE, PARITY_EVEN or PARITY_ODD
  ser.parity = serial.PARITY_NONE
  #ser.parity = serial.PARITY_EVEN
  #ser.parity = serial.PARITY_ODD
  
  ser.xonxoff = 0
  ser.rtscts = 0
  # IF you don't set the timeout for reads the code will hang
  ser.timeout = 2
  
  data = '41'
  with open('./addi.hex', 'rb') as fp:
    hex_list = fp.readlines()
  counter = 0x55000000
  for elem in hex_list:
    line = str(elem)
    #print(line)
    mem_write(counter, line)                     #write MSB byte as 0x55 for write
    #read_address = (counter ^ 0xff000000)
    #print('read_address :', hex(read_address))
    #read_data = mem_read(read_address) #write MSB byte as 0xaa for read
    #print('read_data : ',hex(read_data))

    counter = counter + 4
  exe_start_address = 0x55800000
  exe_start_address_read = 0xaa800000
  exe_start_data = str(b'00000001')
  exe_end_address = 0xaa800000
  mem_write(exe_start_address,exe_start_data)
  read_data = 0
  print("Polling for End of Program : Ecall")
  while (read_data == 0):
    read_data = mem_read(exe_end_address)
  print('ECALL seen. read_data : ',read_data)
  cycle_count = mem_read(0xaa840000)
  print('cycle count : ', hex(cycle_count))
  response = mem_read(0xaa000f00)
  print('Response float : ', hex(response))
  response = mem_read(0xaa000f04)
  print('Response int: ', hex(response))
#!/usr/bin/env python3
import serial, sys, time
#port = '/dev/ttyACM2'
port = '/dev/ttyACM1'
file = open('./data.txt', 'w')
ser = serial.Serial(port, 9600, timeout=None)
#ser.open()
#temp_file = open ('D:/PISTIS-test/temp_file.txt' , 'a', encoding = 'utf-8')
print("Receiving on {}".format(ser.name))
def receive():
    previous_char = None
    while True:
        inp = ser.read(1)
        #if inp:
           #print("Received byte: ", inp.hex())
        char_data = ord(inp)
        if(char_data == 0x0a or char_data == 0x0d):
          if previous_char is None or previous_char not in (0x0D, 0x0A):
            print("endline Received")
            
            file.write('\n')
            previous_char = char_data
        else:
            print("Data Received: ", inp)
            
            #print("Data Received")
            file.write(inp.decode('ascii', errors='ignore'))
            #file.write(inp)
            previous_char = None
    file.flush()
    return True
    
if(receive()):
    print("Data received")
else:
    print("Data was not received")
ser.close()             # close port
file.close()

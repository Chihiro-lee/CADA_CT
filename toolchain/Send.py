
#!/usr/bin/env python3
import serial, sys, time
port = '/dev/ttyACM1'
ser = serial.Serial(port, 9600, timeout=None)
if not ser.is_open:
    ser.open()
    
def send_c():
    ser.write(b'c')  
    print("Sent 's' to trigger count send")
    
def send_x():
    ser.write(b'x')  
    print("Sent 'x' to trigger xor_compute")
    
def send_r():
    ser.write(b'r') 
    print("Sent 'r' to trigger update")
    
send_c()
#send_x()
#send_r()
ser.close()             # close port

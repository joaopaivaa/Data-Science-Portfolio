# Complete project details at https://RandomNerdTutorials.com
import network
import socket
import onewire, ds18x20, sh1106, time, os, sys, math
from machine import Pin, ADC, I2C
import machine
import wifimgr

# Defines the desired water temperature
desired_temp = 60

# Defines the values relateds to the thermistor
R1 = 950
Vs = 3.3
Beta = 3435
ADC_Res = 4095

# Defines the IO and ADC pins
plus_button = Pin(34, Pin.IN)
minus_button = Pin(18, Pin.IN, Pin.PULL_UP)
water_level = ADC(Pin(32, Pin.IN))
temp_sensor = ds18x20.DS18X20(onewire.OneWire((Pin(33))))
thermistor = ADC(Pin(35, Pin.IN))
ac_control = Pin(16, Pin.OUT)
cooler = Pin(25, Pin.OUT)
motor = Pin(26, Pin.OUT)
buzzer = Pin(4, Pin.OUT)

water_level.atten(ADC.ATTN_11DB)
thermistor.atten(ADC.ATTN_11DB)

# Scans the temperature sensor
roms = temp_sensor.scan()

# Defines the initial variable as 1, so it's necessary to press the 2 buttons to start the equipment
i=1

# Defines the display's I2C connection
i2c = I2C(scl=Pin(22), sda=Pin(21), freq=400000)
display = sh1106.SH1106_I2C(128, 64, i2c, None, 0x3c, rotate=180)
display.sleep(False)

wlan_sta = network.WLAN(network.STA_IF)
wlan = wifimgr.get_connection()
ip = wlan_sta.ifconfig()[0]
# Main Code goes here, wlan is a working network.WLAN(STA_IF) instance.
print("ESP OK")

def Internal_Temp():
    Rt = (R1*thermistor.read()/ADC_Res)/(1-(thermistor.read()/ADC_Res))
    Tc = -math.log(Rt/54921) / 0.072
    return Tc

def web_page_sleeping():
    
    html = """<html>
                <head>
                <title>Thermocirculator</title>
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <link rel="icon" href="data:,">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
                
                <meta http-equiv="refresh" content="1">
                
                <style>
                
                html
                {font-family: Arial;
                display:inline-block;
                margin: 0px auto;
                text-align: center;
                background-color: #191970}
                
                h1
                {color: #FFFFFF;
                padding: 2vh;
                font-size: 4em;}
                
                .button
                {display: inline-block;
                background-color: #FFFFFF;
                border: 2px solid #191970;
                border-radius: 8px;
                color: #191970;
                padding: 16px 40px;
                text-decoration: none;
                font-size: 30px;
                width: 210px;
                margin: 2px;
                cursor: pointer;
                -webkit-transition-duration: 0.4s; /* Safari */
                transition-duration: 0.4s;}
                
                .button:hover
                {background-color: #191970;
                color: #FFFFFF;
                border: 2px solid #FFFFFF;}
                
                </style>
                
                </head>
                
                <body>
                
                <br>
                
                <h1>Sleeping mode</h1>
                
                <p><i class="fas fa-bed" style="color:#FFFFFF; font-size: 4em;"></i></p>
                
                <br>
                
                </div>
                <div style="display: inline-block;">
                <a href="/?WakeUp_Button_Web=on"><button class="button">Wake up</button></a>
                </div>

                </body>
                </html>"""
    return html

def web_page_with_water():
    
    global Desired_Temp
    
    html = """<html>
                <head>
                <title>Thermocirculator</title>
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <link rel="icon" href="data:,">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
                
                <meta http-equiv="refresh" content="0.2">
                
                <style>
                
                html
                {font-family: Arial;
                display:inline-block;
                margin: 0px auto;
                text-align: center;}
                
                h1
                {color: #000000;
                padding: 2vh;
                font-size: 4em;
                text-align: center;}
                
                p
                {font-size: 2em;}
                
                .button_Sleep
                {display: inline-block;
                background-color: #000000;
                border: 2px solid #FFFFFF;
                border-radius: 8px;
                color: white;
                padding: 16px 40px;
                text-decoration: none;
                font-size: 30px;
                width: 210px;
                margin: 2px;
                cursor: pointer;
                -webkit-transition-duration: 0.4s; /* Safari */
                transition-duration: 0.4s;}
                
                .button_Sleep:hover
                {background-color: #FFFFFF; /* Green */
                color: #000000;
                border: 2px solid #000000;}
                
                </style>
                
                </head>
                
                <body>
                
                <br>
                
                <h1>Thermocirculator Web Server</h1>
                
                <br>
                
                <p><i class="fas fa-thermometer-half"></i>  Thermocirculator internal temperature: <strong>""" + str(round(Intern_Temp,1)) + """ *C</strong></p>
                
                <p><i class="fas fa-fan"></i>  Cooler status: <strong>""" + cooler_State + """</strong></p>
                
                <br>
                
                <p><i class="fas fa-thermometer-half"></i>  Current Water temperature: <strong>""" + str(round(water_temp,1)) + """ *C</strong></p>
                
                <br>
                
                <p><i class="fas fa-thermometer-half"></i>  Desired Water temperature: <strong>""" + str(round(desired_temp,1)) + """ *C</strong></p>
                
                <br>
                <br>
                
                </div>
                <div style="display: inline-block;">
                <a href="/?Sleep_Button_Web=on"><button class="button_Sleep">Sleep</button></a>
                </div>
                
                </body>
                </html>"""
    return html

def web_page_no_water():
    
    html = """<html>
                <head>
                <title>Thermocirculator</title>
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <link rel="icon" href="data:,">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
                
                <meta http-equiv="refresh" content="1">
                
                <style>
                
                html
                {font-family: Arial;
                display:inline-block;
                margin: 0px auto;
                background-color: #FA8072;
                text-align: center;}
                
                h1
                {color: #000000;
                padding: 2vh;
                font-size: 4em;}
                
                p
                {font-size: 2em;}
                
                .button_Sleep
                {display: inline-block;
                background-color: #000000;
                border: 2px solid #FA8072;
                border-radius: 8px;
                color: #FA8072;
                padding: 16px 40px;
                text-decoration: none;
                font-size: 30px;
                width: 210px;
                margin: 2px;
                cursor: pointer;
                -webkit-transition-duration: 0.4s; /* Safari */
                transition-duration: 0.4s;}
                
                .button_Sleep:hover
                {background-color: #FA8072; /* Green */
                color: #000000;
                border: 2px solid #000000;}
                
                </style>
                
                </head>
                
                <body>
                
                <br>
                
                <h1>DANGER!!</h1>
                
                <i class="fas fa-exclamation-triangle" style="color:#000000; font-size: 4em;"></i>
                
                <br>
                
                <p>No water level detected.</strong></p>

                <br>

                </div>
                <div style="display: inline-block;">
                <a href="/?Sleep_Button_Web=on"><button class="button_Sleep">Sleep</button></a>
                </div>

                </body>
                </html>"""
    return html

try:
  s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
  s.bind(('', 80))
  s.listen(5)
  s.setblocking(False)
except OSError as e:
  machine.reset()

while True:
    
    # if the initial variable is equal to 0 the equipment will be started
    if (i==0):

        if (j==0):
            # Defines the welcome message to be showed by the equipment
            # Cleans the display
            display.fill(0)
            # Text to be showed by the display
            display.text('Termo 3D', 28, 30, 1)
            display.show()
            # Keeps the text in the display during 5 seconds
            time.sleep(4)
        
        j=1
        
        # If the water level sensor detects water
        if (water_level.read() > 1000):
            
            # Turns off the buzzer
            buzzer.value(0)
            # Turns on the motor
            motor.value(1)
            # Calculates the internal temperature measured by the thermistor
            internal_temp = Internal_Temp()
            
            # Gets the water temperature measured by the sensor
            temp_sensor.convert_temp()
            time.sleep_ms(1000)
            for rom in roms:
                water_temp = temp_sensor.read_temp(rom)
            
            # Cleans the display
            display.fill(0)
            # Shows the water temperature
            display.text('Temperatura', 0, 10, 1)
            display.text('Atual:', 0, 25, 1)
            display.text(str(round(water_temp,1)), 0, 45, 1)
            display.text('C', 35, 45, 1)
            display.show()
            time.sleep_ms(10)
            
            # If the plus button is pressed, decrease the desired temperature by 1
            if (plus_button.value()==0 and minus_button.value()==1):
                desired_temp -= 0.5
                display.fill(0)
                display.text('Temperatura', 0, 10, 1)
                display.text('Desejada:', 0, 25, 1)
                display.text(str(round(desired_temp,2)), 0, 45, 1)
                display.text('C', 35, 45, 1)
                display.show()
                time.sleep(0.5)
            
            # If the minus button is pressed, increase the desired temperature by 1
            if (minus_button.value()==0 and plus_button.value()==1):
                desired_temp += 0.5
                display.fill(0)
                display.text('Temperatura', 0, 10, 1)
                display.text('Desejada:', 0, 25, 1)
                display.text(str(round(desired_temp,1)), 0, 45, 1)
                display.text('C', 35, 45, 1)
                display.show()
                time.sleep(0.5)
            
            # If the internal temperature is greater than 30ºC turns on the cooler
            if (internal_temp > 30):
                cooler.value(1)
            else:
                cooler.value(0)
            
            if cooler.value() == 1:
                cooler_State = "ON"
            else:
                cooler_State = "OFF"
                
            Intern_Temp = Internal_Temp()
            
            # If the water temperature is lower than the desired temperature turns on the heater
            if (water_temp<desired_temp):
                ac_control.value(1)

            if (water_temp>=desired_temp):
                ac_control.value(0)
            
            print(water_temp<desired_temp)
            
            # If the two buttons are pressed when the equipment is working, turns it off by setting the initial variable as 1
            if (plus_button.value()==0 and minus_button.value()==0):
                i=1
                # Turns off the buzzer
                buzzer.value(0)
                motor.value(0)
                cooler.value(0)
                # Shows a sleepy face when the equipment isn't working
                display.fill(0)
                display.text('--      --', 23, 10, 1)
                display.text('------', 40, 50, 1)
                display.show()
                time.sleep(2)
                
                if gc.mem_free() < 102000:
                    gc.collect()
                try:
                    conn, addr = s.accept()
                except OSError as e:
                    if e.args[0] == errno.EAGAIN or e.args[0] == errno.EWOULDBLOCK:
                        # não há novas conexões pendentes, continue o loop
                        continue
                    raise
                conn.settimeout(20.0)
                print('Got a connection from %s' % str(addr))
                request = conn.recv(1024)
                conn.settimeout(None)
                request = str(request)
                print('Content = %s' % request)
                
                response = web_page_no_water()
                conn.send('HTTP/1.1 200 OK\n')
                conn.send('Content-Type: text/html\n')
                conn.send('Connection: close\n\n')
                conn.sendall(response)
                conn.close()

            if gc.mem_free() < 102000:
                gc.collect()
            try:
                conn, addr = s.accept()
            except OSError as e:
                if e.args[0] == errno.EAGAIN or e.args[0] == errno.EWOULDBLOCK:
                    # não há novas conexões pendentes, continue o loop
                    continue
                raise
            conn.settimeout(20.0)
            print('Got a connection from %s' % str(addr))
            request = conn.recv(1024)
            conn.settimeout(None)
            request = str(request)
            print('Content = %s' % request)
            response = web_page_with_water()
            conn.send('HTTP/1.1 200 OK\n')
            conn.send('Content-Type: text/html\n')
            conn.send('Connection: close\n\n')
            conn.sendall(response)
            conn.close()

            Sleep_Button_Web = request.find('/?Sleep_Button_Web=on')

            # If the two buttons are pressed when the equipment is working, turns it off by setting the initial variable as 1
            if (Sleep_Button_Web==6):
                i=1
                # Turns off the buzzer
                buzzer.value(0)
                motor.value(0)
                cooler.value(0)
                ac_control.value(0)
                
                # Shows a sleepy face when the equipment isn't working
                display.fill(0)
                display.text('--      --', 23, 10, 1)
                display.text('------', 40, 50, 1)
                display.show()
                time.sleep(2)
                
                if gc.mem_free() < 102000:
                    gc.collect()
                try:
                    conn, addr = s.accept()
                except OSError as e:
                    if e.args[0] == errno.EAGAIN or e.args[0] == errno.EWOULDBLOCK:
                        # não há novas conexões pendentes, continue o loop
                        continue
                    raise
                conn.settimeout(20.0)
                print('Got a connection from %s' % str(addr))
                request = conn.recv(1024)
                conn.settimeout(None)
                request = str(request)
                print('Content = %s' % request)
                
                response = web_page_no_water()
                conn.send('HTTP/1.1 200 OK\n')
                conn.send('Content-Type: text/html\n')
                conn.send('Connection: close\n\n')
                conn.sendall(response)
                conn.close()

            Plus_Button_Web = request.find('/?Plus_Button_Web=on')
            Minus_Button_Web = request.find('/?Minus_Button_Web=on')
            
            if Plus_Button_Web == 6:
                desired_temp += 0.5
            if Minus_Button_Web == 6:
                desired_temp -= 0.5
        
        # If the water level sensor doesn't detect water
        else:
            
            # Turns on the buzzer as a warning
            buzzer.value(1)
            # Turns off the heater 
            ac_control.value(0)
            # Turns off the motor
            motor.value(0)
            # Clens the display
            display.fill(0)
            # Advise that there is no water
            display.text('WARNING', 34, 15, 1)
            display.text('NO WATER', 30, 30, 1)
            display.text('DETECTED', 30, 45, 1)
            display.show()
            
            # If the two buttons are pressed when the equipment is working, turns it off by setting the initial variable as 1
            if (plus_button.value()==0 and minus_button.value()==0):
                i=1
                # Turns off the buzzer
                buzzer.value(0)
                motor.value(0)
                cooler.value(0)
                ac_control.value(0)
                
                # Shows a sleepy face when the equipment isn't working
                display.fill(0)
                display.text('--      --', 23, 10, 1)
                display.text('------', 40, 50, 1)
                display.show()
                time.sleep(2)
        
                if gc.mem_free() < 102000:
                    gc.collect()
                try:
                    conn, addr = s.accept()
                except OSError as e:
                    if e.args[0] == errno.EAGAIN or e.args[0] == errno.EWOULDBLOCK:
                        # não há novas conexões pendentes, continue o loop
                        continue
                    raise
                conn.settimeout(20.0)
                print('Got a connection from %s' % str(addr))
                request = conn.recv(1024)
                conn.settimeout(None)
                request = str(request)
                print('Content = %s' % request)
                
                response = web_page_no_water()
                conn.send('HTTP/1.1 200 OK\n')
                conn.send('Content-Type: text/html\n')
                conn.send('Connection: close\n\n')
                conn.sendall(response)
                conn.close()
            
            if gc.mem_free() < 102000:
                gc.collect()
            try:
                conn, addr = s.accept()
            except OSError as e:
                if e.args[0] == errno.EAGAIN or e.args[0] == errno.EWOULDBLOCK:
                    # não há novas conexões pendentes, continue o loop
                    continue
                raise
            print('1')
            conn.settimeout(20.0)
            print('Got a connection from %s' % str(addr))
            request = conn.recv(1024)
            conn.settimeout(None)
            request = str(request)
            print('Content = %s' % request)
            
            response = web_page_no_water()
            conn.send('HTTP/1.1 200 OK\n')
            conn.send('Content-Type: text/html\n')
            conn.send('Connection: close\n\n')
            conn.sendall(response)
            conn.close()
            
            Sleep_Button_Web = request.find('/?Sleep_Button_Web=on')
            
            # If the two buttons are pressed when the equipment is working, turns it off by setting the initial variable as 1
            if (Sleep_Button_Web==6):
                i=1
                # Turns off the buzzer
                buzzer.value(0)
                motor.value(0)
                cooler.value(0)
                ac_control.value(0)
                
                # Shows a sleepy face when the equipment isn't working
                display.fill(0)
                display.text('--      --', 23, 3, 1)
                display.text('------', 40, 27, 1)
                display.text('IP: ', 3, 55, 1)
                display.text(ip, 28, 55, 1)
                display.show()
                time.sleep(2)
        
                if gc.mem_free() < 102000:
                    gc.collect()
                try:
                    conn, addr = s.accept()
                except OSError as e:
                    if e.args[0] == errno.EAGAIN or e.args[0] == errno.EWOULDBLOCK:
                        # não há novas conexões pendentes, continue o loop
                        continue
                    raise
                conn.settimeout(20.0)
                print('Got a connection from %s' % str(addr))
                request = conn.recv(1024)
                conn.settimeout(None)
                request = str(request)
                print('Content = %s' % request)
                
                response = web_page_no_water()
                conn.send('HTTP/1.1 200 OK\n')
                conn.send('Content-Type: text/html\n')
                conn.send('Connection: close\n\n')
                conn.sendall(response)
                conn.close()
            
    else:

        # Turns off the buzzer
        buzzer.value(0)
        motor.value(0)
        cooler.value(0)
        ac_control.value(0)
        
        # Shows a sleepy face when the equipment isn't working
        display.fill(0)
        display.text('--      --', 23, 3, 1)
        display.text('------', 40, 27, 1)
        display.text('IP: ', 3, 55, 1)
        display.text(ip, 28, 55, 1)
        display.show()
        
        # If the two buttons are pressed when the equipment isn't working, turns it on by setting the initial variable as 0
        if (plus_button.value()==0 and minus_button.value()==0):
            i=0
            j=0
        
        if gc.mem_free() < 102000:
            gc.collect()
        try:
            conn, addr = s.accept()
        except OSError as e:
            if e.args[0] == errno.EAGAIN or e.args[0] == errno.EWOULDBLOCK:
                # não há novas conexões pendentes, continue o loop
                continue
            raise
        conn.settimeout(20.0)
        print('Got a connection from %s' % str(addr))
        request = conn.recv(1024)
        conn.settimeout(None)
        request = str(request)
        print('Content = %s' % request)
        
        response = web_page_sleeping()
        
        WakeUp_Button_Web = request.find('/?WakeUp_Button_Web=on')
        
        conn.send('HTTP/1.1 200 OK\n')
        conn.send('Content-Type: text/html\n')
        conn.send('Connection: close\n\n')
        conn.sendall(response)
        conn.close()
        
        # If the two buttons are pressed when the equipment isn't working, turns it on by setting the initial variable as 0
        if (WakeUp_Button_Web==6):
            i=0
            j=0
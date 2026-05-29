"""
/*
 * serial.py
 *
 *  Created: 29-05-2026 18:44:40
 *   Author: barathrajkb
 */
"""
import serial

ser = serial.Serial("COM6", 9600)

while True:
    if ser.read(1)[0] == 0xAA:
        low = ser.read(1)[0]
        high = ser.read(1)[0]

        distance = (high << 8) | low

        print(f"{distance} cm")
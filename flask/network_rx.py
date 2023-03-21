#!/usr/bin/env python
"""
Simplest possible example of using RF24Network

BASE STATION 
Listens for messages from the sensors and prints them out.
"""
import struct
from pyrf24 import RF24, RF24Network, RF24NetworkHeader


radio = RF24(22, 0)
network = RF24Network(radio)

# Address of our node in Octal format (01, 021, etc)
THIS_NODE = 0o0  # make this node behave like the network master node

# initialize the nRF24L01 on the spi bus
if not radio.begin():
    raise OSError("nRF24L01 hardware isn't responding")

radio.channel = 90
network.begin(THIS_NODE)
radio.print_pretty_details()

EXPECTED_SIZE = struct.calcsize("<LL")

try:
    while True:
        network.update()
        while network.available():
            header, payload = network.read()
            millis, packet_count = struct.unpack("<LL", payload[:EXPECTED_SIZE])
            print(f'payload len: {len(payload)}, packet count: {packet_count}, header: {header.to_string()}') 
except KeyboardInterrupt:
    print("powering down radio and exiting.")
    radio.power = False

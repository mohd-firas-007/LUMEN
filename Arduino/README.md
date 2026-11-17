# Arduino Controller

This directory contains the Arduino firmware for LUMEN.

## Hardware

- Arduino UNO R3
- Six Light Dependent Resistors (LDRs)
- Six 10kΩ resistors

## Sensor Configuration

Each LDR is connected to an independent analogue input:

- LDR 1 → A0
- LDR 2 → A1
- LDR 3 → A2
- LDR 4 → A3
- LDR 5 → A4
- LDR 6 → A5

## Serial Communication

The Arduino reads all six analogue sensors and transmits their readings to the computer using serial communication.

- Baud rate: 9600
- Data format: Comma-separated values
- Transmission interval: 20 milliseconds

The transmitted data is received and processed by the ChucK sound engine.

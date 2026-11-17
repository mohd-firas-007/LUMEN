# LUMEN — System Architecture

## Overview

LUMEN consists of six light sensors, an Arduino UNO R3, serial communication, and a ChucK-based sound engine.

## Data Flow

1. Six LDR sensors detect surrounding light intensity.
2. Arduino reads the analogue values through A0–A5.
3. Sensor readings are transmitted to the computer over serial communication at 9600 baud.
4. ChucK receives and processes the readings.
5. The sound engine generates ambient tones and musical events based on changes in light intensity.
6. Audio is played through the computer's audio output.

## Processing Pipeline

**Light Detection → Arduino Processing → Serial Transmission → ChucK Sound Generation → Audio Output**

# LUMEN

### Where Light Becomes Music.

LUMEN (Light-Utilising Musical Expression Network) is an experimental light-controlled musical instrument that transforms changes in light intensity into sound.

Inspired by the Illumaphone, LUMEN explores the intersection of electronics, programming, and sound design, allowing users to create music through light and movement rather than conventional musical interfaces.

Built around six Light Dependent Resistors (LDRs), an Arduino UNO R3, and the ChucK audio programming language, LUMEN translates real-time sensor readings into an evolving musical experience.

## How It Works

- **Light Detection:** Six independent LDR sensors measure changes in surrounding light intensity.
- **Signal Processing:** The Arduino UNO reads analogue sensor values and transmits them to a computer through serial communication.
- **Sound Generation:** ChucK processes the incoming data and generates sound using synthesised instruments, harmonies, and ambient effects.
- **Musical Interaction:** Light intensity influences the ambient soundscape, while changes in illumination trigger musical events.

## Technologies Used

- Arduino UNO R3
- Light Dependent Resistors (LDRs)
- ChucK
- Arduino IDE
- Serial Communication

## System Architecture

LUMEN follows a simple data-processing pipeline:

**Six LDR Sensors → Arduino UNO R3 → Serial Communication → ChucK Sound Engine → Audio Output**

The six sensors detect changes in light intensity. The Arduino reads their analogue values and transmits them to a computer, where ChucK processes the incoming data to generate an evolving soundscape.

## Project Structure

```text
LUMEN/
├── Arduino/
│   ├── README.md
│   └── Lumen_UNO_R3.ino
│
├── ChucK/
│   ├── README.md
│   ├── LUMEN_V2.0.ck
│   ├── LUMEN_V2.5.ck
│   └── LUMEN_V2.6.ck
│
├── Documentation/
│   ├── README.md
│   ├── SYSTEM_ARCHITECTURE.md
│   └── LUMEN_Hardware_Showcase.mp4
│
└── README.md
```

## Development Versions

| Version | Description |
|---|---|
| V2.0 | Initial six-sensor implementation |
| V2.5 | Organic sound generation and ambient harmonies |
| V2.6 | Refined organic soundscape and smoother sensor response |

**Latest documented version: V2.6**

## Hardware Showcase

A short look at the LUMEN hardware prototype:

[View Hardware Showcase](Documentation/LUMEN_Hardware_Showcase.mp4)

## Future Scope

- More expressive sound-generation techniques
- Improved sensor calibration
- Additional sound textures and musical behaviours
- A refined physical enclosure for the instrument

## Acknowledgements

Inspired by the Illumaphone project by [Bonnie Eisenman](https://blog.bonnieeisenman.com/projects/illumaphone/).

## Project Motto

**Where Light Becomes Music.**

## Vision

LUMEN explores a different way of interacting with music, turning light into an expressive medium for sound creation.

**Where Light Becomes Music.**

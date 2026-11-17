2 => int device;

SerialIO cereal;

if (!cereal.open(device, SerialIO.B9600, SerialIO.ASCII)) {
    <<< "ERROR: Arduino connection failed!" >>>;
    me.exit();
}

// Musical scale: C major pentatonic
[48, 50, 53, 55, 57, 60, 62, 65] @=> int scale[];

// Audio routing
SinOsc bass => Gain g1 => PRCRev rev => dac;
TriOsc piano => Gain g2 => rev;
SinOsc bells => Gain g3 => rev;
SawOsc pluck => Gain g4 => rev;
SinOsc pad => Gain g5 => rev;
TriOsc mallet => Gain g6 => rev;

// Reverb
0.15 => rev.mix;

// Initial gain
0.0 => g1.gain;
0.0 => g2.gain;
0.0 => g3.gain;
0.0 => g4.gain;
0.0 => g5.gain;
0.0 => g6.gain;

// Six sensor values
int values[6];

<<< "================================" >>>;
<<< "       LUMEN V2 STARTED         " >>>;
<<< "       SIX SENSOR MODE          " >>>;
<<< "       ARDUINO: COM6            " >>>;
<<< "================================" >>>;

// Main sensor loop
while (true) {

    cereal.onLine() => now;
    cereal.getLine() => string line;

    0 => int start;
    0 => int count;

    // Parse comma-separated Arduino data
    for (0 => int i; i <= line.length(); i++) {

        if (i == line.length() || line.charAt(i) == 44) {

            if (count < 6) {
                Std.atoi(line.substring(start, i - start))
                    => values[count];

                count++;
            }

            i + 1 => start;
        }
    }

    // Process only complete six-sensor lines
    if (count == 6) {

        for (0 => int i; i < 6; i++) {

            Math.max(0, Math.min(1023, values[i]))
                => values[i];

            // Map brightness to musical scale
            ((values[i] * 7) / 1024) => int index;
            Math.min(7, index) => index;
            scale[index] => int note;

            // PERSONALITY 1: DEEP BASS
            if (i == 0) {
                Std.mtof(note - 12) => bass.freq;
                0.02 + values[i] / 1023.0 * 0.09
                    => g1.gain;
            }

            // PERSONALITY 2: WARM PIANO-LIKE TONE
            if (i == 1) {
                Std.mtof(note + 12) => piano.freq;
                0.015 + values[i] / 1023.0 * 0.06
                    => g2.gain;
            }

            // PERSONALITY 3: HIGH BELLS
            if (i == 2) {
                Std.mtof(note + 24) => bells.freq;
                0.01 + values[i] / 1023.0 * 0.045
                    => g3.gain;
            }

            // PERSONALITY 4: PLUCK
            if (i == 3) {
                Std.mtof(note + 12) => pluck.freq;
                0.01 + values[i] / 1023.0 * 0.035
                    => g4.gain;
            }

            // PERSONALITY 5: AMBIENT PAD
            if (i == 4) {
                Std.mtof(note) => pad.freq;
                0.01 + values[i] / 1023.0 * 0.035
                    => g5.gain;
            }

            // PERSONALITY 6: MALLET
            if (i == 5) {
                Std.mtof(note + 19) => mallet.freq;
                0.01 + values[i] / 1023.0 * 0.045
                    => g6.gain;
            }
        }

        // Display live readings
        <<< "LDR:", values[0], values[1], values[2],
            values[3], values[4], values[5] >>>;
    }
}

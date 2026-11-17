// ---------- SERIAL CONNECTION ----------

2 => int device;

SerialIO cereal;

if (!cereal.open(device, SerialIO.B9600, SerialIO.ASCII)) {
    <<< "ERROR: Could not connect to Arduino COM6" >>>;
    me.exit();
}

// ---------- MUSICAL SCALE ----------

// C major pentatonic
[60, 64, 67, 69, 72, 76, 79] @=> int scale[];

// Different registers for each personality
[-12, -12, 0, 0, 12, 12] @=> int octave[];

// ---------- REVERB ----------

PRCRev rev => dac;
0.16 => rev.mix;

// ---------- EVENT VOICES ----------

// 1. Bass
SinOsc bass => Gain event1 => rev;

// 2. Piano-like
TriOsc piano => Gain event2 => rev;

// 3. Bells
SinOsc bell => Gain event3 => rev;

// 4. Plucked string
TriOsc pluck => Gain event4 => rev;

// 5. Soft mallet
SinOsc mallet => Gain event5 => rev;

// 6. High chime
SinOsc chime => Gain event6 => rev;

// ---------- AMBIENT VOICES ----------

// Six sustained harmonic tones
SinOsc pad1 => Gain ambient1 => rev;
SinOsc pad2 => Gain ambient2 => rev;
SinOsc pad3 => Gain ambient3 => rev;
SinOsc pad4 => Gain ambient4 => rev;
SinOsc pad5 => Gain ambient5 => rev;
SinOsc pad6 => Gain ambient6 => rev;

// ---------- AMBIENT CHORD ----------

// C major / extended harmony
Std.mtof(48) => pad1.freq;
Std.mtof(52) => pad2.freq;
Std.mtof(55) => pad3.freq;
Std.mtof(57) => pad4.freq;
Std.mtof(60) => pad5.freq;
Std.mtof(64) => pad6.freq;

// Quiet initial ambient levels
0.008 => ambient1.gain;
0.008 => ambient2.gain;
0.008 => ambient3.gain;
0.008 => ambient4.gain;
0.008 => ambient5.gain;
0.008 => ambient6.gain;

// Event voices start silent
0.0 => event1.gain;
0.0 => event2.gain;
0.0 => event3.gain;
0.0 => event4.gain;
0.0 => event5.gain;
0.0 => event6.gain;

// ---------- SENSOR VARIABLES ----------

int values[6];
int previous[6];

float brightness[6];
float pulse[6];

0 => int initialized;

// Event sensitivity
35 => int threshold;

// ---------- STARTUP ----------

<<< "==================================" >>>;
<<< "       LUMEN V2.5                 " >>>;
<<< "       ORGANIC MODE               " >>>;
<<< "       SIX LDR INPUTS              " >>>;
<<< "       ARDUINO COM6                " >>>;
<<< "==================================" >>>;

// ---------- MAIN LOOP ----------

while (true) {

    cereal.onLine() => now;
    cereal.getLine() => string line;

    // Parse six comma-separated values
    0 => int start;
    0 => int count;

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

    // Process only complete readings
    if (count == 6) {

        for (0 => int i; i < 6; i++) {

            if (values[i] < 0) 0 => values[i];
            if (values[i] > 1023) 1023 => values[i];

        }

        // Avoid false triggers at startup
        if (initialized == 0) {

            for (0 => int i; i < 6; i++) {
                values[i] => previous[i];
                values[i] => int initial;

                // Initial brightness calibration
                (initial - 80.0) / 820.0 => brightness[i];

                if (brightness[i] < 0.0) 0.0 => brightness[i];
                if (brightness[i] > 1.0) 1.0 => brightness[i];
            }

            1 => initialized;
        }

        else {

            // ---------- SENSOR PROCESSING ----------

            for (0 => int i; i < 6; i++) {

                // Smooth brightness mapping
                (values[i] - 80.0) / 820.0 => float target;

                if (target < 0.0) 0.0 => target;
                if (target > 1.0) 1.0 => target;

                // Smooth transitions
                brightness[i] +
                    (target - brightness[i]) * 0.08
                    => brightness[i];

                // Exponential event decay
                pulse[i] * 0.90 => pulse[i];

                // Detect significant light movement
                if (values[i] - previous[i] > threshold ||
                    previous[i] - values[i] > threshold) {

                    // Choose a note from the scale
                    ((values[i] * 6) / 1024) => int index;

                    if (index > 6) 6 => index;

                    scale[index] + octave[i] => int note;

                    // Trigger the corresponding voice
                    if (i == 0) {
                        Std.mtof(note - 12) => bass.freq;
                        0.13 => pulse[i];
                    }

                    if (i == 1) {
                        Std.mtof(note) => piano.freq;
                        0.10 => pulse[i];
                    }

                    if (i == 2) {
                        Std.mtof(note + 12) => bell.freq;
                        0.09 => pulse[i];
                    }

                    if (i == 3) {
                        Std.mtof(note) => pluck.freq;
                        0.09 => pulse[i];
                    }

                    if (i == 4) {
                        Std.mtof(note + 12) => mallet.freq;
                        0.08 => pulse[i];
                    }

                    if (i == 5) {
                        Std.mtof(note + 12) => chime.freq;
                        0.07 => pulse[i];
                    }
                }

                values[i] => previous[i];
            }

            // ---------- AMBIENT LAYER ----------

            0.006 + brightness[0] * 0.012 => ambient1.gain;
            0.006 + brightness[1] * 0.012 => ambient2.gain;
            0.006 + brightness[2] * 0.012 => ambient3.gain;
            0.006 + brightness[3] * 0.012 => ambient4.gain;
            0.006 + brightness[4] * 0.012 => ambient5.gain;
            0.006 + brightness[5] * 0.012 => ambient6.gain;

            // ---------- EVENT MIX ----------

            pulse[0] => event1.gain;
            pulse[1] => event2.gain;
            pulse[2] => event3.gain;
            pulse[3] => event4.gain;
            pulse[4] => event5.gain;
            pulse[5] => event6.gain;

            // Console monitoring
            <<< "LDR:",
                values[0], values[1], values[2],
                values[3], values[4], values[5] >>>;
        }
    }
}

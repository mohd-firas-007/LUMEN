// ---------- SERIAL ----------

2 => int device;

SerialIO cereal;

if (!cereal.open(device, SerialIO.B9600, SerialIO.ASCII)) {
    <<< "ERROR: Could not connect to Arduino COM6" >>>;
    me.exit();
}

// ---------- MUSICAL SCALE ----------

// C major pentatonic
[60, 62, 64, 67, 69, 72, 74, 76] @=> int scale[];

// Each sensor has its own register
[-12, -12, 0, 0, 12, 12] @=> int octave[];

// ---------- MASTER REVERB ----------

PRCRev rev => dac;
0.24 => rev.mix;

// ---------- AMBIENT SOUND BED ----------

// Warm extended C major harmony
SinOsc pad1 => Gain ambient1 => rev;
SinOsc pad2 => Gain ambient2 => rev;
SinOsc pad3 => Gain ambient3 => rev;
SinOsc pad4 => Gain ambient4 => rev;
SinOsc pad5 => Gain ambient5 => rev;
SinOsc pad6 => Gain ambient6 => rev;

// C3, G3, D4, E4, G4, B4
Std.mtof(48) => pad1.freq;
Std.mtof(55) => pad2.freq;
Std.mtof(62) => pad3.freq;
Std.mtof(64) => pad4.freq;
Std.mtof(67) => pad5.freq;
Std.mtof(71) => pad6.freq;

// Gentle ambient foundation
0.010 => ambient1.gain;
0.009 => ambient2.gain;
0.008 => ambient3.gain;
0.007 => ambient4.gain;
0.006 => ambient5.gain;
0.004 => ambient6.gain;

// ---------- EVENT INSTRUMENTS ----------

// 1. Deep bass
SinOsc bass => Gain event1 => rev;

// 2. Warm piano-like tone
TriOsc piano => Gain event2 => rev;

// 3. Delicate bell
SinOsc bell => Gain event3 => rev;

// 4. Wooden pluck
TriOsc pluck => Gain event4 => rev;

// 5. Soft mallet
SinOsc mallet => Gain event5 => rev;

// 6. High chime
SinOsc chime => Gain event6 => rev;

// Start silent
0.0 => event1.gain;
0.0 => event2.gain;
0.0 => event3.gain;
0.0 => event4.gain;
0.0 => event5.gain;
0.0 => event6.gain;

// ---------- SENSOR DATA ----------

int values[6];
int previous[6];

float brightness[6];
float pulse[6];
float pulseTarget[6];

int cooldown[6];

0 => int initialized;

// Sensitivity
40 => int threshold;

// ---------- STARTUP ----------

<<< "====================================" >>>;
<<< "       LUMEN V2.6                   " >>>;
<<< "       ORGANIC SOUNDSCAPE           " >>>;
<<< "       SIX SENSOR MODE              " >>>;
<<< "====================================" >>>;

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

    if (count == 6) {

        // Clamp sensor values
        for (0 => int i; i < 6; i++) {
            Math.max(0, Math.min(1023, values[i]))
                => values[i];
        }

        // First reading establishes baseline
        if (initialized == 0) {

            for (0 => int i; i < 6; i++) {
                values[i] => previous[i];

                (values[i] - 80.0) / 820.0
                    => brightness[i];

                if (brightness[i] < 0.0) 0.0 => brightness[i];
                if (brightness[i] > 1.0) 1.0 => brightness[i];

                0.0 => pulse[i];
                0.0 => pulseTarget[i];
                0 => cooldown[i];
            }

            1 => initialized;
        }

        else {

            // ---------- SENSOR PROCESSING ----------

            for (0 => int i; i < 6; i++) {

                // Brightness normalisation
                (values[i] - 80.0) / 820.0 => float target;

                if (target < 0.0) 0.0 => target;
                if (target > 1.0) 1.0 => target;

                // Smooth ambient response
                brightness[i] +
                    (target - brightness[i]) * 0.035
                    => brightness[i];

                // Cooldown prevents repeated triggering
                if (cooldown[i] > 0) {
                    cooldown[i] - 1 => cooldown[i];
                }

                // Gradually fade previous event
                pulseTarget[i] * 0.993 => pulseTarget[i];

                // Detect significant light movement
                if (Math.fabs(values[i] - previous[i]) > threshold
                    && cooldown[i] == 0) {

                    // Choose a compatible musical note
                    ((values[i] * 7) / 1024) => int index;
                    Math.min(7, index) => index;

                    scale[index] + octave[i] => int note;

                    // Trigger each personality
                    if (i == 0) {
                        Std.mtof(note - 12) => bass.freq;
                        0.12 => pulseTarget[i];
                    }

                    if (i == 1) {
                        Std.mtof(note) => piano.freq;
                        0.075 => pulseTarget[i];
                    }

                    if (i == 2) {
                        Std.mtof(note + 12) => bell.freq;
                        0.065 => pulseTarget[i];
                    }

                    if (i == 3) {
                        Std.mtof(note) => pluck.freq;
                        0.070 => pulseTarget[i];
                    }

                    if (i == 4) {
                        Std.mtof(note + 12) => mallet.freq;
                        0.065 => pulseTarget[i];
                    }

                    if (i == 5) {
                        Std.mtof(note + 12) => chime.freq;
                        0.055 => pulseTarget[i];
                    }

                    12 => cooldown[i];
                }

                // Smooth attack and release
                pulse[i] +
                    (pulseTarget[i] - pulse[i]) * 0.16
                    => pulse[i];

                values[i] => previous[i];
            }

            // ---------- AMBIENT MIX ----------

            // Brightness subtly changes the atmosphere
            0.006 + brightness[0] * 0.009 => ambient1.gain;
            0.006 + brightness[1] * 0.009 => ambient2.gain;
            0.005 + brightness[2] * 0.009 => ambient3.gain;
            0.005 + brightness[3] * 0.009 => ambient4.gain;
            0.004 + brightness[4] * 0.008 => ambient5.gain;
            0.003 + brightness[5] * 0.007 => ambient6.gain;

            // ---------- EVENT MIX ----------

            pulse[0] => event1.gain;
            pulse[1] => event2.gain;
            pulse[2] => event3.gain;
            pulse[3] => event4.gain;
            pulse[4] => event5.gain;
            pulse[5] => event6.gain;

        }
    }
}

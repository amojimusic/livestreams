//livestream9;
s.boot;

~fmBus = Bus.audio(s, 2);
~modBus = Bus.audio(s, 2);
~reverbBus = Bus.audio(s, 2);
~reverb2Bus = Bus.audio(s, 2);





~scale = [60, 60 + 0.545454, 60 + (0.545454 * 2), 60 + (0.545454 * 3), 60 + (0.545454 * 4), 60 + (0.545454 * 5), 60 + (0.545454 * 6), 60 + (0.545454 * 7), 60 + (0.545454 * 8), 60 + (0.545454 * 9), 60 + (0.545454 * 10), 60 + (0.545454 * 11), 60 + (0.545454 * 12), 60 + (0.545454 * 13), 60 + (0.545454 * 14), 60 + (0.545454 * 15), 60 + (0.545454 * 16), 60 + (0.545454 * 17), 60 + (0.545454 * 18), 60 + (0.545454 * 19), 60 + (0.545454 * 20), 60 + (0.545454 * 21), 72];

~key = [60,60 + (0.545454 * 3), 60 + (0.545454 * 4), 60 + (0.545454 * 6), 60 + (0.545454 * 9), 60 + (0.545454 * 12), 60 + (0.545454 * 15), 60 + (0.545454 * 18), 60 + (0.545454 * 22)];

(SynthDef.new(\reverb, {
	var in;
	in = In.ar(~reverbBus, 2).sum;
	in = FreeVerb.ar(in, 0.6, 0.8, 0.8);
	in = FreeVerb.ar(in, 0.8, 0.8, 0.8);
	in = [in, DelayN.ar(in, 0.0025, 0.0025)] * 0.5;
	in = in * 1.3;
	in = Clip.ar(in, -0.3, 0.3);
	Out.ar(\out.kr(0), in);
	Out.ar(~modBus, in);
};
).add;
);

(SynthDef.new(\reverb2, {
	var in;
	in = In.ar(~reverb2Bus, 2).sum;
	in = FreeVerb.ar(in, 0.6, 0.8, 0.8);
	in = FreeVerb.ar(in, 0.8, 0.8, 0.8);
	in = [DelayN.ar(in, 0.0025, 0.0025), in] * 0.5;
	in = in * 1.1;
	in = Clip.ar(in, -0.3, 0.3);
	Out.ar(\out.kr(0), in);
	Out.ar(~fmBus, in);
};
).add;
);


(SynthDef.new(\synth, {
	var env, pEnv, env2, sig, sig2;
	env = EnvGen.kr(Env([0, \amp.kr(1), 0], [\atk.kr(0.01), \dec.kr(3)]), doneAction: 2);
	pEnv = EnvGen.kr(Env([\freq1.kr(440), \freq2.kr(440), \freq3.kr(440) + (In.ar(~fmBus, 2).sum * 600), \freq4.kr(440), \freq5.kr(440)], [\fst.kr(0.5), \scd.kr(0.5) + (In.ar(~fmBus, 2).sum * 0.5), \thd.kr(0.5), \fth.kr(0.5)], [-10, -10, -10, -10]));
	sig = Select.ar(\sel.kr(0), [RandWave.ar(pEnv, 1) * \mul.kr(1), RandWave.ar(pEnv, 5) * \mul.kr,  Saw.ar(pEnv, \mul.kr(1))]);
	sig = [sig, Select.ar(\sel2.kr(0), [RandWave.ar(pEnv * 2, 1) * \mul.kr(1), RandWave.ar(pEnv * 0.5, 5) * \mul.kr,  Saw.ar(pEnv * 1.5, \mul.kr(1))])].sum * 0.7;
	sig2 = SinOsc.ar(pEnv, 0, \mul.kr(1));
	sig2 = LPF.ar(sig2, pEnv * 0.7);
	sig = LPF.ar(sig, pEnv * 0.8);
	sig = [sig * 0.5, sig2 * 0.5].sum;
	sig = sig * env;
	sig = LPF.ar(sig, 2222);
	sig = Select.ar(\psel.kr(0), [Pan2.ar(sig, \pan.kr(0)), [sig, DelayN.ar(sig, 0.0025, 0.0025)] * 0.5, [DelayN.ar(sig, 0.0025, 0.0025), sig] * 0.5]);
	sig = Clip.ar(sig, -0.3, 0.3);
	sig = sig * 0.5;
	Out.ar(\out.kr(0), sig);
	Out.ar(~modBus, sig);
	Out.ar(~fmBus, sig * 0.3);
};
).add;
);


(SynthDef.new(\acid, {
	var env, pEnv, env2, sig, sig2;
	env = EnvGen.kr(Env([0, \amp.kr(1), 0], [\atk.kr(0.01), \dec.kr(3)]), doneAction: 2);
	pEnv = EnvGen.kr(Env([\freq1.kr(440), \freq2.kr(440), \freq3.kr(440) + (In.ar(~modBus, 2).sum * 600), \freq4.kr(440), \freq5.kr(440)], [\fst.kr(0.5), \scd.kr(0.5) + (In.ar(~modBus, 2).sum * 0.5), \thd.kr(0.5), \fth.kr(0.5)], [-10, -10, -10, -10]));
	sig = Select.ar(\sel.kr(0), [RandWave.ar(pEnv, 1) * \mul.kr(1), RandWave.ar(pEnv, 5) * \mul.kr,  Saw.ar(pEnv, \mul.kr(1))]);
	sig = [sig, Select.ar((env * 3).floor, [RandWave.ar(pEnv * 2, 1) * \mul.kr(1), RandWave.ar(pEnv * 0.5, 5) * \mul.kr,  Saw.ar(pEnv * 1.5, \mul.kr(1))])].sum * 0.7;
	sig2 = SinOsc.ar(pEnv * 1.5, 0, \mul.kr(1));
	sig = [sig * 0.875, sig2 * 0.225].sum;
	sig = sig * env;
	sig2 =  LFNoise2.ar(\ffreq.kr(2), 2400) + 3400 + (env * 500);
	sig = sig * 0.7;
	sig = Clip.ar(sig, -0.05, 0.5);
	sig = LPF.ar(sig, sig2);
	sig2 = BPF.ar(sig, sig2, 0.3);
	sig = [sig * 0.65, sig2 * 0.35].sum;
	sig = HPF.ar(sig, 300);
	sig = Select.ar(\psel.kr(0), [Pan2.ar(sig, \pan.kr(0)), [sig, DelayN.ar(sig, 0.0025, 0.0025)] * 0.5, [DelayN.ar(sig, 0.0025, 0.0025), sig] * 0.5]);
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(\out.kr(0), sig);
	Out.ar(~fmBus, sig);
	Out.ar(~modBus, sig * 0.3);
};
).add;
);

(SynthDef.new(\acid2, {
	var env, pEnv, env2, sig, sig2;
	env = EnvGen.kr(Env([0, \amp.kr(1), 0], [\atk.kr(0.01), \dec.kr(3)]), doneAction: 2);
	pEnv = EnvGen.kr(Env([\freq1.kr(440), \freq2.kr(440), \freq3.kr(440) + (In.ar(~modBus, 2).sum * 600), \freq4.kr(440), \freq5.kr(440)], [\fst.kr(0.5), \scd.kr(0.5) + (In.ar(~modBus, 2).sum * 0.5), \thd.kr(0.5), \fth.kr(0.5)], [-10, -10, -10, -10]));
	sig = Select.ar(\sel.kr(0), [RandWave.ar(pEnv, 1) * \mul.kr(1), RandWave.ar(pEnv, 5) * \mul.kr,  Saw.ar(pEnv, \mul.kr(1))]);
	sig = [sig, Select.ar(\sel2.kr(0), [RandWave.ar(pEnv * 2, 1) * \mul.kr(1), RandWave.ar(pEnv * 0.5, 5) * \mul.kr,  Saw.ar(pEnv * 1.5, \mul.kr(1))])].sum * 0.7;
	sig2 = SinOsc.ar(pEnv * 1.5, 0, \mul.kr(1));
	sig = [sig * 0.875, sig2 * 0.225].sum;
	sig = sig * env;
	sig2 =  LFNoise2.ar(\ffreq.kr(2), 2400) + 3400 + (env * 500);
	sig = sig * 0.7;
	sig = Clip.ar(sig, -0.05, 0.5);
	sig = LPF.ar(sig, sig2);
	sig2 = BPF.ar(sig, sig2, 0.3);
	sig = [sig * 0.65, sig2 * 0.35].sum;
	sig = HPF.ar(sig, 300);
	sig = Select.ar(\psel.kr(0), [Pan2.ar(sig, \pan.kr(0)), [sig, DelayN.ar(sig, 0.0025, 0.0025)] * 0.5, [DelayN.ar(sig, 0.0025, 0.0025), sig] * 0.5]);
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(\out.kr(0), sig);
	Out.ar(~fmBus, sig);
	Out.ar(~modBus, sig * 0.3);
};
).add;
);

(SynthDef.new(\pad, {
	var env, mod, sig;
	env = EnvGen.kr(Env([0, \amp.kr(1), 0], [\atk.kr(2), \dec.kr(3.5)]), doneAction: 2);
	mod = SinOsc.ar(\freq.kr(440) * \r.kr(1.5), 0, \mmul.kr(1));
	sig = Saw.ar(\freq.kr + (mod * 4) + (In.ar(~fmBus, 2).sum * 50), \mul.kr(1));
	sig = LPF.ar(sig, \freq.kr * 0.8);
	sig = HPF.ar(sig, \freq.kr * 0.3);
	sig = [sig, DelayN.ar(sig, 0.0025, 0.0025)] * 0.5;
	sig = FreeVerb.ar(sig, 0.8, 0.8 + (mod * 0.4), 0.7 + (mod * 0.4));
	sig = sig * 1.5;
	sig = sig * env;
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(~reverb2Bus, sig * 0.4);
	Out.ar(\out.kr(0), sig);
	Out.ar(~modBus, sig);
};
).add;
);

(SynthDef.new(\kick, {
	var env, sig;
	env = EnvGen.kr(Env.perc(\atk.kr(0.01), \dec.kr(0.1), \amp.kr(1)), doneAction: 2);
	sig = SinOsc.ar(20 + (env * 90) + WhiteNoise.ar(8), 0, \mul.kr(1) * 1.12);
	sig = sig * env;
	sig = [sig, DelayN.ar(sig, 0.0025, 0.0025)] * 1.15;
	sig = Clip.ar(sig, -0.7, 0.7);
	sig = Select.ar(\psel.kr(0), [[DelayN.ar(sig, 0.0025, 0.0025), sig] * 0.35, [sig, DelayN.ar(sig, 0.0025, 0.0025)] * 0.35, Pan2.ar(sig, \pan.kr(0)) * 0.7]);
	sig = sig * 0.415;
	sig = Clip.ar(sig, -0.3, 0.3);
	sig = sig * 1.05;
	Out.ar(\out.kr(0), sig);
	Out.ar(~fmBus, sig * 5);
};
).add;
);

(SynthDef.new(\snare, {
	var env, sig;
	env = EnvGen.kr(Env.perc(\atk.kr(0.01), \dec.kr(0.1), \amp.kr(1)), doneAction: 2);
	sig = SinOsc.ar(450 + (env * 90) + WhiteNoise.ar(1400) + (In.ar(~modBus, 2).sum * 3000)+ (In.ar(~fmBus, 2).sum * 3000), 0, \mul.kr(1));
	sig = sig * env;
	sig = Select.ar(\psel.kr(0), [[DelayN.ar(sig, 0.0025, 0.0025), sig] * 0.35, [sig, DelayN.ar(sig, 0.0025, 0.0025)] * 0.35, Pan2.ar(sig, \pan.kr(0)) * 0.7]);
	sig = LPF.ar(sig, 3500 + (env * 800));
	sig = HPF.ar(sig, 400);
	sig = sig * 0.85;
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(\out.kr(0), sig * 0.7);
	Out.ar(~modBus, sig * 2.5);
	Out.ar(~reverbBus, sig * 0.3);
};
).add;
);


(SynthDef.new(\hat, {
	var env, sig;
	env = EnvGen.kr(Env.perc(\atk.kr(0.01), \dec.kr(0.1), \amp.kr(1)), doneAction: 2);
	sig = SinOsc.ar(450 + (env * 90) + WhiteNoise.ar(1400), 0, \mul.kr(1));
	sig = sig * env;
	sig = Select.ar(\psel.kr(0), [[DelayN.ar(sig, 0.0025, 0.0025), sig] * 0.35, [sig, DelayN.ar(sig, 0.0025, 0.0025)] * 0.35, Pan2.ar(sig, \pan.kr(0)) * 0.7]);
	sig = LPF.ar(sig, 9500 + (env * 800));
	sig = HPF.ar(sig, 2000);
	sig = sig * 0.85;
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(\out.kr(0), sig);
	Out.ar(~modBus, sig * 2.5);
};
).add;
);


Synth(\snare);

(~synths = Pbind(
	\instrument, \synth,
	\dur, 4,
	\atk, 0.01,
	\dec, Pseq([Prand([2, 2.5, 1.5], 1) * 1.75, Prand([4, 4.5], 1)], inf),
	\freq1, Pseq([60, 60 + (0.545454 * 6), 60 + (0.545454 * 15)].midicps, inf) * Prand([1, 2, 4, 1, 2], inf),
	\freq2, Pseq([60 + (0.545454 * 4),60 + (0.545454 * 3), 60 + (0.545454 * 9)].midicps, inf)* Prand([0.5, 2, 4, 1, 2], inf),
	\freq3, Pseq([60, 60 + (0.545454 * 6)].midicps, inf) * 0.5,
	\freq4, Pseq([60 + (0.545454 * 9), 60 + (0.545454 * 12), 60 + (0.545454 * 15), 60 + (0.545454 * 18)].midicps, inf),
	\freq5, Prand([60, 72, 60 + (0.545454 * 4)].midicps, inf),
	\fst, Prand([0.25, 0.125, 0.5, 0.25, 0.125, 0.5], inf),
	\scd,  Prand([0.25, 0.125, 0.5, 0.25, 0.125, 0.5], inf),
	\thd,  Prand([0.25, 0.125, 0.5, 0.25, 0.125, 0.5, 1], inf),
	\fth,  Prand([0.25, 0.25, 0.125, 0.5, 0.25, 0.125, 0.5, 1], inf),
	\amp, Prand([0.3, 0.4, 0.5, 0.2, 0.5, 0.5, 0.6], inf),
	\sel, Prand([0, 1, 2], inf),
	\sel2, Prand([0, 1, 2], inf),
	\psel, Prand([0, 1, 2], inf),
	\mul, Pwhite(0.4, 0.55, inf),
	\pan, 1,
	\out, Prand([0, 0, 0, 0, 0, 0, 0, 0, ~reverbBus, ~reverb2Bus], inf);
);
);



(~synths2 = Pbind(
	\instrument, \synth,
	\dur, 4,
	\atk, Pwhite(0.01, 0.5, inf),
	\dec, Pwhite(1.5, 5, inf),
	\freq1, Pseq([60, 60 + (0.545454 * 6), 60 + (0.545454 * 15)].midicps, inf),
	\freq2, Pseq([60 + (0.545454 * 4),60 + (0.545454 * 3), 60 + (0.545454 * 9)].midicps, inf) * Prand([1, 2, 4, 1, 2], inf),
	\freq3, Pseq([60, 60 + (0.545454 * 6)].midicps, inf) * Prand([1, 2, 4, 1, 2, 0.5], inf),
	\freq4, Pseq([60 + (0.545454 * 9), 60 + (0.545454 * 12), 60 + (0.545454 * 15), 60 + (0.545454 * 18)].midicps, inf),
	\freq5, Prand([60, 72, 60 + (0.545454 * 4)].midicps, inf) * Prand([1, 2, 4, 1, 2], inf),
	\fst, Prand([0.25, 0.125, 0.125, 0.5, 0.25, 0.125, 0.5, 1], inf),
	\scd,  Prand([0.25, 0.25,  0.125, 0.5, 0.25, 0.125, 0.5, 1], inf),
	\thd,  Prand([0.25, 0.125, 0.25, 0.5, 0.25, 0.125, 0.5, 1], inf),
	\fth,  Prand([0.25, 0.125, 0.5, 0.25, 0.125, 0.5, 1], inf),
	\amp, Prand([0.3, 0.4, 0.5, 0.2, 0.5, 0.5, 0.6], inf),
	\sel, Prand([0, 1, 2], inf),
	\sel2, Prand([0, 1, 2], inf),
	\psel, Prand([0, 1, 2], inf),
	\mul, Pwhite(0.4, 0.55, inf),
	\pan, -1,
	\out, Prand([0, 0, 0, 0, 0, 0, 0, 0, ~reverbBus, ~reverb2Bus], inf);
);
);

(~acid = Pbind(
	\instrument, Prand([\acid, \acid2], inf),
	\dur, 4,
	\atk, Pwhite(00.01, 0.8, inf),
	\dec, Pwhite(0.85, 6.5, inf),
	\freq1, Pseq([60, 60 + (0.545454 * 6), 60 + (0.545454 * 15)].midicps, inf) * Prand([0.5, 0.5, 0.25, 1, 2], inf),
	\freq2, Prand([60,60 + (0.545454 * 3), 60 + (0.545454 * 4), 60 + (0.545454 * 6), 60 + (0.545454 * 9), 60 + (0.545454 * 12), 60 + (0.545454 * 15), 60 + (0.545454 * 18), 60 + (0.545454 * 22)].midicps, inf) * Prand([0.5, 0.5, 0.25, 1, 2], inf) ,
	\freq3, Pseq([60, 60 + (0.545454 * 6)].midicps, inf) * Prand([0.5, 0.5, 0.25, 1, 2], inf),
	\freq4, Prand(~key.midicps, inf) * Prand([0.5, 0.5, 0.25, 1, 2], inf),
	\freq5, Prand([60, 72, 60 + (0.545454 * 4)].midicps, inf),
	\fst, Prand([0.25, 0.125,  0.125, 0.5, 0.25, 0.125, 0.5, 1], inf),
	\scd,  Prand([0.25, 0.125, 0.5, 0.25, 0.125, 0.5, 1], inf),
	\thd,  Prand([0.25, 0.125, 0.125, 0.5, 0.25, 0.125, 0.5, 1], inf),
	\fth,  Prand([0.25, 0.25,  0.125, 0.5, 0.25, 0.125, 0.5, 1], inf),
	\amp, Prand([0.4, 0.3, 0.5, 0.6], inf),
	\sel, Prand([0, 1, 2], inf),
	\sel2, Prand([0, 1, 2], inf),
	\psel, Prand([0, 1, 2], inf),
	\ffreq, Pwhite(0.5, 2, inf),
	\mul, Pwhite(0.4, 0.55, inf),
	\pan, Pwhite(-0.4, 0.4, inf),
	\out, Prand([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ~fmBus], inf);
);
);

(~synths3 = Pbind(
	\instrument, \synth,
	\dur, Prand([ 4, 8, 2, 2, 16, 4, 16, 16], inf),
	\atk, Pwhite(0.01, 0.5, inf),
	\dec, Pwhite(1.5, 3, inf),
	\freq1, Pseq([60, 60 + (0.545454 * 4), 60 + (0.545454 * 18)].midicps, inf),
	\freq2, Pseq([60 + (0.545454 * 4),60 + (0.545454 * 3), 60 + (0.545454 * 9)].midicps, inf) * Prand([2, 4, 1, 2, 8], inf),
	\freq3, Pseq([60, 60 + (0.545454 * 6)].midicps, inf) * Prand([1, 2, 4, 1, 2, 8], inf),
	\freq4, Pseq([60 + (0.545454 * 9), 60 + (0.545454 * 12), 60 + (0.545454 * 15), 60 + (0.545454 * 18)].midicps, inf) * Prand([2, 4], inf),
	\freq5, Prand([60, 72, 60 + (0.545454 * 4)].midicps, inf) * 2,
	\fst, Prand([0.25, 0.125, 0.125, 0.5, 0.25, 0.125, 0.5, 1], inf),
	\scd,  Prand([0.25, 0.25,  0.125, 0.5, 0.25, 0.125, 0.5, 1], inf),
	\thd,  Prand([0.25, 0.125, 0.25, 0.5, 0.25, 0.125, 0.5, 1], inf),
	\fth,  Prand([0.25, 0.125, 0.5, 0.25, 0.125, 0.5, 1], inf),
	\amp, Prand([0.3, 0.4, 0.5, 0.2, 0.6], inf),
	\sel, Prand([0, 1, 2], inf),
	\sel2, Prand([0, 1, 2], inf),
	\psel, Prand([0, 1, 2], inf),
	\mul, Pwhite(0.4, 0.55, inf),
	\pan, Pwhite(-0.6, 0.6, inf),
	\out, Prand([0, 0, 0, 0, 0, 0, 0, 0, ~reverbBus, ~reverb2Bus], inf);
);
);

(~pads = Pbind(
	\instrument, \pad,
	\dur, Prand([4, 8, 2, 4, 4, 2], inf),
	\atk, Pwhite(2, 3, inf),
	\dec, Pwhite(3, 5, inf),
	\freq, Pseq([Prand([[60, 60 + (0.545454 * 6),  60 + (0.545454 * 12)], [60 + (0.545454 * 3),  60 + (0.545454 * 6), 60 + (0.545454 * 18)]], 1), Prand([[60, 60 + (0.545454 * 6),  60 + (0.545454 * 12)], [60 + (0.545454 * 3),  60 + (0.545454 * 6), 60 + (0.545454 * 18)], [60,  60 + (0.545454 * 4), 60 + (0.545454 * 9)], [60 + (0.545454 * 6), 60 + (0.545454 * 12),  60 + (0.545454 * 18)], [60 + (0.545454 * 9), 60 + (0.545454 * 18), 72]], 1)].midicps, inf) * Prand([2, 2, 2, 2, 1, 1, 1, 0.5], inf),
	\amp, 0.5,
	\mul, Prand([0.3, 0.4, 0.4, 0.35, 0.5], inf),
	\r, Prand([1.5, 1, 1.27, 1.25, 1.33, 2], inf),
	\mmul, Pwhite(0.2, 3, inf),
	\out, Prand([0, 0, 0, 0, 0, 0, 0, 0, ~reverbBus, ~reverb2Bus], inf);
);
);

(~drums = Pbind(
	\instrument, Pseq([\kick, \hat, \kick,  Prand([\hat, \hat, \kick, \hat, \kick, \kick, \snare], 1),  \snare, Prand([\kick, \kick, \snare, \snare, \hat, \hat,\hat, \hat, \hat], 3)], inf),
	\dur, Pseq([0.125, 0.125, 0.125, 0.125, 0.25, 0.25, Prand([Pseq([0.25, 0.25, 0.25, 0.25], 1), Pseq([0.25, 0.25, 0.125, 0.375], 1)], 1)], inf),
	\amp, 1.2,
	\mul, Pseq([0.185, 0.197, 0.199], inf) * 0.85,
	\pan, Pwhite(-0.3, 0.3, inf),
	\atk, 0.01,
	\psel, Prand([0, 1, 2], inf),
	\dec, Pwhite(0.07, 0.12, inf),
	\out, 0;
);
);

(~hats = Pbind(
	\instrument, \hat,
	\dur, Prand([0.25, 0.25, 0.5, 0.5, 0.25, 0.5, 0.5, 0.5, 0.25, 0.5, 0.5, Pseq([0.125, 0.125], 1), Pseq([0.125, 0.125], 2)], inf),
	\amp, 1,
	\mul, Pseq([0.2, 0.175, 0.15], inf) * Pwhite(0.7, 0.85, inf),
	\pan, Pwhite(-0.5, 0.5, inf),
	\atk, 0.01,
	\dec, 0.04,
	\psel, Prand([0, 1, 2], inf),
	\out, Prand([0, 0, 0, 0, 0, 0, 0, 0, ~reverbBus, ~reverb2Bus], inf);
);
);


t = TempoClock(54.11/60).permanent_(true);


Synth(\reverb);
Synth(\reverb2);

~synths.play(t);
~synths2.play(t);
~synths3.play(t);
~synths3.play(t);
~acid.play(t);
~pads.play(t);
~drums.play(t);
~hats.play(t);


s.scope;


(~routine = Routine({
	Synth(\reverb);
	Synth(\reverb2);
	~s1 = ~synths.play(t);
	~s2 = ~synths2.play(t);
	wait(8);
	p = ~pads.play(t);
	wait(16);
	~s2.stop;
	~s1.stop;
	a = ~acid.play(t);
	wait(2);
	~s1 = ~synths.play(t);
	~s2 = ~synths2.play(t);
	~s3 = ~synths3.play(t);
	~p  = ~pads.play(t);
	wait(16);
	~s1.stop;
	~s2.stop;
	~s3.stop;
	a.stop;
	a = ~acid.play(t);
	~s1 = ~synths.play(t);
	~s2 = ~synths2.play(t);
	~s3 = ~synths3.play(t);
	d = ~drums.play(t);
	p.stop;
	~p.stop;
	wait(8);
	p = ~pads.play(t);
	~s1.stop;
	~s2.stop;
	h = ~hats.play(t);
	wait(8);
	~s1 = ~synths.play(t);
	~s2 = ~synths2.play(t);
	a.stop;
	wait(16);
	~s2.stop;
	~s1.stop;
	a = ~acid.play(t);
	wait(2);
	~a = ~acid.play(t);
	wait(2);
	~s1 = ~synths.play(t);
	~s2 = ~synths.play(t);
	wait(4);
	~a.stop;
	wait(16);
	d.stop;
	h.stop;
	wait(8);
	a.stop;
	~s1.stop;
	p.stop;
	~s2.stop;
	~s3.stop;
	a = ~acid.play(t);
	~a1 = ~acid.play(t);
	~a2 = ~acid.play(t);
	wait(2);
	~a3 = ~acid.play(t);
	~a4 = ~acid.play(t);
});
);


~routine.play(t);



~key = [60,60 + (0.545454 * 3), 60 + (0.545454 * 4), 60 + (0.545454 * 6), 60 + (0.545454 * 9), 60 + (0.545454 * 12), 60 + (0.545454 * 15), 60 + (0.545454 * 18), 60 + (0.545454 * 22)];
































		
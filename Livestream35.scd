~synthBus = Bus.audio(s, 2);

~tonic = 60;
~di = 12/22;

~edo22 = [~tonic, ~tonic + ~di, ~tonic + (~di * 2), ~tonic + (~di * 3), ~tonic + (~di * 4), ~tonic + (~di * 5), ~tonic + (~di * 6), ~tonic + (~di * 7), ~tonic + (~di * 8), ~tonic + (~di * 9), ~tonic + (~di * 10), ~tonic + (~di * 11), ~tonic + (~di * 12), ~tonic + (~di * 13), ~tonic + (~di * 14), ~tonic + (~di * 15), ~tonic + (~di * 16), ~tonic + (~di * 17), ~tonic + (~di * 18), ~tonic + (~di * 19), ~tonic + (~di * 20), ~tonic + (~di * 21), ~tonic + (~di * 22)];

~key = [~edo22[0], ~edo22[4], ~edo22[7], ~edo22[9], ~edo22[13], ~edo22[17], ~edo22[20]].midicps;

Curt.init;

(Ndef(\synthFX, {
	var in, del;
	in = In.ar(~synthBus, 2);
	del = DelayN.ar(in, 0.5, 0.5);
	in = in.blend(HPF.ar(del, 1000), 0.15);
	del = DelayN.ar(in, 0.5, 0.5);
	in = in.blend(LPF.ar(del, 800), 0.09);
	del = DelayN.ar(in, 0.5, 0.5);
	in = in.blend(del, 0.05);
	del = DelayN.ar(in, 0.5, 0.5);
	in = in.blend(BPF.ar(in, 2000), 0.05);
	del = DelayN.ar(in, 0.5, 0.5);
	in = in.blend(del, 0.05);
	in = in * 1.3;
	in = FreeVerb.ar(in, LFNoise0.ar(0.08, 0.17).abs.clip2(0.99), LFNoise0.ar(0.08, 0.5).abs.clip2(0.99), 0.5);
}));

(SynthDef.new(\synth, {
	var env, pEnv, sig;
	env = Env.perc(\atk.kr(0.01), \dec.kr(0.2), \amp.kr(1)).kr(2);
	pEnv = Env.perc(0.0001, 0.01).kr;
	sig = SinOsc.ar(\freq.kr(440) + (pEnv * 500) + (LocalIn.ar * 50), 0, \mul.kr(1));
	sig = sig.blend(GeneRand.ar(\freq.kr + (pEnv * 500) + (LocalIn.ar * 25)) * \mul.kr, 0.4);
	sig = sig.blend(Saw.ar(\freq.kr(440) + (pEnv * 500) + (sig * 50), \mul.kr(1)), 0.6);
	sig = LPF.ar(sig, 2200);
	sig = BPF.ar(sig, \freq.kr, 0.7);
	sig = sig * 0.9;
	sig = sig * env;
	LocalOut.ar(sig);
	sig = Pan2.ar(sig, \pan.kr(0));
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef(\acid, {
	var env, sig;
	env = Env.perc(\atk.kr(0.01), \dec.kr(0.03), \amp.kr(1)).kr(2);
	sig = Saw.ar(\freq.kr(440), \mul.kr(1));
	sig = sig.blend(Pulse.ar(\freq.kr, 0.5, \mul.kr), 0.05);
	sig = sig.blend(Pulse.ar(\freq.kr * 4, 0.5, \mul.kr), 0.05);
	sig = RLPF.ar(sig, \freq.kr * 0.5 + (\freq.kr * (LFNoise2.ar(1, 64).abs.floor)) + (env * \freq.kr), 0.045 + LFNoise2.ar(0.3, 0.275).abs);
	sig = FreeVerb.ar(sig, 0.05, 0.05, 0.5);
	sig = Clip.ar(sig, -0.7, 0.7);
	sig = sig * env;
	sig = Pan2.ar(sig, \pan.kr(0));
	Out.ar(\out.kr(0), sig * 0.55);
}).add;
);

(SynthDef.new(\kick, {
	var env, sig;
	env = Env.perc(\atk.kr(0.01), \dec.kr(0.2), \amp.kr(1)).kr(2);
	sig = SinOsc.ar(25 + (75 * env), 0, \mul.kr(1));
	sig = Pan2.ar(sig, \pan.kr(0));
	sig = sig * env;
	Out.ar(\out.kr(0), sig);
}).add;
);
Curt.init;


(
(Pdef(\synth, Pbind(
	\instrument, \synth,
	\dur, Pseq([Pseq([0.25], 4), 0.33, 0.33, 0.34, 0.5, 0.125, 0.125, 0.125, 0.125], inf),
	\mul, 0.095,
	\dec, Pseq([1, 1, 0.5, 0.3, 0.3, 0.3, 0.3], inf),
	\freq, Pseq([~key[0], ~key[1], ~key[3], ~key[4], ~key[5], ~key[2], ~key[2], ~key[3]], inf) * Prand([4, 4, 8], inf),
	\amp, 1,
	\pan, Pwhite(-0.6, 0.6, inf),
	\out, ~synthBus

)));

(Pdef(\acid, Pbind(
	\instrument, \acid,
	\dur, Pseq([Prand([0.5, Pseq([0.25], 2), Pseq([0.25], 2), Pseq([0.25, 0.125, 0.125], 1)], 1), 0.125, 0.125, 0.125, 0.125, 0.25, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, Pseq([0.125], 8)], inf),
	\mul, 0.128,
	\dec, Pseq([0.1, 0.2, 0.3, 0.5], inf) * Pwhite(0.45, 0.6, inf),
	\freq, Pseq([60.midicps, 60.025.midicps, 60.05.midicps, ~key[2], ~key[2], ~key[1], 62.5.midicps, 62.75.midicps, 65.125.midicps, Prand(~key, 1), ~key[2], ~key[4], ~key[4], ~key[5], 69.125.midicps, 69.25.midicps, 69.5.midicps, 70.midicps, ~key[6], ~key[1], ~key[4]], inf) * 0.25,
	\amp, 1,
	\pan, Pwhite(-0.1, 0.1, inf),
	\out, ~synthBus

)));

(Pdef(\kick, Pbind(
	\instrument, \kick,
	\dur, Pseq([Pseq([0.5], 4), 0.5, 0.25, 0.125, 0.125], inf),
	\amp, 1,
	\mul, 0.35,
	\dec, 0.24,
	\atk, 0.000001
)));

(Pdef(\hat, Pbind(
	\instrument, Pseq([Prand([\rest, \rest, \rest, \rest, \rest, Curt.hat1, Curt.hat2, \rest, \rest, \rest], 1), Curt.hat1], inf),
	\dec, 0.04,
	\atk, 0.0001,
	\dur, Pseq([Pseq([0.25], 6), 0.125, 0.125, 0.25], inf),
	\amp, 1,
	\mul, 0.8,
	\freq, 2000,
	\nmul, 2,
	\in, 6000

)));

(Pdef(\snare, Pbind(
	\instrument, Pseq([\rest, Curt.snare1], inf),
	\dur, Pseq([0.5, 0.25, 0.25, 1, 1, 3], inf),
	\amp, 1,
	\mul, 0.9,
	\dec, 0.2,
	\curve, -8,
	\pan, 0.1,
	\nmul, 3,
	\in, 4000,
	\freq, 200
)));
);

Ndef(\synthFX).play;

Pdef(\synth).play;

Pdef(\acid).play;

Pdef(\kick).play;
Pdef(\snare).play;
Pdef(\hat).play;
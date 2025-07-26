s.boot;
(
(SynthDef.new(\string, {
	var env, env2, noise, mod, sig, fil;
	env = EnvGen.kr(Env([0, \amp.kr(1), 0], [\atk.kr(0.007), \dec.kr(1.4)], [-2, -0.3]), doneAction: 2);
	env2 = EnvGen.kr(Env([0, 1, 0], [0.004, 1]));
	noise = WhiteNoise.ar(0.2) * env2;
	noise = HPF.ar(noise, 700) * 0.03;
	mod = SinOsc.ar(\freq.kr(440) * 2.78, 0, \mmul.kr(1));
	sig = Generate.ar(0.4, 1, 0.5, 0.7, 0.3, 0, -0.5, -0.4, -0.7, -0.3, \freq.kr + (mod * 12) + (noise * 20))  * \mul.kr(1);
	sig = [sig * 0.9, SinOsc.ar(\freq.kr * [0.5, 2] + (mod * 24), 0, \mul.kr).sum * 0.05, mod * 0.0075].sum;
	sig = sig.blend(noise, 0.5);
	sig = sig * env;
	sig = LPF.ar(sig, 1800 + (env * 200));
	sig = HPF.ar(sig, 400);
	fil = BPF.ar(sig, 879, 0.4);
	sig = sig.blend(fil, 0.2);
	sig = Select.ar(\sel.kr(0), [[sig * 0.5, DelayN.ar(sig, 0.0025, 0.0025) * 0.5], [DelayN.ar(sig, 0.0025, 0.0025) * 0.5, sig * 0.5]]);
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\drum, {
	var env, noise, mod, sig, fil;
	env = EnvGen.kr(Env([0, \amp.kr(1), 0], [\atk.kr(0.0001), \dec.kr(0.05)], [-2, -0.3]), doneAction: 2);
	noise = PinkNoise.ar(\nmul.kr(1));
	noise = LPF.ar(noise, 2200);
	noise = HPF.ar(noise, 1000);
	mod = SinOsc.ar(\freq.kr(440) + (env * 20) + (noise * 550) * 2.78, 0, \mmul.kr(1));
	sig = Generate.ar(0.4, 1, 0.5, 0.7, 0.3, 0, -0.5, -0.4, -0.7, -0.3, \freq.kr + (noise * 400)+ (mod * 12) + (env * 20)) * \mul.kr(1);
	sig = [sig * 0.9, SinOsc.ar(\freq.kr * [0.5, 2] + (mod * 24) + (env * 20) + (noise * 350), 0, \mul.kr).sum * 0.05, mod * 0.0075].sum;
	sig = sig.blend(noise, 0.4);
	sig = sig * env;
	sig = LPF.ar(sig, 3500 + (env * 700 + (noise * 500)));
	sig = HPF.ar(sig, 200 + (noise * 50));
	fil = BPF.ar(sig, 879 + (noise * 300), 0.4);
	sig = [sig * 0.8, fil * 0.3].sum;
	sig = [DelayN.ar(sig, 0.0025, 0.0025) * 0.5, sig * 0.5];
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\drum2, {
	var env, noise, mod, sig, fil;
	env = EnvGen.kr(Env([0, \amp.kr(1), 0], [\atk.kr(0.0001), \dec.kr(0.05)], [-2, -0.3]), doneAction: 2);
	noise = PinkNoise.ar(\nmul.kr(1));
	noise = LPF.ar(noise, 2200);
	noise = HPF.ar(noise, 1000);
	mod = SinOsc.ar(\freq.kr(440) + (env * 20) + (noise * 550) * 2.78, 0, \mmul.kr(1));
	sig = Generate.ar(0.4, 1, 0.5, 0.7, 0.3, 0, -0.5, -0.4, -0.7, -0.3, \freq.kr + (noise * 400)+ (mod * 12) + (env * 20)) * \mul.kr(1);
	sig = [sig * 0.9, SinOsc.ar(\freq.kr * [0.5, 2] + (mod * 24) + (env * 20) + (noise * 350), 0, \mul.kr).sum * 0.05, mod * 0.0075].sum;
	sig = sig.blend(noise, 0.4);
	sig = sig * env;
	sig = LPF.ar(sig, 3500 + (env * 700 + (noise * 500)));
	sig = HPF.ar(sig, 200 + (noise * 50));
	fil = BPF.ar(sig, 879 + (noise * 300), 0.4);
	sig = [sig * 0.8, fil * 0.3].sum;
	sig = [ sig * 0.5,DelayN.ar(sig, 0.0025, 0.0025) * 0.5];
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\pad, {
	var env, env2, noise, mod, sig, fil;
	env = EnvGen.kr(Env([0, \amp.kr(1), 0], [\atk.kr(2), \dec.kr(4)], [-2, -0.3]), doneAction: 2);
	mod = SinOsc.ar(\freq.kr(440) * 2.78, 0, \mmul.kr(1));
	sig = Generate.ar(0.4, 1, 0.5, 0.7, 0.3, 0, -0.5, -0.4, -0.7, -0.3, \freq.kr + (mod * 12))  * \mul.kr(1);
	sig = [sig * 0.9, SinOsc.ar(\freq.kr * [0.5, 2] + (mod * 24), 0, \mul.kr).sum * 0.05, mod * 0.0075].sum;
	sig = sig * env;
	sig = LPF.ar(sig, 1000);
	sig = HPF.ar(sig, 1000);
	fil = BPF.ar(sig, 879, 0.4);
	sig = sig.blend(fil, 0.2);
	sig = Pan2.ar(sig, SinOsc.ar(1.65, 0, 0.35));
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(\out.kr(0), sig);
}).add;
);

(~strings = Pbind(
	\instrument, \string,
	\dur, Prand([4, 8, 16, Pseq([0.25, 0.125, 0.125, 0.25, 0.125, 0.125, 0.5], 1), Pseq([Prand([Pseq([0.25, 0.25], 1), 0.5, Pseq([0.125, 0.125, 0.125, 0.125], 1), Pseq([0.125, 0.125, 0.25], 1) ], 1), 0.25, 0.25, 0.5, Prand([Pseq([0.25, 0.25], 1), 0.5, Pseq([0.125, 0.125, 0.125, 0.125], 1), Pseq([0.125, 0.125, 0.25], 1)], 1), Prand([Pseq([1, 1], 1), 2, Pseq([0.5, 0.5], 2)], 1)] * 2, 2), Pseq([Prand([Pseq([0.25, 0.25], 1), 0.5, Pseq([0.125, 0.125, 0.125, 0.125], 1), Pseq([0.125, 0.125, 0.25], 1) ], 1), 0.25, 0.25, 0.5, Prand([Pseq([0.25, 0.25], 1), 0.5, Pseq([0.125, 0.125, 0.125, 0.125], 1), Pseq([0.125, 0.125, 0.25], 1)], 1), Prand([Pseq([1, 1], 1), 2, Pseq([0.5, 0.5], 2)], 1)] * 2, 2), 16, 16, 8], inf),
	\freq, Pseq([500, 500, 500, 500, 500, [500, 300], 500, [250, 333, 500], 250, 300, 325, [260, 265, 255], 1000, 750, 760, 770, 780], inf) * Pseq([1, 1, 1, Prand([0.5, 1, 2, 2, 2, 4, 1, 1, 1, 0.5], 5)], inf),
	\amp, 1,
	\dec, 1.4,
	\sel, Prand([0, 1], inf),
	\mul, 0.2,
));

(~drums = Pbind(
	\instrument, \drum,
	\dur, Prand([16, 2, 1, Pseq([0.5, 0.5], 1), Pseq([0.25, 0.25], 2), Pseq([0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 0.5, Prand([Pseq([0.25, 0.25], 1), 0.5, Pseq([0.125, 0.125, 0.125, 0.125], 1), Pseq([0.25, 0.125, 0.125], 1)], 1), 0.25, 0.25, 0.5, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125], 1)], inf),
	\dec, Pwhite(0.03, 0.0675, inf),
	\freq, Pseq([Prand([[100, 200], [400, 500], [1000, 1100], [3000, 3100], [400, 800], 2000], 1), 500, 250, 300, 325, 260, 750, 760, 770, 780], inf) * Prand([0.25, 0.5, 1, 2, 4, 8, 0.125], inf),
	\amp, 1,
	\mul, 0.215,
));

(~drums2 = Pbind(
	\instrument, \drum2,
	\dur, Prand([4, 2, Pseq([0.5, 0.5, 1, 0.5, 0.25, 0.25, 1], 4)],  inf),
	\dec, Pwhite(0.03, 0.0675, inf),
	\freq, Pseq([50, 30, 20, 10, 5], inf),
	\amp, 1,
	\mul, 0.215,
));

(~pads = Pbind(
	\instrument, \pad,
	\dur, Prand([4, Pseq([Prand([1, Pseq([0.5, 0.5], 1)], 1), 1, 2] * 4, 2)], inf),
	\freq, Pseq([500, 500, [500, 300], [500, 750], [250, 333, 1500], [250, 800], [300, 325, 1000], [400, 600],[700, 770, 780]], inf) * Pseq([1, 0.5, 1, Prand([0.5, 1, 3, 5, 7, 2, 2, 2, 4, 1, 1, 1, 0.5], 5)], inf),
	\amp, 1,
	\mul, 0.07,
));

(~pads2 = Pbind(
	\instrument, \pad,
	\dur, Prand([8, 16, 4, Pseq([Prand([1, Pseq([0.5, 0.5], 1)], 1), 1, 2] * 4, 2)], inf),
	\freq, Pseq([500, 500, [500, 300], [500, 750], [250, 333, 1500], [250, 800], [300, 325, 1000], [400, 600],[700, 770, 780]], inf) * Pseq([1, 0.5, 1, Prand([0.5, 1, 3, 5, 7, 2, 2, 2, 4, 1, 1, 1, 0.5], 5)], inf) * 2,
	\amp, 1,
	\mul, 0.07,
));

t = TempoClock(52.222/60).permanent_(true);
);
(
~strings.play(t);
~strings.play(t);
~drums.play(t);
~drums.play(t);
~pads.play(t);
~pads2.play(t);
~strings.play(t);
~drums.play(t);
~drums.play(t);
~drums2.play(t);

s.scope;
);
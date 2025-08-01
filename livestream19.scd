

~fmBus = Bus.audio(s, 2);
~mainBus = Bus.audio(s, 2);

~scale = [60, 60 + 0.545454, 60 + (0.545454 * 2), 60 + (0.545454 * 3), 60 + (0.545454 * 4), 60 + (0.545454 * 5), 60 + (0.545454 * 6), 60 + (0.545454 * 7), 60 + (0.545454 * 8), 60 + (0.545454 * 9), 60 + (0.545454 * 10), 60 + (0.545454 * 11), 60 + (0.545454 * 12), 60 + (0.545454 * 13), 60 + (0.545454 * 14), 60 + (0.545454 * 15), 60 + (0.545454 * 16), 60 + (0.545454 * 17), 60 + (0.545454 * 18), 60 + (0.545454 * 19), 60 + (0.545454 * 20), 60 + (0.545454 * 21), 72].midicps;

~key = [60,60 + (0.545454 * 3), 60 + (0.545454 * 4), 60 + (0.545454 * 6), 60 + (0.545454 * 9), 60 + (0.545454 * 12), 60 + (0.545454 * 15), 60 + (0.545454 * 18), 60 + (0.545454 * 22)].midicps;


(SynthDef.new(\main, {
	var in;
	in = In.ar(~mainBus, 2);
	in = Limiter.ar(in, 0.7);
	Out.ar(\out.kr(0), in);
}).add;
);

(SynthDef.new(\add, {
	var env, osc;
	env = EnvGen.kr(Env.perc(0.01, \dec.kr(0.1), \amp.kr(1), -20), doneAction: 2);
	osc = Add.ar( \freq.kr(440) + (In.ar(~fmBus, 2).sum * 190) + (env * 100) + Add.ar(\freq.kr * \r.kr(2.5), 1, 3, 5, 3, 7, mul: \mmul.kr(1)), 1, 0.1, 9, 11, 0.1, 0.5, 1, 0.5, 0.12, 0.4, mul: \mul.kr(0.2));
	osc = osc * env;
	Out.ar(~fmBus, osc!2);
	osc = Add.ar( \freq.kr(440) + (In.ar(~fmBus, 2).sum * 100) + (env * 100) + Add.ar(\freq.kr * \r.kr(2.5), 1, 3, 5, 3, 7, mul: \mmul.kr(1)), 1, 0.1, 9, 11, 0.1, 0.5, 1, 0.5, 0.12, 0.4, mul: \mul.kr(0.2));
	osc = osc.blend(BPF.ar(WhiteNoise.ar, \freq.kr, \q.kr(1)), 0.05);
	osc = osc * env;
	osc = Select.ar(\sel.kr(0), [[osc, DelayN.ar(osc, 0.0025, 0.0025)], [DelayN.ar(osc, 0.0025, 0.0025), osc]]);
	osc = Clip.ar(osc, -0.5, 0.5);
	osc = Limiter.ar(osc, 0.6);
	Out.ar(\out.kr(0), osc);
}).add;
);

(SynthDef.new(\synth, {
	var env, mod, sig;
	env = EnvGen.kr(Env([0, \amp.kr(1), 0], [\atk.kr(0.1), \dec.kr(1)]), doneAction: 2);
	mod = LFSaw.ar(\freq.kr(440) * \r.kr(1.5), 0, \mmul.kr(1));
	sig = LFPulse.ar(\freq.kr + (mod * 20), 0, 0.5, \mul.kr(1)) * env;
	sig = RLPF.ar(sig, \lp.kr(3000), \q.kr(1));
	sig = RHPF.ar(sig, \hp.kr(100), \q.kr);
	sig = Select.ar(\sel.kr(0), [[sig, DelayN.ar(sig, 0.0025, 0.0025)], [DelayN.ar(sig, 0.0025, 0.0025), sig]]);
	sig = Clip.ar(sig, -0.5, 0.5);
	sig = Limiter.ar(sig, 0.6);
	Out.ar(\out.kr(0), sig);
}).add;
);


Synth(\add, [\freq, rrand(100, 2000), \r, [0.125, 0.25, 0.5].choose * 0.05, \amp, 1]);


(~rhythm = Pbind(
	\instrument, \add,
	\dur, Prand([8, 16, Prand([0.25], 16), Prand([0.25], 16), Prand([0.25], 16), Prand([0.25], 16), Prand([0.25], 16), Prand([0.25], 16)], inf),
	\freq, Pseq([80, [2,  3000], 3500, 400, 400, 3500, 2, 2, 1, 1], inf),
	\amp, 1,
	\mul, Pseq([0.2, 0.1, 0.05, 0.05], inf) * 0.8,
	\dec, Pwhite(0.1, 0.25, inf),
	\mmul, Pwhite(0, 50, inf),
	\q, Pwhite(0.001, 1, inf),
	\sel, Pseq([0, 1], inf),
	\r, Prand([0.125, 0.25, 0.5], inf),
	\out, ~mainBus
));

(~rhythm2 = Pbind(
	\instrument, \add,
	\dur, \dur, \dur, Prand([8, 16,  8, Prand([2/6], 6*4), Prand([2/6], 6*4), Prand([2/6], 6*4), Prand([2/6], 6*4), Prand([2/6], 6*4), Prand([2/6], 6*4)], inf),
	\freq, Pseq([[0.25, 30], [2,  3000], 3500, 400, 400, 3500], inf),
	\amp, 1,
	\mul, Pseq([0.2, 0.05, 0.1, 0.1, 0.2, 0.05], inf) * 0.6,
	\dec, Pwhite(0.08, 0.25, inf),
	\mmul, Pwhite(0, 500, inf),
	\q, Pwhite(0.001, 1, inf),
	\sel, Pseq([1, 0], inf),
	\r, Prand([0.125, 0.25, 1.5], inf),
	\out, ~mainBus
));

(~rhythm3 = Pbind(
	\instrument, \add,
	\dur, Prand([8, 16, 8, Prand([2/7], 7*2), Prand([2/7], 7*2), Prand([2/7], 7*2),  Prand([2/7], 7*2), Prand([2/7], 7*2)], inf),
	\freq, Pseq([[2, 3000], [2,  3000], 3500, 400, 400, 3500, 0.25], inf),
	\amp, 1,
	\mul, Pseq([0.05, 0.1, 0.1, 0.13, 0.05], inf) * Pwhite(0.1, 0.7, inf),
	\dec, Pseq([5, 4, 3, 2], inf),
	\mmul, Pwhite(0, 750, inf),
	\q, Pwhite(0.001, 1, inf),
	\sel, Pseq([1, 0], inf),
	\r, Prand([0.125, 0.25, 1.5], inf) * Prand([0.25, 0.5, 1, 2, 4], inf),
	\out, ~mainBus
));

(~notes = Pbind(
	\instrument, \synth,
	\dur, Prand([8, 16, Pseq([0.5, 0.5], 8), Pseq([0.5, 0.5], 16), Pseq([0.5, 0.5], 8)], inf),
	\freq, Prand(~key, inf) * Prand([1, 0.5, 2, 4], inf),
	\amp, 0.3,
	\mul, Pseq([0.1, 0.05, 0.0125, 0.025, 0], inf),
	\r, Prand([0.5, 1, 2, 2.5, 3, 1.5, 3.5, 4, 4.5, 5, 5.5], inf),
	\dec, Prand([1, 2, 3, 0.5], inf) * Pwhite(0.5, 1, inf),
	\mmul, Pwhite(0, 3, inf),
	\lp, Pwhite(500, 2555, inf),
	\hp, Pwhite(55, 555, inf),
	\q, Pwhite(0.4, 1, inf),
	\out, ~mainBus
));

(~notes2 = Pbind(
	\instrument, \synth,
	\dur, Prand([8, 16, Pseq([1/6], 6*4), Pseq([1/6], 6*4), Pseq([1/6], 6*4)], inf),
	\freq, Prand(~key, inf) * Prand([1, 0.5, 2, 4], inf),
	\amp, 0.4,
	\mul, Pseq([0.1, 0.05, 0.025], inf),
	\r, Prand([0.5, 1, 2, 2.5, 3, 1.5, 3.5, 4, 4.5, 5, 5.5], inf),
	\dec, Prand([1, 2, 3, 0.5], inf) * Pwhite(0.5, 1, inf),
	\mmul, Pwhite(0, 3, inf),
	\lp, Pwhite(500, 1555, inf),
	\hp, Pwhite(55, 555, inf),
	\q, Pwhite(0.4, 1, inf),
	\out, ~mainBus
));

t = TempoClock(40.75/60).permanent_(true);

Synth(\main);

~rhythm.play(t);
~rhythm2.play(t);
~rhythm3.play(t);
~notes.play(t);
~notes2.play(t);

s.scope;
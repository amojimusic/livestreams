
~delayBus = Bus.audio(s, 2);

~tonic = 46;

~di = 12/17;
~di2 = 12/19;

~tuning1 = [~tonic, ~tonic + (~di), ~tonic + (~di * 2), ~tonic + (~di * 3), ~tonic + (~di * 4), ~tonic + (~di * 5), ~tonic + (~di * 6), ~tonic + (~di * 7), ~tonic + (~di * 8), ~tonic + (~di * 9), ~tonic + (~di * 10), ~tonic + (~di * 11), ~tonic + (~di * 12), ~tonic + (~di * 13), ~tonic + (~di * 14), ~tonic + (~di * 15), ~tonic + (~di * 16), ~tonic + (~di * 17)].midicps;

~tuning2 = [~tonic, ~tonic + (~di2), ~tonic + (~di2 * 2), ~tonic + (~di2 * 3), ~tonic + (~di2 * 4), ~tonic + (~di2 * 5), ~tonic + (~di2 * 6), ~tonic + (~di2 * 7), ~tonic + (~di2 * 8), ~tonic + (~di2 * 9), ~tonic + (~di2 * 10), ~tonic + (~di2 * 11), ~tonic + (~di2 * 12), ~tonic + (~di2 * 13), ~tonic + (~di2 * 14), ~tonic + (~di2 * 15), ~tonic + (~di2 * 16), ~tonic + (~di2 * 17), ~tonic + (~di2 * 18), ~tonic + (~di2 * 19)].midicps;

~key1 = [~tuning1[0], ~tuning1[3], ~tuning1[6], ~tuning1[8], ~tuning1[11], ~tuning1[14], ~tuning1[17]];

~key2 = [~tuning2[0], ~tuning2[3], ~tuning2[7], ~tuning2[9], ~tuning2[12], ~tuning2[16], ~tuning2[19]];


(SynthDef.new(\synth, {
	var env, mod, sig;
	mod = GeneRand.ar(\freq.kr(440) * \r.kr(1.5), \mmul.kr(1));
	env = Env.perc(\atk.kr(0.01), \dec.kr(0.5), \amp.kr(1), \curve.kr(-3.0)).kr(2);
	sig = Saw.ar(\freq.kr(440) + (mod * 4), \mul.kr(1)) * env;
	sig = sig.blend(Pulse.ar(\freq.kr + (sig * 30) + (mod * 2.5), 0.5, \mul.kr(1)), 0.6);
	sig = sig.blend(SinOsc.ar(\freq.kr + (sig * 30) + (mod * 1.75), (0 + (sig * 0.6)).clip2(1), \mul.kr), 0.7125);
	sig = sig.blend(SinOsc.ar(\freq.kr * 2 + (sig * 30) + (mod * 1.75), (0 + (sig * 0.6)).clip2(1), \mul.kr), 0.0888);
	sig = sig.blend(RandWave.ar(\freq.kr + (mod * LFNoise0.ar(0.1, 30).abs), 2.2, \mul.kr), 0.375);
	sig = sig * env * 1.28;
	sig = RLPF.ar(sig, \lp.kr(2222) + (env * 1500), 0.7);
	sig = Pan2.ar(sig, \pan.kr(0));
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\bass, {
	var env, mod, sig;
	mod = GeneRand.ar(\freq.kr(440) * \r.kr(1.5), \mmul.kr(1));
	env = Env.perc(\atk.kr(0.01), \dec.kr(0.5), \amp.kr(1), \curve.kr(-3.0)).kr(2);
	sig = Saw.ar(\freq.kr(440) + (mod * 4), \mul.kr(1)) * env;
	sig = sig.blend(Pulse.ar(\freq.kr + (sig * 30) + (mod * 2.5), 0.5, \mul.kr(1)), 0.6);
	sig = sig.blend(SinOsc.ar(\freq.kr + (sig * 30) + (mod * 1.75), (0 + (sig * 0.6)).clip2(1), \mul.kr), 0.7125);
	sig = sig.blend(SinOsc.ar(\freq.kr * 2 + (sig * 30) + (mod * 1.75), (0 + (sig * 0.6)).clip2(1), \mul.kr), 0.0888);
	sig = sig.blend(RandWave.ar(\freq.kr + (mod * LFNoise0.ar(0.1, 30).abs), 2.2, \mul.kr), 0.375);
	sig = sig * env * 1.28;
	sig = RLPF.ar(sig, \lp.kr(2222) + (env * 1500), 0.7);
	sig = Select.ar(\sel.kr(0), [[sig * 0.5, DelayN.ar(sig, 0.0025, 0.0025) * 0.5], [DelayN.ar(sig, 0.0025, 0.0025) * 0.5, sig * 0.5]]);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\kick, {
	var env, sig;
	env = Env.perc(\atk.kr(0.001), \dec.kr(0.05), \amp.kr(1), \curve.kr(-2)).kr(2);
	sig = SinOsc.ar(\freq.kr(10) + (env * 200) + WhiteNoise.ar(30), 0, \mul.kr(1));
	sig = sig * env;
	sig = sig.blend(sig.softclip, 0.3) * 1.1;
	sig = sig = Select.ar(\sel.kr(0), [[sig * 0.5, DelayN.ar(sig, 0.0025, 0.0025) * 0.5], [DelayN.ar(sig, 0.0025, 0.0025) * 0.5, sig * 0.5]]);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\snare, {
	var env, sig;
	env = Env.perc(\atk.kr(0.001), \dec.kr(0.05), \amp.kr(1), \curve.kr(-2)).kr(2);
	sig = SinOsc.ar(\freq.kr(1000) + (env * 200) + (LocalIn.ar * 4000), 0, \mul.kr(1));
	sig = sig * env;
	LocalOut.ar(sig);
	sig = sig.blend(sig.softclip, 0.3) * 0.7;
	sig = Pan2.ar(sig, \pan.kr(0));
	Out.ar(\out.kr(0), sig);
}).add;
);

(Ndef(\delay, {
	var in;
	in = In.ar(~delayBus, 2);
	in = in.blend(DelayN.ar(in, 0.5 * 1.05, 0.5 * 1.05), 0.05);
	in = in.blend(DelayN.ar(in, 0.5 * 1.05, 0.5 * 1.05), 0.02);
	in = in.blend(DelayN.ar(in, 0.5 * 1.05, 0.5 * 1.05), 0.01);
	in = FreeVerb.ar(in, 0.13, 0.4, 0.75);
}));



(~track1 = {

	~tr = rrand(0.95, 1.15);

	~tonic = [50, 52.117647058824, 57.764705882353, 59.882352941177, 65.529411764706
 - 12].choose;

	~di = 12/17;
	~di2 = 12/19;

	~tuning1 = [~tonic, ~tonic + (~di), ~tonic + (~di * 2), ~tonic + (~di * 3), ~tonic + (~di * 4), ~tonic + (~di * 5), ~tonic + (~di * 6), ~tonic + (~di * 7), ~tonic + (~di * 8), ~tonic + (~di * 9), ~tonic + (~di * 10), ~tonic + (~di * 11), ~tonic + (~di * 12), ~tonic + (~di * 13), ~tonic + (~di * 14), ~tonic + (~di * 15), ~tonic + (~di * 16), ~tonic + (~di * 17)].midicps;

	~tuning2 = [~tonic, ~tonic + (~di2), ~tonic + (~di2 * 2), ~tonic + (~di2 * 3), ~tonic + (~di2 * 4), ~tonic + (~di2 * 5), ~tonic + (~di2 * 6), ~tonic + (~di2 * 7), ~tonic + (~di2 * 8), ~tonic + (~di2 * 9), ~tonic + (~di2 * 10), ~tonic + (~di2 * 11), ~tonic + (~di2 * 12), ~tonic + (~di2 * 13), ~tonic + (~di2 * 14), ~tonic + (~di2 * 15), ~tonic + (~di2 * 16), ~tonic + (~di2 * 17), ~tonic + (~di2 * 18), ~tonic + (~di2 * 19)].midicps;


	~key1 = [~tuning1[0], ~tuning1[3], ~tuning1[6], ~tuning1[8], ~tuning1[11], ~tuning1[14], ~tuning1[17]];

	~key2 = [~tuning2[0], ~tuning2[3], ~tuning2[7], ~tuning2[9], ~tuning2[12], ~tuning2[16], ~tuning2[19]];

	~arpSeq = Pseq([Prand([~key1[4], ~key2[4]], 1), Prand([~key1[5], ~key2[5]], 1), Prand([~key1[2], ~key2[2]], 1), Prand([~key1[0], ~key2[0]], 1), Prand([~key1[1], ~key2[1]], 1), Prand([~key1[0], ~key2[0]], 1), Prand([~key1[2], ~key2[2]], 1), Prand([~key1[1], ~key2[1]], 1)], 1);

	(Ndef(\delay, {
	var in;
	in = In.ar(~delayBus, 2);
	in = in.blend(DelayN.ar(in, 0.5 * ~tr, 0.5 * ~tr), 0.07);
	in = in.blend(DelayN.ar(in, 0.5 * ~tr, 0.5 * ~tr), 0.05);
	in = in.blend(DelayN.ar(in, 0.5 * ~tr, 0.5 * ~tr), 0.01);
	in = FreeVerb.ar(in, 0.14, 0.45, 0.75);
}));

Pdef(\bass, Pbind(
	\instrument, \bass,
		\sel, Pseq([0, 1], inf),
	\mul, 0.2,
	\amp, 1,
	\atk, 0.05,
	\dec, 0.7,
	\dur, Prand([4, Pseq([0.25, 0.25, Prand([0.5, Pseq([0.25], 2), Pseq([0.125], 4)], 1)], 1), Pseq([0.25, 0.25, Prand([0.5, Pseq([0.25], 2), Pseq([0.125], 4)], 1)], 1), Pseq([0.25, 0.25, Prand([0.5, Pseq([0.25], 2), Pseq([0.125], 4)], 1)], 1), Pseq([0.25, 0.25, Prand([0.5, Pseq([0.25], 2), Pseq([0.125], 4)], 1)], 1)], inf) * ~tr,
	\freq, Pseq([Prand([~key1[0], ~key2[0]], 1), Prand([~key1[1], ~key2[1]], 1), Prand([~key1[0], ~key2[0]], 1), Prand([~key2[1], ~key1[1]], 1), Prand([~key2[2], ~key1[2]], 1)], inf) * Pseq([0.5, 0.5, 0.5, 0.5, 0.5, 1], inf),
	\out, ~delayBus
));

Pdef(\arp, Pbind(
	\instrument, \synth,
	\mul, 0.07,
	\amp, 1,
	\dur, Prand([4, Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16)], inf)  * ~tr,
	\lp, Pwhite(2222, 4444, inf),
	\dec, Pwhite(0.1, 0.25, inf),
	\curve, Pwhite(-10.0, 10.0, inf),
	\freq, Prand([~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, Prand([~key1, ~key2], 16), Prand([Prand(~key1, 1), Prand(~key2, 1)], 16), Prand([Prand(~key1, 1), Prand(~key2, 1)], 16), Prand([Prand(~key1, 1), Prand(~key2, 1)], 16)], inf) * Pseq([2, 4], inf),
	\pan, Pwhite(-0.35, 0.35, inf),
	\out, ~delayBus
));

Pdef(\pads, Pbind(
	\instrument, \synth,
	\mul, 0.1, \amp, 0.5,
		\dur, Prand([4, 8], inf) * ~tr,
		\freq, Prand([[~tuning1.choose, ~tuning1.choose], [~tuning2.choose, ~tuning2.choose], [~tuning1.choose, ~tuning1.choose], [~tuning2.choose, ~tuning2.choose], [~tuning1.choose, [~tuning1, ~tuning2].choose.choose, [~tuning1, ~tuning2].choose.choose]], inf) * Prand([1, 2], inf),
		\dec, Pwhite(2, 4,inf),
		\mmul, Pwhite(0.5, 5.5, inf),
		\pan, Pwhite(-0.2, 0.2, inf),
		\atk, Pwhite(1, 2.5, inf),
		\out, ~delayBus
));

Pdef(\kick, Pbind(
	\instrument, \kick,
	\amp, 1,
		\sel, Pseq([0, 1], inf),
		\freq, Pseq([~key1[0], Prand([~key1[2], ~key2[2]], 1), Prand([~key1[4], ~key2[4]], 1)], inf) * 0.125,
		\dec, 0.0825 * 1.05,
		\dur, 0.5 * ~tr,
	\mul, 0.8
));

Pdef(\snare, Pbind(
	\instrument, Pseq([\rest, \snare], inf),
	\dur, Pseq([0.125, 0.125, 0.25, 0.5], inf) * ~tr,
	\freq, Pseq([1000, 1000, 500], inf),
	\amp, 1,
	\out, ~delayBus
));

Pdef(\and, Pbind(
		\instrument, Pseq([Prand([\snare, \rest, \rest, \rest], 1), \snare], inf),
	\dur, 0.25  * ~tr,
	\freq, Pseq([Prand([~key1[2], ~key2[1]], 2), Prand([~key1[4], ~key2[5]], 2)], inf) * 8,
	\amp, 1,
	\dec, 0.05,
	\mul, 0.4,
	\pan, Pseq([-0.5, Pwhite(-0.5, 0.5, 1), 0.5], inf),
	\out, ~delayBus
));

Ndef(\delay).play;
Pdef(\bass).play;
Pdef(\kick).play;
Pdef(\snare).play;
Pdef(\arp).play;
Pdef(\and).play;
	Pdef(\pads).play;

});

(~track2 = {

	~tr = rrand(0.92, 1.1);



	~tonic = [50, 52.117647058824, 57.764705882353, 59.882352941177, 65.529411764706
 - 12].choose;

	~di = 12/17;
	~di2 = 12/19;

	~tuning1 = [~tonic, ~tonic + (~di), ~tonic + (~di * 2), ~tonic + (~di * 3), ~tonic + (~di * 4), ~tonic + (~di * 5), ~tonic + (~di * 6), ~tonic + (~di * 7), ~tonic + (~di * 8), ~tonic + (~di * 9), ~tonic + (~di * 10), ~tonic + (~di * 11), ~tonic + (~di * 12), ~tonic + (~di * 13), ~tonic + (~di * 14), ~tonic + (~di * 15), ~tonic + (~di * 16), ~tonic + (~di * 17)].midicps;

	~tuning2 = [~tonic, ~tonic + (~di2), ~tonic + (~di2 * 2), ~tonic + (~di2 * 3), ~tonic + (~di2 * 4), ~tonic + (~di2 * 5), ~tonic + (~di2 * 6), ~tonic + (~di2 * 7), ~tonic + (~di2 * 8), ~tonic + (~di2 * 9), ~tonic + (~di2 * 10), ~tonic + (~di2 * 11), ~tonic + (~di2 * 12), ~tonic + (~di2 * 13), ~tonic + (~di2 * 14), ~tonic + (~di2 * 15), ~tonic + (~di2 * 16), ~tonic + (~di2 * 17), ~tonic + (~di2 * 18), ~tonic + (~di2 * 19)].midicps;


	~key1 = [~tuning1[0], ~tuning1[3], ~tuning1[6], ~tuning1[8], ~tuning1[11], ~tuning1[14], ~tuning1[17]];

	~key2 = [~tuning2[0], ~tuning2[3], ~tuning2[7], ~tuning2[9], ~tuning2[12], ~tuning2[16], ~tuning2[19]];

	(Ndef(\delay, {
	var in;
	in = In.ar(~delayBus, 2);
	in = in.blend(DelayN.ar(in, 0.5 * ~tr, 0.5 * ~tr), 0.07);
	in = in.blend(DelayN.ar(in, 0.5 * ~tr, 0.5 * ~tr), 0.05);
	in = in.blend(DelayN.ar(in, 0.5 * ~tr, 0.5 * ~tr), 0.01);
	in = FreeVerb.ar(in, 0.14, 0.45, 0.75);
}));

	Pdef(\kick, Pbind(
		\instrument, \kick,
		\amp, 1,
		\freq, 10,
		\sel, Pseq([0, 1], inf),
		\mul, 0.8,
		\dur, Pseq([Prand([1, Pseq([0.5], 2), Pseq([0.25, 0.25, 0.5], 1)], 1), Prand([1, Pseq([0.75, 0.25], 1)], 1)], inf),
		\out, ~delayBus
	));

	Pdef(\snare, Pbind(
		\instrument, Pseq([\rest, \rest, \snare], inf),
		\dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5], inf),
		\amp, 1,
		\mul, 0.6,
		\dec, Pwhite(0.04, 0.2, inf),
		\out, ~delayBus
	));

	Pdef(\arp, Pbind(
		\instrument, \synth,
		\amp, 0.7,
		\dur, [0.5, 0.25, 0.125].choose,
		\mul, 0.3,
		\freq, Prand([Prand(~tuning1, 1), Prand(~tuning2, 1)], inf),
		\out, ~delayBus,
	));

	Pdef(\and, Pbind(
		\instrument, Pseq([Prand([\snare, \rest, \rest, \rest], 1), \snare], inf),
	\dur, 0.5  * ~tr,
	\freq, Pseq([Prand([~key1[2], ~key2[1]], 2), Prand([~key1[4], ~key2[5]], 2)], inf) * 8,
	\amp, 1,
	\dec, 0.05,
	\mul, 0.4,
	\pan, Pseq([-0.5, Pwhite(1.0, 1.0, 1), 0.5], inf),
	\out, ~delayBus
));

	Pdef(\bass, Pbind(
		\instrument, \bass,
		\amp, 0.7,
		\sel, Pseq([0, 1], inf),
		\dur, [1, 0.5, 0.25].choose,
		\mul, 0.5,
		\freq, Prand([Prand(~tuning1, 1), Prand(~tuning2, 1)], inf) * 0.5,
		\out, 0
	));

	Pdef(\pads, Pbind(
	\instrument, \synth,
	\mul, 0.1, \amp, 0.5,
		\dur, Prand([4, 8], inf) * ~tr,
		\freq, Prand([[~tuning1.choose, ~tuning1.choose], [~tuning2.choose, ~tuning2.choose], [~tuning1.choose, ~tuning1.choose], [~tuning2.choose, ~tuning2.choose], [~tuning1.choose, [~tuning1, ~tuning2].choose.choose, [~tuning1, ~tuning2].choose.choose]], inf) * Prand([1, 2], inf),
		\dec, Pwhite(2, 4,inf),
		\mmul, Pwhite(0.5, 5.5, inf),
		\pan, Pwhite(-0.2, 0.2, inf),
		\atk, Pwhite(1, 2.5, inf),
		\out, ~delayBus
));




	Ndef(\delay).play;
	Pdef(\kick).play;
	Pdef(\snare).play;
	Pdef(\and).play;
	Pdef(\arp).play;
	Pdef(\bass).play;
	Pdef(\pads).play;

});

(~track3 = {

	~tr = rrand(0.9, 1.3);



	~tonic = [50, 52.117647058824, 57.764705882353, 59.882352941177, 65.529411764706
 - 12].choose;

	~di = 12/17;
	~di2 = 12/19;

	~tuning1 = [~tonic, ~tonic + (~di), ~tonic + (~di * 2), ~tonic + (~di * 3), ~tonic + (~di * 4), ~tonic + (~di * 5), ~tonic + (~di * 6), ~tonic + (~di * 7), ~tonic + (~di * 8), ~tonic + (~di * 9), ~tonic + (~di * 10), ~tonic + (~di * 11), ~tonic + (~di * 12), ~tonic + (~di * 13), ~tonic + (~di * 14), ~tonic + (~di * 15), ~tonic + (~di * 16), ~tonic + (~di * 17)].midicps;

	~tuning2 = [~tonic, ~tonic + (~di2), ~tonic + (~di2 * 2), ~tonic + (~di2 * 3), ~tonic + (~di2 * 4), ~tonic + (~di2 * 5), ~tonic + (~di2 * 6), ~tonic + (~di2 * 7), ~tonic + (~di2 * 8), ~tonic + (~di2 * 9), ~tonic + (~di2 * 10), ~tonic + (~di2 * 11), ~tonic + (~di2 * 12), ~tonic + (~di2 * 13), ~tonic + (~di2 * 14), ~tonic + (~di2 * 15), ~tonic + (~di2 * 16), ~tonic + (~di2 * 17), ~tonic + (~di2 * 18), ~tonic + (~di2 * 19)].midicps;


	~key1 = [~tuning1[0], ~tuning1[3], ~tuning1[6], ~tuning1[8], ~tuning1[11], ~tuning1[14], ~tuning1[17]];

	~key2 = [~tuning2[0], ~tuning2[3], ~tuning2[7], ~tuning2[9], ~tuning2[12], ~tuning2[16], ~tuning2[19]];

	(Ndef(\delay, {
	var in;
	in = In.ar(~delayBus, 2);
	in = in.blend(DelayN.ar(in, 1 * ~tr, 1 * ~tr), 0.07);
	in = in.blend(DelayN.ar(in, 1 * ~tr, 1 * ~tr), 0.05);
	in = in.blend(DelayN.ar(in, 1 * ~tr, 1 * ~tr), 0.01);
	in = FreeVerb.ar(in, 0.14, 0.45, 0.75);
}));

	Pdef(\kick, Pbind(
		\instrument, \kick,
		\amp, 1,
		\sel, Pseq([0, 1], inf),
		\freq, 13.4,
		\mul, 0.8,
		\dur, Prand([1, Pseq([0.5], 2), Pseq([0.25], 4), Pseq([0.5, 0.25, 0.25], 1), Pseq([0.25, 0.25, 0.5], 1), Pseq([0.125], 8)], inf),
		\out, ~delayBus
	));

	Pdef(\snare, Pbind(
		\instrument, Pseq([\rest, \rest, \snare], inf),
		\dur, Pseq([0.5, 0.25, 0.25, Prand([Pseq([0.25], 2), Pseq([0.125], 4)], 1), Prand([0.5, Pseq([0.25], 2)], 1)], inf) * Prand([Pseq([0.25], 8), Pseq([0.5], 4)], inf),
		\amp, 1,
		\mul, 0.6,
		\dec, Pwhite(0.04, 0.2, inf),
		\out, ~delayBus
	));

	Pdef(\arp, Pbind(
		\instrument, \synth,
		\amp, 0.7,
		\dur, [0.5, 0.25, 1].choose,
		\mul, 0.3,
		\freq, Prand([Prand(~tuning1, 1), Prand(~tuning2, 1)], inf),
		\out, ~delayBus,
	));

	Pdef(\and, Pbind(
		\instrument, Pseq([Prand([\snare, \rest, \rest, \rest], 1), \snare], inf),
	\dur, 0.5  * ~tr,
	\freq, Pseq([Prand([~key1[2], ~key2[1]], 2), Prand([~key1[4], ~key2[5]], 2)], inf) * 8,
	\amp, 1,
	\dec, 0.05,
	\mul, 0.4,
	\pan, Pseq([-0.5, Pwhite(1.0, 1.0, 1), 0.5], inf),
	\out, ~delayBus
));

	Pdef(\bass, Pbind(
		\instrument, \bass,
		\amp, 0.7,
		\sel, Pseq([0, 1], inf),
		\dur, [2, 1, 0.5, 0.25].choose,
		\mul, 0.5,
		\freq, Prand([Prand(~tuning1, 1), Prand(~tuning2, 1)], inf) * 0.5,
		\out, 0
	));

	Pdef(\pads, Pbind(
	\instrument, \synth,
	\mul, 0.1, \amp, 0.5,
		\dur, Prand([4, 8], inf) * ~tr,
		\freq, Prand([[~tuning1.choose, ~tuning1.choose], [~tuning2.choose, ~tuning2.choose], [~tuning1.choose, ~tuning1.choose], [~tuning2.choose, ~tuning2.choose], [~tuning1.choose, [~tuning1, ~tuning2].choose.choose, [~tuning1, ~tuning2].choose.choose]], inf) * Prand([1, 2], inf),
		\dec, Pwhite(2, 4,inf),
		\mmul, Pwhite(0.5, 5.5, inf),
		\pan, Pwhite(-0.2, 0.2, inf),
		\atk, Pwhite(1, 2.5, inf),
		\out, ~delayBus
));




	Ndef(\delay).play;
	Pdef(\kick).play;
	Pdef(\snare).play;
	Pdef(\and).play;
	Pdef(\arp).play;
	Pdef(\bass).play;
	Pdef(\pads).play;

});

(~track4 = {

	~tr = rrand(0.75, 1.15);

	~tonic = [50, 52.117647058824, 57.764705882353, 59.882352941177, 65.529411764706
 - 12].choose;

	~di = 12/17;
	~di2 = 12/19;

	~tuning1 = [~tonic, ~tonic + (~di), ~tonic + (~di * 2), ~tonic + (~di * 3), ~tonic + (~di * 4), ~tonic + (~di * 5), ~tonic + (~di * 6), ~tonic + (~di * 7), ~tonic + (~di * 8), ~tonic + (~di * 9), ~tonic + (~di * 10), ~tonic + (~di * 11), ~tonic + (~di * 12), ~tonic + (~di * 13), ~tonic + (~di * 14), ~tonic + (~di * 15), ~tonic + (~di * 16), ~tonic + (~di * 17)].midicps;

	~tuning2 = [~tonic, ~tonic + (~di2), ~tonic + (~di2 * 2), ~tonic + (~di2 * 3), ~tonic + (~di2 * 4), ~tonic + (~di2 * 5), ~tonic + (~di2 * 6), ~tonic + (~di2 * 7), ~tonic + (~di2 * 8), ~tonic + (~di2 * 9), ~tonic + (~di2 * 10), ~tonic + (~di2 * 11), ~tonic + (~di2 * 12), ~tonic + (~di2 * 13), ~tonic + (~di2 * 14), ~tonic + (~di2 * 15), ~tonic + (~di2 * 16), ~tonic + (~di2 * 17), ~tonic + (~di2 * 18), ~tonic + (~di2 * 19)].midicps;


	~key1 = [~tuning1[0], ~tuning1[3], ~tuning1[6], ~tuning1[8], ~tuning1[11], ~tuning1[14], ~tuning1[17]];

	~key2 = [~tuning2[0], ~tuning2[3], ~tuning2[7], ~tuning2[9], ~tuning2[12], ~tuning2[16], ~tuning2[19]];

	~arpSeq = Pseq([Prand([~key1[4], ~key2[4]], 1), Prand([~key1[5], ~key2[5]], 1), Prand([~key1[2], ~key2[2]], 1), Prand([~key1[0], ~key2[0]], 1), Prand([~key1[1], ~key2[1]], 1), Prand([~key1[0], ~key2[0]], 1), Prand([~key1[2], ~key2[2]], 1), Prand([~key1[1], ~key2[1]], 1)], 1);

	(Ndef(\delay, {
	var in;
	in = In.ar(~delayBus, 2);
	in = in.blend(DelayN.ar(in, 0.5 * ~tr, 0.5 * ~tr), 0.07);
	in = in.blend(DelayN.ar(in, 0.5 * ~tr, 0.5 * ~tr), 0.05);
	in = in.blend(DelayN.ar(in, 0.5 * ~tr, 0.5 * ~tr), 0.01);
	in = FreeVerb.ar(in, 0.14, 0.45, 0.75);
}));

Pdef(\bass, Pbind(
	\instrument, \bass,
	\mul, 0.2,
	\amp, 1,
		\sel, Pseq([0, 1], inf),
	\atk, 0.000000001,
	\dec, 0.08,
	\dur, Prand([4, Pseq([0.25, 0.25, Prand([0.5, Pseq([0.25], 2), Pseq([0.125], 4)], 1)], 1), Pseq([0.25, 0.25, Prand([0.5, Pseq([0.25], 2), Pseq([0.125], 4)], 1)], 1), Pseq([0.25, 0.25, Prand([0.5, Pseq([0.25], 2), Pseq([0.125], 4)], 1)], 1), Pseq([0.25, 0.25, Prand([0.5, Pseq([0.25], 2), Pseq([0.125], 4)], 1)], 1)], inf) * ~tr * 0.25,
	\freq, Pseq([Prand([~key1[0], ~key2[0]], 1), Prand([~key1[1], ~key2[1]], 1), Prand([~key1[0], ~key2[0]], 1), Prand([~key2[1], ~key1[1]], 1), Prand([~key2[2], ~key1[2]], 1)], inf) * Pseq([0.5, 0.5, 0.5, 0.5, 0.5, 1], inf),
	\out, ~delayBus
));

Pdef(\arp, Pbind(
	\instrument, \synth,
	\mul, 0.07,
	\amp, 1,
		\dur, Prand([4, Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16)], inf)  * ~tr * [0.5, 1].choose,
	\lp, Pwhite(2222, 4444, inf),
	\dec, Pwhite(0.04, 0.08, inf),
		\atk, 0.00001,
	\curve, Pwhite(-10.0, 10.0, inf),
	\freq, Prand([~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, Prand([~key1, ~key2], 16), Prand([Prand(~key1, 1), Prand(~key2, 1)], 16), Prand([Prand(~key1, 1), Prand(~key2, 1)], 16), Prand([Prand(~key1, 1), Prand(~key2, 1)], 16)], inf) * Pseq([2, 4], inf),
	\pan, Pwhite(-0.35, 0.35, inf),
	\out, ~delayBus
));

Pdef(\pads, Pbind(
	\instrument, \synth,
	\mul, 0.05, \amp, 0.5,
		\dur, Prand([4, 8], inf) * ~tr,
		\freq, Prand([[~tuning1.choose, ~tuning1.choose], [~tuning2.choose, ~tuning2.choose], [~tuning1.choose, ~tuning1.choose], [~tuning2.choose, ~tuning2.choose], [~tuning1.choose, [~tuning1, ~tuning2].choose.choose, [~tuning1, ~tuning2].choose.choose]], inf) * Prand([1, 2], inf),
		\dec, Pwhite(0.5, 1,inf),
		\mmul, Pwhite(0.5, 5.5, inf),
		\pan, Pwhite(-0.2, 0.2, inf),
		\atk, Pwhite(0.001, 2.5, inf),
		\out, ~delayBus
));

	Pdef(\kick, Pbind(
		\instrument, \kick,
		\amp, 1.3,
		\freq, 13.4,
		\sel, Pseq([0, 1], inf),
		\mul, 0.1,
		\dec, 0.7,
		\curve, -8,
		\dur, Prand([1, Pseq([0.5], 2), Pseq([0.25], 4), Pseq([0.5, 0.25, 0.25], 1), Pseq([0.25, 0.25, 0.5], 1), Pseq([0.125], 8)], inf),
	));



Pdef(\snare, Pbind(
	\instrument, Pseq([\rest, \snare], inf),
		\dur, Pseq([0.125, 0.125, 0.25, 0.5], inf) * ~tr * [0.5, 1].choose,
	\freq, Pseq([1000, 1000, 500], inf),
	\amp, 0.7,
	\out, ~delayBus
));

Pdef(\and, Pbind(
		\instrument, Pseq([Prand([\snare, \rest, \rest, \rest], 1), \snare], inf),
	\dur, 0.25  * ~tr,
	\freq, Pseq([Prand([~key1[2], ~key2[1]], 2), Prand([~key1[4], ~key2[5]], 2)], inf) * 8,
	\amp, 0.7,
	\dec, 0.05,
	\mul, 0.4,
	\pan, Pseq([-0.5, Pwhite(-0.5, 0.5, 1), 0.5], inf),
	\out, ~delayBus
));

Ndef(\delay).play;
Pdef(\bass).play;
Pdef(\kick).play;
Pdef(\snare).play;
Pdef(\arp).play;
Pdef(\and).play;
	Pdef(\pads).play;

});


(~track5 = {

	~tr = rrand(0.95, 1.15);

	~tonic = [50, 52.117647058824, 57.764705882353, 59.882352941177, 65.529411764706
 - 12].choose;

	~di = 12/17;
	~di2 = 12/19;

	~tuning1 = [~tonic, ~tonic + (~di), ~tonic + (~di * 2), ~tonic + (~di * 3), ~tonic + (~di * 4), ~tonic + (~di * 5), ~tonic + (~di * 6), ~tonic + (~di * 7), ~tonic + (~di * 8), ~tonic + (~di * 9), ~tonic + (~di * 10), ~tonic + (~di * 11), ~tonic + (~di * 12), ~tonic + (~di * 13), ~tonic + (~di * 14), ~tonic + (~di * 15), ~tonic + (~di * 16), ~tonic + (~di * 17)].midicps;

	~tuning2 = [~tonic, ~tonic + (~di2), ~tonic + (~di2 * 2), ~tonic + (~di2 * 3), ~tonic + (~di2 * 4), ~tonic + (~di2 * 5), ~tonic + (~di2 * 6), ~tonic + (~di2 * 7), ~tonic + (~di2 * 8), ~tonic + (~di2 * 9), ~tonic + (~di2 * 10), ~tonic + (~di2 * 11), ~tonic + (~di2 * 12), ~tonic + (~di2 * 13), ~tonic + (~di2 * 14), ~tonic + (~di2 * 15), ~tonic + (~di2 * 16), ~tonic + (~di2 * 17), ~tonic + (~di2 * 18), ~tonic + (~di2 * 19)].midicps;


	~key1 = [~tuning1[0], ~tuning1[3], ~tuning1[6], ~tuning1[8], ~tuning1[11], ~tuning1[14], ~tuning1[17]];

	~key2 = [~tuning2[0], ~tuning2[3], ~tuning2[7], ~tuning2[9], ~tuning2[12], ~tuning2[16], ~tuning2[19]];

	~arpSeq = Pseq([Prand([~key1[4], ~key2[4]], 1), Prand([~key1[5], ~key2[5]], 1), Prand([~key1[2], ~key2[2]], 1), Prand([~key1[0], ~key2[0]], 1), Prand([~key1[1], ~key2[1]], 1), Prand([~key1[0], ~key2[0]], 1), Prand([~key1[2], ~key2[2]], 1), Prand([~key1[1], ~key2[1]], 1)], 1);

	(Ndef(\delay, {
	var in;
	in = In.ar(~delayBus, 2);
	in = in.blend(DelayN.ar(in, 0.5 * ~tr, 0.5 * ~tr), 0.07);
	in = in.blend(DelayN.ar(in, 0.5 * ~tr, 0.5 * ~tr), 0.05);
	in = in.blend(DelayN.ar(in, 0.5 * ~tr, 0.5 * ~tr), 0.01);
	in = FreeVerb.ar(in, 0.14, 0.45, 0.75);
}));

Pdef(\bass, Pbind(
	\instrument, \bass,
	\mul, 0.2,
		\sel, Pseq([0, 1], inf),
	\amp, 1,
	\atk, 0.000000001,
	\dec, 0.08,
	\dur, Prand([4, Pseq([0.25, 0.25, Prand([0.5, Pseq([0.25], 2), Pseq([0.125], 4)], 1)], 1), Pseq([0.25, 0.25, Prand([0.5, Pseq([0.25], 2), Pseq([0.125], 4)], 1)], 1), Pseq([0.25, 0.25, Prand([0.5, Pseq([0.25], 2), Pseq([0.125], 4)], 1)], 1), Pseq([0.25, 0.25, Prand([0.5, Pseq([0.25], 2), Pseq([0.125], 4)], 1)], 1)], inf) * ~tr * 0.25,
	\freq, Pseq([Prand([~key1[0], ~key2[0]], 1), Prand([~key1[1], ~key2[1]], 1), Prand([~key1[0], ~key2[0]], 1), Prand([~key2[1], ~key1[1]], 1), Prand([~key2[2], ~key1[2]], 1)], inf) * Pseq([0.5, 0.5, 0.5, 0.5, 0.5, 1], inf),
	\out, ~delayBus
));

Pdef(\arp, Pbind(
	\instrument, \synth,
	\mul, 0.07,
	\amp, 1,
		\dur, Prand([4, Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16), Pseq([0.125], 16)], inf)  * ~tr * [0.25, 0.125, 0.5].choose,
	\lp, Pwhite(2222, 4444, inf),
	\dec, Pwhite(0.04, 0.08, inf),
		\atk, 0.00001,
	\curve, Pwhite(-10.0, 10.0, inf),
	\freq, Prand([~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, ~arpSeq, Prand([~key1, ~key2], 16), Prand([Prand(~key1, 1), Prand(~key2, 1)], 16), Prand([Prand(~key1, 1), Prand(~key2, 1)], 16), Prand([Prand(~key1, 1), Prand(~key2, 1)], 16)], inf) * Pseq([2, 4], inf),
	\pan, Pwhite(-0.35, 0.35, inf),
	\out, ~delayBus
));

Pdef(\pads, Pbind(
	\instrument, \synth,
	\mul, 0.05, \amp, 0.5,
		\dur, Prand([4, 8], inf) * ~tr,
		\freq, Prand([[~tuning1.choose, ~tuning1.choose], [~tuning2.choose, ~tuning2.choose], [~tuning1.choose, ~tuning1.choose], [~tuning2.choose, ~tuning2.choose], [~tuning1.choose, [~tuning1, ~tuning2].choose.choose, [~tuning1, ~tuning2].choose.choose]], inf) * Prand([1, 2], inf),
		\dec, Pwhite(0.5, 1,inf),
		\mmul, Pwhite(0.5, 5.5, inf),
		\pan, Pwhite(-0.2, 0.2, inf),
		\atk, Pwhite(0.001, 2.5, inf),
		\out, ~delayBus
));

	Pdef(\kick, Pbind(
		\instrument, \kick,
		\amp, 1.3,
		\freq, 13.4,
		\mul, 0.1,
		\dec, 0.7,
		\curve, -8,
		\dur, Prand([1, Pseq([0.5], 2), Pseq([0.25], 4), Pseq([0.5, 0.25, 0.25], 1), Pseq([0.25, 0.25, 0.5], 1), Pseq([0.125], 8)], inf),
	));



Pdef(\snare, Pbind(
	\instrument, Pseq([\rest, \snare], inf),
		\dur, Pseq([0.125, 0.125, 0.25, 0.5], inf) * ~tr * [0.5, 1].choose,
	\freq, Pseq([1000, 1000, 500], inf),
	\amp, 0.7,
	\out, ~delayBus
));

Pdef(\and, Pbind(
		\instrument, Pseq([Prand([\snare, \rest, \rest, \rest], 1), \snare], inf),
	\dur, 0.25  * ~tr,
	\freq, Pseq([Prand([~key1[2], ~key2[1]], 2), Prand([~key1[4], ~key2[5]], 2)], inf) * 8,
	\amp, 0.7,
	\dec, 0.05,
	\mul, 0.4,
	\pan, Pseq([-0.5, Pwhite(-0.5, 0.5, 1), 0.5], inf),
	\out, ~delayBus
));

Ndef(\delay).play;
Pdef(\bass).play;
Pdef(\kick).stop;
Pdef(\snare).stop;
Pdef(\arp).play;
Pdef(\and).stop;
	Pdef(\pads).play;

});
k

(Tdef(\track, {loop{

	if(~tr.isNil){
		~tr = 1;
	};
	~track = [~track1, ~track1, ~track2, ~track3, ~track4, ~track5].choose;
	~track.();
	wait([16, 32, 64, 128, 16, 32, 64, 16, 32, 64, 16, 32, 64, 128, 256, 16, 32, 16, 32, 32, 32, 32, 32].choose * ~tr);



}}));

Tdef(\track).play;


~track5.();
~track1.();
~track2.();
~track3.();
~track4.();

s.scope;










































































































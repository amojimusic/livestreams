// add animation

~reverbBus = Bus.audio(s, 2);
~reverb2Bus = Bus.audio(s, 2);

(Ndef(\reverb, {
	FreeVerb.ar(In.ar(~reverbBus, 2), \mix.kr(0.5), \room.kr(0.5), \damp.kr(0.5));
}));

(Ndef(\reverb2, {
	FreeVerb.ar(FreeVerb.ar(In.ar(~reverb2Bus, 2), \mix.kr(0.5), \room.kr(0.5), \damp.kr(0.5)), \mix.kr, \room.kr, \damp.kr);
}));

(SynthDef.new(\synth1, {
	var env, env2, env3, mod, mod2, sig;
	env = Env.perc(\atk.kr(0.01), \dec.kr(1), \amp.kr(1)).kr(2);
	env2 = Env.perc(\atk2.kr(0.01), \dec2.kr(1), \amp2.kr(1)).kr;
	env3 = Env.perc(\atk3.kr(0.01), \dec3.kr(1), \amp3.kr(1)).kr;
	mod = Generate.ar(0.05, 0.5, -0.6, -0.8, 1, 0, 0, 0, 0, 0, \freq.kr(440) * \r1.kr(1.5)) * \mod1mul.kr(1) * env2;
	mod2 = Generate.ar(0.1, 0.5, 0, 0, -1, -0.45, 0, 0.25, 0.9, 0.35, \freq.kr(440) * \r2.kr(1.5) + (mod * 40)) * \mod2mul.kr(1) * env3;
	mod2 = FreeVerb.ar(mod2, 1, 1, 0.5) * 2;

	sig = Select.ar(\sel.kr(0), [Generate.ar(1, 0.3, -0.8, -0.8, 0.3, 0, 0, 0, 0, 0, \freq.kr(440) + (mod * 10) + (mod2 * 10)) * \mul.kr(1), SinOsc.ar(\freq.kr + (mod * 20) + (mod2 * 20), 0, \mul.kr), Pulse.ar(\freq.kr + (mod * 5) + (mod2 * 40), 0.5, \mul.kr)]);
	sig = Select.ar(\sel.kr(0), [Generate.ar(1, 0.3, -0.8, -0.8, 0.3, 0, 0, 0, 0, 0, \freq.kr(440) + (sig * 10) + (mod * 10) + (mod2 * 5)) * \mul.kr(1), SinOsc.ar(\freq.kr + (sig * 10) + (mod * 10) + (mod2 * 10), 0, \mul.kr), Pulse.ar(\freq.kr + (sig * 10) + (mod * 5) + (mod2 * 20), 0.5, \mul.kr)]);


	sig = sig.blend(Generate.ar(1, 0.3, -0.8, -0.8, 0.3, 0, 0, 0, 0, 0, \freq.kr(440) + (mod * 10) + (mod2 * 10) * 0.5).softclip * \mul.kr(1), 0.333);
	sig = sig.blend(mod2, 0.005);


	sig = RLPF.ar(sig, \lp.kr(2000) + (env * 200) + (env2 * 50) + (env3 * 70) + (LFNoise2.ar(0.2, 2500).abs), (\lq.kr(0.7) + LFNoise2.ar(0.01, 0.5).abs + 0.2).abs.clip2(0.999));

	sig = sig * env;
	sig = sig.softclip.softclip;
	sig = sig * 0.6;

	sig = RHPF.ar(sig, \hp.kr(100), \hq.kr(1));

	sig = sig * 0.7;

	sig = Pan2.ar(sig, \pan.kr(0));
	sig = Clip.ar(sig * 0.5, -0.2, 0.2);
	sig = Out.ar(\out.kr(0), sig);
}).add;
);

(~track = ({
~tr = rrand(0.8, 1.1);
~r = rrand(0.8, 1.5);

(Pdef(\acid, Pbind(
	\instrument, \synth1,
		\dur, [Prand([Prand([Pseq([0.125, 0.125, 0.25, 0.25, 0.125, 0.125], 1), Pseq([0.25, 0.25, 0.25, 0.125, 0.125], 1)], 1),Pseq([0.125, 0.125, 0.25, 0.25, 0.125, 0.125], 1), Pseq([0.25, 0.25, 0.25, 0.125, 0.125], 1), Pseq([0.5, 0.125, 0.125, 0.125, 0.125], 1), Prand([Pseq([0.25, 0.25, 0.25, 0.125, 0.125], 1), Pseq([0.5, 0.125, 0.125, 0.125, 0.125], 1)], 1), Pseq([0.25, 0.25, 0.25 ,0.25, 0.5, 0.25, 0.125, 0.125], 1)], inf),

			Prand([Pseq([0.125, 0.125, 0.25, 0.25, 0.125, 0.125], 1), Pseq([0.25, 0.25, 0.25, 0.125, 0.125], 1)], inf),Pseq([0.125, 0.125, 0.25, 0.25, 0.125, 0.125], inf), Pseq([0.25, 0.25, 0.25, 0.125, 0.125], inf), Pseq([0.5, 0.125, 0.125, 0.125, 0.125], inf), Prand([Pseq([0.25, 0.25, 0.25, 0.125, 0.125], 1), Pseq([0.5, 0.125, 0.125, 0.125, 0.125], 1)], inf), Pseq([0.25, 0.25, 0.25 ,0.25, 0.5, 0.25, 0.125, 0.125], inf)].choose * ~tr * [1, 2, 4].choose,
	\freq, Pseq([50, Prand([50, 52.1, 54.8, 53.95, 57], Prand([1, 2], 1)), Prand([50, 52.1, 57, 54.8], 1), 54.8].midicps, inf) * Prand([0.25, 0.5, 0.125], inf) + 170 * ~r,
	\mul, 0.7,
	\sel, [Prand([0, 1, 2], inf), 0, 1, 2].choose,
	\atk, Pwhite(0.00001, 0.05, inf) * ~tr,
	\dec, Pwhite(0.2, 0.45, inf) * ~tr,
	\atk2, rrand(0.00008, 0.05) * ~tr,
	\atk3, rrand(0.001, 0.008) * ~tr,
	\dec2, rrand(0.01, 0.05) * ~tr,
	\dec3, 0.005 * ~tr,
	\amp2, rrand(0.005, 6.0),
	\amp3, Pwhite(0.0, rrand(0.125, 5.0), inf),
	\lp, Pwhite(rrand(100, 200), rrand(300, 1400), inf),
	\lq, Pwhite(0.05, 1, inf),
	\hp, Pwhite(2, 50, inf),
	\r1, Prand([0.25, 0.5, 0.75, 1.25, 1.5], inf) + 170  * ~r,
	\r2, Prand([0.25, 0.5, 0.75, 1.25, 1.5], inf) * Prand([0.25, 0.5, 1, 2, 4], inf) * 0.125 + 170  * ~r,
		\pan, Pwhite(-0.2, 0.2, inf),
	\amp, rrand(0.6, 0.9) * 0.5,
	\out, ~reverbBus
));

	(Pdef(\arp1, Pbind(
		\instrument, [\synth1, \rest, \rest].choose,
		\dur, [0.125, 0.25].choose * ~tr,
		\freq, Pseq([[50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose].midicps, inf) * ~r * Prand([1, 2, 4], inf),
		\atk, 0.04,
		\dec, rrand(0.1, 0.5),
		\r1, [0.125, 0.25, 0.5, 1, 1.5, 2, 2.5, 3, 3.5].choose,
		\r2, [0.125, 0.25, 0.5, 1, 1.5, 2, 2.5, 3, 3.5].choose,
		\mul, 0.6,
		\amp, 0.45 * Pwhite(0.7, 0.8, inf),
	\pan, Pwhite(-0.4, 0.4, inf),
	\out, ~reverbBus
	)));

	(Pdef(\arp2, Pbind(
		\instrument, [\synth1, \rest, \rest].choose,
		\dur, [0.25, 0.125].choose * ~tr,
		\freq, Pseq([[50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose, [50, 52.1, 54.8, 53.95, 57].choose].midicps, inf) * ~r * Prand([1, 2, 4], inf),
		\atk, 0.04,
		\dec, rrand(0.1, 0.5),
		\r1, [0.125, 0.25, 0.5, 1, 1.5, 2, 2.5, 3, 3.5].choose,
		\r2, [0.125, 0.25, 0.5, 1, 1.5, 2, 2.5, 3, 3.5].choose,
		\mul, 0.6  * Pwhite(0.7, 0.8, inf),
		\amp, 0.45,
	\pan, Pwhite(-0.4, 0.4, inf),
	\out, ~reverbBus
	)));





(Pdef(\synths, Pbind(
	\instrument, \synth1,
	\dur, Prand([Pseq([1, 1], 1), 2, Pseq([1, 1], 1), Pseq([0.5, 0.5], 2), 2], inf) * ~tr * [0.5, 1, 2].choose,
	\freq, Prand([[50, 52.1], [50, 54.8], [50, 53.95], [50, 57], [52.1, 57], [53.95, 57], [53.95, 59]].midicps, inf) * ~r * Prand([2, 2, 4, 2], inf),
	\amp, 0.26,
	\sel, Prand([0, 1, 2], inf),
	\mul, rrand(0.35, 0.6),
	\atk, rrand(0.2, 1.2),
	\dec, Pwhite(0.5, 3, inf),
		\amp3, rrand(0.0, 0.3),
	\amp2, rrand(0.0, 5.5, inf),
		\atk2, rrand(0.0001, 0.75) * ~tr * rrand(0.5, 1.0),
	\dec2, rrand(0.1, 1.5)  * ~tr * rrand(0.5, 1.0),
	\lp, 200,
	\lq, 1,
	\hp, 200,
	\h1, 1,
		\pan, Pwhite(-0.3, 0.3, inf),
	\r1, [1.5, 1.25, 1.75].choose,
	\out, ~reverb2Bus
)));

(Pdef(\kick, Pbind(
		\instrument, [\synth1, Prand([\synth1, \synth1, \synth1, \synth1, \synth1, \synth1, \synth1, \synth1, \synth1, \rest], inf)].choose,
		\dur, [0.5, Prand([Pseq([0.5, 0.5], 1), Pseq([0.5, 0.5], 1), Pseq([0.5, 0.5], 1), Pseq([0.5, 0.5], 1), Pseq([0.5, 0.5], 1), 1], inf), Prand([0.5, 0.5, 0.5, 0.5, Pseq([0.25], 2), 0.5, 0.5, 0.5], inf)].choose * ~tr,
	\freq, 50,
	\sel, [0, 1].choose,
	\r1, 0.001,
	\r2, 0.5,
	\amp, rrand(0.6, 0.8),
	\amp2, rrand(15.0, 55.5),
	\amp3, 0.4,
	\atk, 0.0001,
	\dec, rrand(0.1, 0.25),
	\atk2, 0.000001,
	\dec2, rrand(0.05, 0.15),
	\atk3, 0.0001,
	\dec3, 0.14,
	\lp, rrand(10, 100),
	\mul, rrand(0.4, 0.6)
)));

Ndef(\reverb).play;
Ndef(\reverb).set(\mix, rrand(0.05, 0.45));
Ndef(\reverb).set(\room, rrand(0.005, 0.45));
Ndef(\reverb2).play;
Ndef(\reverb2).set(\mix, rrand(0.25, 0.95));
Ndef(\reverb2).set(\room, rrand(0.15, 0.95));

Pdef(\acid).play;
Pdef(\kick).play;
Pdef(\synths).play;
	Pdef(\arp2).play;
	Pdef(\arp1).play;

);
};
);
);

(Tdef(\track, {loop{
	~track.();
	~time = [16, 16, 16, 32, 32, 64, 32, 32, 32, 64, 64, 128, 256, 256 * 2,  256 * 2 * 2,  256 * 2 * 2 * 2].choose * ~tr;
	wait(~time);
}});
);

Tdef(\track).play;



s.scope.view.alwaysOnTop_(true);






































































































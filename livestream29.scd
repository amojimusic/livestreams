(
~reverbBus = Bus.audio(s, 2);
~reverb2Bus = Bus.audio(s, 2);
~delayBus = Bus.audio(s, 2);
~fmBus = Bus.audio(s, 2);
~modBus = Bus.audio(s, 2);
);

(

~tonic = 47;
~tuning = [~tonic, ~tonic + 0.7, ~tonic + (0.7 * 2), ~tonic + (0.7 * 3), ~tonic + (0.7 * 4), ~tonic + (0.7 * 5), ~tonic + (0.7 * 6), ~tonic + (0.7 * 7), ~tonic + (0.7 * 8), ~tonic + (0.7 * 9), ~tonic + (0.7 * 10), ~tonic + (0.7 * 11), ~tonic + (0.7 * 12), ~tonic + (0.7 * 13), ~tonic + (0.7 * 14), ~tonic + (0.7 * 15), ~tonic + (0.7 * 16), ~tonic + (0.7 * 17)].midicps;


~tuning[6]/~tuning[0];

~key = [~tuning[0], ~tuning[3], ~tuning[6], ~tuning[7], ~tuning[10], ~tuning[14], ~tuning[16]];

);



(

~fxGroup = Group(s);
~modGroup = Group(s, 'addToTail');

Ndef(\reverb).play;
Ndef(\reverb2).play;
Ndef(\delay).play;
Ndef(\lfo1).play;
Ndef(\reverb).group_(~fxGroup);
Ndef(\reverb2).group_(~fxGroup);
Ndef(\delay).group_(~fxGroup);
Ndef(\lfo1).group_(~modGroup);


(Ndef(\reverb, {
	var in;
	in = In.ar(~reverbBus, 2);
	in = FreeVerb.ar(in, \mix.kr(0.5), \room.kr(0.5), \damp.kr(0.5));
	Out.ar(~modBus, in);
	in = in.blend(FreeVerb.ar(in, 1, \room.kr, \damp.kr), 0.5);
}));

(Ndef(\reverb2, {
	var in;
	in = In.ar(~reverbBus, 2);
	in = FreeVerb.ar(in, \mix.kr(0.5), (\room.kr(0.5) + (Ndef(\lfo1).ar * 0.2).abs).clip2(0.99), \damp.kr(0.5));
	Out.ar(~fmBus, in);
	in = FreeVerb.ar(in, (0.3 + (Ndef(\lfo2).ar * 0.3).abs).clip2(0.9), 0.6, 0.8);

	in = in.blend(FreeVerb.ar(in, 1, \room.kr, \damp.kr), 0.5);

	in = Pan2.ar(in.sum, LFNoise2.ar(0.3));
}));

(Ndef(\delay, {
	var in, del;
	in = In.ar(~delayBus, 2);
	del = DelayN.ar(in, \del.kr(1), \del.kr);
	in = in.blend(del, 0.3);
	del = DelayN.ar(in, \del.kr, \del.kr);
	in = in.blend(del, 0.2);
	del = DelayN.ar(in, \del.kr, \del.kr);
	in = in.blend(del, 0.1);
	Out.ar(~fmBus, in);
	in = FreeVerb.ar(in, \mix.kr(0.5), \room.kr(0.5), (\damp.kr(0.5) + (Ndef(\lfo2).ar * 0.5)).abs.clip2(0.99));

	in = in.blend(FreeVerb.ar(in, 1, \room.kr, \damp.kr), 0.5);

	in = Pan2.ar(in.sum, LFNoise2.ar(0.1, 1));
}));

(Ndef(\lfo1, {
	var mod;
	mod = SinOsc.ar(\freq.kr(1), 0, \mul.kr(1), \add.kr(0));
	mod = [mod, mod];
}));

(Ndef(\lfo2, {
	var mod;
	mod = SinOsc.ar(\freq.kr(1), 0, \mul.kr(1), \add.kr(0));
	mod = [mod, mod];
}));

);

(SynthDef.new(\acid, {
	var env, freq, sig;
	env = EnvGen.kr(Env([0, \amp.kr(1), 0], [\atk.kr(0.01), \dec.kr(2)]), doneAction: 2);
	freq = Duty.ar(\ddur.kr(0.5), 0, Dseq([\freq1.kr(440), \freq2.kr(440), \freq3.kr(440), \freq4.kr(440)], inf)) + (In.ar(~fmBus, 2).sum * 70) + (Ndef(\lfo2).ar * (Ndef(\lfo1).ar * 0.45));
	sig = Saw.ar(freq, \mul.kr(1));

	sig = sig.blend(Pulse.ar(freq, 0.5, \mul.kr), 0.3);
	sig = sig.blend(SinOsc.ar(freq + [(SinOsc.ar(freq * 15, 0, 5000 + (In.ar(~modBus, 2).sum * 6000))), 0], mul: \mul.kr).sum * 0.5, (0.1 + (In.ar(~modBus, 2).sum * 4)).clip2(0.5)).softclip;
	sig = sig.blend(Saw.ar(freq * 0.5, \mul.kr), 0.1);
	sig = sig.sum;
	sig = RLPF.ar(sig, (\lp.kr(2000) + (LFNoise0.ar(LFNoise0.ar(3, 2).abs, 1000)) ).abs + 20, \lq.kr(1));
	sig = RHPF.ar(sig, \hp.kr(100), \hq.kr(1));
	sig = sig * 0.8;
	sig = FreeVerb.ar(sig, \mix.kr(0.5), \room.kr(0.5), \damp.kr(0.5));
	sig = Pan2.ar(sig * env, \pan.kr(0)) * 0.2;
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(\out.kr(0), sig);
}).add;
);



(Pdef(\acid, Pbind(
	\instrument, \acid,
	\dur, Pseq([Pseq([0.2, 0.1, 0.1, 0.05, 0.05, 0.1, 0.2, 0.1, 0.05, 0.05], 4), Prand([Pseq([0.4, 0.4, 0.2], 1), 1, Pseq([0.2, 0.8], 1)], 1)], inf) * 2,
	\amp, 0.5,
	\mul, Pwhite(0.2, 0.55, inf),
	\ddur, Prand([0.2, 0.4, 0.8, 1], inf),
	\atk, Pwhite(0.001, 0.1, inf),
	\dec, Pwhite(0.5, 2, inf),
	\lp, Pwhite(300, 3300, inf),
	\hp, Pwhite(20, 650, inf),
	\hq, Pwhite(0.7, 1, inf),
	\lq, Pwhite(0.4, 1, inf),
	\freq1, Pseq([~key[0], ~key[4], ~key[1], ~key[6], Prand(~key, 1)], inf) * Prand([0.5, 1], inf),
	\freq2, Prand(~key, inf) * Prand([0.5, 1, 2, 4], inf),
	\freq3, Pseq([~key[3], ~key[1], ~key[4]], inf) * Prand([0.5, 1, 2, 16], inf),
	\freq4, Pseq([Prand(~key, 1), ~key[2], ~key[5], ~key[5]], inf) * 0.5,
	\mix, Pwhite(0.3, 0.8, inf),
	\room, Pwhite(0.1, 1.0, inf),
	\damp, Pwhite(0.0, 1.0, inf),
	\pan, Pwhite(-0.6, 0.6, inf),
	\out, Prand([~delayBus, ~reverbBus, ~reverbBus, ~reverbBus, ~reverbBus, ~reverbBus, ~delayBus, ~reverbBus, ~delayBus, ~reverb2Bus, ~reverb2Bus, ~reverb2Bus, ~reverb2Bus, ~delayBus], inf)
)));

(

Tdef(\fx).play;
Ndef(\reverb).play;
Ndef(\reverb2).play;
Ndef(\delay).play;
Pdef(\acid).play;

);



(Tdef(\fx, {
	loop{
		Ndef(\reverb).set(\room, rrand(0.3, 1.0));
		Ndef(\reverb).set(\mix, rrand(0.3, 1.0));
		Ndef(\reverb).set(\damp, rrand(0.0, 1.0));
		wait([1, 2].choose);
		Ndef(\reverb2).set(\room, rrand(0.3, 1.0));
		wait([1, 2].choose);
		Ndef(\reverb2).set(\mix, rrand(0.3, 1.0));
		Ndef(\reverb2).set(\damp, rrand(0.0, 1.0));
		wait([1, 2].choose);
		Ndef(\delay).set(\room, rrand(0.3, 1.0));
		wait([1, 2].choose);
		Ndef(\delay).set(\mix, rrand(0.3, 1.0));
		Ndef(\delay).set(\damp, rrand(0.0, 1.0));
		wait([1, 2].choose);
		Ndef(\lfo1).set(\freq, rrand(0.02, 5.5));
		wait([1, 2].choose);
		Ndef(\lfo1).set(\mul, rrand(0.005, 1.5));
		Ndef(\lfo2).set(\freq, rrand(0.02, 2.5));
		wait([1, 2].choose);
		Ndef(\lfo2).set(\mul, rrand(0.005, 2.5));
		Ndef(\delay).set(\del, [0.2, 0.4, 0.8, 1].choose);
		wait([1, 2].choose);
		Ndef(\delay).set(\out, [~reverbBus, ~reverb2Bus].choose);

		wait([4, 8].choose);
}}));










































































































(

// mod buses
(
~lfo1Bus = Bus.audio(s, 2);
~lfo2Bus = Bus.audio(s, 2);
~randLfoBus = Bus.audio(s, 2);
~modBus = Bus.audio(s, 2);
~fmBus = Bus.audio(s, 2);
);

// mix buses
(
~mainBus = Bus.audio(s, 2);
~synthBus = Bus.audio(s, 2);
~padBus = Bus.audio(s, 2);
~bassBus = Bus.audio(s, 2);
);

// fx buses
(
~reverb1Bus = Bus.audio(s, 2);
~reverb2Bus = Bus.audio(s, 2);
~delayBus = Bus.audio(s, 2);
~filterBus = Bus.audio(s, 2);
~distortionBus = Bus.audio(s, 2);
);

);

// mod defs



(Ndef.new(\lfo1,  {
	var mod;
	mod = Select.ar(\sel.kr(0), [SinOsc.ar(\freq.kr(1), 0, \mul.kr(1)), LFTri.ar(\freq.kr, 0, \mul.kr), LFSaw.ar(\freq.kr(1) + (In.ar(~randLfoBus, 2) * 30 + 20) + (In.ar(~lfo2Bus, 2) * 3), mul: \mul.kr), LFPulse.ar(\freq.kr, mul: \mul.kr) - 0.5 * 2])  + In.ar(~lfo2Bus, 2);
	Out.ar(~lfo1Bus, mod ! 2);
});
);


(Ndef.new(\lfo2,  {
	var mod;
	mod = Select.ar(\sel.kr(0), [SinOsc.ar(\freq.kr(1), 0, \mul.kr(1)), LFTri.ar(\freq.kr, 0, \mul.kr), LFSaw.ar(\freq.kr(1), mul: \mul.kr), LFPulse.ar(\freq.kr, mul: \mul.kr) - 0.5 * 2]) * In.ar(~randLfoBus, 2);
	Out.ar(~lfo2Bus, mod ! 2);
});
);

(Ndef.new(\randLfo, {
	var mod;
	mod = LFNoise1.ar(\freq.kr(1), \mul.kr(1));
	Out.ar(~randLfoBus, mod ! 2);
});
);

(Ndef.new(\reverb1, {
	var mod, in;
	mod = SinOsc.ar(\freq.kr(1), 0, \amp.kr(1));
	in = In.ar(~reverb1Bus, 2);
	in = FreeVerb.ar(in, \mix.kr(0.5), Clip.ar(\room.kr(0.5) + (mod * 0.05), 0, 1), Clip.ar(\damp.kr(0.5) + (mod * 0.1), 0, 1))  * \mul.kr(1) * \main.kr(1);
	in = Limiter.ar(in, 0.5);
	Out.ar(\out.kr(0), in);
}));

(Ndef.new(\reverb2, {
	var mod, in;
	mod = SinOsc.ar(\freq.kr(1), 0, \amp.kr(1));
	in = In.ar(~reverb2Bus, 2);
	in = FreeVerb.ar(in, \mix.kr(0.5), Clip.ar(\room.kr(0.5) + (mod * 0.05), 0, 1), Clip.ar(\damp.kr(0.5) + (mod * 0.1), 0, 1)) * \mul.kr(1) * \main.kr(1);
	in = Limiter.ar(in, 0.5);
	Out.ar(\out.kr(0), in);
}));

(Ndef.new(\delay, {
	var in, del;
	in = In.ar(~delayBus, 2);
	del = DelayN.ar(in, \time.kr(0.25), \time.kr);
	in = in.blend(del, 0.75 * \mix.kr(1));
	del = DelayN.ar(in, \time.kr(0.25), \time.kr);
	in = in.blend(del, 0.5 * \mix.kr(1));
	del = DelayN.ar(in, \time.kr(0.25), \time.kr);
	in = in.blend(del, 0.35 * \mix.kr(1));
	del = DelayN.ar(in, \time.kr(0.25), \time.kr);
	in = in.blend(del, 0.25 * \mix.kr(1));
	in = in * \mul.kr(1) * \main.kr;
	in = Limiter.ar(in, 0.5);
	Out.ar(\out.kr(0), in);
}));

(Ndef.new(\filter, {
	var in;
	in = In.ar(~filterBus, 2);
	in = Select.ar(\sel.kr(0), [RLPF.ar(in, \freq.kr(1000), \res.kr(1)), BPF.ar(in, \freq.kr, \res.kr), RHPF.ar(in, \freq.kr, \res.kr)]);
	in = in * \mul.kr(1) * \main.kr(1);
	in = Limiter.ar(in, 0.5);
	Out.ar(\out.kr(0), in);
}));



(SynthDef.new(\synth, {
	var env, mod, sig;
	env = EnvGen.kr(Env.perc(\atk.kr(0.01), \dec.kr(0.5), \amp.kr(1)), doneAction: 2);
	mod = GeneRand.ar(\freq.kr(440) * \r.kr(1.5), \mmul.kr(1));
	sig = LFPulse.ar(\freq.kr + (mod * 5) + (In.ar(~lfo1Bus, 2).sum * 50) + (In.ar(~modBus, 2).sum * 100), mul: 1) - 0.5 * 2 * \mul.kr(1);
	sig = sig * env;
	sig = RLPF.ar(sig, \lp.kr(2500), \q.kr(1));
	sig = Select.ar(\sel.kr(0), [[sig, DelayN.ar(sig, 0.0025, 0.0025)], [DelayN.ar(sig, 0.0025, 0.0025), sig]]) * 0.5;
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(\out.kr(0), sig);
	Out.ar(~fmBus, sig);
}).add;
);

(SynthDef.new(\kick, {
	var env, sig;
	env = EnvGen.kr(Env.perc(\atk.kr(0.001), \dec.kr(0.1), \amp.kr(1), -8.0), doneAction: 2);
	sig = SinOsc.ar(20 + (env * 300) + (In.ar(~fmBus, 2).sum * 70) + (In.ar(~lfo1Bus, 2).sum * 0.25) + (In.ar(~lfo2Bus, 2).sum * 0.1), 0, \mul.kr(1));
	Out.ar(~modBus, sig);
	sig = SinOsc.ar(20 + (env * 300) + (In.ar(~modBus, 2).sum * 40) + (In.ar(~lfo1Bus, 2).sum * 0.25) + (In.ar(~lfo2Bus, 2).sum * 0.1), 0, \mul.kr(1));
	Out.ar(~modBus, sig);
	sig = sig * env;
	sig = Select.ar(\sel.kr(0), [[sig, DelayN.ar(sig, 0.0025, 0.0025)], [DelayN.ar(sig, 0.0025, 0.0025), sig]]) * 0.5;
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\snare, {
	var env, noise, sig;
	env = EnvGen.kr(Env.perc(\atk.kr(0.01), \dec.kr(0.1), \amp.kr(1)), doneAction: 2);
	noise = WhiteNoise.ar(\nmul.kr(1));
	sig = SinOsc.ar(450 + (env * 250) + (In.ar(~fmBus, 2).sum * 500) + (In.ar(~lfo2Bus, 2).sum * 0.0001), 0, \mul.kr(1));
	Out.ar(~fmBus, sig ! 2);
	sig = SinOsc.ar(550 + (env * 450) + (In.ar(~fmBus, 2).sum * 2000) + (In.ar(~lfo2Bus, 2).sum * 0.0001), 0, \mul.kr(1));
	Out.ar(~fmBus, sig ! 2);
	sig = sig.blend(noise, 0.15) * env;
	sig = RHPF.ar(sig, \hp.kr(100), \q.kr(1));
	sig = RLPF.ar(sig, \lp.kr(3000), \q.kr(1));
	sig = Select.ar(\sel.kr(0), [[sig, DelayN.ar(sig, 0.0025, 0.0025)], [DelayN.ar(sig, 0.0025, 0.0025), sig]]) * 0.375;
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(\out.kr(0), sig);
}).add;
);

(Ndef(\main, {
	var in;
	in = In.ar(~mainBus, 2);
	in = in * \main.kr(1);
	in = Limiter.ar(in, 0.5);
	Out.ar(0, in);
}));

(Ndef(\padBus, {
	var in;
	in = In.ar(~padBus, 2);
	in = in * \mul.kr(1) * \main.kr(1);
	in = Limiter.ar(in, 0.5);
	Out.ar(0, in);
}));

(Ndef(\synthBus, {
	var in;
	in = In.ar(~synthBus, 2);
	in = in * \mul.kr(1) * \main.kr(1);
	in = Limiter.ar(in, 0.5);
	Out.ar(0, in);
}));




(


~lfoGroup = Group.new(s, \addToHead);
~synthGroup = Group.new(s, \addToTail);

(~synths = Pbind(
	\instrument, \synth,
	\dur, Prand([2, 1, Pseq([0.25, 0.25], 2), Pseq([0.5, 0.5], 1), Pseq([0.25, 0.25, 0.5], 1), Pseq([0.5, 0.25, 0.25], 1)], inf),
	\freq, Prand([50, 100, 200, 300, 400, 500], inf) * Prand([0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], inf),
	\dec, Pwhite(0.05, 0.65, inf),
	\lp, Pwhite(300, 3500, inf),
	\q, Pwhite(0.05, 1, inf),
	\r, Prand([1.5, 2, 2.5, 3.5, 4.5, 5.5], inf),
	\amp, 0.4,
	\mul, 0.3,
	\group, ~synthGroup,
	\out, Pseq([~padBus, ~synthBus, ~mainBus, ~randLfoBus, ~reverb1Bus, ~delayBus, ~modBus, ~synthBus, ~mainBus, ~randLfoBus, ~synthBus, ~reverb2Bus, ~filterBus, ~synthBus, ~mainBus], inf)
));

(~kicks = Pbind(
	\instrument, \kick,
	\dur, Pseq([16, 1, 1, 1, Pseq([0.5, 0.5], 1), Pseq([0.25, 0.25], 2), Pseq([0.125, 0.125], 4), Pseq([0.125, 0.125, 0.25], 2), Pseq([0.25, 0.125, 0.125], 2), Pseq([0.5, 0.25, 0.25], 1), Pseq([0.5, 0.5], 1), Pseq([0.25, 0.25], 2), Pseq([0.125, 0.125], 4), Pseq([0.125, 0.125, 0.25], 2), Pseq([0.25, 0.125, 0.125], 2), Pseq([0.5, 0.25, 0.25], 1), Pseq([0.5, 0.5], 1), Pseq([0.25, 0.25], 2), Pseq([0.125, 0.125], 4), Pseq([0.125, 0.125, 0.25], 2), Pseq([0.25, 0.125, 0.125], 2), Pseq([0.5, 0.25, 0.25], 1), Pseq([0.5, 0.5], 1), Pseq([0.25, 0.25], 2), Pseq([0.125, 0.125], 4), Pseq([0.125, 0.125, 0.25], 2), Pseq([0.25, 0.125, 0.125], 2), Pseq([0.5, 0.25, 0.25], 1)], inf),
	\amp, 1,
	\mul, 0.6,
	\sel, Prand([0, 1], inf),
	\dec, Pwhite(0.1, 0.325, inf),
	\group, ~synthGroup,
	\out, Pseq([~mainBus, ~filterBus, ~mainBus, ~mainBus, ~filterBus, ~mainBus, ~delayBus, ~mainBus, ~mainBus, ~filterBus, Prand([~mainBus, ~delayBus, ~reverb1Bus], 1)], inf)
));

(~snares = Pbind(
	\instrument, Pseq([\rest, \snare], inf),
	\dur, Prand([8, 16, Pseq([0.5, 0.5], Prand([16, 8, 32], 1)), Pseq([0.125, 0.125], Prand([16, 128, 32, 64], 2)), Pseq([0.125, 0.125], Prand([16, 128, 32, 64], 2)), Pseq([0.25, 0.25], Prand([16, 32, 64, 128], 1)), Pseq([0.25, 0.25], Prand([16, 128, 32, 64], 1)),  Pseq([0.5, 0.5], Prand([16, 8, 32], 1)), Pseq([0.125, 0.125], Prand([16, 128, 32, 64], 2)), Pseq([0.125, 0.125], Prand([16, 128, 32, 64], 2)), Pseq([0.25, 0.25], Prand([16, 32, 64, 128], 1)), Pseq([0.25, 0.25], Prand([16, 128, 32, 64], 1)), Pseq([0.125, 0.125], Prand([16, 128, 32, 64], 2)), Pseq([0.25, 0.25], Prand([64, 128], 1)), Pseq([0.125, 0.125], Prand([ 28, 64], 2))], inf),
	\amp, 1,
	\dec, 0.08,
	\mul, 0.3,
	\sel, Prand([0, 1], inf),
	\group, ~synthGroup,
	\out, Prand([~delayBus, ~reverb1Bus, ~reverb2Bus, ~filterBus, ~mainBus, ~mainBus, ~mainBus], inf)
));

Ndef(\main).play;
Ndef(\padBus).play;
Ndef(\synthBus).play;
Ndef(\reverb1).play;
Ndef(\reverb2).play;
Ndef(\delay).play;
Ndef(\filter).play;

Ndef(\lfo1).play;
Ndef(\lfo1).group_(~lfoGroup);
Ndef(\lfo1).set(\freq, 11, \sel, 3, \mul, 54);

Ndef(\lfo2).play;
Ndef(\lfo2).group_(~lfoGroup);
Ndef(\lfo2).set(\freq, 12, \sel, 3, \mul, 39.5);

Ndef(\randLfo).play;
Ndef(\randLfo).group_(~lfoGroup);
Ndef(\randLfo).set(\freq, 10.75, \mul, 3);

t = TempoClock(53.75/60).permanent_(true);

~synths.play(t);
~synths.play(t);
~synths.play(t);
~synths.play(t);
~synths.play(t);
~kicks.play(t);
~snares.play(t);
~snares.play(t);

);

s.scope;

s.plotTree;











































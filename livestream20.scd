
(
Gremlin.makeBuses;
~reverbBus = Bus.audio(s, 2);
~delayBus = Bus.audio(s, 2);

);

(
~root = 53;

~edo13 = [~root, ~root + (0.923), ~root + (0.923 * 2), ~root + (0.923 * 3), ~root + (0.923 * 4), ~root + (0.923 * 5), ~root + (0.923 * 6), ~root + (0.923 * 7), ~root + (0.923 * 8), ~root + (0.923 * 9), ~root + (0.923 * 10), ~root + (0.923 * 11), ~root + (0.923 * 12)].midicps;



(~key = [~root,
	~second = ~root + (0.923 * 2),
	~third = ~root + (0.923 * 4),
	~fourth = ~root + (0.923 * 5),
	~fifth1 = ~root + (0.923 * 7),
	~fifth2 = ~root + (0.923 * 8),
	~sixth = ~root + (0.923 * 10),
	~seventh = ~root + (0.923 * 12)
].midicps;);

);


(SynthDef.new(\synth, {
	var env, freq, sig;
	env = EnvGen.kr(Env.perc(\atk.kr(0.01), \dec.kr(1), \amp.kr(1)), doneAction: 2);
	freq = \freq.kr(440) + Select.kr(\sel.kr(0), [(In.kr(~gremLfo1Bus, 1) * 100), (In.kr(~gremLfo3Bus, 1) * 150)]);
	sig = Saw.ar(freq, \mul.kr(1));
	sig = [sig, sig].sum;
	sig = sig.blend(SinOsc.ar(freq + (0.923 * 4) * 4, 0, \mul.kr), 0.3) * 0.9;
	sig = sig.blend(Saw.ar(freq + (0.923 * 8) * 4, \mul.kr), 0.85) * 0.8;
	sig = sig.blend(SinOsc.ar(freq * 2, 0, \mul.kr) * 8, 0.55) * 0.7;
	sig = sig.blend(SinOsc.ar(freq + (0.923 * 12) * 16, 0, \mul.kr), 0.2) * 0.9;
	sig = sig.blend(SinOsc.ar(freq + (0.923 * 7) * [4, 8], 0, \mul.kr), 0.1) * 0.8;
	sig = sig.blend(SinOsc.ar(freq + (0.923 * 2) * 2, 0, \mul.kr), 0.4);
	sig = sig.blend(SinOsc.ar(freq + (0.923 * 4) * 2, 0, \mul.kr), 0.7) * 0.9;
	sig = sig.blend(SinOsc.ar(freq + (0.923 * 8) * 2, 0, \mul.kr), 0.4) * 0.6;
	sig = sig.blend(SinOsc.ar(freq * 2, 0, \mul.kr), 0.85) * 0.7;
	sig = RLPF.ar(sig, \lp.kr(4000), \q.kr(1));
	sig = sig * env;
	sig = Select.ar(\sel.kr,[ [sig, DelayN.ar(sig, 0.0025, 0.0025)] * 0.5, [DelayN.ar(sig, 0.0025, 0.0025), sig] * 0.5]);
	sig = sig * 0.4;
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(\out.kr(0), sig);
}).add;
);

(Ndef(\reverb, {
	var in;
	in = In.ar(~reverbBus, 2);
	in = FreeVerb.ar(in, \mix.kr(0.55) + (In.kr(~gremLfo1Bus, 1) * 0.125), Clip.ar(\room.kr(0.9) + (In.kr(~gremLfo2Bus, 1) * 0.025), 0, 1), \damp.kr(0.9));
	in = FreeVerb.ar(in);
	Out.ar(~gremMainBus, in);
}));

(Ndef(\delay, {
	var in, del;
	in = In.ar(~delayBus, 2);
	del = DelayN.ar(in, 0.5, 0.5);
	in = in.blend(del, 0.7);
	del = DelayN.ar(in, 0.5, 0.5);
	in = in.blend(del, 0.6);
	del = DelayN.ar(in, 0.5, 0.5);
	in = in.blend(del, 0.45);
	del = DelayN.ar(in, 0.5, 0.5);
	in = in.blend(del, 0.35);
	del = DelayN.ar(in, 0.5, 0.5);
	in = in.blend(del, 0.2);
	Out.ar(~reverbBus, in);
}));

Gremlin.new;

(r = Routine({inf.do{
	Synth(\synth, [\freq, ~key.choose * 1.3 * [0.5, 0.5, 0.5, 1, 1, 2, 0.5, 0.5, 0.5, 1, 2].choose, \dec, rrand(1, 2), \amp, 0.28, \lp, rrand(1400, 2000) * 1.1, \atk, rrand(0.05, 0.07), \q, rrand(0.7, 1), \sel, [0, 1].choose, \out, [~reverbBus, ~delayBus, ~reverbBus, ~reverbBus, ~reverbBus].choose]);
	wait([0.25, 0.5, 1, 0.25, 0.5].choose);
}};
);
);

t = TempoClock(47.4699/60).permanent_(true);

(
Ndef(\reverb).play;
Ndef(\delay).play;

Gremlin.playLfos;
Gremlin.playMixNodes;

r.play(t);
r.play(t);
);


Synth(\synth, [\dec, 20, \amp, 0.3, \freq, 200, \sel, [0, 1].choose]);
FreqScopeWindow(scopeColor: Color.cyan, server: s);
s.scope.view.alwaysOnTop_(true);


















































































































~reverbBus = Bus.audio(s, 2);


12/14;

~di = 0.8571;
~root = 52;

(~edo14 = [~root, ~root + ~di, ~root + (~di * 2), ~root + (~di * 3), ~root + (~di * 4),
	~root + (~di * 5), ~root + (~di * 6), ~root + (~di * 7), ~root + (~di * 8), ~root + (~di * 9),
	~root + (~di * 10), ~root + (~di * 11), ~root + (~di * 12), ~root + (~di * 13)].midicps;
);

(~key = [~root, ~root + (~di * 2), ~root + (~di * 5), ~root + (~di * 6), ~root + (~di * 8),
	~root + (~di * 11), ~root + (~di * 13)].midicps);

(Ndef(\reverb, {
	var mod, in;
	mod = SinOsc.ar(\freq.kr(1), 0, \amp.kr(1));
	in = In.ar(~reverbBus, 2);
	in = FreeVerb.ar(in, Clip.ar(\mix.kr(0.8) + (In.kr(~gremLfo3Bus, 1) * 0.2), 0.0, 1.0), Clip.ar(\room.kr(0.8) + (mod * 0.1), 0.0, 1.0), \damp.kr(0.5));
	in = FreeVerb .ar(in, Clip.ar(\mix.kr(0.8) + (In.kr(~gremLfo1Bus, 1) * 0.2), 0.0, 1.0), Clip.ar(\room.kr(0.8) + (mod * 0.1), 0.0, 1.0), \damp.kr);
	in = in * \mul.kr(1);
	in = Clip.ar(in, -0.5, 0.5);
	Out.ar(\out.kr(0), in);
}));

(SynthDef.new(\synth, {
	var env, freq, sig;
	env = EnvGen.kr(Env([0, \amp.kr(1), 0], [\atk.kr(0.01), \rel.kr(2)]), doneAction: 2);
	freq = \freq.kr(440) + (In.kr(~gremLfo4Bus, 1) * 70) + (In.kr(~gremLfo2Bus, 1) * 3);
	sig = SinOsc.ar(freq, 0, \mul.kr(1));
	sig = sig.blend(SinOsc.ar(freq + (~root + ~di).midicps * 64, 0, \mul.kr), 0.05) * 0.55;
	sig = sig.blend(SinOsc.ar(freq + (~root + (~di * 13)).midicps * 32, 0, \mul.kr), 0.075 + (In.kr(~gremLfo3Bus, 1) * 0.05)) * 0.63;
	sig = sig.blend(SinOsc.ar(freq + (~root + (~di * 6)).midicps * 16 + (In.kr(~gremLfo1Bus, 1) * 2), 0, \mul.kr), 0.1) * 0.7;
	sig = sig.blend(SinOsc.ar(freq + (~root + (~di * 5)).midicps * 8, 0, \mul.kr), 0.2 + (In.kr(~gremLfo1Bus, 1) * 0.05)) * 0.3;
	sig = sig.blend(SinOsc.ar(freq + (~root + (~di * 8)).midicps * 4, 0, \mul.kr), 0.3 + (In.kr(~gremLfo2Bus, 1) * 0.05)) * 0.2;
	sig = sig.blend(SinOsc.ar(freq * 2, 0, \mul.kr), 0.35 + (In.kr(~gremLfo3Bus, 1) * 0.05)) * 0.3;
	sig = sig * 0.2;
	sig = [sig, SinOsc.ar(freq, 0, \mul.kr * 0.2)].sum * 0.5;
	sig = sig * env * 0.7;
	sig = RLPF.ar(sig, \lp.kr(1000) + (In.kr(~gremLfo3Bus, 1) * 50), \q.kr(1));
	sig = Select.ar(\sel.kr(0), [[sig, DelayN.ar(sig, 0.0025, 0.0025)] * 0.5, [DelayN.ar(sig, 0.0025, 0.0025), sig] * 0.5]);
	sig = Clip.ar(sig * 0.7, -0.3, 0.3);
	Out.ar(\out.kr(0), sig);
}).add;
);

Gremlin();

Synth(\synth, [\freq, ~key.choose * 2, \amp, 1.4]);

(~pattern = Pbind(
	\instrument, \synth,
	\dur, Pseq([Prand([0.5, Pseq([0.25, 0.25], 1)], 1), Prand([0.5, Pseq([0.25, 0.25], 1)], 1), 0.5, 0.5, Prand([1, Pseq([0.5, 0.5], 1), Pseq([0.25, 0.25], 2)], 1)], inf),
	\freq, Pseq([Prand([~key[0], ~key[1]], 2), Prand([~key[0], ~key[2], ~key[4], ~key[5]], Prand([1, 2, 3], 1)), ~key[2], ~key[0],Prand([~key[1], ~key[2], ~key[3]], 1), ~key[0], Prand(~key, Prand([1, 2, 3], 1)), ~key[2]], inf) * Prand([2, 2, 4, 2, 4, 1, 0.5], inf),
	\amp, 0.8,
	\rel, Pwhite(0.7, 3.5, inf),
	\atk, Pwhite(0.001, 0.025, inf),
	\mul, Pseq([0.7, 0.65, 0.625], inf),
	\lp, Pwhite(600, 3500, inf),
	\q, Pwhite(0.3, 1.0, inf),
	\sel, Prand([0, 1], inf),
	\pan, Pwhite(-0.6, 0.6, inf),
	\out, ~reverbBus
));

(~scope = Routine({inf.do{
	c.scopeView.waveColors = [Color(rrand(0.0, 1.0), rrand(0.0, 1.0), rrand(0.0, 1.0), rrand(0.2, 1.0))];
	wait([0.25, 0.5, 1, 2].choose);
}}));

Ndef(\reverb).play;
Ndef(\reverb).set(\mix, 0.3);
Ndef(\reverb).set(\mul, 1.35);
Ndef(\reverb).set(\room, 0.5);

~pattern.play;
~scope.play(AppClock);


c = s.scope;
c..view.alwaysOnTop_(true)















































































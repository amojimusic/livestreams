(
~reverbBus = Bus.audio(s, 2);
~kickVerbBus = Bus.audio(s, 2);
~fmBus = Bus.audio(s, 2);
);

(Task({
	s.waitForBoot;
	loop{
		if(~keyMod.isNil){
			~keyMod = 1};
		n = rrand(30.0, 75.0);
		n.postln;
		t = TempoClock(n/60).permanent_(true);
		~tonic = 48;
		~tuning = [~tonic, ~tonic + 0.75, ~tonic + (0.75 * 2), ~tonic + (0.75 * 3), ~tonic + (0.75 * 4), ~tonic + (0.75 * 5), ~tonic + (0.75 * 6), ~tonic + (0.75 * 7), ~tonic + (0.75 * 8), ~tonic + (0.75 * 9), ~tonic + (0.75 * 10), ~tonic + (0.75 * 11), ~tonic + (0.75 * 12), ~tonic + (0.75 * 13), ~tonic + (0.75 * 14), ~tonic + (0.75 * 15), ~tonic + (0.75 * 16)].midicps;

		~key = [~tuning[0], ~tuning[3], ~tuning[5], ~tuning[7], ~tuning[9], ~tuning[12], ~tuning[13], ~tuning[14]];

		(
			Tdef(\key, {loop{
				~keyMod = rrand(0.6, 1.6);
				wait(rrand(16, 32*2));
			}});
		);
		Tdef(\key).play;

		~fx = Group(s, 'addToHead');
		Ndef(\reverb).group_(~fx);
		Ndef(\reverb).play;
		Ndef(\kickVerb).play;

		(Ndef(\reverb, {
			var mod, in;
			mod = SinOsc.ar(\freq.kr(1.15), 0, \mul.kr(1));
			in = In.ar(~reverbBus, 2);
			in = in.blend(FreeVerb.ar(DelayN.ar(in, 0.5, 0.5)), 1, 1, 0.5);
			in = FreeVerb.ar(in, Clip.ar(\mix.kr(0.8) + (mod * 0.05)), Clip.ar(\room.kr(0.8) + (mod * 0.1)), \damp.kr(0.7));
			in = in.blend(FreeVerb.ar(DelayN.ar(in, 0.5, 0.5), 1, 0.3, 0.1), 0.25);
			in = FreeVerb.ar(in, Clip.ar(0.7 + (mod * 0.025)), 0.9, Clip.ar(0.5 + (mod * 0.3)));
		}));

		(Ndef(\kickVerb, {
			var in;
			in = In.ar(~kickVerbBus, 2);
			in = in.blend(FreeVerb.ar(in, 0.6, 0.8, Clip.ar(SinOsc.ar(2, 0, 0.5, 0.2).abs + 0.5)), 0.48);
		}));


		(SynthDef(\synth, {
			var oTrig, env, mod, freq, sig, pan;
			oTrig = Impulse.ar(0.000001);
			mod = SinOsc.ar(\freq.kr(440) * \r.kr(1.5), 0, \mmul.kr(1));
			freq = \freq.kr + (In.ar(~fmBus, 2).sum * 40)+ (mod * SinOsc.ar(2.5, 0, 5)) + (In.ar(~reverbBus, 2).sum * SinOsc.ar(LFNoise0.ar(2, 6).abs, 0, SinOsc.ar(LFNoise0.ar(3).abs, 0, LFNoise2.ar(0.35, 6000).abs, LFNoise2.ar(0.5, 12000).abs).abs).abs);
			env = EnvGen.ar(Env([0, \amp.kr(1), 0], [\atk.kr(0.01), \dec.kr(0.5)]), doneAction: 2);
			sig = SinOsc.ar(freq, 0, \mul.kr(1));
			sig = sig.blend(SinOsc.ar(freq * 1.682 * 4, 0, \mul.kr), 0.03 * 0.7);
			sig = sig.blend(SinOsc.ar(freq * 1.354 * 2, 0, \mul.kr), 0.05 * 0.7);
			sig = sig.blend(SinOsc.ar(freq * 1.834 * 2, 0, \mul.kr), 0.05 * 0.7);
			sig = sig.blend(Pan2.ar(SinOsc.ar(freq * 1.139 * 2, 0, \mul.kr), 0.3), 0.05 * 0.7);
			sig = sig.blend(SinOsc.ar(freq * 1.242, 0, \mul.kr), 0.05 * 0.7);
			sig = sig.blend(SinOsc.ar(freq * 1.476, 0, \mul.kr), 0.1 * 0.7);
			sig = sig.blend(Pan2.ar(SinOsc.ar(freq * 2, 0, \mul.kr), -0.1), 0.11 * 0.7);
			sig = sig.blend(SinOsc.ar(freq, 0, \mul.kr), 0.4);
			pan = \pan.kr(0);
			sig = Pan2.ar(sig, pan);
			sig = sig.blend(Splay.ar(Saw.ar(freq + (sig * 4) * 2, \mul.kr), 9), SinOsc.ar(1.25, 0, 0.1).abs);
			sig = sig.blend(Splay.ar(Pulse.ar(freq * 4, 0.5, \mul.kr), 5), 0.075);
			sig = RLPF.ar(sig, \lp.kr(2000), \lq.kr(1));
			sig = RHPF.ar(sig, \hp.kr(1), \q.kr(1));
			sig = sig.blend(Pan2.ar(SinOsc.ar(freq * 1.242, 0, \mul.kr), pan), 0.05 * 0.7);
			sig = sig.blend(Pan2.ar(SinOsc.ar(freq * 1.476, 0, \mul.kr), pan), 0.1 * 0.7);
			sig = sig.blend(Pan2.ar(SinOsc.ar(freq * 2, 0, \mul.kr), -0.1), 0.11 * 0.7);
			sig = sig.blend(Pan2.ar(SinOsc.ar(freq, 0, \mul.kr), pan), 0.4);
			sig = sig * env;
			sig = sig * 0.55;
			sig = Clip.ar(sig, -0.3, 0.3);
			SendReply.ar(oTrig, '/synthTrig', 1);
			Out.ar(\out.kr(0), sig);
			Out.ar(~fmBus, sig * 0.05);
		}).add;
		);

		(SynthDef.new(\kick, {
			var trig, env, freq, sig, pan;
			trig = Impulse.ar(0.000001);
			env = Env.perc(\atk.kr(0.01), \dec.kr(0.1), \amp.kr(1), -2).kr(2);
			freq = (env * 350);
			sig = SinOsc.ar(freq, 0, \mul.kr(1));
			sig = sig.blend(SinOsc.ar(freq + (LocalIn.ar(1) * 3000), 0, \mul.kr), 0.4) * env;
			pan = \pan.kr(0);
			LocalOut.ar(sig);
			sig = Pan2.ar(sig, pan);
			sig = RLPF.ar(sig, (env * 500), 1 - Clip.ar((env * 0.8))) * 0.8;
			sig = Clip.ar(sig * 0.8, -0.5, 0.5);
			Out.ar(\out.kr(0), sig);
			Out.ar(~fmBus, sig);
			SendReply.ar(trig, '/kickTrig', 1);
		}).add;
		);

		(SynthDef.new(\snare, {
			var trig, env, freq, sig, pan;
			trig = Impulse.ar(0.000001);
			env = Env.perc(\atk.kr(0.01), \dec.kr(0.1), \amp.kr(1), \curve.kr(0)).kr(2);
			freq = (env * 250) + (LocalIn.ar * 10000) + (In.ar(~fmBus, 2).sum * 3000);
			sig = SinOsc.ar(freq, 0, \mul.kr(1));
			sig = sig.blend(FreeVerb.ar(sig, 0.45 + Clip.ar(sig.abs * 0.5, hi: 0.5), 0.7, 0.1), 0.5)* env;
			LocalOut.ar(sig);
			pan = \pan.kr(0);
			sig = Pan2.ar(sig, pan);
			sig = Clip.ar(sig * 0.65, -0.5, 0.5);
			sig = RLPF.ar(sig, 2000 + (env * 3000), Clip.ar(1 - (env * 0.95)));
			SendReply.ar(trig, '/snareTrig', 1);
			Out.ar(\out.kr(0), sig);
			Out.ar(~fmBus, sig);
		}).add;
		);
		(
			SynthDef.new(\hat, {
				var env, sig, trig;
				env = Env.perc(\at.kr(0.01), \dec.kr(0.05), \amp.kr(1), \curve.kr(0)).kr(2);
				sig = WhiteNoise.ar(\mul.kr(1)) * env;
				sig = Pulse.ar([330, 337.5] * 1.825 + (sig * 200) + (LocalIn.ar * 300), 0.5, \mul.kr(1));
				LocalOut.ar(sig);
				sig = sig.blend(WhiteNoise.ar(\mul.kr), 0.125);
				sig = sig * env;
				sig = RHPF.ar(sig * 0.9, 4000 + (env * 2000), 0.5);
				sig = Pan2.ar(sig, \pan.kr(0));
				trig = Impulse.ar(0.00001);
				Out.ar(\out.kr(0), sig);
				SendReply.ar(trig, '/hatTrig', 1);
			}).add;
		);

		(Pdef(\pads, Pbind(
			\instrument, \synth,
			\dur, Pseq([4, Prand([Pseq([2, 2], 1), 4], 3)], inf),
			\mul, Pseq([0.1, 0.1, 0.075, 0.065, 0.05], inf),
			\amp, 0.6,
			\mmul, Pwhite(0.015, 50, inf),
			\r, Prand([1.476, 1.476, 1.242, 1.242, 1.139, 1.834], inf) * Prand([2, 4, 8, 1, 16], inf) * Pfunc({~keyMod;}),
			\dec, Pwhite(2.5, 8, inf),
			\atk, Pwhite(1.5, 3, inf),
			\freq, Pseq([[~key[0], ~key[2], ~key[4]], [~key[0], ~key[3], ~key[5]], [~key[2], ~key[4], ~key[6]], [~key[5], ~key[2], ~key[4]], [~key[4], ~key[0], ~key[7]], Prand([[~key[0], ~key[2], ~key[4]], [~key[0], ~key[3], ~key[5]], [~key[2], ~key[4], ~key[6]], [~key[5], ~key[2], ~key[4]], [~key[4], ~key[0], ~key[7]], [~key.choose, ~key.choose, ~key.choose], Pfunc({
				[~key.choose, ~key.choose, ~key.choose];
			})], 3)], inf) * Pseq([4, 2, Prand([2, 4, 8], 1), 2, 8, 2], inf) * Pfunc({~keyMod;}),
			\lp, Pwhite(500, 3222, inf),
			\pan, Prand([[-0.5, 0, 0.5], [-0.3, 0.2, -0.1], [0.3, -0.2, 0.1], [0, 0, 0], [-1, 0, 1], [-0.4, 0.1, 0.2], [0.4, -0.1, -0.2]], inf),
			\hp, Pwhite(600, 2000, inf),
			\hq, Pwhite(0.2, 1.0, inf),
			\lq, Pwhite(0.75, 1.0, inf),
			\out, ~reverbBus
		)));

		(Pdef(\kicks, Pbind(
			\instrument, \kick,
			\dur, Pseq([0.5, 0.5, 0.33 * 2, Prand([0.33 * 2, Pseq([0.33], 2)], 1), 0.34 * 2, 0.2, Prand([0.2, Pseq([0.1], 2)], 1), 0.2, 0.2, 0.2], inf),
			\amp, Pseq([1, 0.8, 0.6, 1,  0.35, 0.25, Prand([0.25, 0.35, 0.5, 0.8, 1, 1, 1, 1], 4), 1, 0.5, 0.7, 1], inf),
			\dec, Pseq([Prand([0.1, 0.3, 0.4, 0.5], 1), 0.1, 0.05, 0.05, 0.2, 0.3], inf),
			\mul, 0.35,
			\out, ~kickVerbBus
		)));


		(OSCdef(\synthTrig, {
			if(~padTrig.isNil){
				~padTrig = 0};
			if(~padTrig %  9 == 0){
				Task({
					wait(2);
					Synth(\synth, [\freq, [[~key.choose, ~key.choose], ~key.choose].choose * [1, 2, 4].choose * ~keyMod, \atk, rrand(0.01, 2.5), \dec, rrand(0.05, 3), \amp, 0.06, \mul, 0.2, \out, ~reverbBus, \pan, [[-0.1, -0.3, -0.6].choose, [0.1, 0.3, 0.6].choose]]);
					Synth(\kick, [\amp, 1, \mul, 0.3]);
					wait(1);
					Synth(\snare, [\amp, 1, \mul, 0.2]);
				}).play(t);
			};
			if(~padTrig > 150){
				~padTrig = 1;
			};
			if(~padTrig % 75 == 0){
				Task({
					Synth(\synth, [\freq, ~key[0] * 8, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1),
						\out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait(0.5);
					Synth(\synth, [\freq, ~key.choose * 4, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1), \out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait([0.25, 0.5, 1].choose);
					Synth(\synth, [\freq, ~key[5] * 4, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1),
						\out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait(0.5);
					Synth(\synth, [\freq, ~key.choose * 4, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1), \out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait([0.25, 0.5, 1].choose);
					Synth(\synth, [\freq, ~key[0] * 16, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1),
						\out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait(0.5);
					Synth(\synth, [\freq, ~key.choose * 8, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1), \out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait([0.25, 0.5, 0.125, 0.25].choose);
					Synth(\synth, [\freq, ~key[4] * 4, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1),
						\out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait(0.5);
					Synth(\synth, [\freq, ~key.choose * 16, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1), \out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait([0.25, 0.5].choose);
					Synth(\synth, [\freq, ~key[0] * 8, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1),
						\out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait(0.5);
					Synth(\synth, [\freq, ~key.choose * 4, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1), \out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait([0.25, 0.5, 1].choose);
					Synth(\synth, [\freq, ~key[5] * 4, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1),
						\out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait(0.5);
					Synth(\synth, [\freq, ~key.choose * 4, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1), \out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait([0.25, 0.5].choose);
					Synth(\synth, [\freq, ~key[0] * 16, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1), \out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait(0.5);
					Synth(\synth, [\freq, ~key[4] * 4, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1),
						\out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait(0.5);
					Synth(\synth, [\freq, ~key.choose * 16, \amp, 0.6, \mul, 0.15, \atk, rrand(0.01, 0.1), \dec, rrand(0.1, 1.1), \out, [~kickVerbBus, ~reverbBus, 0].choose]);
					wait([0.25, 0.5, 1].choose);
				}).play(t);
			};
			~padTrig = ~padTrig + 1;

		}, '/synthTrig'));


		(OSCdef(\kickTrig, {

			if(~kickTrig.isNil){
				~kickTrig = 0
			};
			if(~kickTrig % 2 == 0){
				Task({
					Synth(\hat, [\mul, 0.1, \out, [0, ~reverbBus, ~kickVerbBus].choose]);
					wait(0.25);
					Synth(\hat, [\mul, 0.1, \out, [0, ~reverbBus, ~kickVerbBus].choose]);
				}).play(t);
			};

			if(~kickTrig % 3 == 0){
				Task({
					~blingy = true;
					wait(0.5);
					Synth(\snare, [\pan, rrand(-0.7, 0.7), \amp, [0.8, 0.9, 0.95].choose,  \mul, [0.2, 0.25, 0.3, 0.325, 0.4].choose * 0.75, \dec, [0.1, 0.2, 0.4, 0.05].choose, \curve, [-3, -4, 5, 10, 0].choose]);
				}).play(t);
			};
			if(~kickTrig % 48 == 0){
				Task({
					Synth(\synth, [\freq, ~key.choose * 2, \out, [~reverbBus, ~kickVerbBus, 0].choose, \mul, 0.1, \amp, 0.7, \freq, [~key[0], ~key[2], ~key[4]] * ~keyMod, \atk, 0.01, \dec, 0.1]);
					wait(0.125);
					Synth(\synth, [\freq, ~key.choose * 4, \out, [~reverbBus, ~kickVerbBus, 0].choose, \mul, 0.1, \amp, 0.7, \freq, [~key[0], ~key[2], ~key[4]] * ~keyMod * 1.1, \atk, 0.01, \dec, 0.1]);
					wait(0.125);
					Synth(\synth, [\freq, ~key.choose * 2, \out, [~reverbBus, ~kickVerbBus, 0].choose, \mul, 0.1, \amp, 0.7, \freq, [~key[0], ~key[2], ~key[4]] * ~keyMod * 1.1 * 1.1, \atk, 0.01, \dec, 0.1]);
					wait(0.125);
					Synth(\synth, [\freq, ~key.choose * 4, \out, [~reverbBus, ~kickVerbBus, 0].choose, \mul, 0.1, \amp, 0.7, \freq, [~key[0], ~key[2], ~key[4]] * ~keyMod * 1.1 * 1.1 * 1.1, \atk, 0.01, \dec, 0.1]);
				}).play(t);
			};
			~kickTrig = ~kickTrig + 1;
		}, '/kickTrig'));

		(OSCdef(\snareTrig, {

			if(~snareTrig.isNil){
				~snareTrig = 0;
			};
			if(	~snareTrig % 5 == 0){
				Synth(\hat, [\mul, 0.1, \dec, 0.7, \out, ~reverbBus]);
			};
			if(~snareTrig % 8 == 0){
				Task({
					wait(0.5);
					Synth(\kick, [\mul, 0.1, \dec, 0.05]);
					~blingy = true;
				}).play(t);
			};
			if(~snareTrig % 20 == 0){
				Synth(\snare, [\mul, 0.4, \out, ~reverbBus, \dec, [0.1, 0.2, 0.3].choose]);
			};
			~snareTrig = ~snareTrig + 1;
		}, '/snareTrig'));

		(OSCdef(\hatTrig, {
			if(~hatTrig.isNil){
				~hatTrig = 0;
			};
			if(~hatTrig % 50 == 0){
				Task({
					Synth(\synth, [\freq, ~key.choose, \out, [~reverbBus, ~kickVerbBus, 0].choose, \mul, 0.1, \amp, 0.7, \freq, [~key[0], ~key[2], ~key[4]] * ~keyMod, \atk, 0.01, \dec, 0.2]);
					wait(0.125);
					Synth(\synth, [\freq, ~key.choose, \out, [~reverbBus, ~kickVerbBus, 0].choose, \mul, 0.1, \amp, 0.7, \freq, [~key[0], ~key[2], ~key[4]] * ~keyMod * 1.1 * 2, \atk, 0.01, \dec, 0.3]);
					wait(0.125);
					Synth(\synth, [\freq, ~key.choose, \out, [~reverbBus, ~kickVerbBus, 0].choose, \mul, 0.1, \amp, 0.7, \freq, [~key[0], ~key[2], ~key[4]] * ~keyMod * 1.1 * 1.1 * 3, \atk, 0.01, \dec, 0.4]);
					wait(0.125);
					Synth(\synth, [\freq, ~key.choose, \out, [~reverbBus, ~kickVerbBus, 0].choose, \mul, 0.1, \amp, 0.7, \freq, [~key[0], ~key[2], ~key[4]] * ~keyMod * 1.1 * 1.1 * 1.1 * 4, \atk, 0.01, \dec, 0.5]);
					Synth(\synth, [\freq, ~key.choose, \out, [~reverbBus, ~kickVerbBus, 0].choose, \mul, 0.1, \amp, 0.7, \freq, [~key[0], ~key[2], ~key[4]] * ~keyMod * 1.1 * 2, \atk, 0.01, \dec, 0.3]);
					wait(0.125);
					Synth(\synth, [\freq, ~key.choose, \out, [~reverbBus, ~kickVerbBus, 0].choose, \mul, 0.1, \amp, 0.7, \freq, [~key[0], ~key[2], ~key[4]] * ~keyMod * 1.1 * 1.1 * 3, \atk, 0.01, \dec, 0.4]);
					wait(0.125);
					Synth(\synth, [\freq, ~key.choose, \out, [~reverbBus, ~kickVerbBus, 0].choose, \mul, 0.1, \amp, 0.7, \freq, [~key[0], ~key[2], ~key[4]] * ~keyMod * 1.1 * 1.1 * 4, \atk, 0.01, \dec, 0.4]);
					~blingy = true;
				}).play(t);
			};
			if(~hatTrig  % 25 == 0){
				if(~blingy == true){
					Task({
						Synth(\snare, [\pan, rrand(-1.0, 1.0), \amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\pan, rrand(-1.0, 1.0), \amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\pan, rrand(-1.0, 1.0), \amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\pan, rrand(-1.0, 1.0), \amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\pan, rrand(-1.0, 1.0), \amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\pan, rrand(-1.0, 1.0), \amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\pan, rrand(-1.0, 1.0), \amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\pan, rrand(-1.0, 1.0), \amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\pan, rrand(-1.0, 1.0), \amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\pan, rrand(-1.0, 1.0), \amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3]);
						wait(0.025);
						Synth(\snare, [\amp, 0.7, \mul, 0.3, \out, ~kickVerbBus]);
						wait(0.025);
						Synth(\snare, [\pan, rrand(-1.0, 1.0), \amp, 0.7, \mul, 0.3]);
					}).play(t);
				};

			};
			if(~hatTrig % 9 == 0){
				Synth(\kick, [\amp, 1, \mul, 0.1]);
			};
			~hatTrig = ~hatTrig + 1;
			~blingy = false;
		}, '/hatTrig'));


		Tdef(\key).play(t);

		Pdef(\pads).play(t);
		Pdef(\kicks).play(t);
		wait(rrand(20.0, 160.0));
}}).play;
);

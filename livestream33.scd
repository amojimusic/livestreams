



Livestream33.play;


// ^ shortcut to play
// or
(
Livestream33.playSound;
Livestream33.animation;
);

// ^ this

(
Livestream.nInit;
Curt.init;
~kickBus = Bus.audio(s, 2);
~bassBus = Bus.audio(s, 2);
~snareBus = Bus.audio(s, 2);
~synthBus = Bus.audio(s, 2);
);

(Tdef(\track, {
	~osc.();
	loop{

		~tr = rrand(0.9, 1.2);
		~fr = rrand(0.9, 1.2);

		~tonic = [56, 58, 59, 57].choose;
		~di = [12/22, 12/21, 12/20].choose;
		(
			~tuning = [~tonic, ~tonic + ~di, ~tonic + (~di * 2), ~tonic + (~di * 3),
				~tonic + (~di * 4), ~tonic + (~di * 5), ~tonic + (~di * 6), ~tonic + (~di * 7),
				~tonic + (~di * 8), ~tonic + (~di * 9), ~tonic + (~di * 10),
				~tonic + (~di * 11),
				~tonic + (~di * 12), ~tonic + (~di * 13), ~tonic + (~di * 14),
				~tonic + (~di * 15),
				~tonic + (~di * 16), ~tonic + (~di * 17), ~tonic + (~di * 18),
				~tonic + (~di * 19),
				~tonic + (~di * 20), ~tonic + (~di * 21), ~tonic + (~di * 22)].midicps
		);
		(
			~key = [~tuning[0], ~tuning[3], ~tuning[7], ~tuning[10], ~tuning[17]];
		);

		~sec1.();
		wait(50 * ~tr);
		~sec2.();
		wait(50 * ~tr);
		~sec3.();
		wait(25 * ~tr);
		~sec4.();
		wait(25 * ~tr);
		~sec5.();
		wait(25 * ~tr);
		~sec6.();
		wait(25 * ~tr);
		~sec7.();
		wait(50 * ~tr);
		~sec8.();
		wait(25 * ~tr);
}}));


Tdef(\track).play;

(

(~osc = {
	(OSCdef(\bassSig, {
		arg sig;
		~bassSig = sig[3];
	}, '/bassSig'));

	(OSCdef(\bassAmp, {
		arg amp;
		~bassAmp = amp[3];
	}, '/bassAmp'));

	(OSCdef(\bassFreq, {
		arg freq;
		~bassFreq = freq[3];
	}, '/bassFreq' ));

	(OSCdef(\bassEnv, {
		arg env;
		~bassEnv = env[3];
	}, '/bassEnv'));

	(OSCdef(\synthSig, {
		arg sig;
		~synthSig = sig[3];
	}, '/synthSig'));

	(OSCdef(\synthAmp, {
		arg amp;
		~synthAmp = amp[3];
	}, '/synthAmp'));

	(OSCdef(\synthFreq, {
		arg freq;
		~synthFreq = freq[3];
	}, '/synthFreq' ));

	(OSCdef(\synthEnv, {
		arg env;
		~synthEnv = env[3];
	}, '/synthEnv'));

	(OSCdef(\kickSig, {
		arg sig;
		~kickSig = sig[3];
	}, '/kickSig'));

	(OSCdef(\kickAmp, {
		arg amp;
		~kickAmp = amp[3];
	}, '/kickAmp'));

	(OSCdef(\kickEnv, {
		arg env;
		~kickEnv = env[3];
	}, '/kickEnv'));

	(OSCdef(\snareSig, {
		arg sig;
		~snareSig = sig[3];
	}, '/snareSig'));

	(OSCdef(\snareAmp, {
		arg amp;
		~snareAmp = amp[3];
	}, '/snareAmp'));

	(OSCdef(\snareEnv, {
		arg env;
		~snareEnv = env[3];
	}, '/snareEnv'));
};

);

(~sec1 = {

	(SynthDef.new(\bass, {
		var env, mod, sig, freq, amp, send;
		send = Impulse.ar(20);
		env = EnvGen.kr(Env([0, \amp.kr(1), 0], [\atk.kr(0.01), \dec.kr(0.5)]), doneAction: 2);
		freq = \freq.kr(440);
		amp = \amp.kr;
		mod = SinOsc.ar(\freq.kr(440) * \r.kr(0.25), 0, \mmul.kr(1)) * env;
		sig = SinOsc.ar(\freq.kr + (mod * 15), 0, \mul.kr(1));
		sig = sig.blend(Pulse.ar(\freq.kr + (mod * 0.125) * 0.5, (0.4 + (mod * 0.00001)).clip2(0.99), \mul.kr), 0.15);
		sig = sig.blend(Saw.ar(\freq.kr + (mod * 0.1) * [0.5, 1], \mul.kr).sum, 0.15);
		sig = RLPF.ar(sig, \lp.kr(1000) + (LFNoise2.ar(LFNoise2.ar(0.4, 0.5).abs, 3000).abs), \lq.kr(1));
		sig = sig * env;
		sig = sig * 0.5;
		sig = Pan2.ar(sig, \pan.kr(0));
		sig = Clip.ar(sig, -0.5, 0.5);
		SendReply.ar(send, '/bassFreq', freq);
		SendReply.ar(send, '/bassAmp', amp);
		SendReply.ar(send, '/bassEnv', env);
		SendReply.ar(send, '/bassSig', sig.abs);
		Out.ar(\out.kr(0), sig);
	}).add;
	);

	(SynthDef.new(\kick, {
		var env, sig, amp, send;
		send = Impulse.ar(20);
		env = EnvGen.kr(Env([0, \amp.kr(1), 0.45, 0], [\atk.kr, \dec.kr(0.1), 0.02], [4, -1, -4]), doneAction: 2);
		amp = \amp.kr;
		sig = SinOsc.ar([10, 5] + (env * [70, 80]) + (LocalIn.ar * 550), 0, \mul.kr(1)).sum * 0.625;
		sig = sig.blend(SinOsc.ar(20 + (env * 100), 0, \mul.kr), 0.2) * env;
		sig = Clip.ar(sig, env.neg * 1.95, env * 1.95) * env;

		sig = Pan2.ar(sig, \pan.kr(0));
		sig = sig * 0.36;
		sig = RLPF.ar(sig, 30 + (env * 370), 0.235) * 0.9;
		LocalOut.ar(sig.sum);
		sig = Clip.ar(sig, -0.5, 0.5);
		SendReply.ar(send, '/kickAmp', amp);
		SendReply.ar(send, '/kickSig', sig.abs);
		SendReply.ar(send, '/kickEnv', env);
		Out.ar(\out.kr(0), sig);
	}).add;
	);

	(SynthDef.new(\synth, {
		var env, mod, sig, amp, freq, send;
		env = EnvGen.kr(Env([0, \amp.kr(1), 0], [\atk.kr(0.1), \dec.kr(1)]), doneAction: 2);
		freq = \freq.kr(440);
		amp = \amp.kr;
		send = Impulse.ar(20);
		mod = Generate.ar(0, 0.2, 0.9, 0.6, -0.1, -0.4, -1, -0.5, -0.2, 0, freq * \r.kr(1.5)) * \mmul.kr(1);
		sig = Generate.ar(0, 0.3, 1, 0.2, -0.5, -1, -1, -0.4, -0.2, 0, [freq, freq * 0.5] + (mod * 10)).sum * 0.7 * \mul.kr(1);
		sig = sig * env;
		sig = Pan2.ar(sig, \pan.kr(0));
		sig = Clip.ar(sig * 0.3, -0.5, 0.5);
		SendReply.ar(send, '/synthAmp', amp);
		SendReply.ar(send, '/synthFreq', freq);
		SendReply.ar(send, '/synthSig', sig.abs);
		SendReply.ar(send, '/synthEnv', env);
		Out.ar(\out.kr(0), sig);
	}).add;
	);

	(SynthDef.new(\snare, {
		var env, sig, amp, send;
		send = Impulse.ar(20);
		env = EnvGen.kr(Env([0, \amp.kr(1), 0.4, 0], [\atk.kr, \dec.kr(0.1) * LFNoise2.ar(0.2, 1.65).abs, 1.5], [4, -5.5, -4]), doneAction: 2);
		amp = \amp.kr;
		sig = SinOsc.ar(100 + (env * 300) + (LocalIn.ar * 500) + WhiteNoise.ar(2000), 0, \mul.kr(1));
		sig = sig;
		sig = Clip.ar(sig.softclip, env.neg * 0.6, env * 0.7) * env;
		sig = Pan2.ar(sig, \pan.kr(0));
		sig = sig * 0.5;
		sig = RLPF.ar(sig, 300 + (env * 900), 0.735) * 0.9;
		sig = HPF.ar(sig, 300);
		LocalOut.ar(sig.sum);
		sig = Clip.ar(sig, -0.5, 0.5);
		SendReply.ar(send, '/snareEnv', env);
		SendReply.ar(send, '/snareAmp', amp);
		SendReply.ar(send, '/snareSig', sig.abs);
		Out.ar(\out.kr(0), sig);
	}).add;
	);

	(Ndef(\snareFX, {
		var in, del;
		in = In.ar(~snareBus, 2);
		in = FreeVerb.ar(in, 0.025, SinOsc.ar(0.03, 0, 0.4).abs, 0.8);
		del = FreeVerb.ar(in, 1, SinOsc.ar(0.03, 0, 0.4).abs, 0.8);
		del = DelayN.ar(del, 0.15 * ~tr, 0.15 * ~tr);
		in = in.blend(del, 0.35);
		del = DelayN.ar(in, 0.5 * ~tr, 0.5 * ~tr);
		in = in.blend(del, 0.1);

	}));

	(Ndef(\kickFX, {
		var in;
		in = In.ar(~kickBus, 2);
		in = in.blend(in.softclip, 0.1);
		in = FreeVerb.ar(in, 0.157, SinOsc.ar(0.75, 0, 0.18).abs, 0.9);
		in = in.blend(in.softclip, 0.3) * 0.875;
		in = LPF.ar(in, 585).softclip;

	}));

	(Ndef(\bassFX, {
		var in;
		in = In.ar(~bassBus, 2);
		in = in.blend(Splay.ar(FreeVerb.ar(in), 15), 0.7);
	}));

	(Ndef(\synthFX, {
		var in, del;
		in = In.ar(~synthBus, 2);
		in = FreeVerb.ar(in, 0.3, 0.3, 0.3);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.1);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.125);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.1);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.075) * 1.1;
		in = RLPF.ar(in, 9555, 0.8);

	}));



	(Pdef(\bass, Pbind(
		\instrument, \bass,
		\dur, Pseq([0.5, 0.5, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.5, 1, 1], inf) * ~tr,
		\freq, Pseq(~key, inf) * Prand([0.25, 0.25, 0.5, 0.25, 0.5, 1], inf) * ~fr,
		\dec, Pwhite(0.05, [0.1, 0.25, 0.35].choose, inf) * 2.4 * ~tr,
		\amp, 1,
		\mul, 0.68,
		\lp, Pwhite(200, 3000, inf),
		\lq, Pwhite(0.4888, 0.9, inf),
		\mmul, Pwhite(10.0, 40.0, inf),
		\pan, Pwhite(-0.2375, 0.1, inf),
		\r, Pwhite(0.05, 1.0, inf) * Pwhite(0.3, 9.5, inf),
		\out, ~bassBus
	)));

	(SynthDef.new(\kick, {
		var env, sig, amp, send;
		send = Impulse.ar(5);
		env = EnvGen.kr(Env([0, \amp.kr(1), 0.45, 0], [\atk.kr, \dec.kr(0.1), 0.02], [4, -1, -4]), doneAction: 2);
		amp = \amp.kr;
		sig = SinOsc.ar([10, 5] + (env * [70, 80]) + (LocalIn.ar * 550), 0, \mul.kr(1)).sum * 0.625;
		sig = sig.blend(SinOsc.ar(20 + (env * 100), 0, \mul.kr), 0.2) * env;
		sig = Clip.ar(sig, env.neg * 1.95, env * 1.95) * env;

		sig = Pan2.ar(sig, \pan.kr(0));
		sig = sig * 0.36;
		sig = RLPF.ar(sig, 30 + (env * 370), 0.235) * 0.9;
		LocalOut.ar(sig.sum);
		sig = Clip.ar(sig, -0.5, 0.5);
		SendReply.ar(send, '/kickAmp', amp);
		SendReply.ar(send, '/kickSig', sig.abs);
		SendReply.ar(send, '/kickEnv', env);
		Out.ar(\out.kr(0), sig);
	}).add;
	);

	(Pdef(\synths, Pbind(
		\instrument, \synth,
		\dur, Pseq([0.1, 0.1, 0.1, 0.1, 0.1, 4], inf) * ~tr,
		\atk, Pdef([0.5, 0.2, 0.15, 0.05, 0.01, 0.0001], inf),
		\amp, 1,
		\mul, 0.7,
		\dec, 5.2,
		\r, Prand([0.5, 0.25, 1.5, 2.5, 3.5, 4.5], inf),
		\freq, Pseq([~key[0], ~key[2], ~key[4], ~key[2], Prand(~key, 3)], inf) * Prand([2, 4, 4, 8, 8], inf) * ~fr,
		\mmul, Pwhite(0.5, 5.5, inf),
		\pan, Pwhite(-1.0, 1.0, inf),
		\out, ~synthBus

	)));

	(Pdef(\snare, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare], inf),
		\dur, Pseq([2, 0.25, 0.25, 0.5, 0.125, 0.125, 0.125, 0.125, 0.25, 0.25, 1], inf) * ~tr,
		\amp, 2.75,
		\atk, 0.00001,
		\dec, 0.2,
		\pan, Pwhite(-0.2, 0.45, inf),
		\mul, 0.325,
		\out, ~snareBus
	)));

	(Pdef(\snare2, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare], inf),
		\dur, Pseq([5, 2.5/2, 2.5/2, 2.5, 2.5, 2.5, 5, 2.5/2, 2.5/2, 2.5], inf) * ~tr,
		\amp, 5.75,
		\atk, 0.00001,
		\dec, 0.39,
		\pan, 0.15,
		\mul, 0.16,
		\out, ~snareBus
	)));

	(Pdef(\kick, Pbind(
		\instrument, \kick,
		\dur, Pseq([1, 0.5, 0.5, 1, 0.33, 0.33, 0.34, 0.25, 0.25, 0.25, 0.125, 0.125, 0.2, 0.2, 0.2, 0.2, 0.2, 1, 1, 0.33, 0.33, 0.34, 0.25, 0.25, 0.25, 0.125, 0.125, 1, 0.5, 0.5, 1, 0.33, 0.33, 0.34, 0.25, 0.25, 0.25, 0.125, 0.125, 0.2, 0.2, 0.2, 0.2, 0.2, 1, 1, 0.33, 0.33, 0.34, 0.25, 0.25, 0.25, 0.125, 0.125, 1, 0.5, 0.5, 1, 0.33, 0.33, 0.34, 0.25, 0.25, 0.25, 0.125, 0.125], inf) * ~tr,
		\amp, 1.215,
		\dec, 0.225,
		\atk, 0.0000001,
		\mul, 0.6,
		\pan, Pwhite(-0.05, 0.125, inf),
		\out, ~kickBus
	)));

	(Pdef(\hats, Pbind(
		\instrument, Curt.hat2,
		\amp, 1.5,
		\in, Pseq([3500, 3000, 2700], inf),
		\dec, [0.08, 0.1, 0.2, 0.2, 0.25].choose,
		\dur, Pseq([0.25, 0.25, 0.25, 0.25, Pseq([0.4], 5), 0.5, 0.5, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25], inf) * ~tr,
		\mul, Pseq([1.8, 1.7, 1.6, 1.5, 1.6, 1.7], inf) * [0.7, 0.8].choose,
		\pan, 0.25
	)));


	Ndef(\kickFX).play;
	Ndef(\snareFX).play;
	Ndef(\bassFX).play;
	Ndef(\synthFX).play;


	Pdef(\bass).play;
	Pdef(\kick).play;
	Pdef(\snare).play;
	Pdef(\snare2).play;
	Pdef(\hats).play;
	Pdef(\synths).play;

});

(~sec2 = {

	(Ndef(\snareFX, {
		var in, del;
		in = In.ar(~snareBus, 2);
		in = FreeVerb.ar(in, 0.025, SinOsc.ar(0.03, 0, 0.4).abs, 0.8);
		del = FreeVerb.ar(in, 1, SinOsc.ar(0.03, 0, 0.4).abs, 0.8);
		del = DelayN.ar(del, 0.15 * ~tr, 0.15 * ~tr);
		in = in.blend(del, 0.35);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.1);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.07);
	}));

	(Ndef(\kickFX, {
		var in;
		in = In.ar(~kickBus, 2);
		in = in.blend(in.softclip, 0.1);
		in = FreeVerb.ar(in, 0.1, SinOsc.ar(0.75, 0, 0.18).abs, 0.9);
		in = in.blend(in.softclip, 0.3) * 0.875;
		in = LPF.ar(in, 785).softclip;

	}));

	(Ndef(\bassFX, {
		var in;
		in = In.ar(~bassBus, 2);
		in = in.blend(Splay.ar(FreeVerb.ar(in), 15), 0.7);
	}));


	(Pdef(\bass, Pbind(
		\instrument, \bass,
		\dur, Pseq([0.5, 0.5, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.5, 1, 1], inf) * ~tr,
		\freq, Pseq(~key, inf) * Prand([0.25, 0.25, 0.5, 0.25, 0.5, 1], inf) * ~fr,
		\dec, Pwhite(0.05, [0.1, 0.25

		].choose, inf) * 2.4 * ~tr,
		\amp, 1,
		\mul, 0.68,
		\lp, Pwhite(200, 3000, inf),
		\lq, Pwhite(0.4888, 0.9, inf),
		\mmul, Pwhite(10.0, 35.0, inf),
		\pan, Pwhite(-0.2375, 0.1, inf),
		\r, Pwhite(0.025, 1.25, inf) * Pwhite(0.3, 9.5, inf),
		\out, ~bassBus
	)));

	(Pdef(\synths, Pbind(
		\instrument, \synth,
		\dur, Pseq([1, 0.25, 0.125, 0.125, 0.125, 0.125, 0.25, 3], inf) * ~tr,
		\atk, Pdef([0.5, 0.2, 0.15, 0.05, 0.01, 0.0001], inf),
		\amp, 1,
		\mul, 0.7,
		\dec, 5.2,
		\r, Prand([0.5, 0.25, 1.5, 2.5, 3.5, 4.5], inf),
		\pan, Pwhite(-1.0, 1.0, inf),
		\freq, Pseq([~key[0], ~key[2], ~key[4], ~key[2], Prand(~key, 3)], inf) * Prand([2, 4, 8, 8, 8], inf) * ~fr,
		\mmul, Pwhite(0.5, 5.5, inf),
		\out, ~synthBus

	)));

	(Pdef(\kick, Pbind(
		\instrument, \kick,
		\dur, Pseq([1, 0.5, 0.5, 1, 0.33, 0.33, 0.34, 0.25, 0.25, 0.25, 0.125, 0.125, 0.2, 0.2, 0.2, 0.2, 0.2, 1, 1, 0.33, 0.33, 0.34, 0.25, 0.25, 0.25, 0.125, 0.125, 1, 0.5, 0.5, 1, 0.33, 0.33, 0.34, 0.25, 0.25, 0.25, 0.125, 0.125, 0.2, 0.2, 0.2, 0.2, 0.2, 1, 1, 0.33, 0.33, 0.34, 0.25, 0.25, 0.25, 0.125, 0.125, 1, 0.5, 0.5, 1, 0.33, 0.33, 0.34, 0.25, 0.25, 0.25, 0.125, 0.125], inf) * ~tr,
		\amp, 1.215,
		\dec, 0.225,
		\atk, 0.0000001,
		\mul, 0.6,
		\pan, Pwhite(-0.05, 0.125, inf),
		\out, ~kickBus
	)));

	(Pdef(\snare, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare], inf),
		\dur, Pseq([0.5, 0.25, 0.25], inf) * ~tr,
		\amp, 2.95,
		\atk, 0.00001,
		\dec, 0.2,
		\pan, Pwhite(-0.2, 0.45, inf),
		\mul, 0.4,
		\out, ~snareBus
	)));

	(Pdef(\snare2, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare], inf),
		\dur, Pseq([5, 2.5/2, 2.5/2, 2.5, 2.5, 2.5, 5, 2.5/2, 2.5/2, 2.5], inf) * ~tr,
		\amp, 5.75,
		\atk, 0.00001,
		\dec, 0.39,
		\pan, 0.15,
		\mul, 0.16,
		\out, ~snareBus
	)));

	(Pdef(\hats, Pbind(
		\instrument, Curt.hat2,
		\amp, 1.5,
		\in, Pseq([3500, 3000, 2700], inf),
		\dec, [0.08, 0.1, 0.2, 0.2, 0.25].choose,
		\dur, Pseq([0.25, 0.25, 0.25, 0.25, Pseq([0.4], 5), 0.5, 0.5, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25], inf) * ~tr,
		\mul, Pseq([1.8, 1.7, 1.6, 1.5, 1.6, 1.7], inf) * [0.7, 0.8].choose,
		\pan, 0.25
	)));


	Pdef(\bass).play;
	Pdef(\kick).play;
	Pdef(\snare).play;
	Pdef(\snare2).play;
	Pdef(\hats).play;

});


(~sec3 = {

	(Ndef(\synthFX, {
		var in, del;
		in = In.ar(~synthBus, 2);
		in = FreeVerb.ar(in, 0.3, 0.3, 0.3);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.1);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.125);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.1);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.075) * 1.1;
		in = RLPF.ar(in, 9555, 0.8);
		in = FreeVerb.ar(in, 0.3, 0.4, 0.8);

	}));

	(Ndef(\snareFX, {
		var in, del;
		in = In.ar(~snareBus, 2);
		in = FreeVerb.ar(in, 0.025, SinOsc.ar(0.03, 0, 0.4).abs, 0.8);
		del = FreeVerb.ar(in, 1, SinOsc.ar(0.03, 0, 0.4).abs, 0.8);
		del = DelayN.ar(del, 0.15 * ~tr, 0.15 * ~tr);
		in = in.blend(del, 0.35);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.1);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.07);
	}));

	(Ndef(\kickFX, {
		var in;
		in = In.ar(~kickBus, 2);
		in = in.blend(in.softclip, 0.1);
		in = FreeVerb.ar(in, 0.1, SinOsc.ar(0.75, 0, 0.18).abs, 0.9);
		in = in.blend(in.softclip, 0.3) * 0.875;
		in = LPF.ar(in, 785).softclip;

	}));

	(Ndef(\bassFX, {
		var in;
		in = In.ar(~bassBus, 2);
		in = in.blend(Splay.ar(FreeVerb.ar(in), 15), 0.7);
	}));


	(Pdef(\bass, Pbind(
		\instrument, \bass,
		\dur, Pseq([1, 0.25, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.5, 1, 1], inf) * ~tr,
		\freq, Pseq(~key, inf) * Prand([0.25, 0.25, 0.5, 0.25, 0.5, 1], inf) * ~fr,
		\dec, Pwhite(0.05, [0.1, 0.25, 0.35].choose, inf) * 2.4 * ~tr,
		\amp, 1,
		\mul, 0.68,
		\lp, Pwhite(200, 3000, inf),
		\lq, Pwhite(0.4888, 0.9, inf),
		\mmul, Pwhite(10.0, 35.0, inf),
		\pan, Pwhite(-0.2375, 0.1, inf),
		\r, Pwhite(0.05, 2.5, inf) * Pwhite(0.3, 9.5, inf),
		\out, ~bassBus
	)));

	(Pdef(\kick, Pbind(
		\instrument, \kick,
		\dur, Pseq([0.2, 0.2, 0.2, 0.2, 0.2, 0.5, 0.5, 1, 0.33, 0.33, 0.34, 0.25, 0.25, 0.25, 0.125, 0.125], inf) * ~tr,
		\amp, 1.215,
		\dec, 0.225,
		\atk, 0.0000001,
		\mul, 0.6,
		\pan, Pwhite(-0.05, 0.125, inf),
		\out, ~kickBus
	)));

	(Pdef(\snare, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare], inf),
		\dur, Pseq([0.5, 0.25, 0.25], inf) * ~tr,
		\amp, 2.95,
		\atk, 0.00001,
		\dec, 0.2,
		\pan, Pwhite(-0.2, 0.45, inf),
		\mul, 0.4,
		\out, ~snareBus
	)));

	(Pdef(\snare2, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare], inf),
		\dur, Pseq([5, 2.5/2, 2.5/2, 2.5, 2.5, 2.5, 5, 2.5/2, 2.5/2, 2.5], inf) * ~tr,
		\amp, 5.75,
		\atk, 0.00001,
		\dec, 0.39,
		\pan, 0.15,
		\mul, 0.16,
		\out, ~snareBus
	)));

	(Pdef(\hats, Pbind(
		\instrument, Curt.hat2,
		\amp, 1.5,
		\in, Pseq([3500, 3000, 2700], inf),
		\dec, [0.08, 0.1, 0.2, 0.2, 0.25].choose,
		\dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.25, 0.125, 0.125, 1, 1, 0.5, 0.5], inf) * ~tr * 2,
		\mul, Pseq([1.8, 1.7, 1.6, 1.5, 1.6, 1.7], inf) * [0.7, 0.8].choose,
		\pan, 0.25
	)));


	Pdef(\bass).play;
	Pdef(\kick).play;
	Pdef(\snare).play;
	Pdef(\snare2).play;
	Pdef(\hats).play;

});


(~sec4 = {

	(Ndef(\snareFX, {
		var in, del;
		in = In.ar(~snareBus, 2);
		in = FreeVerb.ar(in, 0.025, SinOsc.ar(0.03, 0, 0.4).abs, 0.8);
		del = FreeVerb.ar(in, 1, SinOsc.ar(0.03, 0, 0.4).abs, 0.8);
		del = DelayN.ar(del, 0.15 * ~tr, 0.15 * ~tr);
		in = in.blend(del, 0.35);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.1);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.07);
	}));

	(Ndef(\kickFX, {
		var in;
		in = In.ar(~kickBus, 2);
		in = in.blend(in.softclip, 0.1);
		in = FreeVerb.ar(in, 0.1, SinOsc.ar(0.75, 0, 0.18).abs, 0.9);
		in = in.blend(in.softclip, 0.3) * 0.875;
		in = LPF.ar(in, 785).softclip;

	}));

	(Ndef(\bassFX, {
		var in;
		in = In.ar(~bassBus, 2);
		in = in.blend(Splay.ar(FreeVerb.ar(in), 11), 0.7);
	}));


	(Pdef(\bass, Pbind(
		\instrument, \bass,
		\dur, Pseq([1, 1, 1, 0.5, 0.5, 1], inf) * ~tr,
		\freq, Prand(~tuning, inf) * Prand([0.25, 0.25, 0.5, 0.25, 0.5, 1], inf) * ~fr,
		\dec, Pseq([0.5, 0.5, 0.8, 1, 0.3, 0.3, 1], inf) * 2.4 * ~tr,
		\amp, 1,
		\mul, 0.68,
		\lp, Pwhite(200, 3000, inf),
		\lq, Pwhite(0.4888, 0.9, inf),
		\mmul, Pwhite(1.0, 15.0, inf),
		\pan, Pwhite(-0.2375, 0.1, inf),
		\r, Pwhite(0.125, 0.2, inf) * Pwhite(0.3, 9.5, inf),
		\out, ~bassBus
	)));

	(Pdef(\synths, Pbind(
		\instrument, \synth,
		\dur, Pseq([0.1, 0.1, 0.1, 0.1, 0.1, 4], inf) * ~tr,
		\atk, Pdef([0.5, 0.2, 0.15, 0.05, 0.01, 0.0001], inf),
		\amp, 1,
		\mul, 0.7,
		\dec, 5.2,
		\r, Prand([0.5, 0.25, 1.5, 2.5, 3.5, 4.5], inf),
		\freq, Pseq([~key[0], ~key[2], ~key[4], ~key[2], Prand(~key, 3)], inf) * Prand([2, 4, 4, 8, 8], inf) * ~fr,
		\mmul, Pwhite(0.5, 5.5, inf),
		\pan, Pwhite(-1.0, 1.0, inf),
		\out, ~synthBus

	)));

	(Pdef(\kick, Pbind(
		\instrument, \kick,
		\dur, Pseq([1, 1, 1, 0.33, 0.33, 0.34, 0.25, 0.25, 0.25, 0.125, 0.125], inf) * ~tr,
		\amp, 1.215,
		\dec, 0.225,
		\atk, 0.0000001,
		\mul, 0.6,
		\pan, Pwhite(-0.05, 0.125, inf),
		\out, ~kickBus
	)));

	(Pdef(\snare, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare], inf),
		\dur, Pseq([0.5, 0.25, 0.25], inf) * ~tr,
		\amp, 2.95,
		\atk, 0.00001,
		\dec, 0.2,
		\pan, Pwhite(-0.2, 0.45, inf),
		\mul, 0.4,
		\out, ~snareBus
	)));

	(Pdef(\snare2, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare], inf),
		\dur, Pseq([5, 2.5/2, 2.5/2, 2.5, 2.5, 2.5], inf) * ~tr,
		\amp, 5.75,
		\atk, 0.00001,
		\dec, 0.39,
		\pan, 0.15,
		\mul, 0.16,
		\out, ~snareBus
	)));

	(Pdef(\hats, Pbind(
		\instrument, Curt.hat2,
		\amp, 1.5,
		\in, Pseq([3500, 3000, 2700], inf),
		\dec, [0.08, 0.1, 0.2, 0.2, 0.25].choose,
		\dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.25, 0.125, 0.125, 1, 1, 0.5, 0.5], inf) * ~tr,
		\mul, Pseq([1.8, 1.7, 1.6, 1.5, 1.6, 1.7], inf) * [0.7, 0.8].choose,
		\pan, 0.25
	)));


	Pdef(\bass).play;
	Pdef(\kick).play;
	Pdef(\snare).play;
	Pdef(\snare2).play;
	Pdef(\hats).stop;

});

(~sec5 = {

	(Ndef(\snareFX, {
		var in, del;
		in = In.ar(~snareBus, 2);
		in = FreeVerb.ar(in, 0.025, SinOsc.ar(0.03, 0, 0.4).abs, 0.8);
		del = FreeVerb.ar(in, 1, SinOsc.ar(0.03, 0, 0.4).abs, 0.8);
		del = DelayN.ar(del, 0.15 * ~tr, 0.15 * ~tr);
		in = in.blend(del, 0.35);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.1);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.07);
	}));

	(Ndef(\kickFX, {
		var in;
		in = In.ar(~kickBus, 2);
		in = in.blend(in.softclip, 0.1);
		in = FreeVerb.ar(in, 0.3, SinOsc.ar(0.75, 0, 0.28).abs, 0.9);
		in = in.blend(in.softclip, 0.3) * 0.875;
		in = LPF.ar(in, 785).softclip;

	}));

	(Ndef(\bassFX, {
		var in;
		in = In.ar(~bassBus, 2);
		in = in.blend(Splay.ar(FreeVerb.ar(in), 11), 0.7);
	}));


	(Pdef(\bass, Pbind(
		\instrument, \bass,
		\dur, Pseq([1, 1, 1, 0.5, 0.5, 1], inf) * ~tr,
		\freq, Prand(~tuning, inf) * Prand([0.25, 0.25, 0.5, 0.25, 0.5, 1], inf) * ~fr,
		\dec, Pseq([0.5, 0.5, 0.8, 1, 0.3, 0.3, 1], inf) * 2.4 * ~tr,
		\amp, 1,
		\mul, 0.68,
		\lp, Pwhite(200, 3000, inf),
		\lq, Pwhite(0.4888, 0.9, inf),
		\mmul, Pwhite(1.0, 15.0, inf),
		\pan, Pwhite(-0.2375, 0.1, inf),
		\r, Pwhite(0.125, 0.2, inf) * Pwhite(0.3, 9.5, inf),
		\out, ~bassBus
	)));

	(Pdef(\kick, Pbind(
		\instrument, \kick,
		\dur, Pseq([1, 1, 1, 0.33, 0.33, 0.34, 0.5, 0.5], inf) * ~tr,
		\amp, 1.215,
		\dec, 0.225,
		\atk, 0.0000001,
		\mul, 0.6,
		\pan, Pwhite(-0.05, 0.125, inf),
		\out, ~kickBus
	)));

	(Pdef(\snare, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare], inf),
		\dur, Pseq([0.5, 0.25, 0.25], inf) * ~tr,
		\amp, 2.95,
		\atk, 0.00001,
		\dec, 0.2,
		\pan, Pwhite(-0.2, 0.45, inf),
		\mul, 0.4,
		\out, ~snareBus
	)));

	(Pdef(\snare2, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare], inf),
		\dur, Pseq([5, 2.5/2, 2.5/2, 2.5, 2.5, 2.5], inf) * ~tr,
		\amp, 5.75,
		\atk, 0.00001,
		\dec, 0.39,
		\pan, 0.15,
		\mul, 0.16,
		\out, ~snareBus
	)));

	(Pdef(\hats, Pbind(
		\instrument, Curt.hat2,
		\amp, 1.5,
		\in, Pseq([3500, 3000, 2700], inf),
		\dec, [0.08, 0.1, 0.2, 0.2, 0.25].choose,
		\dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.25, 0.125, 0.125, 1, 1, 0.5, 0.5], inf) * ~tr,
		\mul, Pseq([1.8, 1.7, 1.6, 1.5, 1.6, 1.7], inf) * [0.7, 0.8].choose,
		\pan, 0.25
	)));




	Pdef(\bass).play;
	Pdef(\kick).play;
	Pdef(\snare).play;
	Pdef(\snare2).play;
	Pdef(\hats).stop;

});

(~sec6 = {

	(Ndef(\snareFX, {
		var in, del;
		in = In.ar(~snareBus, 2);
		in = FreeVerb.ar(in, 0.025, SinOsc.ar(0.03, 0, 0.4).abs, 0.8);
		del = FreeVerb.ar(in, 1, SinOsc.ar(0.03, 0, 0.4).abs, 0.8);
		del = DelayN.ar(del, 0.15 * ~tr, 0.15 * ~tr);
		in = in.blend(del, 0.35);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.1);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.07);
	}));

	(Ndef(\kickFX, {
		var in;
		in = In.ar(~kickBus, 2);
		in = in.blend(in.softclip, 0.1);
		in = FreeVerb.ar(in, 0.6, 0.9, 0.9);
		in = in.blend(in.softclip, 0.3) * 0.875;
		in = LPF.ar(in, 1785).softclip;

	}));

	(Ndef(\bassFX, {
		var in;
		in = In.ar(~bassBus, 2);
		in = in.blend(Splay.ar(FreeVerb.ar(in), 11), 0.7);
	}));


	(Pdef(\bass, Pbind(
		\instrument, \bass,
		\dur, Pseq([1, 1, 1, 0.5, 0.5, 1], inf) * ~tr,
		\freq, Pseq([~tuning[0], ~tuning[0], ~tuning[2], ~tuning[1], ~tuning[4], ~tuning[0], ~tuning[3], ~tuning[2]], inf) * Prand([0.25, 0.25, 0.5, 0.25, 0.5, 1], inf) * ~fr,
		\dec, Pseq([0.5, 0.5, 0.8, 1, 0.3, 0.3, 1], inf) * 2.4 * ~tr,
		\amp, 1,
		\mul, 0.68,
		\lp, Pwhite(200, 3000, inf),
		\lq, Pwhite(0.4888, 0.9, inf),
		\mmul, Pwhite(1.0, 15.0, inf),
		\pan, Pwhite(-0.2375, 0.1, inf),
		\r, Pwhite(0.125, 0.2, inf) * Pwhite(0.3, 9.5, inf),
		\out, ~bassBus
	)));

	(Pdef(\kick, Pbind(
		\instrument, \kick,
		\dur, Pseq([1, 0.5, 0.5, 1, 1, 1, 2, 2, 1, 2, 3, 3, 2, 5], inf) * ~tr,
		\amp, 1.215,
		\dec, 0.425,
		\atk, 0.0000001,
		\mul, 0.6,
		\pan, Pwhite(-0.05, 0.125, inf),
		\out, ~kickBus
	)));

	(Pdef(\snare, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare], inf),
		\dur, Pseq([0.5, 0.25, 0.25], inf) * ~tr,
		\amp, 2.95,
		\atk, 0.00001,
		\dec, 0.2,
		\pan, Pwhite(-0.2, 0.45, inf),
		\mul, 0.4,
		\out, ~snareBus
	)));

	(Pdef(\snare2, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare, \snare, \snare], inf),
		\dur, Pseq([5, 2.5/2, 2.5/2, 2.5, 2.5, 2.5], inf) * ~tr * 0.5,
		\amp, 5.75,
		\atk, 0.00001,
		\dec, 0.39,
		\pan, 0.15,
		\mul, 0.16,
		\out, ~snareBus
	)));

	(Pdef(\hats, Pbind(
		\instrument, Curt.hat2,
		\amp, 1.5,
		\in, Pseq([3500, 3000, 2700], inf),
		\dec, [0.08, 0.1, 0.2, 0.2, 0.25].choose,
		\dur, Pseq([0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.125, 0.125], inf) * ~tr,
		\mul, Pseq([1.8, 1.7, 1.6, 1.5, 1.6, 1.7], inf) * [0.7, 0.8].choose,
		\pan, 0.25
	)));




	Pdef(\bass).play;
	Pdef(\kick).play;
	Pdef(\snare).play;
	Pdef(\snare2).play;
	Pdef(\hats).play;

});

(~sec7 = {

	(Ndef(\synthFX, {
		var in, del;
		in = In.ar(~synthBus, 2);
		in = FreeVerb.ar(in, 0.3, 0.3, 0.3);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.1);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.125);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.1);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.075) * 1.1;
		in = RLPF.ar(in, 9555, 0.8);
		in = FreeVerb.ar(in, 0.6, 0.7, 0.7) * 1.2;

	}));


	(Ndef(\snareFX, {
		var in, del;
		in = In.ar(~snareBus, 2);
		in = FreeVerb.ar(in, 0.5, 1, 0.8);
		del = FreeVerb.ar(in, 1, 1, 0.9);
		del = DelayN.ar(del, 0.15 * ~tr, 0.15 * ~tr);
		in = in.blend(del, 0.35);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.1);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.07);
	}));

	(Ndef(\kickFX, {
		var in;
		in = In.ar(~kickBus, 2);
		in = in.blend(in.softclip, 0.1);
		in = FreeVerb.ar(in, 0.6, 0.9, 0.9);
		in = in.blend(in.softclip, 0.3) * 0.875;
		in = LPF.ar(in, 1785).softclip;

	}));

	(Ndef(\bassFX, {
		var in;
		in = In.ar(~bassBus, 2);
		in = in.blend(Splay.ar(FreeVerb.ar(in), 11), 0.7);
	}));


	(Pdef(\bass, Pbind(
		\instrument, \bass,
		\dur, Pseq([1, 1, 1, 0.5, 0.5, 1], inf) * ~tr,
		\freq, Pseq([~tuning[0], ~tuning[0], ~tuning[2], ~tuning[1], ~tuning[4], ~tuning[0], ~tuning[3], ~tuning[2]], inf) * Prand([0.25, 0.25, 0.5, 0.25, 0.5, 1], inf) * ~fr,
		\dec, Pseq([0.5, 0.5, 0.8, 1, 0.3, 0.3, 1], inf) * 2.4 * ~tr,
		\amp, 1,
		\mul, 0.68,
		\lp, Pwhite(200, 3000, inf),
		\lq, Pwhite(0.4888, 0.9, inf),
		\mmul, Pwhite(1.0, 15.0, inf),
		\pan, Pwhite(-0.2375, 0.1, inf),
		\r, Pwhite(0.125, 0.2, inf) * Pwhite(0.3, 9.5, inf),
		\out, ~bassBus
	)));

	(Pdef(\kick, Pbind(
		\instrument, \kick,
		\dur, Pseq([1, 0.5, 0.5, 1, 1, 1, 2, 2, 1, 2, 3, 3, 2, 5], inf) * ~tr,
		\amp, 1.215,
		\dec, 0.425,
		\atk, 0.0000001,
		\mul, 0.6,
		\pan, Pwhite(-0.05, 0.125, inf),
		\out, ~kickBus
	)));

	(Pdef(\snare, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare], inf),
		\dur, 1 * ~tr,
		\amp, 2.95,
		\atk, 0.00001,
		\dec, 0.2,
		\pan, Pwhite(-0.2, 0.45, inf),
		\mul, 0.4,
		\out, ~snareBus
	)));

	(Pdef(\snare2, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare, \snare, \snare], inf),
		\dur, Pseq([5, 2.5/2, 2.5/2, 2.5, 2.5, 2.5], inf) * ~tr * 0.5,
		\amp, 5.75,
		\atk, 0.00001,
		\dec, 0.39,
		\pan, 0.15,
		\mul, 0.16,
		\out, ~snareBus
	)));

	(Pdef(\hats, Pbind(
		\instrument, Curt.hat2,
		\amp, 1.5,
		\in, Pseq([3500, 3000, 2700], inf),
		\dec, [0.08, 0.1, 0.2, 0.2, 0.25].choose,
		\dur, Pseq([0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.125, 0.125], inf) * ~tr,
		\mul, Pseq([1.8, 1.7, 1.6, 1.5, 1.6, 1.7], inf) * [0.7, 0.8].choose,
		\pan, 0.25,
		\out, ~snareBus
	)));


	Pdef(\bass).play;
	Pdef(\kick).play;
	Pdef(\snare).play;
	Pdef(\snare2).stop;
	Pdef(\hats).play;

});

(~sec8 = {

	(Ndef(\synthFX, {
		var in, del;
		in = In.ar(~synthBus, 2);
		in = FreeVerb.ar(in, 0.3, 0.3, 0.3);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.1);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.125);
		in = RLPF.ar(in, 9555, 0.8);
		in = FreeVerb.ar(in, 0.8, 0.9, 0.5) * 1.2;

	}));


	(Ndef(\snareFX, {
		var in, del;
		in = In.ar(~snareBus, 2);
		in = FreeVerb.ar(in, 0.5, 1, 0.8);
		del = FreeVerb.ar(in, 1, 1, 0.9);
		del = DelayN.ar(del, 0.15 * ~tr, 0.15 * ~tr);
		in = in.blend(del, 0.35);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.1);
		del = DelayN.ar(in, 0.25 * ~tr, 0.25 * ~tr);
		in = in.blend(del, 0.07);
	}));

	(Ndef(\kickFX, {
		var in;
		in = In.ar(~kickBus, 2);
		in = in.blend(in.softclip, 0.1);
		in = FreeVerb.ar(in, 0.6, 0.9, 0.9);
		in = in.blend(in.softclip, 0.3) * 0.875;
		in = LPF.ar(in, 1785).softclip;

	}));

	(Ndef(\bassFX, {
		var in;
		in = In.ar(~bassBus, 2);
		in = in.blend(Splay.ar(FreeVerb.ar(in), 11), 0.7);
	}));


	(Pdef(\bass, Pbind(
		\instrument, \bass,
		\dur, Pseq([1, 1, 1, 0.5, 0.5, 1], inf) * ~tr,
		\freq, Pseq([~tuning[0], ~tuning[0], ~tuning[2], ~tuning[1], ~tuning[4], ~tuning[0], ~tuning[3], ~tuning[2]], inf) * Prand([0.25, 0.25, 0.5, 0.25, 0.5, 1], inf) * ~fr,
		\dec, Pseq([0.5, 0.5, 0.8, 1, 0.3, 0.3, 1], inf) * 4.4 * ~tr,
		\amp, 1,
		\mul, 0.68,
		\lp, Pwhite(200, 3000, inf),
		\lq, Pwhite(0.4888, 0.9, inf),
		\mmul, Pwhite(1.0, 45.0, inf),
		\pan, Pwhite(-0.2375, 0.1, inf),
		\r, Pwhite(0.025, 0.2, inf) * Pwhite(0.3, 9.5, inf),
		\out, ~bassBus
	)));

	(Pdef(\kick, Pbind(
		\instrument, \kick,
		\dur, Pseq([1, 0.5, 0.5, 1, 1, 1, 2, 2, 1, 2, 3, 3, 2, 5], inf) * ~tr,
		\amp, 1.215,
		\dec, 0.425,
		\atk, 0.0000001,
		\mul, 0.6,
		\pan, Pwhite(-0.05, 0.125, inf),
		\out, ~kickBus
	)));

	(Pdef(\snare, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare], inf),
		\dur, 1 * ~tr,
		\amp, 2.95,
		\atk, 0.00001,
		\dec, 0.2,
		\pan, Pwhite(-0.2, 0.45, inf),
		\mul, 0.4,
		\out, ~snareBus
	)));

	(Pdef(\snare2, Pbind(
		\instrument, Pseq([\rest, \snare, \snare, \snare, \snare, \snare, \snare], inf),
		\dur, Pseq([5, 2.5/2, 2.5/2, 2.5, 2.5, 2.5], inf) * ~tr * 0.5,
		\amp, 5.75,
		\atk, 0.00001,
		\dec, 0.39,
		\pan, 0.15,
		\mul, 0.16,
		\out, ~snareBus
	)));

	(Pdef(\synths, Pbind(
		\instrument, \synth,
		\dur, Pseq([1, 0.25, 0.125, 0.125, 0.125, 0.125, 0.25, 3], inf) * ~tr,
		\atk, Pdef([0.5, 0.2, 0.15, 0.05, 0.01, 0.0001], inf),
		\amp, 1,
		\mul, 0.7,
		\dec, 3,
		\r, Prand([0.5, 0.25, 1.5, 2.5, 3.5, 4.5], inf),
		\pan, Pwhite(-1.0, 1.0, inf),
		\freq, Pseq([~key[0], ~key[2], ~key[4], ~key[2], Prand(~key, 3)], inf) * Prand([2, 4, 8, 8, 8], inf) * ~fr,
		\mmul, Pwhite(0.5, 5.5, inf),
		\out, ~synthBus

	)));

	(Pdef(\hats, Pbind(
		\instrument, Curt.hat2,
		\amp, 1.5,
		\in, Pseq([3500, 3000, 2700], inf),
		\dec, [0.08, 0.1, 0.2, 0.2, 0.25].choose,
		\dur, Pseq([0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.125, 0.125], inf) * ~tr,
		\mul, Pseq([1.8, 1.7, 1.6, 1.5, 1.6, 1.7], inf) * [0.7, 0.8].choose,
		\pan, 0.25
	)));




	Pdef(\bass).play;
	Pdef(\kick).play;
	Pdef(\snare).stop;
	Pdef(\snare2).stop;
	Pdef(\hats).stop;

});

);





(
Window.closeAll;
~w = Window("animation", Rect(700, 80, 400, 400)).front.alwaysOnTop = true;

~u = UserView(~w, Rect(0, 0, 400, 400)).background = Color.black;

~u.drawFunc_({



	Pen.strokeColor_(Color(0.5, (3 * ~snareSig).clip2(0.99), (~bassSig * 3).clip2(0.99)));
	Pen.fillColor_(Color((3 * ~bassSig).clip2(0.99), (~kickSig * 5).clip2(0.99), 0.5));
	Pen.width_(2 + (~snareSig * 50));
	Pen.moveTo((165 + (~kickSig * 500)).clip2(200)@(180 - (~bassSig * 300)).clip2(350));
	Pen.lineTo((235 - (~snareSig * 2500).clip2(100))@(180 + (~synthSig * 350)).clip2(350));
	Pen.lineTo((175 + (~synthSig * 1000).clip2(300))@(230 - (~kickSig * 1500).clip2(300)));
	Pen.lineTo((200 - (~bassSig * 100)).clip2(350)@(152.5 - (~snareSig * 500).clip2(350)));
	Pen.lineTo((225 - (~synthSig * 800)).clip2(225)@(230 - (~synthSig * 500)).clip2(400));
	Pen.lineTo((165 + (~kickSig * 500)).clip2(200)@(180 - (~bassSig * 300)).clip2(350));

	Pen.fillStroke;

	Pen.strokeColor_(Color(~bassSig.clip2(0.99), (~bassFreq * 0.0025).clip2(0.99), ~bassAmp.clip2(0.99)));
	Pen.fillColor_(Color(~bassEnv.clip2(0.99), (~kickSig * 0.5).clip2(0.99), (~synthFreq * 0.0025).clip2(0.99)));
	Pen.width_(~bassSig * 50);

	Pen.moveTo((80 + (~bassEnv * 10)).clip2(110)@(280 + (~bassSig * 100)).clip2(320));
	Pen.lineTo((120 - (~bassFreq * 0.07))@(280 + (~bassEnv * 80)).clip2(320));
	Pen.lineTo((120 - (~bassAmp * 40))@(320 - (~bassSig * 200)));
	Pen.lineTo((80 + (~bassSig * 100)).clip2(120)@(320 - (~bassAmp * 20)));
	Pen.lineTo((80 + (~bassEnv * 10)).clip2(110)@(280 + (~bassSig * 100)).clip2(320));
	Pen.fillStroke;

	Pen.strokeColor_(Color(0.2, ~synthSig.clip2(0.99), (~synthFreq * 0.00005).clip2(0.99)));
	Pen.fillColor_(Color(~synthEnv.clip2(0.99), ~synthAmp.clip2(0.99), (~kickSig * 0.5).clip2(0.99)));

	Pen.width_(~synthSig * 60);

	Pen.moveTo((80 + (~synthEnv * 10)).clip2(110)@(80 + (~synthSig * 100)).clip2(320));
	Pen.lineTo((120 - (~synthFreq * 0.0035))@(80 + (~synthEnv * 80)).clip2(320));
	Pen.lineTo((120 - (~synthAmp * 40))@(120 - (~synthSig * 200)));
	Pen.lineTo((80 + (~synthSig * 100)).clip2(120)@(120 - (~synthAmp * 20)));
	Pen.lineTo((80 + (~synthEnv * 10)).clip2(110)@(80 + (~synthSig * 100)).clip2(320));
	Pen.fillStroke;

	Pen.strokeColor_(Color((~kickAmp * 0.3).clip2(0.99), (~kickSig * 2).clip2(0.99), (~kickEnv).clip2(0.99)));
	Pen.fillColor_(Color((~kickAmp * 0.2).clip2(0.99), ~kickSig.clip2(0.99), (~synthFreq * 0.00025).clip2(0.99)));
	Pen.width_(~kickSig * 100);

	Pen.moveTo((280 + (~kickEnv * 10)).clip2(320)@(80 + (~kickAmp * 100)).clip2(320));
	Pen.lineTo((320 - (~kickSig * 0.0035))@(80 + (~kickEnv * 80)).clip2(320));
	Pen.lineTo((320 - (~kickAmp * 40))@(120 - (~kickSig * 200)));
	Pen.lineTo((280 + (~kickEnv * 100)).clip2(320)@(120 - (~kickAmp * 20)));
	Pen.lineTo((280 + (~kickEnv * 10)).clip2(320)@(80 + (~kickAmp * 100)).clip2(320));
	Pen.fillStroke;

	Pen.strokeColor_(Color((~snareEnv * 0.9).clip2(0.99), (~snareSig * 2).clip2(0.99), (~snareAmp * 0.4).clip2(0.99)));
	Pen.fillColor_(Color((~snareEnv * 0.3).clip2(0.99), (~snareAmp * 0.8).clip2(0.99), (~bassFreq * 0.01).clip2(0.99)));
	Pen.width_(~snareSig * 30);

	Pen.moveTo((280 + (~snareEnv * 10)).clip2(320)@(280 + (~snareAmp * 50)).clip2(320));
	Pen.lineTo((320 - (~snareSig * 0.0035))@(280 + (~snareEnv * 80)).clip2(320));
	Pen.lineTo((320 - (~snareAmp * 10))@(320 - (~snareSig * 50)));
	Pen.lineTo((280 + (~kickEnv * 100)).clip2(320)@(320 - (~snareAmp * 20)));
	Pen.lineTo((280 + (~snareEnv * 10)).clip2(320)@(280 + (~snareAmp * 50)).clip2(320));
	Pen.fillStroke;



});

~u.frameRate = 13;
~u.animate_(true);


);





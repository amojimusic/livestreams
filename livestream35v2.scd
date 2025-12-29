



Livestream35.play;



s.scope.view.alwaysOnTop = true;






(


Livestream35.nInit;


if(~busMade35.isNil){
	~delayBus = Bus.audio(s, 2);
	~reverbBus = Bus.audio(s, 2);
	~bassBus = Bus.audio(s, 2);
	~synthBus = Bus.audio(s, 2);
	~drumBus = Bus.audio(s, 2);

};

~tonic = 51;
~di = 12/23;
~edo23 = [~tonic, ~tonic + ~di, ~tonic + (~di * 2), ~tonic + (~di * 3), ~tonic + (~di * 4),
	~tonic + (~di * 4), ~tonic + (~di * 5), ~tonic + (~di * 6), ~tonic + (~di * 7),
	~tonic + (~di * 8), ~tonic + (~di * 9), ~tonic + (~di * 10), ~tonic + (~di * 11),
	~tonic + (~di * 12), ~tonic + (~di * 13), ~tonic + (~di * 14), ~tonic + (~di * 15),
	~tonic + (~di * 16), ~tonic + (~di * 17), ~tonic + (~di * 18), ~tonic + (~di * 19),
	~tonic + (~di * 20), ~tonic + (~di * 21), ~tonic + (~di * 22)];

~key = [~edo23[0], ~edo23[3], ~edo23[5], ~edo23[8], ~edo23[11], ~edo23[14], ~edo23[19], ~edo23[21]].midicps;

~fr = rrand(0.9, 1.5);


(SynthDef.new(\bass, {
	var env, pEnv, mod, sig, send, freq;
	env = Env.perc(\atk.kr(0.01), \dec.kr(0.2), \amp.kr(1), \curve.kr(-4.0)).kr(2);
	pEnv = Env.perc(0.001, 0.05, 1).kr;
	mod = SinOsc.ar(\freq.kr(440) * \r.kr(1.5), 0, \mmul.kr(1)) * env;
	sig = GeneRand.ar(\freq.kr * [0.5, 0.5, 1.5, 1] + (mod * 20) + (LocalIn.ar * 40) + (pEnv * \freq.kr)).sum * 0.4 * \mul.kr(1);
	sig = sig.blend(Saw.ar(\freq.kr + (mod * 20) + (LocalIn.ar * 40) + (pEnv * \freq.kr), \mul.kr), 0.3);
	sig = sig.blend(sig * GeneRand.ar(\freq.kr * (0.125 * 0.125 * 0.35), \mul.kr * 5) * Pulse.ar(\freq.kr * 0.05, \mul.kr * 4), 0.2);
	sig = sig.blend(sig * GeneRand.ar(\freq.kr * 0.5 + (pEnv * \freq.kr)) * \mul.kr, 0.3);
	sig = RLPF.ar(sig, \lp.kr(1000) + LFNoise2.ar(LFNoise2.ar(10).abs, 3000).abs, (0.175 + LFNoise2.ar(0.3, 0.8).abs).clip2(0.99));
	sig = sig * 0.3 * env;
	sig = Clip.ar(sig * 2.8, -0.35, 0.35);
	sig = RLPF.ar(sig * 1.5, 100 + (env * 450), 0.37);
	sig = HPF.ar(sig, 40);
	sig = sig * 0.7;
	LocalOut.ar(sig);
	sig = Pan2.ar(sig, \pan.kr(0));
	send = Impulse.ar(30);
	freq = \freq.kr;
	SendReply.ar(send, '/bassSig', sig);
	SendReply.ar(send, '/bassEnv', env);
	SendReply.ar(send, '/bassFreq', freq);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\bass2, {
	var env, sig, mod, send, freq;
	env = Env.perc(\atk.kr(0.01), \dec.kr(1), \amp.kr(1), \curve.kr(-4.0)).kr(2);
	sig = SinOsc.ar(\freq.kr(440), 0, \mul.kr(1));
	mod = Saw.ar(28 + [SinOsc.ar(2, 0, 20), 0, 0, 0], \mul.kr(1)).sum;
	sig = sig.blend(GeneRand.ar(\freq.kr, \mul.kr), 0.2);
	sig = sig * mod * env * 0.875;
	sig = Pan2.ar(sig, \pan.kr(0));
	send = Impulse.ar(30);
	freq = \freq.kr;
	SendReply.ar(send, '/bass2Sig', sig);
	SendReply.ar(send, '/bass2Env', env);
	SendReply.ar(send, '/bass2Freq', freq);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\kick, {
	var env, sig, send;
	env = Env.perc(\atk.kr(0.01), \dec.kr(0.1), \amp.kr(1), \curve.kr(-4.0)).kr(2);
	sig = SinOsc.ar(20 + (env * 200) + (LocalIn.ar * 100), 0, \mul.kr(1)) * env;
	sig = sig.softclip;
	LocalOut.ar(sig);
	sig = Clip.ar(sig, -0.6, 0.6);
	sig = Pan2.ar(sig, \pan.kr(0));
	send = Impulse.ar(30);
	SendReply.ar(send, '/kickSig', sig);
	SendReply.ar(send, '/kickEnv', env);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\snare, {
	var env, sig, send;
	env = Env.perc(\atk.kr(0.01), \dec.kr(0.1), \amp.kr(1), \curve.kr(-4.0) * 3).kr(2);
	sig = SinOsc.ar(450 + (env * 100) + (LocalIn.ar * 2000) + WhiteNoise.ar(900), 0, \mul.kr(1)) * env * 0.885;
	sig = HPF.ar(sig * 1.1, 500);
	sig = sig.blend(HPF.ar(WhiteNoise.ar, 1000) * env, 0.2);
	LocalOut.ar(sig);
	sig = Pan2.ar(sig, \pan.kr(0));
	send = Impulse.ar(30);
	SendReply.ar(send, '/snareSig', sig);
	SendReply.ar(send, '/snareEnv', env);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\hat, {
	var env, sig, send;
	env = Env.perc(\atk.kr(0.01), \dec.kr(0.1) * 0.7, \amp.kr(1), \curve.kr(-4.0)).kr(2);
	sig = Saw.ar(327, \mul.kr(1)).blend(Saw.ar(332.5, \mul.kr), 0.5);
	sig = sig.blend(Pulse.ar(331, 0.5, \mul.kr).blend(Pulse.ar(334, 0.4, \mul.kr), 0.5), 0.5);
	sig = HPF.ar(sig.blend(sig * WhiteNoise.ar, 0.2), 3000 + (env * 2000));
	LocalOut.ar(sig);
	sig = Clip.ar(sig * 3, -0.2, 0.2) * 2.25 * env;
	sig = Pan2.ar(sig, \pan.kr(0));
	send = Impulse.ar(30);
	SendReply.ar(send, '/hatSig', sig);
	SendReply.ar(send, '/hatEnv', env);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\pad, {
	var env, mEnv, sig, send, freq;
	env = Env.perc(\atk.kr(2), \dec.kr(3), \amp.kr(1), 0).kr(2);
	mEnv = Env.perc(\atk.kr(2) * 0.95, \dec.kr(3) * 0.8, 1, 0).kr(2);
	sig = GeneRand.ar(\freq.kr(440) * [1, 1.25] + (In.ar(~bassBus, 2).sum * (1100 + LFNoise2.ar(0.06, 400)) * mEnv)).sum * \mul.kr(1);
	sig = sig.blend(SinOsc.ar(\freq.kr * [1.25, 2, 2.5, 3.25] + (sig * 30 * mEnv), 0, \mul.kr).sum, 0.2);
	sig = sig.blend(Saw.ar(\freq.kr * [0.5, 1.25] + (In.ar(~bassBus, 2).sum * (1100 + LFNoise2.ar(0.06, 400)) * mEnv), \mul.kr).sum * 0.4, 0.005);

	sig = LPF.ar(sig, 500 + (env * 3500));
	sig = HPF.ar(sig, 1000 + (env * 800));
	sig = sig.blend(SinOsc.ar(\freq.kr + (sig * 60 * mEnv) * [1, 1.25], 0, \mul.kr) + (sig * mEnv * 0.3), 0.2) * 0.5;
	sig = sig.blend(sig * GeneRand.ar(SinOsc.ar(0.9, LFNoise0.ar.abs.clip2(0.9), 4.5, 1).abs) * 2.5, 0.3);
	sig = sig.blend(sig * In.ar(~bassBus, 2).sum.neg, 0.221 * mEnv);
	sig = HPF.ar(sig, 600);
	sig = LPF.ar(sig, 2000);
	sig = sig * 0.725;
	sig = LPF.ar(sig, 3000);
	sig = HPF.ar(sig, 50);
	sig = HPF.ar(sig, 200);
	sig = Splay.ar(sig * env, \spread.kr(3));
	send = Impulse.ar(30);
	freq = \freq.kr;
	SendReply.ar(send, '/padSig', sig);
	SendReply.ar(send, '/padEnv', env);
	SendReply.ar(send, '/padFreq', freq);
	Out.ar(\out.kr(0), sig);
}).add;
);


(SynthDef.new(\pluck, {
	var env, pEnv, mod, sig, send, freq;
	env = Env.perc(\atk.kr(0.01), \dec.kr(0.5), \amp.kr(1), \curve.kr(-4.0)).kr(2);
	pEnv = Env.perc(0.001, 0.05, 1).kr;
	mod = Pulse.ar(\freq.kr(440) * \r.kr(1.5) + (pEnv * \freq.kr), 0.5, \mmul.kr(1));
	sig = Saw.ar(\freq.kr + (mod * 50 * env) + (pEnv * \freq.kr), \mul.kr(1));
	sig = sig.blend(SinOsc.ar(\freq.kr * [2, 0.5, 2, 0.5, 2.5] + (mod * 50 * env), 0, \mul.kr).sum, 0.08);
	sig = LPF.ar(FreeVerb.ar(sig, 0.5, 1), 2600);
	sig = sig * env;
	sig = Pan2.ar(sig * 0.65, \pan.kr(0));
	send = Impulse.ar(30);
	freq = \freq.kr;
	SendReply.ar(send, '/pluckSig', sig);
	SendReply.ar(send, '/pluckEnv', env);
	SendReply.ar(send, '/pluckFreq', freq);
	Out.ar(\out.kr(0), sig);
}).add;
);


(OSCdef(\bassSig, {
	arg sig;
	~bassSig = sig[3];

}, '/bassSig'));

(OSCdef(\bassEnv, {
	arg env;
	~bassEnv = env[3];

}, '/bassEnv'));

(OSCdef(\bassFreq, {
	arg freq;
	~bassFreq = freq[3];
6
}, '/bassFreq'));

(OSCdef(\bass2Sig, {
	arg sig;
	~bass2Sig = sig[3];

}, '/bass2Sig'));

(OSCdef(\bass2Env, {
	arg env;
	~bass2Env = env[3];

}, '/bass2Env'));

(OSCdef(\bass2Freq, {
	arg freq;
	~bass2Freq = freq[3];
}, '/bass2Freq'));

(OSCdef(\padSig, {
	arg sig;
	~padSig = sig[3];

}, '/padSig'));

(OSCdef(\padEnv, {
	arg env;
	~padEnv = env[3];

}, '/padEnv'));

(OSCdef(\padFreq, {
	arg freq;
	~padFreq = freq[3];

}, '/padFreq'));

(OSCdef(\pluckSig, {
	arg sig;
	~pluckSig = sig[3];

}, '/pluckSig'));

(OSCdef(\pluckEnv, {
	arg env;
	~pluckEnv = env[3];

}, '/pluckEnv'));

(OSCdef(\pluckFreq, {
	arg freq;
	~pluckFreq = freq[3];

}, '/pluckFreq'));

(OSCdef(\kickSig, {
	arg sig;
	~kickSig = sig[3];

}, '/kickSig'));

(OSCdef(\kickEnv, {
	arg env;
	~kickEnv = env[3];

}, '/kickEnv'));


(OSCdef(\snareSig, {
	arg sig;
	~snareSig = sig[3];

}, '/snareSig'));

(OSCdef(\snareEnv, {
	arg env;
	~snareEnv = env[3];

}, '/snareEnv'));


(OSCdef(\hatSig, {
	arg sig;
	~hatSig = sig[3];

}, '/hatSig'));

(OSCdef(\hatEnv, {
	arg env;
	~hatEnv = env[3];

}, '/hatEnv'));




(Ndef(\bassFX, {
	var in;
	in = In.ar(~bassBus, 2);
	in = in.blend(DelayN.ar(FreeVerb.ar(LPF.ar(in, 600), 1, 0.65, 0.8), 0.06, 0.06), 0.125);
	in = in.blend(DelayN.ar(FreeVerb.ar(BPF.ar(in, 800), 1, 0.886, 0.8), 0.07, 0.07), 0.255);
	in = in.blend(DelayN.ar(FreeVerb.ar(BPF.ar(in, 1100, 0.7), 1, 0.9, 0.8), 0.085, 0.085), 0.19);
	in = in.blend(BPF.ar(FreeVerb.ar(HPF.ar(in, 2000), 1, 0.9, 0.7), 1800, 0.05), 0.05);
}));

(Ndef(\synthFX, {
	var in;
	in = In.ar(~synthBus, 2);
	in = in.blend(DelayN.ar(in, 0.5, 0.5), 0.1);
	in = in.blend(DelayN.ar(HPF.ar(in, 2000), 0.5, 0.5), 0.04);
	in = in.blend(DelayN.ar(LPF.ar(in, 500), 0.5, 0.5), 0.025);

	in = in.blend(DelayN.ar(FreeVerb.ar(LPF.ar(in, 1600), 1, 0.95, 0.7), 0.1, 0.1), 0.25);
	in = in.blend(DelayN.ar(FreeVerb.ar(HPF.ar(in, 1800), 1, 0.986, 0.8), 0.11, 0.11), 0.2);
	in = FreeVerb.ar(in, 0.6, 0.75, 0.5);
	in = LPF.ar(in * 1.5, 3000);
	in = Clip.ar(in, -0.5, 0.5);

}));



(Pdef(\bass, Pbind(
	\instrument, \bass,
	\dur, Pseq([0.33, 0.33, 0.34, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.33, 0.33, 0.34], inf),
	\freq, Prand(~key, inf) * Prand([0.25, 0.5, 4, 0.5, 0.5, 0.25, 0.5], inf) * ~fr,
	\dec, Pseq([0.05, 0.1, 0.2, 0.4, 0.8, 2, 0.3, 0.2, 0.1, 0.05, 2, 0.2, 0.1, 0.05, 2, 0.1, 0.1, 0.1, 0.1, 3.5], inf) * Pwhite(0.7, 1.05, inf),
	\amp, 1,
	\r, Pseq([0.25, 0.125, 0.5, 0.75, 1, 1.5, 1.5, 1.5, 2.5, 2.25, 2.75, 3.25], inf) * Prand([1, 2], inf),
	\mmul, Pwhite(0.1, 10, inf),
	\mul, Pseq([0.65, 0.55], inf),
	\pan, Pseq([-0.3, 0.3, 0.1], inf),
	\lp, Pwhite(200, 3000, inf),
	\curve, Pwhite(-0.1, -9.0, inf),

	\out, ~bassBus



)));

(Pdef(\pad, Pbind(
	\instrument, \pad,
	\dur, Pseq([12, 6, 3, 3], inf),
	\freq, Pseq([[~key[3], ~key[7]], [~key[2], ~key[6]], [~key[0], ~key[1], ~key[5]], [~key[0], ~key[3], ~key[5]], [~key[0], ~key[7]], [~key[0], ~key[5]], [~key[2], ~key[5]], [~key[3], ~key[5]], [~key[1], ~key[6]]], inf) * Prand([2, 2, 4], inf) * ~fr,
	\amp, 0.85,
	\atk, Pseq([4, 2, 1.5, 1.5], inf),
	\dec, Pseq([9, 4.5, 3, 3], inf),
	\spread, Prand([2, 3, 5, 7, 8, 9, 10, 11], inf),
	\mul, Pseq([0.35, 0.37, 0.38, 0.39, 0.4, 0.39, 0.38, 0.37], inf),
	\out, Pseq([~synthBus, ~bassBus, ~synthBus], inf)

)));

(Pdef(\pluck, Pbind(
	\instrument, \pluck,
	\amp, 1,
	\dec, Pwhite(0.1, 0.3, inf),
	\dur, Pseq([0.125, 0.125, 0.25, 0.5, 0.5, 0.5, 1], inf),
	\mul, 0.8,
	\pan, Pwhite(-0.3, 0.3, inf),
	\atk, Pwhite(0.01, 0.045, inf),
	\freq, Pseq([~key[0], ~key[2], ~key[1], ~key[0], ~key[1], ~key[2], Prand(~key, 1), ~key[4], ~key[5], ~key[4], Prand(~key, 2), ~key[2], ~key[4], ~key[6], ~key[4], ~key[2], ~key[1]], inf) * Prand([4, 4, 4, 8, 8, 2], inf) * ~fr,


	\out, Pseq([~synthBus, ~bassBus], inf)

)));

(Pdef(\arp, Pbind(
	\instrument, \pluck,
	\amp, 1,
	\dec, Pwhite(0.1, 0.3, inf),
	\dur, Pseq([Pseq([0.125], 24), Pseq([0.25], 12)], inf) ,
	\mul, 0.8,
	\pan, Pwhite(-0.3, 0.3, inf),
	\atk, Pwhite(0.01, 0.045, inf),
	\freq, Pseq([~key[0], ~key[1], ~key[3], ~key[5], ~key[3], ~key[1], ~key[2], ~key[4], ~key[1], ~key[4], ~key[2], ~key[1], ~key[4], ~key[2], ~key[1], ~key[0], ~key[1], ~key[2]], inf) * 16 * ~fr,


	\out, Pseq([~synthBus, ~bassBus], inf)

)));




(~sec1 = {Task({
	Ndef(\bassFX).play;
	Ndef(\synthFX).play;



	Pdef(\bass).stop;
	Pdef(\drums).stop;
	Pdef(\pad).stop;
	Pdef(\pluck).stop;
	Pdef(\arp).stop;
	Pdef(\drums).stop;
	Ndef(\noise).free;
	Ndef(\brownNoise).free;


	Pdef(\pad).play;

	Ndef(\brownNoise, {
		var noise;
		noise = BrownNoise.ar(0.0045);
		Out.ar(~bassBus, noise ! 2);
	}).play;


	wait(12);

	Ndef(\noise, {
		var noise;
		noise = BrownNoise.ar(0.02);
		noise = RLPF.ar(noise, SinOsc.ar(LFNoise2.ar(2, 0.2).abs, 0, 8000).abs, 0.3);
		noise = RHPF.ar(noise, SinOsc.ar(LFNoise2.ar(2, 0.2).abs, 0, 3000).abs, 0.3);
		noise = Pan2.ar(noise, LFNoise2.ar(LFNoise2.ar(0.2, 1).abs));
		noise = noise.blend(DelayN.ar(noise, 0.1, 0.1), 0.1);
		noise = noise.blend(DelayN.ar(noise, 0.1, 0.1), 0.1);
		noise = noise.blend(DelayN.ar(noise, 0.1, 0.1), 0.1);
		noise = noise.softclip.blend(noise * In.ar(~synthBus, 2).sum * 5, 0.25);
		noise = FreeVerb.ar(noise, 0.7, 0.8, 0.9);
		Out.ar(0, Pan2.ar(noise, LFNoise2.ar(LFNoise2.ar(0.2).abs)));



	}).play;



	Pdef(\bass).play;
	wait(6);

	Pdef(\bass).stop;
	Pdef(\pad).stop;
	Pdef(\bass).play;
	Pdef(\pad).play;
	wait(7);
	Pdef(\pluck).play;
	wait(5);
	Pdef(\bass).stop;
	wait(6);
	Pdef(\arp).play;
	wait(6);
	Pdef(\bass).play;
	Pdef(\pluck).stop;
	Pdef(\pad).stop;
	wait(9);
	Pdef(\pad).play;
	Pdef(\arp).stop;
	wait(12);
	Pdef(\pad).stop;
	Ndef(\noise).stop;
	wait(6);
	Pdef(\bass).stop;


}).play;
});

(~sec2 = {
	Task({

		Ndef(\drumFX, {
			var in;
			in = In.ar(~drumBus, 2);
			in = in.softclip;
			in = in.blend(DelayN.ar(HPF.ar(in), 0.5, 0.5), 0.1125);
			in = in.blend(DelayN.ar(in, 0.25, 0.25), 0.08);
			in = in.blend(DelayN.ar(in, 0.125, 0.125), 0.045);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 200, 0.5), 1, 0.3, 0.2), 0.0125);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 400, 0.5), 1, 0.3, 0.2), 0.0125);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 600, 0.5), 1, 0.3, 0.2), 0.025);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 800, 0.5), 1, 0.4, 0.2), 0.025);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1000, 0.5), 1, 0.4, 0.2), 0.035);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1200, 0.5), 1, 0.4, 0.2), 0.035);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1400, 0.5), 1, 0.5, 0.2), 0.045);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1600, 0.5), 1, 0.5, 0.2), 0.045);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1800, 0.5), 1, 0.6, 0.2), 0.05);
		}).play;



		Ndef(\bassFX).play;
		Ndef(\synthFX).play;
		Ndef(\brownNoise).play;


		Pdef(\pad, Pbind(
			\instrument, \pad,
			\dur, 1.5,
			\amp, 1,
			\atk, 1.25,
			\dec, 0.5,
			\mul, 0.2,
			\freq, Pseq([[~key[0], ~key[3]], [~key[1], ~key[5]], [~key[3], ~key[5]], [~key[4], ~key[6]], [~key[1], ~key[4]]], inf) * 4 * ~fr,
			\out, ~synthBus

		));

		Pdef(\bass, Pbind(
			\instrument, \bass,
			\amp, 1,
			\mul, Pseq([0.4, 0.5, 0.6, 0.7, 0.025, 0.05, 0.1, 0.5, 0.4], inf),
			\freq, Prand(~key, inf) * Prand([0.25, 0.5, 1], inf) * ~fr,
			\dur, Pseq([0.25, 0.25, 0.25, 0.25, 1, 0.5, 0.125, 0.125, 0.125, 0.125], inf),
			\dec, Pwhite(0.1, 1.3, inf),
			\r, 21,
			\pan, Pseq([0.3, 0.15, 0, -0.15, -0.3, -0.5, -0.7, -0.5, 0.3, -0.15, 0, 0.15, 0.3, 0.5, 0.7, 0.8, 0.7, 0.5], inf),
			\mmul, Pseq([Pwhite(0.05, 1.0, 3), Pwhite(0.5, 2.5, 5), Pwhite(2.0, 5.0, 10), Pwhite(3.0, 15.0, 15), Pwhite(12.0, 25.0, 20), Pwhite(25.0, 50.0, 25), 50, 50, 50, 50, 50], inf),
			\out, Prand([~bassBus, ~synthBus], inf)
		));

		Pdef(\pluck, Pbind(
			\instrument, Prand([\pluck, \pad, \bass], inf),
			\dur, Pseq([0.125, 0.125, Prand([Pseq([0.125, 0.125], 1), 0.25], 1), 0.25, 0.25, 0.25, 0.25, Prand([0.5, Pseq([0.25, 0.25], 1), Pseq([0.25, 0.125, 0.125], 1)], 1), Prand([1, Pseq([0.5], 2), Pseq([0.25], 4), Pseq([0.5, 0.25, 0.5], 1), Pseq([0.25, 0.25, 0.25, 0.125, 0.125], 1)], 1)], inf),
			\amp, 1,
			\atk, 0.01,
			\dec, 0.2,
			\mul, 0.5,
			\mmul, 3,
			\r, 3,
			\pan, -0.05,
			\freq, Prand(~key, inf) * 8 * ~fr,
			\out, Prand([~bassBus, ~synthBus], inf)
		));

		Pdef(\drums, Pbind(
			\instrument, Pseq([\kick, \kick, \hat, \snare, \kick, \hat, \hat, \snare, \kick, \hat, \snare, \hat, \kick, \kick, \snare, \hat, Prand([\kick, \hat, \snare], 24)], inf),
			\dur, Pseq([0.125, 0.125, 0.25], inf),
			\amp, 1,
			\pan, Pwhite(-0.1, 0.1, inf),
			\mul, Pseq([0.0, 0.0, 0.0, 0.01, 0.03, 0.05, 0.06, 0.065, 0.07, 0.075, 0.08, 0.085, 0.09, 0.1, 0.125, 0.15, 0.2, 0.25, 0.3, Pseq([0.35], inf)], 1),
			\dec, Pseq([0.2, 0.2, 0.1, 0.05], inf) * Pwhite(1.0, 1.5, inf),
			\out, ~drumBus
		));



		Pdef(\bass).stop;
		Pdef(\arp).stop;
		Pdef(\pad).stop;
		Pdef(\pluck).stop;
		Ndef(\noise).free;
		Pdef(\pad).play;

		wait(6);

		Ndef(\noise).play;
		wait(6);
		Pdef(\bass).play;
		wait(12);
		Pdef(\pad).stop;
		wait(3);
		Pdef(\pluck).play;
		wait(12);
		Pdef(\pad).play;
		wait(6);
		Pdef(\bass).stop;
		wait(12);
		Pdef(\bass).play;
		wait(6);
		Pdef(\pad).stop;
		wait(6);
		Pdef(\pluck).stop;
		wait(12);
		Pdef(\drums).play;
		wait(18);
		Pdef(\bass).stop;
		Pdef(\noise).free;
		wait(3);
		Pdef(\pluck).play;
		wait(3);
		Pdef(\pad).play;
		wait(12);
		Pdef(\pad).stop;
		Pdef(\bass).play;
		wait(12);
		Pdef(\pluck).stop;
		wait(6);
		Ndef(\noise).play;
		wait(1);
		Ndef(\brownNoise).free;
		wait(1);
		Ndef(\brownNoise).play;
		wait(1);
		Ndef(\brownNoise).free;
		wait(1);
		Ndef(\brownNoise).play;
		wait(1);
		Ndef(\brownNoise).free;

		Ndef(\drumFX).fadeTime_(10);
		Ndef(\drumFX, {
			var in;
			in = In.ar(~drumBus, 2);
			in = in.softclip;
			in = in.blend(DelayN.ar(HPF.ar(in), 0.5, 0.5), 0.1125);
			in = in.blend(DelayN.ar(in, 0.25, 0.25), 0.08);
			in = in.blend(DelayN.ar(in, 0.125, 0.125), 0.045);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 200, 0.5), 1, 0.3, 0.2), 0.0125);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 400, 0.5), 1, 0.3, 0.2), 0.0125);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 600, 0.5), 1, 0.3, 0.2), 0.025);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 800, 0.5), 1, 0.4, 0.2), 0.025);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1000, 0.5), 1, 0.4, 0.2), 0.035);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1200, 0.5), 1, 0.4, 0.2), 0.035);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1400, 0.5), 1, 0.5, 0.2), 0.045);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1600, 0.5), 1, 0.5, 0.2), 0.045);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1800, 0.5), 1, 0.6, 0.2), 0.05);
			in = RLPF.ar(in, LFNoise2.ar(0.31, 5000).abs + 200, 0.3);
			in = RHPF.ar(in, LFNoise2.ar(0.14, 2000, 0.6).abs);
		});


		wait(1);
		Ndef(\brownNoise).play;
		wait(1);
		Ndef(\brownNoise).free;
		wait(1);
		Ndef(\brownNoise).play;
		wait(1);
		Ndef(\brownNoise).free;
		wait(30);
		Pdef(\bass).stop;
		Pdef(\drums).stop;
		wait(6);
		Ndef(\brownNoise).play;

		Ndef(\drumFX, {
			var in;
			in = In.ar(~drumBus, 2);
			in = in.softclip;
			in = in.blend(DelayN.ar(HPF.ar(in), 0.5, 0.5), 0.1125);
			in = in.blend(DelayN.ar(in, 0.25, 0.25), 0.08);
			in = in.blend(DelayN.ar(in, 0.125, 0.125), 0.045);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 200, 0.5), 1, 0.3, 0.2), 0.0125);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 400, 0.5), 1, 0.3, 0.2), 0.0125);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 600, 0.5), 1, 0.3, 0.2), 0.025);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 800, 0.5), 1, 0.4, 0.2), 0.025);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1000, 0.5), 1, 0.4, 0.2), 0.035);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1200, 0.5), 1, 0.4, 0.2), 0.035);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1400, 0.5), 1, 0.5, 0.2), 0.045);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1600, 0.5), 1, 0.5, 0.2), 0.045);
			in = in.blend(FreeVerb.ar(BPF.ar(in, 1800, 0.5), 1, 0.6, 0.2), 0.05);
		});





	}).play;
});


(~sec3 = {

	Ndef(\synthFX).play;


	Pdef(\pad1, Pbind(
		\instrument, \pad,
		\amp, 1,
		\mul, 0.2,
		\freq, Prand(~edo23.midicps, inf) * Prand([1, 2, 4, 8], inf),
		\out, ~synthBus
	));
	Pdef(\pad2, Pbind(
		\instrument, \pad,
		\amp, 1,
		\dur, 1.5,
		\mul, 0.2,
		\freq, Prand(~edo23.midicps, inf) * Prand([1, 2, 4, 8], inf),
		\out, ~synthBus
	));
	Pdef(\pad3, Pbind(
		\instrument, \pad,
		\amp, 1,
		\dur, 3,
		\mul, 0.2,
		\freq, Prand(~edo23.midicps, inf) * Prand([1, 2, 4, 8], inf),
		\out, ~synthBus
	));

	Pdef(\pad4, Pbind(
		\instrument, \pluck,
		\amp, 1,
		\dur, Prand([1, Pseq([0.5, 0.5], 1), Pseq([0.5, 0.25, 0.25], 1), Pseq([0.25], 4)], inf),
		\mul, 0.3,
		\freq, Prand(~edo23.midicps, inf) * Prand([1, 2, 4, 8], inf),
		\out, ~synthBus
	));

	Pdef(\pad1).play;
	Pdef(\pad2).play;
	Pdef(\pad3).play;
	Pdef(\pad4).play;
});

(~sec4 = {


	Pdef(\pad1).stop;
	Pdef(\pad2).stop;
	Pdef(\pad3).stop;
	Pdef(\pad4).stop;

	Pdef(\pad, Pbind(
		\instrument, \pad,
		\dur, Pseq([15, 15, 6, 9], inf),
		\atk, Pseq([5, 5, 3, 4], inf),
		\dec, Pseq([10, 10, 3, 5], inf),
		\amp, 1,
		\mul, 0.35,
		\freq, Prand([[~key[0], ~key[2]], [~key[1], ~key[3]], [~key[2], ~key[4]], [~key[3], ~key[5]], [~key[4], ~key[6]]], inf) * ~fr * Prand([4, 8], inf),
		\out, ~synthBus
	));

	Pdef(\bass, Pbind(
		\instrument, Pseq([Prand([\bass, \bass2], 1), \bass2, \bass2, \bass2, \bass, \bass2, \bass2, Prand([\bass,\pluck, \bass2], 3)], inf),
		\amp, 1,
		\mul, 0.5,
		\r, 21,
		\mmul, 5,
		\dec, Pseq([1.75, 1], inf),
		\atk, Pseq([0.01, 0.02, 0.04, 0.08, 0.16, 0.32], inf),
		\dur, Pseq([2, 1], inf),
		\freq, Pseq([~key[0], ~key[0], ~key[1], ~key[0], ~key[2], ~key[3], ~key[1], ~key[4], ~key[0]], inf) * Prand([1, 0.5, 0.5, 0.5], inf) * ~fr,
		\out, ~bassBus
	));

	Pdef(\drums, Pbind(
		\instrument, Pseq([\kick, \kick, \snare, \kick, \hat, \hat, \snare, \snare, \hat, \kick, \kick, \kick, \hat, \snare, \hat, \snare, \kick, \kick, \hat, \snare, \kick, \hat, \kick, \snare, \hat, \hat, \snare], inf),
		\amp, 1,
		\mul, 0.35,
		\pan, Pseq([0, 0.3, 0.5, -0.3, -1, 0.5, 0.8, -0.5, -1], inf),
		\dur, Pseq([1, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 1, 0.5, 0.25, 0.25, 0.25, 0.25, 0.5, 1, 0.25, 0.125, 0.125, 0.5, 0.125, 0.125, 0.125, 0.125, 0.25, 0.125, 0.125, 1, 0.5, 0.25, 0.25, 0.25, 0.25, 0.5], inf),
		\out, ~drumBus
	));

	Pdef(\bass).play;
	Pdef(\drums).play;
	Pdef(\pad).play;

});

(~sec5 = {
	Pdef(\bass).stop;
	Pdef(\drums).stop;
	Pdef(\pad).stop;
	Pdef(\pluck).stop;
	Pdef(\bass).play;
	Pdef(\drums).play;
	Pdef(\pad).play;
	Pdef(\pluck).play;
});


(Tdef(\track, {
	loop{

		~fr = rrand(0.9, 1.5);
		~sec1.();
		wait(70);
		~sec2.();
		wait(189);
		~sec3.();
		wait(30);
		~sec4.();
		wait(90);
		~sec1.();
		wait(70);
		~sec5.();
		wait(210);
		[~sec1, ~sec2, ~sec3, ~sec4, ~sec5].choose.();
		wait(30);
		[~sec1, ~sec2, ~sec3, ~sec4, ~sec5].choose.();
		wait(30);
		[~sec1, ~sec2, ~sec3, ~sec4, ~sec5].choose.();
		wait(30);
		[~sec1, ~sec2, ~sec3, ~sec4, ~sec5].choose.();
		wait(30);
	}

}));

Tdef(\track).play;








);


(
LiveWindow().front.alwaysOnTop_(true);

~l = LiveView.view;
~bassSig = 0;
~bassFreq = 0;
~bassEnv = 0;
~padSig = 0;
~padFreq = 100;
~padEnv = 0;
~pluckSig = 0;
~pluckFreq = 0;
~pluckEnv = 0;
~bass2Env = 0;
~bass2Freq = 0;
~bass2Sig = 0;
~kickSig = 0;
~kickEnv = 0;
~hatEnv = 0;
~hatSig = 0;
~snareEnv = 0;
~snareSig = 0;

~l.drawFunc_({
	~l.background_(Color(~padEnv.clip2(0.99), ~bass2Env.clip2(0.99), (~pluckFreq * 0.001).clip2(0.99)));
	Pen.moveTo(200@200);
	Pen.lineTo((200 + (~bassSig * 700) + (~bassEnv * 200))@(200 + ((~bassSig.neg * 400) + (~bassEnv * 50))));
	Pen.strokeColor_(Color((~bassFreq * 0.03).clip2(0.99), ~bassEnv.clip2(0.99), ~bassSig.abs.clip2(0.99)));
	Pen.width_((~bassFreq * 0.02).clip2(40));
	Pen.stroke;


	Pen.moveTo((200 + (~bassSig * 700))@(200 + ((~bassSig.neg * 400) + (~bassEnv * 50) )));
	Pen.lineTo((200 + (~padSig.neg * 1700) + (~padEnv * 200.neg)).clip2(400)@(200 + (~padSig * 1700)).clip2(400));
	Pen.strokeColor_(Color((~padFreq * 0.00005).clip2(0.99), ~padEnv.clip2(0.99), ~padSig.abs.clip2(0.99)));
	Pen.width_((~bassFreq * 0.02).clip2(40));
	Pen.stroke;

	Pen.moveTo((200 + (~padSig.neg * 1700) + (~padEnv * 200.neg)).clip2(400)@(200 + (~padSig * 1700)).clip2(400));
	Pen.lineTo((200 + (~pluckSig * 1500)).clip2(400)@(200 + ((~pluckSig.neg * 1500) + (~pluckEnv * 100))).clip2(400));
	Pen.strokeColor_(Color(~pluckEnv.clip2(0.99), ~pluckSig.abs.clip2(0.99), (~pluckFreq * 0.00005).clip2(0.99)));
	Pen.width_((~bassFreq * 0.02).clip2(40));
	Pen.stroke;

	Pen.moveTo((200 + (~pluckSig * 1500)).clip2(400)@(200 + ((~pluckSig.neg * 1500) + (~pluckEnv * 100))).clip2(400));
	Pen.lineTo((200 + (~bass2Sig.neg * 1500)).clip2(400)@(200 + ((~bass2Sig * 1500))).clip2(400));
	Pen.strokeColor_(Color(~bass2Sig.abs.clip2(0.99), (~bass2Freq * 0.00005).clip2(0.99), ~bass2Env.clip2(0.99)));
	Pen.width_((~bassFreq * 0.02).clip2(40));
	Pen.stroke;



	Pen.moveTo((200 + (~bass2Sig.neg * 1500)).clip2(400)@(200 + ((~bass2Sig * 1500))).clip2(400));
	Pen.lineTo((200 + (~kickSig * 1100)).clip2(400)@(200 + ((~kickSig.neg * 1100) + (~kickEnv * 20) )).clip2(400));
	Pen.strokeColor_(Color(~kickSig.abs.clip2(0.99), (~kickEnv * 0.00005).clip2(0.99), ~kickEnv.clip2(0.99)));
	Pen.width_((~bassFreq * 0.02).clip2(40));
	Pen.stroke;

	Pen.moveTo((200 + (~kickSig * 1100)).clip2(400)@(200 + ((~kickSig.neg * 1100) + (~kickEnv * 20))).clip2(400));
	Pen.lineTo((200 + (~snareSig.neg * 1100)).clip2(400)@(200 + ((~snareSig * 1100) )).clip2(400));
	Pen.strokeColor_(Color(~snareSig.abs.clip2(0.99), (~snareEnv * 0.00005).clip2(0.99), ~snareEnv.clip2(0.99)));
	Pen.width_((~bassFreq * 0.02).clip2(40));
	Pen.stroke;

	Pen.moveTo((200 + (~snareSig.neg * 1100)).clip2(400)@(200 + ((~snareSig * 1100) )).clip2(400));
	Pen.lineTo((200 + (~hatSig * 1100)).clip2(400)@(200 + ((~hatSig.neg * 1100) )).clip2(400));
	Pen.strokeColor_(Color(~hatSig.abs.clip2(0.99), (~hatEnv * 0.00005).clip2(0.99), ~hatEnv.clip2(0.99)));
	Pen.width_((~bassFreq * 0.02).clip2(40));
	Pen.stroke;

	Pen.moveTo((200 + (~hatSig * 1100)).clip2(400)@(200 + ((~hatSig.neg * 1100) )).clip2(400));
	Pen.lineTo(200@200);
	Pen.strokeColor_(Color(~bass2Sig.abs.clip2(0.99), (~padEnv * 0.00005).clip2(0.99), ~bassEnv.clip2(0.99)));
	Pen.width_((~bassFreq * 0.02).clip2(40));
	Pen.stroke;


});

~l.frameRate_(25);

~l.animate_(true);


);
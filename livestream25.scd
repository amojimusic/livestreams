
~reverbBus = Bus.audio(s, 2);
~delayBus = Bus.audio(s, 2);



(~tuning = [45, 45 + 0.8, 45 + (0.8 * 2), 45 + (0.8 * 3), 45 + (0.8 * 4),  45 + (0.8 * 5),  45 + (0.8 * 6),  45 + (0.8 * 7),  45 + (0.8 * 8),  45 + (0.8 * 9),  45 + (0.8 * 10),  45 + (0.8 * 11),  45 + (0.8 * 12),  45 + (0.8 * 13),  45 + (0.8 * 14),  45 + (0.8 * 15)].midicps
);

(~key = [~tuning[0], ~tuning[3], ~tuning[4], ~tuning[7], ~tuning[9], ~tuning[11], ~tuning[13]]);




(SynthDef.new(\kick, {
	var aTrig, env, freq, sig, pan;
	aTrig = Impulse.ar(40 + LFNoise0.ar(2, 5));
	env = Env.perc(\atk.kr(0.01), \dec.kr(0.05), \amp.kr(1), \curve.kr(-1)).kr(2);
	freq = 20 + (env * [80, 250, 100]);
	sig = SinOsc.ar(freq + (LocalIn.ar(1) * 200 * (\snareSig.kr(0) * 3)), 0, \mul.kr(1));
	sig = sig.softclip * 0.4;
	sig = sig.sum * 0.3;
	LocalOut.ar(sig);
	pan = \pan.kr(0);
	sig = sig * env;
	sig = Pan2.ar(sig, pan);
	sig = RLPF.ar(sig, \lp.kr(450) + (env * 1250), Clip.ar(\q.kr(1) - (env * 0.4))).blend(sig, 0.2) * 1.15;
	sig = sig.blend(sig.clip, 0.5);
	sig = Clip.ar(sig, -0.5, 0.5);
	env = env * 0.7;
	SendReply.ar(aTrig, '/kickSig', sig);
	SendReply.ar(aTrig, '/kickEnv', env);
	SendReply.ar(aTrig, '/kickFreq', freq);
	SendReply.ar(aTrig, '/kickPan', pan);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\snare, {
	var aTrig, env, freq, sig, pan;
	aTrig = Impulse.ar(40 + LFNoise0.ar(2, 5));
	env = Env.perc(\atk.kr(0.01), \dec.kr(0.1), \amp.kr(1), \curve.kr(-1)).kr(2);
	freq = 450 + (env * 200);
	sig = SinOsc.ar([freq + (LocalIn.ar(1) * 3000), freq] + (LocalIn.ar(1) * 900), 0, \mul.kr(1)).sum * 0.5;
	LocalOut.ar(sig);
	sig = sig * 0.45;
	sig = sig.blend(WhiteNoise.ar, (0.0125 * env) + (\hatEnv.kr(0) * \hatEnv.kr(0) * \kickSig.kr(0)));
	pan = \pan.kr(0);
	sig = sig * env;
	sig = RHPF.ar(sig, 200 + Env.perc(0.03, 0.0025, 1500, 0).kr, 0.88) * 0.8;
	sig = Pan2.ar(sig, pan);
	env = env * 0.7;
	sig = Clip.ar(sig, -0.5, 0.5);
	SendReply.ar(aTrig, '/snareSig', sig);
	SendReply.ar(aTrig, '/snareEnv', env);
	SendReply.ar(aTrig, '/snareFreq', freq);
	SendReply.ar(aTrig, '/snarePan', pan);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\hat, {
	var aTrig, env, sig;
	aTrig = Impulse.ar(45);
	env = Env.perc(\atk.kr(0.01), \dec.kr(0.1), \amp.kr(1), \curve.kr(-1)).kr(2);
	sig = Pulse.ar(405 + \kickSig.kr(0) + (LocalIn.ar * 100) + HPF.ar(WhiteNoise.ar(300), 2000), 0.5, \mul.kr(1));
	sig = sig.blend(Pulse.ar(396 + (LocalIn.ar * (20 * \snareSig.kr(0))), 0.5, \mul.kr), 0.5);
		sig = sig.blend(Pulse.ar(412 + (LocalIn.ar * (500 * \hatEnv.kr(0))) + HPF.ar(WhiteNoise.ar(300)), 2000, 0.5, \mul.kr), 0.2);
	sig = sig * env;
	LocalOut.ar(sig);
	sig = RHPF.ar(sig, 4500 + (env * 2000));
	sig = Pan2.ar(sig, \pan.kr(0));
	SendReply.ar(aTrig, '/hatSig', sig);
	SendReply.ar(aTrig, '/hatEnv', env);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\bass, {
	var aTrig, env, mod, freq, sig, pan;
	aTrig = Impulse.ar(40);
	env = EnvGen.ar(Env([0, \amp.kr(1), 0], [\atk.kr(0.05), \dec.kr(2)]), doneAction: 2);
	mod = RLPF.ar(Saw.ar(\freq.kr(440) * \r.kr(1.5), \mmul.kr(1)), \freq.kr * 0.8);
	freq = \freq.kr + (mod * 10);
	sig = Pulse.ar(freq, 0.5, \mul.kr(1));
	sig = sig.blend(Saw.ar(freq, \mul.kr(1)), 0.75);
	sig = sig * env;
	sig = RLPF.ar(sig, \lp.kr(2000), \lq.kr(1));
	sig = sig * 0.9;
	sig = sig.blend(SinOsc.ar(freq, 0, \mul.kr), 0.35);
	sig = sig * env;
	pan = \pan.kr(0);
	sig = RLPF.ar(sig, 2222, 1);
	sig = Pan2.ar(sig, pan);
	SendReply.ar(aTrig, '/bassSig', sig);
	SendReply.ar(aTrig, '/bassEnv', env);
	SendReply.ar(aTrig, '/bassFreq', freq);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\pad, {
	var aTrig, env, mod, freq, sig, pan;
	aTrig = Impulse.ar(40);
	env = EnvGen.ar(Env([0, \amp.kr(1), 0], [\atk.kr(0.05), \dec.kr(2)]), doneAction: 2);
	mod = LFTri.ar(\freq.kr(440) * \r.kr(1.5), 0, \mmul.kr(1));
	freq = \freq.kr + (mod * 25);
	sig = Saw.ar(freq, \mul.kr(1)) * env;
	sig = sig.blend(SinOsc.ar(freq, 0, \mul.kr), 0.3 * env);
	sig = RHPF.ar(sig, \hp.kr(100), \hq.kr(1));
	sig = RLPF.ar(sig, \lp.kr(2000), \lq.kr(1));
	sig = sig * 0.4;
	pan = \pan.kr(0);
	sig = Pan2.ar(sig, pan);
	SendReply.ar(aTrig, '/padSig', sig);
	SendReply.ar(aTrig, '/padEnv', env);
	SendReply.ar(aTrig, '/padFreq', freq);
	Out.ar(\out.kr(0), sig);
}).add;
);


~fxGroup = Group.new(s, 'addToHead');
Ndef(\delay).group_(~fxGroup);
Ndef(\reverb).group_(~fxGroup);

~snareSig = 0;
~snareEnv = 0;
~kickSig = 0;
~kickEnv = 0;
~hatSig = 0;
~hatEnv = 0;
~bassSig = 0;
~bassEnv = 0;
~bassFreq = 0;
~padSig = 0;
~padEnv = 0;
~padSig = 0;
~delSig = 0;


(
OSCdef(\snareSig, {
	arg sig;
	if(~snareSig.isNil){
		~snareSig = 0};
	~snareSig = sig[3].asFloat;
}, '/snareSig');

OSCdef(\snareEnv, {
	arg env;
	if(~snareEnv.isNil){
		~snareSig = 0};
	~snareEnv = env[3].asFloat;
}, '/snareEnv');

OSCdef(\kickSig, {
	arg sig;
	if(~kickSig.isNil){
		~snareSig = 0};
	~kickSig = sig[3].asFloat;
}, '/kickSig');

OSCdef(\kickEnv, {
	arg env;
	if(~kickEnv.isNil){
		~kickEnv = 0};
	~kickEnv = env[3].asFloat;
}, '/kickEnv');

OSCdef(\hatSig, {
	arg sig;
	if(~hatSig.isNil){
		~hatSig = 0};
	~hatSig = sig[3].asFloat;
}, '/hatSig');

OSCdef(\hatEnv, {
	arg env;
	if(~hatEnv.isNil){
		~hatEnv = 0};
	~hatEnv = env[3].asFloat;
}, '/hatEnv');

OSCdef(\bassSig, {
	arg sig;
	~bassSig = sig[3].asFloat;
}, '/bassSig');

OSCdef(\bassEnv, {
	arg env;
	~bassEnv = env[3].asFloat;
}, '/bassEnv');

OSCdef(\bassFreq, {
	arg freq;
	~bassFreq = freq[3].asFloat;
}, '/bassFreq');

OSCdef(\padSig, {
	arg sig;
	~padSig = sig[3].asFloat;
}, '/padSig');

OSCdef(\padEnv, {
	arg env;
	~padEnv = env[3].asFloat;
}, '/padEnv');

OSCdef(\padFreq, {
	arg freq;
	~padFreq = freq[3].asFloat;
}, '/padFreq');

OSCdef(\delaySig, {
	arg sig;
	~delSig = sig[3].asFloat;
}, '/delaySig');
);

(Tdef(\tempo, { loop{
	~tempo = rrand(0.7, 1.75);
	wait(rrand(25, 100));
}}));

(Pdef(\drums, Pbind(
	\instrument, Pseq([\kick, Prand([\snare, \kick, \hat, Pseq([\hat, \hat], 1), Pseq([\hat, \hat], 2), \snare, \kick, \kick, \snare, \snare, \snare], 2)], inf),
	\dur, Prand([Pseq([0.25, 0.25], 1), Pseq([0.125, 0.125], 4), Pseq([0.25], 2), Pseq([0.125, 0.125], 8), Pseq([0.125, 0.125], 2), Pseq([0.125, 0.125], 2), Pseq([0.125, 0.125], 4), Pseq([0.125, 0.125], 2), Pseq([0.25, 0.125, 0.125], 1), Pseq([0.125, 0.125, 0.25], 1), 0.5], inf) * Pfunc({
		~tempo;
	}),
	\amp, 1,
	\snareSig, Pfunc({
		~snareSig;}),
	\hatEnv, Pfunc({
		~hatEnv;
	}),
	\kickSig, Pfunc({
		~kickSig;
	}),
	\pan, Pseq([0, Pwhite(-0.9, 0.9, 7)], inf),
	\dec, Pseq([Pwhite(0.02, 0.35, 1), Pwhite(0.005, 0.055, Prand([2, 5, 6, 7, 8, 9, 10, 11, 24], 1))], inf),
	\atk, Pwhite(0.001, 0.012, inf),
	\mul, Pwhite(0.7, 0.85, inf) * 0.7,
	\out, Prand([0, ~reverbBus, ~delayBus, 0], inf)
)));

(Pdef(\hats, Pbind(
	\instrument, \hat,
	\dur, Prand([Pseq([0.5], 8), 8], inf) * Pfunc({
		~tempo;
	}),
	\snareSig, Pfunc({
		~snareSig
	}),
	\hatEnv, Pfunc({
		~hatEnv;
	}),
	\kickEnv, Pfunc({
		~kickEnv;
	}),
	\dec, Pwhite(0.01, 0.05, inf),
	\amp, 1,
	\mul, Pseq([0.2, 0.2, 0.3, 0.5, 0.6, 0.7, 0.8], inf) * 0.4,
));
);

(Pdef(\bass, Pbind(
	\instrument, \bass,
	\dur, Prand([Pseq([0.25], 16), 8], inf) * Pfunc({
		~tempo;
	}),
	\amp, Pwhite(0.4, 0.6, inf),
	\mul, Pwhite(0.1, 0.35, inf),
	\lp, Pwhite(500, 3500, inf),
	\lq, Pwhite(0.6, 1.0, inf),
	\mmul, Pwhite(0.5, 2, inf),
	\freq, Pseq([~key[0], Prand(~key, 2), ~key[2], Prand(~key, 4)], inf) * Prand([1, 0.5, 0.5, 0.5, 1, 0.25, 1], inf),
	\atk, 0.01,
	\dec, 0.75,
	\pan, Pwhite(-0.5, 0.5, inf),
	\out, Prand([0, ~delayBus], inf)
)));

(Pdef(\pads, Pbind(
	\instrument, \pad,
	\dur, Prand([2, 4, Pseq([1, 1], 1), 16, 2, 4, 2, 4], inf) * Pfunc({
		~tempo;
	}),
	\atk, Prand([0, Pwhite(1.0, 3.0, 1)], inf),
	\dec, Pwhite(1.0, 4.0, inf),
	\freq, Pseq([Prand([[~key[0], ~key[2], ~key[6]], [~key[1], ~key[3], ~key[6]], [~key[0], ~key[1], ~key[5]], [~key[3], ~key[1], ~key[4]], [~key.choose, ~key.choose]], 1)], inf) * Prand([2, 4, 8, 16, 4, 8], inf),
	\mul, 0.1,
	\amp, 0.25,
	\mmul, Pwhite(0.2, 2, inf),
	\r, Prand([1, 1.5, 2.5], inf),
	\lp, Pwhite(700, 5000, inf),
	\lq, Pwhite(0.3, 1.0, inf),
	\hp, Pwhite(10, 400, inf),
	\pan, Pwhite(-1.0, 1.0, inf),
	\out, ~reverbBus
)));

(Pdef(\blips, Pbind(
	\instrument, \pad,
	\dur, Prand([0.25, 0.125, 0.5, 1, 2, 8], inf) * Pfunc({
		~tempo;
	}),
	\freq, Prand(~key, inf) * Prand([1, 2, 4, 8, 16], inf),
	\atk, Pwhite(0.0, 0.1, inf),
	\dec, Pwhite(0.02, 0.3, inf),
	\mul, 0.15,
	\amp, Pwhite(0.2, 0.8, inf),
	\mmul, Pwhite(0.0, 2.5, inf),
	\r, Prand([1.5, 2.5], inf),
	\lp, Pwhite(200, 10000, inf),
	\lq, Pwhite(0.1, 1.0, inf),
	\hp, Pwhite(300, 3000, inf),
	\out, Prand([0, ~delayBus, ~reverbBus], inf)
)));

Ndef(\delay).play;
Ndef(\reverb).play;
Tdef(\tempo).play;
Pdef(\drums).play;
Pdef(\hats).play;
Pdef(\bass).play;
Pdef(\pads).play;
Pdef(\blips).play;

(
Ndef(\reverb, {
	var in;
	in = In.ar(~reverbBus, 2);
	in = FreeVerb.ar(in, \mix.kr(0.7), \room.kr(0.8), \damp.kr(0.5));
});



Ndef(\delay, {
	var aTrig, in, del;
	in = In.ar(~delayBus, 2);
	del = DelayN.ar(in, \del.kr(0.25), \del.kr);
	in = in.blend(del, 0.5 * \mix.kr(1));
	del = DelayN.ar(in, \del.kr(0.25), \del.kr);
	in = in.blend(del, 0.25 * \mix.kr(1));
	del = DelayN.ar(in, \del.kr(0.25), \del.kr);
	in = in.blend(del, 0.125 * \mix.kr(1));
	del = DelayN.ar(in, \del.kr(0.25), \del.kr);
	in = in.blend(del, 0.05 * \mix.kr(1));
	aTrig = Impulse.ar(40);
	SendReply.ar(aTrig, '/delaySig', in);
	in;
});
);

Ndef(\delay).set(\mix, 0.2);

(
if(~animation.notNil){
	~animation.close;
};
~animation = Window("animation", Rect(850, 210, 400, 400)).front.alwaysOnTop_(true);
~view = UserView(~animation, Rect(0, 0, 400, 400)).background_(Color.black);
~view2 = UserView(~animation, Rect(0, 0, 400, 400)).background_(Color(alpha: 0)).resize_(5);
~view.resize_(5);


 ~view.drawFunc_({
	~bBool = [0, 1, 2].choose;
	Pen.strokeColor_(Color(~snareEnv *1.2, ~hatEnv * 1.4, ~kickEnv * 1.4));
	Pen.width_(~hatEnv + (~hatEnv + ~snareEnv * 3) + (~padFreq * 0.00125) + 0.5 * (~kickEnv * 5) * 0.8);
	Pen.moveTo((150 + (~hatSig * 800) + (~padFreq.neg * 0.025) + (~kickSig.abs * 500.neg))@(150 + (~hatEnv * 200) + (~kickSig.abs * 600)));
	Pen.lineTo(((200 + (~hatEnv * 100) + (~bassEnv * 20) + (~kickEnv * 20.neg)) + (~kickSig * 600.neg))@(150  + (~kickEnv * 20)));
	Pen.lineTo((250 + (~snareEnv * 50) + (~kickEnv * 100.neg))@(150 + (~snareEnv * 50.neg) + (~kickEnv * 100)));
	Pen.lineTo((250 + (~hatEnv * 50.neg) + (~snareSig * 300))@(200 + (~delSig * 200) + (~padEnv * 100)));
	Pen.lineTo((250 + (~hatSig.abs * 2000) + (~bassEnv * 200.neg))@(250 + (~kickSig * 500) + (~hatSig * 1000)));
	Pen.lineTo((200 + (~kickSig * 800)  + (~bassSig * 100.neg) + (~hatSig * 1000))@(250 + (~padSig.abs * 200) + (~kickSig * 700.neg)  + (~hatSig * 2000)));
	Pen.lineTo((150 + (~kickSig * 500.neg)+ (~hatSig * 1000) + (~padFreq.neg * 0.005))@(250 + (~hatSig * 500.neg)));
	Pen.lineTo(((~snareEnv * 100) + (~delSig * 50) + 150 + (~bassFreq * 1.25))@200 + (~bassFreq.neg * 0.4));
	Pen.lineTo((150 + (~hatSig * 800) + (~padFreq.neg * 0.025) + (~kickSig.abs * 500.neg))@(150 + (~hatEnv * 200) + (~kickSig.abs * 600)));
	Pen.fillColor_(Color(~kickSig * 18.8, ~hatSig * 10, ~snareSig * 8 + (~padSig.abs * 5), ~tempo * 0.5 + (~bassEnv) * 1.2));
	Pen.fillStroke;
	~view.frameRate_(~bassFreq * 0.1 + ( 10 * ~kickEnv));
 });


~view.animate_(true);


);
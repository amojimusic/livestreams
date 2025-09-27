
~kick2VerbBus = Bus.audio(s, 2);
~delayBus = Bus.audio(s, 2);

~tonic = 47;
~tuning = [~tonic, ~tonic + 0.7, ~tonic + (0.7 * 2), ~tonic + (0.7 * 3), ~tonic + (0.7 * 4), ~tonic + (0.7 * 5), ~tonic + (0.7 * 6), ~tonic + (0.7 * 7), ~tonic + (0.7 * 8), ~tonic + (0.7 * 9), ~tonic + (0.7 * 10), ~tonic + (0.7 * 11), ~tonic + (0.7 * 12), ~tonic + (0.7 * 13), ~tonic + (0.7 * 14), ~tonic + (0.7 * 15), ~tonic + (0.7 * 16), ~tonic + (0.7 * 17)].midicps;


~tuning[6]/~tuning[0];

~key = [~tuning[0], ~tuning[3], ~tuning[5], ~tuning[7], ~tuning[10], ~tuning[12], ~tuning[14], ~tuning[0] * 2];


(

(Ndef(\arp, {
	var sendTrig, trig, freq, env, sig;
	sendTrig = Impulse.ar(80);
	trig = TDuty.ar(0.25, 0, 1);
	freq = Duty.ar(0.125, 0, Drand(~key, inf)) * Duty.ar(0.125, 0, Drand([1, 1, 2, 2, 1], inf));
	env = EnvGen.ar(Env([0, \amp.kr(1), 0], [\atk.kr(0.01), \dec.kr(0.2)]), trig);
	sig = SinOsc.ar(freq, 0, \mul.kr(1));

	sig = sig.blend(SinOsc.ar(freq * 1.224), 0.05);
	sig = sig.blend(SinOsc.ar(freq * 1.498), 0.1);
	sig = sig.blend(SinOsc.ar(freq * 2), 0.1);
	sig = sig.blend(SinOsc.ar(freq), 0.1);

	sig = Pan2.ar(sig * env, LFNoise2.ar(1.8, 0.7));
	sig = sig * 0.07;

	sig = Clip.ar(sig, -0.3, 0.3);


	SendReply.ar(sendTrig, '/arpSig', sig);
	SendReply.ar(sendTrig, '/arpFreq', freq);
	SendReply.ar(sendTrig, '/arpEnv', env);
	sig;
}));

Ndef(\delay).play;
Ndef(\delay) <<>.in1 Ndef(\acid);
Ndef(\delay) <<>.in2 Ndef(\arp);
Ndef(\delay) <<>.in3 Ndef(\arp2);

(Ndef(\delay, {
	var in, sig;
	in = \in1.ar([0, 0]).blend(\in2.ar([0, 0]), 0.6).blend(\in3.ar([0, 0]), 0.25);
	sig = in;
	sig = sig.blend(DelayN.ar(sig, 1, 1), 0.15);
	sig = sig.blend(DelayN.ar(sig, 1, 1), 0.1);
	sig = sig.blend(DelayN.ar(sig, 1, 1), 0.05);
	sig = FreeVerb.ar(sig, 0.2, 0.35, 0.4);
	sig = Clip.ar(sig, -0.4, 0.4) * 1.2;
}));


(Ndef(\arp2, {
	var sendTrig, trig, freq, env, sig;
	sendTrig = Impulse.ar(80);
	trig = TDuty.ar(0.25);
	freq = Duty.ar(0.25, 0, Drand(~key, inf)) * Duty.ar(0.25, 0, Drand([4, 8], inf));
	env = EnvGen.ar(Env([0, \amp.kr(1), 0], [\atk.kr(0.01), \dec.kr(0.2)]), trig);
	sig = SinOsc.ar(freq, 0, \mul.kr(1));



	sig = sig.blend(SinOsc.ar(freq * 1.224), 0.05);
	sig = sig.blend(SinOsc.ar(freq * 1.498), 0.1);
	sig = sig.blend(SinOsc.ar(freq), 0.1);


	sig = Pan2.ar(sig * env, LFNoise2.ar(2));
	sig = sig * 0.07;

	sig = Clip.ar(sig, -0.3, 0.3);


	SendReply.ar(sendTrig, '/arp2Sig', sig);
	SendReply.ar(sendTrig, '/arp2Freq', freq);
	SendReply.ar(sendTrig, '/arp2Env', env);
	sig;
}));


(Ndef(\acid, {
	var sendTrig, trig, freq, env, sig;
	sendTrig = Impulse.ar(80);
	trig = TDuty.ar(Dseq([Drand([1, Dseq([0.5], 2), Dseq([0.25], 4), Dseq([0.125], 8)], 1), Drand([0.5, Dseq([0.25], 1)], 1), 0.25, 0.25, 0.25, Drand([0.25, Dseq([0.125, 0.125], 1)], 1), 0.25, 0.125, 0.125, 0.25, 0.25, Drand([0.5, Dseq([0.25], 2), Dseq([0.125], 4)], 1)], inf));
	freq = Duty.ar(Drand([0.25, Dseq([0.125], 2)], inf), 0, Drand(~key, inf)) * Duty.ar(Drand([0.5, 1, 0.25, 0.5], inf));
	env = EnvGen.ar(Env.perc(\atk.kr(0.01), \dec.kr(0.35), \amp.kr(1), \curve.kr(0)), trig);

	sig = SinOsc.ar(freq, 0, \mul.kr(1));

	sig = sig.blend(SinOsc.ar(freq * 1.224), 0.05);
	sig = sig.blend(SinOsc.ar(freq * 1.498), 0.1);
	sig = sig.blend(SinOsc.ar(freq * 2), 0.1);
	sig = sig.blend(SinOsc.ar(freq), 0.1);

	sig = sig.blend(Saw.ar(freq, \mul.kr), 0.3);
	sig = sig.blend(Saw.ar(freq * 1.498), 0.05);
	sig = sig.blend(SinOsc.ar(freq, mul: \mul.kr), 0.1);
	sig = RLPF.ar(sig * env, LFNoise2.ar(0.3, 3300).abs + 300, 0.4 + (LFNoise2.ar(0.1, 0.4).abs)) * 0.7;

	sig = sig.softclip;
	sig = Pan2.ar(sig, LFNoise2.ar(0.5, 0.5));

	sig = sig * 0.4;
	sig = Clip.ar(sig, -0.3, 0.3);


	SendReply.ar(sendTrig, '/acidSig', sig);
	SendReply.ar(sendTrig, '/acidFreq', freq);
	SendReply.ar(sendTrig, '/acidEnv', env);

	sig;
}));



(Ndef(\kickVerb, {
	var in;
	in = In.ar(~kick2VerbBus, 2);
	in = FreeVerb.ar(in, 0.6, 0.225, 0.4).blend(in, 0.45) * 0.2;
	in = Clip.ar(in, -0.3, 0.3);
}));


(Ndef(\kick, {
	var gate, sendTrig, env, sig;
	gate = TDuty.ar(Drand([Dseq([0.5], 32), Drand([16, Dseq([Drand([1, Dseq([0.5], 2), Dseq([0.25], 4)], 1), Drand([1, Dseq([0.5], 2), Dseq([0.25], 4)], 1), Drand([0.5, Dseq([0.25], 2)], 1), 0.5, 0.5, 0.25, 0.25, 0.25, 0.25], 1), Dseq([Drand([1, Dseq([0.5], 2), Dseq([0.25], 4)], 1), Drand([1, Dseq([0.5], 2), Dseq([0.25], 4)], 1), Drand([0.5, Dseq([0.25], 2)], 1), 0.5, 0.5, 0.25, 0.25, 0.25, 0.25], 1), Dseq([Drand([1, Dseq([0.5], 2), Dseq([0.25], 4)], 1), Drand([1, Dseq([0.5], 2), Dseq([0.25], 4)], 1), Drand([0.5, Dseq([0.25], 2)], 1), 0.5, 0.5, 0.25, 0.25, 0.25, 0.25], 1), Dseq([0.25, 0.25], 8), Dseq([0.25, 0.25], 8)], 1)], inf)) * 4;
	SendReply.ar(gate, '/kickGate', 1);
	sendTrig = Impulse.ar(40);
	env = EnvGen.ar(Env.perc(\atk.kr(0.01), \dec.kr(0.03), \amp.kr(1), \curve.kr(0)), gate);
	sig = SinOsc.ar(10 + (env * 80) + (LocalIn.ar * 200 * env), 0, \mul.kr(1)) * env;
	sig = Pan2.ar(sig, \pan.kr(0), sig);
	sig = Clip.ar(sig, -0.25, 0.5);
	LocalOut.ar(sig.sum);
	sig = sig * 1.25;
	sig = Clip.ar(sig, -0.3, 0.3);
	SendReply.ar(sendTrig, '/kickSig', sig);
	SendReply.ar(sendTrig, '/kickEnv', env);
	sig;

}));

(SynthDef.new(\kick2, {
	var sendTrig, oneTrig, env, sig;
	sendTrig = Impulse.ar(80);
	oneTrig = Impulse.ar(0.000001);
	env = EnvGen.kr(Env.perc(\atk.kr(0.01), \dec.kr(0.05), \amp.kr(1), \curve.kr(0)), doneAction: 2);
	sig = SinOsc.ar(20 + (env * 50) + (LocalIn.ar * 700), 0, \mul.kr(1));
	sig = sig.softclip;
	LocalOut.ar(sig);
	sig = sig * env * 0.7;
	sig = FreeVerb.ar(sig, 0.2, 0.15, 0.1);
	sig = Pan2.ar(sig, \pan.kr(0));
	sig = RLPF.ar(sig, 440);
	SendReply.ar(oneTrig, '/kickGate', 1);
	SendReply.ar(sendTrig, '/kickSig', sig);
	SendReply.ar(sendTrig, '/kickEnv', env);
	Out.ar(~kick2VerbBus, sig);
}).add;
);


(SynthDef(\snare, {
	var gate, oneTrig, sendTrig, env, sig;
	gate = \gate.kr(0);
	oneTrig = Impulse.ar(0.0001) + \gate.kr;
	SendReply.ar(oneTrig, '/snareGate', gate);
	oneTrig = EnvGen.kr(Env.perc(0.01, 2), doneAction: 2);
	sendTrig = Impulse.ar(80);
	env = EnvGen.ar(Env.perc(\atk.kr(0.01), \dec.kr(0.1), \amp.kr(1), \curve.kr(0)));
	sig = SinOsc.ar(500 + (env * 80) + (LocalIn.ar * 200), 0, \mul.kr(1));
	sig = sig.blend(WhiteNoise.ar, 0.16);

	sig = Pan2.ar(sig, \pan.kr(0), sig);
	sig = sig * env;
	sig = sig.softclip * 0.46;
	sig = Clip.ar(sig, -0.2, 0.2);
	sig = (sig * 0.8).blend(FreeVerb.ar(sig, 0.0015, 0.0001, 0.8), 0.025).softclip;
	sig = (sig * 1.05).blend(FreeVerb.ar(sig, 0.002, 0.00125, 0.8), 0.0125);
	sig = RLPF.ar(sig, 8000+ LFNoise2.ar(LFNoise0.ar(0.5, 3).abs, 2000));
	sig = RHPF.ar(sig, 200 + LFNoise2.ar(LFNoise0.ar(0.5, 3).abs, 1000).abs.clip2(700));
	sig = FreeVerb.ar(sig, 0.2, 0.55, 0.75).blend(sig, 0.2);
	LocalOut.ar(sig.sum);
	sig = sig * 0.9;
	sig = Clip.ar(sig, -0.3, 0.3);
	SendReply.ar(sendTrig, '/snareSig', sig);
	SendReply.ar(sendTrig, '/snareEnv', env);
	Out.ar(\out.kr(0), sig);

}).add;);

(SynthDef(\hat, {
	var gate, oneTrig, sendTrig, env, sig;
	gate = \gate.kr(0);
	oneTrig = Impulse.ar(0.0000001);
	SendReply.ar(oneTrig, '/hatGate', 1);
	sendTrig = Impulse.ar(80);
	env = EnvGen.ar(Env.perc(\atk.kr(0.01), \dec.kr(0.05), \amp.kr(1), \curve.kr(0)), doneAction: 2);
	sig = Pulse.ar(440 + (WhiteNoise.ar(1)), 0.5, \mul.kr(1)).blend(Pulse.ar(447.1 + (WhiteNoise.ar(1)), 0,5, \mul.kr), 0.5);
	sig = sig.blend(WhiteNoise.ar, 0.115);
	sig = sig * env * 0.15;
	sig = RHPF.ar(sig, \hp.kr(3600));
	sig = Pan2.ar(sig, \pan.kr(0));
	sig = Clip.ar(sig, -0.3, 0.3);
	Out.ar(\out.kr(0), sig);
	SendReply.ar(sendTrig, '/hatSig', sig);
	SendReply.ar(sendTrig, '/hatEnv', env);
}).add;


);



Ndef(\kickVerb).play;

(OSCdef(\kickGate, {
	if(~kickIndex.isNil){
		~kickIndex = 0;
	};

	if(~kickIndex % 2 == 0){

	Synth(\hat);

	Task({
		wait(0.125);
			Synth(\hat, [\dec, [0.1, 0.05, 0.05, 0.05, 0.05, 0.03].choose, \pan, rrand(-0.3, 0.3)]);
	}).play;

	};

	if(~kickIndex % 25 == 0){

		Synth(\hat, [\dec, [0.1, 0.05, 0.05, 0.05, 0.03, 0.03, 0.2, 0.3].choose, \pan, rrand(-0.5, 0.5)]);

	Task({
		wait(0.125);
		Synth(\hat, [\dec, [0.1, 0.05, 0.05, 0.03, 0.05, 0.2, 0.3].choose]);
	}).play;

	};

	if(~kickIndex % 26 == 0){
		Synth(\hat, [\pan, rrand(-0.2, 0.2), \dec, [0.1, 0.05, 0.05, 0.03, 0.05, 0.05, 0.05].choose]);

	Task({
		wait(0.125);
		Synth(\hat);
	}).play;

	};

	if(~kickIndex % 30 == 0){

		Synth(\hat);

	Task({
		wait(0.125);
		Synth(\hat);
	}).play;

	};

	if(~kickIndex % 29 == 0){

		Synth(\hat);

	Task({
		wait(0.125);
		Synth(\hat);
	}).play;

	};


	if(~kickIndex % 4 == 0){
		Task({
			wait(0.5);
			Synth(\snare, [\sel, [0, 0, 0, 1, 2, 1, 0, 0, 0, 1].choose, \pan, rrand(-1.0, 1.0), \mul, rrand(0.8, 1.0), \out, [0, 0, 0, ~kick2VerbBus]]);
		}).play();
	};

	if(~kickIndex % 18 == 0){
		Task({
			Synth(\kick2, [\atk, rrand(0.01, 0.04), \dec, rrand(0.02, 0.12)]);
			wait(0.5);
			Synth(\snare, [\sel, [0, 0, 0, 1, 2, 1, 0, 0, 0, 1].choose, \mul, rrand(0.8, 1.0)]);
		}).play();
	};

	if(~kickIndex % 19 == 0){
		Task({
			wait(0.5);
			Synth(\snare, [\sel, [0, 0, 0, 1, 2, 1, 0, 0, 0, 1].choose, \mul, rrand(0.8, 1.0)]);
		}).play();
	};



	if(~kickIndex > 333){
		(Ndef(\kick, {
	var gate, sendTrig, env, sig;
	gate = TDuty.ar(Dseq([0.5, 0.5, 0.5, Drand([0.5, Dseq([0.25], 2)], 1), 0.5, 0.5, 0.25, 0.25, 0.25, Drand([0.25, 0.25, 0.25, 0.25, 0.25, Dseq([0.125], 2), Dseq([0.125], 2), Dseq([0.125/2], 4)], 1)], inf));
	SendReply.ar(gate, '/kickGate', 1);
	sendTrig = Impulse.ar(80);
	env = EnvGen.ar(Env.perc(\atk.kr(0.01), \dec.kr(0.03), \amp.kr(1), \curve.kr(0)), gate);
	sig = SinOsc.ar(10 + (env * 80) + (LocalIn.ar * 200 * env), 0, \mul.kr(1)) * env;
	sig = Pan2.ar(sig, \pan.kr(0), sig);
	sig = sig.softclip * 0.4;
	sig = Clip.ar(sig, -0.25, 0.5);
	sig = (sig * 1.1).blend(FreeVerb.ar(sig, 0.3, 0.01, 0.8), 0.25).softclip;
	sig = (sig * 1.05).blend(FreeVerb.ar(sig, 0.1, 0.25, 0.8), 0.125);
	LocalOut.ar(sig.sum);
	sig = sig * 1.2;
	sig = Clip.ar(sig, -0.3, 0.3);
	SendReply.ar(sendTrig, '/kickSig', sig);
	SendReply.ar(sendTrig, '/kickEnv', env);
	sig;

}));
		~kickIndex = -1;
	};


	~kickIndex = ~kickIndex + 1;
}, '/kickGate'));


(OSCdef(\kickSig, {
	arg msg;
	if(~kickSig.isNil){
		~kickSig = 0;
	};

	~kickSig = msg[3].asFloat;

}, '/kickSig'));

(OSCdef(\snareSig, {
	arg msg;
	if(~snareSig.isNil){
		~snareSig = 0;
	};

	~snareSig = msg[3].asFloat;

}, '/snareSig'));


(OSCdef(\snareGate, {

	if(~snareIndex.isNil){
		~snareIndex = 0;
	};

	if(~snareIndex % 10 == 0){
		Task({
			Synth(\kick2, [\atk, rrand(0.01, 0.04), \dec, rrand(0.02, 0.35)]);
			wait(0.125);
			Synth(\hat);
		}).play;
	};

	if(~snareIndex % 9 == 0){
		Task({
			wait(0.125);
			Synth(\hat);
		}).play;
	};

	if(~snareIndex % 27 == 0){
		Task({
			wait(0.125);
			Synth(\hat);
		}).play;
	};

	if(~snareIndex % 26 == 0){
		Task({
			wait(0.125);
			Synth(\hat);
		}).play;
	};

	if(~snareIndex % 20 == 0){
		Synth(\kick2, [\pan, rrand(-0.3, 0.3), \mul, 0.2]);
	};


	~snareIndex = ~snareIndex + 1;
}, '/snareGate'));

(OSCdef(\hatSig, {
	arg msg;
	if(~hatSig.isNil){
		~hatSig = 0;
	};

	~hatSig = msg[3].asFloat;
}, '/hatSig'));

(OSCdef(\hatGate, {
	arg msg;
	if(~hatIndex.isNil){
		~hatIndex = 0;
	};

	if(~hatIndex % 16 == 0){
		Task({
			wait(0.5);
			Synth(\snare, [\mul, 0.6, \sel, [0, 1, 2].choose]);
		}).play;
	};

	if(~hatIndex % 10 == 0){
		Synth(\snare, [\mul, 0.6, \sel, [1, 2].choose]);
	};

	if(~hatIndex % 20 == 0){
		Synth(\kick2, [\pan, rrand(-0.3, 0.3), \mul, 0.2]);
	};

	if(~hatIndex % 33 == 0){
		Synth(\kick2, [\pan, rrand(-0.3, 0.3), \mul, 0.2]);
	};


	~hatIndex = ~hatIndex + 1;
}, '/hatGate'));


(OSCdef(\kickEnv, {
	arg msg;
	if(~kickEnv.isNil){
		~kickEnv = 0;
	};

	~kickEnv = msg[3].asFloat;
}, '/kickEnv'));

(OSCdef(\snareEnv, {
	arg msg;
	if(~snareEnv.isNil){
		~snareEnv = 0;
	};

	~snareEnv = msg[3].asFloat;
}, '/snareEnv'));

(OSCdef(\hatEnv, {
	arg msg;
	if(~hatEnv.isNil){
		~hatEnv = 0;
	};

	~hatEnv = msg[3].asFloat;
}, '/hatEnv'));

(OSCdef(\arpSig, {
	arg msg;
	if(~arpSig.isNil){
		~arpSig = 0;
	};

	~arpSig = msg[3].asFloat;

}, '/arpSig' ));

(OSCdef(\arpFreq, {
	arg msg;
	if(~arpFreq.isNil){
		~arpFreq = 0;
	};

	~arpFreq = msg[3].asFloat;
}, '/arpFreq'));

(OSCdef(\arpEnv, {
	arg msg;
	if(~arpEnv.isNil){
		~arpEnv = 0;
	};

	~arpEnv = msg[3].asFloat;

}, '/arpEnv'));


(OSCdef(\arp2Sig, {
	arg msg;
	if(~arp2Sig.isNil){
		~arp2Sig = 0;
	};

	~arp2Sig = msg[3].asFloat;

}, '/arp2Sig' ));


(OSCdef(\arpF2req, {
	arg msg;
	if(~arp2Freq.isNil){
		~arp2Freq = 0;
	};

	~arp2Freq = msg[3].asFloat;
}, '/arp2Freq'));


(OSCdef(\arp2Env, {
	arg msg;
	if(~arp2Env.isNil){
		~arp2Env = 0;
	};

	~arp2Env = msg[3].asFloat;

}, '/arp2Env'));


(OSCdef(\acidSig, {
	arg msg;
	if(~acidSig.isNil){
		~acidSig = 0;
	};

	~acidSig = msg[3].asFloat;

}, '/acidSig' ));

(OSCdef(\acidFreq, {
	arg msg;
	if(~acidFreq.isNil){
		~acidFreq = 0;
	};

	~acidFreq = msg[3].asFloat;
}, '/acidFreq'));

(OSCdef(\acidEnv, {
	arg msg;
	if(~acidEnv.isNil){
		~acidEnv = 0;
	};

	~acidEnv = msg[3].asFloat;

}, '/acidEnv'));


);

(



~window = Window("animation", Rect(800, 75, 300, 300)).front.alwaysOnTop_(true);
~u = UserView(~window, Rect(0, 0, 300, 300));

~u.background_(Color.black);

~u.drawFunc_({
	Pen.strokeColor_(Color((~kickEnv * 2).clip2(1), (2 * ~snareEnv).clip2(1), (2 * ~hatEnv).clip2(1), ((~kickSig.abs * 2) + (~snareSig.abs * 2) + (~hatSig.abs * 2)).clip2(1)));
	Pen.width_(~kickEnv + ~snareEnv + ~hatEnv);
	Pen.addArc(150@150, (30 + (~kickSig.abs * 70) + (~snareSig.abs * 70) + (~hatSig.abs * 50)).clip2(80, 40), 0, 2pi);
	Pen.fillColor_(Color((~snareSig.abs * 3).clip2(1) , (~kickSig.abs * 3).clip2(1), (~hatSig.abs * 3).clip2(1), ((~kickEnv * 1.5) + (~snareEnv * 1.5)).clip2(1) ));
	Pen.fillStroke;

	Pen.strokeColor_(Color(0 + (~arp2Sig * 40).clip2(0.9), (0.6 + (~acidEnv * 0.025).clip2(0.2)).clip2(0.9), (0.8 + (~arpSig * 3).clip2(0.2)).clip2(0.9), 1));
	Pen.width_((~kickSig * 300 + 1).clip2(10));
	Pen.moveTo((50 + ((~acidFreq * 0.4).clip2(200)))@(50 + (~arp2Env * 50).clip2(150)));
	Pen.lineTo((75 + (~arpSig * 2000).abs.clip2(200))@(125 + ((~arp2Freq * 0.05).clip2(150))));
	Pen.lineTo((225 + (~acidEnv.neg * 150).clip2(200))@(175 + (~arp2Sig * 2000).clip2(300)));
	Pen.lineTo((250 + (~arpFreq.neg * 0.3).clip2(200))@(250 + (~arpEnv.neg * 100).clip2(300)));
	Pen.lineTo((150 + (~acidSig * 800).clip2(200))@((~arpSig.abs.neg * 4000).clip2(150) + 250));
	Pen.lineTo((50 + (10 + (~arp2Sig * 2000))).clip2(200)@(250 + (~arpSig * 800).clip2(110)));
	Pen.lineTo((75 + (~acidSig.abs * 3000)).clip2(100)@(175 + (~acidFreq * 0.3).clip2(50)));
	Pen.lineTo((225 + (~snareEnv * 2000)).clip2(200)@(125 + (~kickEnv * 2000).clip2(100)));
	Pen.lineTo((250 + (~arp2Env.neg * 100).clip2(50))@((~acidEnv * 50).clip2(50) + 50));
	Pen.lineTo((150 + (~arp2Sig * 2000).clip2(100))@(50 + (~arpSig.abs * 2000).clip2(100)));
	Pen.lineTo((50 + ((~acidFreq * 0.4).clip2(150)))@(50 + (~arp2Env * 50).clip2(100)));


	Pen.stroke;

});

~u.animate_(true);
~u.frameRate_(10.25);
~u.resize_(5);




);
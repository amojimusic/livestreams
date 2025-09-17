
(SynthDef.new(\kick, {
	var oTrig, env, sig;
	oTrig = Impulse.ar(0.00001);
	env = Env.perc(0.01, 0.12).kr(2);
	sig = LatoocarfianL.ar(500 + (env * 500)) * \mul.kr(1);
	sig = sig.blend(SinOsc.ar(10 + (env * 120) + (sig * 20), 0, \mul.kr(1)), 0.9) * env;
	sig = Pan2.ar(sig, \pan.kr(0));
	sig = sig.softclip * 1.1;
	SendReply.ar(oTrig, '/kickSig', sig);
	Out.ar(\out.kr(0), sig);
}).add;
);

(SynthDef.new(\snare, {
	var env, noise, sig;
	env = EnvGen.kr(Env.perc(\atk.kr(0.01), \dec.kr(0.1), \amp.kr(1), \curve.kr(0)), doneAction: 2);
	noise = WhiteNoise.ar(\mul.kr(1));
	sig = SinOsc.ar(400 + (env * 200 + (noise * 200)) + (noise * 800), 0, \mul.kr(1));
	sig = sig.blend(noise, 0.08);
	sig = sig * env * 0.7;
	sig = Pan2.ar(sig, \pan.kr(0));
	SendReply.ar(Impulse.ar(0.0001), '/snareSig', sig);
	Out.ar(\out.kr(0), sig);
}).add;
);


(Ndef(\acid, {
	var trig, freq, env, sig;
	trig = TDuty.ar(Dseq([0.25, 0.25, 0.5, 0.5, 0.25, 0.125, 0.125], inf), 0, 1);
	freq = Duty.ar(Dseq([0.25, 0.25, 0.5, 0.25, 0.125, 0.125, 0.5, Drand([0.5, Dseq([0.25], 2)], 1)], inf), 0, Dseq([Drand([\ton.kr(54), \ton.kr, \ton.kr + 1.5], 1), \ton.kr + 5, Drand([\ton.kr + 4, \ton.kr + 2, \ton.kr + 2.25, \ton.kr + 3.75], 1), Drand([\ton.kr + 7, \ton.kr + 7.25], 1)], inf)).midicps * Duty.ar(trig, 0, Drand([1, 2], inf));
	env = EnvGen.ar(Env([0, \amp.kr(1), 0], [\atk.kr(0.04), \dec.kr(1)]), trig);
	sig = LatoocarfianL.ar(freq, \a.kr(3), \b.kr(3), SinOsc.ar(0.2, 0, 0.1, 0.7), \d.kr(1.3) + SinOsc.ar(0.3, 0, 0.025)) * \mul.kr(1);
	sig = sig.blend(Saw.ar(freq * 0.5, \mul.kr), 0.15);
	sig = RLPF.ar(sig, 3000 + (env * 300) + (LatoocarfianL.ar(SinOsc.ar(0.3, mul: 3), SinOsc.ar(0.3, 0, 0.3), SinOsc.ar(0.5, 0, 2), 1.2, 1.5) * 2000), Clip.ar(LatoocarfianL.ar(3.8, 0.3, 0.2, 1.2, 1).abs * 0.9 + 0.1));
	sig = Pan2.ar(sig, LatoocarfianL.ar(8, 0.5, -1, 0.5, 1.2) * 0.4);
	sig = sig.blend(DelayN.ar(sig, 0.5, 0.5), 0.15);
	sig = sig.blend(DelayN.ar(sig, 0.5, 0.5), 0.075);
	sig = sig.blend(DelayN.ar(sig, 0.5, 0.5), 0.0375);
	sig = sig.blend(DelayN.ar(sig, 1, 1), 0.0375);
	sig = FreeVerb.ar(sig, 0.2, 0.5, 0.6);
	sig = sig * env * 0.3;
	SendReply.ar(trig, '/acidFreq', freq);
	sig = Clip.ar(sig, -0.3, 0.3);
}));

(Ndef(\arp, {
	var trig, freq, env, sig;
	trig = Impulse.ar(4);
	freq = Duty.ar(0.25, 0, Dseq([\ton.kr(54), \ton.kr + 2, \ton.kr + 5, \ton.kr + 7.125, \ton.kr + 1.75, \ton.kr + 12, \ton.kr + 2.125], inf)).midicps * Duty.ar(0.5, 0, Drand([4, 8, 16, 8, 8, 8], inf));
	env = EnvGen.ar(Env.perc, trig);
	sig = LatoocarfianL.ar(freq, 2.48, 2.5, 0.6, 1.2) * \mul.kr(1);
	sig = sig.blend(SinOsc.ar(freq * 0.25 + (sig * 3), 0, \mul.kr), 0.7);
	sig = sig * env;
	sig = sig.blend(DelayN.ar(sig, 0.5, 0.5), 0.25);
	sig = sig.blend(DelayN.ar(sig, 0.5, 0.5), 0.15);
	sig = sig.blend(DelayN.ar(sig, 0.5, 0.5), 0.075);
	sig = sig.blend(DelayN.ar(sig, 1, 1), 0.0375);
	sig = FreeVerb.ar(sig, 0.4, 0.8, 0.6);
	sig = Pan2.ar(sig, SinOsc.ar(0.175, 0, 0.3));
	sig = sig * 0.175;
	SendReply.ar(trig, '/arpFreq', freq);
	sig = Clip.ar(sig, -0.3, 0.3);
}));

(Ndef(\arp2, {
	var trig, freq, env, sig;
	trig = Impulse.ar(2);
	freq = Duty.ar(0.25, 0, Dseq([\ton.kr(54), \ton.kr + 2, \ton.kr + 5, Drand([\ton.kr, \ton.kr + 2, \ton.kr + 4, \ton.kr + 5, \ton.kr + 7, \ton.kr + 7.125, \ton.kr + 1.5], 1), \ton.kr + 1.75, Drand([\ton.kr, \ton.kr + 2, \ton.kr + 4, \ton.kr + 5, \ton.kr + 7, \ton.kr + 7.125, \ton.kr + 1.5, \ton.kr + 12], 1), \ton.kr + 2.125], inf)).midicps * Duty.ar(0.5, 0, Drand([4, 8, 16, 8, 8, 8], inf));
	env = EnvGen.ar(Env.perc, trig);
	sig = LatoocarfianL.ar(freq, 2.48, 2.5, 0.6, 1.2) * \mul.kr(1);
	sig = sig.blend(SinOsc.ar(freq * 0.25 + (sig * 3), 0, \mul.kr), 0.5);
	sig = sig * env;
	sig = sig.blend(DelayN.ar(sig, 0.5, 0.5), 0.25);
	sig = sig.blend(DelayN.ar(sig, 0.5, 0.5), 0.15);
	sig = sig.blend(DelayN.ar(sig, 0.5, 0.5), 0.075);
	sig = sig.blend(DelayN.ar(sig, 1, 1), 0.0375);
	sig = FreeVerb.ar(sig, 0.4, 0.8, 0.6);
	sig = Pan2.ar(sig, SinOsc.ar(0.2, 0.2, 0.3));
	sig = sig * 0.14;
	SendReply.ar(trig, '/arp2Freq', freq);
	sig = Clip.ar(sig, -0.3, 0.3);
}));


(Tdef(\acid, {loop{
	Ndef(\acid).set(\atk, rrand(0.01, 0.05));
	Ndef(\acid).set(\dec, rrand(0.3,  2.2));
	Ndef(\acid).set(\ton, 54);
	wait(3);
	Ndef(\acid).set(\ton, 61.125);
	Ndef(\arp).set(\ton, 61.125);
	Ndef(\arp2).set(\ton, 61.125);
	wait(0.25);
	Ndef(\acid).set(\atk, rrand(0.01, 0.05));
	Ndef(\acid).set(\dec, rrand(0.3, 2.2));
	Ndef(\acid).set(\ton, 54);
	Ndef(\arp).set(\ton, 54);
	Ndef(\arp2).set(\ton, 54);
	wait(1.25);
	Ndef(\acid).set(\ton, [54, 58.8, 54].choose);
	wait(0.5);
	Ndef(\acid).set(\ton, 54);
	wait(3);
}
}));

(OSCdef(\acidFreq, {
	if(~acidIndex.isNil){
		~acidIndex = 0;
	};
	if(~acidIndex % 5 == 0){
		Ndef(\acid).set(\ton, 54);
	};
	if(~acidIndex % 19 == 0){
		Ndef(\acid).set(\ton, 59.125);
		Ndef(\arp).set(\ton, 59.125);
		Ndef(\arp2).set(\ton, 59.125);
	};

	if(~acidIndex > 2000){
		~acidIndex = 0;
	};

	if(~acidIndex > 40){
		if(~acidIndex < 1300){

			if(~acidIndex % 4 == 0){
				Synth(\kick);
			};
		};
	};

	if(~acidIndex == 0){

		(Tdef(\acid, {loop{
			Ndef(\acid).set(\atk, rrand(0.01, 0.05));
			Ndef(\acid).set(\dec, rrand(0.3,  2.2));
			Ndef(\acid).set(\ton, 54);
			wait(3);
			Ndef(\acid).set(\ton, 61.125);
			Ndef(\arp).set(\ton, 61.125);
			Ndef(\arp2).set(\ton, 61.125);
			wait(0.25);
			Ndef(\acid).set(\atk, rrand(0.01, 0.05));
			Ndef(\acid).set(\dec, rrand(0.3, 2.2));
			Ndef(\acid).set(\ton, 54);
			Ndef(\arp).set(\ton, 54);
			Ndef(\arp2).set(\ton, 54);
			wait(1.25);
			Ndef(\acid).set(\ton, [54, 58.8, 54].choose);
			wait(0.5);
			Ndef(\acid).set(\ton, 54);
			wait(3);
		}
		}));
	};

	if(~acidIndex == 1600){
		(Tdef(\acid, {loop{
			~r = rrand(0.8, 1.5);
			Ndef(\acid).set(\atk, rrand(0.01, 0.05));
			Ndef(\acid).set(\dec, rrand(0.3,  2.2));
			Ndef(\acid).set(\ton, 54 * ~r);
			wait(3);
			Ndef(\acid).set(\ton, 61.125 * ~r);
			Ndef(\arp).set(\ton, 61.125 * ~r);
			Ndef(\arp2).set(\ton, 61.125 * ~r);
			wait(0.25);
			Ndef(\acid).set(\atk, rrand(0.01, 0.05));
			Ndef(\acid).set(\dec, rrand(0.3, 2.2));
			Ndef(\acid).set(\ton, 54 * ~r);
			Ndef(\arp).set(\ton, 54 * ~r);
			Ndef(\arp2).set(\ton, 54 * ~r);
			wait(1.25);
			Ndef(\acid).set(\ton, [54, 58.8, 54].choose * ~r);
			wait(0.5);
			Ndef(\acid).set(\ton, 54 * ~r);
			wait(3);
		}
		}));

	};
	~acidIndex = ~acidIndex + 1;
}, '/acidFreq'));

(OSCdef(\arpFreq, {
	if(~arpIndex.isNil){
		~arpIndex = 0;
	};

	if(~arpIndex % 15 == 0){
		Ndef(\arp).set(\ton, 54);
	};

	if(~arpIndex % 55 == 0){
		Ndef(\arp).set(\ton, 54);
	};

	if(~arpIndex % 25 == 0){
		Ndef(\acid).set(\ton, 57.75);
		Ndef(\arp).set(\ton, 57.75);
	};

	if(~arpIndex > 2000){
		~arpIndex = 0;
	};

	~arpIndex = ~arpIndex + 1;
}, '/arpFreq'));

(OSCdef(\kickSig, {
	if(~kickIndex.isNil){
		~kickIndex = 0;
	};

	if(~kickIndex % 2 == 0){
		Task({
			wait(0.5);
			Synth(\snare, [\mul, 0.8]);
		}).play();
	};

	if(~kickIndex % 6 == 0){
		Task({
			wait(0.5);
			Synth(\kick);
		}).play();
	};

	~kickIndex = ~kickIndex + 1;
}, '/kickSig'));

(OSCdef(\snareSig, {
	if(~snareIndex.isNil){
		~snareIndex = 0;
	};
	if(~snareIndex % 31 == 0){
		Task({
			wait(1);
			Synth(\kick);
		}).play();
	};

	~snareIndex = ~snareIndex + 1;
}, '/snareSig'));

(OSCdef(\arp2Freq, {
	if(~arp2Index.isNil){
		~arp2Index = 0;
	};
	if(~arp2Index > 800){
		if(~arp2Index < 1500){
			if(~arp2Index % 3 == 0){
				~b = [0, 1].choose;
				if(~b == 0){
					Synth(\kick);
				};
				if(~b == 1){
					Synth(\snare, [\mul, 0.5]);
				};
			};
		};
	};

	~arp2Index = ~arp2Index + 1;
	if(~arp2Index > 2000){
		~arp2Index = 0;
	};
}, '/arp2Freq'));

Ndef(\arp).play;
Ndef(\arp2).play;
Ndef(\acid).play;
Tdef(\acid).play;
~acidIndex;

s.scope;
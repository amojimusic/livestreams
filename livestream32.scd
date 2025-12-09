

~di = [12/17, 12/18, 12/19, 12/20, 12/21].choose;

Livestream.init;

(SynthDef.new(\synth, {
	var sig, env, mod, freq, pan, amp, mmul, rat, atk, dec, sendTrig;
	sendTrig = Impulse.ar(LFNoise0.ar(0.0003, 0.25).abs);
	freq = \freq.kr(440);
	amp = \amp.kr(1);
	pan = \pan.kr(0);
	mmul = \mmul.kr(1);
	rat = \r.kr(1.5);
	atk = \atk.kr(0.001);
	dec = \dec.kr(1);
	env = Env.perc(\atk.kr(0.001), \dec.kr(1), \amp.kr(1), -5.5).kr;
	mod = Saw.ar(\freq.kr(440) * \r.kr(1.5), \mmul.kr(1)) * (env * 2);
	sig = SinOsc.ar(\freq.kr(440) + (mod * 140), 0, \mul.kr(1));
	sig = sig.blend(Saw.ar(\freq.kr + (mod * 80) * 0.5, \mul.kr), 0.02);
	sig = sig.blend(SinOsc.ar(\freq.kr + (sig * 100 * env), 0, \mul.kr), 0.9);
	sig = sig * env;
	env = Env.perc(\atk.kr * 0.5, \dec.kr * 1.75, \amp.kr, -9).kr(2);
	sig = sig.blend(Saw.ar(\freq.kr * 2) * mod * 1.15 * env, 0.0105) * env;
	sig = sig.blend(Pulse.ar(\freq.kr + (sig * 100) * LFNoise0.ar(0.3, 2).abs) * mod * env, 0.0105) * env;

	sig = sig.blend(SinOsc.ar(\freq.kr * sig, 0, \mul.kr) * sig * env, 0.275);
	sig = sig.blend(GeneRand.ar(\freq.kr + (sig * 20)) * \mul.kr * env, LFNoise2.ar(0.3, 0.15).abs);

	sig = LPF.ar(sig, 3000 + (env * 3000), 0.7);
	sig = Pan2.ar(sig, \pan.kr(0));
	sig = sig * 0.5;
	sig = Clip.ar(sig, -0.5, 0.5);
	SendReply.ar(sendTrig, '/freq', freq);
	SendReply.ar(sendTrig, '/pan', pan);
	SendReply.ar(sendTrig, '/amp', amp);
	SendReply.ar(sendTrig, '/mmul', mmul);
	SendReply.ar(sendTrig, '/rat', rat);
	SendReply.ar(sendTrig, '/atk', atk);
	SendReply.ar(sendTrig, '/dec', dec);
	Out.ar(\out.kr(0), sig);
}).add;
);



(Livestream.reverbDef({
	var in, rev, del;
	in = In.ar(Livestream.reverbBus, 2);
	in = FreeVerb.ar(in, 0.3, 0.325, 0.9);
	rev = FreeVerb.ar(in, 1, 0.325, 0.9);
	rev = LPF.ar(rev, 5900);
	rev = HPF.ar(rev, 900);
	in = in.blend(DelayN.ar(rev, 0.1, 0.055), 0.5);
	del = DelayN.ar(in, 0.2, 0.2);
	in = in.blend(del, 0.1);
	del = DelayN.ar(in, 0.2, 0.2);
	in = in.blend(del, 0.05);
	del = DelayN.ar(in, 0.2, 0.2);
	in = in.blend(del, 0.1);
	del = DelayN.ar(in, 0.2, 0.2);
	in = in.blend(del, 0.025);
	del = DelayN.ar(in, 0.2, 0.2);
	in = in.blend(del, 0.02);
	del = DelayN.ar(in, 0.2, 0.2);
	in = in.blend(del, 0.025);
	del = DelayN.ar(in, 0.2, 0.2);
	in = in.blend(del, 0.02);
	del = DelayN.ar(in, 0.2, 0.2);
	in = in.blend(del, 0.025);
	in = FreeVerb.ar(in, 0.15, 0.7, 0.7);
});
);

(~pat = {
	~di = [12/17, 12/18, 12/19, 12/20, 12/21, 12/22].choose;

(Pdef(\hello, Pbind(
	\instrument, \synth,
		\amp, Pwhite(0.4, 0.8, inf),
		\dur, Pseq([0.25, 0.125/2, 0.125/2, 0.125, Prand([0.5, Pseq([0.25], 2), Pseq([0.125], 4)], 1)], inf) * 2 * rrand(0.9, 1.35),
	\dec, Pwhite(0.0125, rrand(0.25, 4), inf) * 0.7,
		\atk, Pwhite(0.0001, rrand(0.25, 4), inf) * 0.9,
	\r, Prand([0.25, 0.5, 1, 1.25, 1.5, 1.75, 1.125], inf),
		\mmul, Pseq([Pwhite(0.05, 0.5, 2), Pwhite(0.5, 10.0, 3), Pwhite(0.0, 30.0, 1)], inf),
	\mul, 0.4,
	\pan, Pseq([Pwhite(-1.0, 0.3, 3), Pwhite(-0.4, 0.4, 3), Pwhite(-0.3, 1.0, 3), Pwhite(-0.4, 0.4, 3)], inf),
		\freq, Pseq([50, [50 + (~di * [2, 4, 6, 8].choose), 50 + (~di * [1, 3, 5, 7, 9, 11].choose)], 50 + (~di * 3), 50 + (~di * 9), 50 + (~di * Prand([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 1)), Prand([[50, 50 + (~di * 6)], [50, 50 + (~di * 9)], [50, 50 + (~di * 12)]], 3)].midicps, inf) * Pseq([0.5, 0.5, 1, 2, 3, 5, 2, 4, Prand([2, 2, 8, 0.5], 1), 4], inf) * rrand(0.9, 1.1),
	\out, Livestream.reverbBus
)));
});



(Tdef(\patChange, {
	Livestream.playReverb;
	Pdef(\hello).play;
	loop{
		~pat.();
		wait(64);
	}
}));

(OSCdef(\freq, {
	arg freq;
	~freq = freq[3];
}, '/freq'));

(OSCdef(\amp, {
	arg amp;
	~amp = amp[3];
}, '/amp'));

(OSCdef(\pan, {
	arg pan;
	~pan = pan[3];
}, '/pan'));

(OSCdef(\mmul, {
	arg mmul;
	~mmul = mmul[3];
}, '/mmul'));

(OSCdef(\rat, {
	arg rat;
	~rat = rat[3];
}, '/rat'));

(OSCdef(\atk, {
	arg atk;
	~atk = atk[3];
}, '/atk'));

(OSCdef(\dec, {
	arg dec;
	~dec = dec[3];
}, '/dec'));

Tdef(\patChange).play;

(
//Window.closeAll;
w = Window("animation", Rect(700, 100, 300, 300)).front.alwaysOnTop_(true);
u = UserView(w, Rect(0, 0, 300, 300)).background_(Color.black);

u.drawFunc_({
	Pen.strokeColor_(Color((~amp * 1.5).clip2(0.99), (~freq * 0.05).clip2(0.99), rrand(0.5, 0.7), 1));
	Pen.moveTo(30@(20 + (~amp * 70)).clip2(40));
	Pen.lineTo(270@(20 + (~freq * 0.1)).clip2(40));
	Pen.stroke;

	Pen.strokeColor_(Color(~mmul.clip2(0.99), ~amp.clip2(0.99), ~pan.abs.clip2(0.99), 1));
	Pen.moveTo(30@(50 + (~pan.abs * 40)).clip2(65));
	Pen.lineTo(270@(50 + (~mmul * 20)).clip2(65));
	Pen.stroke;

	Pen.strokeColor_(Color(~dec.clip2(0.99), ~atk.clip2(0.99), ~pan.abs, 1));
		Pen.moveTo(30@(70 + (~mmul * 10)).clip2(85));
		Pen.lineTo(270@(70 + (~dec * 30)).clip2(85));
		Pen.stroke;
	Pen.strokeColor_(Color((~rat * 0.3).clip2(0.99), (~mmul * 0.1).clip2(0.99), ~amp.clip2(0.99), 1));
		Pen.moveTo(30@(90 + (~rat * 10)).clip2(105));
		Pen.lineTo(270@(90 + (~mmul * 20)).clip2(105));
		Pen.stroke;
	Pen.strokeColor_(Color(~rat.clip2(0.99), (~freq * 0.0025).clip2(0.99), (~amp.clip2(0.99)), 1));
	Pen.moveTo(30@((110 + (~freq * 0.1)).clip2(125)));
	Pen.lineTo(270@(110 + (~amp * 20)).clip2(125));
	Pen.stroke;

	Pen.strokeColor_(Color((~mmul * 0.2).clip2(0.99), ~amp.clip2(0.99), (~rat * 0.2).clip2(0.99)));
	Pen.moveTo(30@(130 + (~mmul * 10)).clip2(145));
	Pen.lineTo(270@(130 + (~rat * 10)).clip2(145));
	Pen.stroke;

	Pen.strokeColor_(Color(~pan.abs.clip2(0.99), (~freq * 0.00065).clip2(0.99), ~pan.abs.clip2(0.99)));
	Pen.moveTo(30@(160 + (~pan * 10)).clip2(165));
	Pen.lineTo(270@(150 + (~freq * 0.05)).clip2(165));
	Pen.stroke;

	Pen.strokeColor_(Color(~amp.abs.clip2(0.99), (~mmul * 0.65).clip2(0.99), ~pan.abs.clip2(0.99)));
	Pen.moveTo(30@(170 + (~amp * 10)).clip2(185));
	Pen.lineTo(270@(170 + (~rat * 10)).clip2(185));
	Pen.stroke;

	Pen.strokeColor_(Color(~amp.abs.clip2(0.99), (~amp * 0.65).clip2(0.99), ~amp.abs.clip2(0.99)));
	Pen.moveTo(30@(190 + (~mmul * 5)).clip2(205));
	Pen.lineTo(270@(190 + (~dec * 10)).clip2(205));
	Pen.stroke;

	Pen.strokeColor_(Color(~atk.abs.clip2(0.99), (~dec * 0.65).clip2(0.99), (~freq * 0.00002).clip2(0.99)));
	Pen.moveTo(30@(210 + (~dec * 8)).clip2(225));
	Pen.lineTo(270@(210 + (~atk * 10)).clip2(225));
	Pen.stroke;

	Pen.strokeColor_(Color((~rat * 0.2).clip2(0.99), ~amp.clip2(0.99), (~amp * 0.2).clip2(0.99)));
	Pen.moveTo(30@(230 + (~rat * 10)).clip2(245));
	Pen.lineTo(270@(230 + (~mmul * 10)).clip2(245));
	Pen.stroke;

	Pen.strokeColor_(Color(~dec.abs.clip2(0.99), (~atk * 0.65).clip2(0.99), (~freq * 0.00002).clip2(0.99)));
	Pen.moveTo(30@(250 + (~atk * 8)).clip2(265));
	Pen.lineTo(270@(250 + (~dec * 10)).clip2(265));
	Pen.stroke;

});

u.animate_(true);
u.frameRate_(18);





);



s.scope;





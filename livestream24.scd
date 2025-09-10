
~tonic = 50;

(
~scale = [~tonic, ~tonic + 0.5, ~tonic + 1, ~tonic + 1.5, ~tonic + 2, ~tonic + 2.5, ~tonic + 3, ~tonic + 3.5,
	~tonic + 4, ~tonic + 4.5, ~tonic + 5, ~tonic + 5.5, ~tonic + 6, ~tonic + 6.5, ~tonic + 7, ~tonic + 7.5, ~tonic + 8, ~tonic + 8.5, ~tonic + 9, ~tonic + 9.5, ~tonic + 10, ~tonic + 10.5, ~tonic + 11, ~tonic + 11.5].midicps;
);

(~key = [~scale[0],  ~scale[3], ~scale[4], ~scale[7], ~scale[11], ~scale[14], ~scale[16], ~scale[20], ~scale[23]]);

(SynthDef.new(\synth, {
	var trig, sendTrig, freq, pan, env, amp, mul, sig, mod;
	amp = \amp.kr(1);
	mul = \mul.kr(1);
	trig = Impulse.ar(1);
	sendTrig = Impulse.ar(4);
	freq = \freq.kr(440);
	mod = SinOsc.ar(freq * \r.kr(1.5) * ((~sig2.abs * 10) + 0.01), 0, \mmul.kr(1));
	freq = \freq.kr + (mod * 5);
	pan = \pan.kr(0) + SinOsc.ar(~freq1.abs * 0.25, 0, 0.3);
	env = EnvGen.ar(Env.perc(\atk.kr(0.01), \dec.kr(1) + (~freq2.abs * 0.00075), amp), doneAction: 2);
	sig = Saw.ar(freq, mul) * env;
	sig = Pan2.ar(sig, pan);
	sig = RLPF.ar(sig, \lp.kr(1000), \q.kr(1));
	sig = sig * 0.5;
	Out.ar(\out.kr(0), sig);
	SendReply.ar(sendTrig, '/freq1', freq);
	SendReply.ar(sendTrig, '/sig1', sig);
	SendReply.ar(sendTrig, '/pan1', pan);
}).add;
);

(SynthDef.new(\synth2, {
	var trig, sendTrig, freq, pan, env, amp, mul, sig, mod;
	amp = \amp.kr(1);
	mul = \mul.kr(1);
	trig = Impulse.ar(1);
	sendTrig = Impulse.ar(4);
	freq = \freq.kr(440);
	mod = Saw.ar(freq * \r.kr(1.5) * ((~sig1.abs * 10) + 0.01), \mmul.kr(1));
	freq = \freq.kr + (mod * 5);
	pan = \pan.kr(0) + SinOsc.ar(~freq2.abs * 0.25, 0, 0.3);
	env = EnvGen.ar(Env.perc(\atk.kr(0.01), \dec.kr(1) + (~freq1.abs * 0.00075), amp), doneAction: 2);
	sig = Pulse.ar(freq, 0.5,  mul) * env;
	sig = Pan2.ar(sig, pan);
	sig = RLPF.ar(sig, \lp.kr(1000), \q.kr(1));
	sig = sig * 0.5;
	Out.ar(\out.kr(0), sig);
	SendReply.ar(sendTrig, '/freq2', freq);
	SendReply.ar(sendTrig, '/sig2', sig);
	SendReply.ar(sendTrig, '/pan2', pan);
}).add;
);

(OSCdef(\freq1, {
	arg freq;
	~freq1 = freq[3].asFloat;
}, '/freq1'));

(OSCdef(\sig1, {
	arg sig;
	~sig1 = sig[3].asFloat;
}, '/sig1'));

(OSCdef(\pan1, {
	arg pan;
	~pan1 = pan[3].asFloat;
}, '/pan1'));


(OSCdef(\freq2, {
	arg freq;
	~freq2 = freq[3].asFloat;
}, '/freq2'));

(OSCdef(\sig2, {
	arg sig;
	~sig2 = sig[3].asFloat;
}, '/sig2'));

(OSCdef(\pan2, {
	arg pan;
	~pan2 = pan[3].asFloat;
}, '/pan2'));

(Pdef(\synths, Pbind(
	\instrument, Prand([\synth, \synth2], inf),
	\dur, Pseq([Prand([ 4, Prand([2, Pseq([0.25, 0.25, Prand([0.5, Pseq([0.25], 2), Pseq([0.125], 4)], 1), Prand([1, Pseq([0.5], 2), Pseq([0.25], 4), Pseq([0.125], 8)], 1)], Prand([2, 4], 1))], 1)], 1)], inf),
	\amp, 0.2,
	\mul, 0.5,
	\mmul, Pwhite(0.01, 3.0, inf),
	\r, Prand([1.5, 2.5, 3, 5, 7, 11], inf),
	\atk, Pwhite(0.01, 0.05, inf),
	\dec, Pwhite(0.05, 2.5, inf),
	\lp, Pwhite(400, 4000, inf),
	\pan, Pwhite(-0.6, 0.6, inf),
	\freq, Prand(~key, inf) * Pseq([0.5, 1, 2, 4, 8], inf);
)));


Pdef(\synths).play;



(
var window, user;
Window.closeAll;
window = Window("animation", Rect(0, 0, 1000, 700)).front.alwaysOnTop_(true);
user = UserView(window, Rect(0, 0, 1000, 700));
user.drawFunc_({
	user.background_(Color((50 * ~sig1.abs) * (20 *~sig2.abs) + 0.01, ~sig2.abs * ~pan1.abs, (~pan2 * 0.2) + (0.3)));
	Pen.moveTo((~pan1.abs * 400 + 100)@(~freq1 * 0.1 + 200));
	Pen.lineTo((~pan1.abs * 500 + 100)@(~sig1.abs * 1000 + 50 + 500));
	Pen.strokeColor_(Color((~freq2 * 0.0008) * 0.5 + 0.2 * 0.8, ~sig1.abs * 1000 + 0.1, ~pan2.abs * 0.8));
	Pen.lineTo(((~sig2.abs * 200) + 20)@(~pan1.abs * 400 + 500));
	Pen.lineTo((~freq2.abs * 0.07 + (200 * (~pan2.abs * 4)))@(~pan2.abs * 500 + 30));
	Pen.lineTo(((~freq1.abs * 0.25) + 150)@((~freq2.abs * 0.25) + 200));
	Pen.lineTo((~pan1.abs * 400 + 100)@(~freq1 * 0.1 + 200));
	Pen.width_(~sig2.abs * 3000 + 2);
	Pen.stroke;
});

user.frameRate_(25);
user.animate_(true);
);








































Gremlin();

(
(Ndef(\sine, {
	var sig, duty, trig, env, sendTrig;
	sendTrig = Impulse.ar(2);
	trig = TDuty.ar(Dseq([0.125, 0.125, 0.25, Drand([0.5, Dseq([0.25], 2), Dseq([0.125], 4)], Drand([1, 3, 5], 1)), Drand([1, Dseq([0.5], 2), Dseq([0.25], 4)], 1), 0.5, 0.25, 0.25] * \tempoR.kr(1), inf));
	env = EnvGen.ar(Env.perc(0.04, 0.07), trig);
	duty = Duty.ar(0.125, 0, Drand([1, 1.125, 1.3, 1.6, 1.9, 1.25, 1.5, 1.75, 1.8275, 1.4, 1.8] * Drand([0.25, 0.5, 1.5, 2.5, 2.25, 2.15, 1, 2, 4, 8, 4.4, 4.5, 3.75], inf) * \freqR.kr(1), inf));
	sig = RandWave.ar(200 * duty, 3, \mul.kr(1)) * env;
	sig = sig.blend(Saw.ar(200 * duty, \mul.kr) * env, 0.4);
	sig = RLPF.ar(sig, 1000 + (env * 1000));
	sig = Pan2.ar(sig, \pan.kr(0));
	sig = Limiter.ar(sig * 0.3, 0.8);
	SendReply.ar(sendTrig, '/sine', [sig, duty, env]);
	Out.ar(\out.kr(0), sig);
	Out.ar(\out2.kr(0), sig);

}));

(Ndef(\sine2, {
	var sig, duty, trig, env;
	trig = TDuty.ar(Dseq([0.125, 0.125, 0.25, 0.5, Drand([1, Dseq([0.5], 2), Dseq([0.25], 4)], 1), 0.5, 0.25, 0.25] * \tempoR.kr(1), inf));
	env = EnvGen.ar(Env.perc(0.01, 0.25), trig);
	duty = Duty.ar(0.125, 0, Drand([1, 1.125, 1.3, 1.6, 1.9, 1.25, 1.5, 1.75, 1.8275, 1.4, 1.8] * Drand([0.25, 0.5, 1.5, 2.5, 2.25, 2.15, 1, 2], inf) * \freqR.kr(1), inf));
	sig = RandWave.ar(200 * duty, 2, \mul.kr(1)) * env;
	sig = sig.blend(Saw.ar(200 * duty, \mul.kr) * env, 0.4);
	sig = RLPF.ar(sig, 1000 + (env * 400));
	sig = Pan2.ar(sig, \pan.kr(0));
	sig = Limiter.ar(sig * 0.3, 0.8);
	Out.ar(\out.kr(0), sig);
	Out.ar(\out2.kr(0), sig);
}));

(Ndef(\sine3, {
	var sig, duty, trig, env;
	trig = TDuty.ar(Dseq([0.125, 0.125, 0.25, Drand([0.5, Dseq([0.25], 2)], Drand([1, 3, 5], 1)), Drand([1, Dseq([0.5], 2) * 8, Dseq([0.25], 4)], 1), 0.5, 0.25, 0.25] * \tempoR.kr(1), inf));
	env = EnvGen.ar(Env.perc(0.4, 0.85, 1, 0), trig);
	duty = Duty.ar(0.125, 0, Drand([1, 1.125, 1.3, 1.6, 1.9, 1.25, 1.5, 1.75, 1.8275, 1.4, 1.8] * Drand([0.25, 0.5, 1.5, 2.5, 2.25, 2.15, 1, 2], inf) * \freqR.kr(1), inf));
	sig = GeneRand.ar(200 * duty, \mul.kr(1)) * env;
	sig = sig.blend(Saw.ar(200 * duty, \mul.kr), 0.3);
	sig = RLPF.ar(sig, 4000 + (env * 500));
	sig = Pan2.ar(sig, \pan.kr(0));
	sig = Limiter.ar(sig * 0.083, 0.8);
	Out.ar(\out.kr(0), sig);
	Out.ar(\out2.kr(0), sig);
}));

(Ndef(\sine4, {
	var sig, duty, trig, env;
	trig = TDuty.ar(Dseq([0.125, 0.125, 0.25, 0.5, Drand([1, Dseq([0.5], 2), Dseq([0.25], 4)], 1), 0.5, 0.25, 0.25] * \tempoR.kr(1), inf));
	env = EnvGen.ar(Env.perc(0.04, 0.07), trig);
	duty = Duty.ar(0.125, 0, Drand([1, 1.125, 1.3, 1.6, 1.9, 1.25, 1.5, 1.75, 1.8275, 1.4, 1.8] * Drand([0.125, 0.125, 0.25, 0.5, 0.5, 1, 0.25, 0.5, 1.5, 2.5, 2.25, 2.15, 1, 2, 4, 8, 4.4, 4.5, 3.75], inf) * \freqR.kr(1), inf));
	sig = RandWave.ar(200 * duty, 3, \mul.kr(1)) * env;
	sig = RLPF.ar(sig, 1000 + (env * 1000));
	sig = Pan2.ar(sig, \pan.kr(0));
	sig = Limiter.ar(sig * 0.3, 0.8);
	Out.ar(\out.kr(0), sig);
	Out.ar(\out2.kr(0), sig);
}));



(Tdef(\pan, {
	loop{
		Ndef(\sine).set(\pan, rrand(-0.6, 0.6));
		Ndef(\sine2).set(\pan, rrand(-0.4, 0.4));
		Ndef(\sine3).set(\pan, rrand(-0.8, 0.8));
		Ndef(\sine4).set(\pan, rrand(-1.0, 1.0));
		wait([2, 4, 8].choose);

}}));

(Tdef(\buses, {
	loop{
		Ndef(\sine).set(\out, [~gremReverbBus, ~gremReverb2Bus, ~gremDelayBus, ~gremFilterBus].choose);
		Ndef(\sine).set(\out2, [~gremReverbBus, ~gremReverb2Bus, ~gremDelayBus, ~gremFilterBus].choose);
		Ndef(\sine2).set(\out, [~gremReverbBus, ~gremReverb2Bus, ~gremDelayBus, ~gremFilterBus].choose);
		Ndef(\sine2).set(\out2, [~gremReverbBus, ~gremReverb2Bus, ~gremDelayBus, ~gremFilterBus].choose);
		Ndef(\sine3).set(\out, [~gremReverbBus, ~gremReverb2Bus, ~gremDelayBus, ~gremFilterBus].choose);
		Ndef(\sine3).set(\out2, [~gremReverbBus, ~gremReverb2Bus, ~gremDelayBus, ~gremFilterBus].choose);
		Ndef(\sine4).set(\out, [~gremReverbBus, ~gremReverb2Bus, ~gremDelayBus, ~gremFilterBus].choose);
		Ndef(\sine4).set(\out2, [~gremReverbBus, ~gremReverb2Bus, ~gremDelayBus, ~gremFilterBus].choose);
		wait([8, 16, 32, 64, 128].choose);
}}));

(Tdef(\ratios, {
	loop{
		~keyRatio = rrand(0.5, 1.1);
		~tempoRatio = rrand(0.95, 3.05);
		Ndef(\sine).set(\freqR, ~keyRatio);
		Ndef(\sine).set(\tempoR, ~tempoRatio);
		Ndef(\sine2).set(\freqR, ~keyRatio);
		Ndef(\sine2).set(\tempoR, ~tempoRatio);
		Ndef(\sine3).set(\freqR, ~keyRatio);
		Ndef(\sine3).set(\tempoR, ~tempoRatio);
		Ndef(\sine4).set(\freqR, ~keyRatio);
		Ndef(\sine4).set(\tempoR, ~tempoRatio);
		wait([32, 64, 128, 256].choose * [0.5, 1, 2, 4, 8, 16].choose);
}}));

(Tdef(\gui, {
	loop{
		~dMixSlider.valueAction_(rrand(0.7, 1.0));
		~r1MixSlider.valueAction_(rrand(0.7, 1.0));
		~r2MixSlider.valueAction_(rrand(0.7, 1.0));
		~r1MulSlider.valueAction_(rrand(0.85, 1.0));
		~r2MulSlider.valueAction_(rrand(0.85, 1.0));
		~dMulSlider.valueAction_(rrand(0.75, 1.0));
		~fResSlider.valueAction_(rrand(0.725, 0.975));
		~fMulSlider.valueAction_(rrand(0.85, 0.975));
		~r1RoomSlider.valueAction_(rrand(0.3, 1.0));
		~r2RoomSlider.valueAction_(rrand(0.3, 1.0));
		~dTimeKnob.valueAction_(rrand(0.3, 1.0));
		~r1DampSlider.valueAction_(rrand(0.3, 1.0));
		~r1AmpSlider.valueAction_(rrand(0.3, 1.0));
		~r1FreqKnob.valueAction_(rrand(0.3, 1.0));
		~r2DampSlider.valueAction_(rrand(0.3, 1.0));
		~r2AmpSlider.valueAction_(rrand(0.3, 1.0));
		~r2FreqKnob.valueAction_(rrand(0.3, 1.0));
		wait([8, 16, 32].choose);
}}).clock_(AppClock));

(Tdef(\filterSweep, {
	loop{
		~fTypeDropDown.valueAction_([0, 1, 2].choose);
		~fFreqKnob.valueAction_(0.3);
		wait(0.09);
		~fFreqKnob.valueAction_(0.2);
		wait(0.09);
		~fFreqKnob.valueAction_(0.3);
		wait(0.09);
		~fFreqKnob.valueAction_(0.4);
		wait(0.09);
		~fFreqKnob.valueAction_(0.5);
		wait(0.09);
		~fFreqKnob.valueAction_(0.6);
		wait(0.09);
		~fFreqKnob.valueAction_(0.7);
		wait(0.09);
		~fFreqKnob.valueAction_(0.8);
		wait(0.09);
		~fFreqKnob.valueAction_(0.9);
		wait(0.09);
		~fFreqKnob.valueAction_(1.0);
		wait(0.08);
		~fFreqKnob.valueAction_(0.9);
		wait(0.09);
		~fFreqKnob.valueAction_(0.8);
		wait(0.09);
		~fFreqKnob.valueAction_(0.7);
		wait(0.09);
		~fFreqKnob.valueAction_(0.6);
		wait(0.09);
		~fFreqKnob.valueAction_(0.4);
		wait(0.09);
		~fFreqKnob.valueAction_(0.3);
		wait(0.09);
		~fFreqKnob.valueAction_(0.2);
		wait(0.09);
		~fFreqKnob.valueAction_(0.3);
		wait(0.09);
}}).clock_(AppClock));

);

Gremlin.new;
Ndef(\sine).play;
Ndef(\sine2).play;
Ndef(\sine3).play;
Ndef(\sine4).play;

Ndef(\sine).set(\out, 0);

Tdef(\buses).play;
Tdef(\ratios).play;
Tdef(\gui).play(AppClock);
Tdef(\filterSweep).play(AppClock);
Tdef(\pan).play;
Gremlin.playFx;

s.scope.view.alwaysOnTop_(true);


~animation = Window.new("animation", Rect(800, 50, 300, 300)).front.alwaysOnTop_(true);
~thing = UserView.new(~animation, Rect(0, 0, 3000, 3000));

(OSCdef.new(\sine1Def, {
	arg msg;
	msg.postln;
	{
		~thing.background_(Color(msg[3] * 0.2, msg[3] * 0.3, (msg[3] * 2) + 0.15, 1));

	~thing.drawFunc_({


			Pen.moveTo(((msg[3] * 20) + 25)@100);
			Pen.lineTo((200 + (msg[3] * 20))@(msg[3]*30 * 2));
			Pen.width_(msg[3] + 2 * rrand(0.5, 3.0));
			Pen.strokeColor_(Color(0.2 + (msg[3] * 0.05).abs, 0.1 + (msg[3] * 0.001).abs, (0.2*(msg[3]*rrand(0.01, 1.0))), 1));
			Pen.lineTo(100@(200 * (msg[3] * 2)));
		Pen.stroke;
	});
		~thing.refresh;

}.defer
}, '/sine'));

(OSCdef.new(\sine1Def2, {
	arg msg;
	{
		~thing.drawFunc_({
			Pen.moveTo((msg[3] * 300 + 20 * 50)@(msg[3] * 30 + 10 * 20));
			Pen.lineTo(200@200);
			Pen.width_(msg[3] * 20 + 2);
			Pen.color_(Color(msg[3] + 0.4, msg[3] * 2, msg[3] * 0.5));
			Pen.stroke;

		});
		~thing.refresh;
	}.defer;

}, '/sine_2'));

~thing.animate_(true);














































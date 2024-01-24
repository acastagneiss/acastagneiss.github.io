
// set server options

(
s.options.numOutputBusChannels_(8);
ServerOptions.outDevices; // output devices
Server.default.options.outDevice_("Built-in Output");
)


//boot server
s.boot

//set limit
Safety.setLimit(0.5)

//check sound & volume
s.meter
s.volume.gui




/// ___ SAMPLER ___ ///

//load the sample

b = Buffer.read(s, "samples/...".resolveRelative); //insert your own sample here

//create a synthDef

(
SynthDef.new(\sampler, {
	var sig, env;

	sig = LoopBuf.ar(
		numChannels: 2,
		bufnum: \buf.kr(0),
		rate: BufRateScale.kr(\buf.kr(0)) * \rate.kr(1),
		startPos: \spos.kr(0),
		startLoop: \startloop.ir(0),
		endLoop: \endloop.ir(5000),
		//interpolation: 1
	);

	env = EnvGen.kr(
		Env(
			levels: [0,1,0],
			times: [\atk.ir(0.02), \rel.ir(3)],
			curve: [-2, -4],
		),
		doneAction: 2
	);

	sig = Pan2.ar(sig, \pan.kr(0));
	sig = sig * env;
	sig = sig * \amp.kr(1);

	Out.ar(\out.kr(0), sig);
}).add;)





////create a routine for the synth

(
w = Routine.new({
	y = 0;
	u = [-3,-2,-1,0,1,2,3,4,5,6,7,8];
	inf.do({

		y.postln;
			if(y >= 70, {

			(

Array.fill(3, {u.choose}).do({ |n|
(
Synth.new(
	\sampler,
	[
		buf: b.bufnum,
		rate: n.midiratio
				* rrand(0.2,-0.2).midiratio,
				//* [-1,1].choose,
		pan: 2,
		atk: 100,
		rel: 20,
		spos: 100000,
		startloop: 100000,
		endloop: 100000 + rrand(4000,2000).postln,
		out: 0
	]
);
)
			}))

		}, {"pass".postln});


		70.do({
			0.5.wait;
			y = y + 1;
			//y.postln;

		});
		if (y >= 140, { y = 0 },{ y = y});


	});
});
)

//play the routine (1)

w.play




/// ____NOISE___ ///

// load a sample


x = Buffer.readChannel(s, "samples/...", channels:[0]); //insert your own sample here

// create a second synthDef

((
SynthDef("noise", {arg position = 0.1,
		duration = 25, rate= 0.2, trigger1 = 30,
		trigger2 = 30;

		var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar([trigger1,trigger2]),
		5, ///duration 2
		x,
		rate,
		position, //position 0.3
		2,
		0,
		-1,
		512);

	sig = Pan2.ar(sig, 0);


	Out.ar(0, sig)}
).add))



////create a routine (2)

(
o = Routine.new({
	m = 0;
	inf.do({

		y.postln;
			if(m >= 70, {

			(

1.do(
	v = Synth.new(\noise,
			[
							\rate, 1,
							\position, 0.1,
							\duration, 6,
							\trigger1, 20,
							\trigger2, 20]
					)

			))

		}, {"pass".postln});


		70.do({
			0.1.wait;
			m = m + 1;
			m.postln

		});
		if (m >= 140, { m = 0 },{ m = m; v.free;

			70.do(
				20.wait;)
		});


	});
});
)

//play routine (2)

o.play






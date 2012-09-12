package
{

import flash.display.Sprite;
import flash.text.TextField;

import org.computus.utils.timekeeper.Timekeeper;
import org.computus.utils.timekeeper.TimekeeperEvent;

public class TimekeeperExample extends Sprite
{
	private var textField:TextField;
	private var timekeeper:Timekeeper;
	private var date:Date;

	public function TimekeeperExample()
	{
		textField = new TextField();
		textField.width = 300;
		addChild(textField);

		// create a date once and re-use it.
		date = new Date();


		// create an instance of the timekeeper
		timekeeper = new Timekeeper();

		// listen for ticks
		timekeeper.addEventListener( TimekeeperEvent.CHANGE, onTick );

		// a couple of convenience functions...

		// tick in real-time, at one tick per second
		timekeeper.setRealTimeTick();

		// set the value of the timekeeper to the current time
		timekeeper.setRealTimeValue();

		// now start ticking!
		timekeeper.startTicking();
	}

	private function onTick(event:TimekeeperEvent):void
	{
		// the value of event.time is the number of milliseconds since the Unix epoch
		var ms:Number = event.time;

		// turn the value into a Date
		date.time = ms;

		textField.text = ms.toString() + "  " + date.toString();
	}
}
}

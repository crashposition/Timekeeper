/*	
	====================================================================================
	2009 | John Dalziel  | The Computus Engine  |  http://www.computus.org

	All source code licenced under The MIT Licence
	====================================================================================  	
*/

package org.computus.utils.timekeeper
{
	import flash.events.*;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	/**
	 * Accurate Timekeeper in AS3.
	 * A solution to the problem of isochronism in the Flash Player.
	 * 
	 * <p>PROBLEM<br/>
	 * Both 'onEnterFrame' and 'Timer' events have variable periodicity and cannot be relied upon to keep reliable time.</p>
	 * 
	 * <p>SOLUTION<br/>
	 * The timekeeper works by keeping a very fast internal regulator to update a slower user clock.
	 * Periodic accuracy is achieved by referencing the system clock and maintaining an accumulator.</p>
	 * 
	 * <p>FEATURES
	 * <ul><li>Stop and start the timekeeper</li>
	 * <li>Get and set the time (in milliseconds)</li>
	 * <li>Get and set the tickFrequency. Default = every 1 second</li>
	 * <li>Get and set the tickDuration. Default = 1 second</li></ul><p>
	 * 
	 * <p>LIMITATIONS
	 * <ul><li>tickDuration values smaller than one second will work but are not recommended.</li>
	 * <li>For capacity reasons the datatype for both 'time' and 'tickDuration' is Number.</li>
	 * <li>For speed reasons the datatype for 'time' is Number, rather than a Date.</li>
	 * <li>Conversion to Date is really simple: var d = new Date(time)</li></ul></p>
	 * 
	 * @see org.computus.utils.timekeeper.TimekeeperEvent
  	 */

	public class Timekeeper extends EventDispatcher
	{

	// ------------------------------------------
	// PROPERTIES
	
		// user defined 'tick' duration and frequency 
		/** @private */
		protected var _time:Number;						// user time in ms since Uinx epoch
		
		/** @private */
		protected var _isTicking:Boolean 	= false;	// is user clock ticking?
		
		/** @private */
		protected var _tickFrequency:int	= 1000;		// 1 second
		
		/** @private */
		protected var _tickDuration:Number	= 1000;		// per second
	
		// internal system timekeeper
		/** @private */
		private var _regulator:Timer;					// system timekeeper
		
		/** @private */
		private var _regulatorAcc:int;					// ms accumulated since last 'tick'
		
		/** @private */
		private var _regulatorCache:int = 0;			// previous value of getTimer()

		/** @private */
		private var _timekeeperEvent:TimekeeperEvent;	// tick event

		// ------------------------------------------
	// CONSTRUCTOR

		/**
		 * Creates a new instance of the Timekeeper() class.
		 */
		public function Timekeeper():void
		{
			super();
			init();
		}
		
	// ------------------------------------------
	// MEMORY MANAGEMENT
		
		/**
		 * Removes all listeners and prepares the class for disposal.
		 */
		public function destroy():void
		{
			// Cleanup listeners
			_regulator.removeEventListener(TimerEvent.TIMER, onTimerEvent);
		}
				
	// ------------------------------------------
	// PUBLIC

		// convenient 'real time' functions
		/**
		 * A convenience function to set the value of the timekeeper to the current "real time".
		 */
		public function setRealTimeValue():void
		{
			var d:Date = new Date();
			_time = d.valueOf();
		}
		
		/**
		 * A convenience function to set the tick frequency and duration of the timekeeper to "real time", e.g. one second per second.
		 */
		public function setRealTimeTick():void
		{
			tickDuration = 1000;
			tickFrequency = 1000;
		}
		
		// Stop / Start ticking
		/**
		 * Stops the Timekeeper from ticking.
		 */
		public function stopTicking():void	{ _isTicking = false }

		/**
		 * Starts the Timekeeper ticking.
		 */
		public function startTicking():void	{ _isTicking = true }

	// ------------------------------------------
	//  GETTERS and SETTERS
		
		/** 
		 * A Boolean indicating if the Timekeeper is ticking or not.
		 * */
		public function get isTicking():Boolean	{ return _isTicking }
		
		 /**
		 * The current time value of the Timekeeper measured in milliseconds since the standard Unix epoch 1.1.1970.
		 */		
		public function set value( ms:Number ):void 
		{
			if (_time != ms )
			{
				_time = ms;

				// dispatch onChange TimekeeperEvent
				_timekeeperEvent.time = _time;
				dispatchEvent(_timekeeperEvent);
			}
		}
		
		/** @private */
		public function get value():Number { return _time }
	
		 /**
		 * The length of time in milliseconds the timekeeper is incremented after each tick. 
		 * Negative values will make the timekeeper tick backwards
		 */	
		public function set tickDuration( ms:Number ):void { _tickDuration = ms }

		/** @private */
		public function get tickDuration():Number { return _tickDuration }

		// Tick frequency in milliseconds
		 /**
		 * The length of time in milliseconds between ticks of the timekeeper. 
		 * 1000 milliseconds (one second) is recommended and values below 100 milliseconds are prone to isochronism.
		 */	
		public function set tickFrequency( ms:int ):void { _tickFrequency = ms }

		/** @private */
		public function get tickFrequency():int { return _tickFrequency }
				
	// ------------------------------------------
	// INTERNAL REGULATOR
	
		/** @private */
		private function init():void
		{
			// create an event we can reuse
			_timekeeperEvent = new TimekeeperEvent( TimekeeperEvent.CHANGE, _time );

			_regulatorAcc = 0;
			_regulatorCache = getTimer();
			_regulator = new Timer( 50 );	// updates regulator 20 times per second
			_regulator.addEventListener(TimerEvent.TIMER, onTimerEvent);
			_regulator.start();
		}

		/** @private */
		private function onTimerEvent( e:TimerEvent ):void
		{
			var regulatorNew:Number 	= getTimer();						// get system timer value
			var regulatorDelta:Number 	= regulatorNew - _regulatorCache;	// calculate elapsed time since last 'tick'
			_regulatorAcc 				+= regulatorDelta;					// increment accumulator
			
			if ( _regulatorAcc > _tickFrequency )							// check for a tick
			{
				// update user time
				if ( _isTicking == true ) { value = _time + _tickDuration }
				
				// reset accumulator
				_regulatorAcc -= _tickFrequency;
			}
			_regulatorCache = regulatorNew;	// cache previous regulator	value
		}				
	}
}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Wargrounds {
	class TurnTimer
	{
		private int ticksRemaining;
		private int pauseRemaining;
		private bool active = true;

		public delegate void TimerCallback();
		private TimerCallback callback;

		public const int MAX_TICKS = 20;

		public void setDelegate(TimerCallback onTimer) {
			callback = onTimer;
		}

		public void tick() {
			if (!active) return;

			if (pauseRemaining > 0) {
				pauseRemaining--;
				return;
			}
			ticksRemaining--;

			//Console.WriteLine("clicks remaining: " + ticksRemaining);
			if (ticksRemaining == 0) {
				callback();
			}
		}

		public void addTicks(int newTicks) {
			ticksRemaining += newTicks;
			if (ticksRemaining > MAX_TICKS) {
				ticksRemaining = MAX_TICKS;
			}
		}

		public void reset() {
			ticksRemaining = 0;
		}

		public void addPause(int pause) {
			pauseRemaining += pause;
		}

		public void stop() {
			active = false;
		}

		public void start() {
			active = true;
		}

		public int getTicksRemaining() {
			return ticksRemaining;
		}
	}
}

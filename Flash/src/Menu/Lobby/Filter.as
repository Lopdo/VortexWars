package Menu.Lobby
{
	import flash.net.SharedObject;

	public class Filter
	{
		public var mapSize:int = -1;
		public var startType:int = -1;
		public var gameType:int = -1;
		public var distType:int = -1;
		//public var showStarted:int = -1;
		public var upgradesEnabled:int = -1;
		public var boostsEnabled:int = -1;
		
		private var so:SharedObject;
		
		public function Filter()
		{
			try {
				so = SharedObject.getLocal("prefs");
				if(!so.data.hasOwnProperty("gameTypeFilter")) {
					so.data.gameTypeFilter = -1;
				}
				if(!so.data.hasOwnProperty("mapTypeFilter")) {
					so.data.mapTypeFilter = -1;
				}
				if(!so.data.hasOwnProperty("distTypeFilter")) {
					so.data.distTypeFilter = -1;
				}
				if(!so.data.hasOwnProperty("startTypeFilter")) {
					so.data.startTypeFilter = -1;
				}
				/*if(!so.data.hasOwnProperty("showStartedFilter")) {
					so.data.showStartedFilter = -1;
				}*/
				if(!so.data.hasOwnProperty("upgradesEnabledFilter")) {
					so.data.upgradesEnabledFilter = -1;
				}
				if(!so.data.hasOwnProperty("boostsEnabledFilter")) {
					so.data.boostsEnabledFilter = -1;
				}
				so.flush();
			}
			catch(errObject:Error) {
				// nothing
			}
			
			mapSize = so.data.mapTypeFilter;
			startType = so.data.startTypeFilter;
			gameType = so.data.gameTypeFilter;
			distType = so.data.distTypeFilter;
			//showStarted = so.data.showStartedFilter;
			upgradesEnabled = so.data.upgradesEnabledFilter;
			boostsEnabled = so.data.boostsEnabledFilter;
		}
		
		public function set(gameType:int, mapSize:int, startType:int, distType:int, upgradesEnabled:int, boostsEnabled:int):void {
			this.gameType = gameType;
			this.mapSize = mapSize;
			this.startType = startType;
			this.distType = distType;
			//this.showStarted = showStarted;
			this.upgradesEnabled = upgradesEnabled;
			this.boostsEnabled = boostsEnabled;
			
			try {
				so.data.gameTypeFilter = gameType;
				so.data.mapTypeFilter = mapSize;
				so.data.startTypeFilter = startType;
				so.data.distTypeFilter = distType;
				//so.data.showStartedFilter = showStarted;
				so.data.upgradesEnabledFilter = upgradesEnabled;
				so.data.boostsEnabledFilter = boostsEnabled;
				so.flush();
			}
			catch(errObj:Error) {
				// nothing
			}
		}
		
		public function check(gameType:int, mapSize:int, startType:int, distType:int, upgradesEnabled:int, boostsEnabled:int):Boolean {
			return (this.gameType == -1 || this.gameType == gameType) && 
				   (this.startType == -1 || this.startType == startType) &&
				   (this.mapSize == -1 || this.mapSize == mapSize || (this.mapSize == 1 && mapSize != 100 && mapSize != 101) ) && 
				   (this.distType == -1 || this.distType == distType) &&
				   //(this.showStarted == -1 || !started) &&
				   (this.upgradesEnabled == -1 || this.upgradesEnabled == upgradesEnabled) &&
				   (this.boostsEnabled == -1 || this.boostsEnabled == boostsEnabled);
		}
		
		public function reset():void {
			gameType = -1;
			mapSize = -1;
			startType = -1;
			distType = -1;
			//showStarted = -1;
			upgradesEnabled = -1;
			boostsEnabled = -1;
			
			try {
				so.data.gameTypeFilter = gameType;
				so.data.mapTypeFilter = mapSize;
				so.data.startTypeFilter = startType;
				so.data.distTypeFilter = distType;
				//so.data.showStartedFilter = showStarted;
				so.data.upgradesEnabledFilter = upgradesEnabled;
				so.data.boostsEnabledFilter = boostsEnabled;
				so.flush();
			}
			catch(errObj:Error) {
				// nothing
			}
		}
	}
}
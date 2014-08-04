package
{
	import Game.Player;
	import Game.Races.Race;
	
	import playerio.DatabaseObject;
	import playerio.Message;

	public class User extends Player
	{
		public var isReady:Boolean = false;
		public var isHost:Boolean = false;
		public var hidePremium:Boolean = false;
		public var xp:int = 0;
		public var totalXP:int = 0;
		public var isGuest:Boolean = false;
		public var premiumUntil:Date = null;
		public var achievements:Object = null;
		public var stats:Object = null;
		public var shards:int = 0;
		public var attackBoostsTotal:int, defeseBoostsTotal:int;
		public var background:int = 0;
		public var mapSlots:int = 0;
		public var playerObject:DatabaseObject;
		
		public var firstLoad:Boolean = true;
		
		public var muteList:Array = new Array();
		public var blackList:Array;
		
		public function User()
		{
			super(-1, "", 0, 0, 0, 1, 0, 0,0,0);
		}
		
		public function reset():void {
			race = Race.Create(0);
			level = 0;
			xp = 0;
			premiumUntil = null;
			achievements = null;
			stats = null;
			isHost = false;
			shards = 0;
			playerObject = null;
		}
		
		public function getNextLvlXP(lvl:int = -1):int {
			if(lvl == -1)
				lvl = level;
			
			return 175 + lvl * lvl * 15;
		}
		
		public function isRaceUnlocked(r:int):Boolean {
			var race:Race = Race.Create(r);
			return race.isUnlocked();
		}
		
		public function hasDeluxeEditor():Boolean {
			return G.client.payVault.has("EditorDeluxe");
		}
		
		public function isPremium():Boolean {
			if(isGuest || premiumUntil == null) return false;
			return (premiumUntil.getTime() - (new Date()).getTime()) > 0;
		}
		
		public function achievementUnlocked(message:Message):void {
			trace("achiev unlocked " + message);
			new AchievementWindow(message.getInt(0), message.getString(1), message.getInt(2), message.getInt(3));
		}
		
		public function isPlayerMuted(name:String):Boolean {
			name = name.toLowerCase();
			for each(var n:String in muteList) {
				if(n == name) return true;
			}
			
			return false;
		}
		
		public function toggleMute(name:String):Boolean {
			name = name.toLowerCase();
			for each(var n:String in muteList) {
				if(n == name) {
					muteList.splice(muteList.indexOf(n), 1);
					return false;
				}
			}
			
			muteList.push(name);
			return true;
		}
		
		public function isBanned(name:String):Boolean {
			name = name.toLowerCase();
			for each(var blacklistObj:Object in blackList) {
				if(blacklistObj.a == name) {
					return true;
				}
			}
			
			return false;
		}
	}
}
package Game.Backgrounds
{
	import IreUtils.ResList;
	
	import flash.display.Sprite;
	
	public class Background extends Sprite
	{
		public static const BACKGROUND_DEFAULT:int = 0;
		public static const BACKGROUND_DESERT:int = 1;
		public static const BACKGROUND_NIGHT_SKY:int = 2;
		public static const BACKGROUND_RED_SKIES:int = 3;
		public static const BACKGROUND_ICE:int = 4;
		public static const BACKGROUND_ALIEN_HOMEWORLD:int = 5;
		public static const BACKGROUND_STEEL:int = 6;
		public static const BACKGROUND_MOON:int = 7;
		public static const BACKGROUND_PUMPKIN:int = 9;
		public static const BACKGROUND_BLOOD:int = 10;
		public static const BACKGROUND_CRACKED_ICE:int = 11;
		public static const BACKGROUND_TUNDRA:int = 12;
		public static const BACKGROUND_FROZEN_LAKE:int = 13;
		public static const BACKGROUND_FOREST:int = 14;
		
		private static const names:Array = new Array("Default", "Desert", "Night sky", "Red Skies", "Ice", "Alien Homeworld", "Steel", "Moon", "", "Pumpkin", "Blood", "Cracked ice", "Tundra", "Frozen lake", "Forest");
		
		public function Background(bgIndex:int, w:int, h:int)
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("map_bg_" + bgIndex).bitmapData);
			graphics.drawRect(0, 0, w, h);
		}
		
		public static function isUnlocked(index:int):Boolean {
			if(index == 100) {
				return G.user.isPremium();
			}
			if(index == 0) {
				return true;
			}
			
			return G.client.payVault.has("MapBackground"+index);
		}
		
		public static function getName(index:int):String {
			if(index == 100) {
				return "Hell";
			}
			else {
				return names[index];
			}
		}
	}
}
package Game.Races
{
	import IreUtils.ResList;

	public class RaceSnowmen extends Race
	{
		public function RaceSnowmen()
		{
			super();
			
			ID = Race.RACE_SNOWMEN;
			name = "Snowmen";
			shopName = "RaceSnowmen";
			bonusDesc = "+2 defense boosts per game (your boosts only)";
			description = "They might look happy and harmless but they can become significant force... until they melt\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_snowmen");
			profileImage = ResList.GetArtResource("race_profileImage_Snowmen");
			symbolSmall = ResList.GetArtResource("army_logoSnowmen");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
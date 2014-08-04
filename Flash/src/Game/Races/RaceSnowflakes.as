package Game.Races
{
	import IreUtils.ResList;

	public class RaceSnowflakes extends Race
	{
		public function RaceSnowflakes()
		{
			super();
			
			ID = RACE_SNOWFLAKES;
			name = "Snowflakes";
			shopName = "RaceSnowflakes";
			bonusDesc = "Disables all bonuses of each race they fight with, for 1 round";
			description = "Their cold embrace can easily paralyze you.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_snowflakes");
			profileImage = ResList.GetArtResource("race_profileImage_Snowflakes");
			symbolSmall = ResList.GetArtResource("army_logoSnowflakes");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
package Game.Races
{
	import IreUtils.ResList;

	public class RaceSnowGiants extends Race
	{
		public function RaceSnowGiants()
		{
			super();
			
			ID = 1;
			name = "Snow Giants";
			shopName = "RaceSnowGiants";
			description = "Big, grumpy, cold and always ready to crush a head or two";
			
			regionImage = ResList.GetArtResource("terrain_snow");
			profileImage = ResList.GetArtResource("race_profileImage_SnowGiants");
			symbolSmall = ResList.GetArtResource("army_logoSnowGiants");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest;
		}
	}
}
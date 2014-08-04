package Game.Races
{
	import IreUtils.ResList;

	public class RaceElves extends Race
	{
		public function RaceElves()
		{
			super();
			
			ID = 0;
			name = "Elves";
			shopName = "RaceElves";
			description = "Good ol' elves, tall, pretty, majestic and stuff like that";
			
			regionImage = ResList.GetArtResource("terrain_grass");
			profileImage = ResList.GetArtResource("race_profileImage_Elves");
			symbolSmall = ResList.GetArtResource("army_logoElves");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return true;
		}
	}
}
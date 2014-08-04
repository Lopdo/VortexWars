package Game.Races
{
	import IreUtils.ResList;

	public class RaceAliens extends Race
	{
		public function RaceAliens()
		{
			super();
			
			ID = 100;
			name = "Aliens";
			shopName = "RaceAliens";
			description = "Nobody knows who they are or where they come from. Only one thing is certain, they are not from this world";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_aliens");
			profileImage = ResList.GetArtResource("race_profileImage_Aliens");
			symbolSmall = ResList.GetArtResource("army_logoAliens");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return G.user.isPremium();
		}
	}
}
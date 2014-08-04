package Game.Races
{
	import IreUtils.ResList;

	public class RaceAngels extends Race
	{
		public function RaceAngels()
		{
			super();
			
			ID = 103;
			name = "Angels";
			shopName = "RaceAngels";
			bonusDesc = "5% defense bonus";
			description = "Avatars of gods long forgotten, they strive to make the world a better place, fighting evil and helping wherever they can.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_angels");
			profileImage = ResList.GetArtResource("race_profileImage_Angels");
			symbolSmall = ResList.GetArtResource("army_logoAngels");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has("RaceAngels");
		}
	}
}
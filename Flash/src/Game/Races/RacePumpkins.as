package Game.Races
{
	import IreUtils.ResList;

	public class RacePumpkins extends Race
	{
		public function RacePumpkins()
		{
			super();
			
			ID = 105;
			name = "Pumpkins";
			shopName = "RacePumpkins";
			bonusDesc = "-5% defense, -5% attack, +15% army spawn";
			description = "They might look vulnerable, but someone carved mean faces on them so better watch your back.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_pumpkins");
			profileImage = ResList.GetArtResource("race_profileImage_Pumpkins");
			symbolSmall = ResList.GetArtResource("army_logoPumpkins");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has("RacePumpkins");
		}
	}
}
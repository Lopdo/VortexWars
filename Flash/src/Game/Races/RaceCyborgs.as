package Game.Races
{
	import IreUtils.ResList;

	public class RaceCyborgs extends Race
	{
		public function RaceCyborgs()
		{
			super();
			
			ID = 116;
			name = "Cyborgs";
			shopName = "RaceCyborgs";
			bonusDesc = "+5 storage bonus";
			description = "Cunning of men, endurance and precision of robots.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_bones");
			profileImage = ResList.GetArtResource("race_profileImage_Cyborgs");
			symbolSmall = ResList.GetArtResource("army_logoCyborgs");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
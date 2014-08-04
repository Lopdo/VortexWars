package Game.Races
{
	import IreUtils.ResList;

	public class RaceReptiles extends Race
	{
		public function RaceReptiles()
		{
			super();
			
			ID = Race.RACE_REPTILES;
			name = "Reptiles";
			shopName = "RaceReptiles";
			bonusDesc = "5% defense bonus, 10% spawn bonus";
			description = "Hard scales and regenerative powers are what makes reptiles so fierce in battle.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_reptiles");
			profileImage = ResList.GetArtResource("race_profileImage_Reptiles");
			symbolSmall = ResList.GetArtResource("army_logoReptiles");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
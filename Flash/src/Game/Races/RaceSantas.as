package Game.Races
{
	import IreUtils.ResList;

	public class RaceSantas extends Race
	{
		public function RaceSantas()
		{
			super();
			
			ID = Race.RACE_SANTAS;
			name = "Santas";
			shopName = "RaceSantas";
			bonusDesc = "+25% shards bonus";
			description = "Army of jolly old men in red approaches. And look! They are bringing presents!.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_santas");
			profileImage = ResList.GetArtResource("race_profileImage_Santas");
			symbolSmall = ResList.GetArtResource("army_logoSantas");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
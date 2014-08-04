package Game.Races
{
	import IreUtils.ResList;

	public class RaceTannenbaums extends Race
	{
		public function RaceTannenbaums()
		{
			super();
			
			ID = RACE_TANNENBAUMS;
			name = "Tannenbaums";
			shopName = "RaceTannenbaums";
			bonusDesc = "20% attack bonus from a defense boosted region";
			description = "They might look nice and harmless, but they are full of sharp needles and glass shards. Once they take root somewhere, they become really fierce.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_tannenbaums");
			profileImage = ResList.GetArtResource("race_profileImage_Tannenbaums");
			symbolSmall = ResList.GetArtResource("army_logoTannenbaums");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
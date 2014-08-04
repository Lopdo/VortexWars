package Game.Races
{
	import IreUtils.ResList;

	public class RaceSoldiers extends Race
	{
		public function RaceSoldiers()
		{
			super();
			
			ID = 3;
			name = "Soldiers";
			shopName = "RaceSoldiers";
			description = "Best of the best of the bestest that the future has to offer";
			unlockLevel = 4;
			
			regionImage = ResList.GetArtResource("terrain_soldiers");
			profileImage = ResList.GetArtResource("race_profileImage_Soldiers");
			symbolSmall = ResList.GetArtResource("army_logoSoldiers");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has("RaceSoldiers");
		}
	}
}
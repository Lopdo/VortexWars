package Game.Races
{
	import IreUtils.ResList;

	public class RaceNinjas extends Race
	{
		public function RaceNinjas()
		{
			super();
			
			ID = 7;
			name = "Ninjas";
			shopName = "RaceNinjas";
			description = "The only trace they leave behind is a trail of dead bodies and sakura petals";
			unlockLevel = 20;
			
			regionImage = ResList.GetArtResource("terrain_ninjas");
			profileImage = ResList.GetArtResource("race_profileImage_Ninjas");
			symbolSmall = ResList.GetArtResource("army_logoNinjas");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has("RaceNinjas");
		}
	}
}
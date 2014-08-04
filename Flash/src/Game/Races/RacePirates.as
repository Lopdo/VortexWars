package Game.Races
{
	import IreUtils.ResList;

	public class RacePirates extends Race
	{
		public function RacePirates()
		{
			super();
			
			ID = 6;
			name = "Pirates";
			shopName = "RacePirates";
			description = "These wretched villains and scum of the seas are a threat to anyone who dares to sail without suitable protection";
			unlockLevel = 16;
			
			regionImage = ResList.GetArtResource("terrain_woodFloor");
			profileImage = ResList.GetArtResource("race_profileImage_Pirates");
			symbolSmall = ResList.GetArtResource("army_logoPirates");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has("RacePirates");
		}
	}
}
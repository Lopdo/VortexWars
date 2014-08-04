package Game.Races
{
	import IreUtils.ResList;

	public class RaceDemons extends Race
	{
		public function RaceDemons()
		{
			super();
			
			ID = 102;
			name = "Demons";
			shopName = "RaceDemons";
			bonusDesc = "5% attack bonus";
			description = "These spawns of hell burn everything in their path, leaving only destruction behind.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_magma");
			profileImage = ResList.GetArtResource("race_profileImage_Demons");
			symbolSmall = ResList.GetArtResource("army_logoDemons");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has("RaceDemons");
		}
	}
}
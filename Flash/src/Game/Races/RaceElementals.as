package Game.Races
{
	import IreUtils.ResList;

	public class RaceElementals extends Race
	{
		public function RaceElementals()
		{
			super();
			
			ID = 5;
			name = "Elementals";
			shopName = "RaceElementals";
			description = "Released from their homeworld ruled by wild forces of nature, these magical creatures seek only to cause havoc.";
			unlockLevel = 12;
			
			regionImage = ResList.GetArtResource("terrain_elementals");
			profileImage = ResList.GetArtResource("race_profileImage_Elementals");
			symbolSmall = ResList.GetArtResource("army_logoElementals");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has("RaceElementals");
		}
	}
}
package Game.Races
{
	import IreUtils.ResList;

	public class RaceNatives extends Race
	{
		public function RaceNatives()
		{
			super();
			
			ID = Race.RACE_NATIVES;
			name = "Natives";
			shopName = "RaceNatives";
			bonusDesc = "region with 1 army has strength of 2 when attacked";
			description = "They were here before us and they fight so they can remain here after we are gone.\n(" + bonusDesc + ")";
			
			regionImage = ResList.GetArtResource("terrain_natives");
			profileImage = ResList.GetArtResource("race_profileImage_Natives");
			symbolSmall = ResList.GetArtResource("army_logoNatives");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
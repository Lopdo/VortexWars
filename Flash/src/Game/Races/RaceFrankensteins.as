package Game.Races
{
	import IreUtils.ResList;

	public class RaceFrankensteins extends Race
	{
		public function RaceFrankensteins()
		{
			super();
			
			ID = Race.RACE_FRANKENSTEINS;
			name = "Frankenstein";
			shopName = "RaceFrankensteins";
			bonusDesc = "+15% defense with 5 contiguous regions or less, decreases with more regions until 0%";
			description = "Everybody thinks that doctor Frankenstein made only one monster. Boy, were they wrong!\n(" + bonusDesc + ")";
			
			regionImage = ResList.GetArtResource("terrain_bones");
			profileImage = ResList.GetArtResource("race_profileImage_Frankensteins");
			symbolSmall = ResList.GetArtResource("army_logoFrankensteins");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
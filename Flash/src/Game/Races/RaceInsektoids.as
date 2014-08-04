package Game.Races
{
	import IreUtils.ResList;

	public class RaceInsektoids extends Race
	{
		public function RaceInsektoids()
		{
			super();
			
			ID = 101;
			name = "Insectoids";
			shopName = "RaceInsectoids";
			bonusDesc = "10% army spawn bonus"
			description = "These creatures are deadly and can multiply extremely fast.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_insectoids");
			profileImage = ResList.GetArtResource("race_profileImage_Insectoids");
			symbolSmall = ResList.GetArtResource("army_logoInsectoids");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has("RaceInsectoids");
		}
	}
}
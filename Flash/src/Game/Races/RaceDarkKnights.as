package Game.Races
{
	import IreUtils.ResList;

	public class RaceDarkKnights extends Race
	{
		public function RaceDarkKnights()
		{
			super();
			
			ID = 117;
			name = "Dark knights";
			shopName = "RaceDarkKnights";
			bonusDesc = "10% defense bonus when using defense boost";
			description = "Warrior order tasked with defending the Secret. Now that the Secret is revealed, they fight for whoever offers the strongest enemy.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_natives");
			profileImage = ResList.GetArtResource("race_profileImage_DarkKnights");
			symbolSmall = ResList.GetArtResource("army_logoDarkKnights");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
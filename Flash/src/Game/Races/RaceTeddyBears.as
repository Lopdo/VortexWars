package Game.Races
{
	import IreUtils.ResList;

	public class RaceTeddyBears extends Race
	{
		public function RaceTeddyBears()
		{
			super();
			
			ID = 118;
			name = "Teddy bears";
			shopName = "RaceTeddyBears";
			bonusDesc = "-5% defense bonus, -5% attack bonus, -10% spawn bonus";
			description = "Too cute to fights. Will you manage to win even with them?\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_angels");
			profileImage = ResList.GetArtResource("race_profileImage_TeddyBears");
			symbolSmall = ResList.GetArtResource("army_logoTeddyBears");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
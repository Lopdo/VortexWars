package Game.Races
{
	import IreUtils.ResList;

	public class RaceBladeMasters extends Race
	{
		public function RaceBladeMasters()
		{
			super();
			
			ID = 115;
			name = "Blade masters";
			shopName = "RaceBladeMasters";
			bonusDesc = "10% attack bonus when using attack boost";
			description = "Their four hands, each wielding an extremely sharp blade, make them superior fighters.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_magma");
			profileImage = ResList.GetArtResource("race_profileImage_BladeMasters");
			symbolSmall = ResList.GetArtResource("army_logoBladeMasters");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
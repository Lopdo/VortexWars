package Game.Races
{
	import IreUtils.ResList;

	public class RaceArachnids extends Race
	{
		public function RaceArachnids()
		{
			super();
			
			ID = Race.RACE_ARACHNIDS;
			name = "Arachnids";
			shopName = "RaceArachnids";
			bonusDesc = "5% attack bonus, 10% spawn bonus";
			description = "Deadly monsters hiding in their web fortresses. If they see you, you are as good as dead.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_arachnids");
			profileImage = ResList.GetArtResource("race_profileImage_Arachnids");
			symbolSmall = ResList.GetArtResource("army_logoArachnids");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
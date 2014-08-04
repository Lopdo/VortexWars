package Game.Races
{
	import IreUtils.ResList;

	public class RaceUndead extends Race
	{
		public function RaceUndead()
		{
			super();
			
			ID = Race.RACE_UNDEAD;
			name = "Undead";
			shopName = "RaceUndead";
			bonusDesc = "attack boost is not consumed when you win first attack";
			description = "The dead are rising!\n(" + bonusDesc + ")";
			
			regionImage = ResList.GetArtResource("terrain_undead");
			profileImage = ResList.GetArtResource("race_profileImage_Undead");
			symbolSmall = ResList.GetArtResource("army_logoUndead");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
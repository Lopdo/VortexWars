package Game.Races
{
	import IreUtils.ResList;

	public class RaceWerewolves extends Race
	{
		public function RaceWerewolves()
		{
			super();
			
			ID = Race.RACE_WEREWOLVES;
			name = "Werewolves";
			shopName = "RaceWerewolves";
			bonusDesc = "+15% attack with 5 contiguous regions or less, decreases with more regions until 0%";
			description = "Ferocious in their attacks, their biggest advantage is surprise, though they are easy to repel once you know about them.\n(" + bonusDesc + ")";
			
			regionImage = ResList.GetArtResource("terrain_natives");
			profileImage = ResList.GetArtResource("race_profileImage_Werewolves");
			symbolSmall = ResList.GetArtResource("army_logoWerewolves");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
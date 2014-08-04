package Game.Races
{
	import IreUtils.ResList;

	public class RaceWatchmen extends Race
	{
		public function RaceWatchmen()
		{
			super();
			
			ID = Race.RACE_WATCHMEN;
			name = "Watchmen";
			shopName = "RaceWatchmen";
			bonusDesc = "attack boost is not consumed when you win first attack";
			description = "Only few know about their existence. They watch constantly and intervene when the need is greatest, making sure that the universe survives.\n(" + bonusDesc + ")";
			
			regionImage = ResList.GetArtResource("terrain_undead");
			profileImage = ResList.GetArtResource("race_profileImage_Watchmen");
			symbolSmall = ResList.GetArtResource("army_logoWatchmen");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
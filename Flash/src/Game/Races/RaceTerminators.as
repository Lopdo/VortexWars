package Game.Races
{
	import IreUtils.ResList;

	public class RaceTerminators extends Race
	{
		public function RaceTerminators()
		{
			super();
			
			ID = Race.RACE_TERMINATORS;
			name = "Terminators";
			shopName = "RaceTerminators";
			bonusDesc = "15% attack bonus when attacking with smaller army";
			description = "He promised he would be back. And he brought reinforcements.\n(" + bonusDesc + ")";
			
			regionImage = ResList.GetArtResource("terrain_terminators");
			profileImage = ResList.GetArtResource("race_profileImage_Terminators");
			symbolSmall = ResList.GetArtResource("army_logoTerminators");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has(shopName);
		}
	}
}
package Game.Races
{
	import IreUtils.ResList;

	public class RaceVampires extends Race
	{
		public function RaceVampires()
		{
			super();
			
			ID = 104;
			name = "Vampires";
			shopName = "RaceVampires";
			bonusDesc = "+5% defense, +5% attack, -10% army spawn";
			description = "Deadly, but rare, seen only in horror movies and halloween parties. Children of the night are ready to fight.\n(" + bonusDesc + ")";
			unlockLevel = -1;
			
			regionImage = ResList.GetArtResource("terrain_vampires");
			profileImage = ResList.GetArtResource("race_profileImage_Vampires");
			symbolSmall = ResList.GetArtResource("army_logoVampires");
			
			profileImage.smoothing = true;
		}
		
		public override function isUnlocked():Boolean {
			return !G.user.isGuest && G.client.payVault.has("RaceVampires");
		}
	}
}
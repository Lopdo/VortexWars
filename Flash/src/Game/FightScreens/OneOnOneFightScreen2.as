package Game.FightScreens
{
	import Game.Game;
	import Game.Region;
	
	import IreUtils.ResList;
	
	public class OneOnOneFightScreen2 extends FightScreen2
	{
		private var throws:Array;
		private var throwIndex:int = 0;
		private var attackResult:int, defenceResult:int;
		private var attackStrength:int, defenceStrength:int;
		
		public function OneOnOneFightScreen2()
		{
			super();
			
		}
		
		public override function startFight(source:Region, target:Region, throws:Array):void {
			super.startFight(source, target, throws);
			
			this.throws = throws;
			
			attackerStrength.text = "" + (source.dice - 1);
			
			throwIndex = 0;
			
			attackStrength = source.dice - 1;
			defenceStrength = target.dice;
			attackResult = throws[throwIndex++];
			defenceResult = throws[throwIndex++];
		}
		
		public override function Update(timeDelta:Number):void {
			if(!fightInProgress) return;
			
			timer += timeDelta;
			
			if(timer < 0.8) {
				attackerThrow.text = ((int)(Math.random() * 6 + 1)).toString();
				defenderThrow.text = ((int)(Math.random() * 6 + 1)).toString();
			}
			else if(timer - timeDelta < 0.8) {
				attackerThrow.text = attackResult.toString();
				defenderThrow.text = defenceResult.toString();
				if(attackResult > defenceResult) {
					attackerThrow.setTextFormat(winThrowTextFormat);
					defenderStrength.text = (--defenceStrength).toString();
					G.sounds.playSound("battle_win");
				}
				else {
					defenderThrow.setTextFormat(winThrowTextFormat);
					attackerStrength.text = (--attackStrength).toString();
					G.sounds.playSound("battle_lose");
				}
			}
			else if(timer > 2) {
				if(throwIndex >= throws.length) {
					if(timer - timeDelta <= 2)
						endFight();
				}
				else {
					timer = 0;
					attackResult = throws[throwIndex++];
					defenceResult = throws[throwIndex++];
					
					G.sounds.playSound("dice_rolling");
				}
			}
		}
	}
}
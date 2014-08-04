package Game.FightScreens
{
	import Game.Game;
	import Game.Player;
	import Game.Region;
	
	import IreUtils.ResList;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.Message;

	public class SingleThrowFightScreen2 extends FightScreen2
	{
		private var attackStrength:int, defenceStrength:int, attackResult:int, defenceResult:int;
		
		public function SingleThrowFightScreen2()
		{
			super();
		}
		
		public override function startFight(source:Region, target:Region, throws:Array):void {
			super.startFight(source, target, throws);

			attackStrength = source.dice;
			defenceStrength = target.dice;
			attackResult = throws[0];
			defenceResult = throws[1];
		}
		
		public override function Update(timeDelta:Number):void {
			if(!fightInProgress) return;
			
			timer += timeDelta;
			
			if(timer < 0.8) {
				var thr:int = 0;
				for(var i:int = 0; i < attackStrength; i++) {
					thr += Math.random() * 6 + 1
				}
				attackerThrow.text = thr.toString();
				
				thr = 0;
				for(i = 0; i < defenceStrength; i++) {
					thr += Math.random() * 6 + 1
				}
				defenderThrow.text = thr.toString();
			}
			else if(timer - timeDelta < 0.8) {
				attackerThrow.text = attackResult.toString();
				defenderThrow.text = defenceResult.toString();
				if(attackResult > defenceResult) {
					attackerThrow.setTextFormat(winThrowTextFormat);
					//defenderBg.alpha = 0.5;
					defenderFg.visible = false;
					G.sounds.playSound("battle_win");
				}
				else {
					defenderThrow.setTextFormat(winThrowTextFormat);
					//attackerBg.alpha = 0.5;
					attackerFg.visible = false;
					G.sounds.playSound("battle_lose");
				}
			}
			else if(timer > 2) {
				if(timer - timeDelta <= 2)
					endFight();
			}
		}
	}
}
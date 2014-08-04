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

	public class SingleThrowFightScreen extends FightScreen
	{
		private var attackStrength:int, defenceStrength:int;
		
		public function SingleThrowFightScreen()
		{
			super();
		}
		
		public override function startFight(source:Region, target:Region, throws:Array, attackBoost:Boolean, defenseBoost:Boolean, battlesCount:int):void {
			super.startFight(source, target, throws, attackBoost, defenseBoost, battlesCount);

			attackStrength = source.dice;
			defenceStrength = target.dice;
			attackResult = throws[0];
			defenceResult = throws[1];
		}
		
		public override function Update(timeDelta:Number):void {
			if(!fightInProgress) return;
			
			if(attackBoostFading) {
				boostFadeCounter += timeDelta;
				if(boostFadeCounter > 0.5) {
					attackBoostFading = false;
					attackBoostSprite.visible = false;
				}
				attackBoostSprite.scaleX = attackBoostSprite.scaleY = 1 + boostFadeCounter * 4;
				attackBoostSprite.alpha = 1 - boostFadeCounter * 2;
			}
			if(defenseBoostFading) {
				boostFadeCounter += timeDelta;
				if(boostFadeCounter > 0.5) {
					defenseBoostFading = false;
					defenseBoostSprite.visible = false;
				}
				defenseBoostSprite.scaleX = defenseBoostSprite.scaleY = 1 + boostFadeCounter * 4;
				defenseBoostSprite.alpha = 1 - boostFadeCounter * 2;
			}
			
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
					defenderBg.visible = true;
					G.sounds.playSound("battle_win");
					if(defenseBoostActive) {
						defenseBoostFading = true;
						boostFadeCounter = 0;
					}
				}
				else {
					defenderThrow.setTextFormat(winThrowTextFormat);
					//attackerBg.alpha = 0.5;
					attackerBg.visible = true;
					G.sounds.playSound("battle_lose");
					if(attackBoostActive) {
						attackBoostFading = true;
						boostFadeCounter = 0;
					}
				}
			}
			else if(timer > 2) {
				if(attackResult > defenceResult && defenseBoostActive) {
					timer = 0;
					nextBattle();
					defenseBoostActive = false;
					return;
				}
				if(attackResult <= defenceResult && attackBoostActive) {
					timer = 0;
					nextBattle();
					attackBoostActive = false;
					return;
				}
				if(timer - timeDelta <= 2)
					endFight();
			}
		}
	}
}
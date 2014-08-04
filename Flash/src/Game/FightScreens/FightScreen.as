package Game.FightScreens
{
	import Game.Game;
	import Game.Region;
	
	import IreUtils.ResList;
	
	import Menu.DynamicBar;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.Message;
	
	public class FightScreen extends Sprite
	{
		protected var attackerBg:Sprite, attackerFg:Sprite;
		protected var defenderBg:Sprite, defenderFg:Sprite;
		private var attackerName:TextField;
		private var defenderName:TextField;
		protected var attackerStrength:TextField;
		protected var defenderStrength:TextField;
		protected var attackerThrow:TextField;
		protected var defenderThrow:TextField;
		
		//protected var throwPanel:Sprite;
		//protected var fightIcon:Sprite;
		
		protected var throwTextFormat:TextFormat;
		protected var winThrowTextFormat:TextFormat;
		
		public var fightInProgress:Boolean = false;
		protected var timer:Number = 0;
		
		protected var attackBoostSprite:Sprite;
		protected var defenseBoostSprite:Sprite;
		protected var attackBoostActive:Boolean;
		protected var defenseBoostActive:Boolean;
		
		protected var battleIndex:int;
		protected var attackResult:int, defenceResult:int;
		protected var throws:Array;

		protected var attackBoostFading:Boolean;
		protected var defenseBoostFading:Boolean;
		protected var boostFadeCounter:Number;
		
		public function FightScreen()
		{
			super();
			
			addChild(ResList.GetArtResource("fightScreen_bg"));
			x = 556 / 2 - width / 2;
			y = 4;
			
			attackerBg = new Sprite();
			attackerBg.addChild(ResList.GetArtResource("gamePanel_player_long_0"));
			attackerBg.x = 6;
			attackerBg.y = 5;
			//attackerBg.visible = true;
			
			defenderBg = new Sprite();
			defenderBg.addChild(ResList.GetArtResource("gamePanel_player_long_0"));
			defenderBg.scaleX = -1;
			defenderBg.x = 260 + defenderBg.width;
			defenderBg.y = 6;
			//defenderBg.visible = true;
		
			attackerFg = new Sprite();
			attackerFg.addChild(ResList.GetArtResource("gamePanel_player_long_0"));
			attackerFg.x = 6;
			attackerFg.y = 5;
			//attackerFg.visible = false;
			addChild(attackerFg);
			
			defenderFg = new Sprite();
			defenderFg.addChild(ResList.GetArtResource("gamePanel_player_long_0"));
			defenderFg.scaleX = -1;
			defenderFg.x = 260 + defenderBg.width;
			defenderFg.y = 6;
			//defenderFg.visible = false;
			addChild(defenderFg);
			
			addChild(defenderBg);
			addChild(attackerBg);

			var outline:GlowFilter = new GlowFilter(0x000000,1.0,2.0,2.0,10);
			outline.quality=BitmapFilterQuality.HIGH;
			//text.filters = [outline];
			
			var nameTextFormat:TextFormat = new TextFormat();
			nameTextFormat.font = "Arial";
			nameTextFormat.bold = true;
			nameTextFormat.size = 14;
			nameTextFormat.align = TextFormatAlign.CENTER;
			nameTextFormat.color = -1;
			
			attackerName = new TextField;
			attackerName.defaultTextFormat = nameTextFormat;
			attackerName.text = " ";
			attackerName.x = 56;
			attackerName.width = 150;
			attackerName.autoSize = TextFieldAutoSize.LEFT;
			attackerName.y = 9 + 29 / 2 - attackerName.height / 2;
			attackerName.mouseEnabled = false;
			attackerName.filters = [outline];
			addChild(attackerName);
			
			defenderName = new TextField;
			defenderName.defaultTextFormat = nameTextFormat;
			defenderName.text = " ";
			defenderName.x = 272;
			defenderName.width = 150;
			defenderName.autoSize = TextFieldAutoSize.RIGHT;
			defenderName.y = 9 + 29 / 2 - defenderName.height / 2;
			defenderName.mouseEnabled = false;
			defenderName.filters = [outline];
			addChild(defenderName);
			
			attackerStrength = new TextField();
			attackerStrength.mouseEnabled = false;
			attackerStrength.defaultTextFormat = nameTextFormat; 
			attackerStrength.text = " ";
			attackerStrength.x = 19;
			attackerStrength.width = 16;
			attackerStrength.autoSize = TextFieldAutoSize.CENTER;
			attackerStrength.y = 10 + 27 / 2 - attackerStrength.height / 2;
			attackerStrength.filters = [outline];
			addChild(attackerStrength);
			
			defenderStrength = new TextField();
			defenderStrength.mouseEnabled = false;
			defenderStrength.defaultTextFormat = nameTextFormat;
			defenderStrength.text = " ";
			defenderStrength.x = 444;
			defenderStrength.width = 16;
			defenderStrength.autoSize = TextFieldAutoSize.CENTER;
			defenderStrength.y = 10 + 27 / 2 - defenderStrength.height / 2;
			defenderStrength.filters = [outline];
			addChild(defenderStrength);
			
			throwTextFormat = new TextFormat();
			throwTextFormat.font = "Arial";
			throwTextFormat.bold = true;
			throwTextFormat.size = 24;
			throwTextFormat.align = TextFormatAlign.CENTER;
			throwTextFormat.color = -1;
			
			winThrowTextFormat = new TextFormat();
			winThrowTextFormat.font = "Arial";
			winThrowTextFormat.bold = true;
			winThrowTextFormat.size = 24;
			winThrowTextFormat.align = TextFormatAlign.CENTER;
			winThrowTextFormat.color = 0x00ff00;
			
			attackerThrow = new TextField();
			attackerThrow.defaultTextFormat = throwTextFormat;
			attackerThrow.text = " ";
			attackerThrow.x = 182;
			attackerThrow.width = 38;
			attackerThrow.autoSize = TextFieldAutoSize.CENTER;
			attackerThrow.y = 49 + 35 / 2 - attackerThrow.height / 2;
			addChild(attackerThrow);
			
			defenderThrow = new TextField();
			defenderThrow.defaultTextFormat = throwTextFormat;
			defenderThrow.text = " ";
			defenderThrow.x = 257;
			defenderThrow.width = 38;
			defenderThrow.autoSize = TextFieldAutoSize.CENTER;
			defenderThrow.y = 49 + 35 / 2 - defenderThrow.height / 2;
			addChild(defenderThrow);
			
			attackBoostSprite = new Sprite();
			var b:Bitmap = ResList.GetArtResource("boost_attack_icon");
			b.x = - b.width / 2;
			b.y = - b.height / 2;
			b.smoothing = true;
			attackBoostSprite.addChild(b);
			attackBoostSprite.x = 171 - b.x
			attackBoostSprite.y = 54 - b.y;
			attackBoostSprite.visible = false;
			addChild(attackBoostSprite);
			
			
			defenseBoostSprite = new Sprite();
			b = ResList.GetArtResource("boost_defense_icon");
			b.x = - b.width / 2;
			b.y = - b.height / 2;
			b.smoothing = true;
			defenseBoostSprite.addChild(b);
			defenseBoostSprite.x = 297 - b.x;
			defenseBoostSprite.y = 54 - b.y;
			defenseBoostSprite.visible = false;
			addChild(defenseBoostSprite);
			
			visible = false;
		}
		
		public function startFight(source:Region, target:Region, throws:Array, attackBoost:Boolean, defenseBoost:Boolean, battlesCount:int):void {
			if(source.owner)
				attackerName.text = source.owner.name;
			attackerStrength.text = source.dice.toString();
			
			this.throws = throws;
			
			attackBoostSprite.visible = attackBoost;
			defenseBoostSprite.visible = defenseBoost;
			attackBoostActive = attackBoost;
			defenseBoostActive = defenseBoost;
			
			battleIndex = 0;
			
			defenseBoostSprite.scaleX = 1;
			defenseBoostSprite.scaleY = 1;
			defenseBoostSprite.alpha = 1;
			
			attackBoostSprite.scaleX = 1;
			attackBoostSprite.scaleY = 1;
			attackBoostSprite.alpha = 1;
			
			while(attackerBg.numChildren > 0) attackerBg.removeChildAt(attackerBg.numChildren - 1);
			while(attackerFg.numChildren > 0) attackerFg.removeChildAt(attackerFg.numChildren - 1);
			if(source.owner) {
				attackerBg.addChild(ResList.GetArtResource("gamePanel_player_long_off"));
				attackerFg.addChild(ResList.GetArtResource("gamePanel_player_long_" + source.owner.colorID));
			}
			else {
				attackerBg.addChild(ResList.GetArtResource("gamePanel_player_long_empty"));
				attackerFg.addChild(ResList.GetArtResource("gamePanel_player_long_empty"));
			}
			attackerBg.visible = false;
			while(defenderBg.numChildren > 0) defenderBg.removeChildAt(defenderBg.numChildren - 1);
			while(defenderFg.numChildren > 0) defenderFg.removeChildAt(defenderFg.numChildren - 1);
			if(target.owner != null) {
				defenderName.text = target.owner.name;
				defenderBg.addChild(ResList.GetArtResource("gamePanel_player_long_off"));
				defenderFg.addChild(ResList.GetArtResource("gamePanel_player_long_" + target.owner.colorID));
			}
			else {
				defenderBg.addChild(ResList.GetArtResource("gamePanel_player_long_empty"));
				defenderFg.addChild(ResList.GetArtResource("gamePanel_player_long_empty"));
			}
			defenderBg.visible = false;
			defenderStrength.text = target.dice.toString();
			visible = true;
				
			G.sounds.playSound("dice_rolling");
			fightInProgress = true;
			timer = 0;
		}
		
		protected function nextBattle():void {
			battleIndex++;
			
			attackResult = throws[2*battleIndex];
			defenceResult = throws[2*battleIndex + 1];
			
			attackerBg.visible = false;
			defenderBg.visible = false;
			
			G.sounds.playSound("dice_rolling");
		}
		
		protected function endFight():void {
			attackerName.text = "";
			attackerStrength.text = "";
			attackerThrow.text = "";
			attackerBg.visible = false;
			
			defenderName.text = "";
			defenderStrength.text = "";
			defenderThrow.text = "";
			defenderBg.visible = false;
			
			visible = false;
			
			fightInProgress = false;
			
			(Game)(this.parent).fightFinished();
		}
		
		public function Update(timeDelta:Number):void {
			
		}
	}
}
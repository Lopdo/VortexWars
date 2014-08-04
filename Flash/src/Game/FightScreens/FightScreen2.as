package Game.FightScreens
{
	import Game.Game;
	import Game.Region;
	
	import IreUtils.ResList;
	
	import Menu.DynamicBar;
	
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.Message;
	
	public class FightScreen2 extends Sprite
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
		
		public function FightScreen2()
		{
			super();
			
			addChild(ResList.GetArtResource("fightScreen_bg2"));
			x = 556 / 2 - width / 2;
			y = 4;
			
			attackerBg = new Sprite();
			attackerBg.addChild(ResList.GetArtResource("gamePanel_player_long_0"));
			attackerBg.x = 6;
			attackerBg.y = 5;
			//attackerBg.visible = true;
			addChild(attackerBg);
			
			defenderBg = new Sprite();
			defenderBg.addChild(ResList.GetArtResource("gamePanel_player_long_0"));
			defenderBg.scaleX = -1;
			defenderBg.x = 260 + defenderBg.width;
			defenderBg.y = 6;
			//defenderBg.visible = true;
			addChild(defenderBg);
			
			attackerFg = new Sprite();
			attackerFg.addChild(ResList.GetArtResource("gamePanel_player_long_0"));
			attackerFg.x = 6;
			attackerFg.y = 5;
			attackerFg.visible = false;
			addChild(attackerFg);
			
			defenderFg = new Sprite();
			defenderFg.addChild(ResList.GetArtResource("gamePanel_player_long_0"));
			defenderFg.scaleX = -1;
			defenderFg.x = 260 + defenderBg.width;
			defenderFg.y = 6;
			defenderFg.visible = false;
			addChild(defenderFg);
			
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
			
			visible = false;
		}
		
		public function startFight(source:Region, target:Region, throws:Array):void {
			if(source.owner)
				attackerName.text = source.owner.name;
			attackerStrength.text = source.dice.toString();
			
			while(attackerBg.numChildren > 0) attackerBg.removeChildAt(attackerBg.numChildren - 1);
			while(attackerFg.numChildren > 0) attackerFg.removeChildAt(attackerFg.numChildren - 1);
			if(source.owner) {
				attackerBg.addChild(ResList.GetArtResource("gamePanel_player_long_off_" + source.owner.colorID));
				attackerFg.addChild(ResList.GetArtResource("gamePanel_player_long_" + source.owner.colorID));
			}
			else {
				attackerBg.addChild(ResList.GetArtResource("gamePanel_player_long_empty"));
				attackerFg.addChild(ResList.GetArtResource("gamePanel_player_long_empty"));
			}
			attackerFg.visible = true;
			while(defenderBg.numChildren > 0) defenderBg.removeChildAt(defenderBg.numChildren - 1);
			while(defenderFg.numChildren > 0) defenderFg.removeChildAt(defenderFg.numChildren - 1);
			if(target.owner != null) {
				defenderName.text = target.owner.name;
				defenderBg.addChild(ResList.GetArtResource("gamePanel_player_long_off_" + target.owner.colorID));
				defenderFg.addChild(ResList.GetArtResource("gamePanel_player_long_" + target.owner.colorID));
				defenderFg.visible = true;
			}
			else {
				defenderBg.addChild(ResList.GetArtResource("gamePanel_player_long_empty"));
				defenderFg.addChild(ResList.GetArtResource("gamePanel_player_long_empty"));
				defenderFg.visible = true;
			}
			defenderStrength.text = target.dice.toString();
			visible = true;
				
			G.sounds.playSound("dice_rolling");
			fightInProgress = true;
			timer = 0;
		}
		
		protected function endFight():void {
			attackerName.text = "";
			attackerStrength.text = "";
			attackerThrow.text = "";
			attackerFg.visible = false;
			attackerFg.alpha = 1.0;
			
			defenderName.text = "";
			defenderStrength.text = "";
			defenderThrow.text = "";
			defenderFg.visible = false;
			defenderFg.alpha = 1.0;
			
			visible = false;
			
			fightInProgress = false;
			
			(Game)(this.parent).FightFinished();
		}
		
		public function Update(timeDelta:Number):void {
			
		}
	}
}
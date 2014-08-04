package Game
{
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.DatabaseObject;
	
	public class PSGameOverScreen extends GameOverScreen
	{
		private var resumeButton:ButtonHex;
		private var position:int;
		
		private var gameOverSoundPlayed:Boolean = false;
		
		protected override function init(widePanel:Boolean, position:int=-1, xp:int=0, bonus:int=0, playersStartedCount:int=0, shards:int=0, prevRank:int = 0, rankGain:int = 0):void {
			
			this.position = position;
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var screen:NinePatchSprite;
			
			screen = new NinePatchSprite("9patch_popup", 368, 230);	
			
			if(widePanel)
				screen.x = 5 + 550 / 2 - screen.width / 2;
			else 
				screen.x = 5 + 655 / 2 - screen.width / 2;
			//screen.x = width / 2 - screen.width / 2;
			screen.y = height / 2 - screen.height / 2;
			addChild(screen);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.text = "GAME OVER";
			label.setTextFormat(tf);
			label.width = screen.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			screen.addChild(label);
			
			var quitButton:ButtonHex = new ButtonHex("LEAVE GAME", onLeave, "button_small_gold");
			quitButton.x = screen.width / 2 - quitButton.width / 2;
			quitButton.y = screen.height - 50;
			screen.addChild(quitButton);
			
			tf.size = 14;
			
			if(position == -1) {
				label = new TextField();
				label.text = "Game has ended.";
				label.setTextFormat(tf);
				label.multiline = true;
				label.wordWrap = true;
				label.x = 20;
				label.width = screen.width - 40;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.y = screen.height / 2 - label.height / 2;
				label.mouseEnabled = false;
				screen.addChild(label);
			}
			else {
				tf.color = 0xFF0000;
				
				var place:TextField = new TextField();
				if(position == -2) {
					place.text = "DRAW!";
				}
				else if(position == 1) {
					place.text = "YOU WON!";
				}
				else {
					place.text = "YOU FINISHED " + position + (position == 2 ? "nd" : (position == 3 ? "rd" : "th"));
				}
				place.x = 0;
				place.width = screen.width;
				place.setTextFormat(tf);
				place.autoSize = TextFieldAutoSize.CENTER;
				place.y = 50;
				place.mouseEnabled = false;
				screen.addChild(place);
				
				tf.size = 14;
				tf.color = -1;
				
				var offsetY:int = 0;
			}
		}
		
		public function PSGameOverScreen(widePanel:Boolean, position:int = -1)
		{
			super("", widePanel);
		}
		
		public override function removeContinueButton():void {
			
		}
		
		private function onLeave():void {
			trace("reporting to playsmart");
			ExternalInterface.call("endGameSuccessful()");
		}
	}
}
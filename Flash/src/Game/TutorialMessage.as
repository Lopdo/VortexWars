package Game
{
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.NinePatchSprite;
	
	import Tutorial.TutorialGame;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class TutorialMessage extends Sprite
	{
		private var game:TutorialGame;
		private var helpPressed:Boolean;
		
		public function TutorialMessage(index:int, text:String, g:TutorialGame, focusRect:Rectangle, helpPressed:Boolean)
		{
			super();
			
			game = g;
			this.helpPressed = helpPressed;
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var titleLabel:TextField = new TextField();
			titleLabel.text = index + " / 17";
			titleLabel.setTextFormat(tf);
			titleLabel.width = 230 - 20;
			titleLabel.x = 10;
			titleLabel.autoSize = TextFieldAutoSize.CENTER;
			titleLabel.y = 40 / 2 - titleLabel.height / 2;
			titleLabel.mouseEnabled = false;
			
			tf.size = 14;
			
			var textLabel:TextField = new TextField();
			textLabel.text = text;
			textLabel.x = 10;
			textLabel.width = 230 - 20;
			textLabel.setTextFormat(tf);
			textLabel.multiline = true;
			textLabel.wordWrap = true;
			textLabel.autoSize = TextFieldAutoSize.CENTER;
			textLabel.y = 50;
			textLabel.mouseEnabled = false;
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_popup", 230, 104 + textLabel.height);
			addChild(bg);

			if(focusRect) {
				graphics.beginFill(0, 0.8);
				graphics.drawRect(0, 0, 800, focusRect.y);
				graphics.drawRect(0, focusRect.y, focusRect.x, 600 - focusRect.y);
				graphics.drawRect(focusRect.x, focusRect.y + focusRect.height, 800 - focusRect.x, 600 - focusRect.y - focusRect.height);
				graphics.drawRect(focusRect.x + focusRect.width, focusRect.y, 800 - focusRect.x - focusRect.width, focusRect.height);
				
				if(focusRect.y + focusRect.height + bg.height + 10 < 600) {
					bg.x = focusRect.x + focusRect.width / 2 - bg.width / 2;
					bg.y = focusRect.y + focusRect.height + 10;
				} 
				else if(focusRect.x + focusRect.width + bg.width + 10 < 800) {
					bg.x = focusRect.x + focusRect.width + 10;
					bg.y = focusRect.y + focusRect.height / 2 - bg.height / 2;
				}
			}
			else {
				graphics.beginFill(0, 0.4);
				graphics.drawRect(0, 0, 800, 600);
				
				bg.x = 565;
				bg.y = 300 - bg.height / 2;
			}
			
			bg.addChild(titleLabel);
			bg.addChild(textLabel);

			/*var button:ButtonHex = new ButtonHex("SKIP", onSkip, "button_small_gray");
			button.x = 20;
			button.y = bg.height - 50;
			bg.addChild(button);*/
			
			var button:ButtonHex = new ButtonHex("NEXT", onNext, "button_small_gold");
			button.x = bg.width / 2 - button.width / 2;
			button.y = bg.height - 50;
			bg.addChild(button);
			if(helpPressed) 
				button.setText("CLOSE");
		}
		
		private function onSkip():void {
			//game.tutorialFinished();
			//game.tutorialClosed();
		}
		
		private function onNext():void {
			parent.removeChild(this);
			if(!helpPressed)
				game.nextTutorialStep();
			//game.tutorialClosed();
		}
	}
}
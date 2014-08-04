package Menu.GameRoom
{
	import IreUtils.ResList;
	
	import Menu.Button;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import flashx.textLayout.operations.CopyOperation;
	
	public class InviteScreen extends Sprite
	{
		private var urlLabel:TextField;
		
		public function InviteScreen(gameName:String)
		{
			super();
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var bgSprite:Sprite = new Sprite();
			bgSprite.addChild(ResList.GetArtResource("menu_dynamicPanel_bg"));
			bgSprite.x = width / 2 - bgSprite.width / 2;
			bgSprite.y = height / 2 - bgSprite.height / 2;
			addChild(bgSprite);
			
			var b:Bitmap = ResList.GetArtResource("menu_label_invite");
			b.x = bgSprite.width / 2 - b.width / 2;
			b.y = 19;
			bgSprite.addChild(b);
			
			var tf:TextFormat = new TextFormat();
			tf.font = "Arial";
			tf.size = 14;
			tf.bold = true;
			tf.color = -1;
			tf.align = TextFormatAlign.CENTER;
							
			var label:TextField = new TextField();
			label.text = "SEND FOLLOWING URL TO YOUR FRIENDS TO INVITE THEM TO THIS GAME";
			label.setTextFormat(tf);
			label.x = 20;
			label.width = bgSprite.width - 40;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 52;
			label.mouseEnabled = false;
			bgSprite.addChild(label);
			
			var editbox:Sprite = new Sprite();
			editbox.addChild(ResList.GetArtResource("menu_editbox_bg"));
			editbox.x = bgSprite.width / 2 - editbox.width / 2;
			editbox.y = 116;
			bgSprite.addChild(editbox);
			
			tf.size = 10;
			tf.color = 0x327623;
			tf.align = TextFormatAlign.LEFT;
			
			urlLabel = new TextField();
			urlLabel.text = "http://vortexwars.com/game/" + escape(gameName);
			urlLabel.setTextFormat(tf);
			urlLabel.x = 6;
			urlLabel.width = 256;
			urlLabel.autoSize = TextFieldAutoSize.LEFT;
			urlLabel.y = editbox.height / 2 - urlLabel.height / 2;
			urlLabel.autoSize = TextFieldAutoSize.NONE;
			urlLabel.width = 256;
			urlLabel.setSelection(0, urlLabel.text.length);
			editbox.addChild(urlLabel);
			
			var button:Button = new Button("OK", onOk, ResList.GetArtResource("button_small_green"));
			button.x = bgSprite.width / 2 - button.width / 2;
			button.y = 172;
			bgSprite.addChild(button);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			stage.focus = urlLabel;
			urlLabel.setSelection(0, urlLabel.text.length);
		}
		
		private function onOk():void {
			parent.removeChild(this);
		}
	}
}
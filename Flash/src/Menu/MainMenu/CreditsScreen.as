package Menu.MainMenu
{
	import IreUtils.ResList;
	
	import Menu.ButtonHex;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class CreditsScreen extends Sprite
	{
		public function CreditsScreen()
		{
			super();
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var bgPanel:NinePatchSprite = new NinePatchSprite("9patch_popup", 300, 420);
			bgPanel.x = width / 2 - bgPanel.width / 2;
			bgPanel.y = height / 2 - bgPanel.height / 2;
			addChild(bgPanel);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = "CREDITS";
			label.width = bgPanel.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			bgPanel.addChild(label);
			
			/*graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			var bgPanel:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 304, 420);
			bgPanel.x = width / 2 - bgPanel.width / 2;
			bgPanel.y = 60;
			addChild(bgPanel);
			
			var tf:TextFormat = new TextFormat("Arial", 20, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.text = "CREDITS";
			label.x = 0;
			label.width = bgPanel.width;
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 22;
			label.mouseEnabled = false;
			bgPanel.addChild(label);*/
			
			tf.size = 16;
			tf.color = 0xAAAAAA;
			
			label = new TextField();
			label.text = "DEVELOPED BY";
			label.x = 0;
			label.width = bgPanel.width;
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 70;
			label.mouseEnabled = false;
			bgPanel.addChild(label);
			
			label = new TextField();
			label.text = "GRAPHICS BY";
			label.x = 0;
			label.width = bgPanel.width;
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 170;
			label.mouseEnabled = false;
			bgPanel.addChild(label);
			
			label = new TextField();
			label.text = "MUSIC BY";
			label.x = 0;
			label.width = bgPanel.width;
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 270;
			label.mouseEnabled = false;
			bgPanel.addChild(label);
			
			tf.size = 20;
			tf.color = -1;
			
			label = new TextField();
			label.text = "LOST BYTES";
			label.x = 0;
			label.width = bgPanel.width;
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 100;
			label.mouseEnabled = false;
			bgPanel.addChild(label);
			
			label = new TextField();
			label.text = "DAODESIGN";
			label.x = 0;
			label.width = bgPanel.width;
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 200;
			label.mouseEnabled = false;
			bgPanel.addChild(label);
			
			label = new TextField();
			label.text = "Tomas Timmy Valent";
			label.x = 0;
			label.width = bgPanel.width;
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 300;
			label.mouseEnabled = false;
			bgPanel.addChild(label);
			
			tf.size = 16;
			
			label = new TextField();
			label.text = "tms.valent@gmail.com";
			label.x = 0;
			label.width = bgPanel.width;
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 330;
			label.mouseEnabled = false;
			bgPanel.addChild(label);
			
			var button:ButtonHex = new ButtonHex("CLOSE", onClose, "button_small_gray");
			button.x = bgPanel.width / 2 - button.width / 2;
			button.y = bgPanel.height - 46;
			bgPanel.addChild(button);
			//addChild(new MenuShortcutsPanel(onBack));
			
			G.gatracker.trackPageview("/creadits");
		}
		
		private function onClose():void {
			//parent.addChild(new MainMenu());
			parent.removeChild(this);
		}
	}
}
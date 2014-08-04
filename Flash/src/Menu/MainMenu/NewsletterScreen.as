package Menu.MainMenu
{
	import Errors.ErrorManager;
	
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.Loading;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.utils.StringUtil;
	
	public class NewsletterScreen extends Sprite
	{
		private var emailField:TextField;
		
		public function NewsletterScreen()
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 400, 300);
			bg.x = 400 - bg.width / 2;
			bg.y = 300 - bg.width / 2;
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Arial", 20, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.text = "DO YOU WANT TO RECEIVE NEWS AND SPECIAL OFFERS?";
			label.x = 30;
			label.width = bg.width - 60;
			label.y = 22;
			label.multiline = true;
			label.wordWrap = true;
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			tf.color = 0xDDDDDD;
			tf.size = 16;
			
			label = new TextField();
			label.text = "SIGN UP FOR THE VORTEX WARS NEWSLETTER";
			label.x = 30;
			label.y = 85;
			label.width = bg.width - 60;
			label.multiline = true;
			label.wordWrap = true;
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			tf.size = 14;
			tf.bold = false;
			tf.color = 0xBBBBBB;
			
			var editbox:NinePatchSprite = new NinePatchSprite("9patch_editText", 266, 26);
			editbox.x = bg.width / 2 - editbox.width / 2;
			editbox.y = 166;
			bg.addChild(editbox);
			
			label = new TextField();
			label.text = "ENTER YOUR EMAIL ADDRESS:";
			label.x = editbox.x + 5;
			label.y = editbox.y - 20;
			label.setTextFormat(tf);
			label.autoSize = TextFieldAutoSize.LEFT;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			var editTF:TextFormat = new TextFormat("Arial", 14, -1, true);
			editTF.align = TextFormatAlign.LEFT;
			
			emailField = new TextField();
			emailField.type = TextFieldType.INPUT;
			emailField.defaultTextFormat = editTF;
			emailField.x = 10;
			emailField.width = editbox.width - 20;
			emailField.autoSize = TextFieldAutoSize.LEFT;
			//emailField.y = 170;
			emailField.y = editbox.height / 2 - emailField.height / 2;
			emailField.autoSize = TextFieldAutoSize.NONE;
			emailField.width = editbox.width - 20;
			editbox.addChild(emailField);
			
			var button:ButtonHex = new ButtonHex("SIGN UP", onSignupPressed, "button_medium_gold", 24, -1, 200);
			button.x = bg.width / 2 - button.width / 2;
			button.y = 210;
			bg.addChild(button);
			
			addChild(new MenuShortcutsPanel(onBack));
			
			G.gatracker.trackPageview("/newsletter");
		}
		
		private function onSignupPressed():void {
			if(StringUtil.trim(emailField.text).length == 0) {
				ErrorManager.showCustomError("Email field can't be empty", 0);
				return;
			}
			
			var loading:Loading = new Loading("SIGNING UP...");
			addChild(loading);
			
			var myLoader:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest("http://www.lost-bytes.com/phplist/?p=subscribe");
			req.method = URLRequestMethod.POST;
			
			var variables:URLVariables = new URLVariables(); 
			variables.email = emailField.text;
			if(G.host == G.HOST_KONGREGATE) {
				variables.listid = 2;
			}
			else if(G.host == G.HOST_ARMORGAMES) {
				variables.listid = 3;
			}
			else {
				variables.listid = 1;	
			}
			variables.silent = 1;
			req.data = variables; 
			
			Security.allowDomain("*");
			myLoader.addEventListener(Event.COMPLETE, function(evt:Event):void {
				trace(evt.target.data);
				removeChild(loading);
				ErrorManager.showCustomError2("You have been successfuly signed up for newsletter", "Success", 0);
			});
			myLoader.load(req);
			
			G.gatracker.trackPageview("/newsletter/signup");
		}
		
		private function onBack():void {
			parent.addChild(new MainMenu());
			parent.removeChild(this);
		}
	}
}
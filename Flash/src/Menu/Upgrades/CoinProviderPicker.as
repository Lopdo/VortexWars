package Menu.Upgrades
{
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.PlayerIOError;
	
	public class CoinProviderPicker extends Sprite
	{
		public function CoinProviderPicker()
		{
			super();
			
			graphics.beginFill(0, 0.8);
			graphics.drawRect(0, 0, 800, 600);
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_popup", 366, 300);
			bg.x = width / 2 - bg.width / 2;
			bg.y = height / 2 - bg.height / 2;
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = "ADD COINS";
			label.width = bg.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			tf.size = 16;
			
			label = new TextField();
			label.text = "CHOOSE PAYPAL TO BUY COINS\nOR SUPER REWARDS OR GAMBIT TO GET SOME COINS FOR FREE";
			label.setTextFormat(tf);
			label.multiline = true;
			label.wordWrap = true;
			label.mouseEnabled = true;
			label.x = 20;
			label.width = bg.width - 40;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 60;
			bg.addChild(label);
			
			var okButton:ButtonHex = new ButtonHex("BACK", onBack, "button_small_gray", 14, -1, 80);
			okButton.y = 256;
			okButton.x = bg.width / 2 - okButton.width / 2;
			bg.addChild(okButton);
			
			var button:Button = new Button(null, onPaypalClicked, ResList.GetArtResource("shop_logo_paypal"));
			button.x = 24;
			button.y = 144;
			bg.addChild(button);
			
			button = new Button(null, onSuperRewardsClicked, ResList.GetArtResource("shop_logo_sr"));
			button.x = 188;
			button.y = 145;
			bg.addChild(button);
			
			button = new Button(null, onGambitClicked, ResList.GetArtResource("shop_logo_gambit"));
			button.x = 188;
			button.y = 200;
			bg.addChild(button);

			G.gatracker.trackPageview("/shop/coinProvider/");
		}
		
		private function onBack():void {
			parent.removeChild(this);
		}
		
		private function onSuperRewardsClicked(button:Button):void {
			G.client.payVault.getBuyCoinsInfo(
				"superrewards",					//provider
				{},								//Provider arguments
				//Success handler
				function(info:Object):void{
					navigateToURL(new URLRequest(info.superrewardsurl), "_blank")
				},
				//Error handler
				function(e:PlayerIOError):void{ trace("Unable to buy item", e) }
			);
			G.gatracker.trackPageview("/shop/coinProvider/superRewards");
		}
		
		private function onPaypalClicked(button:Button):void {
			parent.addChild(new PayPalPricePicker());
			parent.removeChild(this);
		}
		
		private function onGambitClicked(button:Button):void {
			G.client.payVault.getBuyCoinsInfo(
				"gambit",					//provider
				{},							//Provider arguments
				//Success handler
				function(info:Object):void{
					navigateToURL(new URLRequest(info.gambiturl), "_blank")
				},
				//Error handler
				function(e:PlayerIOError):void{ trace("Unable to buy item", e) }
			);
			G.gatracker.trackPageview("/shop/coinProvider/gambit");
		}
	}
}
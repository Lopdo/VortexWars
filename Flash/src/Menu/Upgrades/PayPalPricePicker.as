package Menu.Upgrades
{
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.NinePatchSprite;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.BigDB;
	import playerio.PlayerIOError;
	
	public class PayPalPricePicker extends Sprite
	{
		public function PayPalPricePicker()
		{
			super();
			
			graphics.beginFill(0, 0.8);
			graphics.drawRect(0, 0, 800, 600);
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_popup", 350, 380);
			bg.x = width / 2 - bg.width / 2;
			bg.y = height / 2 - bg.height / 2;
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = "BUY COINS";
			label.width = bg.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			tf.size = 16;
			
			for(var i:int = 0; i < 7; i++) {
				var coinCount:TextField = new TextField();
				switch(i) {
					case 0: coinCount.text = "BUY 55"; break;		// 27.5 coins
					case 1: coinCount.text = "BUY 140"; break;		// 28 coins
					case 2: coinCount.text = "BUY 300"; break;		// 30 coins
					case 3: coinCount.text = "BUY 630"; break;		// 31.5 coins
					case 4: coinCount.text = "BUY 1700"; break;		// 34 coins
					case 5: coinCount.text = "BUY 3600"; break;		// 36
					case 6: coinCount.text = "BUY 10000"; break;		// 40 coins
				}
				coinCount.setTextFormat(tf);
				coinCount.x = 10;
				coinCount.width = 110;
				coinCount.autoSize = TextFieldAutoSize.RIGHT;
				coinCount.y = 44 + i * 40 + 20 - coinCount.height / 2;
				coinCount.mouseEnabled = false;
				bg.addChild(coinCount);
				
				var coinIcon:Bitmap = ResList.GetArtResource("shop_coin");
				coinIcon.x = coinCount.x + coinCount.width + 5;
				coinIcon.y = 44 + i * 40 + 20 - coinIcon.height / 2;
				bg.addChild(coinIcon);
				
				var price:TextField = new TextField();
				switch(i) {
					case 0: price.text = "$2"; break;
					case 1: price.text = "$5"; break;
					case 2: price.text = "$10"; break;
					case 3: price.text = "$20"; break;
					case 4: price.text = "$50"; break;
					case 5: price.text = "$100"; break;
					case 6: price.text = "$250"; break;
				}
				price.setTextFormat(tf);
				price.x = 160;
				price.width = 70;
				price.autoSize = TextFieldAutoSize.CENTER;
				price.y = 44 + i * 40 + 20 - price.height / 2;
				price.mouseEnabled = false;
				bg.addChild(price);
				
				var button:ButtonHex = new ButtonHex("BUY", null, "button_small_gold");
				button.x = 220;
				button.y = 44 + i * 40;
				switch(i) {
					case 0: button.setCallback(function():void { onButtonClicked(0); }); break;
					case 1: button.setCallback(function():void { onButtonClicked(1); }); break;
					case 2: button.setCallback(function():void { onButtonClicked(2); }); break;
					case 3: button.setCallback(function():void { onButtonClicked(3); }); break;
					case 4: button.setCallback(function():void { onButtonClicked(4); }); break;
					case 5: button.setCallback(function():void { onButtonClicked(5); }); break;
					case 6: button.setCallback(function():void { onButtonClicked(6); }); break;
				}
				bg.addChild(button);
				
				var divider:Sprite = new Sprite();
				divider.addChild(ResList.GetArtResource("menu_divider_horizontal"));
				divider.width = 300;
				divider.y = 40 + i * 40 + 40;
				divider.x = 25;
				bg.addChild(divider);
			}
			
			var backButton:ButtonHex = new ButtonHex("BACK", onBack, "button_small_gray");
			backButton.x = bg.width / 2 - backButton.width / 2;
			backButton.y = 330;
			bg.addChild(backButton);
			
			G.gatracker.trackPageview("/shop/paypalPicker");
		}
		
		private function onBack():void {
			parent.removeChild(this);
		}
		
		private function onButtonClicked(index:int):void {
			trace(index);
			
			var args:Object = new Object;
			args.currency = "USD";
			
			switch(index) {
				case 0:
					args.coinamount = "55";
					args.item_name = "55 Coins";
					break;
				case 1:
					args.coinamount = "140";
					args.item_name = "140 Coins";
					break;
				case 2:
					args.coinamount = "300";
					args.item_name = "300 Coins";
					break;
				case 3:
					args.coinamount = "630";
					args.item_name = "630 Coins";
					break;
				case 4:
					args.coinamount = "1700";
					args.item_name = "1700 Coins";
					break;
				case 5:
					args.coinamount = "3600";
					args.item_name = "3600 Coins";
					break;
				case 6:
					args.coinamount = "10000";
					args.item_name = "10000 Coins";
					break;
			}
			
			var self:DisplayObject = this;
			
			//http://api.playerio.com/payvault/paypal/coinsredirect?gameid=test-dlvdxyjssuuirshlm7hj9w&connectuserid=testuser&connection=public&coinamount=100&currency=USD&item_name=100%20Coins
			var url:String = "http://api.playerio.com/payvault/paypal/coinsredirect?gameid=" + G.gameID + "&connectuserid=" + G.user.playerObject.key + "&connection=public&coinamount=" + args.coinamount + "&currency=USD&item_name=" + args.item_name;
			navigateToURL(new URLRequest(url), "_blank");
			parent.addChild(new PaypalPopupInfo(url, ShopScreen(parent).refresh));
			parent.removeChild(this);
			/*G.client.payVault.getBuyCoinsInfo(
				"paypal",									//Provider name
				args,
				//Success handler
				function(info:Object):void{
					navigateToURL(new URLRequest(info.paypalurl), "_blank");
					parent.addChild(new PaypalPopupInfo(info.paypalurl, ShopScreen(parent).refresh));
					parent.removeChild(self);
				},
				//Error handler
				function(e:PlayerIOError):void{ trace("Unable to buy coins", e) }	
			)*/
			
			G.gatracker.trackPageview("/shop/paypalPicker/" + args.coinAmount);
		}
	}
}
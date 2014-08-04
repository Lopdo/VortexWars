package Menu.Upgrades
{
	import Errors.ErrorManager;
	
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.Loading;
	import Menu.NinePatchSprite;
	
	import flash.display.Bitmap;
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
	
	public class FacebookPricePicker extends Sprite
	{
		private var loading:Loading;

		public function FacebookPricePicker()
		{
			super();
			
			graphics.beginFill(0, 0.8);
			graphics.drawRect(0, 0, 800, 600);
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_popup", 380, 336);
			bg.x = width / 2 - bg.width / 2;
			bg.y = height / 2 - bg.height / 2;
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
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
			
			for(var i:int = 0; i < 6; i++) {
				var coinCount:TextField = new TextField();
				switch(i) {
					case 0: coinCount.text = "BUY 50"; break;
					case 1: coinCount.text = "BUY 140"; break;
					case 2: coinCount.text = "BUY 300"; break;
					case 3: coinCount.text = "BUY 630"; break;
					case 4: coinCount.text = "BUY 1700"; break;
					case 5: coinCount.text = "BUY 3600"; break;
				}
				coinCount.setTextFormat(tf);
				coinCount.x = 10;
				coinCount.width = 90;
				coinCount.autoSize = TextFieldAutoSize.RIGHT;
				coinCount.y = 56 + i * 40;
				coinCount.mouseEnabled = false;
				bg.addChild(coinCount);
				
				var coinIcon:Bitmap = ResList.GetArtResource("shop_coin");
				coinIcon.x = coinCount.x + coinCount.width + 5;
				coinIcon.y = coinCount.y + coinCount.height / 2 - coinIcon.height / 2;
				bg.addChild(coinIcon);
				
				var price:TextField = new TextField();
				switch(i) {
					case 0: price.text = "20 Credits"; break;
					case 1: price.text = "50 Credits"; break;
					case 2: price.text = "100 Credits"; break;
					case 3: price.text = "200 Credits"; break;
					case 4: price.text = "500 Credits"; break;
					case 5: price.text = "1000 Credits"; break;
				}
				price.setTextFormat(tf);
				price.x = 153;
				price.width = 100;
				price.autoSize = TextFieldAutoSize.CENTER;
				price.y = coinCount.y
				price.mouseEnabled = false;
				bg.addChild(price);
				
				var creditsIcon:Bitmap = ResList.GetArtResource("shop_fbcredits");
				creditsIcon.x = 252;
				creditsIcon.y = price.y + price.height / 2 - creditsIcon.height / 2;
				bg.addChild(creditsIcon);
				
				var button:ButtonHex = new ButtonHex("BUY", null, "button_small_gold");
				button.x = 280;
				button.y = coinCount.y + coinCount.height / 2 - button.height / 2 + 0.5;
				switch(i) {
					case 0: button.setCallback(function():void { onButtonClicked(0); }); break;
					case 1: button.setCallback(function():void { onButtonClicked(1); }); break;
					case 2: button.setCallback(function():void { onButtonClicked(2); }); break;
					case 3: button.setCallback(function():void { onButtonClicked(3); }); break;
					case 4: button.setCallback(function():void { onButtonClicked(4); }); break;
					case 5: button.setCallback(function():void { onButtonClicked(5); }); break;
				}
				bg.addChild(button);

				var divider:Sprite = new Sprite();
				divider.addChild(ResList.GetArtResource("menu_divider_horizontal"));
				divider.width = 330;
				divider.y = coinCount.y + 30;
				divider.x = 25;
				bg.addChild(divider);
			}
			
			var okButton:ButtonHex = new ButtonHex("BACK", onBack, "button_small_gray", 14, -1, 80);
			okButton.y = 292;
			okButton.x = bg.width / 2 - okButton.width / 2;
			bg.addChild(okButton);
		}
		
		private function onBack():void {
			parent.removeChild(this);
		}
		
		private function onButtonClicked(index:int):void {
			loading = new Loading();
			addChild(loading);

			var coinsCount:int;			
			switch(index) {
				case 0:	coinsCount = 55; 	break;
				case 1:	coinsCount = 140;	break;
				case 2:	coinsCount = 300;	break;
				case 3:	coinsCount = 630;	break;
				case 4:	coinsCount = 1700;	break;
				case 5:	coinsCount = 3600;	break;
			}

			var self:Sprite = this;
			
			G.client.payVault.getBuyCoinsInfo(
				"facebook",										//Provider name
				{												//Purchase arguments
					coinamount:"" + coinsCount,							//(See table below)
					title:coinsCount + " Coins",
					description:"Buy " + coinsCount + " Coins for Vortex Wars",
					image_url:"http://www.lost-bytes.com/vortexwars/images/shop_coin.png",
					product_url:"http://www.lost-bytes.com/vortexwars/images/shop_coin.png" 
				},
				//Success handler
				function(info:Object):void{
					/*Facebook.ui(info, function(data:Object):void {
						if (data.order_id) {
							trace("Purchase completed!");
							G.client.payVault.refresh(function():void {		//Refresh
								removeChild(loading);
								ShopScreen(parent).updateShop();
								parent.removeChild(self);
							});
						} else {
							trace("Purchase failed.");
							removeChild(loading);
							parent.removeChild(self);
						}
					});*/
				},
				//Error handler
				function(e:PlayerIOError):void{ 
					trace("Unable to buy coins", e);
					removeChild(loading);
					parent.removeChild(self);
				}	
			)
		}
	}
}
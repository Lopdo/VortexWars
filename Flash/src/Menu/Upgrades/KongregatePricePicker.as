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
	
	public class KongregatePricePicker extends Sprite
	{
		private var loading:Loading;

		public function KongregatePricePicker()
		{
			super();
			
			graphics.beginFill(0, 0.8);
			graphics.drawRect(0, 0, 800, 600);
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_popup", 350, 336);
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
					case 0: coinCount.text = "BUY 25"; break;
					case 1: coinCount.text = "BUY 50"; break;
					case 2: coinCount.text = "BUY 140"; break;
					case 3: coinCount.text = "BUY 300"; break;
					case 4: coinCount.text = "BUY 630"; break;
					case 5: coinCount.text = "BUY 1700"; break;
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
					case 0: price.text = "10 Kreds"; break;
					case 1: price.text = "20 Kreds"; break;
					case 2: price.text = "50 Kreds"; break;
					case 3: price.text = "100 Kreds"; break;
					case 4: price.text = "200 Kreds"; break;
					case 5: price.text = "500 Kreds"; break;
				}
				price.setTextFormat(tf);
				price.x = 153;
				price.width = 100;
				price.autoSize = TextFieldAutoSize.CENTER;
				price.y = coinCount.y
				price.mouseEnabled = false;
				bg.addChild(price);
				
				var button:ButtonHex = new ButtonHex("BUY", null, "button_small_gold");
				button.x = 250;
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
				divider.width = 300;
				divider.y = coinCount.y + 30;
				divider.x = 25;
				bg.addChild(divider);
			}
			
			var okButton:ButtonHex = new ButtonHex("BACK", onBack, "button_small_gray", 14, -1, 80);
			okButton.y = 292;
			okButton.x = bg.width / 2 - okButton.width / 2;
			bg.addChild(okButton);
			
			G.gatracker.trackPageview("/shop/kongregatePicker");
		}
		
		private function onBack():void {
			parent.removeChild(this);
		}
		
		private function onButtonClicked(index:int):void {
			var coinsName:String;			
			switch(index) {
				case 0:
					coinsName = "coins25";
					break;
				case 1:
					coinsName = "coins50";
					break;
				case 2:
					coinsName = "coins140";
					break;
				case 3:
					coinsName = "coins300";
					break;
				case 4:
					coinsName = "coins630";
					break;
				case 5:
					coinsName = "coins1700";
					break;
			}
			
			loading = new Loading();
			addChild(loading);
			
			try {
				G.kongregate.mtx.purchaseItems([coinsName], buyResult);
			}
			catch(err:Error) {
				ErrorManager.showCustomError(err.message + " " + err.getStackTrace(), 2);
			}
			
			G.gatracker.trackPageview("/shop/kongregatePicker/" + coinsName);
		}
		
		private function buyResult(result:Object):void {
			var self:Sprite = this;

			if (result.success) {
				G.client.payVault.refresh(function():void {		//Refresh
					removeChild(loading);
					ShopScreen(parent).updateShop();
					parent.removeChild(self);
				});
				G.gatracker.trackPageview("/shop/kongregatePicker/success");
			}
			else {
				removeChild(loading);
				parent.removeChild(self);
				G.gatracker.trackPageview("/shop/kongregatePicker/error");
			}
		}
	}
}
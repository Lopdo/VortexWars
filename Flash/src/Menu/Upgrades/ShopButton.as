package Menu.Upgrades
{
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.core.TextFieldAsset;
	
	public class ShopButton extends Sprite
	{
		private var nameLabel:TextField;
		private var priceLabel:TextField;
		
		private var callback:Function;
		
		public function ShopButton(itemName:String, price:int, imageName:String, callback:Function)
		{
			super();
			
			this.callback = callback;
			
			addChild(ResList.GetArtResource(imageName));
			
			var b:Bitmap = ResList.GetArtResource("shop_coin");
			b.x = 225;
			b.y = height / 2 - b.height / 2;
			addChild(b);
			
			var tf:TextFormat = new TextFormat();
			tf.font = "Arial";
			tf.size = 18;
			tf.color = -1;
			tf.bold = true;
			tf.align = TextFormatAlign.RIGHT;
			
			priceLabel = new TextField();
			priceLabel.defaultTextFormat = tf;
			priceLabel.text = price.toString();
			priceLabel.setTextFormat(tf);
			priceLabel.x = 183;
			priceLabel.width = 40;
			priceLabel.autoSize = TextFieldAutoSize.RIGHT;
			priceLabel.y = height / 2 - priceLabel.height / 2;
			priceLabel.mouseEnabled = false;
			addChild(priceLabel);
			
			nameLabel = new TextField();
			addChild(nameLabel);
			
			setItemName(itemName);
			
			addEventListener(MouseEvent.MOUSE_UP, onClick, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, playSound, false, 0, true);
			useHandCursor = true;
			buttonMode = true;
		}
		
		public function setItemName(itemName:String):void {
			var tf:TextFormat = new TextFormat();
			tf.font = "Arial";
			tf.size = 18;
			tf.color = -1;
			tf.bold = true;
			tf.align = TextFormatAlign.LEFT;
			
			nameLabel.text = itemName;
			nameLabel.x = 18;
			nameLabel.width = 180 - 36;
			nameLabel.setTextFormat(tf);
			nameLabel.autoSize = TextFieldAutoSize.LEFT;
			nameLabel.mouseEnabled = false;
			if(nameLabel.width > (180 - 36)) {
				tf.size = int(tf.size) - 1;
				nameLabel.setTextFormat(tf);
				nameLabel.x = 10;
				nameLabel.width = 180 - 20;
				nameLabel.autoSize = TextFieldAutoSize.CENTER;
				while(nameLabel.width > 180 - 20) {
					tf.size = int(tf.size) - 1;
					nameLabel.setTextFormat(tf);
				}
			}
			nameLabel.y = height / 2 - nameLabel.height / 2;
		}
		
		public function setPrice(price:int):void {
			priceLabel.text = price.toString();
		}
		
		private function playSound(event:MouseEvent):void {
			if(callback != null) {
				G.sounds.playSound("button_click0");
			}
		}
		
		private function onClick(event:MouseEvent):void {
			if(callback != null) {
				Input.mouseHandled = true;
				callback();
			}
		}
	}
}
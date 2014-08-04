package Menu
{
	import IreUtils.ResList;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class MenuSelector extends Sprite
	{
		private var items:Array = new Array();
		private var currentItemName:TextField;
		
		private var leftArrow:Sprite;
		private var rightArrow:Sprite;
		
		private var currentItem:int = 0;
		public var callback:Function;
		
		public function MenuSelector(w:int, h:int)
		{
			super();
			
			//width = w;
			//height = h;
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, 1, h);
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "Arial";
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.size = 18;
			textFormat.bold = true;
			textFormat.color = -1;
			
			currentItemName = new TextField();
			currentItemName.width = w;
			currentItemName.defaultTextFormat = textFormat;
			currentItemName.mouseEnabled = false;
			currentItemName.text = "0";
			currentItemName.autoSize = TextFieldAutoSize.CENTER;
			currentItemName.y = h / 2 - currentItemName.height / 2;
			currentItemName.text = "";
			currentItemName.mouseEnabled = false;
			addChild(currentItemName);
			
			leftArrow = new Sprite();
			leftArrow.addChild(ResList.GetArtResource("selector_arrow_disabled"));
			leftArrow.x = 0;
			leftArrow.y = h / 2 - leftArrow.height / 2; 
			leftArrow.addEventListener(MouseEvent.CLICK, OnMoveLeft, false, 0, true);
			leftArrow.useHandCursor = true;
			leftArrow.buttonMode = true;
			addChild(leftArrow);
			
			rightArrow = new Sprite();
			rightArrow.addChild(ResList.GetArtResource("selector_arrow_disabled"));
			rightArrow.x = w;
			rightArrow.scaleX = -1;
			rightArrow.y = h / 2 - rightArrow.height / 2;
			rightArrow.addEventListener(MouseEvent.CLICK, OnMoveRight, false, 0, true);
			rightArrow.useHandCursor = true;
			rightArrow.buttonMode = true;
			addChild(rightArrow);
		}
		
		public function removeAllItems():void {
			items.length = 0;
			currentItem = 0;
			currentItemName.text = "";
		}
		
		public function AddItem(itemName:String, data:int):void {
			items.push(new SelectorData(itemName, data));
			
			// set first item as default index
			if(items.length == 1) {
				currentItemName.text = itemName;
			}
		}
		
		public function GetCurrentItemIndex():int {
			return currentItem;
		}
		
		public function GetCurrentItemData():int {
			return items[currentItem].data;
		}
		
		public function GetItemData(index:int):int {
			return items[index].data;
		}
		
		public function SetActiveItem(index:int):void {
			if(index < 0 || index >= items.length) {
				trace("invalid selector index: " + index);
				return;
			}
			currentItem = index;
			
			currentItemName.text = items[currentItem].name;
			if(callback != null) {
				callback(items[currentItem].data);
			}
		}
		
		public function SetActiveItemByData(data:int):void {
			for(var i:int = 0; i < items.length; ++i) {
				if(items[i].data == data) {
					SetActiveItem(i);
					return;
				}
			}
			
			trace("no item with data " + data + " found!");
		}
		
		private function OnMoveLeft(event:MouseEvent):void {
			currentItem--;
			if(currentItem < 0) {
				currentItem = items.length - 1;
			}
			
			currentItemName.text = items[currentItem].name;

			if(callback != null) {
				callback(items[currentItem].data);
			}
		}
		
		private function OnMoveRight(event:MouseEvent):void {
			currentItem++;
			if(currentItem > items.length - 1) {
				currentItem = 0;
			}
			
			currentItemName.text = items[currentItem].name;
			
			if(callback != null) {
				callback(items[currentItem].data);
			}
		}
	}
}

class SelectorData {
	public var data:int;
	public var name:String;
	
	public function SelectorData(n:String, d:int) {
		data = d;
		name = n;
	}
}

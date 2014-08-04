package MapEditor
{
	import Menu.ButtonHex;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class MapEditorAdminDenyWindow extends Sprite
	{
		private var reasonField:TextField;
		
		private var mapKey:String;
		
		public function MapEditorAdminDenyWindow(key:String)
		{
			super();
		
			mapKey = key;
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var tf:TextFormat = new TextFormat("Arial", 14, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = "Please enter reason for denying this map";
			label.width = 280;
			label.x = 10;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 50;
			label.mouseEnabled = false;
			
			var dialogSprite:NinePatchSprite = new NinePatchSprite("9patch_popup", 300, 180);
			dialogSprite.x = width / 2 - dialogSprite.width / 2;
			dialogSprite.y = height / 2 - dialogSprite.height / 2;
			addChild(dialogSprite);
			
			dialogSprite.addChild(label);
			
			var editbox:NinePatchSprite = new NinePatchSprite("9patch_editText", 266, 26);
			editbox.x = dialogSprite.width / 2 - editbox.width / 2;
			editbox.y = 106;
			dialogSprite.addChild(editbox);
			
			var editTF:TextFormat = new TextFormat("Arial", 14, -1, true);
			editTF.align = TextFormatAlign.LEFT;
			
			reasonField = new TextField();
			reasonField.type = TextFieldType.INPUT;
			reasonField.defaultTextFormat = editTF;
			reasonField.x = 10;
			reasonField.width = editbox.width - 20;
			reasonField.autoSize = TextFieldAutoSize.LEFT;
			//emailField.y = 170;
			reasonField.y = editbox.height / 2 - reasonField.height / 2;
			reasonField.autoSize = TextFieldAutoSize.NONE;
			reasonField.width = editbox.width - 20;
			editbox.addChild(reasonField);
			
			var self:Sprite = this;
			
			var okButton:ButtonHex = new ButtonHex("DENY", onDenyPressed, "button_small_gold");
			okButton.y = dialogSprite.height - 40;
			okButton.x = dialogSprite.width / 2 - okButton.width / 2;
			dialogSprite.addChild(okButton);
			
			var cancelButton:ButtonHex = new ButtonHex("CANCEL", function():void { parent.removeChild(self); }, "button_small_gray");
			var space:int = (300 - okButton.width - cancelButton.width) / 3;
			okButton.x = space;
			cancelButton.x = okButton.width + 2*space;
			cancelButton.y = dialogSprite.height - 40;
			dialogSprite.addChild(cancelButton);
			
			//G.sounds.playSound("error_dialog");
		}
		
		private function onDenyPressed():void {
			if(parent is MapEditorAdmin) {
				MapEditorAdmin(parent).onDenyConfirmed(mapKey, reasonField.text);
			}
			else {
				MapEditorAdminNew(parent).onDenyConfirmed(mapKey, reasonField.text);
			}
			parent.removeChild(this);
		}
	}
}
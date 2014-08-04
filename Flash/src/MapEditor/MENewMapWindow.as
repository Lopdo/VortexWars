package MapEditor
{
	import Errors.ErrorManager;
	
	import Menu.ButtonHex;
	import Menu.Loading;
	import Menu.NinePatchSprite;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.Message;
	
	public class MENewMapWindow extends Sprite
	{
		private var mapNameField:TextField;
		private var loading:Loading;
		
		public function MENewMapWindow()
		{
			super();
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_popup", 340, 200);
			bg.x = width / 2 - bg.width / 2;
			bg.y = height / 2 - bg.height / 2;
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			
			var label:TextField = new TextField();
			label.text = "MAP NAME";
			label.setTextFormat(tf);
			label.width = bg.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			tf.size = 14;
			
			label = new TextField();
			label.text = "Choose name for your new map.\nIt can be changed later.";
			label.setTextFormat(tf);
			label.width = bg.width - 40;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 50;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			var editbox:NinePatchSprite = new NinePatchSprite("9patch_editText", 266, 26);
			editbox.x = bg.width / 2 - editbox.width / 2;
			editbox.y = 110;
			bg.addChild(editbox);
			
			var editTF:TextFormat = new TextFormat("Arial", 14, -1, true);
			editTF.align = TextFormatAlign.LEFT;
			
			mapNameField = new TextField();
			mapNameField.type = TextFieldType.INPUT;
			mapNameField.defaultTextFormat = editTF;
			mapNameField.x = 10;
			mapNameField.width = editbox.width - 20;
			mapNameField.autoSize = TextFieldAutoSize.LEFT;
			//emailField.y = 170;
			mapNameField.y = editbox.height / 2 - mapNameField.height / 2;
			mapNameField.autoSize = TextFieldAutoSize.NONE;
			mapNameField.width = editbox.width - 20;
			mapNameField.maxChars = 20;
			editbox.addChild(mapNameField);
			
			var button:ButtonHex = new ButtonHex("CREATE", onCreatePressed, "button_small_gold");
			button.x = bg.width / 2 + button.width / 2;
			button.y = 152;
			bg.addChild(button);
			
			button = new ButtonHex("CANCEL", onQuit, "button_small_gray");
			button.x = bg.width / 2 - 1.5 * button.width;
			button.y = 152;
			bg.addChild(button);
			
			G.userConnection.addMessageHandler(MessageID.MAP_EDITOR_NEW_MAP_RESULT, onNewMapResult);
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			G.userConnection.removeMessageHandler(MessageID.MAP_EDITOR_NEW_MAP_RESULT, onNewMapResult);
		}

		private function onCreatePressed():void {
			if(mapNameField.text.length == 0) {
				ErrorManager.showCustomError("Map name can't be empty", 0);
				return;
			}
			
			G.userConnection.send(MessageID.MAP_EDITOR_NEW_MAP, mapNameField.text);
			
			loading = new Loading("CREATING...");
			parent.addChild(loading);
		}
		
		private function onQuit():void {
			parent.removeChild(this);
			
			//G.userConnection.removeMessageHandler(MessageID.MAP_EDITOR_NEW_MAP_RESULT, onNewMapResult);
		}
		
		private function onNewMapResult(message:Message):void {
			if(loading) {
				parent.removeChild(loading);
				loading = null;
			}
			
			if(message.getInt(0) != -1) {
				ErrorManager.showCustomError("Map couldn't be created (" + message.getInt(0) + "), please try again later", 0);
			}
			else {
				MapEditorHome(parent).mapCreated(message.getString(1));
			}
		}
	}
}
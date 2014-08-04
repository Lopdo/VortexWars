package Menu.Social
{
	import Menu.ButtonHex;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class BlacklistPlayerCell extends Sprite
	{
		public var playerKey:String;
		private var blacklist:SocialBlacklist;
		
		public function BlacklistPlayerCell(playerKey:String, name:String, reason:String, blacklist:SocialBlacklist)
		{
			super();
			
			this.blacklist = blacklist;
			this.playerKey = playerKey;
			
			var labelName:TextField = new TextField();
			labelName.text = name;
			labelName.setTextFormat(new TextFormat("Arial", 16, -1, true));
			labelName.autoSize = TextFieldAutoSize.LEFT;
			labelName.x = 10;
			labelName.y = 4;
			labelName.mouseEnabled = false;
			
			var labelReason:TextField = new TextField();
			labelReason.text = reason;
			labelReason.setTextFormat(new TextFormat("Arial", 14, 0xBBBBBB, true));
			labelReason.multiline = true;
			labelReason.wordWrap = true;
			labelReason.mouseEnabled = false;
			labelReason.x = 10;
			labelReason.y = 24;
			labelReason.width = 280;
			labelReason.autoSize = TextFieldAutoSize.LEFT;

			var bg:NinePatchSprite = new NinePatchSprite("9patch_context", 400, 30 + labelReason.height);
			addChild(bg);
			bg.addChild(labelName);
			bg.addChild(labelReason);
			
			var button:ButtonHex = new ButtonHex("UNBAN", onUnbanPressed, "button_small_gray");
			button.x = bg.width - button.width - 10;
			button.y = bg.height / 2 - button.height / 2;
			bg.addChild(button);
		}
		
		private function onUnbanPressed():void {
			blacklist.unbanPlayer(playerKey);
		}
	}
}
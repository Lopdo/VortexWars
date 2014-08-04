package Menu.Social
{
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.Loading;
	import Menu.NinePatchSprite;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import playerio.Message;
	
	public class SocialScreen extends Sprite
	{
		private var buttonFriends:ButtonHex;
		private var buttonClan:ButtonHex;
		private var buttonBlacklist:ButtonHex;
		private var buttonUsers:ButtonHex;
		
		private var contentSprite:Sprite;
		
		public var rootSprite:DisplayObject;
		
		public function SocialScreen(rootSprite:DisplayObject)
		{
			super();
			
			this.rootSprite = rootSprite;
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_popup", 656, 530);
			bg.x = 400 - bg.width / 2;
			bg.y = 22;
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			
			var label:TextField = new TextField();
			label.text = "SOCIAL SCREEN";
			label.setTextFormat(tf);
			label.width = bg.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			var tabbar:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 184, 474);
			tabbar.x = 10;
			tabbar.y = 50;
			bg.addChild(tabbar);
			
			buttonFriends = new ButtonHex("FRIENDS", showFriendList, "button_medium_gold", 16, -1, 170);
			buttonFriends.x = tabbar.width / 2 - buttonFriends.width / 2;
			buttonFriends.y = 10;
			tabbar.addChild(buttonFriends);
			
			/*buttonClan = new ButtonHex("CLAN", showClanPage, "button_medium_gray", 16, -1, 170);
			buttonClan.x = tabbar.width / 2 - buttonClan.width / 2;
			buttonClan.y = 70;
			tabbar.addChild(buttonClan);*/
			
			buttonBlacklist = new ButtonHex("BAN LIST", showBlacklist, "button_medium_gray", 16, -1, 170);
			buttonBlacklist.x = tabbar.width / 2 - buttonBlacklist.width / 2;
			buttonBlacklist.y = 70;
			tabbar.addChild(buttonBlacklist);
			
			buttonUsers = new ButtonHex("USERS", showUsers, "button_medium_gray", 16, -1, 170);
			buttonUsers.x = tabbar.width / 2 - buttonBlacklist.width / 2;
			buttonUsers.y = 130;
			tabbar.addChild(buttonUsers);
			
			var contentWrap:Sprite = new NinePatchSprite("9patch_transparent_panel", 430, 474);
			contentWrap.x = 206;
			contentWrap.y = 50;
			bg.addChild(contentWrap);
			
			contentSprite = new Sprite();
			contentSprite.x = 5;
			contentSprite.y = 5;
			contentWrap.addChild(contentSprite);
			
			var closeButton:ButtonHex = new ButtonHex("CLOSE", onClose, "button_medium_gray", 16, -1, 170);
			closeButton.x = tabbar.width / 2 - closeButton.width / 2;
			closeButton.y = tabbar.height - 64;
			tabbar.addChild(closeButton);
			
			showFriendList();
			
			G.gatracker.trackPageview("/social");
		}
		
		private function onClose():void {
			parent.removeChild(this);
		}
		
		public function showUserDetails(userKey:String, username:String):void {
			showUsers(userKey, username);
		}
		
		private function showFriendList():void {
			buttonFriends.setImage("button_medium_gold");
			//buttonClan.setImage("button_medium_gray");
			buttonBlacklist.setImage("button_medium_gray");
			buttonUsers.setImage("button_medium_gray");
			
			while(contentSprite.numChildren > 0) contentSprite.removeChildAt(contentSprite.numChildren - 1);
			
			contentSprite.addChild(new SocialFriendList(this));
		}
		
		private function showClanPage():void {
			buttonFriends.setImage("button_medium_gray");
			//buttonClan.setImage("button_medium_gold");
			buttonBlacklist.setImage("button_medium_gray");
			buttonUsers.setImage("button_medium_gray");

			while(contentSprite.numChildren > 0) contentSprite.removeChildAt(contentSprite.numChildren - 1);
		}
		
		private function showBlacklist():void {
			buttonFriends.setImage("button_medium_gray");
			//buttonClan.setImage("button_medium_gray");
			buttonBlacklist.setImage("button_medium_gold");
			buttonUsers.setImage("button_medium_gray");

			while(contentSprite.numChildren > 0) contentSprite.removeChildAt(contentSprite.numChildren - 1);
			
			contentSprite.addChild(new SocialBlacklist());
		}
		
		private function showUsers(userKey:String = null, username:String = null):void {
			buttonFriends.setImage("button_medium_gray");
			//buttonClan.setImage("button_medium_gray");
			buttonBlacklist.setImage("button_medium_gray");
			buttonUsers.setImage("button_medium_gold");
			
			while(contentSprite.numChildren > 0) contentSprite.removeChildAt(contentSprite.numChildren - 1);
			
			contentSprite.addChild(new SocialUserProfile(username, userKey));
		}
	}
}
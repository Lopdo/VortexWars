package Menu.Social
{
	import Menu.ButtonContextMenu;
	import Menu.ButtonHex;
	import Menu.LevelIcon;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class FriendlistPlayerCell extends Sprite
	{
		public var playerKey:String;
		private var playerName:String;
		private var friendList:SocialFriendList;
		private var roomId:String;
		public var onlineStatus:int;
		public var lastOnline:int;
		
		public function FriendlistPlayerCell(playerKey:String, name:String, level:int, rank:Number, onlineStatus:int, lastOnline:int, roomName:String, roomId:String, friendlist:SocialFriendList)
		{
			super();
			
			this.playerKey = playerKey;
			this.friendList = friendlist;
			this.roomId = roomId;
			this.onlineStatus = onlineStatus
			this.playerName = name;
			this.lastOnline = lastOnline;
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_context", 400, 90);
			addChild(bg);
			
			var labelName:TextField = new TextField();
			labelName.text = name;
			labelName.setTextFormat(new TextFormat("Arial", 18, -1, true));
			labelName.autoSize = TextFieldAutoSize.LEFT;
			labelName.x = 32;
			labelName.y = 10;
			labelName.mouseEnabled = false;
			bg.addChild(labelName);
			
			var levelIcon:LevelIcon = new LevelIcon(level);
			levelIcon.x = 8;
			levelIcon.y = labelName.y + labelName.height / 2 - levelIcon.height / 2;
			bg.addChild(levelIcon);
			
			/*var labelClan:TextField = new TextField();
			labelClan.text = "Clan: none";
			labelClan.setTextFormat(new TextFormat("Arial", 14, -1, true));
			labelClan.autoSize = TextFieldAutoSize.LEFT;
			labelClan.x = 10;
			labelClan.y = 42;
			labelClan.mouseEnabled = false;
			bg.addChild(labelClan);*/
			
			var labelRank:TextField = new TextField();
			labelRank.text = "Rating: " + rank;
			labelRank.setTextFormat(new TextFormat("Arial", 14, -1, true));
			labelRank.autoSize = TextFieldAutoSize.LEFT;
			labelRank.x = 10;
			labelRank.y = 42;
			labelRank.mouseEnabled = false;
			bg.addChild(labelRank);
			
			var labelStatus:TextField = new TextField();
			//labelStatus.text = "Rating: " + rank;
			if(onlineStatus == 0) {
				var d:Date = new Date(lastOnline * 1000);
				var today:Date = new Date();
				var milliseconds:Number = today.getTime() - d.getTime();
				var seconds:Number = milliseconds / 1000;
				var minutes:Number = seconds / 60;
				var hours:Number = minutes / 60;
				var days:Number = Math.floor(hours / 24);
					
				if(days > 1)
					labelStatus.text = "Status: OFFLINE (last seen " + int(days) + " days ago)";
				else if(days > 0)
					labelStatus.text = "Status: OFFLINE (last seen yesterday)";
				else if(hours > 0)
					labelStatus.text = "Status: OFFLINE (last seen " + int(hours) + " hours ago)";
				else if(minutes > 0)
					labelStatus.text = "Status: OFFLINE (last seen " + int(minutes) + " minutes ago)";
				else 
					labelStatus.text = "Status: OFFLINE (last seen less than a minute ago)";
			}
			else if(onlineStatus == 1) {
				labelStatus.text = "Status: ONLINE";
			}
			else if(onlineStatus == 2) {
				labelStatus.text = "Status: ONLINE (in lobby)";
			}
			else {
				labelStatus.text = "Status: ONLINE (" + roomName + ")";
			}
			labelStatus.setTextFormat(new TextFormat("Arial", 14, -1, true));
			labelStatus.autoSize = TextFieldAutoSize.LEFT;
			labelStatus.x = 10;
			labelStatus.y = 62;
			labelStatus.width = 380;
			labelStatus.mouseEnabled = false;
			bg.addChild(labelStatus);
			
			var button:ButtonHex = new ButtonHex("OPTIONS", onOptionsPressed, "button_small_gray");
			button.x = bg.width - button.width - 8;
			button.y = 6;
			bg.addChild(button);
			
			if(onlineStatus > 1) {
				button = new ButtonHex("JOIN", onJoinPressed, "button_small_gold");
				button.x = bg.width - button.width - 8;
				button.y = bg.height - button.height - 6;
				bg.addChild(button);
			}
		}
		
		private function onOptionsPressed():void {
			G.errorSprite.addChild(new ButtonContextMenu(new Array("DETAIL", "REMOVE"), new Array(onDetailPressed, onRemovePressed), localToGlobal(new Point(278, 0)).x, localToGlobal(new Point(0, 48)).y, 40));
		}
		
		private function onDetailPressed():void {
			friendList.showDetails(playerKey, playerName);
		}
		
		private function onRemovePressed():void {
			friendList.removeFriend(playerKey);
		}
		
		private function onJoinPressed():void {
			friendList.joinRoom(onlineStatus, roomId);
		}
	}
}
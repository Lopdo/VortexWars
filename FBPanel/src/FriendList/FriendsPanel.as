package FriendList
{
	import Facebook.FB;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import playerio.DatabaseObject;
	import playerio.Message;
	
	public class FriendsPanel extends Sprite
	{
		[Embed(source="../../res/arrow.png")] 		private var arrow:Class;
		
		private var friends:Array = [];
		
		private var friendItems:Array = new Array();
		
		private var currentIndex:int = 0;
		
		public function FriendsPanel(frnds:Array, facebookdata:Object)
		{
			super();
			
			y = 36;
			
			for(var i:int = 0; i < 4; ++i) {
				var friendItem:FriendItem = new FriendItem();
				friendItem.initWithInvite();
				friendItem.x = 40 + 144 * i;
				addChild(friendItem);
				friendItems[i] = friendItem;
			}
			
			friendItem = new FriendItem();
			friendItem.initWithInvite();
			friendItem.x = 40 + 144 * 4 + 30;
			addChild(friendItem);
			friendItems[i] = friendItem;
			friendItem.addEventListener(MouseEvent.CLICK, onInviteClick, false, 0, true);

			var buttonLeft:Sprite = new Sprite();
			buttonLeft.addChild(new arrow());
			buttonLeft.x = 10;
			buttonLeft.y = friendItem.y + friendItem.height / 2 - buttonLeft.height / 2;
			buttonLeft.addEventListener(MouseEvent.CLICK, moveLeft);
			addChild(buttonLeft);
			
			var buttonRight:Sprite = new Sprite();
			buttonRight.addChild(new arrow());
			buttonRight.x = 40 + 144 * 4 + buttonRight.width;
			buttonRight.scaleX = -1;
			buttonRight.y = friendItem.y + friendItem.height / 2 - buttonRight.height / 2;
			buttonRight.addEventListener(MouseEvent.CLICK, moveRight);
			addChild(buttonRight);

			for each(var o:DatabaseObject in frnds){
				var friend:DatabaseObject = o;
				//Add facebook data to object;
				friend.fbdata = facebookdata[o.key]
				//Add to friends collection
				friends.push(friend);
			}
			fillFriends();
		}
		
		/*public function loadFriends(client:Client):void {
			FB.Data.query('SELECT uid, first_name,last_name, pic_small FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1=me()) AND is_app_user = 1' ).wait(function(rows:*):void {
			
				//Create list for ids to load from BigDB
				var friendsToLoad:Array = [];
				//Create facebook data cache object
				var facebookdata:Object = {};
			
				//For each entry in FQL query
				for( var x:String in rows){
					//Store facebook data
					facebookdata["fb" + rows[x].uid] = rows[x];
					//Insert id to lookup from BigDB
					friendsToLoad.push("fb" + rows[x].uid);
				}
			
				if(friendsToLoad.length != 0){
					//If there are friends to load from BigDB, load them
					client.bigDB.loadKeys("PlayerObjects", friendsToLoad, function(frnd:Array):void{
						//For each friend
						for each(var o:DatabaseObject in frnd){
							var friend:DatabaseObject = o;
							//Add facebook data to object;
							friend.fbdata = facebookdata[o.key]
							//Add to friends collection
							friends.push(friend);
						}
						fillFriends();
						
					}, handleError)
				}
				
			}, function(e:*):void {
				handleError(new Error("From Facebook: " + e))
			});
		}*/
		
		private function fillFriends():void {
			for(var i:int = 0; i < 4; ++i) {
				var friendItem:FriendItem = friendItems[i];
				friendItem.removeEventListener(MouseEvent.CLICK, onInviteClick);
				friendItem.clear();
				if(i + currentIndex < friends.length) {
					var friend:DatabaseObject = friends[i + currentIndex];
					friendItem.initWithFriend(friend.fbdata.first_name + " " + friend.fbdata.last_name, friend.Race, friend.Level, friend.fbdata.pic_small);
				}
				else {
					friendItem.initWithInvite();
					friendItem.addEventListener(MouseEvent.CLICK, onInviteClick, false, 0, true);
				}
			}
		}
		
		private function moveLeft(event:MouseEvent):void {
			if(currentIndex > 0) {
				currentIndex--;
			
				fillFriends();
			}
		}
		
		private function moveRight(event:MouseEvent):void {
			if(currentIndex + 4 < friends.length + 1) {
				currentIndex++;
				
				fillFriends();
			}
		}
		
		private function onInviteClick(event:MouseEvent):void {
			//navigateToURL(new URLRequest("http://apps.facebook.com/vortexwars/invite"), "_top");
			FB.ui({
				method: "apprequests",
				message: "Come join me in Vortex Wars!"
			}, function(response:Object):void {
				if(response) {
					var invites:Array = response.to;
					var message:Message = FBPanel.connection.createMessage("as");
					message.add(invites.length);
					for each(var id:int in invites) {
						trace(id);
						message.add(id.toString());
					}
					FBPanel.connection.sendMessage(message);
				}
				trace(FB.toString(response)); // FB.toString() simply prettyprints the object
			});
		}
	}
}
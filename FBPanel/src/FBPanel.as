package
{
	import Facebook.FB;
	
	import FriendList.FriendsPanel;
	
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import playerio.Client;
	import playerio.Connection;
	import playerio.PlayerIO;

	[SWF(width='800', height='120', backgroundColor='#222222')]
	
	public class FBPanel extends Sprite
	{
		[Embed(source="../res/bg.png")]		private var bgBitmap:Class;
		
		public static var client:Client;
		public static var connection:Connection;
		public static var tooltipSprite:Sprite;
		
		public function FBPanel()
		{
			tooltipSprite = new Sprite();
			addChild(tooltipSprite);
			
			graphics.beginBitmapFill((new bgBitmap()).bitmapData);
			graphics.drawRect(0, 0, 800, 200);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			var accessToken:String = LoaderInfo(this.root.loaderInfo).parameters.fb_access_token || "AAAEUjE6S760BACd3Kri8XioeSbKQmlnI7XLPKKuW7XhwSzLHekbomnCrq2bZBVmT667WW2UlT8umg48HtWCMFo9CREsPOp1s163KCYfIPQlmlcjpE"
			trace("at: " + accessToken);
			trace("params: " + LoaderInfo(this.root.loaderInfo).parameters);
			FB.init({access_token:accessToken, app_id:"304067822940077", debug:true});
		}
		
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			var aff:String = (LoaderInfo(this.root.loaderInfo).parameters != null ? (LoaderInfo(this.root.loaderInfo).parameters.pio$affiliate || null) : null);
			var accessToken:String = LoaderInfo(this.root.loaderInfo).parameters.fb_access_token || "AAAEUjE6S760BACd3Kri8XioeSbKQmlnI7XLPKKuW7XhwSzLHekbomnCrq2bZBVmT667WW2UlT8umg48HtWCMFo9CREsPOp1s163KCYfIPQlmlcjpE"
			PlayerIO.quickConnect.facebookOAuthConnect(stage, "wargrounds-pvrpqmt1ee2jwqueof8ig", accessToken, aff, handleConnect, handleError);
		}
		
		private function handleConnect(client:Client, id:String=""):void {
			FBPanel.client = client;
			
			//client.multiplayer.developmentServer = "localhost:8184";
			
			client.multiplayer.createJoinRoom(
				"$service-room$",						//Room id. If set to null a random roomid is used
				"FBRoom",			//The game type started on the server
				false,								//Should the room be visible in the lobby?
				null,					//Room data. This data is returned to lobby list. Variabels can be modifed on the server
				null,									//User join data
				handleFBRoomJoin,					//Function executed on successful joining of the room
				handleError							//Function executed if we got a join error
			);
		}
		
		private function handleFBRoomJoin(con:Connection):void {
			FBPanel.connection = con;
			
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
						addChild(new FriendsPanel(frnd, facebookdata));
						setChildIndex(tooltipSprite, numChildren - 1); 
					}, handleError)
				}
				
			}, function(e:*):void {
				handleError(new Error("From Facebook: " + e))
			});
		}
		
		private function handleError(error:Error):void {
			trace("conenction error: " + error);
		}
	}
}
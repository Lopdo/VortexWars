package Menu.Lobby
{
	import IreUtils.ResList;
	
	import Menu.Tooltips.TextTooltip;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import playerio.DatabaseObject;
	
	public class UserMapRating extends Sprite
	{
		protected var plusSprite:Sprite, minusSprite:Sprite;
		//protected var mapKey:String;
		protected var mapObject:DatabaseObject;
		protected var tooltip:TextTooltip = null;
		
		public function UserMapRating(mapObject:DatabaseObject)
		{
			super();
		
			this.mapObject = mapObject;
			
			plusSprite = new Sprite();
			plusSprite.x = 113;
			plusSprite.y = 0;
			addChild(plusSprite);
			plusSprite.addEventListener(MouseEvent.CLICK, onPlusClicked, false, 0, true);
			plusSprite.useHandCursor = true;
			plusSprite.buttonMode = true;
			
			minusSprite = new Sprite();
			minusSprite.x = 0;
			minusSprite.y = 0;
			addChild(minusSprite);
			minusSprite.addEventListener(MouseEvent.CLICK, onMinusClicked, false, 0, true);
			minusSprite.useHandCursor = true;
			minusSprite.buttonMode = true;
			
			drawRating();
		}
		
		private function drawRating():void {
			if(G.user.isGuest) {
				plusSprite.visible = false;
				minusSprite.visible = false;
			}
			else {
				var likedMaps:Array = G.user.playerObject.LikedMaps;
				var liked:Boolean = likedMaps.indexOf(mapObject.key) != -1;
				var dislikedMaps:Array = G.user.playerObject.DislikedMaps;
				var disliked:Boolean = dislikedMaps.indexOf(mapObject.key) != -1;
				
				while(plusSprite.numChildren > 0) plusSprite.removeChildAt(0);
				while(minusSprite.numChildren > 0) minusSprite.removeChildAt(0);
				
				plusSprite.addChild(ResList.GetArtResource("lobby_map_rating_plus" + (liked ? "" : "_empty")));
				minusSprite.addChild(ResList.GetArtResource("lobby_map_rating_minus" + (disliked ? "" : "_empty")));
			}
			var likeCount:int = mapObject.LikeCount;
			var dislikeCount:int = mapObject.DislikeCount;
			var likeWidth:int = 41;
			if(likeCount + dislikeCount > 0)
				likeWidth = likeCount / (likeCount + dislikeCount) * 82;
			
			graphics.lineStyle(1, 0xAAAAAA);
			graphics.drawRect(27, 9, 83, 4);
			graphics.lineStyle();
			graphics.beginFill(0x00FF00);
			graphics.drawRect(28, 10, likeWidth, 3);
			graphics.beginFill(0xFF0000);
			graphics.drawRect(28 + likeWidth, 10, 82 - likeWidth, 3);
			
			if(tooltip) {
				tooltip.remove();
			}
			tooltip = new TextTooltip(likeCount + " likes / " + dislikeCount + " dislikes", this);
		}
		
		private function onPlusClicked(event:MouseEvent):void {
			G.userConnection.send(MessageID.LOBBY_MAP_RATED, mapObject.key, true);
			
			var likedMaps:Array = G.user.playerObject.LikedMaps;
			var liked:Boolean = likedMaps.indexOf(mapObject.key) != -1;
			var dislikedMaps:Array = G.user.playerObject.DislikedMaps;
			var disliked:Boolean = dislikedMaps.indexOf(mapObject.key) != -1;
			
			if(liked) {
				likedMaps.splice(likedMaps.indexOf(mapObject.key), 1);
				mapObject.LikeCount--;
			}
			else {
				likedMaps.push(mapObject.key);
				mapObject.LikeCount++;
				
				if(disliked) {
					dislikedMaps.splice(dislikedMaps.indexOf(mapObject.key), 1);
					mapObject.DislikeCount--;
				}
			}
			
			drawRating();
			
			G.gatracker.trackPageview("/mapRated/plus");
		}
		
		private function onMinusClicked(event:MouseEvent):void {
			G.userConnection.send(MessageID.LOBBY_MAP_RATED, mapObject.key, false);
			
			var likedMaps:Array = G.user.playerObject.LikedMaps;
			var liked:Boolean = likedMaps.indexOf(mapObject.key) != -1;
			var dislikedMaps:Array = G.user.playerObject.DislikedMaps;
			var disliked:Boolean = dislikedMaps.indexOf(mapObject.key) != -1;
			
			if(disliked) {
				dislikedMaps.splice(dislikedMaps.indexOf(mapObject.key), 1);
				mapObject.DislikeCount--;
			}
			else {
				dislikedMaps.push(mapObject.key);
				mapObject.DislikeCount++;
				
				if(liked) {
					likedMaps.splice(likedMaps.indexOf(mapObject.key), 1);
					mapObject.LikeCount--;
				}
			}
			
			drawRating();
			
			G.gatracker.trackPageview("/mapRated/minus");
		}
	}
}
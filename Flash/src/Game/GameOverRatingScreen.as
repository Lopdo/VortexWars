package Game
{
	import Menu.Lobby.UserMapRating;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.DatabaseObject;
	
	public class GameOverRatingScreen extends Sprite
	{
		public function GameOverRatingScreen(mapObject:DatabaseObject)
		{
			super();
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_popup", 368, 100);
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = "MAP RATING";
			label.width = bg.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			addChild(label);
			
			tf.size = 14;

			label = new TextField();
			label.defaultTextFormat = tf;
			label.text = "Did you like the map?";
			label.width = bg.width - 40;
			label.x = 20;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 45;
			label.mouseEnabled = false;
			addChild(label);
			
			var rating:UserMapRating = new UserMapRating(mapObject);
			rating.x = bg.width / 2 - rating.width / 2;
			rating.y = 70;
			addChild(rating);
		}
	}
}
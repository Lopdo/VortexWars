package Game.Backgrounds
{
	import Game.Map;
	import Game.Player;
	
	import Menu.ButtonHex;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	
	public class BackgoundPreview extends Sprite
	{
		public function BackgoundPreview(bgIndex:int)
		{
			super();
			
			graphics.beginFill(0, 0.6);
			graphics.drawRect(0, 0, 800, 600);
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_popup", 506, 486);
			bg.x = width / 2 - bg.width / 2;
			bg.y = height / 2 - bg.height / 2;
			addChild(bg);
			
			/*var background:Background = new Background(bgIndex, 600, 400);
			background.x = 3;
			background.y = 40;
			bg.addChild(background);*/
			
			var button:ButtonHex = new ButtonHex("CLOSE", onClose, "button_small_gray");
			button.x = bg.width / 2 - button.width / 2;
			button.y = 442;
			bg.addChild(button);
			
			var tiles:Array = new Array(
				0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 0,
				0, 1, 1, 1, 2, 2, 2, 0, 0, 7, 7, 7, 7, 7, 0,
				0, 1, 1, 1, 2, 2, 2, 2, 7, 7, 7, 7, 7, 7, 0,
				1, 1, 1, 2, 2, 2, 2, 2, 7, 7, 7, 7, 7, 0, 0,
				1, 1, 1, 1, 2, 2, 2, 2, 2, 5, 5, 7, 7, 0, 0,
				1, 1, 1, 3, 2, 2, 5, 5, 5, 5, 5, 7, 0, 0, 0,
				1, 1, 3, 3, 3, 3, 5, 5, 5, 5, 5, 0, 0, 0, 0,
				0, 3, 3, 3, 3, 3, 4, 5, 5, 5, 5, 5, 0, 0, 0,
				0, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 6, 6, 0, 0,
				0, 0, 3, 3, 3, 4, 4, 4, 5, 5, 6, 6, 6, 0, 0,
				0, 0, 3, 3, 3, 4, 4, 4, 4, 6, 6, 6, 6, 0, 0,
				0, 3, 3, 3, 0, 0, 4, 4, 4, 6, 6, 6, 6, 0, 0,
				0, 0, 3, 3, 0, 0, 0, 0, 6, 6, 6, 6, 6, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
			
			var map:Map = new Map(15, 15, tiles);
			bg.addChild(map);
			
			var mapMask:Sprite = new Sprite();
			mapMask.graphics.beginFill(0);
			mapMask.graphics.drawRect(3, 40, 500, 400);
			map.mask = mapMask;
			addChild(mapMask);
			bg.addChild(mapMask);
			
			var players:Array = new Array(	new Player(2, "", 0, 1, 0, 0, 0, 0, 0, 0), 
											new Player(3, "", 1, 1, 1, 0, 0, 0, 0, 0),
											new Player(4, "", 2, 1, 2, 0, 0, 0, 0, 0),
											new Player(5, "", 3, 1, 3, 0, 0, 0, 0, 0),
											new Player(6, "", 4, 1, 4, 0, 0, 0, 0, 0),
											new Player(7, "", 5, 1, 5, 0, 0, 0, 0, 0),
											new Player(8, "", 6, 1, 6, 0, 0, 0, 0, 0));
			
			var regionCount:int = 7;
			for(var i:int = 0; i < regionCount; ++i) {
				map.AddRegion(players[i], 1);
			}
			map.Finalize(bgIndex);
		}
		
		private function onClose():void {
			parent.removeChild(this);
		}
	}
}
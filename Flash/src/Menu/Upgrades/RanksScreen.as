package Menu.Upgrades
{
	import IreUtils.ResList;
	
	import Menu.MainMenu.MainMenu;
	import Menu.MainMenu.MenuShortcutsPanel;
	import Menu.NinePatchSprite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class RanksScreen extends Sprite
	{
		public function RanksScreen()
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 740, 380);
			bg.x = 400 - bg.width / 2;
			bg.y = 300 - bg.height / 2;
			addChild(bg);
			
			var b:Bitmap = ResList.GetArtResource("ranks");

			var tf:TextFormat = new TextFormat("Arial", 14, -1, true);
			var label:TextField;
			var bd:BitmapData;
		
			for(var i:int = 0; i < 54; ++i) {
				label = new TextField();
				label.text = "Level " + (i + 1);
				label.setTextFormat(tf);
				label.x = 20 + (int)(i / 9) * 120;
				label.y = 20 + (i % 9) * 38;
				label.autoSize = TextFieldAutoSize.LEFT;
				bg.addChild(label);
				
				bd = new BitmapData(22, 28, true);
				bd.copyPixels(b.bitmapData, new Rectangle(22*(i % 9), 28*(int)(i / 9), 22, 28), new Point(0, 0));
				var rankBitmap:Bitmap = new Bitmap(bd);
				var rankSprite:Sprite = new Sprite();
				rankSprite.addChild(rankBitmap);
				rankSprite.x = label.x + 70;
				rankSprite.y = label.y + label.height / 2 - rankSprite.height / 2;
				bg.addChild(rankSprite);
			}
			
			addChild(new MenuShortcutsPanel(onBack));
			
			G.gatracker.trackPageview("/ranks");
		}
		
		private function onBack():void {
			parent.addChild(new MainMenu());
			parent.removeChild(this);
		}
	}
}
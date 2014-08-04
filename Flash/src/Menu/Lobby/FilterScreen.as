package Menu.Lobby
{
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.MenuSelector;
	import Menu.NinePatchSprite;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.net.FileFilter;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class FilterScreen extends Sprite
	{
		private var gameName:TextField;
		private var gameType:MenuSelector, mapType:MenuSelector, startType:MenuSelector, distType:MenuSelector, upgradesEnabled:MenuSelector, boostsEnabled:MenuSelector;

		private var filter:Filter;
		
		public function FilterScreen(filter:Filter)
		{
			super();
			
			this.filter = filter;
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var bgSprite:NinePatchSprite = new NinePatchSprite("9patch_popup", 430, 350);
			bgSprite.x = width / 2 - bgSprite.width / 2;
			bgSprite.y = height / 2 - bgSprite.height / 2;
			addChild(bgSprite);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			
			var label:TextField = new TextField();
			label.text = "FILTER";
			label.setTextFormat(tf);
			label.width = bgSprite.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			bgSprite.addChild(label);

			tf.size = 14;
			
			var line:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 344, 35);
			line.x = bgSprite.width / 2 - line.width / 2;
			line.y = 50;
			bgSprite.addChild(line);
			
			label = new TextField();
			label.text = "GAME TYPE:";
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);
			
			gameType = new MenuSelector(200, line.height);
			gameType.x = 140;
			gameType.AddItem("Any", -1);
			gameType.AddItem("Hardcore", 0);
			gameType.AddItem("Attrition", 1);
			gameType.AddItem("1v1 quick", 3);
			line.addChild(gameType);
			gameType.SetActiveItemByData(filter.gameType);
			
			line = new NinePatchSprite("9patch_transparent_panel", 344, 35);
			line.x = bgSprite.width / 2 - line.width / 2;
			line.y = 91;
			bgSprite.addChild(line);
			
			label = new TextField();
			label.text = "MAP TYPE:";
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);
			
			mapType = new MenuSelector(200, line.height);
			mapType.x = 140;
			mapType.AddItem("Any", -1);
			mapType.AddItem("Random", 100);
			mapType.AddItem("Premade", 1);
			mapType.AddItem("User made", 101);
			//mapSize.AddItem("Large", 2);
			//mapSize.AddItem("Huge", 3);
			line.addChild(mapType);
			switch(filter.mapSize) {
				case -1: mapType.SetActiveItem(0); break;
				case 1: mapType.SetActiveItem(2); break;
				case 100: mapType.SetActiveItem(1); break;
				case 101: mapType.SetActiveItem(3); break;
			}
			//mapType.SetActiveItem(filter.mapSize + 1);
			
			line = new NinePatchSprite("9patch_transparent_panel", 344, 35);
			line.x = bgSprite.width / 2 - line.width / 2;
			line.y = 132;
			bgSprite.addChild(line);
			
			label = new TextField();
			label.text = "START TYPE:";
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);
			
			startType = new MenuSelector(200, line.height);
			startType.x = 140;
			startType.AddItem("Any", -1);
			startType.AddItem("Full map", 0);
			startType.AddItem("Conquer", 1);
			line.addChild(startType);
			startType.SetActiveItem(filter.startType + 1);
			
			line = new NinePatchSprite("9patch_transparent_panel", 344, 35);
			line.x = bgSprite.width / 2 - line.width / 2;
			line.y = 173;
			bgSprite.addChild(line);
			
			label = new TextField();
			label.text = "NEW TROOPS:";
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);
			
			distType = new MenuSelector(200, line.height);
			distType.x = 140;
			distType.AddItem("Any", -1);
			distType.AddItem("Random", 0);
			distType.AddItem("Manual", 1);
			distType.AddItem("Border", 2);
			line.addChild(distType);
			distType.SetActiveItem(filter.distType + 1);
			
			/*line = new NinePatchSprite("9patch_transparent_panel", 344, 35);
			line.x = bgSprite.width / 2 - line.width / 2;
			line.y = 214;
			bgSprite.addChild(line);
			
			label = new TextField();
			label.text = "VISIBLE GAMES:";
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);
			
			showStarted = new MenuSelector(200, line.height);
			showStarted.x = 140;
			showStarted.AddItem("All", -1);
			showStarted.AddItem("Available Only", 0);
			line.addChild(showStarted);
			showStarted.SetActiveItem(filter.showStarted + 1);*/
			
			line = new NinePatchSprite("9patch_transparent_panel", 344, 35);
			line.x = bgSprite.width / 2 - line.width / 2;
			line.y = 214;
			bgSprite.addChild(line);
			
			label = new TextField();
			label.text = "UPGRADES:";
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);
			
			upgradesEnabled = new MenuSelector(200, line.height);
			upgradesEnabled.x = 140;
			upgradesEnabled.AddItem("Any", -1);
			upgradesEnabled.AddItem("Disabled", 0);
			upgradesEnabled.AddItem("Enabled", 1);
			line.addChild(upgradesEnabled);
			upgradesEnabled.SetActiveItemByData(filter.upgradesEnabled);
			
			line = new NinePatchSprite("9patch_transparent_panel", 344, 35);
			line.x = bgSprite.width / 2 - line.width / 2;
			line.y = 255;
			bgSprite.addChild(line);
			
			label = new TextField();
			label.text = "BOOSTS:";
			label.setTextFormat(tf);
			label.x = 10;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);
			
			boostsEnabled = new MenuSelector(200, line.height);
			boostsEnabled.x = 140;
			boostsEnabled.AddItem("Any", -1);
			boostsEnabled.AddItem("Disabled", 0);
			boostsEnabled.AddItem("Enabled", 1);
			line.addChild(boostsEnabled);
			boostsEnabled.SetActiveItemByData(filter.boostsEnabled);
			
			var button:ButtonHex = new ButtonHex("OK", onOk, "button_small_gold");
			button.x = 327;
			button.y = bgSprite.height - 44;
			bgSprite.addChild(button);
			
			button = new ButtonHex("CANCEL", onCancel, "button_small_gray");
			button.x = 216;
			button.y = bgSprite.height - 44;
			bgSprite.addChild(button);
			
			button = new ButtonHex("RESET", onReset, "button_small_gray");
			button.x = 37;
			button.y = bgSprite.height - 44;
			bgSprite.addChild(button);
			
			G.gatracker.trackPageview("/filterScreen");
		}
		
		private function onOk():void {
			filter.set(gameType.GetCurrentItemData(), mapType.GetCurrentItemData(), startType.GetCurrentItemData(), distType.GetCurrentItemData(), upgradesEnabled.GetCurrentItemData(), boostsEnabled.GetCurrentItemData());
			Lobby(this.parent).applyFilter();
			this.parent.removeChild(this);
		}
		
		private function onCancel():void {
			this.parent.removeChild(this);
		}
		
		private function onReset():void {
			filter.reset();
			
			gameType.SetActiveItem(0);
			mapType.SetActiveItem(0);
			startType.SetActiveItem(0);
			distType.SetActiveItem(0);
			//showStarted.SetActiveItem(0);
			upgradesEnabled.SetActiveItem(0);
			boostsEnabled.SetActiveItem(0);
		}
	}
}
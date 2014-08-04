package Game
{
	import IreUtils.ResList;
	
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class Army extends Sprite
	{
		public var center:Point = new Point();
		
		private var logoSprite:Sprite = new Sprite();
		private var text:TextField = new TextField();
		//private var tf:TextFormat = new TextFormat();
		private var light:Sprite;
		private var regionActive:Boolean;
		
		private var defenseSprite:Sprite;
		private var pulseTimer:Number = 0;
		private var defenseIconPulsing:Boolean = false;
		
		public function Army(owner:Player, dice:int)
		{
			super();
			
			logoSprite = new Sprite();
			light = new Sprite();
			if(owner) {
				logoSprite.addChild(new Bitmap(owner.race.symbolSmall.bitmapData.clone()));
				light.addChild(ResList.GetArtResource("army_light" + owner.colorID));
			}
			else {
				if(dice == 0) {
					logoSprite.addChild(ResList.GetArtResource("army_logoEmpty"));
					light.addChild(ResList.GetArtResource("army_logoEmpty"));
				}
				else {
					logoSprite.addChild(ResList.GetArtResource("army_logoElves"));
					light.addChild(ResList.GetArtResource("army_logoEmpty"));
				}
			}
			addChild(logoSprite);
			addChild(light);

			light.x = (logoSprite.width - light.width) / 2; 
			light.y = (logoSprite.height - light.height) / 2;
			light.alpha = 0;
			
			var tf:TextFormat = new TextFormat();
			tf.bold = true;
			tf.size = 12;
			tf.align = TextFormatAlign.CENTER;
			tf.color = 0xFFFFFFFF;
			tf.font = "Arial";
			
			text.defaultTextFormat = tf;
			text.width = light.width;
			text.height = 20;
			text.x = light.x + 1;
			text.y = light.y + light.height / 2 - text.height / 2 - 2;
			
			addChild(text);

			defenseSprite = new Sprite();
			defenseSprite.addChild(ResList.GetArtResource("boost_defense_icon"));
			defenseSprite.x = width / 2 - defenseSprite.width / 2;
			defenseSprite.y = height / 2 - defenseSprite.height / 2 - 2;
			defenseSprite.alpha = 0;
			addChild(defenseSprite);

			this.mouseEnabled = false;
			text.mouseEnabled = false;
			
		}
		
		public function setDefenseBoost(active:Boolean):void {
			defenseSprite.alpha = 0;
			pulseTimer = 0;
			defenseIconPulsing = active;
		}
		
		public function update(timeDelta:Number):void {
			if(!regionActive && light.alpha > 0) {
				light.alpha -= timeDelta * 2;
				if(light.alpha < 0) {
					light.alpha = 0;
				}
			}
			if(defenseIconPulsing) {
				pulseTimer += 5*timeDelta;
				defenseSprite.alpha = 0.8 * (1 - Math.cos(pulseTimer)) / 2;
			}
		}
		
		public function setActive(active:Boolean):void {
			//regionActive = active;
			//light.alpha = active ? 1 : 0;
		}
		
		public function setArmyStrength(str:int):void {
			if(str == 0) text.text = "";
			else text.text = str.toString();
		}
		
		public function increasePower(str:int):void {
			text.text = str.toString();
			
			light.alpha = 1.0;
		}
		
		public function setOwner(owner:Player):void {
			if(owner) {
				logoSprite.removeChildAt(0);
				logoSprite.addChild(new Bitmap(owner.race.symbolSmall.bitmapData.clone()));
				light.removeChildAt(0);
				light.addChild(ResList.GetArtResource("army_light" + owner.colorID));
			}
		}
	}
}
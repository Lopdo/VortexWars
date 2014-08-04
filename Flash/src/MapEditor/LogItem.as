package MapEditor
{
	import IreUtils.ResList;
	
	import Menu.Button;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldType;
	
	public class LogItem extends TextField{
		
		// the less the higher severity - 0=highest severity
		public var severity:int;
		
		public function LogItem(severity:int, msg:String) {
			super();				
			this.severity = severity;
			this.text = msg;
			
			this.autoSize = TextFieldAutoSize.LEFT;
			this.type = TextFieldType.DYNAMIC;
			this.selectable = false;
			this.multiline = this.wordWrap = true;
			
			var tf:TextFormat = new TextFormat();
			tf.font = "Arial";
			tf.size = 12;
			tf.bold = false;
			tf.color = -1;
			tf.align = TextFormatAlign.LEFT;
			
			this.defaultTextFormat = tf;
		}
	}
	
}
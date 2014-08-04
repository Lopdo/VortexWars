package Errors
{
	public class ErrorObject
	{
		public var text:String, title:String;
		public var ID:int;
		public var callback:Function;
		
		public function ErrorObject(text:String, title:String, ID:int, callback:Function)
		{
			this.text = text;
			this.ID = ID;
			this.title = title;
			this.callback = callback;
		}
	}
}
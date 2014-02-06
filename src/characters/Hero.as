package characters
{
	
	
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.textures.TextureSmoothing;
	
	import utils.Vector2D;
	
	public class Hero extends Sprite
	{
		private var view:Image;
		private var view_dead:Image;
		private var gravity:Number = .8;
		private var speed:Vector2D = new Vector2D(-30,10);
		private var maxspeedy:Number = 15;
		public var isDead:Boolean;
		public function Hero()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		private function initialize():void
		{
			this.view = new Image( Game.instance.assets.getFirstTexture('astronauta_uno'));
			this.view_dead = new Image(Game.instance.assets.getTexture('astronauta_dos'));
			
			this.view.smoothing = TextureSmoothing.NONE;
			this.view_dead.smoothing = TextureSmoothing.NONE;
			this.addChild( this.view );
			this.view.pivotX = this.view.width>>1;
			this.view.pivotY = this.view.height>>1;
			this.view_dead.pivotX = this.view_dead.width>>1;
			this.view_dead.pivotY = this.view_dead.height>>1;
			this.x = 100;
			this.y = 400;
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, remove);
			this.removeEventListeners( Event.ADDED_TO_STAGE);
		}
		private function remove():void
		{
			this.removeChildren(0,-1, true);
			this.view = null;
			this.view_dead = null;
			this.speed = null;
			this.removeEventListeners(Event.ENTER_FRAME);
			this.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
			this.removeEventListeners(Event.REMOVED_FROM_STAGE);
			this.dispose();
		}
		public function start():void
		{
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		public function resume():void
		{
			this.stop();
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		public function stop():void
		{
			this.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
		}
		private function update():void
		{
			this.speed.y += this.gravity;
			if ( this.speed.y > this.maxspeedy ) this.speed.y = this.maxspeedy;
			this.y+= this.speed.y;
			if ( this.y < 0 ) this.y = 0;
			this.rotation = this.speed.y / 100;
		}
		public function jetPack():void
		{
			Game.instance.assets.getSound('pedo').play();
			this.speed.y -= 16;
			if ( this.speed.y < -20 ) this.speed.y = -20;
		}
		
		public function die():void
		{
			Game.instance.assets.getSound('death').play();
			this.isDead = true;
			this.stop();
			this.dispatchEventWith('die');
			this.view.removeFromParent(true);
			this.addChild(this.view_dead);
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, updatedead);
		}
		private function updatedead():void
		{
			this.rotation+=.5;
			this.x+=3;
			this.y-=2;
			
			if ( this.x > this.stage.stageWidth + 100 || this.y < -100 )
			{
				this.stop();
			}
		}
	}
}
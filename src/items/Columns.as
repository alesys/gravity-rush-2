package items
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.textures.TextureSmoothing;
	
	public class Columns extends Sprite
	{
		private var upper_column:Image;
		private var lower_column:Image;
		private var free_area:Rectangle = new Rectangle(0,0,120,140);
		private var pointA:Point = new Point();
		private var pointB:Point = new Point();
		private var rectangleA:Rectangle = new Rectangle();
		private var rectangleB:Rectangle = new Rectangle();
		private var hasScored:Boolean;
		public function Columns()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(e:Event):void
		{
			this.free_area.y =  Math.round(60*Math.random()+10)*10;
			var fixed_height:int = 800;
			this.upper_column = new Image(Game.instance.assets.getTexture('columna'));
			this.lower_column = new Image(Game.instance.assets.getTexture('columna'));
			
			this.upper_column.smoothing = TextureSmoothing.NONE;
			this.lower_column.smoothing = TextureSmoothing.NONE;
			
			this.upper_column.y = this.free_area.y - fixed_height;
			this.lower_column.y = this.free_area.bottom;
			
			this.addChild( this.upper_column );
			this.addChild( this.lower_column );
			
			this.rectangleA = this.upper_column.bounds;
			this.rectangleB = this.lower_column.bounds;
			
			this.x = this.stage.stageWidth;
			this.addEventListener( EnterFrameEvent.ENTER_FRAME, update);
			this.removeEventListeners( Event.ADDED_TO_STAGE);
			Game.instance.scene.hero.addEventListener('die', this.stop_this);
		}
		private function stop_this():void
		{
			Game.instance.scene.hero.removeEventListener('die', this.stop_this);
			this.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
		}
		private function update():void
		{
			this.x-=3;
			if ( this.x < -this.free_area.width ) 
			{
				this.upper_column.removeFromParent(true);
				this.lower_column.removeFromParent(true);
				Game.instance.scene.hero.removeEventListener('die', this.stop_this);
				this.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
				this.removeFromParent(true);
			}
			else
			{
				if ( this.x < Game.instance.scene.hero.x && !hasScored)
				{
					this.hasScored = true;
					Game.instance.assets.getSound('coin').play();
					Game.instance.scene.score++;
				}
				
				this.rectangleA.x = this.rectangleB.x = this.x;
				
				this.pointA.x = Game.instance.scene.hero.x;
				this.pointA.y = Game.instance.scene.hero.y;
				
				if ( this.pointA.x > this.rectangleA.x && this.pointA.x < this.rectangleA.right &&
					 this.pointA.y > this.rectangleA.y && this.pointA.y < this.rectangleA.bottom )
				{
					Game.instance.scene.kill_hero();
				}
				if ( this.pointA.x > this.rectangleB.x && this.pointA.x < this.rectangleB.right &&
					 this.pointA.y > this.rectangleB.y && this.pointA.y < this.rectangleB.bottom )
				{
					Game.instance.scene.kill_hero();
				}
			}
		}
	}
}
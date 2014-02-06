package characters
{
	import flash.geom.Point;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.textures.TextureSmoothing;
	
	public class Enemy extends Sprite
	{
		private var view:Image;
		private var rotationINC:Number;
		private var hasScored:Boolean;
		private var pointA:Point = new Point();
		private var pointB:Point = new Point();
		public function Enemy()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		private function initialize():void
		{
			var skins:Array = ('escombros_uno,escombro_dos,escombro_tres,escombro_cuatro,lagarra,nave_panel,' +
				'navesita,piedra_cuatro,piedra_dos,piedra_tres,piedra_uno,planeta_cuatro,planeta_dos,planeta_tres,' +
				'planeta_uno,satelite').split(',');
			this.view = new Image( Game.instance.assets.getFirstTexture( skins[ Math.floor(Math.random()*skins.length) ] ));
			this.view.smoothing = TextureSmoothing.NONE;
			this.addChild( this.view );
			this.view.pivotX = this.view.width>>1;
			this.view.pivotY = this.view.height>>1;
			this.x = this.stage.stageWidth + 64;
			this.y = this.stage.stageHeight * Math.random();
			this.rotationINC = Math.random() * 2 - 1;
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		private function update():void
		{
			this.x-=3;
			if ( this.x < -64 ) 
			{
				this.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
				this.removeFromParent(true);
			}
			else
			{
				this.rotation+= this.rotationINC/10;
				if ( this.x < Game.instance.scene.hero.x && !hasScored)
				{
					this.hasScored = true;
					Game.instance.scene.score++;
				}
				pointA.x = Game.instance.scene.hero.x;
				pointA.y = Game.instance.scene.hero.y;
				pointB.x = this.x;
				pointB.y = this.y;
				var distance:int = Math.round( Point.distance(pointA, pointB));
				if ( distance < 64 ) 
				{
					//kill
				}
			}
			
		}
	}
}
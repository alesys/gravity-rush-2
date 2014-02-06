package utils
{
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	
	public class Assets extends AssetManager
	{
		public function Assets(scaleFactor:Number=1, useMipmaps:Boolean=false)
		{
			super(scaleFactor, useMipmaps);
		}
		public function getFirstTexture(prefix:String):Texture
		{
			return this.getTextures(prefix)[0];
		}
	}
}
package shaders;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import haxe.Timer;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

class PixelFilter extends FlxShader {
	@:glFragmentSource('
		#pragma header
		vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
		vec2 iResolution = openfl_TextureSize;

		#define PIXEL_SIZE 10

		void main()
		{
			gl_FragColor = vec4(0);
			vec2 d = 1.0 / iResolution.xy;
			vec2 uv = (d.xy * float(PIXEL_SIZE)) * floor(fragCoord.xy / float(PIXEL_SIZE));

			for (int i = 0; i < PIXEL_SIZE; i++)
				for (int j = 0; j < PIXEL_SIZE; j++)
					gl_FragColor += flixel_texture2D(bitmap, uv.xy + vec2(d.x * float(i), d.y * float(j)));

			gl_FragColor /= pow(float(PIXEL_SIZE), 2.0);
		}
	')
	public function new() {
		super();
	}
}
package shaders;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import haxe.Timer;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

class ChromaticAberrationShader extends FlxShader { 
	@:glFragmentSource(' 
		#pragma header //https://www.shadertoy.com/view/4dXXDl

		void main()
		{
			float ChromaticAberration = 20 / 10.0 + 8.0;
			vec2 uv = openfl_TextureCoordv;
              
			vec2 texel = 1.0 / openfl_TextureSize.xy;
			
			vec2 coords = (uv - 0.5) * 2.0;
			float coordDot = dot(coords, coords);
			
			vec2 precompute = ChromaticAberration * coordDot * coords;
			vec2 uvR = uv - texel.xy * precompute;
			vec2 uvB = uv + texel.xy * precompute;
			
			vec4 color;
			color.r = flixel_texture2D(bitmap, uvR).r;
			color.g = flixel_texture2D(bitmap, uv).g;
			color.b = flixel_texture2D(bitmap, uvB).b;

			gl_FragColor = color;
         }
	')
	public function new() {
		super();
	}
}

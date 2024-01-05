package shaders;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import haxe.Timer;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

class GlitchShader extends FlxShader { 
	@:glFragmentSource(' 
		#pragma header //https://www.shadertoy.com/view/MllBzs
		uniform float iTime;

		float rand(vec2 co) {
			return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
		}

		void main()
		{
			vec2 uv = openfl_TextureCoordv; //Condensing this into one line
			vec4 texColor = flixel_texture2D(bitmap, uv); //Get the pixel at xy from iChannel0
              
			float gt = 30.0; // + rand(vec2(iTime, iTime)) * 3.0;
			float m = mod(iTime, 1.0);
			bool glitch = m < 0.5;
			float t = floor(iTime * gt) / gt;
			float r = rand(vec2(t, t));
			
			if (glitch)
			{
				vec2 uvGlitch = uv;
				uvGlitch.x -= r / 5.0;
				if (uv.y > r && uv.y < r + 0.01) {
					texColor = flixel_texture2D(bitmap, uvGlitch);
				}
			}

			gl_FragColor = texColor;
         }
	')
	public function new() {
		super();
		iTime.value = [Timer.stamp()];
	}

	public function update(elapsed:Float) {
		iTime.value[0] += elapsed;
	}
}

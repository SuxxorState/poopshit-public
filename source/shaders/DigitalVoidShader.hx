package shaders;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import haxe.Timer;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

class DigitalVoidShader extends FlxShader { 
	@:glFragmentSource(' 
		#pragma header //https://www.shadertoy.com/view/wtsSW8
		uniform float iTime;
		#define PI 3.141592

		float random(vec2 uv) {
			float rand = sin(fract(sin(uv.x * 2.528371
				 + sin(uv.y * 7.72962))) * 83.62847) + sin(uv.x + sin(uv.y)) * 22.0;
			return rand;
		}

		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			vec3 col = vec3(1.0, 1.0, 1.0);
			//uv.x += iTime;
			vec2 outV = uv;
			vec2 newV = (uv - 0.5) * 2.0;
			float fade = 1.0 - abs(uv.x * 2.0 - 1.0);
			outV.x = fade * 2.0;
			outV.y += outV.x * newV.y;
			
			outV.x *= 1.5;
			
			float spd = abs(random(vec2(floor(outV.y * 10.0))) * 0.25 + 10.0) * 0.2;
			
			outV.x += iTime * -0.5 * spd;
			
			vec2 fpos = fract(outV * 10.0);
			//used to add randomness to either side
			outV.x += floor(uv.x * 2.0 - 1.0);
			vec2 ipos = floor(outV * 10.0);
			float fval = fpos.x * fpos.y;
			
			float rand = abs(random(ipos)) * 0.05;
			fval = floor(sin(fpos.x * PI) + rand * 0.8);
			fval *= floor(sin(fpos.y * PI) + 0.3);
			//fval = sin(fpos.y * PI) * rand;
			
			//col = vec3(abs(random(vec2(ipos.y, ipos.y))) * 0.05);

			col = vec3(fval);
			col *= 1.0 - fade;
			//col = vec3(rand);
			
			gl_FragColor = vec4(col, 1.0);
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

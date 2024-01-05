package shaders;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import haxe.Timer;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

class GreyscaleFilter extends FlxShader {
	@:glFragmentSource('
		#pragma header
		#define USE_PHOTOSHOP_ALGORITHM

		vec4 generic_desaturate(vec3 color, float factor)
		{
			vec3 lum = vec3(0.299, 0.587, 0.114);
			vec3 gray = vec3(dot(lum, color));
			return vec4(mix(color, gray, factor), 1.0);
		}

		vec4 photoshop_desaturate(vec3 color)
		{
			float bw = (min(color.r, min(color.g, color.b)) + max(color.r, max(color.g, color.b))) * 0.5;
			return vec4(bw, bw, bw, 0.5);
		}

		void main()
		{
			vec2 uv = openfl_TextureCoordv;
    
			#	ifdef USE_GENERIC_ALGORITHM
			gl_FragColor = generic_desaturate(texture2D(bitmap, uv).rgb, 1.0);
			#	endif
    
			#	ifdef USE_PHOTOSHOP_ALGORITHM
			gl_FragColor = photoshop_desaturate(texture2D(bitmap, uv).rgb);
			#	endif
    
			#	ifndef USE_PHOTOSHOP_ALGORITHM
			#	ifndef USE_GENERIC_ALGORITHM
			gl_FragColor = texture2D(bitmap, uv);
			#	endif
			#	endif
        }
	')
	public function new() {
		super();
	}
}
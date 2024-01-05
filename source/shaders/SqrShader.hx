package shaders;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import haxe.Timer;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;
  
class SqrShader extends FlxShader {
        @:glFragmentSource('
                #pragma header //https://www.shadertoy.com/view/4sSBDK
                uniform float iTime;
                vec2 iResolution = openfl_TextureSize;

                void mainImage( out vec4 C, in vec2 R ) {
                        R = ceil((R.xy / iResolution.xy - .5) * 99.) / 99. + cos(iTime) * .2;
                        R.x *= 1. + pow(sin(iTime + R.y * 2.), 4.);
                        //C -= C; // mac fix - clear color;
                        R *= sin(R * 30.);
                        C += -C + ceil(R.x * R.y) * .2;
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
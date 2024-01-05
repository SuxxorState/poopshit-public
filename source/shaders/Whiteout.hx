package shaders;

import flixel.system.FlxAssets.FlxShader;
import haxe.Timer;

//that's what it is
class Whiteout extends FlxShader {
    @:glFragmentSource('
        #pragma header

        void main() {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            gl_FragColor = vec4(1 * color.a, 1 * color.a, 1 * color.a, color.a);
        }
    ')
    public function new() {
        super();
    }
}
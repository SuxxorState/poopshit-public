package shaders;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import haxe.Timer;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

class SnowShader extends FlxShader {
    @:glFragmentSource('
        #pragma header
        vec2 uv = openfl_TextureCoordv;
        vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
        vec2 iResolution = openfl_TextureSize;
        uniform float iTime;
        #define iChannel0 bitmap
        #define texture flixel_texture2D
        #define fragColor gl_FragColor
        #define mainImage main    
        #define HASHSCALE1 .1031
        #define HASHSCALE3 vec3(.1031, .1030, .0973)
        #define HASHSCALE4 vec3(.1031, .1030, .0973, .1099)
        
        float SIZE_RATE = 0.1;
        float XSPEED = 0.5;
        float YSPEED = 1.0;
        float LAYERS = 10.;
        
        float Hash11(float p)
        {
            vec3 p3  = fract(vec3(p) * HASHSCALE1);
            p3 += dot(p3, p3.yzx + 19.19);
            return fract((p3.x + p3.y) * p3.z); 
        }
        
        vec2 Hash22(vec2 p)
        {
            vec3 p3 = fract(vec3(p.xyx) * HASHSCALE3);
            p3 += dot(p3, p3.yzx+19.19);
            return fract((p3.xx+p3.yz)*p3.zy);
        }
        
        
        vec2 Rand22(vec2 co)
        {
            float x = fract(sin(dot(co.xy ,vec2(122.9898,783.233))) * 43758.5453);
            float y = fract(sin(dot(co.xy ,vec2(457.6537,537.2793))) * 37573.5913);
            return vec2(x,y);
        }
        
        vec3 SnowSingleLayer(vec2 uv,float layer){
            
            vec3 acc = vec3(0.0,0.0,0.0);//让雪花的大小变化
            uv = uv * (2.0+layer);//透视视野变大效果
            float xOffset = uv.y * (((Hash11(layer)*2.-1.)*0.5+1.)*XSPEED);//增加x轴移动
            float yOffset = (YSPEED*iTime);//y轴下落过程
            uv += vec2(xOffset,yOffset);
            vec2 rgrid = Hash22(floor(uv)+(31.1759*layer));
            uv = fract(uv);
            uv -= (rgrid*2.-1.0) * 0.35;
            uv -=0.5;
            float r = length(uv);
            //让大小变化点
            float circleSize = 0.05*(1.0+0.3*sin(iTime*SIZE_RATE));
            float val = smoothstep(circleSize,-circleSize,r);
            vec3 col = vec3(val,val,val)* rgrid.x ;
            return col;
        }
        
        
        void main()
        {
            // Normalized pixel coordinates (from 0 to 1)
            vec2 uv = fragCoord/iResolution.xy;
        
        
            uv *= vec2(iResolution.x/iResolution.y,1.0);
            
            vec3 acc = vec3(0,0,0);
            for (float i=0.;i<LAYERS;i++) {
                acc += SnowSingleLayer(uv,i); 
            }
        
            // Output to screen
            fragColor = vec4(acc,0.0);
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
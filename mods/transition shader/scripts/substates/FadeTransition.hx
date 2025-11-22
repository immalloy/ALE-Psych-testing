import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import funkin.visuals.shaders.ALERuntimeShader;
import utils.cool.ShaderUtil;

var transCamera:FlxCamera;
var shaderSprite:FlxSprite;
var transitionShader:ALERuntimeShader;
var progress:Float = 0;
var shaderTime:Float = 0;
var transitionDuration:Float = 0.75;
var finished:Bool = false;

function onCreate()
{
        FlxState.transitioning = true;

        transCamera = new ALECamera();
        FlxG.cameras.add(transCamera, false);

        shaderSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x00ffffff);
        shaderSprite.scrollFactor.set();
        shaderSprite.cameras = [transCamera];
        add(shaderSprite);

        transitionShader = ShaderUtil.createRuntimeShader('Pretty Hip');
        if (transitionShader != null)
        {
                shaderSprite.shader = transitionShader;
        }

        progress = transIn ? 1.0 : 0.0;
        updateShaderUniforms(0);
}

function updateShaderUniforms(elapsed:Float)
{
        if (transitionShader == null)
                return;

        shaderTime += elapsed;
        transitionShader.setFloat('uTime', shaderTime);
        transitionShader.setFloat('uProgress', progress);
        transitionShader.setFloat2('uResolution', FlxG.width, FlxG.height);
}

function onUpdate(elapsed:Float)
{
        var direction:Float = transIn ? -1.0 : 1.0;
        progress = Math.max(0, Math.min(1, progress + direction * (elapsed / transitionDuration)));

        updateShaderUniforms(elapsed);

        if (!finished && ((!transIn && progress >= 1) || (transIn && progress <= 0)))
        {
                finished = true;
                finishCallback();
                close();
        }
}

function onDestroy()
{
        FlxState.transitioning = false;
        FlxG.cameras.remove(transCamera);
}

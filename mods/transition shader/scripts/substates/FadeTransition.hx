import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import funkin.visuals.ALECamera;
import funkin.visuals.shaders.ALERuntimeShader;
import utils.cool.ShaderUtil;

// HScript compatibility: provide a default super constructor placeholder so the
// interpreter never complains about an undefined __super_new reference.
function __super_new(?arg1:Dynamic, ?arg2:Dynamic, ?arg3:Dynamic, ?arg4:Dynamic)
{
        return null;
}

var transCamera:FlxCamera;
var shaderSprite:FlxSprite;
var transitionShader:ALERuntimeShader;
var progress:Float = 0;
var shaderTime:Float = 0;
var transitionDuration:Float = 0.75;
var finished:Bool = false;
var lastLogStep:Int = -1;

function onCreate()
{
        FlxState.transitioning = true;
        trace('[FadeTransition] onCreate (transIn=' + transIn + ')');

        transCamera = new ALECamera();
        FlxG.cameras.add(transCamera, false);

        shaderSprite = new FlxSprite();
        shaderSprite.makeGraphic(FlxG.width, FlxG.height, 0x00ffffff);
        shaderSprite.scrollFactor.set();
        shaderSprite.cameras = [transCamera];
        add(shaderSprite);

        transitionShader = ShaderUtil.createRuntimeShader('Pretty Hip');
        if (transitionShader != null)
        {
                shaderSprite.shader = transitionShader;
                trace('[FadeTransition] Shader assigned successfully');
        }
        else
        {
                trace('[FadeTransition] Failed to create transition shader');
        }

        progress = transIn ? 1.0 : 0.0;
        updateShaderUniforms(0);
}

function updateShaderUniforms(elapsed:Float)
{
        if (transitionShader == null)
                return;

        shaderTime += elapsed;
        var clampedProgress:Float = Math.max(0, Math.min(1, progress));

        transitionShader.setFloat('uTime', shaderTime);
        transitionShader.setFloat('uProgress', clampedProgress);
        transitionShader.setFloat2('uResolution', FlxG.width, FlxG.height);
}

function onUpdate(elapsed:Float)
{
        var direction:Float = transIn ? -1.0 : 1.0;
        progress = Math.max(0, Math.min(1, progress + direction * (elapsed / transitionDuration)));

        updateShaderUniforms(elapsed);

        var currentStep:Int = Std.int(shaderTime * 10);
        if (currentStep != lastLogStep && currentStep % 5 == 0)
        {
                trace('[FadeTransition] time=' + shaderTime + ' progress=' + progress + ' dir=' + direction);
                lastLogStep = currentStep;
        }

        if (!finished && ((!transIn && progress >= 1) || (transIn && progress <= 0)))
        {
                finished = true;
                trace('[FadeTransition] Transition finished');
                finishCallback();
                close();
        }
}

function onDestroy()
{
        FlxState.transitioning = false;
        trace('[FadeTransition] onDestroy');
        FlxG.cameras.remove(transCamera);
}

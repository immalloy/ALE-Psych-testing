#pragma header

uniform float uTime;
uniform float uProgress;
uniform vec2 uResolution;

float gridLine(vec2 p, float thickness)
{
    vec2 d = abs(fract(p) - 0.5);
    float lineX = 1.0 - smoothstep(thickness, thickness + 0.02, d.x);
    float lineY = 1.0 - smoothstep(thickness, thickness + 0.02, d.y);
    return max(lineX, lineY);
}

void main()
{
    vec2 fragCoord = openfl_TextureCoordv * uResolution;
    float aspect = uResolution.y / uResolution.x;

    vec2 uv = (fragCoord - 0.5 * uResolution) / uResolution.x;
    float spin = radians(45.0) + 0.25 * sin(uTime * 0.8);
    mat2 rot = mat2(cos(spin), -sin(spin), sin(spin), cos(spin));
    uv = rot * uv;
    uv += vec2(0.5, 0.5 * aspect);
    uv.y += 0.5 * (1.0 - aspect);

    vec2 wobble = 0.12 * sin(vec2(0.8, 1.1) * uTime + uv.yx * 6.2831);
    vec2 grid = uv * (8.0 + 2.0 * sin(uTime * 0.5)) + wobble;

    float pulse = 0.5 + 0.5 * sin(uTime * 1.6 + length(grid) * 0.75);
    float thickness = mix(0.26, 0.1, clamp(uProgress, 0.0, 1.0));
    float lines = gridLine(grid + pulse, thickness);

    float visibility = clamp(uProgress, 0.0, 1.0);
    float alpha = lines * visibility;
    vec3 color = vec3(1.0) * lines;

    gl_FragColor = vec4(color, alpha);
}

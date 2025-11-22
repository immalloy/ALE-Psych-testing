#pragma header

uniform float uTime;
uniform float uProgress;
uniform vec2 uResolution;

float gridLine(vec2 p, float thickness)
{
        vec2 d = abs(p);
        float lineX = 1.0 - smoothstep(thickness, thickness + 0.005, d.x);
        float lineY = 1.0 - smoothstep(thickness, thickness + 0.005, d.y);
        return max(lineX, lineY);
}

void main()
{
        vec2 fragCoord = openfl_TextureCoordv * uResolution;
        vec2 uv = fragCoord / uResolution.xy;

        // Centered UV with aspect preservation for consistent square shape.
        vec2 centered = uv - 0.5;
        centered.x *= uResolution.x / uResolution.y;

        // Spin gently over time to keep the grid alive without overwhelming the transition.
        float spin = 0.2 * sin(uTime * 0.7);
        mat2 rot = mat2(cos(spin), -sin(spin), sin(spin), cos(spin));
        vec2 animUV = rot * centered + 0.5;

        float eased = smoothstep(0.0, 1.0, clamp(uProgress, 0.0, 1.0));

        // Increase cell density as progress rises so squares "build" across the screen.
        float cellCount = mix(3.0, 18.0, eased);
        vec2 wobble = 0.015 * sin(vec2(1.8, 1.4) * uTime + animUV.yx * 10.0);
        vec2 grid = (animUV + wobble) * cellCount;

        vec2 cell = fract(grid) - 0.5;
        float thickness = mix(0.003, 0.02, eased);
        float lines = gridLine(cell, thickness);

        // Reveal the lines from their intersections outward, filling each square over time.
        float edge = max(abs(cell.x), abs(cell.y)) * 2.0;
        float build = smoothstep(-0.1, 1.0, eased - edge);

        float pulse = 0.55 + 0.45 * sin(uTime * 1.3 + length(grid) * 0.2);
        float alpha = clamp(lines * build * pulse, 0.0, 1.0);

        gl_FragColor = vec4(vec3(1.0), alpha);
}

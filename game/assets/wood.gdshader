shader_type spatial;
varying vec3 world_position;
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
    vec2 p = world_position.xz;
    float row = floor(p.x / 0.23);
    float gx = mod(p.x, 0.23);
    float gy = mod(p.y + mod(row, 3.0) * 0.65, 2.0);
    float seam = smoothstep(0.001, 0.004 + fwidth(p.x), min(gx, 0.23 - gx)) * smoothstep(0.001, 0.004 + fwidth(p.y), min(gy, 2.0 - gy));
    float grain = sin(p.y * 26.0 + sin(p.y * 1.2 + row) * 4.0 + row * 8.0) * 0.009;
    float variation = fract(sin(row * 78.23) * 43758.54) * 0.07;
    ALBEDO = mix(vec3(0.31, 0.23, 0.16), vec3(0.48 + variation, 0.34 + variation, 0.22 + variation) + grain, seam);
    ROUGHNESS = 0.66;
}

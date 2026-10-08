Texture2D scene : register(t0, space2);
Texture2D displacement : register(t1, space2);
Texture2D soup : register(t2, space2);
Texture2D mask : register(t3, space2);
SamplerState sampler_scene : register(s0, space2);
SamplerState sampler_displacement : register(s1, space2);
SamplerState sample_soup : register(s2, space2);
SamplerState sampler_mask : register(s3, space2);

struct Input {
    float4 tex_color : COLOR0;
    float2 tex_coord : TEXCOORD0;
};

struct Output {
    float4 frag_color : SV_Target;
};

Output main(Input input) {
    Output output;
    float4 displacement_magnitude = displacement.Sample(sampler_displacement, input.tex_coord);

    float displacement_perc = 0.06;
    float2 displacement_uv = float2(
        input.tex_coord.x + (displacement_magnitude.r * displacement_perc - displacement_perc / 2.0),
        input.tex_coord.y + (displacement_magnitude.r * displacement_perc - displacement_perc / 2.0)
    );
    float2 resolved_uv = float2(
        clamp(displacement_uv.x, 0.0, 1.0),
        clamp(displacement_uv.y, 0.0, 1.0)
    );

    float4 soup_level = soup.Sample(sample_soup, input.tex_coord);
    float4 should_mask = mask.Sample(sampler_mask, input.tex_coord);

    if (should_mask.r < 0.5 && should_mask.a > 0.5) {
      if (soup_level.r > 0.30) {
        float highlight_alpha = 0.65;
        float4 base_color = scene.Sample(sampler_scene, resolved_uv) * input.tex_color;
        output.frag_color = float4(lerp(base_color.rgb,
                                        float3(1.0, 1.0, 1.0),
                                        highlight_alpha),
                                   base_color.a);
      } else {
        output.frag_color = scene.Sample(sampler_scene, resolved_uv) * input.tex_color;
      }
    } else {
      output.frag_color = scene.Sample(sampler_scene, input.tex_coord) * input.tex_color;
    }
    return output;
}

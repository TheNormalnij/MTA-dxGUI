texture texture0;
float factor;

sampler Sampler0 = sampler_state
{
    Texture = (texture0);
    AddressU = MIRROR;
    AddressV = MIRROR;
};

struct PSInput
{
  float2 TexCoord : TEXCOORD0;
};

float4 PixelShader_Background(PSInput PS) : COLOR0
{
	float4 sum = tex2D(Sampler0, PS.TexCoord);
	for (float i = 1; i < 3; i++) {
		sum += tex2D(Sampler0, float2(PS.TexCoord.x, PS.TexCoord.y + (i * factor)));
		sum += tex2D(Sampler0, float2(PS.TexCoord.x, PS.TexCoord.y - (i * factor)));
		sum += tex2D(Sampler0, float2(PS.TexCoord.x - (i * factor), PS.TexCoord.y));
		sum += tex2D(Sampler0, float2(PS.TexCoord.x + (i * factor), PS.TexCoord.y));
	}
	sum /= 9;
	sum.a = 1.0;
	return sum;
}

technique complercated
{
    pass P0
    {
        PixelShader = compile ps_2_0 PixelShader_Background();
    }
}

technique simple
{
    pass P0
    {
        Texture[0] = texture0;
    }
}
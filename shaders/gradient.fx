//
// Gradient shader - gradient.fx
//

float2 gradientVector = float2( 1, 1 );
float4 sGradientFromColor = float4( 0, 0, 0, 0 );
float4 sGradientToColor = float4( 1, 1, 1, 1 );

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction( float4 Diffuse : COLOR0, float2 TexCoord : TEXCOORD0) : COLOR0
{
    return ( sGradientFromColor + ( sGradientToColor - sGradientFromColor ) * length( TexCoord * gradientVector ) ) * Diffuse;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique tec0
{
    pass P0
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

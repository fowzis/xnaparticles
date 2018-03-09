#if OPENGL
	#define SV_Position POSITION
	#define VS_SHADERMODEL vs_3_0
	#define PS_SHADERMODEL ps_3_0
#else
	#define VS_SHADERMODEL vs_4_0_level_9_1
	#define PS_SHADERMODEL ps_4_0_level_9_1
#endif

//float4x4 view;
//float4x4 proj;
//float4x4 world;
float4x4 WVP;

//float sizeModifier : PARTICLE_SIZE = 5.5f; 

//float screenHeight = 720;

//particle texture
Texture2D textureMap : register(t0);
Texture2D positionMap : register(t1);

SamplerState textureSampler : register(s0);
//SamplerState textureSampler : register(s0)
//{
//	MipFilter = LINEAR;
//	MinFilter = LINEAR;
//	MagFilter = LINEAR;
//	AddressU = CLAMP;
//	AddressV = CLAMP;
//};


SamplerState positionSampler : register(s1);
//SamplerState positionSampler : register(s1)
//{
//	MipFilter = NONE;
//	MinFilter = POINT;
//	MagFilter = POINT;
//	AddressU = CLAMP;
//	AddressV = CLAMP;
//};

struct PS_INPUT
{
	float4 coord : POSITION0;
	float4 color   : COLOR0;
};

struct VertexShaderInput
{
	float4 pos    : POSITION0;
	float4 color  : SV_Target;
};

struct VertexShaderOutput
{
	float4 pos    : SV_Position;
	float4 color  : COLOR0;
};

VertexShaderOutput Transform(in VertexShaderInput In)
{
	VertexShaderOutput Out = (VertexShaderOutput)0;

	float4 realPosition = positionMap.SampleLevel( positionSampler, In.pos.xy, 0 );
	
    
    Out.color = In.color;
    realPosition.w = 1;
    Out.pos = mul(realPosition, WVP);
	//Out.Size = sizeModifier * proj._m11 / Out.position.w * screenHeight / 2;
	//Out.Size = 1;
    return Out;
};
    
float4 ApplyTexture(PS_INPUT input) : COLOR
{
	//float4 col=tex2D(textureSampler, coord) * input.color;
	float4 col = textureMap.Sample(textureSampler, input.coord.xy) * input.color;

	return col;
};

technique TransformAndTexture
{
	pass Pass1
	{
		VertexShader = compile VS_SHADERMODEL Transform();
		PixelShader = compile PS_SHADERMODEL ApplyTexture();
	}
};
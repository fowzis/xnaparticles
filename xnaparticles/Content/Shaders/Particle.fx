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

//SamplerState textureSampler : register(s0);
SamplerState textureSampler : register(s0)
{
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
};


//SamplerState positionSampler : register(s1);
SamplerState positionSampler : register(s1)
{
	MipFilter = NONE;
	MinFilter = POINT;
	MagFilter = POINT;
	AddressU = CLAMP;
	AddressV = CLAMP;
};


struct VertexShaderInput
{
	float4 pos    : SV_POSITION;
	float4 color  : COLOR0;
};

struct VertexShaderOutput
{
	float4 pos    : SV_Position;
	float4 color  : COLOR0;
};

struct VS_INPUT {
	float4 vertexData	: POSITION;
	float4 color		: COLOR0;
};

struct VS_OUTPUT
{
	float4 position  : POSITION;
	float4 color	 : COLOR0;
	//float Size : PSIZE0;
};

struct PS_INPUT
{
	float2 texCoord : TEXCOORD0;
	float4 color : COLOR0;
};

VS_OUTPUT Transform(in VS_INPUT In)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;

	float4 realPosition = positionMap.SampleLevel( positionSampler, In.vertexData.xy, 0 );
	
    realPosition.w = 1;
    Out.position = mul(realPosition, WVP);
	Out.color = In.color;
	//Out.Size = sizeModifier * proj._m11 / Out.position.w * screenHeight / 2;
	//Out.Size = 1;
    return Out;
};
    
float4 ApplyTexture(PS_INPUT input) : COLOR
{
	//float4 col=tex2D(textureSampler, pos) * input.color;
	float4 col = textureMap.Sample(textureSampler, input.texCoord) * input.color;

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
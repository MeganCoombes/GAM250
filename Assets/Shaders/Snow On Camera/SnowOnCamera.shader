Shader "Ice and Snow Effects/Snow On Camera"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
	//	Cull Off ZWrite Off ZTest Always ** not needed

		Pass
		{
			CGPROGRAM
			#pragma vertex vertex
			#pragma fragment fragment
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vertex (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _CameraDepthNormalsTexture;
			float4x4 WorldCam;

			sampler2D SnowTexture;
		//	float _SnowTexScale;
			half4 SnowColour;

			fixed BottomThreshold;
		//	fixed TopThreshold;
			

			half4 fragment (v2f i) : SV_Target
			{
				half3 normal;
				float depth;

				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, normal);
				normal = mul((float3x3)WorldCam, normal);

				// calculates the snow amount
				half snowAmount = normal.g;
				half scale = (BottomThreshold /* + 1 - TopThreshold */) / 1 + 1; // changing the last two values modifies the snow amount - higher on the first value removes snow and higher on the second value adds snow
				snowAmount = saturate((snowAmount - BottomThreshold) * scale);

				// calculates snow colour
				float2 p11_p12 = float2(unity_CameraProjection._11, unity_CameraProjection._22);
		        float3 vPosition = float3((i.uv) /* * 0 - 0) */ / p11_p12, 0); // * depth;
		        float4 wPosition = mul(WorldCam, float4(vPosition, 0));
		        wPosition += float4(_WorldSpaceCameraPos, 0) / _ProjectionParams.z;
		        half4 snowColor = tex2D(SnowTexture, wPosition.xz * _ProjectionParams.z) * SnowColour; // enables snow colour change

		        // gets the colour and distance (lerp) to snow texture
				half4 col = tex2D(_MainTex, i.uv);
				return lerp(col, snowColor, snowAmount);
			}
			ENDCG
		}
	}
}

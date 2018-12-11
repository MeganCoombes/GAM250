Shader "Ice and Snow Effects/Ice Effect 2" {

	Properties
	{
		SilhouetteEffect("Silhouette Effect", 2D) = "white" {}
		OverIce("Over Ice Effect", 2D) = "white" {}
		SurfaceTexture("Surface Effect", 2D) = "white" {}
		Colour("Colour", Color) = (1, 1, 1, 1)
		EdgeThickness("Silouette Dropoff Rate", float) = 1.0
		DistortStrength("Distortion Strength", float) = 1.0
	}

		SubShader
		{
			// Grabs the screen behind the object into "Background"
			GrabPass
			{
				"Background"
			}

			// Background distortion
			Pass
			{
				Tags
				{
					"Queue" = "Transparent"
				}

				CGPROGRAM
				#pragma vertex vertex
				#pragma fragment fragment
				#include "UnityCG.cginc"

			// Properties
			sampler2D Background;
			sampler2D SurfaceTexture;
			float     DistortStrength;
			float     EdgeThickness;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float3 texCoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 grabPosition : TEXCOORD0;
			};

			vertexOutput vertex(vertexInput input)
			{
				vertexOutput output;

				// convert to world space
				output.pos = UnityObjectToClipPos(input.vertex);
				float4 normal4 = float4(input.normal, 0.0);
				float3 normal = normalize(mul(normal4, unity_WorldToObject).xyz);

				// ComputeGrabScreenPos function gets correct texture coordinate
				output.grabPosition = ComputeGrabScreenPos(output.pos);

				// distort based on the surface texture
				float3 bump = tex2Dlod(SurfaceTexture, float4(input.texCoord.xy, 0, 0)).rgb;
				output.grabPosition.x += bump.x * DistortStrength;
				output.grabPosition.y += bump.y * DistortStrength;

				return output;
			}

			float4 fragment(vertexOutput input) : COLOR
			{
				return tex2Dproj(Background, input.grabPosition);
			}
			ENDCG
		}


			// Transparent color & lighting pass
			Pass
			{
				Tags
				{
					"LightMode" = "ForwardBase" // allows shadow rec/cast
					"Queue" = "Transparent"
				}
				Cull Off
				Blend SrcAlpha OneMinusSrcAlpha // standard alpha blending

				CGPROGRAM
				#pragma vertex vertex
				#pragma fragment fragment

				// Properties
				sampler2D       SilhouetteEffect;
				sampler2D       SurfaceTexture;
				sampler2D       OverIce;
				uniform float4	Colour;
			    uniform float   EdgeThickness;
				sampler2D       Background;

				struct vertexInput
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float3 texCoord : TEXCOORD0;
				};

				struct vertexOutput
				{
					float4 pos : SV_POSITION;
					float3 normal : NORMAL;
					float3 texCoord : TEXCOORD0;
					float3 viewDir : TEXCOORD1;
				};

				vertexOutput vertex(vertexInput input)
				{
					vertexOutput output;

					// convert input to world space
					output.pos = UnityObjectToClipPos(input.vertex);
					float4 normal4 = float4(input.normal, 0.0);
					output.normal = normalize(mul(normal4, unity_WorldToObject).xyz);
					output.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, input.vertex).xyz);

					// texture coordinates
					output.texCoord = input.texCoord; // almost removes transparent effect on larger objects when commented out

					return output;
				}

				float4 fragment(vertexOutput input) : COLOR
				{
					float edgeFactor = abs(dot(input.viewDir, input.normal)); // computes silhouette factor
					float oneMinusEdge = 1.0 - edgeFactor; // computes silhouette factor
					float3 rgb = tex2D(SilhouetteEffect, float2(oneMinusEdge, 0.5)).rgb; // gets silhouette colour
					float opacity = min(1.0, Colour.a / edgeFactor); // grabs silhouette opacity
					opacity = pow(opacity, EdgeThickness); // grabs silhouette opacity

					// applies the surface texture
					float3 bump = tex2D(SurfaceTexture, input.texCoord.xy).rgb + input.normal.xyz;
					float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
					float ramp = clamp(dot(bump, lightDir), 0.001, 1.0);
					float4 lighting = float4(tex2D(OverIce, float2(ramp, 0.5)).rgb, 1.0);

					return float4(rgb, opacity) * lighting;
				}

				ENDCG
			}
	 }
}
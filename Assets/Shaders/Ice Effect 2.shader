Shader "Ice and Snow Effects/Ice Effect 2" {

	Properties
	{
		Highlights("Colour Highlights", 2D) = "white" {} // leave as none to keep white colour
		OverIce("Over Ice Effect", 2D) = "white" {}
		SurfaceTexture("Surface Effect", 2D) = "white" {}
		Colour("Colour", Color) = (1, 1, 1, 1)
	//	EdgeThickness("Silouette Dropoff Rate", float) = 1.0
	//	DistortStrength("Distortion Strength", float) = 1.0
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
			// float     EdgeThickness;
		//	float     DistortStrength;

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

				// converts the inputs to world space
				output.pos = UnityObjectToClipPos(input.vertex);
				float4 normal4 = float4(input.normal, 0.0);
				float3 normal = normalize(mul(normal4, unity_WorldToObject).xyz);

				// ComputeGrabScreenPos function grabs the texture coordinate
				output.grabPosition = ComputeGrabScreenPos(output.pos);

				// **Distortion effect code below is not needed
			//	float3 bump = tex2Dlod(SurfaceTexture, float4(input.texCoord.xy, 0, 0)).rgb;
			//	output.grabPosition.x += bump.x * DistortStrength;
			//	output.grabPosition.y += bump.y * DistortStrength;

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
			//		"LightMode" = "ForwardBase" ** shadow, not needed
					"Queue" = "Transparent"
				}
				Cull Off
				Blend SrcAlpha OneMinusSrcAlpha // standard alpha blending

				CGPROGRAM
				#pragma vertex vertex
				#pragma fragment fragment

				// Properties
				sampler2D       Highlights;
				sampler2D       SurfaceTexture;
				sampler2D       OverIce;
				float4			Colour;
		//	    float			EdgeThickness;
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
					float3 viewDirection : TEXCOORD1;
				};

				vertexOutput vertex(vertexInput input)
				{
					vertexOutput output;

					// convert input to world space
					output.pos = UnityObjectToClipPos(input.vertex);
					float4 normal3 = float4(input.normal, 0.0);
					output.normal = normalize(mul(normal3, unity_WorldToObject).xyz);
					output.viewDirection = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, input.vertex).xyz);

					// texture coordinates
					output.texCoord = input.texCoord; // almost removes transparent effect on larger objects when commented out

					return output;
				}

				float4 fragment(vertexOutput input) : COLOR
				{
					//computes silhouette factor
					float edgeFactor = abs(dot(input.viewDirection, input.normal));
					float oneMinusEdge = edgeFactor;

					// gets silhouette colour
					float3 rgb = tex2D(Highlights, float2(oneMinusEdge, 0.5)).rgb;

					// gets silhouette opacity
					float opacity = min(2.0, Colour.a / edgeFactor);

				//	opacity = pow(opacity, EdgeThickness); ** not really needed for this shader since there's no 'edge'

					// applies the surface texture
					float3 bump = tex2D(SurfaceTexture, input.texCoord.xy).rgb + input.normal.xyz;
					float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
					float ramp = clamp(dot(bump, lightDirection), 0.001, 1.0);
					float4 lighting = float4(tex2D(OverIce, float2(ramp, 0.3)).rgb, 1); // changing the first value (after ramp,) changes the look of the ice surface
					

					return float4(rgb, opacity) * lighting;
				}
				
				ENDCG
			}
 
 /* Shadow pass - NOT NEEDED AT ALL
		Pass
    	{
            Tags 
			{
				"LightMode" = "ShadowCaster"
			}

            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f { 
                V2F_SHADOW_CASTER;
            };

            v2f vertex(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 fragment(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
		}
		*/
	}
}
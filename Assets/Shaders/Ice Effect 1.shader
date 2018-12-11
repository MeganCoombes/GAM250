Shader "Ice and Snow Effects/Ice Effect" {

	Properties{
		TopColor("Top Color", Color) = (0,0,0,0) // top gradient colour, change in inspector
		BottomColor("Bottom Color", Color) = (0,0,0,0) // top gradient colour, change in inspector
		RimBrightness("Rim Brightness", Range(3,5)) = 3.2 // ice rim brightness
	}

		SubShader{
		Tags{ "RenderType" = "Opaque" }

		LOD 200
		CGPROGRAM

#pragma surface surf IceSurface

		sampler2D IceLight;

		// something
#pragma lighting IceSurface
	inline half4 LightingIceSurface(SurfaceOutput s, half3 lightDir, half atten)
	{
		half d = dot(s.Normal, lightDir);
		half3 ice = tex2D(IceLight, float2(d,d)).rgb;
		half4 c;
		c.rgb = s.Albedo * _LightColor0.rgb * ice * (atten * 2);
		c.a = 0;
		return c;
	}


	float4 TopColor; // top gradient colour
	float4 BottomColor;// bottom gradient color
	float RimBrightness;// ice rim brightness


	struct Input {
		float3 viewDir; // view direction
		float3 worldPos; // world position

	};

	void surf(Input IN, inout SurfaceOutput o) {
		float3 localPos = saturate(IN.worldPos - mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz) + 0.4;
		float softIce = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal)); 
		float hardIce = round(softIce); 
		o.Emission = TopColor * lerp(hardIce, softIce, (localPos.x + localPos.y))  * (RimBrightness*localPos.y); // disabling this makes a nice dull effect
		float innerRim = 1.5 + saturate(dot(normalize(IN.viewDir), o.Normal)); 
		o.Albedo = TopColor * pow(innerRim, 0.7)*lerp(BottomColor, TopColor, localPos.y); // disabling this makes the gradient surface effect turn black

	}
	ENDCG

	}

		Fallback "Diffuse"
}
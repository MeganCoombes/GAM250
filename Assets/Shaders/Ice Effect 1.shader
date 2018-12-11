Shader "Ice and Snow Effects/Ice Effect" {

	Properties{
		TopColour("Top Color", Color) = (0,0,0,0) // top gradient colour, change in inspector
	//	BottomColor("Bottom Color", Color) = (0,0,0,0) // top gradient colour, change in inspector (not needed when transparent)
		IceBrightness("Ice Brightness", Range(3,5)) = 3.2 // ice brightness -- disabling this removes the brightness from the object
	}

		SubShader{
		Tags{ "RenderType" = "Transparency" } // makes objects look transparent
		// Tags{ "RenderType" = "Opaque" } 

		LOD 200
		CGPROGRAM

#pragma surface surf IceSurface

		sampler2D IceLight;

#pragma lighting IceSurface
	inline half4 LightingIceSurface(SurfaceOutput s, half3 lightDirection, half atten)
	{

/* BELOW NOT NEEDED FOR THIS SHADER AS THE DIRECTION OF THE LIGHT IS NOT NECESSARY
#ifndef USING_DIRECTIONAL_LIGHT
        lightDirection = normalize(lightDirection);
#endif
*/

		// applies colours correctly using the dot product
		half d = dot(s.Normal, lightDirection);
		half3 ice = tex2D(IceLight, half2(d,d)).rgb;
		half4 c;
		c.rgb = s.Albedo * _LightColor0.rgb * ice * (atten); //* 2
		c.a = 0;
		return c;
	}


	float4 TopColour; // top gradient colour
	float4 BottomColour;// bottom gradient color
	float IceBrightness;// ice rim brightness


	struct Input {
		float3 viewDir; // view direction
		float3 worldPos; // world position

	};

	// applies the lighting effect
	void surf(Input IN, inout SurfaceOutput o) {
		float3 localPos = saturate(IN.worldPos - mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz) + 0.4; // <- changing the last value changes the saturation of 'shadow' on the ice (depending on where the camera is facing)
		float softIce = /* 1.0 - */ saturate(dot(normalize(IN.viewDir), o.Normal)); // changing the value after softIce changes the saturation of the 'shadow' (not really needed if transparent)
		float hardIce = round(softIce); 
		o.Emission = TopColour * lerp(hardIce, softIce, (localPos.x + localPos.y)) * (IceBrightness*localPos.y); // disabling this makes a nice dull effect
		float innerRim = 2 + saturate(dot(normalize(IN.viewDir), o.Normal)); // changing the value after innerRim changes how saturated the 'shadow' of the ice is (keep at 2 to have a better effect if transparent)
		o.Albedo = TopColour * pow(innerRim, 0.7)*lerp(BottomColour, TopColour, localPos.y); // disabling this makes the gradient surface effect turn black
	}
	
	ENDCG

	}

		Fallback "Diffuse"
}
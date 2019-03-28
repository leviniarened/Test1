Shader "VertexColor"
{
	Properties
	{
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"}
		Cull Back
		CGPROGRAM
		#pragma surface surf BlinnPhong
		struct Input
		{
			float4 vertexColor : COLOR;
		};

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Albedo = i.vertexColor.rgb;
			o.Alpha = i.vertexColor.a;
		}
		ENDCG
	}
	Fallback "Diffuse"
}
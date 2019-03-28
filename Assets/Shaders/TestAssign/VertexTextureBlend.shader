Shader "VertexTextureBlend"
{
	Properties
	{
		_SpecColor("Specular Color",Color)=(1,1,1,1)
		_Texture1("Texture1", 2D) = "white" {}
		_Texture2("Texture2", 2D) = "white" {}
		_Texture3("Texture3", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"}
		Cull Back
		CGPROGRAM
		#pragma surface surf BlinnPhong
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _Texture1;
		uniform sampler2D _Texture2;
		uniform sampler2D _Texture3;

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv = i.uv_texcoord;
			float3 t1 = tex2D(_Texture1, uv).rgb;
			float3 t2 = tex2D(_Texture2, uv).rgb;
			float3 t3 = tex2D(_Texture3, uv).rgb;
			float3 l1 = lerp( t1, t2 , i.vertexColor.r);
			float3 result = lerp( l1 , t3 , i.vertexColor.g);
			o.Albedo = result;
			o.Alpha = 1;
		}
		ENDCG
	}
	Fallback "Diffuse"
}
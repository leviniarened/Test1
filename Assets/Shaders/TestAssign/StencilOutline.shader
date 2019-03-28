Shader "Tower" {

	Properties{
		[NoScaleOffset] _MainTex("Texture", 2D) = "white" {}
		_Outline("Outline Length", Range(0.0, 0.01)) = 0.001
		_OutlineColor("Outline Color", Color) = (0.2, 0.2, 0.2, 1.0)
	}

		
		SubShader{

			Tags {
				"RenderType" = "Opaque"
			}
			LOD 200
		Pass {

			Tags{"LightMode" = "ForwardBase"}


			Stencil {
				Ref 128
				Pass replace
				ZFail Replace
			}

			CGPROGRAM
			#pragma multi_compile_fog
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			// compile shader into multiple variants, with and without shadows
			// (we don't care about any lightmaps yet, so skip these variants)
			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
			// shadow helper functions and macros
			#include "AutoLight.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				SHADOW_COORDS(1) // put shadows data into TEXCOORD1
				fixed3 diff : COLOR0;
				fixed3 ambient : COLOR1;
				float4 pos : SV_POSITION;
				UNITY_FOG_COORDS(2)
			};
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
				o.diff = nl * _LightColor0.rgb;
				o.ambient = ShadeSH9(half4(worldNormal,1));

				TRANSFER_SHADOW(o)
				UNITY_TRANSFER_FOG(o, o.pos);
				return o;
			}

			sampler2D _MainTex;

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				fixed shadow = SHADOW_ATTENUATION(i);

				fixed3 lighting = i.diff * shadow + i.ambient;
				col.rgb *= lighting;

				UNITY_APPLY_FOG(i.fogCoord, col);

				return col;
			}
			ENDCG
		}

		
			
		Pass {//outline pass
			
			Stencil {
				Ref 128
				Comp NotEqual
			}

			Cull Off
			ZTest Greater

			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag

			float _Outline;
			float4 _OutlineColor;

			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 color : COLOR;
			};

			v2f vert(appdata v) {

				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				float3 norm = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				float2 offset = TransformViewToProjection(norm.xy);

				o.pos.xy += offset * _Outline;
				o.color = _OutlineColor;
				return o;
			}

			half4 frag(v2f i) : COLOR {
				return _OutlineColor;
			}

			ENDCG
		}

		}
		FallBack "Diffuse"
}
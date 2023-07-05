// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/PrePixelHalfLambert"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {

            Tags
            {
                "LightModel"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float3 _Diffuse;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };


            v2f vert(appdata appdata)
            {
                v2f v2f;

                v2f.vertex = UnityObjectToClipPos(appdata.vertex);

                //获取Model的法线，并将物体坐标空间转为世界坐标空间
                v2f.normal = mul(appdata.normal, (float3x3)unity_ObjectToWorld);

                return v2f;
            }

            fixed4 frag(v2f v2f) : SV_Target
            {
                //获取环境光
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //获取物体的法线，并归一化
                float3 worldNormal = normalize(v2f.normal);

                //获取光源的方向，并归一化
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                //计算漫反射（半兰伯特光照）
                fixed3 halfLambert=dot(worldNormal, lightDir)*0.5+0.5;
                
                float3 color = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

                return fixed4(ambient + color, 1);
            }
            ENDCG
        }
    }
}
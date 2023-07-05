Shader "Unlit/TextPreVertexShader"
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
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert;
            #pragma fragment frag;

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float3 _Diffuse;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 vertex:SV_POSITION;
                fixed4 color:Color;
            };

            v2f vert(a2v a2v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(a2v.vertex);

                //获取环境光
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //获取模型的世界法线
                float3 objectNormal = normalize(mul(a2v.normal, (float3x3)UNITY_MATRIX_MVP));//这里错误使用UNITY_MATRIX_MVP，应该使用unity_ObjectToWorld

                //获取光线方向
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                //计算漫反射
                //阴影部分由lightDir,objectNormal控制
                //LightColor、Diffuse控制Model的着色部分
                float3 color = _LightColor0.rgb * _Diffuse * saturate(dot(lightDir,objectNormal));

                o.color = fixed4(ambient + color, 1);

                return o; 
            }

            fixed4 frag(v2f v2f):SV_Target
            {
                return v2f.color;
            }
            ENDCG
        }
    }
}
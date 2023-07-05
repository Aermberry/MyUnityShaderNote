Shader "TextBilnn-Phong/DiffusePixelLevel"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
    }
    SubShader
    {

        Pass
        {

            Tags
            {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"


            float3 _Diffuse;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
            };


            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            v2f vert(a2v a2v)
            {
                v2f o;

                //将模型的顶点坐标转换为剪裁坐标
                o.vertex = mul(unity_MatrixMVP, a2v.vertex);

                //将模型坐标的法线转为时间坐标的下的法线
                o.normal = mul(a2v.normal, (float3x3)unity_ObjectToWorld);

                return o;
            }

            fixed4 frag(v2f v2f):SV_Target
            {
                //获取环境光
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //世界坐标下的法线归一化
                float3 worldNormal = normalize(v2f.normal);

                //光线的方向归一化
                float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                // 漫反射
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

                float3 color = ambient.rgb + diffuse.rgb;

                return float4(color, 1);
            }
            ENDCG

        }

    }

    Fallback "Diffuse"
}
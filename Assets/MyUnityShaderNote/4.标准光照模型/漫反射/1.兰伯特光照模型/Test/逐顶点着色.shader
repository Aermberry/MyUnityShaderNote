// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TextBilnn-Phong/DiffuseVertexLevel"
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
                "LightModel"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            v2f vert(a2v a)
            {
                v2f o;

                //获取环境光
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //获取顶点，从模型坐标空间转换为剪裁坐标空间
                o.vertex = UnityObjectToClipPos(a.vertex);

                //获取模型坐标下的法线，并转换为世界坐标下的法线
                float3 worldNormal = normalize(mul(a.normal, (float3x3)unity_ObjectToWorld));

                //获取光线的方向，将光线的方向从模型坐标转换为世界坐标
                float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                //计算漫反射
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

                fixed3 color = ambient.rgb + diffuse;

                o.color = fixed4(color, 1);

                return o;
            }

            fixed4 frag(v2f v):SV_Target
            {
                return v.color;
            }
            ENDCG
        }


    }


}
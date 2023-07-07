Shader "Unlit/SpeccularVertexShader"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
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
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float3 _Diffuse;
            float _Gloss;
            float3 _Specular;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color:COLOR;
            };


            v2f vert(appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);

                //获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //获取Model的法线，将物体坐标系转换为世界坐标系
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                //获取物体受到光线照射的方向，将物体坐标系转换为世界坐标系
                //这里光源方向是由交点到光源的位置
                fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 lamber = saturate(dot(worldNormal, worldLightDirection));

                fixed3 diffuseColor = _LightColor0.rgb * _Diffuse.rgb * lamber;

                //高光反射运算
                
                //计算反射角方向
                //Cg的reflect函数规定入射方向要求是由光源位置到交点位置，因此这里的worldLightDirection需要取反方向
                fixed3 reflectDir = normalize(reflect(-worldLightDirection, worldNormal));
                
                //计算视角方向
                fixed3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
                
                //高光反射
                //_Gloss控制高光的区域的大小
                //pow(x,y) 指数幂函数,x：底数,y:指数
                fixed3 specular = pow(
                    saturate(dot(reflectDir, viewDirection)), _Gloss);
                fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * specular;

                fixed4 color = fixed4(ambient + diffuseColor+specularColor , 1);

                o.color = color;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }

    Fallback "Specular"
}
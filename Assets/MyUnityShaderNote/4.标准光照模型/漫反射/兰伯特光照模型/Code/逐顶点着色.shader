// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Bilnn-Phong/DiffuseVertexLevel"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
    }
    SubShader
    {
       
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

            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            fixed4 _Diffuse;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                fixed3 color: COLOR;
                float4 vertex : SV_POSITION;
            };


            v2f vert(appdata v)
            {
                v2f o;

                //把顶点的坐标空间从模型空间转换为剪裁空间
                o.vertex = UnityObjectToClipPos(v.vertex);

                //获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //获取顶点的法线并从当前的模型坐标空间转换为与光源一致的世界坐标空间
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                //获取光源的方向并由模型坐标空间转换为世界坐标空间
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                //计算漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldLight, worldNormal));

                o.color.rgb = ambient + diffuse;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color = fixed4(i.color, 1.0);

                return color;
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
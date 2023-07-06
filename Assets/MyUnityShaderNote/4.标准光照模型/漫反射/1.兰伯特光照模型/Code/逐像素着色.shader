// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Bilnn-Phong/DiffusePixelLevel"
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
                "LightMode"="ForwardBase"
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
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
            };


            v2f vert(appdata v)
            {
                v2f o;

                //把顶点的坐标空间从模型空间转换为剪裁空间
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //获取顶点的法线并从当前的模型坐标空间转换为与光源一致的世界坐标空间
                fixed3 worldNormal = normalize(i.worldNormal);

                //获取光源的方向并由模型坐标空间转换为世界坐标空间
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);


                //计算漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldLight, worldNormal));

                fixed3 color = ambient + diffuse;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
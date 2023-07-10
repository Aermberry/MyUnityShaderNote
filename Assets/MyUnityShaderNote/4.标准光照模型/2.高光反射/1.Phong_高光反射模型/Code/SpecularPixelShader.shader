Shader "Unlit/SpecularPixelShader"
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

            struct appdata
            {
                float4 vertex : POSITION;
                fixed3 normal :NORMAL;
            };

            struct v2f
            {
                float4 vertex :SV_POSITION;
                fixed3 worldNormal :TEXCOORD0;
                fixed3 worldVertexPosition :TEXCOORD1;
            };

            fixed3 _Diffuse;
            fixed3 _Specular;
            float _Gloss;

            v2f vert(appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.worldVertexPosition = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //漫反射
                //获取世界坐标下的光源方向
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //Lambert Mode
                fixed3 lambert = saturate(dot(worldLightDir, i.worldNormal));
                fixed3 diffuseColor = _LightColor0.rgb * _Diffuse.rgb * lambert;

                //高光反射
                //反射角

                fixed3 reflectDir = normalize(reflect(-_WorldSpaceLightPos0.xyz, i.worldNormal));
                //视角
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldVertexPosition.xyz);
                //Specular Mode
                fixed3 specular = pow(max(0,dot(reflectDir, viewDir)), _Gloss);
                fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * specular;


                fixed4 color = fixed4(ambient + diffuseColor+specularColor, 1);

                return color;
            }
            ENDCG
        }
    }
}
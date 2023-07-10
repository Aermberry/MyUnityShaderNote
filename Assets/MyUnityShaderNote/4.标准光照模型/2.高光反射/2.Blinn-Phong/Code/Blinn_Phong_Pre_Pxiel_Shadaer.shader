Shader "Unlit/Blinn_Phong_Pre_Pxiel_Shadaer"
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

            fixed3 _Diffuse;
            fixed3 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                fixed3 normal:NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed3 worldNormal:TEXCOORD0;
                fixed3 worldVertexPosition:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.worldVertexPosition= mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //漫反射
                //获取Model的法线，将物体坐标转换为世界坐标
                fixed3 worldNormal = normalize(i.worldNormal);
                //获取光源的方向，将物体坐标转换为世界坐标
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //计算Lambert
                fixed3 lambert = saturate(dot(worldLightDir, worldNormal));
                fixed3 diffuseColor = _LightColor0.rgb * _Diffuse.rgb * lambert;

                //高光反射
                //获取视口方向，将物体坐标转换为世界坐标
                fixed3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz-i.worldVertexPosition.xyz);                                                                                                                                                                                                                                                                 
                //half direction
                fixed3 halfDir=normalize(worldViewDir+worldLightDir) ;
                //高光计算
                fixed3 specular=pow(max(0,dot(worldNormal,halfDir)),_Gloss);
                fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * specular;

                fixed4 color = fixed4(ambient + diffuseColor + specularColor, 1);

                return color;
            }
            ENDCG
        }
    }
}
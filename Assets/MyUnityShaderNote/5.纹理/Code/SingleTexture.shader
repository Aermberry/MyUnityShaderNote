Shader "Unlit/SingleTexture"
{
    Properties
    {
        _Color("Color Tint",Color)=(1,1,1,1)
        _MainTex("Main Tex",2D)="White"{}
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,256))=20.0
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

            fixed4 _Color;
            sampler2D _MainTex;
            //在Unity，我们需要使用纹理名_ST的方式来声明某个纹理的属性，ST是缩放（scale）和平移（translation）的缩写。
            //_MainTex_SV可以让我们得到该纹理的缩放和平移（偏移）值，_MainTex_ST.xy存储的是缩放值，而_MainTex_ST.zw存储的是偏移值。
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;


            struct appdata
            {
                float4 vertex : POSITION;
                fixed3 normal: NORMAL;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                fixed3 worldVertexPosition : TEXCOORD1;
                float2 uv:TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);

                //获取Model的法线，转换物体坐标为世界坐标
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //将Model的顶点物体坐标系转换为世界坐标系
                o.worldVertexPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
                //对当前的纹理坐标进行缩放和平移的的运算
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // 获取世界法线,归一化
                float3 worldNormal = normalize(i.worldNormal);
                // 获取世界坐标系的光源方向
                float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                //纹理采样
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                // 获取环境光
                float3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                //漫反射
                float3 lambert = max(0, dot(worldLightDir, worldNormal));
                float3 diffuseColor = _LightColor0.rgb * albedo.rgb * lambert;

                //高光反射
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldVertexPosition));

                //Bline Phong
                fixed3 halfSpecular = normalize(worldViewDir + worldLightDir);
                fixed3 specular = pow(max(0, dot(halfSpecular, worldNormal)), _Gloss);
                fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * specular;


                return fixed4(ambientColor + diffuseColor + specularColor, 1);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
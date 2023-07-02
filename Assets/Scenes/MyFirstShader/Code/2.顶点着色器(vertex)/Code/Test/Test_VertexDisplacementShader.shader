Shader ""
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
        _Texture("Texture",2D)="white"{}
        _VertexController("VertexController",Range(0,1.0))=0
    }

    SubShader
    {

        Tags {}

        LOD 100

        Pass
        {

            CGPROGRAM
            #pragma vertex vert  // 指定顶点着色器函数为vert
            #pragma fragment frag  // 指定片段着色器函数为frag

            #include "UnityCG.cginc"

            float4 _Color;
            sampler2D _Texture;
            float _VertexController;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v a2v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(a2v.vertex);
                o.uv = a2v.uv;

                o.vertex.xyz += normalize(a2v.vertex.xyz)*_VertexController;

                return o;
            }

            fixed4 frag(v2f v2f):SV_Target
            {
                return  tex2D(_Texture, v2f.uv);
            }
            ENDCG

        }
    }
}
Shader"Test/MyFirstShaderTest"
{
    Properties {
        _Color("Color",Color)=(1,1,1,1)
        }

    SubShader
    {
        Tags {}

        LOD 100
        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vert:POSITION;
            };

            struct v2f
            {
                float4 vert:SV_POSITION;
            };

            float4 _Color;
            
            v2f vert(appdata appdata)
            {
                v2f o;

                o.vert = UnityObjectToClipPos(appdata.vert);

                return o;
            }

            fixed4 frag(v2f v2f):SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
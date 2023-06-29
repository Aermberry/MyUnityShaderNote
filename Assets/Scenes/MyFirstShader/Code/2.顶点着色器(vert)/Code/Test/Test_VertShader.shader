Shader "Custom/VertexAnimation" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Speed", Range(0, 5)) = 1
        _Amplitude ("Amplitude", Range(0, 5)) = 1
    }

    SubShader {
        Tags {"Queue"="Transparent" "RenderType"="Transparent"}
        LOD 100

        CGPROGRAM
        #pragma surface surf Lambert vertex:vert

        sampler2D _MainTex;
        float _Speed;
        float _Amplitude;

        struct Input {
            float2 uv_MainTex;
        };

        void vert (inout appdata_full v) {
            float offset = _Amplitude * sin(_Speed * v.vertex.y + _Time.y);
            v.vertex.xyz += v.normal * offset;
        }

        void surf (Input IN, inout SurfaceOutput o) {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
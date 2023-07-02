Shader "VertexDisplacementShader" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}  // 主纹理属性，用于接收一个2D纹理
        _DisplacementAmount ("Displacement Amount", Range(0.0, 1.0)) = 0.1  // 位移量属性，用于控制顶点位移的强度
    }
    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex vert  // 指定顶点着色器函数为vert
            #pragma fragment frag  // 指定片段着色器函数为frag
            #include "UnityCG.cginc"  // 引入Unity内置的CG库
            
            // 顶点结构体，包含顶点位置和纹理坐标信息
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            // 输出结构体，包含纹理坐标和变换后的顶点位置信息
            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            sampler2D _MainTex;  // 主纹理变量
            float _DisplacementAmount;  // 位移量变量
            
            // 顶点着色器函数，接收appdata结构体作为输入，返回v2f结构体
            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);  // 将顶点位置进行变换，转换到裁剪空间
                o.uv = v.uv;  // 传递纹理坐标
                
                // 执行顶点位移
                o.vertex.xyz += normalize(v.vertex.xyz) * _DisplacementAmount;
                
                return o;
            }
            
            // 片段着色器函数，接收v2f结构体作为输入，返回fixed4类型的颜色
            fixed4 frag(v2f i) : SV_Target {
                return tex2D(_MainTex, i.uv);  // 从主纹理中获取颜色并返回
            }
            
            ENDCG
        }
    }
}

// 定义Shader的名称，这将在Unity的Shader下拉菜单中显示
Shader "Custom/MyFirstShader"
{
    // 定义Shader的属性，这些属性将在材质的Inspector窗口中显示
    Properties
    {
        // 定义一个颜色属性，名为"Color"，默认值为白色（1,1,1,1）
        _Color ("Color", Color) = (1,1,1,1)
    }
    // 定义SubShader，如果有多个SubShader，Unity将选择第一个能在当前硬件上运行的SubShader
    SubShader
    {
        // 定义渲染标签，"RenderType"="Opaque"表示这是一个不透明的Shader
        Tags { "RenderType"="Opaque" }
        // 定义LOD值，如果有多个SubShader，Unity将选择LOD值最接近的SubShader
        LOD 100

        // 定义渲染Pass，一个Shader可以有多个Pass，每个Pass都会渲染一次物体
        Pass
        {
            // 开始CG程序，CG是一种高级的Shader编程语言
            CGPROGRAM
            // 指定顶点Shader和片元Shader的函数名
            #pragma vertex vert
            #pragma fragment frag

            // 包含Unity的CG库，这个库包含了许多有用的函数
            #include "UnityCG.cginc"

            // 定义输入到顶点Shader的数据结构
            struct appdata
            {
                // 顶点的位置，POSITION是一个语义，表示这个变量是顶点的位置
                float4 vertex : POSITION;
            };

            // 定义从顶点Shader输出到片元Shader的数据结构
            struct v2f
            {
                // 顶点的位置，SV_POSITION是一个语义，表示这个变量是裁剪空间的位置
                float4 vertex : SV_POSITION;
            };

            // 定义一个全局变量，表示颜色
            fixed4 _Color;

            // 顶点Shader函数，输入一个appdata，输出一个v2f
            v2f vert (appdata v)
            {
                v2f o;
                // 将顶点的位置从对象空间转换到裁剪空间
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            // 片元Shader函数，输入一个v2f，输出一个颜色
            fixed4 frag (v2f i) : SV_Target
            {
                // 返回颜色，这意味着每个像素都将被渲染为这个颜色
                return _Color;
            }
            // 结束CG程序
            ENDCG
        }
    }
}

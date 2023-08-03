// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "NormalMapInTangentSpace"
{
	Properties
	{
		_Color("_Color", Color) = (0.9150943,0.06474723,0.06474723,0)
		_MainTex("Main Tex", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "white" {}
		_Specular("_Specular", Color) = (0,0,0,0)
		_BumpScale("_BumpScale", Float) = 1
		_Gloss("_Gloss", Range( 8 , 256)) = 8
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Color;
		uniform float4 _Specular;
		uniform float _BumpScale;
		uniform sampler2D _NormalMap;
		uniform float _Gloss;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float4 ase_vertex4Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 ase_objectlightDir = normalize( ObjSpaceLightDir( ase_vertex4Pos ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float4 ase_vertexTangent = mul( unity_WorldToObject, float4( ase_worldTangent, 0 ) );
			ase_vertexTangent = normalize( ase_vertexTangent );
			float3 normalizeResult21 = normalize( ase_vertexTangent.xyz );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			ase_vertexNormal = normalize( ase_vertexNormal );
			float3 normalizeResult19 = normalize( ase_vertexNormal );
			float3 normalizeResult32 = normalize( mul( ase_objectlightDir, float3x3(ase_vertexTangent.xyz, cross( normalizeResult21 , normalizeResult19 ), ase_vertexNormal) ) );
			float3 objectSpaceViewDir30 = ObjSpaceViewDir( float4( 0,0,0,1 ) );
			float3 normalizeResult33 = normalize( mul( float3x3(ase_vertexTangent.xyz, cross( normalizeResult21 , normalizeResult19 ), ase_vertexNormal), objectSpaceViewDir30 ) );
			float dotResult106 = dot( normalizeResult32 , normalizeResult33 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode4 = tex2D( _MainTex, uv_MainTex );
			float4 appendResult51 = (float4(tex2DNode4.r , tex2DNode4.g , tex2DNode4.b , 0.0));
			float4 appendResult95 = (float4(_Color.r , _Color.g , _Color.b , 0.0));
			float4 temp_output_96_0 = ( appendResult51 * appendResult95 );
			float4 appendResult111 = (float4(_Specular.r , _Specular.g , _Specular.b , 0.0));
			float3 normalizeResult118 = normalize( ( normalizeResult32 + normalizeResult33 ) );
			float3 localUnpackNormal79 = UnpackNormal( tex2D( _NormalMap, uv_MainTex ) );
			float4 appendResult82 = (float4(localUnpackNormal79.x , localUnpackNormal79.y , 0.0 , 0.0));
			float dotResult88 = dot( appendResult82 , appendResult82 );
			float4 appendResult92 = (float4(( _BumpScale * appendResult82 ).xy , sqrt( ( (float)1 - saturate( dotResult88 ) ) ) , 0.0));
			float dotResult117 = dot( float4( normalizeResult118 , 0.0 ) , appendResult92 );
			float4 appendResult123 = (float4(( ( ( max( (float)0 , dotResult106 ) * ( float4( ase_lightColor.rgb , 0.0 ) * temp_output_96_0 ) ) + ( temp_output_96_0 * UNITY_LIGHTMODEL_AMBIENT ) ) + ( ( float4( ase_lightColor.rgb , 0.0 ) * appendResult111 ) * pow( max( (float)0 , dotResult117 ) , _Gloss ) ) ).xyz , (float)1));
			o.Emission = appendResult123.xyz;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;120;133.5719,5360.35;Inherit;False;4586.703;2480.378;Specular;13;118;119;117;115;116;114;113;112;110;111;109;108;90;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;107;125.8866,1881.272;Inherit;False;3403.463;1589.165;Diffuse;7;103;101;106;104;102;105;93;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;100;146.5987,3585.295;Inherit;False;2000.912;408.8448;ambient;2;99;98;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;97;147.7795,4251.52;Inherit;False;1454.151;673.0718;albedo;6;51;4;89;95;94;96;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;93;175.8864,1931.272;Inherit;False;2114.541;1071.127;LightDir和ViewDir;8;27;29;31;30;28;32;33;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;90;183.5718,6688.791;Inherit;False;2887.297;1066.27;获取法线;12;92;81;80;84;86;85;88;87;16;82;79;5;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;27;225.8865,2215.903;Inherit;False;1046.9;588.2996;副切线;5;17;18;19;21;20;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ObjSpaceLightDirHlpNode;29;1445.076,1981.271;Inherit;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;18;274.8861,2510.905;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;105;2486.752,2074.644;Inherit;False;Constant;_Int1;Int 1;2;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;1888.993,3694.837;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;98;210.3861,3723.56;Inherit;False;UNITY_LIGHTMODEL_AMBIENT;0;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;1752.189,2575.404;Inherit;False;2;2;0;FLOAT3x3;0,0,0,0,0,1,1,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjSpaceViewDirHlpNode;30;1431.193,2748.401;Inherit;False;1;0;FLOAT4;0,0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;1766.824,2221.834;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3x3;0,0,0,0,0,1,1,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;32;2022.428,2223.178;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;33;2021.127,2575.48;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;21;605.9842,2359.204;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;19;612.2842,2598.206;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;17;1054.785,2506.306;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.MatrixFromVectors;26;1371.844,2267.065;Inherit;False;FLOAT3x3;True;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;1366.934,4513.087;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;51;1012.263,4330.574;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;4;566.68,4301.521;Inherit;True;Property;_MainTex;Main Tex;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;89;197.7799,4323.962;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;95;1020.357,4670.6;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;2943.749,3206.411;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;104;2785.951,2245.196;Inherit;False;2;0;INT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TangentVertexDataNode;20;279.8866,2276.904;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;106;2477.323,2428.934;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;101;2433.525,2968.318;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;5;575.5845,7144.295;Inherit;True;Property;_NormalMap;Normal Map;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnpackScaleNormalNode;79;1024.222,7149.008;Inherit;False;Tangent;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;82;1345.341,7172.788;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;233.5708,7166.794;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;87;1946.665,7478.954;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;88;1721.66,7478.954;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;86;2196.67,7335.955;Inherit;False;2;0;INT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;84;2458.474,7336.255;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;1704.41,6860.86;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;92;2826.189,6860.027;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LightColorNode;108;3755.451,5471.53;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;109;3511.892,5774.294;Inherit;False;Property;_Specular;_Specular;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;111;3795.191,5803.27;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;4141.194,5640.27;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;4482.195,5941.27;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PowerNode;113;4156.594,6370.469;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;116;3840.592,6262.469;Inherit;False;2;0;INT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;115;3531.591,6154.469;Inherit;False;Constant;_Int2;Int 2;4;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.DotProductOpNode;117;3498.591,6469.469;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;5470.689,3655.758;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;122;6396.338,5080.893;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;123;6828.54,5310.822;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.IntNode;124;6424.631,5530.892;Inherit;False;Constant;_Int3;Int 3;4;0;Create;True;0;0;0;False;0;False;1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;3290.471,2626.096;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;2;7347.609,5259.94;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;NormalMapInTangentSpace;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;80;1380.43,6740.742;Inherit;False;Property;_BumpScale;_BumpScale;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;94;644.7745,4641.653;Inherit;False;Property;_Color;_Color;0;0;Create;True;0;0;0;False;0;False;0.9150943,0.06474723,0.06474723,0;0.9150943,0.06474723,0.06474723,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;85;1936.664,7210.957;Inherit;True;Constant;_Int0;Int 0;2;0;Create;True;0;0;0;False;0;False;1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;119;2410.355,6054.35;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;118;2758.315,6054.901;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;114;3769.591,6604.469;Inherit;False;Property;_Gloss;_Gloss;5;0;Create;True;0;0;0;False;0;False;8;20;8;256;0;1;FLOAT;0
WireConnection;99;0;96;0
WireConnection;99;1;98;0
WireConnection;31;0;26;0
WireConnection;31;1;30;0
WireConnection;28;0;29;0
WireConnection;28;1;26;0
WireConnection;32;0;28;0
WireConnection;33;0;31;0
WireConnection;21;0;20;0
WireConnection;19;0;18;0
WireConnection;17;0;21;0
WireConnection;17;1;19;0
WireConnection;26;0;20;0
WireConnection;26;1;17;0
WireConnection;26;2;18;0
WireConnection;96;0;51;0
WireConnection;96;1;95;0
WireConnection;51;0;4;1
WireConnection;51;1;4;2
WireConnection;51;2;4;3
WireConnection;4;1;89;0
WireConnection;95;0;94;1
WireConnection;95;1;94;2
WireConnection;95;2;94;3
WireConnection;102;0;101;1
WireConnection;102;1;96;0
WireConnection;104;0;105;0
WireConnection;104;1;106;0
WireConnection;106;0;32;0
WireConnection;106;1;33;0
WireConnection;5;1;16;0
WireConnection;79;0;5;0
WireConnection;82;0;79;1
WireConnection;82;1;79;2
WireConnection;87;0;88;0
WireConnection;88;0;82;0
WireConnection;88;1;82;0
WireConnection;86;0;85;0
WireConnection;86;1;87;0
WireConnection;84;0;86;0
WireConnection;81;0;80;0
WireConnection;81;1;82;0
WireConnection;92;0;81;0
WireConnection;92;2;84;0
WireConnection;111;0;109;1
WireConnection;111;1;109;2
WireConnection;111;2;109;3
WireConnection;110;0;108;1
WireConnection;110;1;111;0
WireConnection;112;0;110;0
WireConnection;112;1;113;0
WireConnection;113;0;116;0
WireConnection;113;1;114;0
WireConnection;116;0;115;0
WireConnection;116;1;117;0
WireConnection;117;0;118;0
WireConnection;117;1;92;0
WireConnection;121;0;103;0
WireConnection;121;1;99;0
WireConnection;122;0;121;0
WireConnection;122;1;112;0
WireConnection;123;0;122;0
WireConnection;123;3;124;0
WireConnection;103;0;104;0
WireConnection;103;1;102;0
WireConnection;2;2;123;0
WireConnection;119;0;32;0
WireConnection;119;1;33;0
WireConnection;118;0;119;0
ASEEND*/
//CHKSM=4694C67B04E3F1D805B5EC579D4DB53B72FC8D24
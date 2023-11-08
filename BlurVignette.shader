Shader "Custom/VignetteBlur"
{
    Properties
    {
        _BlitTexture ("Texture", 2D) = "white" {}
        _BlurRadius ("Blur Radius", Range(0, 15)) = 2.0
        _VignetteSize ("Vignette Size", Range(0, 1)) = 0.5
        _VignetteFeathering ("Vignette Feathering", Range(0, 1)) = 0.2
        _Intensity ("Intensity", Range(0, 5)) = 1.0
        _ShowOnlyMask ("Show Only Mask", Range(0, 1)) = 0.0
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _BlitTexture;
            float4 _BlitTexture_ST;
            float _BlurRadius;
            float _VignetteSize;
            float _VignetteFeathering;
            float _Intensity;
            float _ShowOnlyMask;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _BlitTexture_ST.xy + _BlitTexture_ST.zw;
                return o;
            }

            half4 BoxBlur(sampler2D tex, float2 uv)
            {
                half4 sum = half4(0, 0, 0, 0);
                float blurAmount = _BlurRadius / 10.0;

                for (int i = -5; i <= 5; i++)
                {
                    for (int j = -5; j <= 5; j++)
                    {
                        float2 sampleUV = uv + float2(i, j) * blurAmount;
                        sum += tex2D(tex, sampleUV);
                    }
                }

                return sum / 121; // 11x11 box blur kernel
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 baseColor = tex2D(_BlitTexture, i.uv);

                // Calculate the distance to the center
                float2 vignetteCenter = float2(0.5, 0.5);
                float vignetteDistance = length(i.uv - vignetteCenter);

                // Create the vignette effect
                float vignette = 1.0 - smoothstep(_VignetteSize, _VignetteSize - _VignetteFeathering, vignetteDistance);

                // Apply the box blur
                half4 blurred = BoxBlur(_BlitTexture, i.uv);

                // Show only the mask if _ShowOnlyMask is enabled
                if (_ShowOnlyMask > 0.0)
                {
                    return float4(vignette, vignette, vignette, 1.0);
                }

                // Blend the blurred image with the vignette
                half4 finalColor = lerp(baseColor, blurred, vignette);

                return lerp(baseColor, finalColor, _Intensity);
            }
            ENDCG
        }
    }
}

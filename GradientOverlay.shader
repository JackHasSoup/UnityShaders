Shader "Custom/GradientOverlay"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TopLeftColor ("Top Left Color", Color) = (1, 1, 1, 1)
        _BottomRightColor ("Bottom Right Color", Color) = (0, 0, 0, 1)
        _Opacity ("Opacity", Range(0, 1)) = 1
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" }

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

            sampler2D _MainTex;
            float4 _TopLeftColor;
            float4 _BottomRightColor;
            float _Opacity;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 texColor = tex2D(_MainTex, i.uv);

                // Calculate the gradient colors based on screen position
                half4 topLeftGradient = lerp(_TopLeftColor, texColor, i.uv.y);
                half4 bottomRightGradient = lerp(_BottomRightColor, texColor, 1 - i.uv.y);

                // Combine the two gradients
                half4 gradient = lerp(topLeftGradient, bottomRightGradient, i.uv.x);

                // Interpolate between the original texture and the gradient based on opacity
                half4 finalColor = lerp(texColor, gradient, _Opacity);

                return finalColor;
            }
            ENDCG
        }
    }
}

//
//  ImageShader.metal
//  ComparisonOfMetalAndOpenCV
//
//  Created by kotetu on 2018/09/01.
//  Copyright © 2018年 kotetu. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

constant float kThreshold = 0.5;

// https://docs-assets.developer.apple.com/published/69d0d33d65/HelloCompute.zip より
constant float3 kRec709Luma = float3(0.2126, 0.7152, 0.0722);

kernel void threshold(texture2d<float, access::read> inTexture [[ texture(0) ]],
                      texture2d<float, access::write> outTexture [[ texture(1) ]],
                      uint2 gid [[ thread_position_in_grid ]]) {
    float4 inColor = inTexture.read(gid);
    float gray = dot(inColor.rgb, kRec709Luma);
    if (gray >= kThreshold) {
        outTexture.write(float4(1, 1, 1, 1), gid);
    } else {
        outTexture.write(float4(0, 0, 0, 1), gid);
    }
}

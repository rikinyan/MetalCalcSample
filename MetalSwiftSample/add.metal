//
//  add.metal
//  MetalSwiftSample
//
//  Created by 力石優武 on 2025/04/06.
//

#include <metal_stdlib>
using namespace metal;

kernel void add_arrays(device const float* inA,
                       device const float* inB,
                       device float* result,
                       uint index [[thread_position_in_grid]])
{
    result[index] = inA[index] + inB[index];
}

//
//  main.swift
//  MetalSwiftSample
//
//  Created by 力石優武 on 2025/04/06.
//

import Foundation
import Metal

guard let gpuDevice = MTLCreateSystemDefaultDevice() else {
    throw NSError(domain: "device", code: 1)
}

let intByte = Int.bitWidth / 8
let arrayLength = 10
let bufferLenght = intByte * arrayLength
var bufferA = gpuDevice.makeBuffer(length: bufferLenght, options: .storageModeShared)
var bufferB = gpuDevice.makeBuffer(length: bufferLenght, options: .storageModeShared)
var bufferResult = gpuDevice.makeBuffer(length: bufferLenght, options: .storageModeShared)

for index in 0..<arrayLength {
    let byteOffset = index * intByte
    bufferA?.contents().storeBytes(of: Int.random(in: 1...10), toByteOffset: byteOffset, as: Int.self)
    bufferB?.contents().storeBytes(of: Int.random(in: 1...10), toByteOffset: byteOffset, as: Int.self)
}

guard let shaderLibrary = gpuDevice.makeDefaultLibrary() else {
    throw NSError(domain: "lib", code: 1)
}

guard let addFunc = shaderLibrary.makeFunction(name: "add_arrays") else {
    throw NSError(domain: "func", code: 1)
}

guard let pipline = try? gpuDevice.makeComputePipelineState(function: addFunc) else {
    throw NSError(domain: "pipline", code: 1)
}

guard let commandQueue = gpuDevice.makeCommandQueue() else {
    throw NSError(domain: "queue", code: 1)
}

guard let commandBuffer = commandQueue.makeCommandBuffer() else {
    throw NSError(domain: "buffer", code: 1)
}

guard let commandEncoder = commandBuffer.makeComputeCommandEncoder() else {
    throw NSError(domain: "encoder", code: 1)
}

commandEncoder.setComputePipelineState(pipline)
commandEncoder.setBuffer(bufferA, offset: 0, index: 0)
commandEncoder.setBuffer(bufferB, offset: 0, index: 1)
commandEncoder.setBuffer(bufferResult, offset: 0, index: 2)

let threadPerGrid = MTLSize(width: arrayLength, height: 1, depth: 1)
var threadGroupSize = pipline.maxTotalThreadsPerThreadgroup

if threadGroupSize > arrayLength {
    threadGroupSize = arrayLength
}

commandEncoder.dispatchThreadgroups(
    threadPerGrid,
    threadsPerThreadgroup: MTLSize(width: threadGroupSize, height: 1, depth: 1)
)

commandEncoder.endEncoding()

commandBuffer.commit()

commandBuffer.waitUntilCompleted()

for index in 0..<arrayLength {
    let byteOffset = index * intByte
    print(
        bufferResult?.contents().load(fromByteOffset: byteOffset, as: Int.self)
    )
}

//
//  MetalShaderDataStore.swift
//  ComparisonOfMetalAndOpneCV
//
//  Created by kotetu on 2018/09/01.
//  Copyright © 2018年 kotetu. All rights reserved.
//

import MetalKit
import MetalPerformanceShaders

final class MetalShaderDataStore {
    
    private let device: MTLDevice!
    private let library: MTLLibrary!
    private let commandQueue: MTLCommandQueue!
    private let textureLoader: MTKTextureLoader!
    
    private var thresholdPipelineState: MTLComputePipelineState? = nil
    
    enum TextureIndex: Int {
        case input = 0
        case output
    }
    
    init?() {
        if !MetalShaderDataStore.isSupportMetal {
            return nil
        }
        
        device = MTLCreateSystemDefaultDevice()
        library = device.makeDefaultLibrary()
        commandQueue = device.makeCommandQueue()
        textureLoader = MTKTextureLoader(device: device)
        
        // MTLComputePipelineStateの生成は1度だけにする
        
        // .metalファイル側に 指定したすすシェーダの定義が無いとmakeFunctionの結果がnilになる
        if let thresholdFunction = library.makeFunction(name: "threshold"),
            let pipeline = try? device.makeComputePipelineState(function: thresholdFunction) {
            thresholdPipelineState = pipeline
        }
    }
    
    static var isSupportMetal: Bool {
        return MTLCreateSystemDefaultDevice() != nil
    }
    
}

extension MetalShaderDataStore: ImageProcessor {
    
    // TODO: 現在シェーダ側に値を渡す処理が実装されていないため、threasholdとmaxValueは指定しても機能しない
    func threshold(sourceImage: UIImage, threashold: Int, maxValue: Int) -> UIImage? {
        guard
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let sourceCIImage = CIImage(image: sourceImage),
            let inputTexture = createTexture(image: sourceCIImage, commandBuffer: commandBuffer),
            let encoder = commandBuffer.makeComputeCommandEncoder(),
            let pipelineState = thresholdPipelineState else{
                return nil
        }
        
        // TODO: 外部から指定した閾値を使って二値化できるようにする
        let normalizedThreashold = ((1 / Float(maxValue + 1)) * Float(threashold))
        
        encoder.setComputePipelineState(pipelineState)
        
        // setTexture　は　dispatchThreadgroups　より先に実行しないといけない
        encoder.setTexture(inputTexture, index: TextureIndex.input.rawValue)
        encoder.setTexture(inputTexture, index: TextureIndex.output.rawValue)
        
        // スレッドグループサイズは調整可能
        // dispatchThreadsはiOS11以降でしか使えないので注意
        // 感覚的には 5x5 < 32x32 ≒ 3x3 の順で速い用に見える
        let threadgroupSize = MTLSize(width: 5, height: 5, depth: 1)
        encoder.dispatchThreads(MTLSize(width: Int(sourceCIImage.extent.width), height: Int(sourceCIImage.extent.height), depth: 1),
                                threadsPerThreadgroup: threadgroupSize)
        
        encoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let context = CIContext(mtlDevice: device)
        guard let outputCIImage = CIImage(mtlTexture: inputTexture, options: nil),
            let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
                return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func blur(sourceImage: UIImage, width: Int, height: Int, scale: Double) -> UIImage? {
        // inputTextureで出力も受け取るとうまくいかない
        guard
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let sourceCIImage = CIImage(image: sourceImage),
            let inputTexture = createTexture(image: sourceCIImage, commandBuffer: commandBuffer),
            var outputTexture = createTexture(width: Int(sourceCIImage.extent.width * CGFloat(scale)), height: Int(sourceCIImage.extent.height * CGFloat(scale))) else{
                return nil
        }
        
        // リサイズ
        let lanczosFilter = MPSImageLanczosScale(device: device)
        var transform = MPSScaleTransform(scaleX: scale, scaleY: scale, translateX: 0, translateY: 0)
        _ = withUnsafePointer(to: &transform) { (transformPtr) -> Void in
            lanczosFilter.scaleTransform = transformPtr
            lanczosFilter.encode(commandBuffer: commandBuffer, sourceTexture: inputTexture, destinationTexture: outputTexture)
        }
        
        // ブラー
        // 注意：極端に大きな画像を入力すると、クラッシュする
        let boxBlur = MPSImageBox(device: device, kernelWidth: width, kernelHeight: height)
        _ = withUnsafeMutablePointer(to: &outputTexture) { (texturePtr: UnsafeMutablePointer<MTLTexture>) in
            boxBlur.encode(commandBuffer: commandBuffer, inPlaceTexture: texturePtr, fallbackCopyAllocator: nil)
        }
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let context = CIContext(mtlDevice: device)
        
        guard let outputCIImage = CIImage(mtlTexture: outputTexture, options: nil),
            let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
                return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func gaussianBlur(sourceImage: UIImage, sigma: Float) -> UIImage? {
        // inputTextureで出力も受け取るため、varで定義する
        guard
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let sourceCIImage = CIImage(image: sourceImage),
            var inputTexture = createTexture(image: sourceCIImage, commandBuffer: commandBuffer) else{
                return nil
        }
        
        let gaussianBlurFilter = MPSImageGaussianBlur(device: device, sigma: sigma)
        _ = withUnsafeMutablePointer(to: &inputTexture) { (texturePtr: UnsafeMutablePointer<MTLTexture>) in
            gaussianBlurFilter.encode(commandBuffer: commandBuffer, inPlaceTexture: texturePtr, fallbackCopyAllocator: nil)
        }
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let context = CIContext(mtlDevice: device)
        guard let outputCIImage = CIImage(mtlTexture: inputTexture, options: nil),
            let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
                return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func resize(sourceImage: UIImage, scale: Double) -> UIImage? {
        // inputTextureで出力も受け取るため、varで定義する
        guard
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let sourceCIImage = CIImage(image: sourceImage),
            let inputTexture = createTexture(image: sourceCIImage, commandBuffer: commandBuffer),
            let outputTexture = createTexture(width: Int(sourceCIImage.extent.width * CGFloat(scale)), height: Int(sourceCIImage.extent.height * CGFloat(scale))) else{
                return nil
        }
        
        let lanczosFilter = MPSImageLanczosScale(device: device)
        var transform = MPSScaleTransform(scaleX: scale, scaleY: scale, translateX: 0, translateY: 0)
        _ = withUnsafePointer(to: &transform) { (transformPtr) -> Void in
            lanczosFilter.scaleTransform = transformPtr
            lanczosFilter.encode(commandBuffer: commandBuffer, sourceTexture: inputTexture, destinationTexture: outputTexture)
        }
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let context = CIContext(mtlDevice: device)
        guard let outputCIImage = CIImage(mtlTexture: inputTexture, options: nil),
            let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
                return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
}

private extension MetalShaderDataStore {
    
    func threadGroupCount(threadgroupSize: MTLSize, textureWidth: Int, textureHeight: Int) -> MTLSize {
        let width = threadgroupSize.width
        let height = threadgroupSize.height
        return MTLSize(
            width: (textureWidth + width - 1) / width,
            height: (textureHeight + height - 1) / height,
            depth: 1
        )
    }
    
    func createTexture(image: CIImage, commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        guard let texture = createTexture(rect: image.extent) else {
            return nil
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CIContext(mtlDevice: device)
        context.render(image,
                       to: texture,
                       commandBuffer: commandBuffer,
                       bounds: image.extent,
                       colorSpace: colorSpace)
        
        return texture
    }
    
    func createTexture(rect: CGRect) -> MTLTexture? {
        return createTexture(width: Int(rect.width), height: Int(rect.height))
    }
    
    func createTexture(width: Int, height: Int) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                  width: width,
                                                                  height: height,
                                                                  mipmapped: true)
        descriptor.usage
            = MTLTextureUsage(rawValue: MTLTextureUsage.shaderWrite.rawValue | MTLTextureUsage.shaderRead.rawValue)
        return device.makeTexture(descriptor: descriptor)
    }
    
}

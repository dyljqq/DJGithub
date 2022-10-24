//
//  StackAddressInfo.swift
//  DJMonitor
//
//  Created by jiqinqiang on 2022/10/21.
//

import Foundation

@_silgen_name("swift_demangle")
public func stdlibDemangleImpl(
    mangledName: UnsafePointer<CChar>?,
    mangledNameLength: UInt,
    outputBuffer: UnsafeMutablePointer<CChar>?,
    outputBufferSize: UnsafeMutablePointer<UInt>?,
    flags: UInt32
) -> UnsafeMutablePointer<CChar>?

public struct StackAddressInfo {
  private let info: dl_info
  
  public let address: UInt
  
  public init(address: UInt) {
    self.address = address
    var _info = dl_info()
    dladdr(UnsafeRawPointer(bitPattern: address), &_info)
    self.info = _info
  }
  
  public var image: String {
    if let fname = info.dli_fname,
       let name = String(validatingUTF8: fname),
       let _ = name.range(of: "/", options: .backwards) {
      return (name as NSString).lastPathComponent
    }
    return "???"
  }
  
  public var symbol: String {
    if let dli_sname = info.dli_sname, let sname = String(validatingUTF8: dli_sname) {
      return sname
    } else if let dli_fname = info.dli_fname, let _ = String(validatingUTF8: dli_fname) {
      return self.image
    } else {
      return String(format: "0x%1x", UInt(bitPattern: info.dli_saddr))
    }
  }
  
  public var offset: UInt {
    if let dli_sname = info.dli_sname, let _ = String(validatingUTF8: dli_sname) {
      return UInt(address - UInt(bitPattern: info.dli_saddr))
    } else if let dli_fname = info.dli_fname, let _ = String(validatingUTF8: dli_fname) {
      return UInt(address - UInt(bitPattern: info.dli_fbase))
    } else {
      return 0
    }
  }
  
  public func formattedDescription(index: Int) -> String {
    return self.image.utf8CString.withUnsafeBufferPointer { (imageBuffer: UnsafeBufferPointer<CChar>) -> String in
      let demangleSymbol = self.symbol.utf8CString.withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<CChar>) -> String in
        let namePtr = stdlibDemangleImpl(mangledName: buffer.baseAddress, mangledNameLength: UInt(buffer.count - 1), outputBuffer: nil, outputBufferSize: nil, flags: 0)
        
        let value: String
        if let namePtr = namePtr {
          let name = String(cString: namePtr)
          free(namePtr)
          value = name
        } else {
          value = self.image
        }
        return value
      }
      return String(format: "%-4d%-35s 0x%08lx %@ + %d", index, UInt(bitPattern: imageBuffer.baseAddress), address, demangleSymbol, offset)
    }
  }
}

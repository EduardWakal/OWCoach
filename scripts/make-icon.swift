import AppKit
import CoreGraphics

let size: CGFloat = 1024
let out = CommandLine.arguments[1]
let cs = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(data: nil, width: Int(size), height: Int(size), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!

func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 0xff) / 255, green: CGFloat((hex >> 8) & 0xff) / 255, blue: CGFloat(hex & 0xff) / 255, alpha: a)
}

let bg = CGGradient(colorsSpace: cs, colors: [rgb(0x2a3048), rgb(0x10121c), rgb(0x07080d)] as CFArray, locations: [0, 0.55, 1])!
ctx.drawRadialGradient(bg, startCenter: CGPoint(x: 512, y: 640), startRadius: 0, endCenter: CGPoint(x: 512, y: 512), endRadius: 760, options: [.drawsAfterEndLocation])

let center = CGPoint(x: 512, y: 512)
let orange = CGGradient(colorsSpace: cs, colors: [rgb(0xffc04d), rgb(0xf99e1a), rgb(0xe0620f)] as CFArray, locations: [0, 0.5, 1])!

func strokeGradient(_ path: CGPath, width: CGFloat, cap: CGLineCap = .round, glow: CGFloat = 0) {
    if glow > 0 {
        ctx.saveGState()
        ctx.setShadow(offset: .zero, blur: glow, color: rgb(0xf99e1a, 0.75))
        ctx.addPath(path)
        ctx.setLineWidth(width)
        ctx.setLineCap(cap)
        ctx.setLineJoin(.round)
        ctx.setStrokeColor(rgb(0xf99e1a))
        ctx.strokePath()
        ctx.restoreGState()
    }
    ctx.saveGState()
    ctx.addPath(path)
    ctx.setLineWidth(width)
    ctx.setLineCap(cap)
    ctx.setLineJoin(.round)
    ctx.replacePathWithStrokedPath()
    ctx.clip()
    ctx.drawLinearGradient(orange, start: CGPoint(x: 200, y: 850), end: CGPoint(x: 824, y: 170), options: [])
    ctx.restoreGState()
}

let radius: CGFloat = 330
let gap: CGFloat = 0.30
for i in 0..<4 {
    let mid = CGFloat(i) * .pi / 2 + .pi / 4
    let arc = CGMutablePath()
    arc.addArc(center: center, radius: radius, startAngle: mid - .pi / 4 + gap, endAngle: mid + .pi / 4 - gap, clockwise: false)
    strokeGradient(arc, width: 54, glow: 40)
}

for i in 0..<4 {
    let a = CGFloat(i) * .pi / 2
    let tick = CGMutablePath()
    tick.move(to: CGPoint(x: center.x + cos(a) * (radius - 40), y: center.y + sin(a) * (radius - 40)))
    tick.addLine(to: CGPoint(x: center.x + cos(a) * (radius + 40), y: center.y + sin(a) * (radius + 40)))
    ctx.saveGState()
    ctx.addPath(tick)
    ctx.setLineWidth(22)
    ctx.setLineCap(.round)
    ctx.setStrokeColor(rgb(0xffffff, 0.85))
    ctx.strokePath()
    ctx.restoreGState()
}

let line = CGMutablePath()
line.move(to: CGPoint(x: 330, y: 400))
line.addLine(to: CGPoint(x: 450, y: 520))
line.addLine(to: CGPoint(x: 540, y: 450))
line.addLine(to: CGPoint(x: 680, y: 620))
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -6), blur: 30, color: rgb(0x000000, 0.6))
ctx.addPath(line)
ctx.setLineWidth(58)
ctx.setLineCap(.round)
ctx.setLineJoin(.round)
ctx.setStrokeColor(rgb(0xffffff))
ctx.strokePath()
ctx.restoreGState()

let head = CGMutablePath()
let tip = CGPoint(x: 728, y: 678)
head.move(to: tip)
head.addLine(to: CGPoint(x: 600, y: 664))
head.addLine(to: CGPoint(x: 714, y: 550))
head.closeSubpath()
ctx.saveGState()
ctx.addPath(head)
ctx.setLineWidth(24)
ctx.setLineJoin(.round)
ctx.setFillColor(rgb(0xffffff))
ctx.setStrokeColor(rgb(0xffffff))
ctx.drawPath(using: .fillStroke)
ctx.restoreGState()

let img = ctx.makeImage()!
let rep = NSBitmapImageRep(cgImage: img)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))

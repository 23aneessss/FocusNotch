#!/usr/bin/env swift
import AppKit
import CoreGraphics

// Renders FocusNotch's app icon at 1024×1024 and writes it next to the asset
// catalog. `Tools/make_icons.sh` then derives the smaller sizes with `sips`.
//
// Design: a "squircle" with a warm focus gradient, a dark notch biting into the
// top edge, and a white progress ring with a play glyph at the center.

let size = 1024
let outPath = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "Sources/Resources/Assets.xcassets/AppIcon.appiconset/icon_1024.png"

let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
guard let ctx = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fatalError("Could not create context")
}

let s = CGFloat(size)
let inset = s * 0.085
let rect = CGRect(x: inset, y: inset, width: s - inset * 2, height: s - inset * 2)
let corner = rect.width * 0.235  // Apple squircle-ish

func roundedPath(_ r: CGRect, _ radius: CGFloat) -> CGPath {
    CGPath(roundedRect: r, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

// Background gradient (focus red → deep orange-red).
ctx.saveGState()
ctx.addPath(roundedPath(rect, corner))
ctx.clip()
let grad = CGGradient(
    colorsSpace: colorSpace,
    colors: [
        CGColor(red: 1.00, green: 0.45, blue: 0.30, alpha: 1),
        CGColor(red: 0.97, green: 0.20, blue: 0.32, alpha: 1),
    ] as CFArray,
    locations: [0, 1]
)!
ctx.drawLinearGradient(grad, start: CGPoint(x: rect.minX, y: rect.maxY), end: CGPoint(x: rect.maxX, y: rect.minY), options: [])
ctx.restoreGState()

// Notch biting into the top edge.
let notchW = rect.width * 0.42
let notchH = rect.height * 0.11
let notchRadius = notchH * 0.55
let notchRect = CGRect(
    x: rect.midX - notchW / 2,
    y: rect.maxY - notchH,
    width: notchW,
    height: notchH + corner
)
ctx.saveGState()
ctx.addPath(roundedPath(rect, corner))
ctx.clip()
let notchPath = CGMutablePath()
notchPath.move(to: CGPoint(x: notchRect.minX, y: rect.maxY + 10))
notchPath.addLine(to: CGPoint(x: notchRect.minX, y: notchRect.minY + notchRadius))
notchPath.addQuadCurve(to: CGPoint(x: notchRect.minX + notchRadius, y: notchRect.minY),
                       control: CGPoint(x: notchRect.minX, y: notchRect.minY))
notchPath.addLine(to: CGPoint(x: notchRect.maxX - notchRadius, y: notchRect.minY))
notchPath.addQuadCurve(to: CGPoint(x: notchRect.maxX, y: notchRect.minY + notchRadius),
                       control: CGPoint(x: notchRect.maxX, y: notchRect.minY))
notchPath.addLine(to: CGPoint(x: notchRect.maxX, y: rect.maxY + 10))
notchPath.closeSubpath()
ctx.addPath(notchPath)
ctx.setFillColor(CGColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1))
ctx.fillPath()
ctx.restoreGState()

// Progress ring.
let ringCenter = CGPoint(x: rect.midX, y: rect.midY - rect.height * 0.03)
let ringRadius = rect.width * 0.27
let ringWidth = rect.width * 0.055

ctx.setLineCap(.round)
// Track
ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.22))
ctx.setLineWidth(ringWidth)
ctx.addArc(center: ringCenter, radius: ringRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
ctx.strokePath()
// Progress (about 70%)
ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
ctx.setLineWidth(ringWidth)
let start = CGFloat.pi / 2
ctx.addArc(center: ringCenter, radius: ringRadius, startAngle: start, endAngle: start - .pi * 2 * 0.70, clockwise: true)
ctx.strokePath()

// Play glyph.
let g = rect.width * 0.085
let playPath = CGMutablePath()
playPath.move(to: CGPoint(x: ringCenter.x - g * 0.6, y: ringCenter.y + g))
playPath.addLine(to: CGPoint(x: ringCenter.x - g * 0.6, y: ringCenter.y - g))
playPath.addLine(to: CGPoint(x: ringCenter.x + g, y: ringCenter.y))
playPath.closeSubpath()
ctx.addPath(playPath)
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
ctx.fillPath()

guard let image = ctx.makeImage() else { fatalError("Could not render image") }
let url = URL(fileURLWithPath: outPath)
guard let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else {
    fatalError("Could not create destination at \(outPath)")
}
CGImageDestinationAddImage(dest, image, nil)
if CGImageDestinationFinalize(dest) {
    print("Wrote \(outPath)")
} else {
    fatalError("Could not write PNG")
}

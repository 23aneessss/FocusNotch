#!/usr/bin/env swift
import AppKit
import CoreGraphics

// FocusNotch app icon, 1024×1024. `Tools/make_icons.sh` derives smaller sizes.
//
// Usage: generate_icon.swift [outPath] [style]
//   style ∈ { dark, vibrant, indigo }  (default: dark)
//
// Concept "Backlit Island": a squircle with a soft accent glow behind a floating
// glass "island" (the notch), an accent rim-light, a top glass sheen, a lens
// dot, and a real drop shadow. The style varies the palette.

let outPath = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "Sources/Resources/Assets.xcassets/AppIcon.appiconset/icon_1024.png"
let style = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "dark"

let size = 1024
let cs = CGColorSpace(name: CGColorSpace.sRGB)!
guard let ctx = CGContext(
    data: nil, width: size, height: size, bitsPerComponent: 8,
    bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else { fatalError("ctx") }

let s = CGFloat(size)
func col(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: r/255, green: g/255, blue: b/255, alpha: a)
}
func grad(_ colors: [CGColor], _ locs: [CGFloat]) -> CGGradient {
    CGGradient(colorsSpace: cs, colors: colors as CFArray, locations: locs)!
}

let inset = s * 0.085
let rect = CGRect(x: inset, y: inset, width: s - inset*2, height: s - inset*2)
let corner = rect.width * 0.2237
func squircle() -> CGPath { CGPath(roundedRect: rect, cornerWidth: corner, cornerHeight: corner, transform: nil) }

// Island geometry (shared).
let iW = rect.width * 0.52
let iH = rect.height * 0.17
let iX = rect.midX - iW / 2
let iCenterY = rect.midY + rect.height * 0.03
let iY = iCenterY - iH / 2
let iR = iH / 2
func islandPath() -> CGPath {
    CGPath(roundedRect: CGRect(x: iX, y: iY, width: iW, height: iH), cornerWidth: iR, cornerHeight: iR, transform: nil)
}

// Palette per style.
let accentA: CGColor, accentB: CGColor, glowColor: CGColor
var islandIsPureBlack = false

switch style {
case "vibrant":
    accentA = col(255, 255, 255); accentB = col(255, 255, 255)
    glowColor = col(255, 255, 255, 0)
    islandIsPureBlack = true
case "indigo":
    accentA = col(120, 170, 255); accentB = col(150, 110, 255)
    glowColor = col(90, 140, 255, 0.42)
default: // dark
    accentA = col(255, 138, 92); accentB = col(255, 42, 116)
    glowColor = col(255, 70, 115, 0.40)
}

// ---------- Background ----------
ctx.saveGState()
ctx.addPath(squircle()); ctx.clip()

switch style {
case "vibrant":
    // Vivid diagonal mesh — coral → magenta → violet.
    ctx.drawLinearGradient(
        grad([col(255, 122, 80), col(255, 46, 120), col(150, 70, 255)], [0, 0.55, 1]),
        start: CGPoint(x: rect.minX, y: rect.maxY),
        end: CGPoint(x: rect.maxX, y: rect.minY), options: [])
    // Warm bloom top-left.
    ctx.drawRadialGradient(
        grad([col(255, 200, 120, 0.35), col(255, 200, 120, 0)], [0, 1]),
        startCenter: CGPoint(x: rect.minX + rect.width*0.28, y: rect.maxY - rect.height*0.24), startRadius: 0,
        endCenter: CGPoint(x: rect.minX + rect.width*0.28, y: rect.maxY - rect.height*0.24), endRadius: rect.width*0.55, options: [])
case "indigo":
    ctx.drawLinearGradient(
        grad([col(46, 52, 96), col(10, 11, 22)], [0, 1]),
        start: CGPoint(x: rect.midX, y: rect.maxY),
        end: CGPoint(x: rect.midX, y: rect.minY), options: [])
default:
    ctx.drawLinearGradient(
        grad([col(20, 20, 26), col(6, 6, 9)], [0, 1]),
        start: CGPoint(x: rect.midX, y: rect.maxY),
        end: CGPoint(x: rect.midX, y: rect.minY), options: [])
}

// Accent glow behind the island (skip for vibrant — the bg already glows).
if !islandIsPureBlack {
    let glowCenter = CGPoint(x: rect.midX, y: rect.midY + rect.height * 0.06)
    ctx.drawRadialGradient(
        grad([glowColor, col(0, 0, 0, 0)], [0, 1]),
        startCenter: glowCenter, startRadius: 0,
        endCenter: glowCenter, endRadius: rect.width * 0.52, options: [])
}

// Top sheen + edge vignette.
ctx.drawLinearGradient(
    grad([col(255, 255, 255, 0.10), col(255, 255, 255, 0)], [0, 1]),
    start: CGPoint(x: rect.midX, y: rect.maxY),
    end: CGPoint(x: rect.midX, y: rect.maxY - rect.height*0.34), options: [])
ctx.drawRadialGradient(
    grad([col(0, 0, 0, 0), col(0, 0, 0, islandIsPureBlack ? 0.30 : 0.45)], [0.55, 1]),
    startCenter: CGPoint(x: rect.midX, y: rect.midY), startRadius: rect.width * 0.32,
    endCenter: CGPoint(x: rect.midX, y: rect.midY), endRadius: rect.width * 0.74, options: [])
ctx.restoreGState()

// ---------- Floating island ----------
// Drop shadow + base.
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -22), blur: 55, color: col(0, 0, 0, islandIsPureBlack ? 0.5 : 0.65))
ctx.addPath(islandPath())
ctx.setFillColor(islandIsPureBlack ? col(0, 0, 0) : col(18, 18, 22))
ctx.fillPath()
ctx.restoreGState()

if !islandIsPureBlack {
    // Form gradient + top sheen.
    ctx.saveGState()
    ctx.addPath(islandPath()); ctx.clip()
    ctx.drawLinearGradient(
        grad([col(44, 44, 54), col(10, 10, 14)], [0, 1]),
        start: CGPoint(x: rect.midX, y: iY + iH),
        end: CGPoint(x: rect.midX, y: iY), options: [])
    ctx.drawLinearGradient(
        grad([col(255, 255, 255, 0.18), col(255, 255, 255, 0)], [0, 1]),
        start: CGPoint(x: rect.midX, y: iY + iH),
        end: CGPoint(x: rect.midX, y: iY + iH * 0.45), options: [])
    ctx.restoreGState()
}

// Rim-light.
ctx.saveGState()
if islandIsPureBlack {
    // Crisp white hairline for the black-on-color island.
    ctx.addPath(islandPath())
    ctx.setStrokeColor(col(255, 255, 255, 0.22))
    ctx.setLineWidth(rect.width * 0.004)
    ctx.strokePath()
} else {
    ctx.setShadow(offset: .zero, blur: 26, color: (style == "indigo" ? col(90, 140, 255, 0.85) : col(255, 60, 110, 0.85)))
    ctx.addPath(islandPath())
    ctx.setLineWidth(rect.width * 0.0095)
    ctx.replacePathWithStrokedPath()
    ctx.clip()
    ctx.drawLinearGradient(
        grad([accentA, accentB], [0, 1]),
        start: CGPoint(x: iX, y: iY + iH),
        end: CGPoint(x: iX + iW, y: iY), options: [])
}
ctx.restoreGState()

// Lens dot.
let dotR = iH * 0.085
ctx.setFillColor(col(230, 230, 236, 0.9))
ctx.fillEllipse(in: CGRect(x: rect.midX - dotR, y: iCenterY - dotR, width: dotR * 2, height: dotR * 2))

// ---------- Write PNG ----------
guard let image = ctx.makeImage() else { fatalError("image") }
let url = URL(fileURLWithPath: outPath)
guard let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else { fatalError("dest") }
CGImageDestinationAddImage(dest, image, nil)
if CGImageDestinationFinalize(dest) { print("Wrote \(outPath) [\(style)]") } else { fatalError("write") }

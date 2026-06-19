#!/usr/bin/env swift
import AppKit

// Renders docs/showcase.png — a marketing banner showing the collapsed notch
// ("at a glance") and the expanded panel ("on hover") on a dark wallpaper.

let W = 1200, H = 430
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "docs/showcase.png"

func col(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: r/255, green: g/255, blue: b/255, alpha: a)
}
let coral = col(255, 107, 92)
let coralB = col(255, 70, 110)

func rounded(_ size: CGFloat, _ weight: NSFont.Weight) -> NSFont {
    let base = NSFont.systemFont(ofSize: size, weight: weight)
    if let d = base.fontDescriptor.withDesign(.rounded) { return NSFont(descriptor: d, size: size) ?? base }
    return base
}
func draw(_ s: String, _ font: NSFont, _ color: NSColor, at p: CGPoint) {
    (s as NSString).draw(at: p, withAttributes: [.font: font, .foregroundColor: color])
}
func width(_ s: String, _ font: NSFont) -> CGFloat {
    (s as NSString).size(withAttributes: [.font: font]).width
}
func drawRight(_ s: String, _ font: NSFont, _ color: NSColor, rightX: CGFloat, y: CGFloat) {
    draw(s, font, color, at: CGPoint(x: rightX - width(s, font), y: y))
}
func drawCentered(_ s: String, _ font: NSFont, _ color: NSColor, cx: CGFloat, y: CGFloat) {
    draw(s, font, color, at: CGPoint(x: cx - width(s, font) / 2, y: y))
}

// Notch silhouette: flat top, rounded bottom corners.
func notch(_ r: CGRect, _ br: CGFloat) -> NSBezierPath {
    let p = NSBezierPath()
    p.move(to: CGPoint(x: r.minX, y: r.minY))
    p.line(to: CGPoint(x: r.maxX, y: r.minY))
    p.line(to: CGPoint(x: r.maxX, y: r.maxY - br))
    p.appendArc(from: CGPoint(x: r.maxX, y: r.maxY), to: CGPoint(x: r.maxX - br, y: r.maxY), radius: br)
    p.line(to: CGPoint(x: r.minX + br, y: r.maxY))
    p.appendArc(from: CGPoint(x: r.minX, y: r.maxY), to: CGPoint(x: r.minX, y: r.maxY - br), radius: br)
    p.close()
    return p
}
func dot(_ x: CGFloat, _ y: CGFloat, _ d: CGFloat, _ c: NSColor) {
    c.setFill(); NSBezierPath(ovalIn: CGRect(x: x, y: y, width: d, height: d)).fill()
}
func circle(_ cx: CGFloat, _ cy: CGFloat, _ d: CGFloat, _ c: NSColor) {
    c.setFill(); NSBezierPath(ovalIn: CGRect(x: cx - d/2, y: cy - d/2, width: d, height: d)).fill()
}

let img = NSImage(size: NSSize(width: W, height: H))
img.lockFocusFlipped(true)
let cg = NSGraphicsContext.current!.cgContext

let cs = CGColorSpaceCreateDeviceRGB()
let bg = CGGradient(colorsSpace: cs, colors: [col(28, 39, 71).cgColor, col(10, 14, 28).cgColor] as CFArray, locations: [0, 1])!
cg.drawLinearGradient(bg, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: CGFloat(H)), options: [])
let glow = CGGradient(colorsSpace: cs, colors: [col(90, 110, 255, 0.18).cgColor, col(90, 110, 255, 0).cgColor] as CFArray, locations: [0, 1])!
cg.drawRadialGradient(glow, startCenter: CGPoint(x: CGFloat(W)/2, y: 150), startRadius: 0, endCenter: CGPoint(x: CGFloat(W)/2, y: 150), endRadius: 520, options: [])

let cx = CGFloat(W) / 2

// ---- Collapsed pill (hangs from the top) ----
let pw: CGFloat = 360, ph: CGFloat = 34
let pr = CGRect(x: cx - pw/2, y: 0, width: pw, height: ph)
NSColor.black.setFill(); notch(pr, 11).fill()
draw("24:18", rounded(15, .semibold), .white, at: CGPoint(x: pr.minX + 26, y: 8))
dot(pr.minX + 14, 13, 7, coral)
let dxR = pr.maxX - 70
let dcolors: [NSColor] = [coral, col(90,90,90), col(90,90,90), col(90,90,90)]
for i in 0..<4 { dot(dxR + CGFloat(i)*11, 14, 6, dcolors[i]) }
drawCentered("At a glance", rounded(12, .medium), col(255,255,255,0.55), cx: cx, y: ph + 14)

// ---- Expanded panel (on hover) ----
let ew: CGFloat = 460, eh: CGFloat = 250
let ey: CGFloat = 96
let er = CGRect(x: cx - ew/2, y: ey, width: ew, height: eh)
cg.saveGState()
cg.setShadow(offset: .zero, blur: 40, color: col(0,0,0,0.5).cgColor)
NSColor.black.setFill(); notch(er, 28).fill()
cg.restoreGState()

let pad: CGFloat = 26
let lx = er.minX + pad
let rx = er.maxX - pad

// badge "Focus"
let badgeFont = rounded(13, .semibold)
let bw = width("Focus", badgeFont) + 34
coral.withAlphaComponent(0.16).setFill()
NSBezierPath(roundedRect: CGRect(x: lx, y: er.minY + 24, width: bw, height: 28), xRadius: 14, yRadius: 14).fill()
dot(lx + 12, er.minY + 35, 7, coral)
draw("Focus", badgeFont, coral, at: CGPoint(x: lx + 26, y: er.minY + 31))
// session dots top-right
for i in 0..<4 { dot(rx - 60 + CGFloat(i)*12, er.minY + 35, 7, i == 0 ? coral : col(70,70,70)) }

// hero time
draw("24:18", rounded(54, .bold), .white, at: CGPoint(x: lx - 2, y: er.minY + 66))
drawRight("NEXT", rounded(10, .bold), col(255,255,255,0.35), rightX: rx, y: er.minY + 78)
drawRight("Short Break", rounded(13, .medium), col(255,255,255,0.6), rightX: rx, y: er.minY + 92)

// progress bar
let barY = er.minY + 150
col(255,255,255,0.14).setFill()
NSBezierPath(roundedRect: CGRect(x: lx, y: barY, width: ew - pad*2, height: 6), xRadius: 3, yRadius: 3).fill()
let fillGrad = CGGradient(colorsSpace: cs, colors: [coral.cgColor, coralB.cgColor] as CFArray, locations: [0, 1])!
cg.saveGState()
NSBezierPath(roundedRect: CGRect(x: lx, y: barY, width: (ew - pad*2) * 0.16, height: 6), xRadius: 3, yRadius: 3).addClip()
cg.drawLinearGradient(fillGrad, start: CGPoint(x: lx, y: 0), end: CGPoint(x: lx + 120, y: 0), options: [])
cg.restoreGState()

// controls
let ctlY = er.minY + 196
circle(lx + 19, ctlY, 38, coral)
NSColor.black.setFill()
let tri = NSBezierPath()
tri.move(to: CGPoint(x: lx + 13, y: ctlY - 8)); tri.line(to: CGPoint(x: lx + 13, y: ctlY + 8)); tri.line(to: CGPoint(x: lx + 27, y: ctlY)); tri.close(); tri.fill()
// skip
circle(lx + 64, ctlY, 32, col(255,255,255,0.10))
NSColor.white.setFill()
for k in 0..<2 { let bx = lx + 56 + CGFloat(k)*9; let t = NSBezierPath(); t.move(to: CGPoint(x: bx, y: ctlY - 6)); t.line(to: CGPoint(x: bx, y: ctlY + 6)); t.line(to: CGPoint(x: bx + 8, y: ctlY)); t.close(); t.fill() }
// reset (circular arrow)
circle(lx + 105, ctlY, 32, col(255,255,255,0.10))
NSColor.white.setStroke(); NSColor.white.setFill()
let arc = NSBezierPath(); arc.lineWidth = 2.4
arc.appendArc(withCenter: CGPoint(x: lx + 105, y: ctlY), radius: 7.5, startAngle: 50, endAngle: 320)
arc.stroke()
let ah = NSBezierPath()
ah.move(to: CGPoint(x: lx + 105 + 7.5, y: ctlY - 6))
ah.line(to: CGPoint(x: lx + 105 + 12, y: ctlY - 4))
ah.line(to: CGPoint(x: lx + 105 + 6, y: ctlY - 0.5))
ah.close(); ah.fill()
// moon (right) — clear crescent
circle(rx - 19, ctlY, 32, col(255,255,255,0.10))
NSColor.white.setFill()
let moon = NSBezierPath(ovalIn: CGRect(x: rx - 29, y: ctlY - 9, width: 18, height: 18))
let cut = NSBezierPath(ovalIn: CGRect(x: rx - 21, y: ctlY - 12, width: 18, height: 18))
moon.append(cut.reversed); moon.fill()

drawCentered("On hover", rounded(12, .medium), col(255,255,255,0.55), cx: cx, y: er.maxY + 14)

img.unlockFocus()
guard let tiff = img.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else { fatalError("png") }
try! FileManager.default.createDirectory(atPath: (out as NSString).deletingLastPathComponent, withIntermediateDirectories: true)
try! png.write(to: URL(fileURLWithPath: out))
print("Wrote \(out)")

// Generates Resources/AppIcon.png (1024²) and Resources/AppIcon.icns.
// Usage: swift scripts/make-icon.swift
import AppKit

let size = 1024
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8,
                           samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
let ctx = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current = ctx
let s = CGFloat(size)

// Tile: 824² centered, leaving room for the system-style shadow.
let tile = NSRect(x: 100, y: 100, width: 824, height: 824)
let tilePath = NSBezierPath(roundedRect: tile, xRadius: 186, yRadius: 186)

NSGraphicsContext.saveGraphicsState()
let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.30)
shadow.shadowBlurRadius = 28
shadow.shadowOffset = NSSize(width: 0, height: -12)
shadow.set()
NSColor.black.setFill()
tilePath.fill()
NSGraphicsContext.restoreGraphicsState()

NSGraphicsContext.saveGraphicsState()
tilePath.addClip()
NSGradient(colors: [NSColor(red: 0.36, green: 0.72, blue: 1.0, alpha: 1),
                    NSColor(red: 0.06, green: 0.33, blue: 0.95, alpha: 1)])!
    .draw(in: tile, angle: -65)
// soft top highlight
NSGradient(colors: [NSColor.white.withAlphaComponent(0.22), NSColor.white.withAlphaComponent(0)])!
    .draw(in: NSRect(x: tile.minX, y: tile.midY, width: tile.width, height: tile.height / 2), angle: -90)
NSGraphicsContext.restoreGraphicsState()

// Mouse body
let mw: CGFloat = 330, mh: CGFloat = 500
let mouse = NSRect(x: s / 2 - mw / 2, y: s / 2 - mh / 2 - 6, width: mw, height: mh)
let body = NSBezierPath(roundedRect: mouse, xRadius: mw / 2, yRadius: mw / 2)

NSGraphicsContext.saveGraphicsState()
let ms = NSShadow()
ms.shadowColor = NSColor(red: 0, green: 0.12, blue: 0.5, alpha: 0.35)
ms.shadowBlurRadius = 30
ms.shadowOffset = NSSize(width: 0, height: -14)
ms.set()
NSColor.white.setFill()
body.fill()
NSGraphicsContext.restoreGraphicsState()

NSGraphicsContext.saveGraphicsState()
body.addClip()
NSGradient(colors: [NSColor.white, NSColor(white: 0.90, alpha: 1)])!.draw(in: mouse, angle: -90)
// button split
NSColor(red: 0.06, green: 0.33, blue: 0.95, alpha: 0.16).setFill()
NSRect(x: mouse.minX, y: mouse.maxY - 215, width: mw, height: 10).fill()
NSRect(x: s / 2 - 5, y: mouse.maxY - 215, width: 10, height: 215).fill()
NSGraphicsContext.restoreGraphicsState()

// Scroll wheel
let wheel = NSRect(x: s / 2 - 28, y: mouse.maxY - 175, width: 56, height: 110)
NSColor(red: 0.08, green: 0.38, blue: 0.97, alpha: 1).setFill()
NSBezierPath(roundedRect: wheel, xRadius: 28, yRadius: 28).fill()

// "Tune" sliders flanking the mouse
func slider(x: CGFloat, knobY: CGFloat) {
    NSColor.white.withAlphaComponent(0.45).setFill()
    NSBezierPath(roundedRect: NSRect(x: x - 7, y: 300, width: 14, height: 424), xRadius: 7, yRadius: 7).fill()
    NSColor.white.setFill()
    NSBezierPath(ovalIn: NSRect(x: x - 26, y: knobY - 26, width: 52, height: 52)).fill()
}
slider(x: 240, knobY: 600)
slider(x: 784, knobY: 430)

let png = rep.representation(using: .png, properties: [:])!
try png.write(to: URL(fileURLWithPath: "Resources/AppIcon.png"))
print("Wrote Resources/AppIcon.png")

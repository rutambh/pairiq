import math
import os
from PIL import Image, ImageDraw, ImageFilter

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(BASE, 'build', 'icons')
os.makedirs(OUT, exist_ok=True)

def gradient_circle(size, colors):
    """Create a circle with vertical gradient."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    # Build gradient image
    grad = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(grad)
    steps = len(colors) - 1
    seg_h = size / steps
    for i in range(steps):
        c1, c2 = colors[i], colors[i+1]
        y0 = int(i * seg_h)
        y1 = int((i + 1) * seg_h) if i < steps - 1 else size
        for y in range(y0, y1):
            t = (y - y0) / (y1 - y0) if y1 != y0 else 0
            r = int(c1[0] + (c2[0] - c1[0]) * t)
            g = int(c1[1] + (c2[1] - c1[1]) * t)
            b = int(c1[2] + (c2[2] - c1[2]) * t)
            gdraw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    # Circle mask
    mask = Image.new('L', (size, size), 0)
    mdraw = ImageDraw.Draw(mask)
    margin = int(size * 0.031)  # ~32px at 1024
    mdraw.ellipse([margin, margin, size - margin, size - margin], fill=255)
    # Smooth mask
    mask = mask.filter(ImageFilter.GaussianBlur(radius=max(1, size // 256)))
    img.paste(grad, (0, 0), mask)
    return img

def star_polygon(cx, cy, outer_r, inner_r, n=5):
    pts = []
    for i in range(n * 2):
        angle = math.radians(-90 + i * 180 / n)
        r = outer_r if i % 2 == 0 else inner_r
        pts.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    return pts

def create_card(w, h, radius, has_brain):
    """Create a card image with shadow."""
    card = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    cdraw = ImageDraw.Draw(card)
    tint = (255, 245, 250) if has_brain else (245, 245, 255)
    cdraw.rounded_rectangle([0, 0, w - 1, h - 1], radius=radius,
                            fill=tint, outline=(230, 230, 240), width=max(1, w // 340))

    if has_brain:
        bx, by = w // 2, int(h * 0.52)
        br = w // 10
        col = (108, 60, 225)
        cdraw.ellipse([bx - br, by - br - w // 25, bx + br, by + br - w // 25], fill=(108, 60, 225, 25))
        cdraw.pieslice([bx - br, by - br - w // 17, bx + br, by + br - w // 26], start=0, end=180, fill=col)
        bw3 = max(1, w // 40)
        cdraw.rectangle([bx - bw3, by - w // 34, bx + bw3, by + w // 34], fill=col)
        for yy in [w // 25, w // 19, w // 15]:
            lw = max(1, w // 85)
            cdraw.line([bx - w // 64, by + yy, bx + w // 64, by + yy], fill=col, width=lw)
        for dx, dy, r_ in [(-15, -30, 6), (20, -25, 4), (-22, -10, 3)]:
            r2 = w // 85 * r_
            cdraw.ellipse([bx + w//68*dx - r2, by + w//68*dy - r2,
                          bx + w//68*dx + r2, by + w//68*dy + r2], fill=(108, 60, 225, 80))
    else:
        cx_st, cy_st = w // 2, int(h * 0.48)
        outer_r, inner_r = w // 9, w // 22
        pts = star_polygon(cx_st, cy_st, outer_r, inner_r)
        cdraw.polygon(pts, fill=(253, 203, 110))
    return card

def rotated_card_with_shadow(img, cx, cy, angle, w, h, radius, has_brain):
    """Draw a card with drop shadow onto img at position cx,cy with rotation."""
    card = create_card(w, h, radius, has_brain)
    # Shadow layer
    shadow = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.rounded_rectangle([w//128, h//85, w - 1 + w//128, h - 1 + h//85], radius=radius, fill=(0, 0, 0, 60))
    shadow = shadow.rotate(angle, expand=True, resample=Image.BICUBIC, fillcolor=(0, 0, 0, 0))
    card = card.rotate(angle, expand=True, resample=Image.BICUBIC, fillcolor=(0, 0, 0, 0))

    px = int(cx - card.width / 2)
    py = int(cy - card.height / 2)
    spx = int(cx - shadow.width / 2)
    spy = int(cy - shadow.height / 2)
    img.paste(shadow, (spx, spy), shadow)
    img.paste(card, (px, py), card)

def draw_icon(size):
    # Background gradient circle
    s = size / 1024
    colors = [(108, 60, 225), (232, 67, 147), (253, 203, 110)]
    img = gradient_circle(size, colors)
    draw = ImageDraw.Draw(img)

    # Decorative dots
    for x, y, rad, alpha in [(280, 220, 60, 20), (760, 340, 40, 15),
                              (800, 780, 50, 20), (200, 750, 35, 15)]:
        draw.ellipse([int(s*x - s*rad), int(s*y - s*rad),
                     int(s*x + s*rad), int(s*y + s*rad)], fill=(255, 255, 255, alpha))

    cw, ch = int(s * 340), int(s * 400)
    cr = int(s * 40)

    rotated_card_with_shadow(img, s * 512, s * 480, -8, cw, ch, cr, has_brain=False)
    rotated_card_with_shadow(img, s * 512, s * 500, 8, cw, ch, cr, has_brain=True)

    # Sparkles
    def sparkle(x, y, r, alpha):
        pts = []
        for i in range(8):
            a = math.radians(45 * i)
            rad = s * (r * (0.4 if i % 2 == 0 else 1))
            pts.append((s*x + rad * math.cos(a), s*y + rad * math.sin(a)))
        draw.polygon(pts, fill=(255, 255, 255, alpha))
    sparkle(720, 280, 18, 230)
    sparkle(310, 330, 12, 180)

    return img

master = draw_icon(1024)
master_path = os.path.join(OUT, 'icon_1024.png')
master.save(master_path)
print(f"Master -> {master_path}")

def resize(size, path):
    img = master.resize((size, size), Image.LANCZOS)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)
    print(f"  {size}x{size} -> {path}")

ANDROID_DIR = os.path.join(BASE, 'android', 'app', 'src', 'main', 'res')
for folder, sz in {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}.items():
    resize(sz, os.path.join(ANDROID_DIR, f'mipmap-{folder}', 'ic_launcher.png'))

IOS_DIR = os.path.join(BASE, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
for sz, name in [
    (20, 'Icon-App-20x20@1x.png'), (40, 'Icon-App-20x20@2x.png'), (60, 'Icon-App-20x20@3x.png'),
    (29, 'Icon-App-29x29@1x.png'), (58, 'Icon-App-29x29@2x.png'), (87, 'Icon-App-29x29@3x.png'),
    (40, 'Icon-App-40x40@1x.png'), (80, 'Icon-App-40x40@2x.png'), (120, 'Icon-App-40x40@3x.png'),
    (60, 'Icon-App-60x60@2x.png'), (180, 'Icon-App-60x60@3x.png'),
    (76, 'Icon-App-76x76@1x.png'), (152, 'Icon-App-76x76@2x.png'),
    (167, 'Icon-App-83.5x83.5@2x.png'), (1024, 'Icon-App-1024x1024@1x.png'),
]:
    resize(sz, os.path.join(IOS_DIR, name))

MACOS_DIR = os.path.join(BASE, 'macos', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
for sz, name in [(16, 'app_icon_16.png'), (32, 'app_icon_32.png'), (64, 'app_icon_64.png'),
                 (128, 'app_icon_128.png'), (256, 'app_icon_256.png'), (512, 'app_icon_512.png'),
                 (1024, 'app_icon_1024.png')]:
    resize(sz, os.path.join(MACOS_DIR, name))

WEB_DIR = os.path.join(BASE, 'web', 'icons')
for sz in [192, 512]:
    resize(sz, os.path.join(WEB_DIR, f'Icon-{sz}.png'))
    resize(sz, os.path.join(WEB_DIR, f'Icon-maskable-{sz}.png'))
resize(48, os.path.join(BASE, 'web', 'favicon.png'))

ico_sizes = [16, 32, 48, 64, 128, 256]
ico_images = [master.resize((s, s), Image.LANCZOS) for s in ico_sizes]
ico_path = os.path.join(BASE, 'windows', 'runner', 'resources', 'app_icon.ico')
ico_images[0].save(ico_path, format='ICO', sizes=[(s, s) for s in ico_sizes], append_images=ico_images[1:])
print(f"  ICO -> {ico_path}")

print("\nAll icons generated successfully!")

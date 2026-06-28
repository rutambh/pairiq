import os
from PIL import Image

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
logo = Image.open(os.path.join(BASE, 'logo.png')).convert('RGBA')

def resize(size, path):
    img = logo.resize((size, size), Image.LANCZOS)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)
    print(f"  {size}x{size} -> {path}")

# Android
ANDROID_DIR = os.path.join(BASE, 'android', 'app', 'src', 'main', 'res')
for folder, sz in {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}.items():
    resize(sz, os.path.join(ANDROID_DIR, f'mipmap-{folder}', 'ic_launcher.png'))

# iOS
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

# macOS
MACOS_DIR = os.path.join(BASE, 'macos', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
for sz, name in [(16, 'app_icon_16.png'), (32, 'app_icon_32.png'), (64, 'app_icon_64.png'),
                 (128, 'app_icon_128.png'), (256, 'app_icon_256.png'), (512, 'app_icon_512.png'),
                 (1024, 'app_icon_1024.png')]:
    resize(sz, os.path.join(MACOS_DIR, name))

# Web
WEB_DIR = os.path.join(BASE, 'web', 'icons')
for sz in [192, 512]:
    resize(sz, os.path.join(WEB_DIR, f'Icon-{sz}.png'))
    resize(sz, os.path.join(WEB_DIR, f'Icon-maskable-{sz}.png'))
resize(48, os.path.join(BASE, 'web', 'favicon.png'))

# Windows ICO
ico_sizes = [16, 32, 48, 64, 128, 256]
ico_images = [logo.resize((s, s), Image.LANCZOS) for s in ico_sizes]
ico_path = os.path.join(BASE, 'windows', 'runner', 'resources', 'app_icon.ico')
ico_images[0].save(ico_path, format='ICO', sizes=[(s, s) for s in ico_sizes], append_images=ico_images[1:])
print(f"  ICO -> {ico_path}")

print("\nAll icons updated from logo.png!")

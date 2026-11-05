"""Build both Linux cursor formats from Capitaine's original SVG and specs."""
import json
from pathlib import Path
import shutil
import subprocess
import sys
from tempfile import TemporaryDirectory


def build(source, target):
    raster = target / 'cursors'
    scalable = target / 'cursors_scalable'
    raster.mkdir(parents=True, exist_ok=True)
    scalable.mkdir(parents=True, exist_ok=True)
    sizes = (24, 28, 30, 32, 36, 40, 48, 60, 72, 96, 120, 144)
    for spec in sorted((source / 'config').glob('*/*.spec')):
        name = spec.stem
        x, y, *animation = map(int, spec.read_text().split())
        filenames = ([f'{name}-{index:02d}.svg' for index in range(animation[0])]
                     if animation else [f'{name}.svg'])
        cursor = scalable / name
        cursor.mkdir()
        frames = []
        for filename in filenames:
            shutil.copyfile(source / 'svg' / 'dark' / filename, cursor / filename)
            frame = dict(filename=filename, hotspot_x=x, hotspot_y=y, nominal_size=24)
            if animation:
                frame['delay'] = animation[1]
            frames.append(frame)
        (cursor / 'metadata.json').write_text(json.dumps(frames, indent=2) + '\n')
        with TemporaryDirectory() as directory:
            scratch = Path(directory)
            rows = []
            for size in sizes:
                for index, filename in enumerate(filenames):
                    image = f'{size}-{index}.png'
                    subprocess.run(['rsvg-convert', '-w', str(size), '-h', str(size),
                                    str(cursor / filename), '-o', str(scratch / image)], check=True)
                    delay = f' {animation[1]}' if animation else ''
                    rows.append(f'{size} {x * size // 24} {y * size // 24} {image}{delay}')
            (scratch / 'frames').write_text('\n'.join(rows) + '\n')
            subprocess.run(['xcursorgen', 'frames', str(raster / name)], cwd=scratch, check=True)

    aliases = (source / 'cursor-aliases').read_text().splitlines()
    aliases += ['X_cursor x-cursor', 'all-resize all-scroll', 'dnd-ask help',
                'ew-resize size_hor', 'ns-resize size_ver', 'top_left_arrow default']
    for output in (raster, scalable):
        for line in aliases:
            alias, name = line.split()
            if not (output / alias).exists() and not (output / alias).is_symlink():
                (output / alias).symlink_to(name)
        for alias in output.iterdir():
            if not alias.exists():
                raise ValueError(f'Broken Capitaine cursor alias {alias.name}')


if __name__ == '__main__':
    build(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve())

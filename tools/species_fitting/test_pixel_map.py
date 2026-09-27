import json
import tempfile
import unittest
from pathlib import Path

from PIL import Image

from dmi import read_dmi
from fit import SpeciesFit, _read_pixel_map, _refit_rows


class PixelMapTests(unittest.TestCase):
    def test_refit_outline_and_alpha(self):
        dark, cloth = (20, 10, 5, 255), (220, 190, 70, 128)
        source = dict(enumerate([None, dark, cloth, cloth, dark, None]))
        adapted = dict(enumerate([dark, dark, cloth, cloth, dark, dark]))
        source = {(x, 0): color for x, color in source.items()}
        adapted = {(x, 0): color for x, color in adapted.items()}
        result = _refit_rows(source, adapted, 6, 1, {0})
        self.assertEqual(list(result.values()), [dark, cloth, cloth, cloth, cloth, dark])
        self.assertEqual(_refit_rows(source, adapted, 6, 1, set()), adapted)
        self.assertEqual(source[0, 0], None)
        self.assertEqual(adapted[1, 0], dark)

    def test_refit_coverage_and_growth_limits(self):
        dark, cloth = (20, 10, 5, 255), (220, 190, 70, 255)
        source = {(x, 0): color for x, color in enumerate([dark, cloth, None, cloth, dark])}
        adapted = {(x, 0): dark for x in range(5)}
        self.assertEqual(_refit_rows(source, adapted, 5, 1, {0})[2, 0], cloth)
        adapted[0, 0] = adapted[4, 0] = None
        self.assertEqual(_refit_rows(source, adapted, 5, 1, {0}), adapted)
        source = {(x, 0): cloth if x == 5 else None for x in range(12)}
        adapted = {(x, 0): dark for x in range(12)}
        self.assertEqual(_refit_rows(source, adapted, 12, 1, {0}), adapted)

    def test_export_coordinates(self):
        maps = _read_pixel_map(
            "code/modules/mob/living/carbon/human/species/fitting/maps/human-to-trottine.json", 32, 32)
        self.assertEqual(maps[0][9, 19], (10, 19))
        self.assertEqual([len(maps[index]) for index in range(4)], [33, 33, 44, 44])

    def test_sparse_pull_and_clear(self):
        data = {"version": 1, "resolution": {"width": 32, "height": 32},
                "supportedDirections": "eight", "mappings": {"South": [
                    {"source": {"x": 0, "y": 0}, "target": {"x": 1, "y": 1}},
                    {"source": {"x": 1, "y": 1}, "target": {"x": 0, "y": 0}},
                    {"source": {"x": 2, "y": 2}, "target": None}]}}
        body = read_dmi("icons/mob/human_races/r_human.dmi")[0]
        image = Image.new("RGBA", (32, 32))
        image.putpixel((0, 0), (20, 40, 60, 128))
        image.putpixel((1, 1), (90, 80, 70, 255))
        image.putpixel((2, 2), (255, 255, 255, 255))
        image.putpixel((3, 3), (10, 20, 30, 255))
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "map.json"
            path.write_text(json.dumps(data))
            fitter = SpeciesFit(body, body, trim="shrink", remap="auto", pixel_map=path)
            result, changed = fitter.fit_frame(image, 0, False, (), False)
            self.assertTrue(changed)
            self.assertEqual(result[0, 0], (90, 80, 70, 255))
            self.assertEqual(result[1, 1], (20, 40, 60, 128))
            self.assertIsNone(result[2, 2])
            self.assertEqual(result[3, 3], (10, 20, 30, 255))
            self.assertEqual(fitter.pixel_maps[1], {})
            data["resolution"]["width"] = 64
            path.write_text(json.dumps(data))
            with self.assertRaises(ValueError):
                _read_pixel_map(path, 32, 32)


if __name__ == "__main__":
    unittest.main()

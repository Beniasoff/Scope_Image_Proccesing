
---

# Image Processing For Data Extraction From Images

![Alt text](Proccess.png)

## Description

This repository contains a Julia notebook and a set of functions for processing images and videos. The notebook demonstrates various image processing techniques, including filtering, segmentation, and transformation. The functions provide utilities for processing images, transforming them using homography, and extracting signals based on the center of mass of image components.

## Repository Structure

- [`Example.ipynb`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2FUsers%2Fbenniasoff%2FVscode%2Fchemlab%2Fsound%2FExample.ipynb%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/Users/benniasoff/Vscode/chemlab/sound/Example.ipynb"): A Jupyter notebook that demonstrates the usage of the functions defined in [`Functions.jl`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2FUsers%2Fbenniasoff%2FVscode%2Fchemlab%2Fsound%2FFunctions.jl%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/Users/benniasoff/Vscode/chemlab/sound/Functions.jl"). It includes examples of video frame extraction, image processing, and signal extraction.
- [`Functions.jl`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2FUsers%2Fbenniasoff%2FVscode%2Fchemlab%2Fsound%2FFunctions.jl%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/Users/benniasoff/Vscode/chemlab/sound/Functions.jl"): A Julia script containing functions for image processing, including filtering, segmentation, and transformation.

## Usage

1. Open the [`Example.ipynb`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2FUsers%2Fbenniasoff%2FVscode%2Fchemlab%2Fsound%2FExample.ipynb%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/Users/benniasoff/Vscode/chemlab/sound/Example.ipynb") notebook in Jupyter:
   ```sh
   jupyter notebook Example.ipynb
   ```

2. Run the cells in the notebook to see the image and video processing examples.

## Main Functions

### `processImage(img, retain, segments, sigma, epsilon, show=false)`

Processes an image by applying a Gaussian filter, segmenting it into connected components, and retaining the largest components based on their distance from the image center.

### `transformImage(selected_components_img, pixels)`

Transforms an image using a homography to map the farthest colored pixels in each quadrant to a square of specified size (`pixels`).

### `get_signal(data)`

Generates a signal by calculating the center of mass for each column in a binary image.

## Acknowledgements

- JuliaLang community for the amazing Julia programming language and packages.
- Open source contributors for the libraries used in this project.

## Contact

For any questions or suggestions, please contact [ben.niasoff@mail.huji.ac.il](mailto:ben.niasoff@mail.huji.ac.il).
## Acknowledgments

- This function utilizes several Julia packages for image processing and graph manipulation.
- Special thanks to the Julia community for providing extensive documentation and support.

---


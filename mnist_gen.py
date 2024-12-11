import numpy as np
import gzip
import struct

# Load MNIST data
def load_mnist_images(filename):
    with gzip.open(filename, 'rb') as f:
        _, num_images, rows, cols = struct.unpack(">IIII", f.read(16))
        return np.frombuffer(f.read(), dtype=np.uint8).reshape(num_images, rows, cols)

def load_mnist_labels(filename):
    with gzip.open(filename, 'rb') as f:
        _ = struct.unpack(">II", f.read(8))
        return np.frombuffer(f.read(), dtype=np.uint8)

images = load_mnist_images('train-images-idx3-ubyte.gz')
labels = load_mnist_labels('train-labels-idx1-ubyte.gz')

# Save to mnist_data.txt
with open('mnist_data.txt', 'w') as f:
    for img, label in zip(images, labels):
        flat_img = img.flatten()
        f.write(" ".join(map(str, flat_img)) + f" {label}\n")

import numpy as np
import torch

weights = torch.load("vit_weights.pth")

def quantize(tensor, scale=256):
    return (tensor * scale).round().clamp(-128, 127).int()

for key in weights:
    weights[key] = quantize(weights[key])

np.savez("vit_weights.npz", **{k: v.numpy() for k, v in weights.items()})
import torch
import torch.nn as nn
import torchvision.datasets as datasets
import torchvision.transforms as transforms


class SimpleViT(nn.Module):
    def __init__(self, dim):
        super(SimpleViT, self).__init__()
        self.dim = dim
        self.q = nn.Linear(dim, dim)
        self.k = nn.Linear(dim, dim)
        self.softmax = nn.Softmax(dim=-1)

    def forward(self, x):
        Q = self.q(x)
        K = self.k(x)
        attn = torch.matmul(Q, K.transpose(-1, -2)) / (self.dim**0.5)
        attn = self.softmax(attn)
        return attn

transform = transforms.Compose([transforms.ToTensor()])
dataset = datasets.MNIST(root="./data", train=True, download=True, transform=transform)
x, _ = dataset[0]

x = x.view(1, -1)[:, :16]  # Lấy 16 phần tử đầu tiên
vit = SimpleViT(dim=16)
attn = vit(x)
torch.save(vit.state_dict(), "vit_weights.pth")

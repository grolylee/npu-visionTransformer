import torch
import timm  # Sử dụng thư viện timm để load mô hình ViT

# Load mô hình ViT có sẵn
model = timm.create_model('vit_base_patch16_224', pretrained=True)
model.eval()

# Tạo input giả lập (1 ảnh với kích thước 224x224, 3 kênh màu)
dummy_input = torch.randn(1, 3, 224, 224)

# Hook để lấy giá trị Q, K, V từ self-attention layer
QKV_list = []

def hook_fn(module, input, output):
    QKV_list.append(output)

# Gán hook vào tầng Multi-Head Self-Attention của ViT
for name, module in model.named_modules():
    if 'attn' in name:  # Tìm lớp attention
        module.qkv.register_forward_hook(hook_fn)

# Chạy mô hình để lấy giá trị Q, K, V
with torch.no_grad():
    model(dummy_input)

# QKV có kích thước (Batch, Num_Heads, Num_Patches, Head_Dim * 3)
QKV_tensor = QKV_list[0].squeeze(0)  # Lấy kết quả từ batch đầu tiên
num_heads = QKV_tensor.shape[0]
head_dim = QKV_tensor.shape[-1] // 3

# Tách riêng Q, K, V
Q = QKV_tensor[:, :, :head_dim]
K = QKV_tensor[:, :, head_dim:2*head_dim]
V = QKV_tensor[:, :, 2*head_dim:]

# Lưu ra file để đưa vào FPGA
torch.save(Q, "Q_tensor.pt")
torch.save(K, "K_tensor.pt")
torch.save(V, "V_tensor.pt")

print("Saved Q, K, V tensors for FPGA verification.")


# Related work về FPGA/GEMM/systolic array

Tài liệu này chỉ ghi paper/nguồn đã kiểm chứng bằng link web trong phiên làm việc. Không dùng số liệu performance cho project này nếu chưa chạy Vivado thật.

## Systolic Tensor Array (2020)

- Nguồn: Zhi-Gang Liu, Paul N. Whatmough, Matthew Mattina, “Systolic Tensor Array: An Efficient Structured-Sparse GEMM Accelerator for Mobile CNN Inference”, arXiv:2005.08098, 2020. https://arxiv.org/abs/2005.08098
- Ý chính: paper tập trung GEMM INT8 cho CNN inference, mở rộng PE scalar thành Tensor-PE và hỗ trợ block-sparse format.
- Liên hệ project: củng cố hướng dùng PE array/GEMM INT8, nhưng baseline hiện tại chưa có sparse format/Tensor-PE.

## Systolic-CNN (2020)

- Nguồn: Akshay Dua, Yixing Li, Fengbo Ren, “Systolic-CNN: An OpenCL-defined Scalable Run-time-flexible FPGA Accelerator Architecture for Accelerating Convolutional Neural Network Inference in Cloud/Edge Computing”, arXiv:2012.03177, 2020. https://arxiv.org/abs/2012.03177
- Ý chính: kiến trúc systolic 1-D được mô tả là scalable/runtime-flexible cho CNN inference trên FPGA.
- Liên hệ project: nhấn mạnh tham số hóa và khả năng tái sử dụng kiến trúc; project hiện đã đặt `ROWS`, `COLS`, `K` làm parameter.

## Evaluating Low-Memory GEMMs (FCCM 2020)

- Nguồn: Wentai Zhang, Ming Jiang, Guojie Luo, “Evaluating Low-Memory GEMMs for Convolutional Neural Network Inference on FPGAs”, FCCM 2020. https://www.fccm.org/past/2020/proceedings/2020/pdfs/FCCM2020-65FOvhMqzyMYm99lfeVKyl/580300a028/580300a028.pdf
- Ý chính: đánh giá low-memory GEMM trên FPGA để giảm overhead memory của explicit GEMM.
- Liên hệ project: phần TODO nên mở rộng `MM_buffer` thành tiling/ping-pong buffer để giảm bandwidth và tăng data reuse.

## High-frequency systolic array Transformer accelerator (2023)

- Nguồn: Chen et al., “High-Frequency Systolic Array-Based Transformer Accelerator on Field Programmable Gate Arrays”, Electronics 2023, DOI 10.3390/electronics12040822. https://www.mdpi.com/2079-9292/12/4/822/xml
- Ý chính: tập trung high-frequency systolic array cho Transformer trên FPGA và flow sinh constraint.
- Liên hệ project: Vivado XDC/placement/timing closure có thể là hướng phát triển sau khi baseline function pass.

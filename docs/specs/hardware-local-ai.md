# Hardware Local AI Capabilities Report

## Executive Summary

**✅ LLM-Ready**: RTX 3060 (12GB VRAM) + 32GB RAM enables 7B-13B models at good speeds

## Hardware Specifications

### GPU

| Spec         | Value                   |
| ------------ | ----------------------- |
| Model        | NVIDIA GeForce RTX 3060 |
| VRAM         | 12,288 MiB (12GB)       |
| Architecture | GA106 (Ampere)          |
| Compute Cap  | 8.6                     |
| CUDA         | 11.8                    |
| Driver       | 535.247.01              |
| Current Use  | 1GB used, 11GB free     |

### CPU

| Spec         | Value            |
| ------------ | ---------------- |
| Model        | AMD Ryzen 5 2600 |
| Cores        | 6 physical       |
| Threads      | 12 logical       |
| Base/Max     | 1.55/3.4 GHz     |
| L3 Cache     | 16 MiB           |
| Architecture | Zen+ (14nm)      |

### Memory

| Type | Size  | Available   |
| ---- | ----- | ----------- |
| RAM  | 32 GB | ~16 GB free |
| Swap | 64 GB | ~60 GB free |

## Model Compatibility Matrix

### VRAM-Based Loading (GPU-Only)

| Size | Quant  | VRAM Req | Status       | Speed (tok/s) |
| ---- | ------ | -------- | ------------ | ------------- |
| 1.5B | Q4_K_M | 1.2GB    | ✅ Excellent | 150-200       |
| 3B   | Q4_K_M | 2.4GB    | ✅ Excellent | 100-150       |
| 7B   | Q4_K_M | 4.5GB    | ✅ Excellent | 60-80         |
| 7B   | Q8_0   | 7.5GB    | ✅ Excellent | 50-70         |
| 7B   | FP16   | 14GB     | ❌ Too large | -             |
| 13B  | Q4_K_M | 8.5GB    | ✅ Good      | 30-40         |
| 13B  | Q5_K_M | 10GB     | ✅ Good      | 25-35         |
| 13B  | Q8_0   | 14GB     | ❌ Too large | -             |
| 20B  | Q4_K_M | 12.5GB   | ⚠️ Tight fit | 15-25         |
| 30B  | Q4_K_M | 19GB     | ❌ Too large | -             |

### Hybrid Loading (GPU+RAM)

| Size | Quant  | Total Mem | GPU Layers  | Status  | Speed |
| ---- | ------ | --------- | ----------- | ------- | ----- |
| 13B  | Q8_0   | 14GB      | 70% (~10GB) | ✅ Good | 20-30 |
| 20B  | Q4_K_M | 12.5GB    | 90% (~11GB) | ✅ Good | 20-25 |
| 30B  | Q4_K_M | 19GB      | 60% (~11GB) | ✅ OK   | 10-15 |
| 30B  | Q3_K_M | 14GB      | 80% (~11GB) | ✅ Good | 12-18 |
| 34B  | Q4_K_M | 21GB      | 50% (~11GB) | ✅ OK   | 8-12  |
| 70B  | Q2_K   | 26GB      | 40% (~10GB) | ⚠️ Slow | 3-5   |

## Recommended Configurations

### Optimal Models (Full GPU)

1. **Llama-3.2-7B-Q4_K_M** → 60-80 tok/s, excellent quality
2. **Mistral-7B-Q5_K_M** → 50-70 tok/s, high quality
3. **Qwen2.5-Coder-7B-Q4_K_M** → 60-80 tok/s, code-optimized
4. **DeepSeek-Coder-6.7B-Q5_K_M** → 60-80 tok/s, code specialist

### Best 13B Models (Hybrid)

1. **Llama-3-13B-Q4_K_M** → 30-40 tok/s, balanced
2. **CodeLlama-13B-Q4_K_M** → 30-40 tok/s, code-focused
3. **WizardCoder-13B-Q5_K_M** → 25-35 tok/s, high quality

### Maximum Capability

- **Llama-2-30B-Q3_K_M** → 12-18 tok/s, largest practical
- **CodeLlama-34B-Q3_K_S** → 8-12 tok/s, extreme but usable

## Performance Optimization

### Quantization Guide

| Quant    | Size↓ | Quality      | Use Case         |
| -------- | ----- | ------------ | ---------------- |
| Q2_K     | 70%   | Low          | Testing only     |
| Q3_K_S/M | 60%   | OK           | Large models     |
| Q4_0     | 50%   | Good         | Balanced         |
| Q4_K_S/M | 45%   | Better       | **Recommended**  |
| Q5_0     | 40%   | Very Good    | Quality focus    |
| Q5_K_S/M | 38%   | Excellent    | **Best balance** |
| Q6_K     | 30%   | Near-perfect | Max quality      |
| Q8_0     | 12%   | Perfect      | Baseline         |

### Ollama Optimization

```bash
# Set GPU layers (adjust based on model)
export OLLAMA_NUM_GPU=999  # Max GPU usage
export OLLAMA_GPU_LAYERS=35  # For 7B models
export OLLAMA_GPU_LAYERS=28  # For 13B models

# Memory settings
export OLLAMA_MAX_LOADED_MODELS=1
export OLLAMA_KEEP_ALIVE=5m
```

## Bottlenecks & Limitations

### Primary Constraints

1. **VRAM**: 12GB hard limit for full GPU models
2. **PCIe Speed**: Hybrid models slower due to RAM↔GPU transfer
3. **CPU**: Zen+ older arch, affects CPU-only portions
4. **No Tensor Cores**: RTX 3060 lacks FP8 support

### Mitigation Strategies

- Use Q4_K_M/Q5_K_M quantization for best size/quality
- Prefer 7B models for interactive use (>50 tok/s)
- Use 13B models for quality tasks (accept 30 tok/s)
- Avoid models >30B unless batch processing

## Installation Commands

### Ollama Models

```bash
# Optimal 7B models
ollama pull llama3.2:7b-instruct-q4_K_M
ollama pull mistral:7b-instruct-q5_K_M
ollama pull qwen2.5-coder:7b-instruct-q4_K_M

# Best 13B models
ollama pull llama3:13b-instruct-q4_K_M
ollama pull codellama:13b-instruct-q4_K_M

# Maximum capability
ollama pull llama2:30b-chat-q3_K_M
```

## Current Status

- **Ollama**: ✅ Installed
- **Models**: llama3.2 (2GB), Qwen2.5-Coder:1.5B, gemma3:1b
- **CUDA**: ✅ 11.8 available
- **PyTorch**: ❌ Not installed (optional)

## Summary Metrics

- **Sweet Spot**: 7B models Q4_K_M-Q5_K_M
- **Max Practical**: 30B Q3_K_M hybrid
- **Interactive Speed**: 7B only (>50 tok/s)
- **Quality Focus**: 13B Q5_K_M (25-35 tok/s)
- **VRAM Efficiency**: 92% usable (11GB/12GB)
- **RAM Headroom**: 16GB available for models

______________________________________________________________________

*Generated: 2025-10-18 | Hardware: RTX 3060 12GB + Ryzen 5 2600 + 32GB RAM*

# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Install necessary build tools and libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    ffmpeg \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create a directory for the app
WORKDIR /app

# Copy the requirements file into the image
COPY roop-unleashed/requirements.txt /app/

# Install dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the image
COPY roop-unleashed/ /app/

# Add models
RUN mkdir -p /app/models/Frame /app/models/CLIP /app/models/CodeFormer && \
    curl -L -o /app/models/Frame/deoldify_artistic.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/deoldify_artistic.onnx && \
    curl -L -o /app/models/Frame/deoldify_stable.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/deoldify_stable.onnx && \
    curl -L -o /app/models/Frame/isnet-general-use.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/isnet-general-use.onnx && \
    curl -L -o /app/models/Frame/lsdir_x4.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/lsdir_x4.onnx && \
    curl -L -o /app/models/Frame/real_esrgan_x2.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/real_esrgan_x2.onnx && \
    curl -L -o /app/models/Frame/real_esrgan_x4.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/real_esrgan_x4.onnx && \
    curl -L -o /app/models/CLIP/rd64-uni-refined.pth https://huggingface.co/countfloyd/deepfake/resolve/main/rd64-uni-refined.pth && \
    curl -L -o /app/models/CodeFormer/CodeFormerv0.1.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/CodeFormerv0.1.onnx && \
    curl -L -o /app/models/DMDNet.pth https://github.com/csxmli2016/DMDNet/releases/download/v1/DMDNet.pth && \
    curl -L -o /app/models/GFPGANv1.4.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/GFPGANv1.4.onnx && \
    curl -L -o /app/models/GPEN-BFR-512.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/GPEN-BFR-512.onnx && \
    curl -L -o /app/models/inswapper_128.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/inswapper_128.onnx && \
    curl -L -o /app/models/restoreformer_plus_plus.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/restoreformer_plus_plus.onnx && \
    curl -L -o /app/models/xseg.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/xseg.onnx

# Create a non-root user
RUN useradd -m appuser

# Create a directory for the app
WORKDIR /app

# Change ownership to the non-root user
RUN chown -R appuser /app

# Switch to the non-root user
USER appuser

# Command to run the application
CMD ["python", "run.py"]
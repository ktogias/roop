FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu20.04

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary build tools and libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.9 \
    python3-pip \
    python3-setuptools \
    python3.9-dev \
    gcc \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    ffmpeg \
    tzdata \
    curl \
    unzip \
    libcufft10 \
    && rm -rf /var/lib/apt/lists/*

# Set the timezone to UTC
RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata

# Create a directory for the app
WORKDIR /app

# Copy the requirements file into the image
COPY roop-unleashed/requirements.txt /app/

# Install dependencies
RUN python3.9 -m pip install --upgrade pip && \
    python3.9 -m pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the image
COPY roop-unleashed/ /app/

# Add models
RUN mkdir -p /app/models/Frame /app/models/CLIP /app/models/CodeFormer && \
    curl -L -Z -o /app/models/Frame/deoldify_artistic.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/deoldify_artistic.onnx \
    -o /app/models/Frame/deoldify_stable.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/deoldify_stable.onnx \
    -o /app/models/Frame/isnet-general-use.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/isnet-general-use.onnx \
    -o /app/models/Frame/lsdir_x4.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/lsdir_x4.onnx \
    -o /app/models/Frame/real_esrgan_x2.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/real_esrgan_x2.onnx \
    -o /app/models/Frame/real_esrgan_x4.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/real_esrgan_x4.onnx \
    -o /app/models/CLIP/rd64-uni-refined.pth https://huggingface.co/countfloyd/deepfake/resolve/main/rd64-uni-refined.pth \
    -o /app/models/CodeFormer/CodeFormerv0.1.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/CodeFormerv0.1.onnx \
    -o /app/models/DMDNet.pth https://github.com/csxmli2016/DMDNet/releases/download/v1/DMDNet.pth \
    -o /app/models/GFPGANv1.4.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/GFPGANv1.4.onnx \
    -o /app/models/GPEN-BFR-512.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/GPEN-BFR-512.onnx \
    -o /app/models/inswapper_128.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/inswapper_128.onnx \
    -o /app/models/restoreformer_plus_plus.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/restoreformer_plus_plus.onnx \
    -o /app/models/xseg.onnx https://huggingface.co/countfloyd/deepfake/resolve/main/xseg.onnx \
    -o /app/models/buffalo_l.zip https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l.zip

RUN unzip /app/models/buffalo_l.zip -d /app/models/buffalo_l

# Copy settings
COPY settings.py /app/settings.py   

#ln libcufft.so
RUN ln -s /usr/local/cuda-12/lib64/libcufft.so.11 /usr/local/cuda-12/lib64/libcufft.so.10

# Create a non-root user
RUN useradd -m appuser

# Create a directory for the app
WORKDIR /app

# Change ownership to the non-root user
RUN chown -R appuser /app

# Switch to the non-root user
USER appuser

# Command to run the application
CMD ["python3.9", "run.py"]
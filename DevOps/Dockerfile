# Use the existing ROCm Composable Kernel image as the base
# FROM rocm/composable_kernel:ck_ub22.04_rocm6.3

# Use Ubuntu 22.04 (Jammy) as the base image
FROM ubuntu:jammy

# Install dependencies and GitHub CLI
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Copy the script into /usr/local/
COPY promote_ck.sh /promote_ck.sh

# Make the script executable
RUN chmod +x /promote_ck.sh

# Add alias for 'promote' command
RUN echo 'alias promote="/promote_ck.sh"' >> /etc/bash.bashrc

# Set default shell to bash
CMD ["/bin/bash"]
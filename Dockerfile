# Use Ruby 3.4.x
FROM ruby:3.4.2-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    libyaml-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock (will be created)
COPY Gemfile* ./

# Install Ruby dependencies
RUN bundle install

# Copy the application code
COPY . .

# Expose port 3000
EXPOSE 3000

# Make entrypoint script executable
RUN chmod +x /app/docker-entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# Default command
CMD ["rails", "server", "-b", "0.0.0.0"]

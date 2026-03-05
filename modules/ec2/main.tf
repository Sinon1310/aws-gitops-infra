# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# EC2 Instance
resource "aws_instance" "main" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    
    # Get instance metadata
    INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    
    cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>aws-gitops-infra | GitOps Infrastructure Automation</title>
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@300;400;700&family=Orbitron:wght@700;900&display=swap" rel="stylesheet">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    background: #050a0f;
    color: #c8e0f0;
    font-family: 'JetBrains Mono', monospace;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
  }
  body::before {
    content: '';
    position: fixed;
    inset: 0;
    background-image:
      linear-gradient(rgba(0,212,255,0.03) 1px, transparent 1px),
      linear-gradient(90deg, rgba(0,212,255,0.03) 1px, transparent 1px);
    background-size: 40px 40px;
  }
  .orb {
    position: fixed;
    border-radius: 50%;
    filter: blur(120px);
    pointer-events: none;
    animation: float 20s infinite ease-in-out;
  }
  @keyframes float {
    0%, 100% { transform: translate(0, 0); }
    50% { transform: translate(50px, -50px); }
  }
  .orb1 { width: 500px; height: 500px; background: rgba(0,212,255,0.07); top: -150px; right: -150px; }
  .orb2 { width: 400px; height: 400px; background: rgba(189,0,255,0.05); bottom: -100px; left: -100px; animation-delay: -10s; }
  .container {
    position: relative;
    z-index: 1;
    text-align: center;
    padding: 40px 24px;
    max-width: 900px;
  }
  .status-bar {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: rgba(57,255,20,0.08);
    border: 1px solid rgba(57,255,20,0.3);
    padding: 6px 16px;
    border-radius: 2px;
    font-size: 11px;
    letter-spacing: 3px;
    color: #39ff14;
    text-transform: uppercase;
    margin-bottom: 32px;
  }
  .dot {
    width: 7px; height: 7px;
    background: #39ff14;
    border-radius: 50%;
    animation: pulse 1.5s infinite;
  }
  @keyframes pulse {
    0%, 100% { opacity: 1; transform: scale(1); }
    50% { opacity: 0.4; transform: scale(0.8); }
  }
  h1 {
    font-family: 'Orbitron', monospace;
    font-size: clamp(2rem, 5vw, 4rem);
    font-weight: 900;
    color: #e8f4ff;
    line-height: 1.1;
    margin-bottom: 16px;
  }
  h1 span {
    background: linear-gradient(90deg, #00d4ff, #bd00ff);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }
  .tagline {
    font-size: 14px;
    color: #5a8aaa;
    margin-bottom: 40px;
    letter-spacing: 1px;
  }
  .metadata {
    background: rgba(0,212,255,0.03);
    border: 1px solid rgba(0,212,255,0.2);
    border-radius: 2px;
    padding: 16px;
    margin-bottom: 32px;
    font-size: 11px;
    display: flex;
    justify-content: center;
    gap: 24px;
    flex-wrap: wrap;
  }
  .metadata-item {
    display: flex;
    align-items: center;
    gap: 6px;
  }
  .metadata-label { color: #5a8aaa; }
  .metadata-value { color: #00d4ff; font-weight: 700; }
  .stats {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
    gap: 1px;
    margin-bottom: 40px;
    border: 1px solid #1a3a5c;
    border-radius: 2px;
    overflow: hidden;
    background: #1a3a5c;
  }
  .stat {
    padding: 24px 16px;
    background: #050a0f;
    transition: all 0.3s ease;
    cursor: default;
  }
  .stat:hover {
    background: rgba(0,212,255,0.03);
    transform: translateY(-2px);
  }
  .stat-val {
    font-family: 'Orbitron', monospace;
    font-size: 1.6rem;
    font-weight: 700;
    color: #00d4ff;
    display: block;
    margin-bottom: 6px;
  }
  .stat-label {
    font-size: 10px;
    letter-spacing: 2px;
    text-transform: uppercase;
    color: #5a8aaa;
  }
  .services {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    justify-content: center;
    margin-bottom: 32px;
  }
  .tag {
    font-size: 10px;
    padding: 6px 14px;
    background: rgba(0,212,255,0.06);
    border: 1px solid rgba(0,212,255,0.2);
    color: #00d4ff;
    border-radius: 2px;
    letter-spacing: 1px;
    transition: all 0.3s ease;
  }
  .tag:hover {
    background: rgba(0,212,255,0.12);
    border-color: rgba(0,212,255,0.4);
  }
  .arch {
    background: #0a1520;
    border: 1px solid #1a3a5c;
    border-radius: 2px;
    padding: 24px;
    text-align: left;
    font-size: 13px;
    line-height: 2;
    color: #5a8aaa;
    margin-bottom: 24px;
  }
  .arch .hl { color: #00d4ff; }
  .arch .hl2 { color: #e8f4ff; font-weight: 700; }
  .arch .arrow { color: #bd00ff; }
  .actions {
    display: flex;
    gap: 12px;
    justify-content: center;
    margin-bottom: 32px;
  }
  .btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 12px 24px;
    border-radius: 2px;
    font-size: 12px;
    letter-spacing: 1px;
    text-decoration: none;
    transition: all 0.3s ease;
    font-family: 'JetBrains Mono', monospace;
  }
  .btn-primary {
    background: rgba(0,212,255,0.1);
    border: 1px solid rgba(0,212,255,0.3);
    color: #00d4ff;
  }
  .btn-primary:hover {
    background: rgba(0,212,255,0.2);
    border-color: #00d4ff;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,212,255,0.2);
  }
  .btn-secondary {
    background: rgba(189,0,255,0.1);
    border: 1px solid rgba(189,0,255,0.3);
    color: #bd00ff;
  }
  .btn-secondary:hover {
    background: rgba(189,0,255,0.2);
    border-color: #bd00ff;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(189,0,255,0.2);
  }
  .footer {
    font-size: 11px;
    color: #2a4a6a;
    letter-spacing: 2px;
  }
  .footer span { color: #00d4ff; }
  .timestamp {
    font-size: 10px;
    color: #3a5a7a;
    margin-top: 16px;
  }
</style>
</head>
<body>
<div class="orb orb1"></div>
<div class="orb orb2"></div>
<div class="container">
  <div class="status-bar"><div class="dot"></div>Infrastructure Live</div>
  <h1>aws-gitops-<span>infra</span></h1>
  <p class="tagline">// GitOps · Terraform · AWS · Zero Manual Clicks</p>
  
  <div class="metadata">
    <div class="metadata-item">
      <span class="metadata-label">Public IP:</span>
      <span class="metadata-value" id="ip">Loading...</span>
    </div>
    <div class="metadata-item">
      <span class="metadata-label">Instance:</span>
      <span class="metadata-value" id="instance">Loading...</span>
    </div>
    <div class="metadata-item">
      <span class="metadata-label">Region:</span>
      <span class="metadata-value">ap-south-1a</span>
    </div>
  </div>

  <div class="stats">
    <div class="stat"><span class="stat-val">~$0</span><span class="stat-label">Monthly Cost</span></div>
    <div class="stat"><span class="stat-val">8</span><span class="stat-label">AWS Services</span></div>
    <div class="stat"><span class="stat-val">100%</span><span class="stat-label">Automated</span></div>
    <div class="stat"><span class="stat-val">IaC</span><span class="stat-label">Terraform</span></div>
  </div>
  
  <div class="services">
    <span class="tag">VPC</span>
    <span class="tag">EC2</span>
    <span class="tag">EIP</span>
    <span class="tag">CodePipeline</span>
    <span class="tag">CodeBuild</span>
    <span class="tag">S3</span>
    <span class="tag">DynamoDB</span>
    <span class="tag">CloudTrail</span>
    <span class="tag">IAM</span>
  </div>
  
  <div class="arch">
    <span class="hl2">GitOps Flow:</span><br>
    <span class="hl">git push</span> <span class="arrow">→</span> CodePipeline triggers <span class="arrow">→</span> CodeBuild runs<br>
    <span class="arrow">→</span> <span class="hl">terraform apply</span> <span class="arrow">→</span> AWS infra updated <span class="arrow">→</span> CloudTrail logs<br><br>
    <span class="hl2">Infrastructure:</span><br>
    VPC <span class="arrow">→</span> Public Subnet (ap-south-1a) <span class="arrow">→</span> EC2 t3.micro + Elastic IP<br>
    Remote State <span class="arrow">→</span> S3 + DynamoDB Lock<br>
    Audit <span class="arrow">→</span> CloudTrail <span class="arrow">→</span> S3
  </div>

  <div class="actions">
    <a href="https://github.com/Sinon1310/aws-gitops-infra" target="_blank" class="btn btn-primary">
      <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
        <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.012 8.012 0 0 0 16 8c0-4.42-3.58-8-8-8z"/>
      </svg>
      View on GitHub
    </a>
    <a href="https://github.com/Sinon1310" target="_blank" class="btn btn-secondary">
      Portfolio
    </a>
  </div>

  <div class="footer">
    BUILT BY <span>SINON RODRIGUES</span> · TERRAFORM + AWS · 2026
    <div class="timestamp">Last deployed: <span id="time">Loading...</span></div>
  </div>
</div>

<script>
  // Fetch instance metadata
  fetch('http://169.254.169.254/latest/meta-data/public-ipv4')
    .then(r => r.text())
    .then(ip => document.getElementById('ip').textContent = ip)
    .catch(() => document.getElementById('ip').textContent = 'Elastic IP');
  
  fetch('http://169.254.169.254/latest/meta-data/instance-id')
    .then(r => r.text())
    .then(id => document.getElementById('instance').textContent = id)
    .catch(() => document.getElementById('instance').textContent = 't3.micro');
  
  // Display current time
  document.getElementById('time').textContent = new Date().toLocaleString('en-US', {
    month: 'short', day: 'numeric', year: 'numeric', 
    hour: '2-digit', minute: '2-digit', timeZone: 'Asia/Kolkata', timeZoneName: 'short'
  });
</script>
</body>
</html>
HTML
  EOF
}

# Elastic IP
resource "aws_eip" "main" {
  instance = aws_instance.main.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-eip"
    Environment = var.environment
  }
}
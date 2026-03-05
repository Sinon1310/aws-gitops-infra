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
    cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>aws-gitops-infra</title>
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
  }
  .orb1 { width: 500px; height: 500px; background: rgba(0,212,255,0.07); top: -150px; right: -150px; }
  .orb2 { width: 400px; height: 400px; background: rgba(189,0,255,0.05); bottom: -100px; left: -100px; }
  .container {
    position: relative;
    z-index: 1;
    text-align: center;
    padding: 40px 24px;
    max-width: 800px;
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
    font-size: clamp(1.8rem, 5vw, 3.5rem);
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
    font-size: 13px;
    color: #5a8aaa;
    margin-bottom: 48px;
    letter-spacing: 1px;
  }
  .stats {
    display: flex;
    justify-content: center;
    gap: 0;
    margin-bottom: 48px;
    border: 1px solid #1a3a5c;
    border-radius: 2px;
    overflow: hidden;
  }
  .stat {
    flex: 1;
    padding: 20px;
    border-right: 1px solid #1a3a5c;
  }
  .stat:last-child { border-right: none; }
  .stat-val {
    font-family: 'Orbitron', monospace;
    font-size: 1.4rem;
    font-weight: 700;
    color: #00d4ff;
    display: block;
    margin-bottom: 4px;
  }
  .stat-label {
    font-size: 9px;
    letter-spacing: 2px;
    text-transform: uppercase;
    color: #5a8aaa;
  }
  .services {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    justify-content: center;
    margin-bottom: 40px;
  }
  .tag {
    font-size: 10px;
    padding: 5px 12px;
    background: rgba(0,212,255,0.06);
    border: 1px solid rgba(0,212,255,0.2);
    color: #00d4ff;
    border-radius: 2px;
    letter-spacing: 1px;
  }
  .arch {
    background: #0a1520;
    border: 1px solid #1a3a5c;
    border-radius: 2px;
    padding: 24px;
    text-align: left;
    font-size: 12px;
    line-height: 2;
    color: #5a8aaa;
    margin-bottom: 32px;
  }
  .arch .hl { color: #00d4ff; }
  .arch .hl2 { color: #e8f4ff; }
  .arch .arrow { color: #bd00ff; }
  .footer {
    font-size: 11px;
    color: #2a4a6a;
    letter-spacing: 2px;
  }
  .footer span { color: #00d4ff; }
</style>
</head>
<body>
<div class="orb orb1"></div>
<div class="orb orb2"></div>
<div class="container">
  <div class="status-bar"><div class="dot"></div>Infrastructure Live</div>
  <h1>aws-gitops-<span>infra</span></h1>
  <p class="tagline">// GitOps · Terraform · AWS · Zero Manual Clicks</p>
  <div class="stats">
    <div class="stat"><span class="stat-val">~$0</span><span class="stat-label">Monthly Cost</span></div>
    <div class="stat"><span class="stat-val">7</span><span class="stat-label">AWS Services</span></div>
    <div class="stat"><span class="stat-val">100%</span><span class="stat-label">Automated</span></div>
    <div class="stat"><span class="stat-val">IaC</span><span class="stat-label">Terraform</span></div>
  </div>
  <div class="services">
    <span class="tag">VPC</span>
    <span class="tag">EC2</span>
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
    VPC <span class="arrow">→</span> Public Subnet (ap-south-1a) <span class="arrow">→</span> EC2 t3.micro<br>
    Remote State <span class="arrow">→</span> S3 + DynamoDB Lock<br>
    Audit <span class="arrow">→</span> CloudTrail <span class="arrow">→</span> S3
  </div>
  <div class="footer">BUILT BY <span>SINON RODRIGUES</span> · TERRAFORM + AWS · 2026</div>
</div>
</body>
</html>
HTML
  EOF
}